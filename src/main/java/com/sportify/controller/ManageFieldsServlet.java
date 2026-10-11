package com.sportify.controller;

import com.sportify.data.SportFieldDB;
import com.sportify.data.BookingDB;
import com.sportify.model.Booking;
import com.sportify.model.SportField;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Collections;
import java.util.UUID;
import java.time.LocalDate;
import java.time.ZoneId;

@WebServlet({"/owner/fields", "/owner/bookings"})
public class ManageFieldsServlet extends HttpServlet {

    // TODO: use session.getAttribute("userId") and require the OWNER role.
    private static final Long DEMO_OWNER_ID = 1L;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        try {
            List<SportField> fields =
                    SportFieldDB.findByOwnerId(DEMO_OWNER_ID);

            request.setAttribute("fields", fields);
            request.setAttribute("ownerId", DEMO_OWNER_ID);
            request.setAttribute("bookingPage", "/owner/bookings".equals(request.getServletPath()));
            request.setAttribute("bookingPage", "/owner/bookings".equals(request.getServletPath()));

            if (request.getSession().getAttribute(UpdateBookingStatusServlet.CSRF_ATTRIBUTE) == null) {
                request.getSession().setAttribute(
                        UpdateBookingStatusServlet.CSRF_ATTRIBUTE, UUID.randomUUID().toString());
            }
            request.setAttribute("bookingCsrfToken",
                    request.getSession().getAttribute(UpdateBookingStatusServlet.CSRF_ATTRIBUTE));
            try {
                List<Booking> bookings = BookingDB.findByOwnerId(DEMO_OWNER_ID);
                BookingDB.Summary summary = BookingDB.getDashboardSummary(
                        DEMO_OWNER_ID, LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")));
                request.setAttribute("bookings", bookings);
                request.setAttribute("todayBookingCount", summary.getTodayCount());
                request.setAttribute("pendingBookingCount", summary.getPendingCount());
                request.setAttribute("todayBookingRevenue", summary.getTodayRevenue());
            } catch (RuntimeException exception) {
                getServletContext().log("Không thể tải các đơn đặt sân.", exception);
                request.setAttribute("bookings", Collections.<Booking>emptyList());
                request.setAttribute("bookingLoadFailed", Boolean.TRUE);
            }

            request.getRequestDispatcher("/owner/dashboard.jsp")
                    .forward(request, response);

       } catch (Exception exception) {
    throw new ServletException(
            "Lỗi khi đọc bảng sports_fields",
            exception
    );
}
    }
}
