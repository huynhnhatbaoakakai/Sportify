package com.sportify.controller;

import com.sportify.data.CustomerDB;
import com.sportify.model.CustomerOverview;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet("/owner/customers")
public class ManageCustomersServlet extends HttpServlet {

    // TODO: use session.getAttribute("userId") and require the OWNER role.
    private static final Long DEMO_OWNER_ID = 1L;

    @Override
    protected void doGet(
            HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String search = "";
        try {
            search = CustomerDB.normalizeSearch(request.getParameter("q"));
        } catch (IllegalArgumentException exception) {
            request.setAttribute("errorMessage", exception.getMessage());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
        request.setAttribute("search", search);

        try {
            List<CustomerOverview> customers = CustomerDB.findByOwnerId(DEMO_OWNER_ID, search);
            CustomerDB.Summary summary = CustomerDB.getSummaryByOwnerId(DEMO_OWNER_ID);
            request.setAttribute("customers", customers);
            request.setAttribute("customerNameCount", summary.getCustomerNameCount());
            request.setAttribute("reviewCount", summary.getReviewCount());
            request.setAttribute("reviewedFieldCount", summary.getFieldCount());
        } catch (RuntimeException | ExceptionInInitializerError | NoClassDefFoundError exception) {
            getServletContext().log("Không thể tải danh sách khách hàng của chủ sân.", exception);
            request.setAttribute("customers", Collections.<CustomerOverview>emptyList());
            request.setAttribute("customerNameCount", 0L);
            request.setAttribute("reviewCount", 0L);
            request.setAttribute("reviewedFieldCount", 0L);
            request.setAttribute("loadFailed", Boolean.TRUE);
            request.setAttribute("errorMessage", "Không thể tải khách hàng. Vui lòng thử lại sau.");
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
        }

        request.getRequestDispatcher("/owner/customers.jsp").forward(request, response);
    }
}
