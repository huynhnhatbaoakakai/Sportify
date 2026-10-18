package com.sportify.controller.profile;

import com.sportify.controller.BaseServlet;
import com.sportify.dao.UserDAO;
import com.sportify.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;

/**
 * GET/POST /profile → user/profile.jsp.
 */
@WebServlet("/profile")
public class ProfileServlet extends BaseServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User current = (User) session.getAttribute("user");
            User fresh = userDAO.getUserById(current.getId());
            if (fresh != null) {
                session.setAttribute("user", fresh);
            }
        }
        render(req, resp, "user/profile");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");
        String fullname = req.getParameter("fullname");
        String phone = req.getParameter("phone");
        String gender = req.getParameter("gender");
        String dobStr = req.getParameter("dob");
        String address = req.getParameter("address");

        if (fullname != null && !fullname.trim().isEmpty()) {
            user.setFullname(fullname.trim());
        }
        user.setPhone(phone != null ? phone.trim() : null);
        user.setGender(gender != null ? gender.trim() : null);
        if (dobStr != null && !dobStr.trim().isEmpty()) {
            try {
                user.setDateOfBirth(LocalDate.parse(dobStr.trim()));
            } catch (Exception ignored) {
            }
        }
        user.setAddress(address != null ? address.trim() : null);

        if (userDAO.updateProfile(user)) {
            User updated = userDAO.getUserById(user.getId());
            if (updated != null) {
                session.setAttribute("user", updated);
            }
            req.setAttribute("successMessage", "Cập nhật thông tin hồ sơ thành công!");
        } else {
            req.setAttribute("errorMessage", "Không thể cập nhật hồ sơ, vui lòng thử lại.");
        }
        render(req, resp, "user/profile");
    }
}

