package com.sportify.controller;

import com.sportify.data.ReviewDB;
import com.sportify.model.Review;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet("/owner/reviews")
public class ManageReviewsServlet extends HttpServlet {

    // TODO: use session.getAttribute("userId") and require the OWNER role.
    private static final Long DEMO_OWNER_ID = 1L;

    @Override
    protected void doGet(
            HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        Integer rating = parseRating(request.getParameter("rating"));
        if (rating == null && request.getParameter("rating") != null
                && !request.getParameter("rating").trim().isEmpty()) {
            request.setAttribute("errorMessage", "Bộ lọc số sao không hợp lệ.");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
        request.setAttribute("selectedRating", rating);

        try {
            Long ownerId = com.sportify.util.OwnerAccess.resolveOwnerId(request);
            List<Review> reviews = ReviewDB.findByOwnerId(ownerId, rating);
            ReviewDB.Summary summary = ReviewDB.getSummaryByOwnerId(ownerId);
            request.setAttribute("reviews", reviews);
            request.setAttribute("totalReviews", summary.getTotalCount());
            request.setAttribute("averageRating", summary.getAverageRating());
        } catch (RuntimeException | ExceptionInInitializerError | NoClassDefFoundError exception) {
            getServletContext().log("Không thể tải đánh giá của chủ sân.", exception);
            request.setAttribute("reviews", Collections.<Review>emptyList());
            request.setAttribute("totalReviews", 0L);
            request.setAttribute("averageRating", 0.0);
            request.setAttribute("loadFailed", Boolean.TRUE);
            request.setAttribute("errorMessage",
                    "Không thể tải đánh giá. Vui lòng thử lại sau.");
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
        }

        request.getRequestDispatcher("/owner/reviews.jsp").forward(request, response);
    }

    static Integer parseRating(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.matches("[1-5]") ? Integer.valueOf(trimmed) : null;
    }
}
