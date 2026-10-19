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
        String sql = "SELECT * FROM chat_sessions WHERE user_id = ? AND role_class = 'role-court'";
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
        // Compatibility helper for the retired service chat; keep court sessions only.
        try (Connection conn = DBContext.getConnection()) {
            String checkSql = "SELECT COUNT(*) FROM chat_sessions WHERE user_id = ? AND role_class = 'role-court'";
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

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void createSession(Connection conn, int userId, String partnerName, String icon, String roleName,
            String roleClass, boolean isOnline) throws Exception {
        String sql = "INSERT INTO chat_sessions (user_id, partner_name, partner_icon, role_name, role_class, is_online) VALUES (?, ?, ?, ?, ?, ?)";
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
                String deleteSql = "DELETE FROM Messages WHERE id IN (SELECT id FROM Messages WHERE session_id = ? ORDER BY id ASC LIMIT ?)";
                try (PreparedStatement psDel = conn.prepareStatement(deleteSql)) {
                    psDel.setInt(1, sessionId);
                    psDel.setInt(2, limit);
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
        String sql = "SELECT * FROM friend_messages WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?) ORDER BY id ASC";
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

    public Integer findLatestOwnerChatPartner(int customerId) {
        String sql = "SELECT CASE WHEN fm.sender_id = ? THEN fm.receiver_id ELSE fm.sender_id END AS partner_id " +
                     "FROM friend_messages fm " +
                     "JOIN Users u ON u.id = (CASE WHEN fm.sender_id = ? THEN fm.receiver_id ELSE fm.sender_id END) " +
                     "WHERE (fm.sender_id = ? OR fm.receiver_id = ?) " +
                     "  AND (u.role = 'OWNER' OR u.role = 'ADMIN') " +
                     "ORDER BY fm.id DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, customerId);
            ps.setInt(3, customerId);
            ps.setInt(4, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("partner_id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public void saveFriendMessage(int senderId, int receiverId, String text, String time) {
        try (Connection conn = DBContext.getConnection()) {
            // Check count
            String countSql = "SELECT COUNT(*) FROM friend_messages WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)";
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

            // Giữ tối đa 500 tin nhắn gần nhất
            if (count >= 500) {
                int limit = count - 499;
                String deleteSql = "DELETE FROM friend_messages WHERE id IN (SELECT id FROM friend_messages WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?) ORDER BY id ASC LIMIT ?)";
                try (PreparedStatement psDel = conn.prepareStatement(deleteSql)) {
                    psDel.setInt(1, senderId);
                    psDel.setInt(2, receiverId);
                    psDel.setInt(3, receiverId);
                    psDel.setInt(4, senderId);
                    psDel.setInt(5, limit);
                    psDel.executeUpdate();
                }
            }

            // Insert new
            String insertSql = "INSERT INTO friend_messages (sender_id, receiver_id, message_text, created_at) VALUES (?, ?, ?, ?)";
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
