package com.sportify.controller.chat;

import com.sportify.controller.BaseServlet;
import com.sportify.model.User;
import com.sportify.service.ChatService;
import com.sportify.util.JsonResponse;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * API JSON cho chat giữa người dùng. Chat dịch vụ mẫu đã ngừng hoạt động.
 *
 * <pre>
 * GET  /chat-api?action=getConversations          → HTTP 410 (chat dịch vụ mẫu đã tắt)
 * GET  /chat-api?action=getFriends                → hội thoại với bạn bè    (trang /chat-friends)
 * POST /chat-api  action=sendMessage             → HTTP 410
 * POST /chat-api  action=sendFriendMessage receiverId, text, time
 * </pre>
 */
@WebServlet("/chat-api")
public class ChatApiServlet extends BaseServlet {

    private final ChatService chatService = new ChatService();

    private static void serviceChatDisabled(HttpServletResponse resp) throws IOException {
        JsonResponse.error(resp, HttpServletResponse.SC_GONE,
                "Chat dịch vụ mẫu đã tắt. Vui lòng dùng tin nhắn trực tiếp với chủ sân hoặc khách hàng.");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = currentUser(req);
        String action = req.getParameter("action");
        try {
            if ("getConversations".equals(action)) {
                serviceChatDisabled(resp);
            } else if ("getFriends".equals(action)) {
                JsonResponse.ok(resp, chatService.getFriendConversations(user.getId()));
            } else if ("getOrderChat".equals(action)) {
                long bookingId = Long.parseLong(req.getParameter("bookingId"));
                Integer partnerId = req.getParameter("partnerId") != null && !req.getParameter("partnerId").isEmpty()
                        ? Integer.parseInt(req.getParameter("partnerId")) : null;
                JsonResponse.ok(resp, chatService.getOrderChatData(user.getId(), bookingId, partnerId));
            } else if ("getMyConfirmedBookings".equals(action)) {
                java.util.List<java.util.Map<String, Object>> assets = new java.util.ArrayList<>();
                for (com.sportify.model.Booking b : com.sportify.data.BookingDB.findConfirmedAssetsByUserId(user.getId())) {
                    assets.add(com.sportify.data.BookingDB.toAssetMap(b));
                }
                JsonResponse.ok(resp, assets);
            } else {
                JsonResponse.error(resp, HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
            }
        } catch (Exception e) {
            e.printStackTrace();
            JsonResponse.error(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        User user = currentUser(req);
        String action = req.getParameter("action");
        String text = req.getParameter("text");
        String time = req.getParameter("time");
        try {
            if ("sendMessage".equals(action)) {
                serviceChatDisabled(resp);
            } else if ("sendFriendMessage".equals(action)) {
                int receiverId = Integer.parseInt(req.getParameter("receiverId"));
                chatService.sendFriendMessage(user.getId(), receiverId, text, time);
                JsonResponse.success(resp);
            } else if ("sendOrderMessage".equals(action)) {
                int receiverId = Integer.parseInt(req.getParameter("receiverId"));
                chatService.sendOrderMessage(user.getId(), receiverId, text, time);
                JsonResponse.success(resp);
            } else if ("transferBooking".equals(action)) {
                long bookingId = Long.parseLong(req.getParameter("bookingId"));
                int receiverId = Integer.parseInt(req.getParameter("receiverId"));
                String note = req.getParameter("note");
                if (note == null) note = "";
                note = note.replace("|", "/").replace("]", ")").trim();

                User receiver = new com.sportify.dao.UserDAO().getUserById(receiverId);
                if (receiver == null) {
                    JsonResponse.error(resp, HttpServletResponse.SC_BAD_REQUEST, "Không tìm thấy người nhận.");
                    return;
                }

                com.sportify.model.Booking transferred = com.sportify.data.BookingDB.transferBookingOwnership(
                        bookingId, user.getId(), receiver);
                java.util.Map<String, Object> asset = com.sportify.data.BookingDB.toAssetMap(transferred);

                String msgPayload = "[BOOKING_ASSET_TRANSFER|"
                        + asset.getOrDefault("bookingId", "") + "|"
                        + asset.getOrDefault("bookingCode", "") + "|"
                        + String.valueOf(asset.getOrDefault("fieldName", "")).replace("|", "/") + "|"
                        + asset.getOrDefault("sportType", "") + "|"
                        + asset.getOrDefault("courtNumber", "1") + "|"
                        + asset.getOrDefault("dateStr", "") + "|"
                        + asset.getOrDefault("timeStr", "") + "|"
                        + asset.getOrDefault("priceFormatted", "") + "|"
                        + (user.getFullname() != null ? user.getFullname().replace("|", "/") : "Người gửi") + "|"
                        + (receiver.getFullname() != null ? receiver.getFullname().replace("|", "/") : "Người nhận") + "|"
                        + note + "]";

                String msgTime = (time != null && !time.trim().isEmpty()) ? time.trim()
                        : java.time.LocalTime.now().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm"));
                chatService.sendFriendMessage(user.getId(), receiverId, msgPayload, msgTime);

                java.util.Map<String, Object> resMap = new java.util.LinkedHashMap<>();
                resMap.put("status", "success");
                resMap.put("transferredBooking", asset);
                resMap.put("messageText", msgPayload);
                resMap.put("time", msgTime);
                JsonResponse.ok(resp, resMap);
            } else {
                JsonResponse.error(resp, HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
            }
        } catch (IllegalArgumentException e) {
            JsonResponse.error(resp, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            JsonResponse.error(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }
}
