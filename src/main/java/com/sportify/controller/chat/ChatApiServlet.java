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
            } else {
                JsonResponse.error(resp, HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
            }
        } catch (Exception e) {
            e.printStackTrace();
            JsonResponse.error(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }
}
