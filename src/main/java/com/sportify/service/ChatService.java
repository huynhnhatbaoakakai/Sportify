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
            boolean isOwner = "OWNER".equalsIgnoreCase(friend.getRole()) || "ADMIN".equalsIgnoreCase(friend.getRole()) || friend.getId() == 1;
            cs.setRoleName(isOwner ? "Chủ sân" : "Thành viên");
            cs.setRoleClass(isOwner ? "badge-role-owner" : "badge-role-user");
            cs.setMessages(chatDAO.getFriendMessages(userId, friend.getId()));
            sessions.add(cs);
        }
        return sessions;
    }

    public void sendFriendMessage(int senderId, int receiverId, String text, String time) {
        chatDAO.saveFriendMessage(senderId, receiverId, text, time);
    }

    // ===== Chat phục vụ đơn hàng (Order Service Chat) =====

    public java.util.Map<String, Object> getOrderChatData(int currentUserId, long bookingId, Integer targetPartnerId) {
        com.sportify.model.Booking booking = com.sportify.data.BookingDB.findById(bookingId);
        if (booking == null) {
            throw new IllegalArgumentException("Không tìm thấy đơn đặt sân #" + bookingId);
        }

        int ownerId = (booking.getField() != null && booking.getField().getOwnerId() != null)
                ? booking.getField().getOwnerId().intValue() : 0;
        if (ownerId <= 0) {
            ownerId = 1;
        }

        int customerId = booking.getCustomerId() != null ? booking.getCustomerId()
                : userDAO.resolveOrCreateUser(booking.getCustomerName(), booking.getCustomerPhone());

        int partnerId;
        if (targetPartnerId != null && targetPartnerId > 0) {
            partnerId = targetPartnerId;
        } else if (currentUserId == customerId) {
            Integer activeOwner = chatDAO.findLatestOwnerChatPartner(customerId);
            partnerId = (activeOwner != null && activeOwner > 0) ? activeOwner : ownerId;
        } else {
            partnerId = customerId;
        }

        User partner = userDAO.getUserById(partnerId);
        String partnerRole = (partner != null && ("OWNER".equalsIgnoreCase(partner.getRole()) || "ADMIN".equalsIgnoreCase(partner.getRole()) || partnerId == ownerId))
                ? "Chủ sân" : "Khách hàng";
        String partnerName = partner != null ? partner.getFullname() : (partnerRole.equals("Chủ sân") ? "Chủ sân Sportify" : booking.getCustomerName());

        List<com.sportify.model.ChatMessage> messages = chatDAO.getFriendMessages(currentUserId, partnerId);

        java.text.NumberFormat vndFormat = java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi", "VN"));
        java.time.format.DateTimeFormatter dtFormat = java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");

        java.util.Map<String, Object> bookingMap = new java.util.LinkedHashMap<>();
        bookingMap.put("bookingId", booking.getBookingId());
        bookingMap.put("bookingCode", booking.getBookingCode());
        bookingMap.put("fieldName", booking.getField() != null ? booking.getField().getFieldName() : "Sân thể thao");
        bookingMap.put("sportType", booking.getField() != null ? booking.getField().getSportType() : "SPORT");
        bookingMap.put("startsAt", booking.getStartsAt() != null ? booking.getStartsAt().format(dtFormat) : "");
        bookingMap.put("endsAt", booking.getEndsAt() != null ? booking.getEndsAt().format(dtFormat) : "");
        bookingMap.put("totalPrice", vndFormat.format(booking.getTotalPrice()) + " đ");
        bookingMap.put("status", booking.getStatus());
        bookingMap.put("statusLabel", booking.getStatusLabel());
        bookingMap.put("customerName", booking.getCustomerName());
        bookingMap.put("customerPhone", booking.getCustomerPhone() != null ? booking.getCustomerPhone() : "");
        bookingMap.put("ownerId", ownerId);
        bookingMap.put("customerId", customerId);

        java.util.Map<String, Object> partnerMap = new java.util.LinkedHashMap<>();
        partnerMap.put("id", partnerId);
        partnerMap.put("name", partnerName);
        partnerMap.put("role", partnerRole);
        partnerMap.put("initial", initialOf(partnerName));
        partnerMap.put("email", partner != null ? partner.getEmail() : "");

        java.util.Map<String, Object> result = new java.util.LinkedHashMap<>();
        result.put("booking", bookingMap);
        result.put("partner", partnerMap);
        result.put("currentUserId", currentUserId);
        result.put("messages", messages);
        result.put("isOwnerViewing", (currentUserId == ownerId));

        return result;
    }

    public void sendOrderMessage(int senderId, int receiverId, String text, String time) {
        if (text == null || text.trim().isEmpty()) return;
        if (time == null || time.trim().isEmpty()) {
            time = java.time.LocalDateTime.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh"))
                    .format(java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM"));
        }
        chatDAO.saveFriendMessage(senderId, receiverId, text.trim(), time);
    }

    private static String initialOf(String name) {
        return (name != null && !name.isEmpty()) ? name.substring(0, 1).toUpperCase() : "U";
    }
}

