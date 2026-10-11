package com.sportify.data;

import com.sportify.model.CustomerOverview;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;

import java.util.List;
import java.util.Locale;

public final class CustomerDB {

    private CustomerDB() {
    }

    public static List<CustomerOverview> findByOwnerId(Long ownerId, String search) {
        requireOwnerId(ownerId);
        String normalizedSearch = normalizeSearch(search);
        return findByOwnerId(
                DBUtil.getEntityManagerFactory().createEntityManager(),
                ownerId, normalizedSearch);
    }

    static List<CustomerOverview> findByOwnerId(
            EntityManager em, Long ownerId, String search) {
        // TODO: group by customer/user ID when Booking and user accounts are available.
        // Never infer a stable customer identity by matching names to other tables.
        String jpql =
                "SELECT NEW com.sportify.model.CustomerOverview(" +
                "review.customerName, COUNT(review), " +
                "COUNT(DISTINCT field.fieldId), AVG(review.rating), MAX(review.createdAt)) " +
                "FROM Review review JOIN review.field field " +
                "WHERE field.ownerId = :ownerId ";
        if (search != null && !search.isEmpty()) {
            jpql += "AND LOWER(review.customerName) LIKE :search ESCAPE '!' ";
        }
        jpql += "GROUP BY review.customerName " +
                "ORDER BY MAX(review.createdAt) DESC, review.customerName ASC";

        try {
            TypedQuery<CustomerOverview> query = em.createQuery(jpql, CustomerOverview.class);
            query.setParameter("ownerId", ownerId);
            if (search != null && !search.isEmpty()) {
                String escaped = search.toLowerCase(Locale.ROOT)
                        .replace("!", "!!").replace("%", "!%").replace("_", "!_");
                query.setParameter("search", "%" + escaped + "%");
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
                    "SELECT COUNT(DISTINCT review.customerName), COUNT(review), " +
                    "COUNT(DISTINCT field.fieldId) " +
                    "FROM Review review JOIN review.field field " +
                    "WHERE field.ownerId = :ownerId", Object[].class)
                    .setParameter("ownerId", ownerId)
                    .getSingleResult();
            return new Summary(((Number) result[0]).longValue(),
                    ((Number) result[1]).longValue(), ((Number) result[2]).longValue());
        } finally {
            em.close();
        }
    }

    private static void requireOwnerId(Long ownerId) {
        if (ownerId == null || ownerId <= 0) {
            throw new IllegalArgumentException("Mã chủ sân không hợp lệ.");
        }
    }

    public static String normalizeSearch(String value) {
        String search = value == null ? "" : value.trim();
        if (search.length() > 100) {
            throw new IllegalArgumentException("Từ khóa tìm kiếm chỉ được tối đa 100 ký tự.");
        }
        return search;
    }

    public static final class Summary {
        private final long customerNameCount;
        private final long reviewCount;
        private final long fieldCount;

        private Summary(long customerNameCount, long reviewCount, long fieldCount) {
            this.customerNameCount = customerNameCount;
            this.reviewCount = reviewCount;
            this.fieldCount = fieldCount;
        }

        public long getCustomerNameCount() {
            return customerNameCount;
        }

        public long getReviewCount() {
            return reviewCount;
        }

        public long getFieldCount() {
            return fieldCount;
        }
    }
}
