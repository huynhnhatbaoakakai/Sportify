package com.sportify.controller;

import com.sportify.data.ReviewDB;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/owner/reviews/reply")
public class ReplyReviewServlet extends HttpServlet {

    // TODO: use session.getAttribute("userId") and require the OWNER role.
    private static final Long DEMO_OWNER_ID = 1L;

    @Override
    protected void doPost(
            HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        Integer rating = ManageReviewsServlet.parseRating(request.getParameter("rating"));
        String redirectUrl = request.getContextPath() + "/owner/reviews";
        String result;

        try {
            String idValue = request.getParameter("reviewId");
            if (idValue == null || !idValue.trim().matches("[0-9]+")) {
                throw new IllegalArgumentException("Mã đánh giá không hợp lệ.");
            }
            Long reviewId = Long.valueOf(idValue.trim());
            if (reviewId <= 0) {
                throw new IllegalArgumentException("Mã đánh giá không hợp lệ.");
            }

            String replyValue = request.getParameter("ownerReply");
            if (replyValue == null || replyValue.trim().isEmpty()) {
                response.sendRedirect(redirectUrl + "?error=empty" + ratingQuery(rating));
                return;
            }
            if (replyValue.length() > 2000) {
                response.sendRedirect(redirectUrl + "?error=length" + ratingQuery(rating));
                return;
            }

            boolean updated = ReviewDB.saveOwnerReply(reviewId, DEMO_OWNER_ID, replyValue);
            result = updated ? "success=replied" : "error=notfound";
        } catch (IllegalArgumentException exception) {
            result = "error=invalid";
        } catch (RuntimeException | ExceptionInInitializerError | NoClassDefFoundError exception) {
            getServletContext().log("Không thể lưu phản hồi đánh giá.", exception);
            result = "error=save";
        }

        response.sendRedirect(redirectUrl + "?" + result + ratingQuery(rating));
    }

    private static String ratingQuery(Integer rating) {
        return rating == null ? "" : "&rating=" + rating;
    }
}
