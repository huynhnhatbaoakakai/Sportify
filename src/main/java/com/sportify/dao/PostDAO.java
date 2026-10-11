package com.sportify.dao;

import com.sportify.model.Post;
import com.sportify.model.PostComment;
import com.sportify.config.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PostDAO {

    // ===== GET ALL POSTS (newest first) =====
    public List<Post> getAllPosts(int currentUserId) {
        List<Post> posts = new ArrayList<>();
        String sql = "SELECT p.id, p.user_id, p.content, " +
                "FORMAT(p.created_at, 'HH:mm dd/MM/yyyy') AS created_at, " +
                "u.fullname, " +
                "(SELECT COUNT(*) FROM PostLikes l WHERE l.post_id = p.id) AS like_count, " +
                "(SELECT COUNT(*) FROM PostLikes l2 WHERE l2.post_id = p.id AND l2.user_id = ?) AS liked_by_me " +
                "FROM Posts p JOIN Users u ON p.user_id = u.id " +
                "ORDER BY p.created_at DESC";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, currentUserId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Post post = new Post();
                    post.setId(rs.getInt("id"));
                    post.setUserId(rs.getInt("user_id"));
                    post.setAuthorName(rs.getString("fullname"));
                    post.setContent(rs.getString("content"));
                    post.setCreatedAt(rs.getString("created_at"));
                    post.setLikeCount(rs.getInt("like_count"));
                    post.setLikedByMe(rs.getInt("liked_by_me") > 0);
                    post.setComments(getCommentsByPostId(post.getId(), conn));
                    posts.add(post);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return posts;
    }

    // ===== GET COMMENTS FOR A POST =====
    private List<PostComment> getCommentsByPostId(int postId, Connection conn) {
        List<PostComment> comments = new ArrayList<>();
        String sql = "SELECT c.id, c.post_id, c.user_id, c.content, " +
                "FORMAT(c.created_at, 'HH:mm dd/MM/yyyy') AS created_at, u.fullname " +
                "FROM PostComments c JOIN Users u ON c.user_id = u.id " +
                "WHERE c.post_id = ? ORDER BY c.created_at ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PostComment c = new PostComment();
                    c.setId(rs.getInt("id"));
                    c.setPostId(rs.getInt("post_id"));
                    c.setUserId(rs.getInt("user_id"));
                    c.setAuthorName(rs.getString("fullname"));
                    c.setContent(rs.getString("content"));
                    c.setCreatedAt(rs.getString("created_at"));
                    comments.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return comments;
    }

    // ===== CREATE A NEW POST =====
    public boolean createPost(int userId, String content) {
        String sql = "INSERT INTO Posts (user_id, content) VALUES (?, ?)";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, content);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ===== TOGGLE LIKE (tim) =====
    // Returns: true = liked, false = unliked
    public boolean toggleLike(int postId, int userId) {
        // Check if already liked
        String checkSql = "SELECT COUNT(*) FROM PostLikes WHERE post_id = ? AND user_id = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, postId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    // Already liked -> unlike
                    String del = "DELETE FROM PostLikes WHERE post_id = ? AND user_id = ?";
                    try (PreparedStatement del_ps = conn.prepareStatement(del)) {
                        del_ps.setInt(1, postId);
                        del_ps.setInt(2, userId);
                        del_ps.executeUpdate();
                    }
                    return false; // now unliked
                } else {
                    // Not liked -> like
                    String ins = "INSERT INTO PostLikes (post_id, user_id) VALUES (?, ?)";
                    try (PreparedStatement ins_ps = conn.prepareStatement(ins)) {
                        ins_ps.setInt(1, postId);
                        ins_ps.setInt(2, userId);
                        ins_ps.executeUpdate();
                    }
                    return true; // now liked
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ===== GET LIKE COUNT =====
    public int getLikeCount(int postId) {
        String sql = "SELECT COUNT(*) FROM PostLikes WHERE post_id = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ===== ADD COMMENT =====
    public PostComment addComment(int postId, int userId, String content, String authorName) {
        String sql = "INSERT INTO PostComments (post_id, user_id, content) VALUES (?, ?, ?); " +
                "SELECT SCOPE_IDENTITY();";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            ps.setInt(2, userId);
            ps.setString(3, content);
            boolean hasResult = ps.execute();
            if (hasResult) {
                try (ResultSet rs = ps.getResultSet()) {
                    if (rs.next()) {
                        PostComment c = new PostComment();
                        c.setId(rs.getInt(1));
                        c.setPostId(postId);
                        c.setUserId(userId);
                        c.setAuthorName(authorName);
                        c.setContent(content);
                        c.setCreatedAt("Vừa xong");
                        return c;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
