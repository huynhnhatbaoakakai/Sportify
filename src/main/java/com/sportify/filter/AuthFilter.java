package com.sportify.filter;

import com.sportify.controller.BaseServlet;
import com.sportify.util.JsonResponse;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Chặn truy cập các trang/API cần đăng nhập.
 * <ul>
 *   <li>Trang HTML: chuyển hướng về /login</li>
 *   <li>API (đuôi -api): trả 401 JSON</li>
 * </ul>
 * Thêm URL mới cần bảo vệ vào {@code urlPatterns} bên dưới.
 */
@WebFilter(urlPatterns = {
        "/home",
        "/newsfeed", "/newsfeed-api",
        "/chat", "/chat-friends", "/chat-api",
        "/appointments", "/appointments/*",
        "/profile",
        "/owner/*"
})
public class AuthFilter extends HttpFilter {

    @Override
    protected void doFilter(HttpServletRequest req, HttpServletResponse resp, FilterChain chain)
            throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        boolean loggedIn = session != null && session.getAttribute(BaseServlet.SESSION_USER) != null;

        if (loggedIn) {
            chain.doFilter(req, resp);
        } else if (req.getServletPath().endsWith("-api")) {
            JsonResponse.error(resp, HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
        } else {
            resp.sendRedirect(req.getContextPath() + "/login");
        }
    }
}

