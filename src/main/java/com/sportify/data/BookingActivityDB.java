package com.sportify.data;

import com.sportify.config.DBContext;
import com.sportify.model.Booking;
import jakarta.persistence.EntityManager;
import org.hibernate.Session;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public final class BookingActivityDB {
    private BookingActivityDB() { }

    /** The audit entry and both notifications commit with the booking transaction. */
    static void record(EntityManager em, Booking booking, String previous, String actor, Integer actorId, String reason) {
        em.unwrap(Session.class).doWork(connection -> {
            try (PreparedStatement statement = connection.prepareStatement(
                    "INSERT INTO public.booking_events (booking_id, from_status, to_status, actor_type, actor_id, reason, occurred_at) " +
                    "VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Ho_Chi_Minh')")) {
                statement.setLong(1, booking.getBookingId());
                statement.setString(2, previous);
                statement.setString(3, booking.getStatus());
                statement.setString(4, actor);
                statement.setObject(5, actorId);
                statement.setString(6, reason);
                statement.executeUpdate();
            }
            String title = switch (booking.getStatus()) {
                case "CONFIRMED" -> booking.isAutomaticallyConfirmed() ? "Đặt sân được tự động xác nhận" : "Đặt sân đã được xác nhận";
                case "REJECTED" -> "Yêu cầu đặt sân bị từ chối";
                case "CANCELLED" -> "Yêu cầu đặt sân đã hủy";
                case "COMPLETED" -> "Đơn đặt sân đã hoàn thành";
                default -> "Có yêu cầu đặt sân đang chờ duyệt";
            };
            String body = booking.getBookingCode() + " · " + booking.getField().getFieldName() + " · "
                    + booking.getStartsAt().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))
                    + "–" + booking.getEndsAt().format(DateTimeFormatter.ofPattern("HH:mm")) + ". " + reason;
            if (body.length() > 500) body = body.substring(0, 500);
            notify(connection, booking.getCustomerId(), booking.getBookingId(), title, body);
            Long owner = booking.getField().getOwnerId();
            if (owner != null && owner <= Integer.MAX_VALUE && !owner.equals(
                    booking.getCustomerId() == null ? null : booking.getCustomerId().longValue())) {
                notify(connection, owner.intValue(), booking.getBookingId(), title, body);
            }
        });
    }

    private static void notify(Connection connection, Integer userId, Long bookingId, String title, String body) throws SQLException {
        if (userId == null) return;
        // Legacy demo fields/bookings can reference owners without an account; skip only that recipient.
        try (PreparedStatement statement = connection.prepareStatement(
                "INSERT INTO public.notifications (recipient_id, booking_id, title, body, created_at) " +
                "SELECT id, ?, ?, ?, CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Ho_Chi_Minh' FROM public.users WHERE id = ?")) {
            statement.setLong(1, bookingId);
            statement.setString(2, title);
            statement.setString(3, body);
            statement.setInt(4, userId);
            statement.executeUpdate();
        }
    }

    public record HistoryEntry(String fromStatus, String toStatus, String actorType, String reason, LocalDateTime occurredAt) {
        public String actorLabel() {
            return switch (actorType) { case "SYSTEM" -> "Hệ thống"; case "OWNER" -> "Chủ sân"; default -> "Khách hàng"; };
        }
    }

    public static Map<Long, List<HistoryEntry>> findByOwner(Long ownerId) {
        Map<Long, List<HistoryEntry>> history = new LinkedHashMap<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT e.* FROM public.booking_events e JOIN public.bookings b ON b.booking_id=e.booking_id " +
                     "JOIN public.sports_fields f ON f.field_id=b.field_id WHERE f.owner_id=? " +
                     "ORDER BY e.occurred_at DESC, e.event_id DESC LIMIT 1000")) {
            statement.setLong(1, ownerId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) history.computeIfAbsent(result.getLong("booking_id"), key -> new ArrayList<>())
                        .add(new HistoryEntry(result.getString("from_status"), result.getString("to_status"),
                                result.getString("actor_type"), result.getString("reason"), result.getTimestamp("occurred_at").toLocalDateTime()));
            }
        } catch (Exception exception) { throw new IllegalStateException("Không thể tải lịch sử đặt sân.", exception); }
        return history;
    }
}
