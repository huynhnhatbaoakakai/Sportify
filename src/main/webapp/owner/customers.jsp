<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.sportify.model.CustomerBookingProfile" %>
<%@ page import="com.sportify.model.Booking" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%!
    private static String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }

    private static String getAvatarColor(String name) {
        if (name == null || name.trim().isEmpty()) return "linear-gradient(135deg, #10b981, #059669)";
        int hash = Math.abs(name.trim().hashCode());
        String[] gradients = {
            "linear-gradient(135deg, #10b981, #059669)", // Emerald
            "linear-gradient(135deg, #3b82f6, #1d4ed8)", // Blue
            "linear-gradient(135deg, #8b5cf6, #6d28d9)", // Purple
            "linear-gradient(135deg, #f59e0b, #d97706)", // Amber
            "linear-gradient(135deg, #06b6d4, #0891b2)", // Cyan
            "linear-gradient(135deg, #ec4899, #be185d)"  // Pink
        };
        return gradients[hash % gradients.length];
    }
%>
<%
    String contextPath = request.getContextPath();
    List<CustomerBookingProfile> customers = (List<CustomerBookingProfile>) request.getAttribute("customers");
    if (customers == null) {
        response.sendRedirect(contextPath + "/owner/customers");
        return;
    }
    String search = (String) request.getAttribute("search");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String actionNotice = (String) request.getAttribute("actionNotice");
    boolean loadFailed = Boolean.TRUE.equals(request.getAttribute("loadFailed"));

    long totalCustomerCount = request.getAttribute("totalCustomerCount") == null ? 0
            : ((Number) request.getAttribute("totalCustomerCount")).longValue();
    long totalBookingCount = request.getAttribute("totalBookingCount") == null ? 0
            : ((Number) request.getAttribute("totalBookingCount")).longValue();
    BigDecimal totalRevenue = (BigDecimal) request.getAttribute("totalRevenue");
    if (totalRevenue == null) totalRevenue = BigDecimal.ZERO;
    long pendingBookingCount = request.getAttribute("pendingBookingCount") == null ? 0
            : ((Number) request.getAttribute("pendingBookingCount")).longValue();

    String bookingCsrfToken = (String) request.getAttribute("bookingCsrfToken");

    DateTimeFormatter dateTimeFormat = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    DateTimeFormatter timeFormat = DateTimeFormatter.ofPattern("HH:mm");
    NumberFormat vndFormat = NumberFormat.getNumberInstance(new Locale("vi", "VN"));

    com.sportify.model.User sessionUser = (com.sportify.model.User) session.getAttribute("user");
    String ownerDisplayName = (sessionUser != null && sessionUser.getFullname() != null)
            ? sessionUser.getFullname() : "Chủ sân Sportify";
    String ownerInitials = (ownerDisplayName.length() > 0)
            ? ownerDisplayName.substring(0, 1).toUpperCase() : "CS";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Quản lý khách hàng và theo dõi toàn bộ lịch sử đặt sân trên Sportify">
    <title>Quản lý Khách hàng & Lịch sử Đặt sân - Sportify</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Material+Symbols+Rounded:FILL@0..1&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/owner-dashboard.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/owner-customers.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/order-chat.css">
    <script defer src="<%= contextPath %>/assets/js/owner-customers.js"></script>
    <script defer src="<%= contextPath %>/assets/js/order-chat.js"></script>
