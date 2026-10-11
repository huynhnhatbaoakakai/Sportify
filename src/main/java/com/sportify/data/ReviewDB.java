package com.sportify.data;

import com.sportify.model.Review;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.Query;
import jakarta.persistence.TypedQuery;

import java.time.LocalDateTime;
import java.util.List;

public final class ReviewDB {

    private ReviewDB() {
    }

    public static List<Review> findByOwnerId(Long ownerId, Integer rating) {
        requireOwnerId(ownerId);
        if (rating != null && (rating < 1 || rating > 5)) {
            throw new IllegalArgumentException("Số sao không hợp lệ.");
        }

        return findByOwnerId(
                DBUtil.getEntityManagerFactory().createEntityManager(),
                ownerId, rating);
    }

    static List<Review> findByOwnerId(
            EntityManager em, Long ownerId, Integer rating) {
        String jpql =
                "SELECT review FROM Review review " +
                "JOIN FETCH review.field field " +
                "WHERE field.ownerId = :ownerId ";

        if (rating != null) {
            jpql += "AND review.rating = :rating ";
        }
        jpql += "ORDER BY review.createdAt DESC, review.reviewId DESC";

        try {
            TypedQuery<Review> query = em.createQuery(jpql, Review.class);
            query.setParameter("ownerId", ownerId);
            if (rating != null) {
                query.setParameter("rating", rating);
            }
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    public static Summary getSummaryByOwnerId(Long ownerId) {
        requireOwnerId(ownerId);
        return getSummaryByOwnerId(
                DBUtil.getEntityManagerFactory().createEntityManager(), ownerId);
    }

    static Summary getSummaryByOwnerId(EntityManager em, Long ownerId) {
        try {
            Object[] result = em.createQuery(
                    "SELECT COUNT(review), AVG(review.rating) " +
                    "FROM Review review WHERE review.field.ownerId = :ownerId",
                    Object[].class)
                    .setParameter("ownerId", ownerId)
                    .getSingleResult();

            long count = ((Number) result[0]).longValue();
            double average = result[1] == null
                    ? 0.0 : ((Number) result[1]).doubleValue();
            return new Summary(count, average);
        } finally {
            em.close();
        }
    }

    public static boolean saveOwnerReply(
            Long reviewId, Long ownerId, String ownerReply) {
        requireOwnerId(ownerId);
        if (reviewId == null || reviewId <= 0) {
            throw new IllegalArgumentException("Mã đánh giá không hợp lệ.");
        }
        if (ownerReply == null || ownerReply.trim().isEmpty()
                || ownerReply.length() > 2000) {
            throw new IllegalArgumentException("Phản hồi không hợp lệ.");
        }

        return saveOwnerReply(
                DBUtil.getEntityManagerFactory().createEntityManager(),
                reviewId, ownerId, ownerReply.trim());
    }

    static boolean saveOwnerReply(
            EntityManager em, Long reviewId, Long ownerId, String ownerReply) {
        EntityTransaction transaction = em.getTransaction();

        try {
            transaction.begin();

            // Ownership is checked in the UPDATE itself, including for forged IDs.
            Query query = em.createQuery(
                    "UPDATE Review review " +
                    "SET review.ownerReply = :ownerReply, " +
                    "review.repliedAt = :repliedAt " +
                    "WHERE review.reviewId = :reviewId " +
                    "AND review.field.fieldId IN " +
                    "(SELECT field.fieldId FROM SportField field " +
                    "WHERE field.ownerId = :ownerId)");
            query.setParameter("ownerReply", ownerReply);
            query.setParameter("repliedAt", LocalDateTime.now());
            query.setParameter("reviewId", reviewId);
            query.setParameter("ownerId", ownerId);

            int updated = query.executeUpdate();
            transaction.commit();
            return updated == 1;
        } catch (RuntimeException exception) {
            if (transaction.isActive()) {
                transaction.rollback();
            }
            throw exception;
        } finally {
            em.close();
        }
    }

    private static void requireOwnerId(Long ownerId) {
        if (ownerId == null || ownerId <= 0) {
            throw new IllegalArgumentException("Mã chủ sân không hợp lệ.");
        }
    }

    public static final class Summary {
        private final long totalCount;
        private final double averageRating;

        private Summary(long totalCount, double averageRating) {
            this.totalCount = totalCount;
            this.averageRating = averageRating;
        }

        public long getTotalCount() {
            return totalCount;
        }

        public double getAverageRating() {
            return averageRating;
        }
    }
}
