<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.sportify.model.SportField,com.sportify.model.FieldBlock,com.sportify.model.Booking,com.sportify.data.AvailabilityDB,com.sportify.util.Html,java.util.List,java.time.LocalDate,java.time.format.DateTimeFormatter" %>
<%
    String contextPath = request.getContextPath();
    List<SportField> fields = (List<SportField>) request.getAttribute("fields");
    SportField field = (SportField) request.getAttribute("selectedField");
    LocalDate date = (LocalDate) request.getAttribute("selectedDate");
    AvailabilityDB.Day day = (AvailabilityDB.Day) request.getAttribute("availability");
    List<FieldBlock> blocks = (List<FieldBlock>) request.getAttribute("blocks");
    List<Booking> bookings = (List<Booking>) request.getAttribute("calendarBookings");
    DateTimeFormatter time = DateTimeFormatter.ofPattern("HH:mm");
    DateTimeFormatter full = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html><html lang="vi"><head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Lịch trống và khóa giờ - Sportify</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/owner-dashboard.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/booking-automation.css">
    <script defer src="<%= contextPath %>/assets/js/availability.js"></script>
    <script defer src="<%= contextPath %>/assets/js/owner-calendar.js"></script>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/icons.css">
</head><body class="calendar-page">
<div class="dashboard-layout">
    <aside class="sidebar" id="owner-sidebar">
        <div class="sidebar-header"><a class="sidebar-logo" href="<%= contextPath %>/home"><img src="<%= contextPath %>/assets/images/logo.jpeg" alt="Sportify"></a></div>
        <nav class="sidebar-nav">
            <p class="nav-label">QUẢN LÝ SÂN</p>
            <a class="nav-item" href="<%= contextPath %>/owner/fields">Tổng quan và quản lý sân</a>
            <a class="nav-item" href="<%= contextPath %>/owner/bookings">Đơn đặt sân</a>
            <a class="nav-item active" href="<%= contextPath %>/owner/calendar" aria-current="page">Lịch trống và khóa giờ</a>
            <a class="nav-item" href="<%= contextPath %>/owner/customers">Khách hàng</a>
            <a class="nav-item" href="<%= contextPath %>/owner/reviews">Đánh giá</a>
            <a class="nav-item" href="<%= contextPath %>/notifications">Thông báo</a>
            <a class="nav-item" href="<%= contextPath %>/home">Trang khách hàng</a>
        </nav>
        <a class="logout-link" href="<%= contextPath %>/logout">Đăng xuất</a>
    </aside>
    <div class="dashboard-main">
        <header class="topbar"><div><p class="topbar-label">Khu vực chủ sân</p><h1>Lịch sân theo ngày</h1></div>
            <div class="automation-toolbar"><a class="automation-button secondary" href="<%= contextPath %>/owner/fields">Quản lý sân</a><%@ include file="/WEB-INF/views/common/notification-link.jspf" %></div>
        </header>
        <main class="dashboard-content">
            <% if (request.getAttribute("calendarMessage") != null) { %><p class="automation-message" role="status"><%= Html.escape(request.getAttribute("calendarMessage")) %></p><% } %>
            <section class="automation-panel">
                <h2>Lịch trống, lịch đã đặt và giờ ngoại lệ</h2>
                <p>Chọn sân và ngày. Giờ trống tính theo số sân con còn lại sau các đơn chờ duyệt, đã xác nhận và giờ khóa. Thời gian hiển thị theo giờ Việt Nam.</p>
                <% if (fields.isEmpty()) { %><p>Bạn chưa có sân nào. <a href="<%= contextPath %>/owner/fields#fields">Thêm sân để bắt đầu</a>.</p><% } else { %>
                <form class="automation-toolbar" method="get" action="<%= contextPath %>/owner/calendar">
                    <label>Sân<select name="fieldId"><% for (SportField choice : fields) { %><option value="<%= choice.getFieldId() %>" <%= choice.getFieldId().equals(field.getFieldId()) ? "selected" : "" %>><%= Html.escape(choice.getFieldName()) %></option><% } %></select></label>
                    <label>Ngày<input type="date" name="date" value="<%= date %>" required></label>
                    <button class="automation-button" type="submit">Xem lịch</button>
                </form>
                <div class="availability-grid" data-owner-availability data-context="<%= contextPath %>" data-field-id="<%= field.getFieldId() %>" data-date="<%= date %>">
                    <% for (AvailabilityDB.Window window : day.windows()) { %>
                    <div class="availability-window slot-<%= window.status().toLowerCase(java.util.Locale.ROOT) %>"><strong><%= window.startsAt().format(time) %> – <%= window.endsAt().format(time) %></strong><span><%= "FREE".equals(window.status()) ? "Còn trống" : "BOOKED".equals(window.status()) ? "Đã đặt" : "BLOCKED".equals(window.status()) ? "Đã khóa" : "PAST".equals(window.status()) ? "Đã qua giờ" : "Tạm ngưng" %></span><small><%= Html.escape(window.reason()) %></small></div>
                    <% } %>
                </div>
                <p class="availability-status" data-calendar-status aria-live="polite">Lịch được làm mới mỗi 15 giây. Bấm khoảng trống để điền giờ khóa.</p>
                <% } %>
            </section>
            <% if (field != null) { %>
            <div class="automation-two-columns">
                <section class="automation-panel"><h2>Chế độ xác nhận đơn mới</h2>
                    <p><strong><%= field.isAutoApprove() ? "Đang tự động xác nhận" : "Đang duyệt thủ công" %></strong> · <%= Html.escape(field.getFieldName()) %></p>
                    <% if (field.supportsAutoApproval()) { %>
                    <p>Khi bật, đơn mới hợp lệ được xác nhận và giữ chỗ ngay. Các đơn cũ đang chờ vẫn cần bạn xử lý.</p>
                    <form method="post" action="<%= contextPath %>/owner/fields/approval">
                        <input type="hidden" name="csrfToken" value="<%= Html.escape(request.getAttribute("csrfToken")) %>">
                        <input type="hidden" name="fieldId" value="<%= field.getFieldId() %>"><input type="hidden" name="date" value="<%= date %>">
                        <input type="hidden" name="enabled" value="<%= !field.isAutoApprove() %>">
                        <button class="automation-button" type="submit"><%= field.isAutoApprove() ? "Chuyển sang duyệt thủ công" : "Bật tự xác nhận" %></button>
                    </form>
                    <% } else { %><p>Tự xác nhận hiện dành cho sân bóng rổ và pickleball thuê riêng. Gym và hồ bơi giữ chế độ duyệt thủ công.</p><% } %>
                </section>
                <section class="automation-panel"><h2>Khóa giờ ngoại lệ</h2><p>Dùng cho bảo trì, sự kiện hoặc khách đã đặt trực tiếp. Hệ thống sẽ kiểm tra các đơn được xác nhận trước khi khóa.</p>
                    <form class="automation-form" method="post" action="<%= contextPath %>/owner/blocks/create" data-block-form>
                        <input type="hidden" name="csrfToken" value="<%= Html.escape(request.getAttribute("csrfToken")) %>">
                        <input type="hidden" name="fieldId" value="<%= field.getFieldId() %>"><input type="hidden" name="date" value="<%= date %>">
                        <div class="automation-two-columns"><label>Từ lúc<input type="datetime-local" name="startsAt" value="<%= date %>T<%= field.getOpenTime().format(time) %>" required></label>
                        <label>Đến lúc<input type="datetime-local" name="endsAt" value="<%= date %>T<%= field.getCloseTime().format(time) %>" required></label></div>
                        <label>Lý do hiển thị cho khách<textarea name="reason" maxlength="250" required placeholder="Ví dụ: Bảo trì mặt sân"></textarea></label>
                        <button class="automation-button" type="submit">Kiểm tra và khóa giờ</button>
                    </form>
                </section>
            </div>
            <section class="automation-panel"><h2>Khoảng giờ đã khóa</h2>
                <% if (blocks.isEmpty()) { %><p>Không có lịch khóa trong ngày đang xem.</p><% } else { %>
                <div class="automation-table-wrap"><table class="automation-table"><thead><tr><th>Khoảng giờ</th><th>Lý do</th><th>Thao tác</th></tr></thead><tbody>
                    <% for (FieldBlock block : blocks) { %><tr><td><%= block.getStartsAt().format(full) %> – <%= block.getEndsAt().format(full) %></td><td><%= Html.escape(block.getReason()) %></td><td>
                        <form method="post" action="<%= contextPath %>/owner/blocks/delete" data-unblock-form>
                            <input type="hidden" name="csrfToken" value="<%= Html.escape(request.getAttribute("csrfToken")) %>"><input type="hidden" name="fieldId" value="<%= field.getFieldId() %>"><input type="hidden" name="blockId" value="<%= block.getBlockId() %>"><input type="hidden" name="date" value="<%= date %>">
                            <button class="automation-button secondary" type="submit">Mở lại giờ</button>
                        </form></td></tr><% } %>
                </tbody></table></div><% } %>
            </section>
            <section class="automation-panel"><h2>Đơn đặt sân trong ngày</h2>
                <% if (bookings.isEmpty()) { %><p>Chưa có đơn đặt sân trong ngày này.</p><% } else { %>
                <div class="automation-table-wrap"><table class="automation-table"><thead><tr><th>Mã đơn</th><th>Khách hàng</th><th>Giờ chơi</th><th>Trạng thái</th><th>Cách xác nhận</th></tr></thead><tbody>
                    <% for (Booking booking : bookings) { %><tr><td><a href="<%= contextPath %>/owner/bookings#booking-section"><%= booking.getBookingCode() %></a></td><td><%= Html.escape(booking.getCustomerName()) %></td><td><%= booking.getStartsAt().format(time) %> – <%= booking.getEndsAt().format(time) %></td><td><%= booking.getStatusLabel() %></td><td><%= booking.isAutomaticallyConfirmed() ? "Hệ thống tự xác nhận" : "PENDING".equals(booking.getStatus()) ? "Chờ chủ sân" : "Chủ sân xử lý" %></td></tr><% } %>
                </tbody></table></div><% } %>
            </section>
            <% } %>
        </main>
    </div>
</div></body></html>
