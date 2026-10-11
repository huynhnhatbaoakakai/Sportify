package com.sportify.data;

import com.sportify.model.Booking;
import com.sportify.model.SportField;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.LockModeType;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;

public final class BookingDB {

    private BookingDB() {
    }

    public static List<Booking> findByOwnerId(Long ownerId) {
        requireOwnerId(ownerId);
        return findByOwnerId(DBUtil.getEntityManagerFactory().createEntityManager(), ownerId);
    }

    static List<Booking> findByOwnerId(EntityManager em, Long ownerId) {
        try {
            return em.createQuery(
                    "SELECT booking FROM Booking booking JOIN FETCH booking.field field " +
                    "WHERE field.ownerId = :ownerId " +
                    "ORDER BY booking.createdAt DESC, booking.bookingId DESC", Booking.class)
                    .setParameter("ownerId", ownerId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public static Summary getDashboardSummary(Long ownerId, LocalDate date) {
        requireOwnerId(ownerId);
        if (date == null) throw new IllegalArgumentException("Thiếu ngày thống kê.");
        return getDashboardSummary(DBUtil.getEntityManagerFactory().createEntityManager(), ownerId, date);
    }

    static Summary getDashboardSummary(EntityManager em, Long ownerId, LocalDate date) {
        try {
            Object[] result = em.createQuery(
                    "SELECT " +
                    "SUM(CASE WHEN booking.startsAt >= :dayStart AND booking.startsAt < :dayEnd " +
                    "AND booking.status IN ('PENDING', 'CONFIRMED', 'COMPLETED') THEN 1 ELSE 0 END), " +
                    "SUM(CASE WHEN booking.status = 'PENDING' THEN 1 ELSE 0 END), " +
                    "SUM(CASE WHEN booking.status = 'COMPLETED' " +
                    "AND booking.startsAt >= :dayStart AND booking.startsAt < :dayEnd " +
                    "THEN booking.totalPrice ELSE 0 END) " +
                    "FROM Booking booking WHERE booking.field.ownerId = :ownerId", Object[].class)
                    .setParameter("ownerId", ownerId)
                    .setParameter("dayStart", date.atStartOfDay())
                    .setParameter("dayEnd", date.plusDays(1).atStartOfDay())
                    .getSingleResult();
            return new Summary(
                    result[0] == null ? 0 : ((Number) result[0]).longValue(),
                    result[1] == null ? 0 : ((Number) result[1]).longValue(),
                    result[2] == null ? BigDecimal.ZERO : new BigDecimal(result[2].toString()));
        } finally {
            em.close();
        }
    }

    public static StatusChangeResult changeStatus(Long bookingId, Long ownerId, String status) {
        requireOwnerId(ownerId);
        if (bookingId == null || bookingId <= 0) {
            throw new IllegalArgumentException("Mã đơn không hợp lệ.");
        }
        if (!"CONFIRMED".equals(status) && !"REJECTED".equals(status)) {
            throw new IllegalArgumentException("Thao tác không hợp lệ.");
        }
        return changeStatus(DBUtil.getEntityManagerFactory().createEntityManager(),
                bookingId, ownerId, status, LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")));
    }

    static StatusChangeResult changeStatus(
            EntityManager em, Long bookingId, Long ownerId, String status, LocalDateTime now) {
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            List<Long> fieldIds = em.createQuery(
                    "SELECT booking.field.fieldId FROM Booking booking " +
                    "WHERE booking.bookingId = :bookingId AND booking.field.ownerId = :ownerId", Long.class)
                    .setParameter("bookingId", bookingId)
                    .setParameter("ownerId", ownerId)
                    .getResultList();
            if (fieldIds.isEmpty()) return cancel(transaction, StatusChangeResult.NOT_FOUND);

            // Always lock field first, then booking: confirmations for one field are serialized.
            SportField field = em.find(SportField.class, fieldIds.get(0), LockModeType.PESSIMISTIC_WRITE);
            Booking booking = em.find(Booking.class, bookingId, LockModeType.PESSIMISTIC_WRITE);
            if (field == null || booking == null || !ownerId.equals(field.getOwnerId())
                    || !field.getFieldId().equals(booking.getField().getFieldId())) {
                return cancel(transaction, StatusChangeResult.NOT_FOUND);
            }
            if (!"PENDING".equals(booking.getStatus())) {
                return cancel(transaction, StatusChangeResult.NOT_PENDING);
            }

            if ("CONFIRMED".equals(status)) {
                if (!"ACTIVE".equals(field.getStatus())) {
                    return cancel(transaction, StatusChangeResult.FIELD_INACTIVE);
                }
                if (booking.getStartsAt().isBefore(now)
                        || !booking.getEndsAt().isAfter(booking.getStartsAt())
                        || !booking.getStartsAt().toLocalDate().equals(booking.getEndsAt().toLocalDate())
                        || booking.getStartsAt().toLocalTime().isBefore(field.getOpenTime())
                        || booking.getEndsAt().toLocalTime().isAfter(field.getCloseTime())) {
                    return cancel(transaction, StatusChangeResult.INVALID_TIME);
                }
                long conflicts = em.createQuery(
                        "SELECT COUNT(other) FROM Booking other " +
                        "WHERE other.field.fieldId = :fieldId AND other.bookingId <> :bookingId " +
                        "AND other.status IN ('CONFIRMED', 'COMPLETED') " +
                        "AND other.startsAt < :endsAt AND other.endsAt > :startsAt", Long.class)
                        .setParameter("fieldId", field.getFieldId())
                        .setParameter("bookingId", bookingId)
                        .setParameter("startsAt", booking.getStartsAt())
                        .setParameter("endsAt", booking.getEndsAt())
                        .getSingleResult();
                if (conflicts > 0) return cancel(transaction, StatusChangeResult.CONFLICT);
            }

            booking.setStatus(status);
            booking.setUpdatedAt(now);
            transaction.commit();
            return StatusChangeResult.UPDATED;
        } catch (RuntimeException exception) {
            if (transaction.isActive()) transaction.rollback();
            // PostgreSQL exclusion constraint also protects writes from other clients.
            Throwable cause = exception;
            for (int depth = 0; cause != null && depth < 20; depth++, cause = cause.getCause()) {
                if (cause instanceof SQLException && "23P01".equals(((SQLException) cause).getSQLState())) {
                    return StatusChangeResult.CONFLICT;
                }
            }
            throw exception;
        } finally {
            em.close();
        }
    }

    private static StatusChangeResult cancel(EntityTransaction transaction, StatusChangeResult result) {
        transaction.rollback();
        return result;
    }

    private static void requireOwnerId(Long ownerId) {
        if (ownerId == null || ownerId <= 0) throw new IllegalArgumentException("Mã chủ sân không hợp lệ.");
    }

    // ===================== Phía khách hàng =====================

    /** Danh sách đơn đặt sân của một khách hàng (mới nhất trước). */
    public static List<Booking> findByCustomerId(int customerId) {
        EntityManager em = DBUtil.getEntityManagerFactory().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT booking FROM Booking booking JOIN FETCH booking.field field " +
                    "WHERE booking.customerId = :customerId " +
                    "ORDER BY booking.startsAt DESC, booking.bookingId DESC", Booking.class)
                    .setParameter("customerId", customerId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Khách tạo đơn đặt sân mới (trạng thái PENDING) — chủ sân sẽ xác nhận / từ chối
     * trong kênh chủ sân.
     */
    public static CreateResult createCustomerBooking(
            Long fieldId, int customerId, String customerName, String customerPhone,
            LocalDateTime startsAt, LocalDateTime endsAt) {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        EntityManager em = DBUtil.getEntityManagerFactory().createEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            SportField field = fieldId == null ? null : em.find(SportField.class, fieldId);
            if (field == null) return rollback(transaction, CreateResult.FIELD_NOT_FOUND);
            if (!"ACTIVE".equals(field.getStatus())) return rollback(transaction, CreateResult.FIELD_INACTIVE);

            if (startsAt == null || endsAt == null
                    || !endsAt.isAfter(startsAt)
                    || !startsAt.toLocalDate().equals(endsAt.toLocalDate())
                    || startsAt.toLocalTime().isBefore(field.getOpenTime())
                    || endsAt.toLocalTime().isAfter(field.getCloseTime())) {
                return rollback(transaction, CreateResult.INVALID_TIME);
            }
            if (!startsAt.isAfter(now)) return rollback(transaction, CreateResult.PAST_TIME);

            long conflicts = em.createQuery(
                    "SELECT COUNT(other) FROM Booking other " +
                    "WHERE other.field.fieldId = :fieldId " +
                    "AND other.status IN ('CONFIRMED', 'COMPLETED') " +
                    "AND other.startsAt < :endsAt AND other.endsAt > :startsAt", Long.class)
                    .setParameter("fieldId", field.getFieldId())
                    .setParameter("startsAt", startsAt)
                    .setParameter("endsAt", endsAt)
                    .getSingleResult();
            if (conflicts > 0) return rollback(transaction, CreateResult.CONFLICT);

            long duplicates = em.createQuery(
                    "SELECT COUNT(other) FROM Booking other " +
                    "WHERE other.field.fieldId = :fieldId AND other.customerId = :customerId " +
                    "AND other.status = 'PENDING' " +
                    "AND other.startsAt < :endsAt AND other.endsAt > :startsAt", Long.class)
                    .setParameter("fieldId", field.getFieldId())
                    .setParameter("customerId", customerId)
                    .setParameter("startsAt", startsAt)
                    .setParameter("endsAt", endsAt)
                    .getSingleResult();
            if (duplicates > 0) return rollback(transaction, CreateResult.DUPLICATE);

            long minutes = java.time.Duration.between(startsAt, endsAt).toMinutes();
            BigDecimal total = field.getPricePerHour()
                    .multiply(BigDecimal.valueOf(minutes))
                    .divide(BigDecimal.valueOf(60), 2, java.math.RoundingMode.HALF_UP);

            Booking booking = new Booking();
            booking.setField(field);
            booking.setCustomerId(customerId);
            booking.setCustomerName(customerName);
            booking.setCustomerPhone(customerPhone);
            booking.setStartsAt(startsAt);
            booking.setEndsAt(endsAt);
            booking.setTotalPrice(total);
            booking.setStatus("PENDING");
            em.persist(booking);
            transaction.commit();
            return CreateResult.CREATED;
        } catch (RuntimeException exception) {
            if (transaction.isActive()) transaction.rollback();
            throw exception;
        } finally {
            em.close();
        }
    }

    /** Khách hủy đơn của chính mình khi đơn còn ở trạng thái chờ xác nhận. */
    public static boolean cancelByCustomer(Long bookingId, int customerId) {
        EntityManager em = DBUtil.getEntityManagerFactory().createEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            Booking booking = em.find(Booking.class, bookingId, LockModeType.PESSIMISTIC_WRITE);
            if (booking == null || booking.getCustomerId() == null
                    || booking.getCustomerId() != customerId
                    || !"PENDING".equals(booking.getStatus())) {
                transaction.rollback();
                return false;
            }
            booking.setStatus("CANCELLED");
            booking.setUpdatedAt(LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")));
            transaction.commit();
            return true;
        } catch (RuntimeException exception) {
            if (transaction.isActive()) transaction.rollback();
            throw exception;
        } finally {
            em.close();
        }
    }

    private static CreateResult rollback(EntityTransaction transaction, CreateResult result) {
        transaction.rollback();
        return result;
    }

    public enum CreateResult {
        CREATED, FIELD_NOT_FOUND, FIELD_INACTIVE, INVALID_TIME, PAST_TIME, CONFLICT, DUPLICATE
    }

    public enum StatusChangeResult {
        UPDATED, NOT_FOUND, NOT_PENDING, FIELD_INACTIVE, INVALID_TIME, CONFLICT
    }

    public static final class Summary {
        private final long todayCount;
        private final long pendingCount;
        private final BigDecimal todayRevenue;

        private Summary(long todayCount, long pendingCount, BigDecimal todayRevenue) {
            this.todayCount = todayCount;
            this.pendingCount = pendingCount;
            this.todayRevenue = todayRevenue;
        }

        public long getTodayCount() { return todayCount; }
        public long getPendingCount() { return pendingCount; }
        public BigDecimal getTodayRevenue() { return todayRevenue; }
    }
}
