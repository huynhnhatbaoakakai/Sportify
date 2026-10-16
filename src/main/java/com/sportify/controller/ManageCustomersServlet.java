package com.sportify.controller;

import com.sportify.data.CustomerDB;
import com.sportify.data.SportFieldDB;
import com.sportify.model.CustomerBookingProfile;
import com.sportify.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

@WebServlet("/owner/customers")
public class ManageCustomersServlet extends HttpServlet {

    private static final Long DEMO_OWNER_ID = 1L;

    @Override
    protected void doGet(
            HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        Long ownerId = DEMO_OWNER_ID;
        HttpSession session = request.getSession(false);
        if (session != null) {
            User sessionUser = (User) session.getAttribute("user");
            if (sessionUser != null && sessionUser.getId() > 0) {
                try {
                    Long uid = (long) sessionUser.getId();
                    if (uid.equals(1L) || !SportFieldDB.findByOwnerId(uid).isEmpty()) {
                        ownerId = uid;
                    }
                } catch (Exception ignored) {
                }
            }
        }

        String search = "";
        try {
            search = CustomerDB.normalizeSearch(request.getParameter("q"));
        } catch (IllegalArgumentException exception) {
            request.setAttribute("errorMessage", exception.getMessage());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
        request.setAttribute("search", search);

        // Đảm bảo CSRF token cho việc duyệt/từ chối đơn trực tiếp từ modal
        if (request.getSession().getAttribute(UpdateBookingStatusServlet.CSRF_ATTRIBUTE) == null) {
            request.getSession().setAttribute(
                    UpdateBookingStatusServlet.CSRF_ATTRIBUTE, UUID.randomUUID().toString());
        }
        request.setAttribute("bookingCsrfToken",
                request.getSession().getAttribute(UpdateBookingStatusServlet.CSRF_ATTRIBUTE));

        String successParam = request.getParameter("success");
        if ("booking_confirmed".equals(successParam)) {
            request.setAttribute("actionNotice", "Đã xác nhận đơn đặt sân thành công.");
        } else if ("booking_rejected".equals(successParam)) {
            request.setAttribute("actionNotice", "Đã từ chối đơn đặt sân.");
        }

        try {
            List<CustomerBookingProfile> customers = CustomerDB.findBookingCustomersByOwnerId(ownerId, search);
            CustomerDB.BookingCustomerSummary summary = CustomerDB.getBookingCustomersSummary(ownerId);

            request.setAttribute("customers", customers);
            request.setAttribute("totalCustomerCount", summary.getTotalCustomers());
            request.setAttribute("totalBookingCount", summary.getTotalBookings());
            request.setAttribute("totalRevenue", summary.getTotalRevenue());
            request.setAttribute("pendingBookingCount", summary.getPendingBookings());
        } catch (RuntimeException | ExceptionInInitializerError | NoClassDefFoundError exception) {
            getServletContext().log("Không thể tải danh sách khách hàng của chủ sân.", exception);
            request.setAttribute("customers", Collections.<CustomerBookingProfile>emptyList());
            request.setAttribute("totalCustomerCount", 0L);
            request.setAttribute("totalBookingCount", 0L);
            request.setAttribute("totalRevenue", BigDecimal.ZERO);
            request.setAttribute("pendingBookingCount", 0L);
            request.setAttribute("loadFailed", Boolean.TRUE);
            request.setAttribute("errorMessage", "Không thể tải khách hàng. Vui lòng thử lại sau.");
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
        }

        request.getRequestDispatcher("/owner/customers.jsp").forward(request, response);
    }
}
