package com.sportify.controller;

import com.sportify.data.BookingDB;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Locale;

@WebServlet("/owner/bookings/status")
public class UpdateBookingStatusServlet extends HttpServlet {

    static final String CSRF_ATTRIBUTE = com.sportify.util.Csrf.SESSION_KEY;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String result;
        HttpSession session = request.getSession(false);
        String expectedToken = session == null ? null : (String) session.getAttribute(CSRF_ATTRIBUTE);
        String submittedToken = request.getParameter("csrfToken");
        if (expectedToken == null || submittedToken == null
                || !MessageDigest.isEqual(expectedToken.getBytes(StandardCharsets.UTF_8),
                submittedToken.getBytes(StandardCharsets.UTF_8))) {
            redirect(request, response, "error=booking_csrf");
            return;
        }

        try {
            String id = request.getParameter("bookingId");
            if (id == null || !id.trim().matches("[0-9]+")) throw new IllegalArgumentException();
            Long bookingId = Long.valueOf(id.trim());
            if (bookingId <= 0) throw new IllegalArgumentException();
            String status = request.getParameter("status");
            if (!"CONFIRMED".equals(status) && !"REJECTED".equals(status) && !"COMPLETED".equals(status)) throw new IllegalArgumentException();

            Long ownerId = com.sportify.util.OwnerAccess.resolveOwnerId(request);
            BookingDB.StatusChangeResult changed = BookingDB.changeStatus(bookingId, ownerId, status);
            result = changed == BookingDB.StatusChangeResult.UPDATED
                    ? "success=booking_" + status.toLowerCase(Locale.ROOT)
                    : "error=booking_" + changed.name().toLowerCase(Locale.ROOT);
        } catch (IllegalArgumentException exception) {
            result = "error=booking_invalid";
        } catch (RuntimeException | ExceptionInInitializerError | NoClassDefFoundError exception) {
            getServletContext().log("Không thể cập nhật trạng thái đơn đặt sân.", exception);
            result = "error=booking_save";
        }
        redirect(request, response, result);
    }

    private static void redirect(HttpServletRequest request, HttpServletResponse response, String result)
            throws IOException {
        String from = request.getParameter("from");
        if ("customers".equals(from)) {
            response.sendRedirect(request.getContextPath() + "/owner/customers?" + result);
        } else {
            response.sendRedirect(request.getContextPath() + "/owner/bookings?" + result + "#booking-section");
        }
    }
}
