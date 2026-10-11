package com.sportify.service;

import com.sportify.dao.ChatDAO;
import com.sportify.dao.UserDAO;
import com.sportify.model.ChatSession;
import com.sportify.model.User;

import java.util.ArrayList;
import java.util.List;

/**
 * Nghiệp vụ chat: chat với dịch vụ (bot) và chat giữa bạn bè.
 */
public class ChatService {

    private final ChatDAO chatDAO = new ChatDAO();
    private final UserDAO userDAO = new UserDAO();

    // ===== Chat dịch vụ =====

    /** Danh sách hội thoại với dịch vụ; tự tạo hội thoại mặc định nếu user chưa có. */
    public List<ChatSession> getServiceConversations(int userId) {
        chatDAO.initializeDefaultSessions(userId);
        return chatDAO.getUserChatSessions(userId);
    }

    /** Lưu tin nhắn của user và câu trả lời tự động của dịch vụ. */
    public void sendServiceMessage(int sessionId, String text, String time) {
        chatDAO.saveMessage(sessionId, "me", text, time);
        chatDAO.saveMessage(sessionId, "them", autoReply(text), time);
    }

    /** Câu trả lời tự động dựa trên từ khoá. */
    static String autoReply(String text) {
        String lower = text == null ? "" : text.toLowerCase();
        if (lower.contains("xin chào") || lower.contains("chào")) {
            return "Chào bạn! Tôi có thể giúp gì cho bạn?";
        }
        if (lower.contains("giá")) {
            return "Dạ, chi phí tuỳ thuộc vào dịch vụ bạn chọn. Bạn vui lòng đợi nhân viên kiểm tra nhé.";
        }
        return "Cảm ơn bạn đã liên hệ, chúng tôi sẽ phản hồi sớm nhất!";
    }

    // ===== Chat bạn bè =====

    /** Mỗi user khác là một "hội thoại", kèm lịch sử tin nhắn với user hiện tại. */
    public List<ChatSession> getFriendConversations(int userId) {
        List<ChatSession> sessions = new ArrayList<>();
        for (User friend : userDAO.getAllUsersExcept(userId)) {
            ChatSession cs = new ChatSession();
            cs.setId(friend.getId());
            cs.setPartnerName(friend.getFullname());
            cs.setPartnerIcon(initialOf(friend.getFullname()));
            cs.setOnline(true);
            cs.setMessages(chatDAO.getFriendMessages(userId, friend.getId()));
            sessions.add(cs);
        }
        return sessions;
    }

    public void sendFriendMessage(int senderId, int receiverId, String text, String time) {
        chatDAO.saveFriendMessage(senderId, receiverId, text, time);
    }

    private static String initialOf(String name) {
        return (name != null && !name.isEmpty()) ? name.substring(0, 1).toUpperCase() : "U";
    }
}

