package com.sportify.controller.newsfeed;

import com.sportify.controller.BaseServlet;
import com.sportify.dao.PostDAO;
import com.sportify.model.PostComment;
import com.sportify.model.User;
import com.sportify.util.JsonResponse;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * API JSON cho trang Newsfeed.
 *
 * <pre>
 * GET  /newsfeed-api?action=getPosts
 * POST /newsfeed-api  action=createPost  content
 * POST /newsfeed-api  action=toggleLike  postId
 * POST /newsfeed-api  action=addComment  postId, content
 * </pre>
 */
@WebServlet("/newsfeed-api")
public class NewsfeedApiServlet extends BaseServlet {

    private final PostDAO postDAO = new PostDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = currentUser(req);
        String action = req.getParameter("action");
        try {
            if ("getPosts".equals(action)) {
                JsonResponse.ok(resp, postDAO.getAllPosts(user.getId()));
            } else if ("getMyBookings".equals(action)) {
                java.util.List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
                for (com.sportify.model.Booking b : com.sportify.data.BookingDB.findConfirmedAssetsByUserId(user.getId())) {
                    list.add(com.sportify.data.BookingDB.toAssetMap(b));
                }
                JsonResponse.ok(resp, list);
            } else {
                JsonResponse.error(resp, HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
            }
        } catch (Exception e) {
            e.printStackTrace();
            JsonResponse.error(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        User user = currentUser(req);
        String action = req.getParameter("action");
        try {
            switch (action == null ? "" : action) {
                case "createPost":
                    createPost(req, resp, user);
                    break;
                case "toggleLike":
                    toggleLike(req, resp, user);
                    break;
                case "addComment":
                    addComment(req, resp, user);
                    break;
                default:
                    JsonResponse.error(resp, HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
            }
        } catch (Exception e) {
            e.printStackTrace();
            JsonResponse.error(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    private void createPost(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        String content = req.getParameter("content");
        String bookingIdParam = req.getParameter("bookingId");
        String postPurpose = req.getParameter("postPurpose");

        Long bookingId = null;
        if (bookingIdParam != null && !bookingIdParam.trim().isEmpty()) {
            try {
                long parsed = Long.parseLong(bookingIdParam.trim());
                if (parsed > 0) {
                    com.sportify.model.Booking b = com.sportify.data.BookingDB.findById(parsed);
                    if (b != null && b.getCustomerId() != null && b.getCustomerId() == user.getId()
                            && "CONFIRMED".equals(b.getStatus())) {
                        bookingId = parsed;
                    }
                }
            } catch (NumberFormatException ignored) {
            }
        }

        if (isBlank(content) && bookingId == null) {
            JsonResponse.ok(resp, errorBody("Nội dung không được trống"));
            return;
        }
        String finalContent = isBlank(content)
                ? ("PASS_SAN".equals(postPurpose) ? "Mình cần nhượng lại lịch đặt sân đã xác nhận bên dưới, bạn nào cần nhắn mình nhé!" : "Mình đã đặt sẵn sân bên dưới, rủ anh em giao lưu cùng nhé!")
                : content.trim();

        boolean ok = postDAO.createPost(user.getId(), finalContent, bookingId, postPurpose);
        Map<String, Object> result = new HashMap<>();
        result.put("status", ok ? "success" : "error");
        JsonResponse.ok(resp, result);
    }

    private void toggleLike(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        int postId = Integer.parseInt(req.getParameter("postId"));
        boolean liked = postDAO.toggleLike(postId, user.getId());
        Map<String, Object> result = new HashMap<>();
        result.put("liked", liked);
        result.put("likeCount", postDAO.getLikeCount(postId));
        JsonResponse.ok(resp, result);
    }

    private void addComment(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        int postId = Integer.parseInt(req.getParameter("postId"));
        String content = req.getParameter("content");
        if (isBlank(content)) {
            JsonResponse.ok(resp, errorBody("Bình luận không được trống"));
            return;
        }
        PostComment comment = postDAO.addComment(postId, user.getId(), content.trim(), user.getFullname());
        JsonResponse.ok(resp, comment != null ? comment : errorBody("Không thể thêm bình luận"));
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    /** Lỗi validate: giữ status 200 như trước để JS hiển thị thông báo. */
    private static Map<String, String> errorBody(String message) {
        Map<String, String> body = new HashMap<>();
        body.put("error", message);
        return body;
    }
}
