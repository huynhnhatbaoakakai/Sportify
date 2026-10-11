package com.sportify.controller.booking;

import com.sportify.controller.BaseServlet;
import com.sportify.data.BookingDB;
import com.sportify.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;

import com.sportify.data.SportFieldDB;
import com.sportify.model.SportField;
import jakarta.servlet.ServletException;

/**
 * Khách hàng đặt sân / dịch vụ:
 * <pre>
 * GET  /field-booking?fieldId= → hiển thị giao diện riêng để đặt lịch cho sân đó (user/booking.jsp)
 * POST /field-booking          → tạo đơn PENDING (chủ sân xác nhận/từ chối ở kênh chủ sân)
 * POST /field-booking/cancel   → khách hủy đơn đang chờ xác nhận
 * </pre>
 * Sau khi xử lý luôn quay về /home kèm thông báo (?bookingMsg=...&bookingOk=1|0).
 */
@WebServlet({"/field-booking", "/field-booking/cancel"})
public class FieldBookingServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        if (user == null) {
            redirect(req, resp, "/login");
            return;
        }

        String fieldIdParam = req.getParameter("fieldId");
        if (fieldIdParam == null || fieldIdParam.trim().isEmpty()) {
            redirect(req, resp, "/home#fields");
            return;
        }

        try {
            Long fieldId = Long.valueOf(fieldIdParam);
            SportField field = SportFieldDB.findById(fieldId);
            if (field == null || !"ACTIVE".equalsIgnoreCase(field.getStatus())) {
                redirect(req, resp, "/home?bookingOk=0&bookingMsg="
                        + URLEncoder.encode("Sân không tồn tại hoặc đang tạm ngưng.", StandardCharsets.UTF_8));
                return;
            }
            req.setAttribute("field", field);
            render(req, resp, "user/booking");
        } catch (NumberFormatException e) {
            redirect(req, resp, "/home#fields");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        User user = currentUser(req);
        if (user == null) {
            redirect(req, resp, "/login");
            return;
        }
        if ("/field-booking/cancel".equals(req.getServletPath())) {
            cancel(req, resp, user);
        } else {
            create(req, resp, user);
        }
    }

    private void create(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        Long fieldId;
        LocalDateTime startsAt;
        LocalDateTime endsAt;
        try {
            fieldId = Long.valueOf(req.getParameter("fieldId"));
            LocalDate date = LocalDate.parse(req.getParameter("date"));
            startsAt = date.atTime(LocalTime.parse(req.getParameter("startTime")));
            endsAt = date.atTime(LocalTime.parse(req.getParameter("endTime")));
        } catch (NullPointerException | NumberFormatException | DateTimeParseException e) {
            back(req, resp, false, "Vui lòng chọn đầy đủ sân, ngày và khung giờ hợp lệ.");
            return;
        }

        String phone = req.getParameter("phone");
        phone = phone == null ? null : phone.trim();
        if (phone != null && phone.isEmpty()) phone = null;
        if (phone != null && !phone.matches("[0-9+ ]{8,20}")) {
            back(req, resp, false, "Số điện thoại không hợp lệ.");
            return;
        }

        String name = user.getFullname() != null && !user.getFullname().trim().isEmpty()
                ? user.getFullname().trim() : user.getEmail();

        BookingDB.CreateResult result;
        try {
            result = BookingDB.createCustomerBooking(fieldId, user.getId(), name, phone, startsAt, endsAt);
        } catch (RuntimeException e) {
            getServletContext().log("Không thể tạo đơn đặt sân", e);
            back(req, resp, false, "Có lỗi khi lưu đơn đặt sân. Vui lòng thử lại.");
            return;
        }

        switch (result) {
            case CREATED:
                back(req, resp, true, "Đã gửi yêu cầu đặt lịch! Vui lòng chờ chủ sân xác nhận.");
                break;
            case FIELD_NOT_FOUND:
                back(req, resp, false, "Không tìm thấy sân/dịch vụ.");
                break;
            case FIELD_INACTIVE:
                back(req, resp, false, "Sân/dịch vụ này đang tạm ngưng hoạt động.");
                break;
            case PAST_TIME:
                back(req, resp, false, "Không thể đặt lịch trong quá khứ.");
                break;
            case CONFLICT:
                back(req, resp, false, "Khung giờ này đã có người đặt. Vui lòng chọn giờ khác.");
                break;
            case DUPLICATE:
                back(req, resp, false, "Bạn đã gửi yêu cầu cho khung giờ này rồi, đang chờ xác nhận.");
                break;
            default:
                back(req, resp, false, "Khung giờ không hợp lệ hoặc nằm ngoài giờ mở cửa.");
        }
    }

    private void cancel(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        try {
            Long bookingId = Long.valueOf(req.getParameter("bookingId"));
            if (BookingDB.cancelByCustomer(bookingId, user.getId())) {
                back(req, resp, true, "Đã hủy yêu cầu đặt lịch.");
            } else {
                back(req, resp, false, "Không thể hủy đơn này (có thể chủ sân đã xử lý).");
            }
        } catch (NumberFormatException e) {
            back(req, resp, false, "Mã đơn không hợp lệ.");
        }
    }

    private void back(HttpServletRequest req, HttpServletResponse resp, boolean ok, String msg) throws IOException {
        redirect(req, resp, "/home?bookingOk=" + (ok ? 1 : 0)
                + "&bookingMsg=" + URLEncoder.encode(msg, StandardCharsets.UTF_8) + "#my-bookings");
    }
}

