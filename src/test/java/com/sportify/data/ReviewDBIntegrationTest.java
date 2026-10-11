package com.sportify.data;

import com.sportify.model.Review;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import org.junit.AfterClass;
import org.junit.Assume;
import org.junit.BeforeClass;
import org.junit.Test;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.*;

/** Opt-in: run only against the disposable PostgreSQL instance used for review tests. */
public class ReviewDBIntegrationTest {

    private static EntityManagerFactory factory;
    private static Long foreignReviewId;

    @BeforeClass
    public static void connectToDisposableDatabase() throws Exception {
        String url = System.getProperty("sportify.reviewTestUrl");
        Assume.assumeTrue("Requires a disposable PostgreSQL test database", url != null);
        // The test cluster uses its own role and a separate port, never the app's DB credentials.
        try (Connection connection = DriverManager.getConnection(url, "sportify_review_test", "");
             PreparedStatement statement = connection.prepareStatement(
                     "INSERT INTO public.reviews (field_id, customer_name, rating, comment) " +
                     "SELECT field_id, 'Other owner customer', 5, 'Private review' " +
                     "FROM public.sports_fields WHERE owner_id = 2 RETURNING review_id")) {
            try (ResultSet result = statement.executeQuery()) {
                assertTrue(result.next());
                foreignReviewId = result.getLong(1);
            }
        }
        Map<String, Object> properties = new HashMap<String, Object>();
        properties.put("jakarta.persistence.jdbc.url", url);
        properties.put("jakarta.persistence.jdbc.user", "sportify_review_test");
        properties.put("jakarta.persistence.jdbc.password", "");
        properties.put("hibernate.show_sql", "false");
        factory = Persistence.createEntityManagerFactory("sportifyPU", properties);
    }

    @AfterClass
    public static void closeFactory() {
        if (factory != null) factory.close();
    }

    @Test
    public void listsOnlyOwnedReviewsNewestFirstWithFieldLoaded() {
        List<Review> reviews = ReviewDB.findByOwnerId(factory.createEntityManager(), 1L, null);
        assertEquals(5, reviews.size());
        for (int index = 0; index < reviews.size(); index++) {
            Review review = reviews.get(index);
            assertEquals(Long.valueOf(1), review.getField().getOwnerId());
            assertNotNull(review.getField().getFieldName());
            if (index > 0) {
                assertFalse(review.getCreatedAt().isAfter(reviews.get(index - 1).getCreatedAt()));
            }
        }
    }

    @Test
    public void filtersEveryStarRatingWithinOwnerScope() {
        for (int stars = 1; stars <= 5; stars++) {
            List<Review> reviews = ReviewDB.findByOwnerId(factory.createEntityManager(), 1L, stars);
            assertEquals(1, reviews.size());
            assertEquals(Integer.valueOf(stars), reviews.get(0).getRating());
            assertEquals(Long.valueOf(1), reviews.get(0).getField().getOwnerId());
        }
    }

    @Test
    public void summaryExcludesOtherOwnersAndHandlesEmptyOwner() {
        ReviewDB.Summary owned = ReviewDB.getSummaryByOwnerId(factory.createEntityManager(), 1L);
        assertEquals(5, owned.getTotalCount());
        assertEquals(3.0, owned.getAverageRating(), 0.001);
        ReviewDB.Summary empty = ReviewDB.getSummaryByOwnerId(factory.createEntityManager(), 99L);
        assertEquals(0, empty.getTotalCount());
        assertEquals(0.0, empty.getAverageRating(), 0.001);
        assertTrue(ReviewDB.findByOwnerId(factory.createEntityManager(), 99L, null).isEmpty());
    }

    @Test
    public void cannotReplyToForeignOrMissingReview() {
        assertFalse(ReviewDB.saveOwnerReply(factory.createEntityManager(), foreignReviewId, 1L, "Forbidden"));
        assertFalse(ReviewDB.saveOwnerReply(factory.createEntityManager(), Long.MAX_VALUE, 1L, "Missing"));
        EntityManager em = factory.createEntityManager();
        try {
            assertNull(em.find(Review.class, foreignReviewId).getOwnerReply());
        } finally {
            em.close();
        }
    }

    @Test
    public void createsAndUpdatesReplyPersistedAcrossNewEntityManagers() {
        Review review = ReviewDB.findByOwnerId(factory.createEntityManager(), 1L, 4).get(0);
        Long id = review.getReviewId();
        String reply = "Cảm ơn bạn! <script>alert(1)</script> </textarea>";
        assertTrue(ReviewDB.saveOwnerReply(factory.createEntityManager(), id, 1L, reply));
        EntityManager em = factory.createEntityManager();
        try {
            Review saved = em.find(Review.class, id);
            assertEquals(reply, saved.getOwnerReply());
            assertNotNull(saved.getRepliedAt());
        } finally {
            em.close();
        }
        assertTrue(ReviewDB.saveOwnerReply(factory.createEntityManager(), id, 1L, "Phản hồi đã cập nhật"));
        em = factory.createEntityManager();
        try {
            assertEquals("Phản hồi đã cập nhật", em.find(Review.class, id).getOwnerReply());
        } finally {
            em.close();
        }
    }
}
