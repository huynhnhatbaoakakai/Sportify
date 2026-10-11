package com.sportify.controller;

import com.sportify.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Lớp cha cho mọi servlet trong ứng dụng.
 * Gom các thao tác lặp lại: lấy user đăng nhập, hiển thị view, redirect.
 */
public abstract class BaseServlet extends HttpServlet {

    /** Key lưu user đăng nhập trong session. */
    public static final String SESSION_USER = "user";

    private static final String VIEW_PREFIX = "/WEB-INF/views/";
    private static final String VIEW_SUFFIX = ".jsp";

    /** User đang đăng nhập, hoặc {@code null} nếu chưa đăng nhập. */
    protected User currentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (User) session.getAttribute(SESSION_USER);
    }

    /**
     * Forward tới view trong {@code /WEB-INF/views}.
     *
     * @param view đường dẫn tương đối, không có đuôi .jsp (vd. {@code "user/home"})
     */
    protected void render(HttpServletRequest req, HttpServletResponse resp, String view)
            throws ServletException, IOException {
        req.getRequestDispatcher(VIEW_PREFIX + view + VIEW_SUFFIX).forward(req, resp);
    }

    /**
     * Redirect tới đường dẫn trong ứng dụng.
     *
     * @param path đường dẫn bắt đầu bằng "/" (vd. {@code "/login?error=invalid"})
     */
    protected void redirect(HttpServletRequest req, HttpServletResponse resp, String path) throws IOException {
        resp.sendRedirect(req.getContextPath() + path);
    }
}

