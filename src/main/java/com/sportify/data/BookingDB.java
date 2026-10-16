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
                int maxQuantity = field.getQuantity();
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
                if (conflicts >= maxQuantity) return cancel(transaction, StatusChangeResult.CONFLICT);
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

    // ===================== Phía khách hàng & Truy xuất khung giờ đã đặt =====================

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

    /** Lấy toàn bộ các đơn đặt đang giữ chỗ (PENDING, CONFIRMED, COMPLETED) của một sân. */
    public static List<Booking> findActiveByFieldId(Long fieldId) {
        if (fieldId == null || fieldId <= 0) return java.util.Collections.emptyList();
        EntityManager em = DBUtil.getEntityManagerFactory().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT booking FROM Booking booking JOIN FETCH booking.field field " +
                    "WHERE field.fieldId = :fieldId " +
                    "AND booking.status IN ('PENDING', 'CONFIRMED', 'COMPLETED') " +
                    "ORDER BY booking.startsAt ASC, booking.courtNumber ASC, booking.bookingId ASC", Booking.class)
                    .setParameter("fieldId", fieldId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /** Lấy toàn bộ các đơn đặt đang giữ chỗ (PENDING, CONFIRMED, COMPLETED) của tất cả các sân đang hoạt động. */
    public static List<Booking> findAllActiveBookings() {
        EntityManager em = DBUtil.getEntityManagerFactory().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT booking FROM Booking booking JOIN FETCH booking.field field " +
                    "WHERE field.status = 'ACTIVE' " +
                    "AND booking.status IN ('PENDING', 'CONFIRMED', 'COMPLETED') " +
                    "ORDER BY booking.startsAt DESC, field.fieldId ASC, booking.courtNumber ASC, booking.bookingId ASC", Booking.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Gom nhóm các đơn đặt đang giữ chỗ thành danh sách các khung giờ đã có người đặt,
     * tính toán số lượng đơn trùng trong từng khung giờ trên tổng số sản phẩm (sân) của danh mục đó.
     */
    public static List<BookedSlotSummary> groupBookedSlots(List<Booking> bookings) {
        if (bookings == null || bookings.isEmpty()) return java.util.Collections.emptyList();

        List<Booking> activeList = new java.util.ArrayList<>();
        for (Booking b : bookings) {
            if (b != null && b.getField() != null && b.getStartsAt() != null && b.getEndsAt() != null) {
                String st = b.getStatus();
                if ("PENDING".equals(st) || "CONFIRMED".equals(st) || "COMPLETED".equals(st)) {
                    activeList.add(b);
                }
            }
        }

        // Sắp xếp theo thời gian mới nhất trước (theo ngày giảm dần, giờ tăng dần trong ngày)
        activeList.sort((a, b) -> {
            int dateCmp = b.getStartsAt().toLocalDate().compareTo(a.getStartsAt().toLocalDate());
            if (dateCmp != 0) return dateCmp;
            int timeCmp = a.getStartsAt().toLocalTime().compareTo(b.getStartsAt().toLocalTime());
            if (timeCmp != 0) return timeCmp;
            int fieldCmp = a.getField().getFieldId().compareTo(b.getField().getFieldId());
            if (fieldCmp != 0) return fieldCmp;
            return Integer.compare(a.getCourtNumber(), b.getCourtNumber());
        });

        java.util.Map<String, BookedSlotSummary> slotMap = new java.util.LinkedHashMap<>();
        for (Booking b : activeList) {
            String key = b.getField().getFieldId() + "_" + b.getStartsAt().toString() + "_" + b.getEndsAt().toString();
            BookedSlotSummary summary = slotMap.get(key);
            if (summary == null) {
                // Tìm tất cả các đơn active của cùng fieldId có giao thoa (trùng khung giờ) với [b.startsAt, b.endsAt)
                List<Booking> overlapping = new java.util.ArrayList<>();
                for (Booking other : activeList) {
                    if (other.getField().getFieldId().equals(b.getField().getFieldId())
                            && other.getStartsAt().isBefore(b.getEndsAt())
                            && other.getEndsAt().isAfter(b.getStartsAt())) {
                        overlapping.add(other);
                    }
                }
                overlapping.sort((x, y) -> {
                    int c = Integer.compare(x.getCourtNumber(), y.getCourtNumber());
                    return c != 0 ? c : Long.compare(
                            x.getBookingId() != null ? x.getBookingId() : 0L,
                            y.getBookingId() != null ? y.getBookingId() : 0L);
                });
                summary = new BookedSlotSummary(b.getField(), b.getStartsAt(), b.getEndsAt(), overlapping);
                slotMap.put(key, summary);
            }
        }
        return new java.util.ArrayList<>(slotMap.values());
    }

    /**
     * Khách tạo đơn đặt sân mới (trạng thái PENDING) — hỗ trợ giới hạn số lượng sản phẩm/sân (quantity) ở mỗi khung giờ.
     */
    public static CreateResult createCustomerBooking(
            Long fieldId, int customerId, String customerName, String customerPhone,
            LocalDateTime startsAt, LocalDateTime endsAt) {
        return createCustomerBooking(fieldId, customerId, customerName, customerPhone, startsAt, endsAt, null);
    }

    public static CreateResult createCustomerBooking(
            Long fieldId, int customerId, String customerName, String customerPhone,
            LocalDateTime startsAt, LocalDateTime endsAt, Integer requestedCourtNumber) {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        EntityManager em = DBUtil.getEntityManagerFactory().createEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            SportField field = fieldId == null ? null : em.find(SportField.class, fieldId, LockModeType.PESSIMISTIC_WRITE);
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

            int maxQuantity = field.getQuantity();
            List<Booking> overlapping = em.createQuery(
                    "SELECT other FROM Booking other " +
                    "WHERE other.field.fieldId = :fieldId " +
                    "AND other.status IN ('PENDING', 'CONFIRMED', 'COMPLETED') " +
                    "AND other.startsAt < :endsAt AND other.endsAt > :startsAt " +
                    "ORDER BY other.courtNumber ASC, other.bookingId ASC", Booking.class)
                    .setParameter("fieldId", field.getFieldId())
                    .setParameter("startsAt", startsAt)
                    .setParameter("endsAt", endsAt)
                    .getResultList();

            // Kiểm tra số đơn trùng trong khung giờ đã đạt giới hạn sản phẩm (ví dụ 4 sân) hay chưa
            if (overlapping.size() >= maxQuantity) {
                return rollback(transaction, CreateResult.CONFLICT);
            }

            // Kiểm tra chi tiết theo từng nấc 30 phút trong khoảng [startsAt, endsAt)
            LocalDateTime cursor = startsAt;
            while (cursor.isBefore(endsAt)) {
                LocalDateTime nextStep = cursor.plusMinutes(30);
                if (nextStep.isAfter(endsAt)) nextStep = endsAt;
                int stepCount = 0;
                for (Booking b : overlapping) {
                    if (b.getStartsAt().isBefore(nextStep) && b.getEndsAt().isAfter(cursor)) {
                        stepCount++;
                    }
                }
                if (stepCount >= maxQuantity) {
                    return rollback(transaction, CreateResult.CONFLICT);
                }
                cursor = nextStep;
            }

            // Xác định các sân số (1..maxQuantity) đã có người đặt trong khung giờ này
            java.util.Set<Integer> usedCourts = new java.util.HashSet<>();
            for (Booking b : overlapping) {
                int c = b.getCourtNumber();
                if (c >= 1 && c <= maxQuantity && !usedCourts.contains(c)) {
                    usedCourts.add(c);
                } else {
                    for (int fallback = 1; fallback <= maxQuantity; fallback++) {
                        if (!usedCourts.contains(fallback)) {
                            usedCourts.add(fallback);
                            break;
                        }
                    }
                }
            }

            if (usedCourts.size() >= maxQuantity) {
                return rollback(transaction, CreateResult.CONFLICT);
            }

            int assignedCourt = 1;
            if (requestedCourtNumber != null && requestedCourtNumber >= 1 && requestedCourtNumber <= maxQuantity) {
                if (usedCourts.contains(requestedCourtNumber)) {
                    return rollback(transaction, CreateResult.CONFLICT);
                }
                assignedCourt = requestedCourtNumber;
            } else {
                for (int c = 1; c <= maxQuantity; c++) {
                    if (!usedCourts.contains(c)) {
                        assignedCourt = c;
                        break;
                    }
                }
            }

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
            booking.setCourtNumber(assignedCourt);
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

    public static Booking findById(Long bookingId) {
        if (bookingId == null || bookingId <= 0) return null;
        EntityManager em = DBUtil.getEntityManagerFactory().createEntityManager();
        try {
            List<Booking> list = em.createQuery(
                    "SELECT b FROM Booking b JOIN FETCH b.field f WHERE b.bookingId = :bookingId", Booking.class)
                    .setParameter("bookingId", bookingId)
                    .getResultList();
            return list.isEmpty() ? null : list.get(0);
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

    public static final class BookedSlotSummary {
        private final SportField field;
        private final LocalDateTime startsAt;
        private final LocalDateTime endsAt;
        private final int totalQuantity;
        private final int bookedCount;
        private final int confirmedCount;
        private final int pendingCount;
        private final List<Booking> bookings;
        private final List<Integer> bookedCourtNumbers;
        private final List<Integer> availableCourtNumbers;

        public BookedSlotSummary(SportField field, LocalDateTime startsAt, LocalDateTime endsAt, List<Booking> bookings) {
            this.field = field;
            this.startsAt = startsAt;
            this.endsAt = endsAt;
            this.totalQuantity = field != null ? field.getQuantity() : 4;
            this.bookings = bookings != null ? bookings : java.util.Collections.emptyList();
            this.bookedCount = this.bookings.size();

            int conf = 0;
            int pend = 0;
            java.util.Set<Integer> used = new java.util.LinkedHashSet<>();
            for (Booking b : this.bookings) {
                if ("CONFIRMED".equals(b.getStatus()) || "COMPLETED".equals(b.getStatus())) {
                    conf++;
                } else if ("PENDING".equals(b.getStatus())) {
                    pend++;
                }
                int c = b.getCourtNumber();
                if (c >= 1 && c <= this.totalQuantity && !used.contains(c)) {
                    used.add(c);
                } else {
                    for (int fallback = 1; fallback <= this.totalQuantity; fallback++) {
                        if (!used.contains(fallback)) {
                            used.add(fallback);
                            break;
                        }
                    }
                }
            }
            this.confirmedCount = conf;
            this.pendingCount = pend;
            this.bookedCourtNumbers = new java.util.ArrayList<>(used);
            this.availableCourtNumbers = new java.util.ArrayList<>();
            for (int c = 1; c <= this.totalQuantity; c++) {
                if (!used.contains(c)) {
                    this.availableCourtNumbers.add(c);
                }
            }
        }

        public SportField getField() { return field; }
        public Long getFieldId() { return field != null ? field.getFieldId() : null; }
        public String getFieldName() { return field != null && field.getFieldName() != null ? field.getFieldName() : ""; }
        public String getSportType() { return field != null && field.getSportType() != null ? field.getSportType() : ""; }
        public LocalDateTime getStartsAt() { return startsAt; }
        public LocalDateTime getEndsAt() { return endsAt; }
        public String getDateStr() {
            return startsAt != null ? startsAt.toLocalDate().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")) : "";
        }
        public String getIsoDate() {
            return startsAt != null ? startsAt.toLocalDate().toString() : "";
        }
        public String getStartTimeStr() {
            return startsAt != null ? startsAt.toLocalTime().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm")) : "";
        }
        public String getEndTimeStr() {
            return endsAt != null ? endsAt.toLocalTime().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm")) : "";
        }
        public int getTotalQuantity() { return totalQuantity; }
        public int getFieldQuantity() { return totalQuantity; }
        public int getBookedCount() { return bookedCount; }
        public int getConfirmedCount() { return confirmedCount; }
        public int getPendingCount() { return pendingCount; }
        public int getRemainingCount() { return Math.max(0, totalQuantity - bookedCount); }
        public boolean isFull() { return bookedCount >= totalQuantity; }
        public List<Booking> getBookings() { return bookings; }
        public List<Integer> getBookedCourtNumbers() { return bookedCourtNumbers; }
        public List<Integer> getAvailableCourtNumbers() { return availableCourtNumbers; }
    }
}
