package com.sportify.dao;

import com.sportify.model.ChatMessage;
import com.sportify.model.ChatSession;
import com.sportify.config.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ChatDAO {

    public List<ChatSession> getUserChatSessions(int userId) {
        List<ChatSession> sessions = new ArrayList<>();
        String sql = "SELECT * FROM ChatSessions WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChatSession session = new ChatSession();
                    session.setId(rs.getInt("id"));
                    session.setUserId(rs.getInt("user_id"));
                    session.setPartnerName(rs.getString("partner_name"));
                    session.setPartnerIcon(rs.getString("partner_icon"));
                    session.setRoleName(rs.getString("role_name"));
                    session.setRoleClass(rs.getString("role_class"));
                    session.setOnline(rs.getBoolean("is_online"));

                    // Fetch messages for this session
                    session.setMessages(getMessagesBySessionId(session.getId(), conn));
                    sessions.add(session);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return sessions;
    }

    private List<ChatMessage> getMessagesBySessionId(int sessionId, Connection conn) {
        List<ChatMessage> messages = new ArrayList<>();
        String sql = "SELECT * FROM Messages WHERE session_id = ? ORDER BY id ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChatMessage msg = new ChatMessage();
                    msg.setId(rs.getInt("id"));
                    msg.setSessionId(rs.getInt("session_id"));
                    msg.setSender(rs.getString("sender"));
                    msg.setText(rs.getString("message_text"));
                    msg.setTime(rs.getString("created_at"));
                    messages.add(msg);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return messages;
    }

    public void initializeDefaultSessions(int userId) {
        // If user has 0 sessions, create 3 default ones
        try (Connection conn = DBContext.getConnection()) {
            String checkSql = "SELECT COUNT(*) FROM ChatSessions WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        return; // Already initialized
                    }
                }
            }

            // Create default sessions
            createSession(conn, userId, "Sân bóng Sunrise", "🏢", "Chủ sân", "role-court", true);
            createSession(conn, userId, "PT Nguyễn Minh Anh", "💪", "Huấn luyện viên", "role-pt", false);
            createSession(conn, userId, "Sport Gear Q7", "🎒", "Shop dụng cụ", "role-shop", true);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void createSession(Connection conn, int userId, String partnerName, String icon, String roleName,
            String roleClass, boolean isOnline) throws Exception {
        String sql = "INSERT INTO ChatSessions (user_id, partner_name, partner_icon, role_name, role_class, is_online) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, partnerName);
            ps.setString(3, icon);
            ps.setString(4, roleName);
            ps.setString(5, roleClass);
            ps.setBoolean(6, isOnline);
            ps.executeUpdate();
        }
    }

    public void saveMessage(int sessionId, String sender, String text, String time) {
        try (Connection conn = DBContext.getConnection()) {
            // Check count
            String countSql = "SELECT COUNT(*) FROM Messages WHERE session_id = ?";
            int count = 0;
            try (PreparedStatement psCount = conn.prepareStatement(countSql)) {
                psCount.setInt(1, sessionId);
                try (ResultSet rs = psCount.executeQuery()) {
                    if (rs.next()) {
                        count = rs.getInt(1);
                    }
                }
            }

            // Max 10 messages: delete oldest if count >= 10
            if (count >= 10) {
                int limit = count - 9;
                String deleteSql = "DELETE FROM Messages WHERE id IN (SELECT TOP (?) id FROM Messages WHERE session_id = ? ORDER BY id ASC)";
                try (PreparedStatement psDel = conn.prepareStatement(deleteSql)) {
                    psDel.setInt(1, limit);
                    psDel.setInt(2, sessionId);
                    psDel.executeUpdate();
                }
            }

            // Insert new
            String insertSql = "INSERT INTO Messages (session_id, sender, message_text, created_at) VALUES (?, ?, ?, ?)";
            try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                psInsert.setInt(1, sessionId);
                psInsert.setString(2, sender);
                psInsert.setString(3, text);
                psInsert.setString(4, time);
                psInsert.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<ChatMessage> getFriendMessages(int user1, int user2) {
        List<ChatMessage> messages = new ArrayList<>();
        String sql = "SELECT * FROM FriendMessages WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?) ORDER BY id ASC";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, user1);
            ps.setInt(2, user2);
            ps.setInt(3, user2);
            ps.setInt(4, user1);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChatMessage msg = new ChatMessage();
                    msg.setId(rs.getInt("id"));
                    // Use sender field to store the actual sender_id as string
                    msg.setSender(String.valueOf(rs.getInt("sender_id")));
                    msg.setText(rs.getString("message_text"));
                    msg.setTime(rs.getString("created_at"));
                    messages.add(msg);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return messages;
    }

    public void saveFriendMessage(int senderId, int receiverId, String text, String time) {
        try (Connection conn = DBContext.getConnection()) {
            // Check count
            String countSql = "SELECT COUNT(*) FROM FriendMessages WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)";
            int count = 0;
            try (PreparedStatement psCount = conn.prepareStatement(countSql)) {
                psCount.setInt(1, senderId);
                psCount.setInt(2, receiverId);
                psCount.setInt(3, receiverId);
                psCount.setInt(4, senderId);
                try (ResultSet rs = psCount.executeQuery()) {
                    if (rs.next()) {
                        count = rs.getInt(1);
                    }
                }
            }

            // Max 10 messages: delete oldest if count >= 10
            if (count >= 10) {
                int limit = count - 9;
                String deleteSql = "DELETE FROM FriendMessages WHERE id IN (SELECT TOP (?) id FROM FriendMessages WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?) ORDER BY id ASC)";
                try (PreparedStatement psDel = conn.prepareStatement(deleteSql)) {
                    psDel.setInt(1, limit);
                    psDel.setInt(2, senderId);
                    psDel.setInt(3, receiverId);
                    psDel.setInt(4, receiverId);
                    psDel.setInt(5, senderId);
                    psDel.executeUpdate();
                }
            }

            // Insert new
            String insertSql = "INSERT INTO FriendMessages (sender_id, receiver_id, message_text, created_at) VALUES (?, ?, ?, ?)";
            try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                psInsert.setInt(1, senderId);
                psInsert.setInt(2, receiverId);
                psInsert.setString(3, text);
                psInsert.setString(4, time);
                psInsert.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
