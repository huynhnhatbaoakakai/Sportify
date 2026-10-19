<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="com.sportify.model.SportField" %>
<%@ page import="com.sportify.model.Booking" %>
<%@ page import="com.sportify.data.BookingDB" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>

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
    java.net.URL dashboardScript = application.getResource("/assets/js/owner-dashboard.js");
    String dashboardScriptVersion = dashboardScript == null ? "2"
            : String.valueOf(dashboardScript.openConnection().getLastModified());

    List<SportField> fields =
            (List<SportField>) request.getAttribute("fields");

    if (fields == null) {
        response.sendRedirect(contextPath + "/owner/fields");
        return;
    }

    long activeFieldCount = 0;
    long totalActiveProducts = 0;

    for (SportField field : fields) {
        if ("ACTIVE".equalsIgnoreCase(field.getStatus())) {
            activeFieldCount++;
            totalActiveProducts += field.getQuantity();
        }
    }

    NumberFormat priceFormat =
            NumberFormat.getNumberInstance(new Locale("vi", "VN"));

    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    if (bookings == null) bookings = Collections.emptyList();
    @SuppressWarnings("unchecked")
    List<BookingDB.BookedSlotSummary> bookedSlots =
            (List<BookingDB.BookedSlotSummary>) request.getAttribute("bookedSlots");
    if (bookedSlots == null) {
        bookedSlots = BookingDB.groupBookedSlots(bookings);
    }
    boolean bookingLoadFailed = Boolean.TRUE.equals(request.getAttribute("bookingLoadFailed"));
    boolean bookingPage = Boolean.TRUE.equals(request.getAttribute("bookingPage"));
    String bookingCsrfToken = (String) request.getAttribute("bookingCsrfToken");
    long todayBookingCount = request.getAttribute("todayBookingCount") == null ? 0
            : ((Number) request.getAttribute("todayBookingCount")).longValue();
    long pendingBookingCount = request.getAttribute("pendingBookingCount") == null ? 0
            : ((Number) request.getAttribute("pendingBookingCount")).longValue();
    BigDecimal todayBookingRevenue = (BigDecimal) request.getAttribute("todayBookingRevenue");
    if (todayBookingRevenue == null) todayBookingRevenue = BigDecimal.ZERO;
    DateTimeFormatter bookingDateFormat = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    DateTimeFormatter bookingTimeFormat = DateTimeFormatter.ofPattern("HH:mm");

    com.sportify.model.User sessionUser = (com.sportify.model.User) session.getAttribute("user");
    String ownerDisplayName = (sessionUser != null && sessionUser.getFullname() != null)
            ? sessionUser.getFullname() : "Minh Nguyễn";
    String ownerShortName = (sessionUser != null && sessionUser.getFullname() != null && !sessionUser.getFullname().trim().isEmpty())
            ? sessionUser.getFullname().trim().substring(sessionUser.getFullname().trim().lastIndexOf(' ') + 1) : "Minh";
    String ownerInitials = (ownerDisplayName.length() > 0)
            ? ownerDisplayName.substring(0, 1).toUpperCase() : "MN";
    String bookingNotice = null;
    boolean bookingNoticeError = false;
    String bookingSuccess = request.getParameter("success");
    if ("booking_confirmed".equals(bookingSuccess)) bookingNotice = "Đã xác nhận đơn đặt sân.";
    if ("booking_rejected".equals(bookingSuccess)) bookingNotice = "Đã từ chối đơn đặt sân.";
    if ("booking_completed".equals(bookingSuccess)) bookingNotice = "Đã xác nhận khách sử dụng sân và hoàn thành đơn.";
    String bookingError = request.getParameter("error");
    if (bookingError != null) {
        switch (bookingError) {
            case "booking_csrf": bookingNotice = "Biểu mẫu đã hết hiệu lực. Vui lòng tải lại trang rồi thử lại."; break;
            case "booking_invalid": bookingNotice = "Mã đơn hoặc thao tác không hợp lệ."; break;
            case "booking_not_found": bookingNotice = "Không tìm thấy đơn đặt sân thuộc sân của bạn."; break;
            case "booking_not_pending": bookingNotice = "Đơn đã được xử lý. Vui lòng kiểm tra trạng thái hiện tại."; break;
            case "booking_field_inactive": bookingNotice = "Sân đang tạm ngưng, không thể xác nhận đơn."; break;
            case "booking_invalid_time": bookingNotice = "Lịch đặt đã qua hoặc nằm ngoài giờ hoạt động của sân."; break;
            case "booking_conflict": bookingNotice = "Khung giờ này đã có lịch được xác nhận. Đơn vẫn ở trạng thái chờ."; break;
            case "booking_blocked": bookingNotice = "Khung giờ này đã được khóa. Vui lòng mở lại giờ trước khi xác nhận."; break;
            case "booking_save": bookingNotice = "Không thể cập nhật đơn. Vui lòng thử lại sau."; break;
            default: break;
        }
        if (bookingError.startsWith("booking_")) bookingNoticeError = true;
    }
    if (bookingLoadFailed) {
        bookingNotice = "Không thể tải lịch đặt sân. Vui lòng thử tải lại trang.";
        bookingNoticeError = true;
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Bảng điều khiển quản lý sân Sportify">

    <title><%= bookingPage ? "Quản lý đặt sân" : "Tổng quan chủ sân" %> - Sportify</title>


    <link rel="stylesheet"
          href="<%= contextPath %>/assets/css/owner-dashboard.css?v=<%= dashboardScriptVersion %>">
    <link rel="stylesheet"
          href="<%= contextPath %>/assets/css/order-chat.css?v=<%= dashboardScriptVersion %>">
    <script defer
            src="<%= contextPath %>/assets/js/owner-dashboard.js?v=<%= dashboardScriptVersion %>"></script>
    <script defer
            src="<%= contextPath %>/assets/js/order-chat.js"></script>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/icons.css">
</head>

<body>
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

            <a class="nav-item <%= bookingPage ? "" : "active" %>" href="<%= contextPath %>/owner/fields#overview" <%= bookingPage ? "" : "aria-current=\"page\"" %>>
                <span class="app-icon icon-grid" aria-hidden="true"></span>
                <span>Tổng quan</span>
            </a>
            <a class="nav-item <%= bookingPage ? "active" : "" %>" href="<%= contextPath %>/owner/bookings#booking-section" <%= bookingPage ? "aria-current=\"page\"" : "" %>>
                <span class="app-icon icon-calendar" aria-hidden="true"></span>
                <span>Lịch đặt sân</span>
                <span class="nav-count" data-pending-nav-count><%= bookingLoadFailed ? "—" : String.valueOf(pendingBookingCount) %></span>
            </a>
            <a class="nav-item" href="#fields">
                <span class="app-icon icon-racket" aria-hidden="true"></span>
                <span>Quản lý sân</span>
            </a>
            <a class="nav-item" href="<%= contextPath %>/owner/calendar"><span class="app-icon icon-calendar" aria-hidden="true"></span><span>Lịch trống và khóa giờ</span></a>
            <a class="nav-item" href="<%= contextPath %>/owner/customers">
                <span class="app-icon icon-users" aria-hidden="true"></span>
                <span>Khách hàng</span>
            </a>
            <a class="nav-item" href="<%= contextPath %>/owner/reviews">
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
                    <h1><%= bookingPage ? "Quản lý đặt sân" : "Dashboard chủ sân" %></h1>
                </div>
            </div>

            <div class="topbar-actions">
                <a class="btn-customer-portal" href="<%= contextPath %>/home" title="Trở về trang khách hàng" style="display:inline-flex; align-items:center; gap:6px; padding:7px 12px; background:var(--surface,#fff); border:1px solid var(--border,#e2e8f0); border-radius:8px; text-decoration:none; color:var(--text,#1e293b); font-size:13px; font-weight:600;">
                    <span class="app-icon icon-arrow-left" aria-hidden="true" style="font-size:18px;"></span>
                    <span>Trang khách hàng</span>
                </a>

                <%@ include file="/WEB-INF/views/common/notification-link.jspf" %>
                <div class="today" aria-label="Ngày hiện tại">
                    <span class="app-icon icon-calendar" aria-hidden="true"></span>
                    <span data-current-date>Hôm nay</span>
                </div>

                <button class="notification-button" type="button" aria-label="Thông báo mới">
                    <span class="app-icon icon-bell" aria-hidden="true"></span>
                    <span class="notification-dot" aria-hidden="true" <%= pendingBookingCount == 0 ? "hidden" : "" %>></span>
                </button>

                <div class="topbar-owner">
                    <div class="owner-avatar owner-avatar-small" aria-hidden="true"><%= escapeHtml(ownerInitials) %></div>
                    <div>
                        <strong><%= escapeHtml(ownerDisplayName) %></strong>
                        <span>Chủ sân</span>
                    </div>
                </div>
            </div>
        </header>

        <main class="dashboard-content" id="overview">
            <section class="welcome-panel" aria-labelledby="welcome-title">
                <div>
                    <span class="eyebrow">TỔNG QUAN HOẠT ĐỘNG</span>
                    <h2 id="welcome-title">Chào <%= escapeHtml(ownerShortName) %>!</h2>
                    <p>Bạn có <strong data-pending-message-count><%= bookingLoadFailed ? "—" : String.valueOf(pendingBookingCount) %> lịch đặt</strong> đang chờ xác nhận.</p>
                </div>
                <div class="demo-label">
                    <span class="app-icon icon-info" aria-hidden="true"></span>
                    Lịch đặt từ cơ sở dữ liệu
                </div>
            </section>

            <section class="stats-grid" id="court-summary" aria-label="Thống kê nhanh">
                <article class="stat-card stat-fields">
                    <div class="stat-card-top">
                        <span class="stat-icon">
                            <span class="app-icon icon-court" aria-hidden="true"></span>
                        </span>
                        <span class="stat-caption">Đang mở</span>
                    </div>
                    <p>Danh mục & Sản phẩm sân</p>
                    <strong data-active-field-count><%= activeFieldCount %></strong>
                    <small>Tổng <strong><%= totalActiveProducts %> sản phẩm (sân)</strong> cho thuê</small>
                </article>

                <article class="stat-card stat-bookings">
                    <div class="stat-card-top">
                        <span class="stat-icon">
                            <span class="app-icon icon-calendar-check" aria-hidden="true"></span>
                        </span>
                        <span class="stat-caption">Hôm nay</span>
                    </div>
                    <p>Lịch đặt hôm nay</p>
                    <strong data-today-booking-count><%= bookingLoadFailed ? "—" : String.valueOf(todayBookingCount) %></strong>
                    <small>Không tính đơn từ chối hoặc đã hủy</small>
                </article>

                <article class="stat-card stat-pending">
                    <div class="stat-card-top">
                        <span class="stat-icon">
                            <span class="app-icon icon-clock" aria-hidden="true"></span>
                        </span>
                        <span class="stat-caption warning">Cần xử lý</span>
                    </div>
                    <p>Yêu cầu chờ xác nhận</p>
                    <strong data-pending-count data-pending-value="<%= pendingBookingCount %>"><%= bookingLoadFailed ? "—" : String.valueOf(pendingBookingCount) %></strong>
                    <small>Yêu cầu đặt sân mới</small>
                </article>

                <article class="stat-card stat-revenue">
                    <div class="stat-card-top">
                        <span class="stat-icon">
                            <span class="app-icon icon-wallet" aria-hidden="true"></span>
                        </span>
                        <span class="stat-caption">Lịch hoàn thành</span>
                    </div>
                    <p>Doanh thu hôm nay</p>
                    <strong data-today-booking-revenue><%= bookingLoadFailed ? "—" : priceFormat.format(todayBookingRevenue) + "đ" %></strong>
                    <small>Tổng giá lịch đã hoàn thành hôm nay</small>
                </article>
            </section>

            <section class="booking-panel" id="booking-section" aria-labelledby="booking-title"
                     data-booking-load-failed="<%= bookingLoadFailed %>">
                <% if (bookingNotice != null) { %>
                <p class="booking-notice <%= bookingNoticeError ? "booking-notice-error" : "booking-notice-success" %>"
                   role="<%= bookingNoticeError ? "alert" : "status" %>"><%= escapeHtml(bookingNotice) %></p>
                <% } %>
                <div class="booking-header">
                    <div>
                        <span class="section-kicker">QUẢN LÝ ĐẶT SÂN</span>
                        <h2 id="booking-title">Lịch đặt gần đây</h2>
                        <p>Kiểm tra và xử lý các yêu cầu đặt sân của khách hàng (mỗi khung giờ nhận tối đa theo số lượng sản phẩm của sân).</p>
                    </div>

                    <a class="view-calendar-link" href="#booked-slots-section">
                        Xem các khung giờ đã đặt (<%= bookedSlots.size() %>)
                        <span class="app-icon icon-arrow" aria-hidden="true"></span>
                    </a>
                </div>

                <div class="booking-toolbar">
                    <div class="filter-group" role="group" aria-label="Lọc lịch đặt theo trạng thái">
                        <button class="filter-button active" type="button" data-status-filter="all"
                                aria-pressed="true">Tất cả</button>
                        <button class="filter-button" type="button" data-status-filter="pending"
                                aria-pressed="false">Chờ xác nhận</button>
                        <button class="filter-button" type="button" data-status-filter="confirmed"
                                aria-pressed="false">Đã xác nhận</button>
                        <button class="filter-button" type="button" data-status-filter="completed"
                                aria-pressed="false">Hoàn thành</button>
                        <button class="filter-button" type="button" data-status-filter="rejected"
                                aria-pressed="false">Đã từ chối</button>
                        <button class="filter-button" type="button" data-status-filter="cancelled"
                                aria-pressed="false">Đã hủy</button>
                    </div>

                    <label class="booking-search">
                        <span class="app-icon icon-search" aria-hidden="true"></span>
                        <span class="sr-only">Tìm lịch đặt</span>
                        <input type="search" data-booking-search
                               placeholder="Tìm mã đơn, khách hàng..."
                               autocomplete="off">
                    </label>
                </div>

                <div class="table-wrap">
                    <table class="booking-table">
                        <caption class="sr-only">Danh sách lịch đặt sân gần đây</caption>
                        <thead>
                        <tr>
                            <th scope="col">Mã đặt sân</th>
                            <th scope="col">Khách hàng</th>
                            <th scope="col">Danh mục sân & Sản phẩm</th>
                            <th scope="col">Thời gian & Lấp đầy khung giờ</th>
                            <th scope="col">Tổng tiền</th>
                            <th scope="col">Trạng thái</th>
                            <th scope="col" class="actions-heading">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody data-booking-body>
                        <% for (Booking booking : bookings) {
                            String bookingStatus = booking.getStatus().toLowerCase(Locale.ROOT);
                            String bookingSearch = booking.getBookingCode() + " " + booking.getCustomerName()
                                    + " " + booking.getField().getFieldName() + " "
                                    + (booking.getCustomerPhone() == null ? "" : booking.getCustomerPhone());
                            int totalQty = booking.getField().getQuantity();
                            int overlapCount = 0;
                            for (Booking other : bookings) {
                                if (other.getField().getFieldId().equals(booking.getField().getFieldId())
                                        && ("PENDING".equals(other.getStatus()) || "CONFIRMED".equals(other.getStatus()) || "COMPLETED".equals(other.getStatus()))
                                        && other.getStartsAt().isBefore(booking.getEndsAt())
                                        && other.getEndsAt().isAfter(booking.getStartsAt())) {
                                    overlapCount++;
                                }
                            }
                        %>
                        <tr data-booking-row data-booking-id="<%= booking.getBookingId() %>"
                            data-status="<%= escapeHtml(bookingStatus) %>" data-search="<%= escapeHtml(bookingSearch) %>">
                            <td data-label="Mã đặt sân"><strong class="booking-code">#<%= booking.getBookingCode() %></strong>
                                <% if (booking.isAutomaticallyConfirmed()) { %><span class="approval-badge">Hệ thống tự xác nhận</span><% } %>
                                <details class="booking-history"><summary>Lịch sử xử lý</summary><ul>
                                <%
                                    java.util.Map<Long, java.util.List<com.sportify.data.BookingActivityDB.HistoryEntry>> history =
                                        (java.util.Map<Long, java.util.List<com.sportify.data.BookingActivityDB.HistoryEntry>>) request.getAttribute("bookingHistory");
                                    java.util.List<com.sportify.data.BookingActivityDB.HistoryEntry> events = history == null ? java.util.List.of() : history.getOrDefault(booking.getBookingId(), java.util.List.of());
                                    if (events.isEmpty()) { %><li>Đơn cũ chưa có lịch sử chi tiết.</li><% }
                                    for (com.sportify.data.BookingActivityDB.HistoryEntry event : events) { %>
                                    <li><strong><%= event.actorLabel() %></strong> · <%= event.occurredAt().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM HH:mm")) %><br><%= escapeHtml(event.reason()) %></li>
                                <% } %></ul></details>
                            </td>
                            <td data-label="Khách hàng">
                                <div class="customer-cell">
                                    <span class="customer-avatar"><span class="app-icon icon-user" aria-hidden="true"></span></span>
                                    <div>
                                        <strong><%= escapeHtml(booking.getCustomerName()) %></strong>
                                        <span><%= booking.getCustomerPhone() == null || booking.getCustomerPhone().trim().isEmpty() ? "Chưa có SĐT" : escapeHtml(booking.getCustomerPhone()) %></span>
                                        <a href="<%= contextPath %>/owner/customers?q=<%= java.net.URLEncoder.encode(booking.getCustomerPhone() != null && !booking.getCustomerPhone().trim().isEmpty() ? booking.getCustomerPhone() : booking.getCustomerName(), "UTF-8") %>"
                                           class="customer-history-chip" title="Xem hồ sơ và toàn bộ lịch sử khách hàng này">
                                            <span class="material-symbols-rounded app-icon icon-clock" style="font-size:14px;" aria-hidden="true"></span>
                                            <span>Lịch sử khách</span>
                                        </a>
                                    </div>
                                </div>
                            </td>
                            <td data-label="Danh mục sân & Sản phẩm">
                                <strong><%= escapeHtml(booking.getField().getFieldName()) %></strong>
                                <span class="cell-note"><span class="app-icon icon-court" aria-hidden="true"></span> Sản phẩm: <strong>Sân #<%= booking.getCourtNumber() %></strong> / Tổng <%= totalQty %> sân</span>
                            </td>
                            <td data-label="Thời gian & Lấp đầy khung giờ">
                                <strong><time datetime="<%= booking.getStartsAt() %>"><%= booking.getStartsAt().format(bookingTimeFormat) %> - <%= booking.getEndsAt().format(bookingTimeFormat) %></time></strong>
                                <span class="cell-note"><%= booking.getStartsAt().format(bookingDateFormat) %> • Đã đặt <strong><%= overlapCount %>/<%= totalQty %></strong> sân</span>
                            </td>
                            <td data-label="Tổng tiền"><strong><%= priceFormat.format(booking.getTotalPrice()) %>đ</strong></td>
                            <td data-label="Trạng thái"><span class="status-badge status-<%= escapeHtml(bookingStatus) %>"><%= booking.getStatusLabel() %></span></td>
                            <td data-label="Thao tác" class="booking-actions">
                                <div style="display:flex;align-items:center;gap:6px;flex-wrap:wrap;">
                                    <button type="button" class="action-button chat-order-btn"
                                            onclick="openOrderChat(<%= booking.getBookingId() %>, <%= booking.getCustomerId() != null ? booking.getCustomerId() : 0 %>)"
                                            title="Nhắn tin phục vụ đơn đặt sân này">
                                        <span class="material-symbols-rounded app-icon icon-chat" style="font-size:15px;vertical-align:middle;" aria-hidden="true"></span> Chat
                                    </button>
                                    <% if ("PENDING".equals(booking.getStatus())) { %>
                                    <form class="booking-action-form" method="post"
                                          action="<%= contextPath %>/owner/bookings/status" data-booking-action-form>
                                        <input type="hidden" name="bookingId" value="<%= booking.getBookingId() %>">
                                        <input type="hidden" name="status" value="CONFIRMED">
                                        <input type="hidden" name="csrfToken" value="<%= escapeHtml(bookingCsrfToken) %>">
                                        <button class="action-button confirm-button" type="submit"
                                                aria-label="Xác nhận đơn <%= booking.getBookingCode() %>">Xác nhận</button>
                                    </form>
                                    <form class="booking-action-form" method="post"
                                          action="<%= contextPath %>/owner/bookings/status" data-booking-action-form>
                                        <input type="hidden" name="bookingId" value="<%= booking.getBookingId() %>">
                                        <input type="hidden" name="status" value="REJECTED">
                                        <input type="hidden" name="csrfToken" value="<%= escapeHtml(bookingCsrfToken) %>">
                                        <button class="action-button reject-button" type="submit"
                                                aria-label="Từ chối đơn <%= booking.getBookingCode() %>">Từ chối</button>
                                    </form>
                                    <% } else if ("CONFIRMED".equals(booking.getStatus())) {
                                        if (!booking.getEndsAt().isAfter(java.time.LocalDateTime.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh")))) { %>
                                    <form class="booking-action-form" method="post" action="<%= contextPath %>/owner/bookings/status" data-booking-action-form>
                                        <input type="hidden" name="bookingId" value="<%= booking.getBookingId() %>">
                                        <input type="hidden" name="status" value="COMPLETED">
                                        <input type="hidden" name="csrfToken" value="<%= escapeHtml(bookingCsrfToken) %>">
                                        <button class="action-button confirm-button" type="submit">Xác nhận đã sử dụng</button>
                                    </form>
                                    <% } else { %><span class="action-finished">Chờ kết thúc buổi chơi</span><% }
                                    } else { %><span class="action-finished">Đã xử lý</span><% } %>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

                <div class="empty-state" data-empty-state <%= bookings.isEmpty() ? "" : "hidden" %>>
                    <span class="app-icon icon-calendar-x" aria-hidden="true"></span>
                    <strong><%= bookingLoadFailed ? "Chưa thể tải lịch đặt" : "Chưa có lịch đặt phù hợp" %></strong>
                    <p><%= bookingLoadFailed ? "Vui lòng thử lại sau ít phút." : "Đơn đặt sân sẽ xuất hiện tại đây. Bạn cũng có thể thử đổi bộ lọc hoặc từ khóa." %></p>
                </div>

                <div class="table-footer">
                    <p data-booking-result aria-live="polite">Hiển thị <%= bookings.size() %> lịch đặt</p>
                    <span>Cập nhật vừa xong</span>
                </div>
            </section>

            <!-- BẢNG LIỆT KÊ ĐẦY ĐỦ CÁC KHUNG GIỜ ĐÃ CÓ NGƯỜI ĐẶT CHO CHỦ SỞ HỮU -->
            <section class="owner-slots-panel" id="booked-slots-section" aria-labelledby="booked-slots-title">
                <div class="booking-header">
                    <div>
                        <span class="section-kicker">THỐNG KÊ KHUNG GIỜ & CÔNG SUẤT SÂN</span>
                        <h2 id="booked-slots-title">Danh sách các khung giờ đã có người đặt</h2>
                        <p>Liệt kê đầy đủ những khung giờ đã có khách đặt thuê theo từng danh mục sân và số lượng sản phẩm còn trống.</p>
                    </div>
                    <div class="demo-label">
                        <span class="material-symbols-rounded app-icon icon-clock" aria-hidden="true"></span>
                        <%= bookedSlots.size() %> khung giờ có người đặt
                    </div>
                </div>

                <% if (bookedSlots.isEmpty()) { %>
                <div class="empty-state">
                    <span class="material-symbols-rounded app-icon icon-calendar-check" aria-hidden="true"></span>
                    <strong>Chưa có khung giờ nào được đặt</strong>
                    <p>Khi khách hàng đặt sân, các khung giờ đã đặt và số lượng sản phẩm lấp đầy sẽ hiển thị chi tiết tại đây.</p>
                </div>
                <% } else { %>
                <div class="table-wrap">
                    <table class="booking-table">
                        <thead>
                        <tr>
                            <th scope="col">Danh mục sân & Tổng sản phẩm</th>
                            <th scope="col">Ngày đặt</th>
                            <th scope="col">Khung giờ</th>
                            <th scope="col">Số đơn / Công suất</th>
                            <th scope="col">Tình trạng khung giờ</th>
                            <th scope="col">Danh sách đơn & sản phẩm đã đặt trong khung giờ</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (BookingDB.BookedSlotSummary slot : bookedSlots) {
                            boolean full = slot.isFull();
                        %>
                        <tr>
                            <td>
                                <strong><%= escapeHtml(slot.getField().getFieldName()) %></strong>
                                <span class="cell-note"><span class="app-icon icon-box" aria-hidden="true"></span> Quy mô: <strong><%= slot.getTotalQuantity() %> sản phẩm (sân)</strong></span>
                            </td>
                            <td><strong><%= slot.getStartsAt().format(bookingDateFormat) %></strong></td>
                            <td><strong><%= slot.getStartsAt().format(bookingTimeFormat) %> - <%= slot.getEndsAt().format(bookingTimeFormat) %></strong></td>
                            <td>
                                <strong style="color: <%= full ? "#d74343" : "#087838" %>; font-size: 14px;">
                                    <%= slot.getBookedCount() %> / <%= slot.getTotalQuantity() %> đơn
                                </strong>
                                <span class="cell-note">
                                    Đã duyệt: <%= slot.getConfirmedCount() %> • Chờ duyệt: <%= slot.getPendingCount() %>
                                </span>
                            </td>
                            <td>
                                <% if (full) { %>
                                <span class="status-badge status-rejected"><span class="app-icon icon-lock" aria-hidden="true"></span> Đã kín <%= slot.getTotalQuantity() %>/<%= slot.getTotalQuantity() %> sân (Không nhận thêm)</span>
                                <% } else { %>
                                <span class="status-badge status-confirmed"><span class="app-icon icon-check" aria-hidden="true"></span> Còn trống <%= slot.getRemainingCount() %>/<%= slot.getTotalQuantity() %> sân</span>
                                <% } %>
                            </td>
                            <td style="white-space: normal; min-width: 320px;">
                                <div class="owner-slot-order-list">
                                    <% for (Booking b : slot.getBookings()) { %>
                                    <span class="owner-slot-order-item">
                                        <strong class="booking-code">#<%= b.getBookingCode() %></strong>
                                        <span>• Sân #<%= b.getCourtNumber() %></span>
                                        <span>• <%= escapeHtml(b.getCustomerName()) %></span>
                                        <% if (b.getCustomerPhone() != null && !b.getCustomerPhone().isEmpty()) { %>
                                        <span style="color:var(--text-light);">(<%= escapeHtml(b.getCustomerPhone()) %>)</span>
                                        <% } %>
                                        <span class="status-badge status-<%= b.getStatus().toLowerCase(Locale.ROOT) %>" style="padding:2px 7px; font-size:10px;"><%= b.getStatusLabel() %></span>
                                    </span>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                <% } %>
            </section>

            <section class="fields-panel" id="fields" aria-labelledby="fields-title">
                <div class="fields-header">
                    <div>
                        <span class="section-kicker">DANH MỤC CƠ SỞ & SỐ LƯỢNG SẢN PHẨM</span>
                        <h2 id="fields-title">Quản lý sân & Sản phẩm cho thuê</h2>
                        <p>Cập nhật thông tin, số lượng sản phẩm (sân cho thuê) và xem các khung giờ đã đặt của từng danh mục sân.</p>
                    </div>
                    <button class="primary-button" type="button" data-field-add>
                        <span class="app-icon icon-plus" aria-hidden="true"></span>
                        Thêm danh mục sân
                    </button>
                </div>

                <div class="fields-grid" data-fields-grid>
                    <% if (fields.isEmpty()) { %>
                    <div class="empty-state">
                        <span class="app-icon icon-court" aria-hidden="true"></span>
                        <strong>Chưa có sân nào</strong>
                        <p>Hãy thêm dữ liệu vào bảng sports_fields.</p>
                    </div>
                    <% } else { %>
                        <% for (SportField field : fields) {
                            boolean isActive = "ACTIVE".equalsIgnoreCase(field.getStatus());
                            String sportType = field.getSportType();
                            String sportLabel;

                            switch (sportType == null ? "" : sportType.toUpperCase(Locale.ROOT)) {
                                case "GYM":
                                    sportLabel = "Gym";
                                    break;
                                case "BASKETBALL":
                                    sportLabel = "Bóng rổ";
                                    break;
                                case "SWIMMING":
                                    sportLabel = "Bơi";
                                    break;
                                case "PICKLEBALL":
                                    sportLabel = "Pickleball";
                                    break;
                                case "TABLE_TENNIS":
                                    sportLabel = "Bóng bàn";
                                    break;
                                default:
                                    sportLabel = sportType == null ? "" : sportType;
                            }

                            List<BookingDB.BookedSlotSummary> thisFieldSlots = new java.util.ArrayList<>();
                            for (BookingDB.BookedSlotSummary s : bookedSlots) {
                                if (s.getField() != null && s.getField().getFieldId().equals(field.getFieldId())) {
                                    thisFieldSlots.add(s);
                                }
                            }
                        %>
                        <article class="field-card"
                                 data-field-card
                                 data-field-id="<%= field.getFieldId() %>"
                                 data-sport-type="<%= field.getSportType() %>"
                                 data-open-time="<%= field.getOpenTime() %>"
                                 data-close-time="<%= field.getCloseTime() %>"
                                 data-status="<%= isActive ? "active" : "paused" %>"
                                 data-price="<%= field.getPricePerHour() %>"
                                 data-quantity="<%= field.getQuantity() %>">
                            <div class="field-card-top">
                                <span class="field-sport" data-field-sport><%= escapeHtml(sportLabel) %></span>
                                <span class="field-status <%= isActive ? "status-active" : "status-paused" %>"
                                      data-field-status><%= isActive ? "Đang hoạt động" : "Tạm ngưng" %></span>
                            </div>
                            <h3 data-field-name><%= escapeHtml(field.getFieldName()) %></h3>
                            <p class="field-address">
                                <span class="app-icon icon-map" aria-hidden="true"></span>
                                <span data-field-address><%= escapeHtml(field.getAddress()) %></span>
                            </p>

                            <div class="field-quantity-row">
                                <span><span class="app-icon icon-box" aria-hidden="true"></span> Số lượng sản phẩm hiện có: <strong><%= field.getQuantity() %> sân cho thuê</strong></span>
                                <span>Giới hạn: <strong><%= field.getQuantity() %> đơn / khung giờ</strong></span>
                            </div>

                            <div class="field-booked-mini">
                                <div class="field-booked-mini-title">
                                    <span><span class="app-icon icon-clock" aria-hidden="true"></span> Khung giờ đã có người đặt (<%= thisFieldSlots.size() %>)</span>
                                    <span style="font-size:11px; color:var(--text-light);">Giờ mở: <%= field.getOpenTime() %> - <%= field.getCloseTime() %></span>
                                </div>
                                <% if (thisFieldSlots.isEmpty()) { %>
                                <div style="color: var(--text-light); font-size: 11.5px;">Chưa có khung giờ nào được đặt — Còn đủ <%= field.getQuantity() %>/<%= field.getQuantity() %> sân ở mọi khung giờ.</div>
                                <% } else { %>
                                <div class="field-slot-chips">
                                    <% for (BookingDB.BookedSlotSummary s : thisFieldSlots) { %>
                                    <span class="field-slot-chip <%= s.isFull() ? "chip-full" : "chip-partial" %>">
                                        <%= s.getStartsAt().format(bookingDateFormat) %> •
                                        <%= s.getStartsAt().format(bookingTimeFormat) %>-<%= s.getEndsAt().format(bookingTimeFormat) %>
                                        (<%= s.getBookedCount() %>/<%= s.getTotalQuantity() %> sân<%= s.isFull() ? " - Kín" : "" %>)
                                    </span>
                                    <% } %>
                                </div>
                                <% } %>
                            </div>

                            <div class="field-price">
                                <strong data-field-price><%= priceFormat.format(field.getPricePerHour()) %>đ</strong>
                                <span>/ giờ / 1 sản phẩm</span>
                            </div>
                            <div class="approval-controls">
                                <a class="automation-button secondary" href="<%= contextPath %>/owner/calendar?fieldId=<%= field.getFieldId() %>">Xem lịch / khóa giờ</a>
                                <% if (field.supportsAutoApproval()) { %>
                                <form method="post" action="<%= contextPath %>/owner/fields/approval">
                                    <input type="hidden" name="csrfToken" value="<%= escapeHtml((String) request.getAttribute("csrfToken")) %>"><input type="hidden" name="fieldId" value="<%= field.getFieldId() %>"><input type="hidden" name="enabled" value="<%= !field.isAutoApprove() %>">
                                    <button class="automation-button secondary" type="submit"><%= field.isAutoApprove() ? "Tắt tự xác nhận" : "Bật tự xác nhận" %></button>
                                </form>
                                <% } %>
                            </div>
                            <span class="approval-badge"><%= field.isAutoApprove() ? "Tự động xác nhận đơn mới" : "Duyệt thủ công" %></span>
                            <div class="field-actions">
                                <button class="field-edit-button"
                                        type="button"
                                        data-field-edit>
                                    Chỉnh sửa & Số lượng
                                </button>

                                <form class="field-toggle-form"
                                      method="post"
                                      action="<%= contextPath %>/owner/fields/toggle"
                                      data-field-toggle-form>
<input type="hidden" name="csrfToken" value="<%= com.sportify.util.Html.escape(request.getAttribute("csrfToken")) %>">
                                    <input type="hidden"
                                           name="fieldId"
                                           value="<%= field.getFieldId() %>">

                                    <button class="field-toggle-button"
                                            type="submit"
                                            data-field-toggle>
                                        <%= isActive ? "Tạm ngưng" : "Kích hoạt" %>
                                    </button>
                                </form>
                            </div>
                        </article>
                        <% } %>
                    <% } %>
                </div>
            </section>

            <template id="field-card-template">
                <article class="field-card" data-field-card data-status="active" data-price="0" data-quantity="4">
                    <div class="field-card-top">
                        <span class="field-sport" data-field-sport></span>
                        <span class="field-status status-active" data-field-status>Đang hoạt động</span>
                    </div>
                    <h3 data-field-name></h3>
                    <p class="field-address">
                        <span class="app-icon icon-map" aria-hidden="true"></span>
                        <span data-field-address></span>
                    </p>
                    <div class="field-price"><strong data-field-price></strong><span>/ giờ</span></div>
                    <div class="field-actions">
                        <button class="field-edit-button" type="button" data-field-edit>Chỉnh sửa</button>
                        <button class="field-toggle-button" type="button" data-field-toggle>Tạm ngưng</button>
                    </div>
                </article>
            </template>
        </main>
    </div>
</div>

<div class="modal-backdrop" data-field-modal hidden>
    <div class="field-modal" role="dialog" aria-modal="true" aria-labelledby="field-modal-title">
        <div class="modal-header">
            <div>
                <span class="section-kicker">QUẢN LÝ SÂN & SẢN PHẨM</span>
                <h2 id="field-modal-title" data-field-modal-title>Thêm sân</h2>
            </div>
            <button class="modal-close" type="button" data-field-modal-close aria-label="Đóng biểu mẫu">
                <span class="app-icon icon-close" aria-hidden="true"></span>
            </button>
        </div>
        <form class="field-form"
              data-field-form
              method="post"
              action="<%= contextPath %>/owner/fields/create"
              data-create-action="<%= contextPath %>/owner/fields/create"
              data-update-action="<%= contextPath %>/owner/fields/update">
<input type="hidden" name="csrfToken" value="<%= com.sportify.util.Html.escape(request.getAttribute("csrfToken")) %>">

    <input type="hidden"
           name="fieldId"
           data-field-id-input>

    <label for="field-name">
        Tên danh mục sân / cơ sở
        <input id="field-name"
               name="fieldName"
               type="text"
               maxlength="150"
               required>
    </label>

    <div class="field-form-row">
        <label for="field-sport">
            Môn thể thao
            <select id="field-sport"
                    name="sportType"
                    required>
                <option value="">Chọn môn thể thao</option>
                <option value="GYM">Gym</option>
                <option value="BASKETBALL">Bóng rổ</option>
                <option value="SWIMMING">Bơi</option>
                <option value="PICKLEBALL">Pickleball</option>
                <option value="TABLE_TENNIS">Bóng bàn</option>
            </select>
        </label>

        <label for="field-quantity">
            Số lượng sân / sản phẩm cho thuê
            <input id="field-quantity"
                   name="quantity"
                   type="number"
                   min="1"
                   max="100"
                   step="1"
                   value="4"
                   required>
        </label>
    </div>

    <label for="field-address">
        Địa chỉ
        <input id="field-address"
               name="address"
               type="text"
               maxlength="255"
               required>
    </label>

    <div class="field-form-row">
        <label for="field-price">
            Giá theo giờ / 1 sản phẩm (đ)
            <input id="field-price"
                   name="pricePerHour"
                   type="number"
                   min="1000"
                   step="1000"
                   required>
        </label>

        <label for="field-status">
            Trạng thái
            <select id="field-status"
                    name="status"
                    required>
                <option value="ACTIVE">Đang hoạt động</option>
                <option value="INACTIVE">Tạm ngưng</option>
            </select>
        </label>
    </div>

    <div class="field-form-row">
        <label for="field-open-time">
            Giờ mở cửa
            <input id="field-open-time"
                   name="openTime"
                   type="time"
                   value="06:00"
                   required>
        </label>

        <label for="field-close-time">
            Giờ đóng cửa
            <input id="field-close-time"
                   name="closeTime"
                   type="time"
                   value="22:00"
                   required>
        </label>
    </div>

    <div class="modal-actions">
        <button class="secondary-button"
                type="button"
                data-field-modal-close>
            Hủy
        </button>

        <button class="primary-button"
                type="submit"
                data-field-submit>
            Thêm sân
        </button>
    </div>
</form>
    </div>
</div>

<div class="toast" data-toast role="status" aria-live="polite" aria-atomic="true"></div>

<%@ include file="/WEB-INF/views/common/order-chat-modal.jspf" %>
<script>
    const CTX = '<%= contextPath %>';
</script>

</body>
</html>
