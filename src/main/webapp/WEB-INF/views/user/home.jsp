<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.sportify.model.User" %>
<%@ page import="com.sportify.model.Appointment" %>
<%@ page import="com.sportify.model.SportField" %>
<%@ page import="com.sportify.model.Booking" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%-- Controller: com.sportify.controller.home.HomeServlet (GET /home) --%>
<%
    String contextPath = request.getContextPath();
    User user = (User) session.getAttribute("user");

    int upcomingCount = (Integer) request.getAttribute("upcomingCount");
    int trainingHours = (Integer) request.getAttribute("trainingHours");
    @SuppressWarnings("unchecked")
    List<Appointment> upcomingAppts = (List<Appointment>) request.getAttribute("upcomingAppts");
    if (upcomingAppts == null) upcomingAppts = java.util.Collections.emptyList();

    @SuppressWarnings("unchecked")
    List<SportField> activeFields = (List<SportField>) request.getAttribute("activeFields");
    if (activeFields == null) activeFields = java.util.Collections.emptyList();

    @SuppressWarnings("unchecked")
    List<Booking> customerBookings = (List<Booking>) request.getAttribute("customerBookings");
    if (customerBookings == null) customerBookings = java.util.Collections.emptyList();

    String bookingMsg = (String) request.getAttribute("bookingMsg");
    boolean bookingOk = Boolean.TRUE.equals(request.getAttribute("bookingOk"));

    NumberFormat vndFormat = NumberFormat.getInstance(new Locale("vi", "VN"));
    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang chủ - Sportify</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/pages/home.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/icons.css">
</head>
<body>

<% String activeMenu = "home"; %>
<%@ include file="/WEB-INF/views/common/sidebar.jspf" %>

