package com.sportify.controller.chat;

import com.sportify.controller.BaseServlet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Hiển thị trang chat bạn bè. Dữ liệu được tải bằng JS qua {@link ChatApiServlet}.
 * <pre>
 * GET /chat          → redirect /chat-friends
 * GET /chat-friends  → user/chat-friends.jsp  (chat với bạn bè)
 * </pre>
 */
@WebServlet({"/chat", "/chat-friends"})
public class ChatPageServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if ("/chat".equals(req.getServletPath())) {
            resp.sendRedirect(req.getContextPath() + "/chat-friends");
            return;
        }
        render(req, resp, "user/chat-friends");
    }
}

