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
        try {
            if ("getPosts".equals(req.getParameter("action"))) {
                JsonResponse.ok(resp, postDAO.getAllPosts(user.getId()));
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
        if (isBlank(content)) {
            JsonResponse.ok(resp, errorBody("Nội dung không được trống"));
            return;
        }
        boolean ok = postDAO.createPost(user.getId(), content.trim());
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
