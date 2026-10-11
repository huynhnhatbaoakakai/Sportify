package com.sportify.data;

import com.sportify.model.CustomerOverview;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import static org.junit.Assert.*;

/** Opt-in test using the same disposable PostgreSQL fixtures as ReviewDBIntegrationTest. */
public class CustomerDBIntegrationTest {

    private static EntityManagerFactory factory;
    private static String url;
    private static String sharedCustomerName;
    private static Long extraFieldId;
    private static final List<Long> insertedReviewIds = new ArrayList<Long>();
    private static final String LITERAL_NAME = "Khách %_! <script>alert(1)</script>";

    @BeforeClass
    public static void createDisposableFixtures() throws Exception {
        url = System.getProperty("sportify.reviewTestUrl");
        Assume.assumeTrue("Requires a disposable PostgreSQL test database", url != null);
        try (Connection connection = connect();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT r.customer_name FROM reviews r JOIN sports_fields f " +
                     "ON f.field_id = r.field_id WHERE f.owner_id = 1 AND r.rating = 4 LIMIT 1");
             ResultSet result = statement.executeQuery()) {
            assertTrue(result.next());
            sharedCustomerName = result.getString(1);
        }
        extraFieldId = insertReturningId(
                "INSERT INTO sports_fields (owner_id, field_name, sport_type, address, " +
                "price_per_hour, open_time, close_time, status) " +
                "SELECT owner_id, 'Customer test extra field', sport_type, address, " +
                "price_per_hour, open_time, close_time, status FROM sports_fields " +
                "WHERE owner_id = 1 ORDER BY field_id LIMIT 1 RETURNING field_id");
        insertedReviewIds.add(insertReturningId(
                "INSERT INTO reviews (field_id, customer_name, rating, comment) " +
                "VALUES (?, ?, 2, 'Additional review') RETURNING review_id",
                extraFieldId, sharedCustomerName));
        insertedReviewIds.add(insertReturningId(
                "INSERT INTO reviews (field_id, customer_name, rating, comment) " +
                "SELECT field_id, ?, 5, 'Literal wildcard test' FROM sports_fields " +
                "WHERE owner_id = 1 ORDER BY field_id LIMIT 1 RETURNING review_id", LITERAL_NAME));
        insertedReviewIds.add(insertReturningId(
                "INSERT INTO reviews (field_id, customer_name, rating, comment) " +
                "SELECT field_id, ?, 1, 'Same name at foreign owner' FROM sports_fields " +
                "WHERE owner_id = 2 ORDER BY field_id LIMIT 1 RETURNING review_id", sharedCustomerName));
        insertedReviewIds.add(insertReturningId(
                "INSERT INTO reviews (field_id, customer_name, rating, comment) " +
                "SELECT field_id, 'Foreign customer only', 1, 'Foreign review' FROM sports_fields " +
                "WHERE owner_id = 2 ORDER BY field_id LIMIT 1 RETURNING review_id"));

        Map<String, Object> properties = new HashMap<String, Object>();
        properties.put("jakarta.persistence.jdbc.url", url);
        properties.put("jakarta.persistence.jdbc.user", "sportify_review_test");
        properties.put("jakarta.persistence.jdbc.password", "");
        properties.put("hibernate.show_sql", "false");
        factory = Persistence.createEntityManagerFactory("sportifyPU", properties);
    }

    @AfterClass
    public static void removeDisposableFixtures() throws Exception {
        if (factory != null) factory.close();
        if (url == null) return;
        try (Connection connection = connect()) {
            try (PreparedStatement statement = connection.prepareStatement("DELETE FROM reviews WHERE review_id = ?")) {
                for (Long id : insertedReviewIds) {
                    statement.setLong(1, id);
                    statement.executeUpdate();
                }
            }
            if (extraFieldId != null) {
                try (PreparedStatement statement = connection.prepareStatement("DELETE FROM sports_fields WHERE field_id = ?")) {
                    statement.setLong(1, extraFieldId);
                    statement.executeUpdate();
                }
            }
        }
    }

    @Test
    public void aggregatesOnlyOwnedReviewsForEachName() {
        List<CustomerOverview> customers = CustomerDB.findByOwnerId(factory.createEntityManager(), 1L, "");
        assertEquals(6, customers.size());
        CustomerOverview shared = customers.stream()
                .filter(customer -> sharedCustomerName.equals(customer.getCustomerName()))
                .findFirst().get();
        assertEquals(2, shared.getReviewCount());
        assertEquals(2, shared.getFieldCount());
        assertEquals(3.0, shared.getAverageRating(), 0.001);
        assertFalse(customers.stream().anyMatch(customer -> "Foreign customer only".equals(customer.getCustomerName())));
        for (int index = 1; index < customers.size(); index++) {
            assertFalse(customers.get(index).getLastReviewAt().isAfter(customers.get(index - 1).getLastReviewAt()));
        }
    }

    @Test
    public void searchesNamesWithoutExpandingLiteralWildcards() {
        for (String search : new String[]{"%", "_", "!"}) {
            List<CustomerOverview> matches = CustomerDB.findByOwnerId(factory.createEntityManager(), 1L, search);
            assertEquals(1, matches.size());
            assertEquals(LITERAL_NAME, matches.get(0).getCustomerName());
        }
        List<CustomerOverview> matches = CustomerDB.findByOwnerId(
                factory.createEntityManager(), 1L, sharedCustomerName.toUpperCase(Locale.ROOT));
        assertEquals(1, matches.size());
        assertEquals(sharedCustomerName, matches.get(0).getCustomerName());
        assertTrue(CustomerDB.findByOwnerId(factory.createEntityManager(), 1L, "' OR 1=1 --").isEmpty());
    }

    @Test
    public void summaryCountsOwnedNamesReviewsAndDistinctFields() {
        CustomerDB.Summary summary = CustomerDB.getSummaryByOwnerId(factory.createEntityManager(), 1L);
        assertEquals(6, summary.getCustomerNameCount());
        assertEquals(7, summary.getReviewCount());
        assertEquals(2, summary.getFieldCount());
    }

    @Test
    public void returnsEmptyResultsForOwnerWithoutReviews() {
        assertTrue(CustomerDB.findByOwnerId(factory.createEntityManager(), 99L, "").isEmpty());
        CustomerDB.Summary summary = CustomerDB.getSummaryByOwnerId(factory.createEntityManager(), 99L);
        assertEquals(0, summary.getCustomerNameCount());
        assertEquals(0, summary.getReviewCount());
        assertEquals(0, summary.getFieldCount());
    }

    private static Connection connect() throws Exception {
        return DriverManager.getConnection(url, "sportify_review_test", "");
    }

    private static Long insertReturningId(String sql, Object... parameters) throws Exception {
        try (Connection connection = connect();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            for (int index = 0; index < parameters.length; index++) statement.setObject(index + 1, parameters[index]);
            try (ResultSet result = statement.executeQuery()) {
                assertTrue(result.next());
                return result.getLong(1);
            }
        }
    }
}
