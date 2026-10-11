package com.sportify.controller.home;

import com.sportify.controller.BaseServlet;
import com.sportify.dao.AppointmentDAO;
import com.sportify.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * GET /home → user/home.jsp (trang tổng quan sau khi đăng nhập).
 * <p>
 * Attributes gửi cho view: {@code upcomingCount}, {@code trainingHours}, {@code upcomingAppts}.
 */
@WebServlet("/home")
public class HomeServlet extends BaseServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        req.setAttribute("upcomingCount", appointmentDAO.countUpcoming(user.getId()));
        req.setAttribute("trainingHours", appointmentDAO.getTrainingHoursThisMonth(user.getId()));
        req.setAttribute("upcomingAppts", appointmentDAO.getUpcomingAppointments(user.getId()));
        render(req, resp, "user/home");
    }
}

