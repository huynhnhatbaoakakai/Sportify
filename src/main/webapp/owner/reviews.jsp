<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="com.sportify.model.Review" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%!
    private static String escapeHtml(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
    String contextPath = request.getContextPath();
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    if (reviews == null) {
        response.sendRedirect(contextPath + "/owner/reviews");
        return;
    }
    Integer selectedRating = (Integer) request.getAttribute("selectedRating");
    long totalReviews = ((Number) request.getAttribute("totalReviews")).longValue();
    double averageRating = ((Number) request.getAttribute("averageRating")).doubleValue();
    boolean loadFailed = Boolean.TRUE.equals(request.getAttribute("loadFailed"));
    DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String errorCode = request.getParameter("error");
    if (errorMessage == null && errorCode != null) {
        switch (errorCode) {
            case "empty":
                errorMessage = "Nội dung phản hồi không được để trống.";
                break;
            case "length":
                errorMessage = "Phản hồi chỉ được tối đa 2.000 ký tự.";
                break;
            case "invalid":
                errorMessage = "Mã đánh giá không hợp lệ.";
                break;
            case "notfound":
                errorMessage = "Không tìm thấy đánh giá thuộc sân của bạn.";
                break;
            case "save":
                errorMessage = "Không thể lưu phản hồi. Vui lòng thử lại sau.";
                break;
            default:
                break;
        }
    }

    com.sportify.model.User sessionUser = (com.sportify.model.User) session.getAttribute("user");
    String ownerDisplayName = (sessionUser != null && sessionUser.getFullname() != null)
            ? sessionUser.getFullname() : "Minh Nguyễn";
    String ownerInitials = (ownerDisplayName.length() > 0)
            ? ownerDisplayName.substring(0, 1).toUpperCase() : "MN";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Quản lý đánh giá các sân của bạn trên Sportify">
    <title>Quản lý đánh giá - Sportify</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/owner-dashboard.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/owner-reviews.css">
    <script defer src="<%= contextPath %>/assets/js/owner-reviews.js"></script>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/icons.css">
</head>
<body class="owner-reviews-page">
<div class="dashboard-layout">
    <div class="sidebar-overlay" data-sidebar-overlay aria-hidden="true"></div>
    <aside class="sidebar" id="owner-sidebar" aria-label="Điều hướng dành cho chủ sân">
        <div class="sidebar-header">
            <a class="sidebar-logo" href="<%= contextPath %>/home" aria-label="Sportify - Trang chủ">
                <img src="<%= contextPath %>/assets/images/logo.jpeg" alt="Sportify">
            </a>
            <button class="sidebar-close" type="button" data-sidebar-close aria-label="Đóng menu">
                <span class="app-icon icon-close" aria-hidden="true"></span>
            </button>
        </div>
        <div class="owner-summary">
            <div class="owner-avatar" aria-hidden="true"><%= escapeHtml(ownerInitials) %></div>
            <div class="owner-summary-text">
                <strong><%= escapeHtml(ownerDisplayName) %></strong>
                <span>Chủ sân Sportify</span>
            </div>
        </div>
        <nav class="sidebar-nav">
            <p class="nav-label">Quản lý</p>
            <a class="nav-item" href="<%= contextPath %>/owner/fields#overview">
                <span class="app-icon icon-grid" aria-hidden="true"></span>
                <span>Tổng quan</span>
            </a>
            <a class="nav-item" href="<%= contextPath %>/owner/bookings#booking-section">
                <span class="app-icon icon-calendar" aria-hidden="true"></span>
                <span>Lịch đặt sân</span>
            </a>
            <a class="nav-item" href="<%= contextPath %>/owner/fields#fields">
                <span class="app-icon icon-racket" aria-hidden="true"></span>
                <span>Quản lý sân</span>
            </a>
            <a class="nav-item" href="<%= contextPath %>/owner/calendar"><span class="app-icon icon-calendar" aria-hidden="true"></span><span>Lịch trống và khóa giờ</span></a>
            <a class="nav-item" href="<%= contextPath %>/owner/customers">
                <span class="app-icon icon-users" aria-hidden="true"></span>
                <span>Khách hàng</span>
            </a>
            <a class="nav-item active" href="<%= contextPath %>/owner/reviews" aria-current="page">
                <span class="app-icon icon-star" aria-hidden="true"></span>
                <span>Đánh giá</span>
            </a>
            <p class="nav-label nav-label-spaced">Tài khoản</p>
            <a class="nav-item" href="<%= contextPath %>/home">
                <span class="app-icon icon-home" aria-hidden="true"></span>
                <span>Về trang chủ</span>
            </a>
            <a class="nav-item" href="<%= contextPath %>/home">
                <span class="app-icon icon-user" aria-hidden="true"></span>
                <span>Về trang khách hàng</span>
            </a>
            <a class="nav-item" href="#">
                <span class="app-icon icon-help" aria-hidden="true"></span>
                <span>Trợ giúp</span>
            </a>
        </nav>
        <a class="logout-link" href="<%= contextPath %>/owner/access/logout">
            <span class="app-icon icon-logout" aria-hidden="true"></span>
            <span>Đăng xuất</span>
        </a>
    </aside>

    <div class="dashboard-main">
        <header class="topbar">
            <div class="topbar-start">
                <button class="menu-toggle" type="button" data-sidebar-toggle
                        aria-label="Mở menu" aria-controls="owner-sidebar" aria-expanded="false">
                    <span class="app-icon icon-menu" aria-hidden="true"></span>
                </button>
                <div>
                    <p class="topbar-label">Khu vực chủ sân</p>
                    <h1>Quản lý đánh giá</h1>
                </div>
            </div>
            <div style="display:flex; align-items:center; gap:12px;">
                <a class="btn-customer-portal" href="<%= contextPath %>/home" title="Trở về trang khách hàng" style="display:inline-flex; align-items:center; gap:6px; padding:7px 12px; background:var(--surface,#fff); border:1px solid var(--border,#e2e8f0); border-radius:8px; text-decoration:none; color:var(--text,#1e293b); font-size:13px; font-weight:600;">
                    <span class="app-icon icon-arrow-left" aria-hidden="true" style="font-size:18px;"></span>
                    <span>Trang khách hàng</span>
                </a>
                <%@ include file="/WEB-INF/views/common/notification-link.jspf" %>
                <div class="today" aria-label="Ngày hiện tại">
                    <span class="app-icon icon-calendar" aria-hidden="true"></span>
                    <span data-current-date>Hôm nay</span>
                </div>
            </div>
        </header>

        <main class="dashboard-content">
            <section class="welcome-panel" aria-labelledby="reviews-heading">
                <div>
                    <span class="eyebrow">LẮNG NGHE KHÁCH HÀNG</span>
                    <h2 id="reviews-heading">Đánh giá từ khách hàng</h2>
                    <p>Theo dõi trải nghiệm tại các sân của bạn và phản hồi khách hàng.</p>
                </div>
            </section>

            <% if (errorMessage != null) { %>
            <p class="review-notice review-notice-error" role="alert"><%= escapeHtml(errorMessage) %></p>
            <% } else if ("replied".equals(request.getParameter("success"))) { %>
            <p class="review-notice review-notice-success" role="status">Đã lưu phản hồi của bạn.</p>
            <% } %>

            <section class="stats-grid review-stats" aria-label="Thống kê đánh giá">
                <article class="stat-card">
                    <div class="stat-card-top">
                        <span class="stat-icon"><span class="app-icon icon-chat" aria-hidden="true"></span></span>
                        <span class="stat-caption">Tất cả đánh giá</span>
                    </div>
                    <p>Tổng số đánh giá</p>
                    <strong><%= loadFailed ? "—" : String.valueOf(totalReviews) %></strong>
                    <small>Trên tất cả sân của bạn</small>
                </article>
                <article class="stat-card">
                    <div class="stat-card-top">
                        <span class="stat-icon"><span class="app-icon icon-star" aria-hidden="true"></span></span>
                        <span class="stat-caption">Thang điểm 5</span>
                    </div>
                    <p>Điểm đánh giá trung bình</p>
                    <strong><%= loadFailed || totalReviews == 0 ? "—" : String.format(new Locale("vi", "VN"), "%.1f / 5", averageRating) %></strong>
                    <small><%= totalReviews == 0 && !loadFailed ? "Chưa có đánh giá" : "Tính trên tất cả đánh giá của bạn" %></small>
                </article>
            </section>

            <section class="review-panel" aria-labelledby="review-list-title">
                <div class="review-toolbar">
                    <div>
                        <span class="section-kicker">PHẢN HỒI KHÁCH HÀNG</span>
                        <h2 id="review-list-title">Danh sách đánh giá</h2>
                        <% if (!loadFailed) { %>
                        <p>Hiển thị <%= reviews.size() %> đánh giá · Mới nhất trước</p>
                        <% } %>
                    </div>
                    <form class="review-filter" method="get" action="<%= contextPath %>/owner/reviews">
                        <label for="review-rating">Lọc theo số sao</label>
                        <div class="review-filter-controls">
                            <select id="review-rating" name="rating">
                                <option value="">Tất cả số sao</option>
                                <% for (int stars = 5; stars >= 1; stars--) { %>
                                <option value="<%= stars %>" <%= selectedRating != null && selectedRating == stars ? "selected" : "" %>><%= stars %> sao</option>
                                <% } %>
                            </select>
                            <button class="primary-button" type="submit">Lọc</button>
                        </div>
                    </form>
                </div>

                <% if (reviews.isEmpty()) { %>
                <div class="empty-state review-empty">
                    <span class="app-icon icon-<%= loadFailed ? "cloud-off" : "edit" %>" aria-hidden="true"></span>
                    <strong><%= loadFailed ? "Chưa thể tải danh sách" : "Chưa có đánh giá" %></strong>
                    <p><%= loadFailed ? "Vui lòng thử tải lại sau ít phút." : selectedRating == null ? "Đánh giá của khách hàng sẽ xuất hiện tại đây." : "Không có đánh giá phù hợp với số sao đã chọn." %></p>
                    <% if (loadFailed || selectedRating != null) { %>
                    <a class="secondary-button" href="<%= contextPath %>/owner/reviews"><%= loadFailed ? "Thử lại" : "Xem tất cả đánh giá" %></a>
                    <% } %>
                </div>
                <% } else { %>
                <div class="review-list">
                    <% for (Review review : reviews) {
                        boolean hasReply = review.getOwnerReply() != null && !review.getOwnerReply().trim().isEmpty();
                    %>
                    <article class="review-card" id="review-<%= review.getReviewId() %>">
                        <div class="review-card-header">
                            <div>
                                <h3><%= escapeHtml(review.getField().getFieldName()) %></h3>
                                <p class="review-customer"><span class="app-icon icon-user" aria-hidden="true"></span><%= escapeHtml(review.getCustomerName()) %></p>
                            </div>
                            <span class="review-reply-status <%= hasReply ? "review-status-replied" : "review-status-pending" %>"><%= hasReply ? "Đã phản hồi" : "Chưa phản hồi" %></span>
                        </div>
                        <div class="review-meta">
                            <span class="review-stars" aria-label="<%= review.getRating() %> trên 5 sao">
                                <span aria-hidden="true"><% for (int star = 1; star <= 5; star++) { %><span class="<%= star <= review.getRating() ? "review-star-filled" : "review-star-empty" %>"><span class="app-icon icon-star" aria-hidden="true"></span></span><% } %></span>
                                <strong><%= review.getRating() %>/5</strong>
                            </span>
                            <time datetime="<%= review.getCreatedAt() %>"><%= review.getCreatedAt().format(dateFormat) %></time>
                        </div>
                        <p class="review-comment"><%= escapeHtml(review.getComment()) %></p>

                        <% if (hasReply) { %>
                        <div class="review-owner-reply">
                            <strong>Phản hồi của chủ sân</strong>
                            <p class="review-reply-text"><%= escapeHtml(review.getOwnerReply()) %></p>
                            <% if (review.getRepliedAt() != null) { %>
                            <time datetime="<%= review.getRepliedAt() %>">Cập nhật: <%= review.getRepliedAt().format(dateFormat) %></time>
                            <% } %>
                        </div>
                        <% } %>

                        <details class="review-reply-editor" <%= hasReply ? "" : "open" %>>
                            <summary><%= hasReply ? "Chỉnh sửa phản hồi" : "Phản hồi đánh giá" %></summary>
                            <form class="review-reply-form" method="post" action="<%= contextPath %>/owner/reviews/reply">
<input type="hidden" name="csrfToken" value="<%= com.sportify.util.Html.escape(request.getAttribute("csrfToken")) %>">
                                <input type="hidden" name="reviewId" value="<%= review.getReviewId() %>">
                                <input type="hidden" name="rating" value="<%= selectedRating == null ? "" : selectedRating %>">
                                <label for="owner-reply-<%= review.getReviewId() %>">Nội dung phản hồi</label>
                                <textarea id="owner-reply-<%= review.getReviewId() %>" name="ownerReply" rows="3" maxlength="2000" required
                                          placeholder="Cảm ơn khách hàng hoặc trao đổi về trải nghiệm tại sân..."><%= escapeHtml(review.getOwnerReply()) %></textarea>
                                <div class="review-reply-actions">
                                    <small>Tối đa 2.000 ký tự</small>
                                    <button class="primary-button" type="submit"><%= hasReply ? "Lưu thay đổi" : "Gửi phản hồi" %></button>
                                </div>
                            </form>
                        </details>
                    </article>
                    <% } %>
                </div>
                <% } %>
            </section>
        </main>
    </div>
</div>
</body>
</html>
