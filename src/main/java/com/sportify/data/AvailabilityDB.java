package com.sportify.data;

import com.sportify.model.Booking;
import com.sportify.model.FieldBlock;
import com.sportify.model.SportField;
import jakarta.persistence.EntityManager;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

public final class AvailabilityDB {
    private AvailabilityDB() { }
    public record Window(LocalDateTime startsAt, LocalDateTime endsAt, String status, String reason) { }
    public record Day(Long fieldId, String fieldName, LocalDate date, LocalTime opensAt, LocalTime closesAt,
                      boolean active, boolean autoApprove, List<Window> windows) { }

    public static Day getDay(Long fieldId, LocalDate date) {
        if (fieldId == null || fieldId <= 0 || date == null) throw new IllegalArgumentException("Sân hoặc ngày không hợp lệ.");
        EntityManager em = DBUtil.getEntityManagerFactory().createEntityManager();
        try {
            SportField field = em.find(SportField.class, fieldId);
            if (field == null) return null;
            List<Booking> reserved = em.createQuery("SELECT b FROM Booking b WHERE b.field.fieldId=:fieldId " +
                            "AND b.status IN ('PENDING','CONFIRMED','COMPLETED') AND b.startsAt<:end AND b.endsAt>:start ORDER BY b.startsAt", Booking.class)
                    .setParameter("fieldId", fieldId).setParameter("start", date.atStartOfDay())
                    .setParameter("end", date.plusDays(1).atStartOfDay()).getResultList();
            List<Window> busy = new ArrayList<>();
            // Old pending requests can share one court. Count that physical court once.
            for (List<Booking> lane : reserved.stream().collect(java.util.stream.Collectors.groupingBy(Booking::getCourtNumber)).values()) {
                Window current = null;
                for (Booking booking : lane) {
                    if (current != null && !booking.getStartsAt().isAfter(current.endsAt())) {
                        current = new Window(current.startsAt(), booking.getEndsAt().isAfter(current.endsAt()) ? booking.getEndsAt() : current.endsAt(), "BOOKED", "Sân đã có lịch đặt");
                    } else {
                        if (current != null) busy.add(current);
                        current = new Window(booking.getStartsAt(), booking.getEndsAt(), "BOOKED", "Sân đã có lịch đặt");
                    }
                }
                if (current != null) busy.add(current);
            }
            List<Window> blocks = em.createQuery("SELECT b FROM FieldBlock b WHERE b.field.fieldId=:fieldId " +
                            "AND b.startsAt<:end AND b.endsAt>:start ORDER BY b.startsAt", FieldBlock.class)
                    .setParameter("fieldId", fieldId).setParameter("start", date.atStartOfDay())
                    .setParameter("end", date.plusDays(1).atStartOfDay()).getResultList().stream()
                    .map(block -> new Window(block.getStartsAt(), block.getEndsAt(), "BLOCKED", block.getReason())).toList();
            LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
            return new Day(fieldId, field.getFieldName(), date, field.getOpenTime(), field.getCloseTime(),
                    "ACTIVE".equals(field.getStatus()), field.isAutoApprove() && field.supportsAutoApproval(),
                    buildWindows(date.atTime(field.getOpenTime()), date.atTime(field.getCloseTime()),
                            "ACTIVE".equals(field.getStatus()), busy, blocks, now, field.getQuantity()));
        } finally { em.close(); }
    }

    static List<Window> buildWindows(LocalDateTime open, LocalDateTime close, boolean active,
                                     List<Window> bookings, List<Window> blocks, LocalDateTime now) {
        return buildWindows(open, close, active, bookings, blocks, now, 1);
    }

    static List<Window> buildWindows(LocalDateTime open, LocalDateTime close, boolean active,
                                     List<Window> bookings, List<Window> blocks, LocalDateTime now, int quantity) {
        TreeSet<LocalDateTime> boundaries = new TreeSet<>();
        boundaries.add(open); boundaries.add(close);
        List<Window> occupied = new ArrayList<>(bookings); occupied.addAll(blocks);
        for (Window window : occupied) {
            if (window.startsAt().isAfter(open) && window.startsAt().isBefore(close)) boundaries.add(window.startsAt());
            if (window.endsAt().isAfter(open) && window.endsAt().isBefore(close)) boundaries.add(window.endsAt());
        }
        LocalDateTime cutoff = now.withSecond(0).withNano(0).plusMinutes(1);
        if (cutoff.isAfter(open) && cutoff.isBefore(close)) boundaries.add(cutoff);
        List<LocalDateTime> points = new ArrayList<>(boundaries);
        List<Window> result = new ArrayList<>();
        for (int index = 0; index + 1 < points.size(); index++) {
            LocalDateTime start = points.get(index), end = points.get(index + 1);
            Window covering = blocks.stream().filter(window -> window.startsAt().isBefore(end) && window.endsAt().isAfter(start)).findFirst().orElse(null);
            long reserved = bookings.stream().filter(window -> window.startsAt().isBefore(end) && window.endsAt().isAfter(start)).count();
            if (covering == null && reserved >= quantity) covering = new Window(start, end, "BOOKED", "Đã hết sân trong khung giờ này");
            String status = covering != null ? covering.status() : !active ? "INACTIVE" : !start.isAfter(now) ? "PAST" : "FREE";
            String reason = covering != null ? covering.reason() : !active ? "Sân đang tạm ngưng" : "PAST".equals(status) ? "Đã qua thời gian đặt" : "Có thể đặt sân";
            if (!result.isEmpty()) {
                Window last = result.get(result.size() - 1);
                if (last.endsAt().equals(start) && last.status().equals(status) && last.reason().equals(reason)) {
                    result.set(result.size() - 1, new Window(last.startsAt(), end, status, reason)); continue;
                }
            }
            result.add(new Window(start, end, status, reason));
        }
        return result;
    }

    public static List<Booking> ownerBookings(Long fieldId, Long ownerId, LocalDate date) {
        EntityManager em = DBUtil.getEntityManagerFactory().createEntityManager();
        try {
            return em.createQuery("SELECT b FROM Booking b JOIN FETCH b.field f WHERE f.fieldId=:fieldId AND f.ownerId=:owner " +
                            "AND b.startsAt<:end AND b.endsAt>:start ORDER BY b.startsAt, b.bookingId", Booking.class)
                    .setParameter("fieldId", fieldId).setParameter("owner", ownerId)
                    .setParameter("start", date.atStartOfDay()).setParameter("end", date.plusDays(1).atStartOfDay()).getResultList();
        } finally { em.close(); }
    }
}
