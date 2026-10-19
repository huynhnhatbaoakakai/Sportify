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
        String sql = "SELECT p.id, p.user_id, p.content, p.booking_id, p.post_purpose, " +
                "to_char(p.created_at, 'HH24:MI DD/MM/YYYY') AS created_at, " +
                "u.fullname, " +
                "(SELECT COUNT(*) FROM post_likes l WHERE l.post_id = p.id) AS like_count, " +
                "(SELECT COUNT(*) FROM post_likes l2 WHERE l2.post_id = p.id AND l2.user_id = ?) AS liked_by_me, " +
                "b.court_number, b.starts_at, b.ends_at, b.total_price, b.status AS booking_status, " +
                "b.customer_id AS booking_owner_id, b.customer_name AS booking_owner_name, " +
                "sf.field_name, sf.sport_type, sf.address AS field_address, sf.quantity AS field_quantity " +
                "FROM Posts p " +
                "JOIN Users u ON p.user_id = u.id " +
                "LEFT JOIN bookings b ON p.booking_id = b.booking_id " +
                "LEFT JOIN sports_fields sf ON b.field_id = sf.field_id " +
                "ORDER BY p.created_at DESC";
        java.text.NumberFormat vnd = java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN"));
        java.time.format.DateTimeFormatter dFmt = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
        java.time.format.DateTimeFormatter tFmt = java.time.format.DateTimeFormatter.ofPattern("HH:mm");
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

                    long bId = rs.getLong("booking_id");
                    if (!rs.wasNull() && bId > 0) {
                        post.setBookingId(bId);
                        post.setBookingCode(String.format(java.util.Locale.ROOT, "SP%06d", bId));
                        post.setPostPurpose(rs.getString("post_purpose"));
                        post.setFieldName(rs.getString("field_name"));
                        post.setSportType(rs.getString("sport_type"));
                        post.setFieldAddress(rs.getString("field_address"));
                        post.setCourtNumber(rs.getInt("court_number"));
                        post.setFieldQuantity(rs.getInt("field_quantity"));
                        Timestamp sTs = rs.getTimestamp("starts_at");
                        Timestamp eTs = rs.getTimestamp("ends_at");
                        if (sTs != null && eTs != null) {
                            post.setBookingDate(sTs.toLocalDateTime().toLocalDate().format(dFmt));
                            post.setBookingTime(sTs.toLocalDateTime().toLocalTime().format(tFmt)
                                    + " - " + eTs.toLocalDateTime().toLocalTime().format(tFmt));
                        }
                        java.math.BigDecimal price = rs.getBigDecimal("total_price");
                        post.setBookingPrice(price != null ? vnd.format(price) + " đ" : "0 đ");
                        post.setBookingStatus(rs.getString("booking_status"));
                        int ownerId = rs.getInt("booking_owner_id");
                        if (!rs.wasNull()) {
                            post.setBookingOwnerId(ownerId);
                        }
                        post.setBookingOwnerName(rs.getString("booking_owner_name"));
                    }

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
                "to_char(c.created_at, 'HH24:MI DD/MM/YYYY') AS created_at, u.fullname " +
                "FROM post_comments c JOIN Users u ON c.user_id = u.id " +
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
        return createPost(userId, content, null, null);
    }

    public boolean createPost(int userId, String content, Long bookingId, String postPurpose) {
        String sql = "INSERT INTO Posts (user_id, content, booking_id, post_purpose) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, content);
            if (bookingId != null && bookingId > 0) {
                ps.setLong(3, bookingId);
                ps.setString(4, postPurpose != null && !postPurpose.trim().isEmpty() ? postPurpose.trim() : "TIM_DOI");
            } else {
                ps.setNull(3, Types.BIGINT);
                ps.setNull(4, Types.VARCHAR);
            }
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
        String checkSql = "SELECT COUNT(*) FROM post_likes WHERE post_id = ? AND user_id = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, postId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    // Already liked -> unlike
                    String del = "DELETE FROM post_likes WHERE post_id = ? AND user_id = ?";
                    try (PreparedStatement del_ps = conn.prepareStatement(del)) {
                        del_ps.setInt(1, postId);
                        del_ps.setInt(2, userId);
                        del_ps.executeUpdate();
                    }
                    return false; // now unliked
                } else {
                    // Not liked -> like
                    String ins = "INSERT INTO post_likes (post_id, user_id) VALUES (?, ?)";
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
        String sql = "SELECT COUNT(*) FROM post_likes WHERE post_id = ?";
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
        String sql = "INSERT INTO post_comments (post_id, user_id, content) VALUES (?, ?, ?) RETURNING id";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            ps.setInt(2, userId);
            ps.setString(3, content);
            try (ResultSet rs = ps.executeQuery()) {
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
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