</head>
<body class="owner-customers-page">
<div class="dashboard-layout">
    <div class="sidebar-overlay" data-sidebar-overlay aria-hidden="true"></div>
    
    <!-- SIDEBAR CHỦ SÂN -->
    <aside class="sidebar" id="owner-sidebar" aria-label="Điều hướng dành cho chủ sân">
        <div class="sidebar-header">
            <a class="sidebar-logo" href="<%= contextPath %>/home" aria-label="Sportify - Trang chủ">
                <img src="<%= contextPath %>/assets/images/logo.jpeg" alt="Sportify">
            </a>
            <button class="sidebar-close" type="button" data-sidebar-close aria-label="Đóng menu">
                <span class="material-symbols-rounded" aria-hidden="true">close</span>
            </button>
        </div>
        <div class="owner-summary">
            <div class="owner-avatar" aria-hidden="true"><%= ownerInitials %></div>
            <div class="owner-summary-text">
                <strong><%= ownerDisplayName %></strong>
                <span>Chủ sân Sportify</span>
            </div>
        </div>
        <nav class="sidebar-nav">
            <p class="nav-label">Quản lý cơ sở</p>
            <a class="nav-item" href="<%= contextPath %>/owner/fields#overview">
                <span class="material-symbols-rounded" aria-hidden="true">dashboard</span><span>Tổng quan</span>
            </a>
            <a class="nav-item" href="<%= contextPath %>/owner/bookings#booking-section">
                <span class="material-symbols-rounded" aria-hidden="true">calendar_month</span><span>Lịch đặt sân</span>
            </a>
            <a class="nav-item" href="<%= contextPath %>/owner/fields#fields">
                <span class="material-symbols-rounded" aria-hidden="true">sports_tennis</span><span>Quản lý sân</span>
            </a>
            <a class="nav-item active" href="<%= contextPath %>/owner/customers" aria-current="page">
                <span class="material-symbols-rounded" aria-hidden="true">groups</span><span>Khách hàng</span>
            </a>
            <a class="nav-item" href="<%= contextPath %>/owner/reviews">
                <span class="material-symbols-rounded" aria-hidden="true">star</span><span>Đánh giá</span>
            </a>
            <p class="nav-label nav-label-spaced">Cổng người dùng</p>
            <a class="nav-item" href="<%= contextPath %>/home">
                <span class="material-symbols-rounded" aria-hidden="true">home</span><span>Về trang chủ</span>
            </a>
            <a class="nav-item" href="<%= contextPath %>/home">
                <span class="material-symbols-rounded" aria-hidden="true">person</span><span>Trang khách hàng</span>
            </a>
        </nav>
        <a class="logout-link" href="<%= contextPath %>/owner/access/logout">
            <span class="material-symbols-rounded" aria-hidden="true">logout</span><span>Đăng xuất</span>
        </a>
    </aside>

    <div class="dashboard-main">
        <!-- TOPBAR -->
        <header class="topbar">
            <div class="topbar-start">
                <button class="menu-toggle" type="button" data-sidebar-toggle aria-label="Mở menu"
                        aria-controls="owner-sidebar" aria-expanded="false">
                    <span class="material-symbols-rounded" aria-hidden="true">menu</span>
                </button>
                <div>
                    <p class="topbar-label">Quản lý cơ sở thể thao</p>
                    <h1>Quản lý Khách hàng</h1>
                </div>
            </div>
            <div class="topbar-actions">
                <a class="btn-customer-portal" href="<%= contextPath %>/home" title="Trở về trang khách hàng">
                    <span class="material-symbols-rounded" aria-hidden="true">storefront</span>
                    <span>Xem trang người dùng</span>
                </a>
                <div class="today" aria-label="Ngày hiện tại">
                    <span class="material-symbols-rounded" aria-hidden="true">calendar_today</span>
                    <span data-current-date>Hôm nay</span>
                </div>
            </div>
        </header>

        <main class="dashboard-content">
            <!-- BANNER CHÀO MỪNG -->
            <section class="customers-hero-banner" aria-labelledby="customers-heading">
                <div class="hero-text-col">
                    <span class="hero-badge">
                        <span class="material-symbols-rounded" aria-hidden="true">verified_user</span>
                        <span>Dữ liệu khách hàng thực tế</span>
                    </span>
                    <h2 id="customers-heading">Hồ sơ Khách hàng & Lịch sử Đặt sân</h2>
                    <p>Tra cứu chi tiết danh tính, số điện thoại liên hệ, tần suất đặt lịch và toàn bộ lịch sử các lần thuê sân của khách hàng.</p>
                </div>
                <div class="hero-actions-col">
                    <a class="hero-btn-secondary" href="<%= contextPath %>/owner/bookings#booking-section">
                        <span class="material-symbols-rounded" aria-hidden="true">calendar_month</span>
                        <span>Xem lịch đặt sân</span>
                    </a>
                </div>
            </section>

            <!-- THÔNG BÁO THAO TÁC THÀNH CÔNG -->
            <% if (actionNotice != null) { %>
            <div class="customer-alert-success" role="status">
                <span class="material-symbols-rounded" aria-hidden="true">check_circle</span>
                <div>
                    <strong>Thành công!</strong>
                    <span><%= escapeHtml(actionNotice) %></span>
                </div>
            </div>
            <% } %>

            <% if (errorMessage != null) { %>
            <div class="customer-alert-error" role="alert">
                <span class="material-symbols-rounded" aria-hidden="true">error</span>
                <span><%= escapeHtml(errorMessage) %></span>
            </div>
            <% } %>

            <!-- THẺ THỐNG KÊ TỔNG QUAN -->
            <section class="stats-grid customer-stats-grid" aria-label="Thống kê khách hàng">
                <article class="stat-card modern-stat-card">
                    <div class="stat-card-top">
                        <span class="stat-icon-wrap icon-emerald">
                            <span class="material-symbols-rounded" aria-hidden="true">groups</span>
                        </span>
                        <span class="stat-tag tag-emerald">Khách đặt</span>
                    </div>
                    <div class="stat-body">
                        <p class="stat-title">Tổng số khách hàng</p>
                        <strong class="stat-number"><%= loadFailed ? "—" : String.valueOf(totalCustomerCount) %></strong>
                        <span class="stat-sub">Đã từng đặt sân</span>
                    </div>
                </article>

                <article class="stat-card modern-stat-card">
                    <div class="stat-card-top">
                        <span class="stat-icon-wrap icon-blue">
                            <span class="material-symbols-rounded" aria-hidden="true">event_available</span>
                        </span>
                        <span class="stat-tag tag-blue">Đơn đặt</span>
                    </div>
                    <div class="stat-body">
                        <p class="stat-title">Tổng lượt đặt sân</p>
                        <strong class="stat-number"><%= loadFailed ? "—" : String.valueOf(totalBookingCount) %></strong>
                        <span class="stat-sub">Phát sinh từ khách hàng</span>
                    </div>
                </article>

                <article class="stat-card modern-stat-card">
                    <div class="stat-card-top">
                        <span class="stat-icon-wrap icon-purple">
                            <span class="material-symbols-rounded" aria-hidden="true">payments</span>
                        </span>
                        <span class="stat-tag tag-purple">Doanh số</span>
                    </div>
                    <div class="stat-body">
                        <p class="stat-title">Tổng giá trị đơn</p>
                        <strong class="stat-number"><%= loadFailed ? "—" : (vndFormat.format(totalRevenue) + "đ") %></strong>
                        <span class="stat-sub">Giá trị trên tất cả các sân</span>
                    </div>
                </article>

                <article class="stat-card modern-stat-card">
                    <div class="stat-card-top">
                        <span class="stat-icon-wrap icon-amber">
                            <span class="material-symbols-rounded" aria-hidden="true">pending_actions</span>
                        </span>
                        <span class="stat-tag tag-amber">Cần duyệt</span>
                    </div>
                    <div class="stat-body">
                        <p class="stat-title">Đơn chờ xác nhận</p>
                        <strong class="stat-number text-amber"><%= loadFailed ? "—" : String.valueOf(pendingBookingCount) %></strong>
                        <span class="stat-sub">Yêu cầu chưa xử lý</span>
                    </div>
                </article>
            </section>

            <!-- BẢNG DANH SÁCH KHÁCH HÀNG -->
            <section class="customer-main-panel" aria-labelledby="customer-list-title">
                <div class="customer-panel-header">
                    <div class="panel-heading-wrap">
                        <span class="panel-eyebrow">DANH SÁCH KHÁCH ĐẶT SÂN</span>
                        <h2 id="customer-list-title">Khách hàng của cơ sở</h2>
                        <% if (!loadFailed) { %>
                            <p class="panel-subtitle">Hiển thị <strong><%= customers.size() %></strong> khách hàng · Bấm vào khách để xem chi tiết lịch sử đặt sân</p>
                        <% } %>
                    </div>

                    <!-- THANH TÌM KIẾM & BỘ LỌC TỨC THÌ -->
                    <div class="customer-filter-toolbar">
                        <div class="search-input-box">
                            <span class="material-symbols-rounded search-icon" aria-hidden="true">search</span>
                            <input id="customer-search-input" type="search" maxlength="100"
                                   value="<%= escapeHtml(search) %>" placeholder="Tìm theo tên khách, số điện thoại, mã đơn..."
                                   autocomplete="off">
                            <% if (search != null && !search.isEmpty()) { %>
                                <a class="clear-search-btn" href="<%= contextPath %>/owner/customers" title="Xóa tìm kiếm">
                                    <span class="material-symbols-rounded">close</span>
                                </a>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- CÁC CHIP BỘ LỌC NHANH (LIVE FILTER CHIPS) -->
                <div class="quick-filter-chips" role="tablist">
                    <button type="button" class="chip-btn active" data-filter="all">
                        <span>Tất cả</span>
                        <span class="chip-count"><%= customers.size() %></span>
                    </button>
                    <button type="button" class="chip-btn" data-filter="pending">
                        <span class="dot-indicator dot-amber"></span>
                        <span>Có đơn chờ duyệt</span>
                    </button>
                    <button type="button" class="chip-btn" data-filter="frequent">
                        <span class="material-symbols-rounded chip-icon">star</span>
                        <span>Khách quen (≥2 đơn)</span>
                    </button>
                    <button type="button" class="chip-btn" data-filter="registered">
                        <span class="material-symbols-rounded chip-icon">account_circle</span>
                        <span>Tài khoản Sportify</span>
                    </button>
                </div>

                <% if (customers.isEmpty()) { %>
                <div class="empty-state customer-empty-state">
                    <div class="empty-icon-wrap">
                        <span class="material-symbols-rounded" aria-hidden="true"><%= loadFailed ? "cloud_off" : "person_search" %></span>
                    </div>
                    <h3><%= loadFailed ? "Chưa thể tải danh sách khách hàng" : search != null && !search.isEmpty() ? "Không tìm thấy khách hàng phù hợp" : "Chưa có lượt đặt sân nào" %></h3>
                    <p><%= loadFailed ? "Vui lòng kiểm tra lại kết nối cơ sở dữ liệu." : search != null && !search.isEmpty() ? "Hãy thử tìm theo tên, số điện thoại khác hoặc xóa bộ lọc." : "Khi khách hàng tạo lịch hẹn trên trang chủ, thông tin của họ sẽ tự động được ghi nhận tại đây." %></p>
                    <% if (search != null && !search.isEmpty()) { %>
                        <a class="empty-btn" href="<%= contextPath %>/owner/customers">Xem toàn bộ khách hàng</a>
                    <% } %>
                </div>
                <% } else { %>
                <div class="customer-table-container">
                    <table class="customer-master-table" id="customerMasterTable">
                        <thead>
                        <tr>
                            <th scope="col" style="width: 260px;">Khách hàng</th>
                            <th scope="col" style="width: 170px;">Số điện thoại</th>
                            <th scope="col" style="width: 190px;">Tài khoản / Email</th>
                            <th scope="col" style="width: 110px; text-align: center;">Tổng đơn</th>
                            <th scope="col" style="width: 140px;">Tổng chi tiêu</th>
                            <th scope="col" style="min-width: 180px;">Lần đặt gần nhất</th>
                            <th scope="col" style="width: 140px; text-align: right;">Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (CustomerBookingProfile customer : customers) {
                            String cName = customer.getCustomerName() != null ? customer.getCustomerName() : "Khách";
                            String cInitial = cName.trim().length() > 0 ? cName.trim().substring(0, 1).toUpperCase() : "K";
                            String cPhone = customer.getCustomerPhone() != null && !customer.getCustomerPhone().trim().isEmpty()
                                    ? customer.getCustomerPhone().trim() : "Chưa có SĐT";
                            String avatarBg = getAvatarColor(cName);
                            boolean isFrequent = customer.isFrequentCustomer();
                            boolean hasPending = customer.getPendingBookings() > 0;
                            boolean isReg = customer.isRegistered();
                        %>
                        <tr class="customer-row"
                            data-customer-row
                            data-customer-key="<%= escapeHtml(customer.getCustomerKey()) %>"
                            data-search="<%= escapeHtml(cName + " " + cPhone + " " + (customer.getEmail() != null ? customer.getEmail() : "")).toLowerCase() %>"
                            data-is-frequent="<%= isFrequent %>"
                            data-has-pending="<%= hasPending %>"
                            data-is-registered="<%= isReg %>">
                            
                            <!-- CỘT 1: THÔNG TIN KHÁCH HÀNG -->
                            <td class="customer-info-cell" data-label="Khách hàng">
                                <div class="customer-profile-block">
                                    <div class="customer-avatar-badge" style="background: <%= avatarBg %>;">
                                        <%= cInitial %>
                                    </div>
                                    <div class="customer-name-meta">
                                        <div class="name-line">
                                            <strong class="customer-name-text"><%= escapeHtml(cName) %></strong>
                                            <% if (isFrequent) { %>
                                                <span class="vip-badge" title="Khách hàng thân thiết">
                                                    <span class="material-symbols-rounded">stars</span> VIP
                                                </span>
                                            <% } %>
                                        </div>
                                        <div class="account-tag-line">
                                            <% if (isReg) { %>
                                                <span class="badge-account-user">
                                                    <span class="material-symbols-rounded">verified</span>
                                                    <span>Tài khoản #<%= customer.getCustomerId() %></span>
                                                </span>
                                            <% } else { %>
                                                <span class="badge-guest-user">
                                                    <span>Khách trực tiếp</span>
                                                </span>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                            </td>

                            <!-- CỘT 2: SỐ ĐIỆN THOẠI -->
                            <td data-label="Số điện thoại">
                                <div class="phone-display-wrap">
                                    <span class="material-symbols-rounded phone-badge-icon">call</span>
                                    <span class="phone-number-str"><%= escapeHtml(cPhone) %></span>
                                    <% if (!"Chưa có SĐT".equals(cPhone)) { %>
                                        <button type="button" class="copy-phone-btn" data-copy-phone="<%= escapeHtml(cPhone) %>" title="Sao chép số điện thoại">
                                            <span class="material-symbols-rounded">content_copy</span>
                                        </button>
                                    <% } %>
                                </div>
                            </td>

                            <!-- CỘT 3: TÀI KHOẢN / EMAIL -->
                            <td data-label="Tài khoản / Email">
                                <div class="email-display-wrap">
                                    <% if (customer.getEmail() != null && !customer.getEmail().isEmpty()) { %>
                                        <a href="mailto:<%= escapeHtml(customer.getEmail()) %>" class="email-link" title="Gửi email cho khách">
                                            <span class="material-symbols-rounded">mail</span>
                                            <span><%= escapeHtml(customer.getEmail()) %></span>
                                        </a>
                                    <% } else { %>
                                        <span class="text-subtle">Chưa liên kết email</span>
                                    <% } %>
                                </div>
                            </td>

                            <!-- CỘT 4: TỔNG ĐƠN ĐẶT -->
                            <td data-label="Lượt đặt" style="text-align: center;">
                                <div class="booking-count-pill <%= hasPending ? "has-pending-badge" : "" %>">
                                    <strong><%= customer.getTotalBookings() %></strong>
                                    <span>đơn</span>
                                    <% if (hasPending) { %>
                                        <span class="mini-pending-dot" title="Có <%= customer.getPendingBookings() %> đơn chờ duyệt"></span>
                                    <% } %>
                                </div>
                            </td>

                            <!-- CỘT 5: TỔNG CHI TIÊU -->
                            <td data-label="Tổng chi tiêu">
                                <strong class="total-spent-str"><%= vndFormat.format(customer.getTotalSpent()) %> đ</strong>
                            </td>

                            <!-- CỘT 6: LẦN ĐẶT GẦN NHẤT -->
                            <td data-label="Đặt gần nhất">
                                <% if (customer.getLastBookingAt() != null) { %>
                                    <div class="last-booking-block">
                                        <div class="last-date-str">
                                            <span class="material-symbols-rounded">schedule</span>
                                            <strong><%= customer.getLastBookingAt().format(dateFormat) %></strong>
                                            <span><%= customer.getLastBookingAt().format(timeFormat) %></span>
                                        </div>
                                        <% if (customer.getLastFieldName() != null) { %>
                                            <div class="last-field-tag">
                                                <span class="material-symbols-rounded">location_on</span>
                                                <span><%= escapeHtml(customer.getLastFieldName()) %></span>
                                            </div>
                                        <% } %>
                                    </div>
                                <% } else { %>
                                    <span class="text-subtle">—</span>
                                <% } %>
                            </td>

                            <!-- CỘT 7: HÀNH ĐỘNG -->
                            <td data-label="Hành động" style="text-align: right;">
                                <div style="display: inline-flex; align-items: center; justify-content: flex-end; gap: 8px;">
                                    <% if (!customer.getBookingHistory().isEmpty()) { 
                                        Booking latestBooking = customer.getBookingHistory().get(0);
                                    %>
                                    <button type="button" class="btn-chat-order-sm"
                                            onclick="openOrderChat(<%= latestBooking.getBookingId() %>, <%= customer.getCustomerId() != null ? customer.getCustomerId() : 0 %>)"
                                            title="Nhắn tin với khách về đơn gần nhất (#<%= latestBooking.getBookingCode() %>)">
                                        <span class="material-symbols-rounded">chat</span> Chat đơn
                                    </button>
                                    <% } %>
                                    <button type="button" class="btn-open-history"
                                            data-open-modal="<%= escapeHtml(customer.getCustomerKey()) %>"
                                            title="Xem chi tiết hồ sơ và lịch sử các lần đặt sân">
                                        <span class="material-symbols-rounded">history</span>
                                        <span>Xem lịch sử</span>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

                <div class="table-pagination-footer">
                    <p id="tableResultSummary">Hiển thị <strong><%= customers.size() %></strong> khách hàng</p>
                    <span class="data-live-badge"><span class="live-dot"></span> Dữ liệu thời gian thực</span>
                </div>
                <% } %>
            </section>
        </main>
    </div>
</div>

<!-- ======================================================== -->
<!-- MODAL XEM CHI TIẾT HỒ SƠ & TOÀN BỘ LỊCH SỬ ĐẶT SÂN       -->
<!-- ======================================================== -->
<div id="customerModal" class="customer-modal-backdrop" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="customer-modal-dialog">
        <!-- MODAL BANNER HEADER -->
        <header class="modal-banner-header">
            <div class="modal-profile-card">
                <div class="modal-avatar-lg" id="modalCustomerAvatar">K</div>
                <div class="modal-profile-text">
                    <div class="modal-name-row">
                        <h3 id="modalCustomerName">Tên khách hàng</h3>
                        <span id="modalCustomerTypeBadge" class="modal-badge-type">Tài khoản</span>
                    </div>
                    <div class="modal-contact-pills">
                        <div class="contact-pill" id="modalPhoneWrapper">
                            <span class="material-symbols-rounded">call</span>
                            <strong id="modalCustomerPhone">0901234567</strong>
                            <button type="button" id="modalCopyPhoneBtn" class="pill-copy-btn" title="Sao chép số điện thoại">
                                <span class="material-symbols-rounded">content_copy</span>
                            </button>
                        </div>
                        <div class="contact-pill" id="modalEmailWrapper">
                            <span class="material-symbols-rounded">mail</span>
                            <span id="modalCustomerEmail">email@example.com</span>
                        </div>
                    </div>
                </div>
            </div>
            <button type="button" class="modal-dismiss-btn" data-close-modal aria-label="Đóng cửa sổ">
                <span class="material-symbols-rounded">close</span>
            </button>
        </header>

        <!-- MODAL BODY -->
        <div class="modal-scroll-body">
            <!-- 4 Thẻ thống kê của vị khách này -->
            <div class="modal-kpi-grid">
                <div class="kpi-card">
                    <span class="kpi-label">Tổng lượt đặt</span>
                    <strong class="kpi-val" id="modalStatTotal">0</strong>
                    <span class="kpi-desc">Tất cả các lần gửi yêu cầu</span>
                </div>
                <div class="kpi-card kpi-success">
                    <span class="kpi-label">Đã duyệt / Hoàn thành</span>
                    <strong class="kpi-val text-green" id="modalStatSuccess">0</strong>
                    <span class="kpi-desc">Đơn được phê duyệt</span>
                </div>
                <div class="kpi-card kpi-pending">
                    <span class="kpi-label">Đang chờ xác nhận</span>
                    <strong class="kpi-val text-amber" id="modalStatPending">0</strong>
                    <span class="kpi-desc">Cần chủ sân xử lý</span>
                </div>
                <div class="kpi-card kpi-spent">
                    <span class="kpi-label">Tổng chi tiêu</span>
                    <strong class="kpi-val text-blue" id="modalStatSpent">0 đ</strong>
                    <span class="kpi-desc">Tổng giá trị dịch vụ</span>
                </div>
            </div>

            <!-- DANH SÁCH TOÀN BỘ LỊCH SỬ ĐẶT SÂN -->
            <div class="modal-history-wrap">
                <div class="history-section-header">
                    <div class="section-title-group">
                        <span class="material-symbols-rounded title-icon">receipt_long</span>
                        <h4>Toàn bộ Lịch sử Đặt lịch của khách</h4>
                    </div>
                    <span class="history-sub-note">Sắp xếp theo đơn mới nhất</span>
                </div>

                <div class="modal-table-responsive">
                    <div id="modalHistoryContent">
                        <!-- Nội dung bảng chi tiết render từ server -->
                    </div>
                </div>
            </div>
        </div>

        <!-- MODAL FOOTER -->
        <footer class="modal-bottom-bar">
            <span class="modal-footer-note">Chủ sân có thể duyệt hoặc từ chối ngay đối với các đơn đang chờ</span>
            <button type="button" class="btn-modal-close" data-close-modal>
                <span class="material-symbols-rounded">close</span>
                <span>Đóng lại</span>
            </button>
        </footer>
    </div>
</div>

<!-- ======================================================== -->
<!-- KHO DỮ LIỆU ĐƯỢC RENDER SẴN TỪ SERVER (HIDDEN DATA STORE) -->
<!-- ======================================================== -->
<div id="customerDataStore" style="display:none;" aria-hidden="true">
<% for (CustomerBookingProfile customer : customers) {
    String cName = customer.getCustomerName() != null ? customer.getCustomerName() : "Khách";
    String cInitial = cName.trim().length() > 0 ? cName.trim().substring(0, 1).toUpperCase() : "K";
    String cPhone = customer.getCustomerPhone() != null && !customer.getCustomerPhone().trim().isEmpty()
            ? customer.getCustomerPhone().trim() : "Chưa có SĐT";
    int successCount = customer.getConfirmedBookings() + customer.getCompletedBookings();
    String avatarBg = getAvatarColor(cName);
%>
    <div class="customer-raw-record"
         id="data-<%= escapeHtml(customer.getCustomerKey()) %>"
         data-key="<%= escapeHtml(customer.getCustomerKey()) %>"
         data-name="<%= escapeHtml(cName) %>"
         data-initial="<%= escapeHtml(cInitial) %>"
         data-avatar-bg="<%= avatarBg %>"
         data-phone="<%= escapeHtml(cPhone) %>"
         data-email="<%= escapeHtml(customer.getEmail() != null ? customer.getEmail() : "") %>"
         data-type="<%= customer.isRegistered() ? ("Tài khoản Sportify #" + customer.getCustomerId()) : "Khách trực tiếp" %>"
         data-total="<%= customer.getTotalBookings() %>"
         data-success="<%= successCount %>"
         data-pending="<%= customer.getPendingBookings() %>"
         data-spent="<%= vndFormat.format(customer.getTotalSpent()) %> đ">

        <table class="history-sub-table">
            <thead>
                <tr>
                    <th scope="col" style="width: 110px;">Mã đơn</th>
                    <th scope="col" style="min-width: 170px;">Sân thể thao</th>
                    <th scope="col" style="width: 160px;">Khung giờ đặt</th>
                    <th scope="col" style="width: 120px;">Tổng tiền</th>
                    <th scope="col" style="width: 130px;">Trạng thái</th>
                    <th scope="col" style="width: 140px;">Thời gian tạo</th>
                    <th scope="col" style="width: 130px; text-align: right;">Thao tác</th>
                </tr>
            </thead>
            <tbody>
            <% for (Booking b : customer.getBookingHistory()) {
                String bStatus = b.getStatus() != null ? b.getStatus().toUpperCase() : "PENDING";
                String badgeClass = "badge-status-" + bStatus.toLowerCase();
            %>
                <tr>
                    <td>
                        <span class="order-code-pill">#<%= b.getBookingCode() %></span>
                    </td>
                    <td>
                        <div class="court-title-box">
                            <strong class="court-name"><%= escapeHtml(b.getField() != null ? b.getField().getFieldName() : "Sân thể thao") %></strong>
                            <% if (b.getField() != null && b.getField().getSportType() != null) { %>
                                <span class="court-type-pill"><%= b.getField().getSportType() %></span>
                            <% } %>
                        </div>
                    </td>
                    <td>
                        <div class="time-slot-box">
                            <strong><%= b.getStartsAt().format(timeFormat) %> - <%= b.getEndsAt().format(timeFormat) %></strong>
                            <span class="slot-date-str"><%= b.getStartsAt().format(dateFormat) %></span>
                        </div>
                    </td>
                    <td>
                        <strong class="slot-price-str"><%= vndFormat.format(b.getTotalPrice()) %> đ</strong>
                    </td>
                    <td>
                        <span class="booking-status-tag <%= badgeClass %>">
                            <span class="status-dot"></span>
                            <span><%= b.getStatusLabel() %></span>
                        </span>
                    </td>
                    <td>
                        <span class="created-at-str"><%= b.getCreatedAt() != null ? b.getCreatedAt().format(dateTimeFormat) : "—" %></span>
                    </td>
                    <td style="text-align: right;">
                        <div style="display: inline-flex; align-items: center; justify-content: flex-end; gap: 6px;">
                            <button type="button" class="btn-chat-order-sm"
                                    onclick="openOrderChat(<%= b.getBookingId() %>, <%= customer.getCustomerId() != null ? customer.getCustomerId() : 0 %>)"
                                    title="Nhắn tin với khách phục vụ đơn này">
                                <span class="material-symbols-rounded">chat</span> Chat
                            </button>
                            <% if ("PENDING".equals(bStatus)) { %>
                            <div class="quick-booking-actions">
                                <form method="post" action="<%= contextPath %>/owner/bookings/status" style="display:inline;">
                                    <input type="hidden" name="bookingId" value="<%= b.getBookingId() %>">
                                    <input type="hidden" name="status" value="CONFIRMED">
                                    <input type="hidden" name="from" value="customers">
                                    <input type="hidden" name="csrfToken" value="<%= escapeHtml(bookingCsrfToken) %>">
                                    <button type="submit" class="action-btn-confirm" title="Xác nhận đơn">
                                        <span class="material-symbols-rounded">check</span> Duyệt
                                    </button>
                                </form>
                                <form method="post" action="<%= contextPath %>/owner/bookings/status" style="display:inline;">
                                    <input type="hidden" name="bookingId" value="<%= b.getBookingId() %>">
                                    <input type="hidden" name="status" value="REJECTED">
                                    <input type="hidden" name="from" value="customers">
                                    <input type="hidden" name="csrfToken" value="<%= escapeHtml(bookingCsrfToken) %>">
                                    <button type="submit" class="action-btn-reject" title="Từ chối đơn">
                                        <span class="material-symbols-rounded">close</span>
                                    </button>
                                </form>
                            </div>
                            <% } else { %>
                            <span class="action-done-label">Đã xử lý</span>
                            <% } %>
                        </div>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
    </div>
<% } %>
</div>

<!-- TOAST THÔNG BÁO SAO CHÉP NHANH -->
<div id="copyToast" class="copy-toast" aria-live="polite">
    <span class="material-symbols-rounded">check_circle</span>
    <span id="copyToastMsg">Đã sao chép số điện thoại!</span>
</div>

<%@ include file="/WEB-INF/views/common/order-chat-modal.jspf" %>
<script>
    const CTX = '<%= contextPath %>';
</script>

</body>
</html>
