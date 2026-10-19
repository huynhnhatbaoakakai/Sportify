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


    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        try {
            Long ownerId = com.sportify.util.OwnerAccess.resolveOwnerId(request);
            List<SportField> fields =
                    SportFieldDB.findByOwnerId(ownerId);

            request.setAttribute("fields", fields);
            request.setAttribute("bookingHistory", com.sportify.data.BookingActivityDB.findByOwner(ownerId));
            request.setAttribute("ownerId", ownerId);
            request.setAttribute("bookingPage", "/owner/bookings".equals(request.getServletPath()));

            if (request.getSession().getAttribute(UpdateBookingStatusServlet.CSRF_ATTRIBUTE) == null) {
                request.getSession().setAttribute(
                        UpdateBookingStatusServlet.CSRF_ATTRIBUTE, UUID.randomUUID().toString());
            }
            request.setAttribute("bookingCsrfToken",
                    request.getSession().getAttribute(UpdateBookingStatusServlet.CSRF_ATTRIBUTE));
            try {
                List<Booking> bookings = BookingDB.findByOwnerId(ownerId);
                BookingDB.Summary summary = BookingDB.getDashboardSummary(
                        ownerId, LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")));
                List<BookingDB.BookedSlotSummary> bookedSlots = BookingDB.groupBookedSlots(bookings);
                request.setAttribute("bookings", bookings);
                request.setAttribute("bookedSlots", bookedSlots);
                request.setAttribute("todayBookingCount", summary.getTodayCount());
                request.setAttribute("pendingBookingCount", summary.getPendingCount());
                request.setAttribute("todayBookingRevenue", summary.getTodayRevenue());
            } catch (RuntimeException exception) {
                getServletContext().log("Không thể tải các đơn đặt sân.", exception);
                request.setAttribute("bookings", Collections.<Booking>emptyList());
                request.setAttribute("bookedSlots", Collections.<BookingDB.BookedSlotSummary>emptyList());
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
