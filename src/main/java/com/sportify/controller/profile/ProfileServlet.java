package com.sportify.controller.profile;

import com.sportify.controller.BaseServlet;
import com.sportify.dao.UserDAO;
import com.sportify.model.User;
import com.sportify.util.Csrf;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

/** GET shows the current account; POST saves only that account's editable profile. */
@WebServlet("/profile")
public class ProfileServlet extends BaseServlet {
    private final UserDAO users = new UserDAO();
    private static final String SAVED = "PROFILE_SAVED";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        if (user == null) { redirect(req, resp, "/login"); return; }
        try {
            User profile = users.findById(user.getId());
            if (profile == null) { req.getSession().invalidate(); redirect(req, resp, "/login"); return; }
            req.getSession().setAttribute(SESSION_USER, profile);
            req.setAttribute("profile", profile);
            if (Boolean.TRUE.equals(req.getSession().getAttribute(SAVED))) {
                req.setAttribute("successMsg", "Đã lưu thay đổi hồ sơ của bạn.");
                req.getSession().removeAttribute(SAVED);
            }
        } catch (RuntimeException exception) {
            getServletContext().log("Không thể tải hồ sơ", exception);
            resp.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            req.setAttribute("profile", user);
            req.setAttribute("errorMsg", "Chưa thể tải hồ sơ. Vui lòng tải lại trang sau.");
        }
        render(req, resp, "user/profile");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User user = currentUser(req);
        if (user == null) { redirect(req, resp, "/login"); return; }
        if (!Csrf.isValid(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Biểu mẫu đã hết hiệu lực. Vui lòng tải lại trang.");
            return;
        }
        User profile = new User(user.getId(), value(req, "fullname"), user.getEmail(), null);
        profile.setRole(user.getRole());
        profile.setCreatedAt(user.getCreatedAt());
        profile.setPhone(value(req, "phone").replace(" ", ""));
        profile.setGender(value(req, "gender"));
        profile.setAddress(value(req, "address"));
        String birthDate = value(req, "dob");
        String error = null;
        try {
            if (!birthDate.isEmpty()) profile.setDateOfBirth(LocalDate.parse(birthDate));
        } catch (DateTimeParseException exception) {
            error = "Vui lòng nhập ngày sinh hợp lệ.";
        }
        if (error == null) error = UserDAO.validateProfile(profile);
        if (error != null) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            showError(req, resp, profile, birthDate, error);
            return;
        }
        try {
            User saved = users.updateProfile(user.getId(), profile);
            if (saved == null) { req.getSession().invalidate(); redirect(req, resp, "/login"); return; }
            req.getSession().setAttribute(SESSION_USER, saved);
            req.getSession().setAttribute(SAVED, true);
            redirect(req, resp, "/profile");
        } catch (RuntimeException exception) {
            getServletContext().log("Không thể lưu hồ sơ", exception);
            resp.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            showError(req, resp, profile, birthDate, "Chưa lưu được thay đổi. Vui lòng thử lại sau.");
        }
    }

    private void showError(HttpServletRequest req, HttpServletResponse resp, User profile, String birthDate, String error)
            throws ServletException, IOException {
        req.setAttribute("profile", profile);
        req.setAttribute("profileDob", birthDate);
        req.setAttribute("errorMsg", error);
        render(req, resp, "user/profile");
    }

    private static String value(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        return value == null ? "" : value.trim();
    }
}

