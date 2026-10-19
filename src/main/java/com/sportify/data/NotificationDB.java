package com.sportify.data;

import com.sportify.config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public final class NotificationDB {
    private NotificationDB() { }
    public record Item(long id, Long bookingId, String title, String body, LocalDateTime createdAt, boolean read) { }

    public static List<Item> findByUser(int userId) {
        List<Item> items = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT * FROM public.notifications WHERE recipient_id=? ORDER BY created_at DESC, notification_id DESC LIMIT 50")) {
            statement.setInt(1, userId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) items.add(new Item(result.getLong("notification_id"),
                        (Long) result.getObject("booking_id"), result.getString("title"), result.getString("body"),
                        result.getTimestamp("created_at").toLocalDateTime(), result.getTimestamp("read_at") != null));
            }
        } catch (Exception exception) { throw new IllegalStateException("Không thể tải thông báo.", exception); }
        return items;
    }

    public static long countUnread(int userId) {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT COUNT(*) FROM public.notifications WHERE recipient_id=? AND read_at IS NULL")) {
            statement.setInt(1, userId);
            try (ResultSet result = statement.executeQuery()) { result.next(); return result.getLong(1); }
        } catch (Exception exception) { throw new IllegalStateException("Không thể đếm thông báo.", exception); }
    }

    public static int markRead(int userId, Long notificationId) {
        String sql = "UPDATE public.notifications SET read_at=CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Ho_Chi_Minh' WHERE recipient_id=? AND read_at IS NULL";
        if (notificationId != null) sql += " AND notification_id=?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            if (notificationId != null) statement.setLong(2, notificationId);
            return statement.executeUpdate();
        } catch (Exception exception) { throw new IllegalStateException("Không thể đánh dấu thông báo.", exception); }
    }
}
