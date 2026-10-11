package com.sportify.controller.chat;

import com.sportify.controller.BaseServlet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Hiển thị 2 trang chat. Dữ liệu được tải bằng JS qua {@link ChatApiServlet}.
 * <pre>
 * GET /chat          → user/chat.jsp          (chat với dịch vụ)
 * GET /chat-friends  → user/chat-friends.jsp  (chat với bạn bè)
 * </pre>
 */
@WebServlet({"/chat", "/chat-friends"})
public class ChatPageServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String view = "/chat-friends".equals(req.getServletPath()) ? "user/chat-friends" : "user/chat";
        render(req, resp, view);
    }
}

