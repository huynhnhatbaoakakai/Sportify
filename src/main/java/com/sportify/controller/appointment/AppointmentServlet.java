package com.sportify.controller.appointment;

import com.sportify.controller.BaseServlet;
import com.sportify.dao.AppointmentDAO;
import com.sportify.model.Appointment;
import com.sportify.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Quản lý lịch hẹn của người dùng.
 *
 * <pre>
 * GET  /appointments            → user/appointments.jsp
 * POST /appointments            → tạo lịch hẹn mới rồi hiển thị lại trang
 * GET  /appointments/delete?id= → xoá lịch hẹn, quay về /appointments?deleted=1
 * </pre>
 * Attributes gửi cho view: {@code allAppts}, {@code successMsg}, {@code errorMsg}.
 */
@WebServlet({"/appointments", "/appointments/delete"})
public class AppointmentServlet extends BaseServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if ("/appointments/delete".equals(req.getServletPath())) {
            delete(req, resp);
        } else {
            showPage(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        String title = req.getParameter("title");
        String date = req.getParameter("date");
        String time = req.getParameter("time");
        String note = req.getParameter("note");

        if (title == null || title.trim().isEmpty() || date == null || time == null) {
            req.setAttribute("errorMsg", "❌ Vui lòng điền đầy đủ thông tin bắt buộc.");
        } else {
            Appointment a = new Appointment();
            a.setUserId(user.getId());
            a.setTitle(title.trim());
            a.setAppointmentDate(date);
            a.setAppointmentTime(time);
            a.setType(req.getParameter("type"));
            a.setNote(note != null ? note.trim() : "");

            if (appointmentDAO.createAppointment(a)) {
                req.setAttribute("successMsg", "✅ Đã thêm lịch hẹn thành công!");
            } else {
                req.setAttribute("errorMsg", "❌ Không thể lưu lịch hẹn. Vui lòng thử lại.");
            }
        }
        showPage(req, resp);
    }

    private void showPage(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("allAppts", appointmentDAO.getAllAppointments(currentUser(req).getId()));
        render(req, resp, "user/appointments");
    }

    private void delete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            appointmentDAO.deleteAppointment(id, currentUser(req).getId());
        } catch (NumberFormatException e) {
            redirect(req, resp, "/appointments");
            return;
        }
        redirect(req, resp, "/appointments?deleted=1");
    }
}

