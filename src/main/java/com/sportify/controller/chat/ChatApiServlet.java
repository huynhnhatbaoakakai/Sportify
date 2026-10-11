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
 * API JSON cho 2 trang chat.
 *
 * <pre>
 * GET  /chat-api?action=getConversations          → hội thoại với dịch vụ   (trang /chat)
 * GET  /chat-api?action=getFriends                → hội thoại với bạn bè    (trang /chat-friends)
 * POST /chat-api  action=sendMessage       sessionId, text, time
 * POST /chat-api  action=sendFriendMessage receiverId, text, time
 * </pre>
 */
@WebServlet("/chat-api")
public class ChatApiServlet extends BaseServlet {

    private final ChatService chatService = new ChatService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = currentUser(req);
        String action = req.getParameter("action");
        try {
            if ("getConversations".equals(action)) {
                JsonResponse.ok(resp, chatService.getServiceConversations(user.getId()));
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
                int sessionId = Integer.parseInt(req.getParameter("sessionId"));
                chatService.sendServiceMessage(sessionId, text, time);
                JsonResponse.success(resp);
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
