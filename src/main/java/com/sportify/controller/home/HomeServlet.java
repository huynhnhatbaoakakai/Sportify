package com.sportify.controller.home;

import com.sportify.controller.BaseServlet;
import com.sportify.dao.AppointmentDAO;
import com.sportify.data.BookingDB;
import com.sportify.data.SportFieldDB;
import com.sportify.model.Booking;
import com.sportify.model.SportField;
import com.sportify.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

/**
 * GET /home → user/home.jsp (trang tổng quan sau khi đăng nhập).
 * <p>
 * Attributes gửi cho view: {@code upcomingCount}, {@code trainingHours}, {@code upcomingAppts},
 * {@code activeFields}, {@code customerBookings}, {@code bookingMsg}, {@code bookingOk}.
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

        try {
            List<SportField> activeFields = SportFieldDB.findActive();
            req.setAttribute("activeFields", activeFields);
        } catch (Exception e) {
            getServletContext().log("Không thể tải danh sách sân.", e);
            req.setAttribute("activeFields", Collections.emptyList());
        }

        try {
            List<Booking> customerBookings = BookingDB.findByCustomerId(user.getId());
            req.setAttribute("customerBookings", customerBookings);
        } catch (Exception e) {
            getServletContext().log("Không thể tải danh sách đơn đặt sân.", e);
            req.setAttribute("customerBookings", Collections.emptyList());
        }

        try {
            List<Booking> allActiveBookings = BookingDB.findAllActiveBookings();
            List<BookingDB.BookedSlotSummary> bookedSlots = BookingDB.groupBookedSlots(allActiveBookings);
            req.setAttribute("allActiveBookings", allActiveBookings);
            req.setAttribute("bookedSlots", bookedSlots);
        } catch (Exception e) {
            getServletContext().log("Không thể tải danh sách các khung giờ đã đặt.", e);
            req.setAttribute("allActiveBookings", Collections.emptyList());
            req.setAttribute("bookedSlots", Collections.emptyList());
        }

        req.setAttribute("bookingMsg", req.getParameter("bookingMsg"));
        req.setAttribute("bookingOk", "1".equals(req.getParameter("bookingOk")));

        render(req, resp, "user/home");
    }
}

