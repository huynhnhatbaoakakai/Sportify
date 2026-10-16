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

    public static List<com.sportify.model.CustomerBookingProfile> findBookingCustomersByOwnerId(Long ownerId, String search) {
        requireOwnerId(ownerId);
        List<com.sportify.model.Booking> allBookings = BookingDB.findByOwnerId(ownerId);
        java.util.Map<Integer, com.sportify.model.User> userMap = new com.sportify.dao.UserDAO().getAllUsersMap();

        java.util.Map<String, com.sportify.model.CustomerBookingProfile> profileMap = new java.util.LinkedHashMap<>();

        for (com.sportify.model.Booking booking : allBookings) {
            String key;
            if (booking.getCustomerId() != null && booking.getCustomerId() > 0) {
                key = "UID_" + booking.getCustomerId();
            } else if (booking.getCustomerPhone() != null && !booking.getCustomerPhone().trim().isEmpty()) {
                key = "PHONE_" + booking.getCustomerPhone().trim();
            } else {
                key = "NAME_" + (booking.getCustomerName() != null ? booking.getCustomerName().trim().toLowerCase(Locale.ROOT) : "guest");
            }

            com.sportify.model.CustomerBookingProfile profile = profileMap.get(key);
            if (profile == null) {
                profile = new com.sportify.model.CustomerBookingProfile();
                profile.setCustomerKey(key);
                profile.setCustomerId(booking.getCustomerId());
                profile.setCustomerName(booking.getCustomerName());
                profile.setCustomerPhone(booking.getCustomerPhone());

                if (booking.getCustomerId() != null && userMap.containsKey(booking.getCustomerId())) {
                    com.sportify.model.User u = userMap.get(booking.getCustomerId());
                    profile.setAccountName(u.getFullname());
                    profile.setEmail(u.getEmail());
                    if ((profile.getCustomerPhone() == null || profile.getCustomerPhone().trim().isEmpty())
                            && u.getPhone() != null && !u.getPhone().trim().isEmpty()) {
                        profile.setCustomerPhone(u.getPhone());
                    }
                }
                profileMap.put(key, profile);
            } else {
                if ((profile.getCustomerPhone() == null || profile.getCustomerPhone().trim().isEmpty())
                        && booking.getCustomerPhone() != null && !booking.getCustomerPhone().trim().isEmpty()) {
                    profile.setCustomerPhone(booking.getCustomerPhone().trim());
                }
            }

            profile.addBooking(booking);
        }

        List<com.sportify.model.CustomerBookingProfile> resultList = new java.util.ArrayList<>(profileMap.values());

        if (search != null && !search.trim().isEmpty()) {
            String q = search.trim().toLowerCase(Locale.ROOT);
            List<com.sportify.model.CustomerBookingProfile> filteredList = new java.util.ArrayList<>();
            for (com.sportify.model.CustomerBookingProfile p : resultList) {
                boolean matchName = p.getCustomerName() != null && p.getCustomerName().toLowerCase(Locale.ROOT).contains(q);
                boolean matchPhone = p.getCustomerPhone() != null && p.getCustomerPhone().toLowerCase(Locale.ROOT).contains(q);
                boolean matchEmail = p.getEmail() != null && p.getEmail().toLowerCase(Locale.ROOT).contains(q);
                boolean matchAccount = p.getAccountName() != null && p.getAccountName().toLowerCase(Locale.ROOT).contains(q);
                boolean matchBooking = p.getBookingHistory().stream().anyMatch(b ->
                        b.getBookingCode().toLowerCase(Locale.ROOT).contains(q)
                        || (b.getField() != null && b.getField().getFieldName().toLowerCase(Locale.ROOT).contains(q)));

                if (matchName || matchPhone || matchEmail || matchAccount || matchBooking) {
                    filteredList.add(p);
                }
            }
            resultList = filteredList;
        }

        resultList.sort((a, b) -> {
            if (a.getLastBookingAt() == null && b.getLastBookingAt() == null) return 0;
            if (a.getLastBookingAt() == null) return 1;
            if (b.getLastBookingAt() == null) return -1;
            return b.getLastBookingAt().compareTo(a.getLastBookingAt());
        });

        return resultList;
    }

    public static BookingCustomerSummary getBookingCustomersSummary(Long ownerId) {
        requireOwnerId(ownerId);
        List<com.sportify.model.CustomerBookingProfile> customers = findBookingCustomersByOwnerId(ownerId, "");
        long totalCustomers = customers.size();
        long totalBookings = 0;
        java.math.BigDecimal totalRevenue = java.math.BigDecimal.ZERO;
        long pendingBookings = 0;

        for (com.sportify.model.CustomerBookingProfile p : customers) {
            totalBookings += p.getTotalBookings();
            totalRevenue = totalRevenue.add(p.getTotalSpent());
            pendingBookings += p.getPendingBookings();
        }

        return new BookingCustomerSummary(totalCustomers, totalBookings, totalRevenue, pendingBookings);
    }

    public static final class BookingCustomerSummary {
        private final long totalCustomers;
        private final long totalBookings;
        private final java.math.BigDecimal totalRevenue;
        private final long pendingBookings;

        public BookingCustomerSummary(long totalCustomers, long totalBookings, java.math.BigDecimal totalRevenue, long pendingBookings) {
            this.totalCustomers = totalCustomers;
            this.totalBookings = totalBookings;
            this.totalRevenue = totalRevenue != null ? totalRevenue : java.math.BigDecimal.ZERO;
            this.pendingBookings = pendingBookings;
        }

        public long getTotalCustomers() { return totalCustomers; }
        public long getTotalBookings() { return totalBookings; }
        public java.math.BigDecimal getTotalRevenue() { return totalRevenue; }
        public long getPendingBookings() { return pendingBookings; }
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
