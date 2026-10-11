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
 * GET  /register → auth/register.jsp
 * POST /register → tạo tài khoản, thành công thì về /login?registered=true
 * </pre>
 */
@WebServlet("/register")
public class RegisterServlet extends BaseServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        render(req, resp, "auth/register");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String fullname = req.getParameter("fullname");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirm_password");

        if (password == null || !password.equals(confirmPassword)) {
            redirect(req, resp, "/register?error=password_mismatch");
            return;
        }

        String status = userDAO.registerUser(new User(fullname, email, password));
        if ("SUCCESS".equals(status)) {
            redirect(req, resp, "/login?registered=true");
        } else if ("EMAIL_EXISTS".equals(status)) {
            redirect(req, resp, "/register?error=email_exists");
        } else {
            redirect(req, resp, "/register?error=db_error");
        }
    }
}

