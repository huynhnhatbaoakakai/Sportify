package com.sportify.controller.auth;

import com.sportify.controller.BaseServlet;
import com.sportify.dao.UserDAO;
import com.sportify.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * <pre>
 * GET  /login → auth/login.jsp
 * POST /login → kiểm tra email/mật khẩu, thành công thì vào /home
 * </pre>
 */
@WebServlet("/login")
public class LoginServlet extends BaseServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        render(req, resp, "auth/login");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = userDAO.checkLogin(req.getParameter("email"), req.getParameter("password"));
        if (user != null) {
            if (req.getSession(false) != null) req.getSession(false).invalidate();
            req.getSession().setAttribute(SESSION_USER, user);
            redirect(req, resp, user.isOwner() ? "/owner/fields" : "/home");
        } else {
            redirect(req, resp, "/login?error=invalid");
        }
    }
}