<div class="main-wrapper">
    <header class="top-navbar">
        <h1 class="page-title">Tổng quan</h1>
        <a href="<%= contextPath %>/profile" class="user-profile">
            <div class="profile-img"><%= user != null && user.getFullname() != null && !user.getFullname().isEmpty() ? user.getFullname().substring(0,1).toUpperCase() : "U" %></div>
            <div class="profile-name"><%= user != null ? user.getFullname() : "Người dùng" %></div>
        </a>
    </header>

    <main class="content-area">

        <!-- THÔNG BÁO NẾU CÓ -->
        <% if (bookingMsg != null && !bookingMsg.trim().isEmpty()) { %>
        <div class="alert-banner <%= bookingOk ? "alert-success" : "alert-error" %>">
            <span><span class="app-icon icon-<%= bookingOk ? "check" : "alert" %>" aria-hidden="true"></span> <%= bookingMsg %></span>
            <button type="button" class="close-alert" onclick="this.parentElement.remove()"><span class="app-icon icon-close" aria-hidden="true"></span></button>
        </div>
        <% } %>

        <!-- WELCOME CARD -->
        <div class="welcome-card">
            <div>
                <h2>Chào bạn, <%= user != null ? user.getFullname() : "" %>!</h2>
                <p>Khám phá cụm sân tập, phòng gym cao cấp và đặt lịch trực tuyến cùng đối tác Sportify.</p>
            </div>
            <div class="welcome-illustration"><span class="app-icon icon-court" aria-hidden="true"></span></div>
        </div>

        <!-- STATS CARDS -->
        <div class="stats-grid">
            <a href="#my-bookings" class="stat-card">
                <div class="stat-icon" style="background: var(--primary-light); color: var(--primary);"><span class="app-icon icon-court" aria-hidden="true"></span></div>
                <div class="stat-info">
                    <h4>Đơn đặt sân của bạn</h4>
                    <span><%= customerBookings.size() %></span>
                    <small><%= customerBookings.isEmpty() ? "Chưa có đơn nào" : "lịch đã gửi chủ sân" %></small>
                </div>
            </a>

            <a href="<%= contextPath %>/appointments" class="stat-card">
                <div class="stat-icon" style="background: #fef3c7; color: #d97706;"><span class="app-icon icon-calendar" aria-hidden="true"></span></div>
                <div class="stat-info">
                    <h4>Giờ tập tháng này</h4>
                    <span><%= trainingHours %>h</span>
                    <small><%= trainingHours == 0 ? "Hãy bắt đầu tập luyện!" : "giờ đã tập luyện" %></small>
                </div>
            </a>
        </div>

        <!-- DANH SÁCH SÂN & DỊCH VỤ (GỌN GÀNG, ĐÓNG KHUNG CHUẨN ĐẸP) -->
        <div class="section-header" id="fields">
            <h3><span class="app-icon icon-court" aria-hidden="true"></span> Sân & Dịch vụ tập luyện</h3>
            <span style="font-size: 13px; color: var(--muted);"><%= activeFields.size() %> cơ sở hoạt động</span>
        </div>

        <% if (activeFields.isEmpty()) { %>
        <div class="empty-appt" style="margin-bottom: 28px;">
            Hiện tại chưa có sân hoặc dịch vụ nào mở hoạt động.
        </div>
        <% } else { %>
        <div class="fields-grid">
            <% for (SportField f : activeFields) {
                String st = f.getSportType() != null ? f.getSportType().toUpperCase() : "GENERAL";
                String badgeClass = "badge-default";
                String badgeText = f.getSportType() != null ? f.getSportType() : "THỂ THAO";
                String badgeIcon = "court";
                String defaultImg = contextPath + "/assets/images/basketball.jpg";

                if ("GYM".equals(st)) {
                    badgeClass = "badge-gym";
                    badgeText = "Gym";
                    badgeIcon = "gym";
                    defaultImg = contextPath + "/assets/images/gymfitzone.jfif";
                } else if ("BASKETBALL".equals(st)) {
                    badgeClass = "badge-basketball";
                    badgeText = "Bóng rổ";
                    badgeIcon = "basketball";
                    defaultImg = contextPath + "/assets/images/basketballcourt1.jpg";
                } else if ("SWIMMING".equals(st)) {
                    badgeClass = "badge-swimming";
                    badgeText = "Hồ bơi";
                    badgeIcon = "swimming";
                    defaultImg = contextPath + "/assets/images/swimmingpoolaqua.jfif";
                } else if ("PICKLEBALL".equals(st)) {
                    badgeClass = "badge-pickleball";
                    badgeText = "Pickleball";
                    badgeIcon = "racket";
                    defaultImg = contextPath + "/assets/images/greenpickleballcourt.jfif";
                }

                String imgSrc = f.getImageUrl() != null && !f.getImageUrl().trim().isEmpty() 
                                ? contextPath + "/" + f.getImageUrl() 
                                : defaultImg;

                String openTimeStr = f.getOpenTime() != null ? f.getOpenTime().toString().substring(0, 5) : "06:00";
                String closeTimeStr = f.getCloseTime() != null ? f.getCloseTime().toString().substring(0, 5) : "22:00";
                double price = f.getPricePerHour() != null ? f.getPricePerHour().doubleValue() : 0.0;
            %>
            <div class="field-card">
                <!-- KHUNG THUMBNAIL -->
                <div class="field-card-thumb">
                    <img src="<%= imgSrc %>" alt="<%= f.getFieldName() %>" onerror="this.src='<%= defaultImg %>'">
                    <span class="field-card-badge <%= badgeClass %>">
                        <span><span class="app-icon icon-<%= badgeIcon %>" aria-hidden="true"></span></span> <%= badgeText %>
                    </span>
                </div>

                <!-- NỘI DUNG SÂN -->
                <div class="field-card-info">
                    <div>
                        <div class="field-card-header">
                            <h4 class="field-card-title" title="<%= f.getFieldName() %>"><%= f.getFieldName() %></h4>

                        </div>

                        <div class="field-card-meta">
                            <span title="<%= f.getAddress() %>"><span class="app-icon icon-map" aria-hidden="true"></span> <%= f.getAddress() != null ? f.getAddress() : "TP. Hồ Chí Minh" %></span>
                            <span><span class="app-icon icon-clock" aria-hidden="true"></span> <%= openTimeStr %> - <%= closeTimeStr %> hàng ngày</span>
                        </div>

                        <p class="field-card-desc">
                            <%= f.getDescription() != null ? f.getDescription() : "Cơ sở thể thao hiện đại, phục vụ hội viên tận tình." %>
                        </p>
                    </div>

                    <!-- FOOTER: GIÁ & NÚT ĐẶT LỊCH CHUYỂN SANG TRANG RIÊNG -->
                    <div class="field-card-action">
                        <div class="field-card-price">
                            <%= vndFormat.format(price) %> đ <small>/ giờ</small>
                        </div>

                        <a href="<%= contextPath %>/field-booking?fieldId=<%= f.getFieldId() %>" class="btn-book-action">
                            <span><span class="app-icon icon-calendar" aria-hidden="true"></span></span> Đặt lịch
                        </a>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>

        <!-- ĐƠN ĐẶT SÂN CỦA BẠN (ĐÓNG KHUNG BẢNG LỊCH) -->
        <div class="section-header" id="my-bookings">
            <h3><span class="app-icon icon-file" aria-hidden="true"></span> Đơn đặt sân của bạn</h3>
            <% if (!customerBookings.isEmpty()) { %>
            <span style="font-size: 13px; color: var(--muted);"><%= customerBookings.size() %> đơn đã gửi</span>
            <% } %>
        </div>

        <% if (customerBookings.isEmpty()) { %>
        <div class="empty-appt" style="margin-bottom: 28px;">
            <span class="app-icon icon-inbox" aria-hidden="true"></span> Bạn chưa có đơn đặt sân nào.<br>
            <a href="#fields" style="color: var(--primary); font-weight: 600;">+ Chọn sân và gửi yêu cầu đặt lịch ở trên</a>
        </div>
        <% } else { %>
        <div class="card-framed-box">
            <table class="bookings-table">
                <thead>
                    <tr>
                        <th>Mã đơn</th>
                        <th>Sân / Dịch vụ</th>
                        <th>Ngày đặt</th>
                        <th>Khung giờ</th>
                        <th>Tổng tiền</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Booking b : customerBookings) {
                        String stClass = "status-pending";
                        String stText = "Chờ xác nhận";
                        if ("CONFIRMED".equals(b.getStatus())) {
                            stClass = "status-confirmed";
                            stText = "Đã xác nhận";
                        } else if ("REJECTED".equals(b.getStatus())) {
                            stClass = "status-rejected";
                            stText = "Bị từ chối";
                        } else if ("COMPLETED".equals(b.getStatus())) {
                            stClass = "status-completed";
                            stText = "Hoàn thành";
                        } else if ("CANCELLED".equals(b.getStatus())) {
                            stClass = "status-cancelled";
                            stText = "Đã hủy";
                        }

                        String dateText = b.getStartsAt() != null ? b.getStartsAt().toLocalDate().format(dateFmt) : "";
                        String startTimeText = b.getStartsAt() != null ? b.getStartsAt().toLocalTime().format(timeFmt) : "";
                        String endTimeText = b.getEndsAt() != null ? b.getEndsAt().toLocalTime().format(timeFmt) : "";
                        String fieldTitle = b.getField() != null ? b.getField().getFieldName() : "Sân #" + b.getBookingId();
                    %>
                    <tr>
                        <td><strong style="color: var(--primary); font-weight: 800;">#<%= b.getBookingCode() %></strong></td>
                        <td>
                            <div style="font-weight: 700; color: #1e293b;"><%= fieldTitle %></div>
                            <% if (b.getField() != null && b.getField().getSportType() != null) { %>
                            <small style="color: var(--muted); font-weight: 600;"><%= b.getField().getSportType() %></small>
                            <% } %>
                        </td>
                        <td><%= dateText %></td>
                        <td><strong><%= startTimeText %> - <%= endTimeText %></strong></td>
                        <td><strong style="color: var(--primary); font-size: 14.5px;"><%= vndFormat.format(b.getTotalPrice()) %> đ</strong></td>
                        <td>
                            <span class="status-pill <%= stClass %>">
                                <% if ("PENDING".equals(b.getStatus())) { %><span class="app-icon icon-clock" aria-hidden="true"></span><% }
                                   else if ("CONFIRMED".equals(b.getStatus())) { %><span class="app-icon icon-check" aria-hidden="true"></span><% }
                                   else if ("REJECTED".equals(b.getStatus())) { %><span class="app-icon icon-close" aria-hidden="true"></span><% }
                                   else if ("COMPLETED".equals(b.getStatus())) { %><span class="app-icon icon-trophy" aria-hidden="true"></span><% }
                                   else { %><span class="app-icon icon-ban" aria-hidden="true"></span><% } %>
                                <%= stText %>
                            </span>
                        </td>
                        <td>
                            <% if ("PENDING".equals(b.getStatus())) { %>
                            <form method="post" action="<%= contextPath %>/field-booking/cancel" style="display:inline;"
                                  onsubmit="return confirm('Bạn có chắc chắn muốn hủy yêu cầu đặt sân này?');">
                                <input type="hidden" name="bookingId" value="<%= b.getBookingId() %>">
                                <button type="submit" class="btn-cancel-sm">Hủy đơn</button>
                            </form>
                            <% } else { %>
                            <span style="color: var(--muted); font-size: 12px;">—</span>
                            <% } %>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>

        <!-- LỊCH HẸN CÁ NHÂN SẮP TỚI -->
        <div class="section-header">
            <h3><span class="app-icon icon-file" aria-hidden="true"></span> Lịch hẹn cá nhân sắp tới</h3>
            <a href="<%= contextPath %>/appointments">Xem tất cả <span class="app-icon icon-arrow" aria-hidden="true"></span></a>
        </div>

        <% if (upcomingAppts.isEmpty()) { %>
        <div class="empty-appt">
            <span class="app-icon icon-inbox" aria-hidden="true"></span> Chưa có lịch hẹn cá nhân nào sắp tới.<br>
            <a href="<%= contextPath %>/appointments" style="color: var(--primary); font-weight: 600;">+ Thêm lịch hẹn ngay</a>
        </div>
        <% } else {
            int shown = 0;
            for (Appointment a : upcomingAppts) {
                if (shown >= 3) break;
                String itemType = a.getType() != null ? a.getType() : "court";
                String bg = "#e0f2fe";
                String icon = "soccer";
                String meta = "Đặt sân";
                if ("pt".equals(itemType)) {
                    bg = "#fef3c7";
                    icon = "gym";
                    meta = "Tập với PT";
                } else if ("gear".equals(itemType)) {
                    bg = "#f3e8ff";
                    icon = "racket";
                    meta = "Thuê Gear";
                } else if ("clothing".equals(itemType)) {
                    bg = "#fce7f3";
                    icon = "user";
                    meta = "Thuê Trang phục";
                }
                shown++;
        %>
        <div class="appt-mini">
            <div class="appt-mini-icon" style="background: <%= bg %>">
                <span class="app-icon icon-<%= icon %>" aria-hidden="true"></span>
            </div>
            <div class="appt-mini-info">
                <div class="appt-mini-title"><%= a.getTitle() %></div>
                <div class="appt-mini-meta">
                    <%= meta %>
                    <% if (a.getNote() != null && !a.getNote().isEmpty()) { %>
                    — <%= a.getNote() %>
                    <% } %>
                </div>
            </div>
            <div class="appt-mini-date">
                <%= a.getAppointmentTime() %>
                <small><%= a.getAppointmentDate() %></small>
            </div>
        </div>
        <% } } %>

    </main>
</div>

</body>
</html>
