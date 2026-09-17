<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%
    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Bảng điều khiển quản lý sân Sportify">

    <title>Tổng quan chủ sân - Sportify</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:FILL@0..1&amp;display=swap"
          rel="stylesheet">
    <link rel="stylesheet"
          href="<%= contextPath %>/assets/css/owner-dashboard.css">
    <script defer
            src="<%= contextPath %>/assets/js/owner-dashboard.js"></script>
</head>

<body>
<div class="dashboard-layout">
    <div class="sidebar-overlay" data-sidebar-overlay aria-hidden="true"></div>

    <aside class="sidebar" id="owner-sidebar" aria-label="Điều hướng dành cho chủ sân">
        <div class="sidebar-header">
            <a class="sidebar-logo" href="<%= contextPath %>/home.jsp" aria-label="Sportify - Trang chủ">
                <img src="<%= contextPath %>/assets/images/logo.jpeg" alt="Sportify">
            </a>

            <button class="sidebar-close" type="button" data-sidebar-close aria-label="Đóng menu">
                <span class="material-symbols-rounded" aria-hidden="true">close</span>
            </button>
        </div>

        <div class="owner-summary">
            <div class="owner-avatar" aria-hidden="true">MN</div>
            <div class="owner-summary-text">
                <strong>Minh Nguyễn</strong>
                <span>Chủ sân Sportify</span>
            </div>
        </div>

        <nav class="sidebar-nav">
            <p class="nav-label">Quản lý</p>

            <a class="nav-item active" href="#overview" aria-current="page">
                <span class="material-symbols-rounded" aria-hidden="true">dashboard</span>
                <span>Tổng quan</span>
            </a>
            <a class="nav-item" href="#booking-section">
                <span class="material-symbols-rounded" aria-hidden="true">calendar_month</span>
                <span>Lịch đặt sân</span>
                <span class="nav-count" data-pending-nav-count>4</span>
            </a>
            <a class="nav-item" href="#fields">
                <span class="material-symbols-rounded" aria-hidden="true">sports_tennis</span>
                <span>Quản lý sân</span>
            </a>
            <a class="nav-item" href="#booking-section">
                <span class="material-symbols-rounded" aria-hidden="true">groups</span>
                <span>Khách hàng</span>
            </a>
            <a class="nav-item" href="#booking-section">
                <span class="material-symbols-rounded" aria-hidden="true">star</span>
                <span>Đánh giá</span>
            </a>

            <p class="nav-label nav-label-spaced">Tài khoản</p>

            <a class="nav-item" href="<%= contextPath %>/home.jsp">
                <span class="material-symbols-rounded" aria-hidden="true">home</span>
                <span>Về trang chủ</span>
            </a>
            <a class="nav-item" href="#">
                <span class="material-symbols-rounded" aria-hidden="true">help</span>
                <span>Trợ giúp</span>
            </a>
        </nav>

        <a class="logout-link" href="<%= contextPath %>/index.jsp">
            <span class="material-symbols-rounded" aria-hidden="true">logout</span>
            <span>Đăng xuất</span>
        </a>
    </aside>

    <div class="dashboard-main">
        <header class="topbar">
            <div class="topbar-start">
                <button class="menu-toggle" type="button" data-sidebar-toggle
                        aria-label="Mở menu" aria-controls="owner-sidebar" aria-expanded="false">
                    <span class="material-symbols-rounded" aria-hidden="true">menu</span>
                </button>

                <div>
                    <p class="topbar-label">Khu vực chủ sân</p>
                    <h1>Dashboard chủ sân</h1>
                </div>
            </div>

            <div class="topbar-actions">
                <div class="today" aria-label="Ngày hiện tại">
                    <span class="material-symbols-rounded" aria-hidden="true">calendar_today</span>
                    <span data-current-date>Hôm nay</span>
                </div>

                <button class="notification-button" type="button" aria-label="Thông báo mới">
                    <span class="material-symbols-rounded" aria-hidden="true">notifications</span>
                    <span class="notification-dot" aria-hidden="true"></span>
                </button>

                <div class="topbar-owner">
                    <div class="owner-avatar owner-avatar-small" aria-hidden="true">MN</div>
                    <div>
                        <strong>Minh Nguyễn</strong>
                        <span>Chủ sân</span>
                    </div>
                </div>
            </div>
        </header>

        <main class="dashboard-content" id="overview">
            <section class="welcome-panel" aria-labelledby="welcome-title">
                <div>
                    <span class="eyebrow">TỔNG QUAN HOẠT ĐỘNG</span>
                    <h2 id="welcome-title">Chào Minh!</h2>
                    <p>Bạn có <strong data-pending-message-count>4 lịch đặt</strong> đang chờ xác nhận.</p>
                </div>
                <div class="demo-label">
                    <span class="material-symbols-rounded" aria-hidden="true">info</span>
                    Dữ liệu minh họa
                </div>
            </section>

            <section class="stats-grid" id="court-summary" aria-label="Thống kê nhanh">
                <article class="stat-card stat-fields">
                    <div class="stat-card-top">
                        <span class="stat-icon">
                            <span class="material-symbols-rounded" aria-hidden="true">sports_soccer</span>
                        </span>
                        <span class="stat-caption">Đang mở</span>
                    </div>
                    <p>Sân đang hoạt động</p>
                    <strong data-active-field-count>4</strong>
                    <small>Trong hệ thống minh họa</small>
                </article>

                <article class="stat-card stat-bookings">
                    <div class="stat-card-top">
                        <span class="stat-icon">
                            <span class="material-symbols-rounded" aria-hidden="true">event_available</span>
                        </span>
                        <span class="stat-caption">Hôm nay</span>
                    </div>
                    <p>Lịch đặt hôm nay</p>
                    <strong>12</strong>
                    <small>Theo dữ liệu minh họa</small>
                </article>

                <article class="stat-card stat-pending">
                    <div class="stat-card-top">
                        <span class="stat-icon">
                            <span class="material-symbols-rounded" aria-hidden="true">pending_actions</span>
                        </span>
                        <span class="stat-caption warning">Cần xử lý</span>
                    </div>
                    <p>Yêu cầu chờ xác nhận</p>
                    <strong data-pending-count>4</strong>
                    <small>Yêu cầu đặt sân mới</small>
                </article>

                <article class="stat-card stat-revenue">
                    <div class="stat-card-top">
                        <span class="stat-icon">
                            <span class="material-symbols-rounded" aria-hidden="true">payments</span>
                        </span>
                        <span class="stat-trend positive">
                            <span class="material-symbols-rounded" aria-hidden="true">trending_up</span>
                            12,5%
                        </span>
                    </div>
                    <p>Doanh thu hôm nay</p>
                    <strong>4.850.000đ</strong>
                    <small>So với ngày hôm qua</small>
                </article>
            </section>

            <section class="booking-panel" id="booking-section" aria-labelledby="booking-title">
                <div class="booking-header">
                    <div>
                        <span class="section-kicker">QUẢN LÝ ĐẶT SÂN</span>
                        <h2 id="booking-title">Lịch đặt gần đây</h2>
                        <p>Kiểm tra và xử lý các yêu cầu đặt sân của khách hàng.</p>
                    </div>

                    <a class="view-calendar-link" href="#booking-section">
                        Xem lịch sân
                        <span class="material-symbols-rounded" aria-hidden="true">arrow_forward</span>
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
                    </div>

                    <label class="booking-search">
                        <span class="material-symbols-rounded" aria-hidden="true">search</span>
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
                            <th scope="col">Sân</th>
                            <th scope="col">Thời gian</th>
                            <th scope="col">Tổng tiền</th>
                            <th scope="col">Trạng thái</th>
                            <th scope="col" class="actions-heading">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody data-booking-body>
                        <tr data-booking-row data-status="pending" data-date-offset="0" data-search="sp1024 tran gia huy pickleball court 01">
                            <td data-label="Mã đặt sân"><strong class="booking-code">#SP1024</strong></td>
                            <td data-label="Khách hàng">
                                <div class="customer-cell">
                                    <span class="customer-avatar avatar-green">TH</span>
                                    <div><strong>Trần Gia Huy</strong><span>0901 234 567</span></div>
                                </div>
                            </td>
                            <td data-label="Sân"><strong>Pickleball Court 01</strong><span class="cell-note">Pickleball</span></td>
                            <td data-label="Thời gian"><strong><time datetime="2026-09-10T08:00">08:00 - 09:30</time></strong><span class="cell-note">Hôm nay, 10/09</span></td>
                            <td data-label="Tổng tiền"><strong>450.000đ</strong></td>
                            <td data-label="Trạng thái"><span class="status-badge status-pending">Chờ xác nhận</span></td>
                            <td data-label="Thao tác" class="booking-actions">
                                <button class="action-button confirm-button" type="button" data-booking-action="confirm" aria-label="Xác nhận đơn SP1024">Xác nhận</button>
                                <button class="action-button reject-button" type="button" data-booking-action="reject" aria-label="Từ chối đơn SP1024">Từ chối</button>
                            </td>
                        </tr>

                        <tr data-booking-row data-status="pending" data-date-offset="0" data-search="sp1025 le thu trang basketball court a">
                            <td data-label="Mã đặt sân"><strong class="booking-code">#SP1025</strong></td>
                            <td data-label="Khách hàng">
                                <div class="customer-cell">
                                    <span class="customer-avatar avatar-blue">LT</span>
                                    <div><strong>Lê Thu Trang</strong><span>0934 567 890</span></div>
                                </div>
                            </td>
                            <td data-label="Sân"><strong>Basketball Court A</strong><span class="cell-note">Bóng rổ</span></td>
                            <td data-label="Thời gian"><strong><time datetime="2026-09-10T10:00">10:00 - 11:30</time></strong><span class="cell-note">Hôm nay, 10/09</span></td>
                            <td data-label="Tổng tiền"><strong>520.000đ</strong></td>
                            <td data-label="Trạng thái"><span class="status-badge status-pending">Chờ xác nhận</span></td>
                            <td data-label="Thao tác" class="booking-actions">
                                <button class="action-button confirm-button" type="button" data-booking-action="confirm" aria-label="Xác nhận đơn SP1025">Xác nhận</button>
                                <button class="action-button reject-button" type="button" data-booking-action="reject" aria-label="Từ chối đơn SP1025">Từ chối</button>
                            </td>
                        </tr>

                        <tr data-booking-row data-status="confirmed" data-date-offset="0" data-search="sp1022 nguyen quoc bao pickleball court 02">
                            <td data-label="Mã đặt sân"><strong class="booking-code">#SP1022</strong></td>
                            <td data-label="Khách hàng">
                                <div class="customer-cell">
                                    <span class="customer-avatar avatar-purple">NB</span>
                                    <div><strong>Nguyễn Quốc Bảo</strong><span>0988 112 233</span></div>
                                </div>
                            </td>
                            <td data-label="Sân"><strong>Pickleball Court 02</strong><span class="cell-note">Pickleball</span></td>
                            <td data-label="Thời gian"><strong><time datetime="2026-09-10T14:00">14:00 - 15:30</time></strong><span class="cell-note">Hôm nay, 10/09</span></td>
                            <td data-label="Tổng tiền"><strong>450.000đ</strong></td>
                            <td data-label="Trạng thái"><span class="status-badge status-confirmed">Đã xác nhận</span></td>
                            <td data-label="Thao tác" class="booking-actions"><span class="action-finished">Đã xử lý</span></td>
                        </tr>

                        <tr data-booking-row data-status="pending" data-date-offset="0" data-search="sp1026 pham hoang nam gym room 02">
                            <td data-label="Mã đặt sân"><strong class="booking-code">#SP1026</strong></td>
                            <td data-label="Khách hàng">
                                <div class="customer-cell">
                                    <span class="customer-avatar avatar-orange">PN</span>
                                    <div><strong>Phạm Hoàng Nam</strong><span>0912 445 566</span></div>
                                </div>
                            </td>
                            <td data-label="Sân"><strong>Gym Room 02</strong><span class="cell-note">Gym</span></td>
                            <td data-label="Thời gian"><strong><time datetime="2026-09-10T17:30">17:30 - 19:00</time></strong><span class="cell-note">Hôm nay, 10/09</span></td>
                            <td data-label="Tổng tiền"><strong>380.000đ</strong></td>
                            <td data-label="Trạng thái"><span class="status-badge status-pending">Chờ xác nhận</span></td>
                            <td data-label="Thao tác" class="booking-actions">
                                <button class="action-button confirm-button" type="button" data-booking-action="confirm" aria-label="Xác nhận đơn SP1026">Xác nhận</button>
                                <button class="action-button reject-button" type="button" data-booking-action="reject" aria-label="Từ chối đơn SP1026">Từ chối</button>
                            </td>
                        </tr>

                        <tr data-booking-row data-status="completed" data-date-offset="-1" data-search="sp1018 do minh anh swimming lane 03">
                            <td data-label="Mã đặt sân"><strong class="booking-code">#SP1018</strong></td>
                            <td data-label="Khách hàng">
                                <div class="customer-cell">
                                    <span class="customer-avatar avatar-pink">DA</span>
                                    <div><strong>Đỗ Minh Anh</strong><span>0977 221 144</span></div>
                                </div>
                            </td>
                            <td data-label="Sân"><strong>Swimming Lane 03</strong><span class="cell-note">Bơi</span></td>
                            <td data-label="Thời gian"><strong><time datetime="2026-09-09T18:00">18:00 - 19:00</time></strong><span class="cell-note">Hôm qua, 09/09</span></td>
                            <td data-label="Tổng tiền"><strong>320.000đ</strong></td>
                            <td data-label="Trạng thái"><span class="status-badge status-completed">Hoàn thành</span></td>
                            <td data-label="Thao tác" class="booking-actions"><span class="action-finished">Đã xử lý</span></td>
                        </tr>

                        <tr data-booking-row data-status="pending" data-date-offset="1" data-search="sp1027 vu khanh linh pickleball court 03">
                            <td data-label="Mã đặt sân"><strong class="booking-code">#SP1027</strong></td>
                            <td data-label="Khách hàng">
                                <div class="customer-cell">
                                    <span class="customer-avatar avatar-teal">VL</span>
                                    <div><strong>Vũ Khánh Linh</strong><span>0908 776 655</span></div>
                                </div>
                            </td>
                            <td data-label="Sân"><strong>Pickleball Court 03</strong><span class="cell-note">Pickleball</span></td>
                            <td data-label="Thời gian"><strong><time datetime="2026-09-11T07:00">07:00 - 08:30</time></strong><span class="cell-note">Ngày mai, 11/09</span></td>
                            <td data-label="Tổng tiền"><strong>400.000đ</strong></td>
                            <td data-label="Trạng thái"><span class="status-badge status-pending">Chờ xác nhận</span></td>
                            <td data-label="Thao tác" class="booking-actions">
                                <button class="action-button confirm-button" type="button" data-booking-action="confirm" aria-label="Xác nhận đơn SP1027">Xác nhận</button>
                                <button class="action-button reject-button" type="button" data-booking-action="reject" aria-label="Từ chối đơn SP1027">Từ chối</button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>

                <div class="empty-state" data-empty-state hidden>
                    <span class="material-symbols-rounded" aria-hidden="true">event_busy</span>
                    <strong>Không tìm thấy lịch đặt</strong>
                    <p>Hãy thử chọn trạng thái hoặc từ khóa khác.</p>
                </div>

                <div class="table-footer">
                    <p data-booking-result aria-live="polite">Hiển thị 6 lịch đặt</p>
                    <span>Cập nhật vừa xong</span>
                </div>
            </section>

            <section class="fields-panel" id="fields" aria-labelledby="fields-title">
                <div class="fields-header">
                    <div>
                        <span class="section-kicker">DANH SÁCH CƠ SỞ</span>
                        <h2 id="fields-title">Quản lý sân</h2>
                        <p>Cập nhật thông tin và trạng thái các sân, phòng tập của bạn.</p>
                    </div>
                    <button class="primary-button" type="button" data-field-add>
                        <span class="material-symbols-rounded" aria-hidden="true">add</span>
                        Thêm sân
                    </button>
                </div>

                <div class="fields-grid" data-fields-grid>
                    <article class="field-card" data-field-card data-status="active" data-price="180000">
                        <div class="field-card-top">
                            <span class="field-sport" data-field-sport>Gym</span>
                            <span class="field-status status-active" data-field-status>Đang hoạt động</span>
                        </div>
                        <h3 data-field-name>Phòng Gym FitZone</h3>
                        <p class="field-address">
                            <span class="material-symbols-rounded" aria-hidden="true">location_on</span>
                            <span data-field-address>123 Nguyễn Trãi, Quận 1, TP.HCM</span>
                        </p>
                        <div class="field-price"><strong data-field-price>180.000đ</strong><span>/ giờ</span></div>
                        <div class="field-actions">
                            <button class="field-edit-button" type="button" data-field-edit>Chỉnh sửa</button>
                            <button class="field-toggle-button" type="button" data-field-toggle>Tạm ngưng</button>
                        </div>
                    </article>

                    <article class="field-card" data-field-card data-status="active" data-price="300000">
                        <div class="field-card-top">
                            <span class="field-sport" data-field-sport>Bóng rổ</span>
                            <span class="field-status status-active" data-field-status>Đang hoạt động</span>
                        </div>
                        <h3 data-field-name>Sân bóng rổ Sunrise</h3>
                        <p class="field-address">
                            <span class="material-symbols-rounded" aria-hidden="true">location_on</span>
                            <span data-field-address>45 Võ Văn Tần, Quận 3, TP.HCM</span>
                        </p>
                        <div class="field-price"><strong data-field-price>300.000đ</strong><span>/ giờ</span></div>
                        <div class="field-actions">
                            <button class="field-edit-button" type="button" data-field-edit>Chỉnh sửa</button>
                            <button class="field-toggle-button" type="button" data-field-toggle>Tạm ngưng</button>
                        </div>
                    </article>

                    <article class="field-card" data-field-card data-status="active" data-price="150000">
                        <div class="field-card-top">
                            <span class="field-sport" data-field-sport>Bơi</span>
                            <span class="field-status status-active" data-field-status>Đang hoạt động</span>
                        </div>
                        <h3 data-field-name>Hồ bơi Aqua Center</h3>
                        <p class="field-address">
                            <span class="material-symbols-rounded" aria-hidden="true">location_on</span>
                            <span data-field-address>78 Phan Xích Long, Phú Nhuận, TP.HCM</span>
                        </p>
                        <div class="field-price"><strong data-field-price>150.000đ</strong><span>/ giờ</span></div>
                        <div class="field-actions">
                            <button class="field-edit-button" type="button" data-field-edit>Chỉnh sửa</button>
                            <button class="field-toggle-button" type="button" data-field-toggle>Tạm ngưng</button>
                        </div>
                    </article>

                    <article class="field-card" data-field-card data-status="active" data-price="220000">
                        <div class="field-card-top">
                            <span class="field-sport" data-field-sport>Pickleball</span>
                            <span class="field-status status-active" data-field-status>Đang hoạt động</span>
                        </div>
                        <h3 data-field-name>Green Pickleball Court</h3>
                        <p class="field-address">
                            <span class="material-symbols-rounded" aria-hidden="true">location_on</span>
                            <span data-field-address>21 Nguyễn Hữu Cảnh, Bình Thạnh, TP.HCM</span>
                        </p>
                        <div class="field-price"><strong data-field-price>220.000đ</strong><span>/ giờ</span></div>
                        <div class="field-actions">
                            <button class="field-edit-button" type="button" data-field-edit>Chỉnh sửa</button>
                            <button class="field-toggle-button" type="button" data-field-toggle>Tạm ngưng</button>
                        </div>
                    </article>
                </div>
            </section>

            <template id="field-card-template">
                <article class="field-card" data-field-card data-status="active" data-price="0">
                    <div class="field-card-top">
                        <span class="field-sport" data-field-sport></span>
                        <span class="field-status status-active" data-field-status>Đang hoạt động</span>
                    </div>
                    <h3 data-field-name></h3>
                    <p class="field-address">
                        <span class="material-symbols-rounded" aria-hidden="true">location_on</span>
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
                <span class="section-kicker">QUẢN LÝ SÂN</span>
                <h2 id="field-modal-title" data-field-modal-title>Thêm sân</h2>
            </div>
            <button class="modal-close" type="button" data-field-modal-close aria-label="Đóng biểu mẫu">
                <span class="material-symbols-rounded" aria-hidden="true">close</span>
            </button>
        </div>
        <form class="field-form" data-field-form>
            <label for="field-name">Tên sân
                <input id="field-name" name="name" type="text" maxlength="100" required>
            </label>
            <label for="field-sport">Môn thể thao
                <select id="field-sport" name="sport" required>
                    <option value="">Chọn môn thể thao</option>
                    <option value="Gym">Gym</option>
                    <option value="Bóng rổ">Bóng rổ</option>
                    <option value="Bơi">Bơi</option>
                    <option value="Pickleball">Pickleball</option>
                </select>
            </label>
            <label for="field-address">Địa chỉ
                <input id="field-address" name="address" type="text" maxlength="200" required>
            </label>
            <div class="field-form-row">
                <label for="field-price">Giá theo giờ (đ)
                    <input id="field-price" name="price" type="number" min="0" step="1000" required>
                </label>
                <label for="field-status">Trạng thái
                    <select id="field-status" name="status" required>
                        <option value="active">Đang hoạt động</option>
                        <option value="paused">Tạm ngưng</option>
                    </select>
                </label>
            </div>
            <div class="modal-actions">
                <button class="secondary-button" type="button" data-field-modal-close>Hủy</button>
                <button class="primary-button" type="submit" data-field-submit>Thêm sân</button>
            </div>
        </form>
    </div>
</div>

<div class="toast" data-toast role="status" aria-live="polite" aria-atomic="true"></div>
</body>
</html>
