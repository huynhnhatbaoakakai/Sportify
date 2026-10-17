<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.sportify.model.CustomerOverview" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%!
    private static String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    String contextPath = request.getContextPath();
    List<CustomerOverview> customers = (List<CustomerOverview>) request.getAttribute("customers");
    if (customers == null) {
        response.sendRedirect(contextPath + "/owner/customers");
        return;
    }
    String search = (String) request.getAttribute("search");
    String errorMessage = (String) request.getAttribute("errorMessage");
    boolean loadFailed = Boolean.TRUE.equals(request.getAttribute("loadFailed"));
    long customerNameCount = ((Number) request.getAttribute("customerNameCount")).longValue();
    long reviewCount = ((Number) request.getAttribute("reviewCount")).longValue();
    long reviewedFieldCount = ((Number) request.getAttribute("reviewedFieldCount")).longValue();
    DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    Locale vietnameseLocale = new Locale("vi", "VN");

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
    <meta name="description" content="Khách hàng đã đánh giá sân của bạn trên Sportify">
    <title>Khách hàng - Sportify</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/owner-dashboard.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/owner-customers.css">
    <script defer src="<%= contextPath %>/assets/js/owner-customers.js"></script>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/icons.css">
</head>
<body class="owner-customers-page">
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
            <div class="owner-avatar" aria-hidden="true"><%= ownerInitials %></div>
            <div class="owner-summary-text"><strong><%= ownerDisplayName %></strong><span>Chủ sân Sportify</span></div>
        </div>
        <nav class="sidebar-nav">
            <p class="nav-label">Quản lý</p>
            <a class="nav-item" href="<%= contextPath %>/owner/fields#overview">
                <span class="app-icon icon-grid" aria-hidden="true"></span><span>Tổng quan</span>
            </a>
            <a class="nav-item" href="<%= contextPath %>/owner/bookings#booking-section">
                <span class="app-icon icon-calendar" aria-hidden="true"></span><span>Lịch đặt sân</span>
            </a>
            <a class="nav-item" href="<%= contextPath %>/owner/fields#fields">
                <span class="app-icon icon-racket" aria-hidden="true"></span><span>Quản lý sân</span>
            </a>
            <a class="nav-item active" href="<%= contextPath %>/owner/customers" aria-current="page">
                <span class="app-icon icon-users" aria-hidden="true"></span><span>Khách hàng</span>
            </a>
            <a class="nav-item" href="<%= contextPath %>/owner/reviews">
                <span class="app-icon icon-star" aria-hidden="true"></span><span>Đánh giá</span>
            </a>
            <p class="nav-label nav-label-spaced">Tài khoản</p>
            <a class="nav-item" href="<%= contextPath %>/home">
                <span class="app-icon icon-home" aria-hidden="true"></span><span>Về trang chủ</span>
            </a>
            <a class="nav-item" href="<%= contextPath %>/home">
                <span class="app-icon icon-user" aria-hidden="true"></span><span>Về trang khách hàng</span>
            </a>
            <a class="nav-item" href="#">
                <span class="app-icon icon-help" aria-hidden="true"></span><span>Trợ giúp</span>
            </a>
        </nav>
        <a class="logout-link" href="<%= contextPath %>/owner/access/logout">
            <span class="app-icon icon-logout" aria-hidden="true"></span><span>Đăng xuất</span>
        </a>
    </aside>
    <div class="dashboard-main">
        <header class="topbar">
            <div class="topbar-start">
                <button class="menu-toggle" type="button" data-sidebar-toggle aria-label="Mở menu"
                        aria-controls="owner-sidebar" aria-expanded="false">
                    <span class="app-icon icon-menu" aria-hidden="true"></span>
                </button>
                <div><p class="topbar-label">Khu vực chủ sân</p><h1>Khách hàng</h1></div>
            </div>
            <div style="display:flex; align-items:center; gap:12px;">
                <a class="btn-customer-portal" href="<%= contextPath %>/home" title="Trở về trang khách hàng" style="display:inline-flex; align-items:center; gap:6px; padding:7px 12px; background:var(--surface,#fff); border:1px solid var(--border,#e2e8f0); border-radius:8px; text-decoration:none; color:var(--text,#1e293b); font-size:13px; font-weight:600;">
                    <span class="app-icon icon-arrow-left" aria-hidden="true" style="font-size:18px;"></span>
                    <span>Trang khách hàng</span>
                </a>
                <div class="today" aria-label="Ngày hiện tại">
                    <span class="app-icon icon-calendar" aria-hidden="true"></span>
                    <span data-current-date>Hôm nay</span>
                </div>
            </div>
        </header>
        <main class="dashboard-content">
            <section class="welcome-panel" aria-labelledby="customers-heading">
                <div>
                    <span class="eyebrow">KHÁCH HÀNG CỦA BẠN</span>
                    <h2 id="customers-heading">Khách hàng đã đánh giá</h2>
                    <p>Tìm khách hàng và theo dõi những đánh giá họ đã gửi trên các sân của bạn.</p>
                </div>
                <a class="secondary-button" href="<%= contextPath %>/owner/reviews">Xem đánh giá</a>
            </section>
            <% if (errorMessage != null) { %>
            <p class="customer-notice" role="alert"><%= escapeHtml(errorMessage) %></p>
            <% } %>
            <section class="stats-grid customer-stats" aria-label="Thống kê khách hàng đã đánh giá">
                <article class="stat-card">
                    <div class="stat-card-top"><span class="stat-icon"><span class="app-icon icon-users" aria-hidden="true"></span></span><span class="stat-caption">Theo tên khách</span></div>
                    <p>Tên khách đã đánh giá</p>
                    <strong><%= loadFailed ? "—" : String.valueOf(customerNameCount) %></strong>
                    <small>Tổng hợp từ đánh giá của khách</small>
                </article>
                <article class="stat-card">
                    <div class="stat-card-top"><span class="stat-icon"><span class="app-icon icon-chat" aria-hidden="true"></span></span><span class="stat-caption">Tất cả đánh giá</span></div>
                    <p>Tổng số đánh giá</p>
                    <strong><%= loadFailed ? "—" : String.valueOf(reviewCount) %></strong>
                    <small>Trên các sân của bạn</small>
                </article>
                <article class="stat-card">
                    <div class="stat-card-top"><span class="stat-icon"><span class="app-icon icon-racket" aria-hidden="true"></span></span><span class="stat-caption">Đã có phản hồi khách</span></div>
                    <p>Sân được đánh giá</p>
                    <strong><%= loadFailed ? "—" : String.valueOf(reviewedFieldCount) %></strong>
                    <small>Có ít nhất một đánh giá</small>
                </article>
            </section>
            <section class="customer-panel" aria-labelledby="customer-list-title">
                <div class="customer-toolbar">
                    <div>
                        <span class="section-kicker">TÌM HIỂU KHÁCH HÀNG</span>
                        <h2 id="customer-list-title">Danh sách khách hàng</h2>
                        <% if (!loadFailed) { %><p>Hiển thị <%= customers.size() %> tên khách · Đánh giá gần nhất trước</p><% } %>
                    </div>
                    <form class="customer-search" method="get" action="<%= contextPath %>/owner/customers">
                        <label for="customer-search">Tìm theo tên khách hàng</label>
                        <div class="customer-search-controls">
                            <input id="customer-search" name="q" type="search" maxlength="100"
                                   value="<%= escapeHtml(search) %>" placeholder="Nhập tên khách hàng...">
                            <button class="primary-button" type="submit">Tìm</button>
                        </div>
                        <% if (search != null && !search.isEmpty()) { %><a class="customer-clear-search" href="<%= contextPath %>/owner/customers">Xóa tìm kiếm</a><% } %>
                    </form>
                </div>
                <% if (customers.isEmpty()) { %>
                <div class="empty-state customer-empty">
                    <span class="app-icon icon-<%= loadFailed ? "cloud-off" : "users-search" %>" aria-hidden="true"></span>
                    <strong><%= loadFailed ? "Chưa thể tải danh sách" : search != null && !search.isEmpty() ? "Không tìm thấy khách hàng" : "Chưa có khách hàng đánh giá" %></strong>
                    <p><%= loadFailed ? "Vui lòng thử tải lại sau ít phút." : search != null && !search.isEmpty() ? "Hãy thử tìm theo tên khác hoặc xóa từ khóa." : "Khách hàng sẽ xuất hiện khi họ gửi đánh giá cho sân của bạn." %></p>
                    <% if (loadFailed) { %><a class="secondary-button" href="<%= contextPath %>/owner/customers">Thử lại</a><% } %>
                </div>
                <% } else { %>
                <div class="customer-table-wrap">
                    <table class="customer-table">
                        <caption class="sr-only">Khách hàng đã gửi đánh giá cho các sân của bạn</caption>
                        <thead><tr>
                            <th scope="col">Khách hàng</th>
                            <th scope="col">Số đánh giá</th>
                            <th scope="col">Số sân đã đánh giá</th>
                            <th scope="col">Điểm trung bình</th>
                            <th scope="col">Đánh giá gần nhất</th>
                        </tr></thead>
                        <tbody>
                        <% for (CustomerOverview customer : customers) { %>
                        <tr data-customer-row>
                            <td class="customer-name" data-label="Khách hàng">
                                <div class="customer-cell">
                                    <span class="customer-avatar"><span class="app-icon icon-user" aria-hidden="true"></span></span>
                                    <strong><%= escapeHtml(customer.getCustomerName()) %></strong>
                                </div>
                            </td>
                            <td data-label="Số đánh giá"><strong><%= customer.getReviewCount() %></strong></td>
                            <td data-label="Số sân đã đánh giá"><%= customer.getFieldCount() %> sân</td>
                            <td data-label="Điểm trung bình"><span class="customer-average"><span aria-hidden="true"><span class="app-icon icon-star" aria-hidden="true"></span></span> <%= String.format(vietnameseLocale, "%.1f / 5", customer.getAverageRating()) %></span></td>
                            <td data-label="Đánh giá gần nhất"><time datetime="<%= customer.getLastReviewAt() %>"><%= customer.getLastReviewAt().format(dateFormat) %></time></td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                <% } %>
            </section>
        </main>
    </div>
</div>
</body>
</html>
