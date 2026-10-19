<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.sportify.model.User" %>
<%@ page import="com.sportify.model.SportField" %>
<%@ page import="com.sportify.model.Booking" %>
<%@ page import="com.sportify.data.BookingDB" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%-- Controller: com.sportify.controller.booking.FieldBookingServlet (GET /field-booking?fieldId=...) --%>
<%!
    private static String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private static String escapeJs(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("'", "\\'")
                .replace("\r", "")
                .replace("\n", " ");
    }
%>
<%
    String contextPath = request.getContextPath();
    long bookingAssetVersion = 1L;
    for (String assetPath : new String[] {
            "/assets/css/style.css", "/assets/css/pages/home.css", "/assets/css/pages/booking.css",
            "/assets/css/icons.css", "/assets/js/pages/booking.js" }) {
        java.net.URL asset = application.getResource(assetPath);
        if (asset != null) {
            bookingAssetVersion = Math.max(bookingAssetVersion,
                    asset.openConnection().getLastModified());
        }
    }
    User user = (User) session.getAttribute("user");
    SportField field = (SportField) request.getAttribute("field");
    if (field == null) {
        response.sendRedirect(contextPath + "/home");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Booking> fieldActiveBookings = (List<Booking>) request.getAttribute("fieldActiveBookings");
    if (fieldActiveBookings == null) fieldActiveBookings = Collections.emptyList();

    @SuppressWarnings("unchecked")
    List<BookingDB.BookedSlotSummary> fieldBookedSlots =
            (List<BookingDB.BookedSlotSummary>) request.getAttribute("fieldBookedSlots");
    if (fieldBookedSlots == null) fieldBookedSlots = Collections.emptyList();

    NumberFormat vndFormat = NumberFormat.getInstance(new Locale("vi", "VN"));
    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HH:mm");

    String todayStr = LocalDate.now().toString();
    String prefillDate = request.getParameter("date");
    if (prefillDate == null || !prefillDate.matches("\\d{4}-\\d{2}-\\d{2}") || prefillDate.compareTo(todayStr) < 0) {
        prefillDate = todayStr;
    }

    int fieldQuantity = field.getQuantity();

    String st = field.getSportType() != null ? field.getSportType().toUpperCase(Locale.ROOT) : "GENERAL";
    String badgeClass = "badge-default";
    String badgeText = field.getSportType() != null ? field.getSportType() : "THỂ THAO";
    String badgeIcon = "court";
    String productUnitLabel = "sân";
    String defaultImg = contextPath + "/assets/images/basketball.jpg";
    String amenitiesHtml = "";

    if ("GYM".equals(st)) {
        badgeClass = "badge-gym";
        badgeText = "Phòng Gym & Fitness";
        badgeIcon = "gym";
        productUnitLabel = "khu tập / phòng";
        defaultImg = contextPath + "/assets/images/gymfitzone.jfif";
        amenitiesHtml = "<span class='amenity-pill'>Full thiết bị tập</span><span class='amenity-pill'>Máy lạnh 24/7</span><span class='amenity-pill'>Phòng tắm nóng lạnh</span><span class='amenity-pill'>Wifi miễn phí</span>";
    } else if ("BASKETBALL".equals(st)) {
        badgeClass = "badge-basketball";
        badgeText = "Sân Bóng Rổ";
        badgeIcon = "basketball";
        productUnitLabel = "sân bóng rổ";
        defaultImg = contextPath + "/assets/images/basketballcourt1.jpg";
        amenitiesHtml = "<span class='amenity-pill'>Sàn gỗ chuẩn FIBA</span><span class='amenity-pill'>Đèn LED chiếu sáng</span><span class='amenity-pill'>Bãi giữ xe rộng</span><span class='amenity-pill'>Nước uống miễn phí</span>";
    } else if ("SWIMMING".equals(st)) {
        badgeClass = "badge-swimming";
        badgeText = "Hồ Bơi Thể Thao";
        badgeIcon = "swimming";
        productUnitLabel = "làn bơi tiêu chuẩn";
        defaultImg = contextPath + "/assets/images/swimmingpoolaqua.jfif";
        amenitiesHtml = "<span class='amenity-pill'>Làn bơi Olympic</span><span class='amenity-pill'>Nước ấm 4 mùa</span><span class='amenity-pill'>Cứu hộ chuyên nghiệp</span><span class='amenity-pill'>Phòng thay đồ VIP</span>";
    } else if ("PICKLEBALL".equals(st)) {
        badgeClass = "badge-pickleball";
        badgeText = "Sân Pickleball";
        badgeIcon = "racket";
        productUnitLabel = "sân pickleball";
        defaultImg = contextPath + "/assets/images/greenpickleballcourt.jfif";
        amenitiesHtml = "<span class='amenity-pill'>Mặt sân chuẩn thi đấu</span><span class='amenity-pill'>Đèn chơi ban đêm</span><span class='amenity-pill'>Đỗ xe ô tô</span><span class='amenity-pill'>Quầy căng tin</span>";
    } else if ("TABLE_TENNIS".equals(st)) {
        badgeClass = "badge-pickleball";
        badgeText = "Sân Bóng Bàn";
        badgeIcon = "racket";
        productUnitLabel = "sân bóng bàn";
        defaultImg = contextPath + "/assets/images/pickleball.jpg";
        amenitiesHtml = "<span class='amenity-pill'>Bàn chuẩn ITTF</span><span class='amenity-pill'>Điều hòa mát mẻ</span><span class='amenity-pill'>Ánh sáng chống lóa</span><span class='amenity-pill'>Có sẵn vợt & bóng</span>";
    }

    String imgSrc = field.getImageUrl() != null && !field.getImageUrl().trim().isEmpty()
                    ? contextPath + "/" + field.getImageUrl()
                    : defaultImg;

    String openTimeStr = field.getOpenTime() != null ? field.getOpenTime().toString().substring(0, 5) : "06:00";
    String closeTimeStr = field.getCloseTime() != null ? field.getCloseTime().toString().substring(0, 5) : "22:00";
    double price = field.getPricePerHour() != null ? field.getPricePerHour().doubleValue() : 0.0;

    int openH = Integer.parseInt(openTimeStr.split(":")[0]);
    int openM = Integer.parseInt(openTimeStr.split(":")[1]);
    int defEndH = openH + 1;
    String defStartStr = request.getParameter("startTime") != null && request.getParameter("startTime").matches("\\d{2}:\\d{2}")
            ? request.getParameter("startTime") : openTimeStr;
    String defEndTimeStr = request.getParameter("endTime") != null && request.getParameter("endTime").matches("\\d{2}:\\d{2}")
            ? request.getParameter("endTime") : String.format("%02d:%02d", defEndH, openM);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt lịch: <%= escapeHtml(field.getFieldName()) %> - Sportify</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css?v=<%= bookingAssetVersion %>">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/pages/home.css?v=<%= bookingAssetVersion %>">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/pages/booking.css?v=<%= bookingAssetVersion %>">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/icons.css?v=<%= bookingAssetVersion %>">
</head>
<body>

<% String activeMenu = "home"; %>
<%@ include file="/WEB-INF/views/common/sidebar.jspf" %>

<div class="main-wrapper">
    <header class="top-navbar booking-top-navbar">
        <div class="booking-navbar-heading">
            <a href="<%= contextPath %>/home" class="back-link-btn">
                <span><span class="app-icon icon-arrow-left" aria-hidden="true"></span></span> Quay lại trang chủ
            </a>
            <h1 class="page-title" style="margin: 0;">Đặt sân & Bảng chọn khung giờ</h1>
        </div>
        <a href="<%= contextPath %>/profile" class="user-profile">
            <div class="profile-img"><%= user != null && user.getFullname() != null && !user.getFullname().isEmpty() ? user.getFullname().substring(0,1).toUpperCase() : "U" %></div>
            <div class="profile-name"><%= user != null ? escapeHtml(user.getFullname()) : "Người dùng" %></div>
        </a>
    </header>

    <main class="content-area">

        <div class="booking-page-layout">

            <!-- CỘT TRÁI: THÔNG TIN CHI TIẾT DANH MỤC SÂN & SỐ LƯỢNG SẢN PHẨM -->
            <div class="venue-card-details">
                <div class="venue-img-wrap">
                    <img src="<%= imgSrc %>" alt="<%= escapeHtml(field.getFieldName()) %>" onerror="this.src='<%= defaultImg %>'">
                    <span class="venue-badge <%= badgeClass %>">
                        <span><span class="app-icon icon-<%= badgeIcon %>" aria-hidden="true"></span></span> <%= badgeText %>
                    </span>
                    <span class="venue-qty-badge">
                        <span class="app-icon icon-court" aria-hidden="true"></span> Quy mô: <%= fieldQuantity %> <%= productUnitLabel %> (sản phẩm)
                    </span>
                </div>

                <h2 class="venue-title"><%= escapeHtml(field.getFieldName()) %></h2>

                <div class="venue-rating-row">

                    <strong>4.9 / 5</strong>
                    <span>•</span>
                    <span style="background: #eaf8ef; color: var(--primary-dark); padding: 3px 9px; border-radius: 6px; font-weight: 700; font-size: 11.5px;">
                        Tổng <%= fieldQuantity %> sản phẩm cho thuê
                    </span>
                </div>

                <!-- HỘP QUY MÔ SẢN PHẨM CỦA DANH MỤC SÂN -->
                <div class="inventory-highlight-box">
                    <div class="inventory-highlight-top">
                        <strong><span class="app-icon icon-box" aria-hidden="true"></span> Số lượng sản phẩm trong danh mục</strong>
                        <span class="inventory-count-pill">Còn <%= fieldQuantity %> <%= productUnitLabel %> cho thuê</span>
                    </div>
                    <p>
                        Danh mục này có <strong><%= fieldQuantity %> <%= productUnitLabel %></strong> (tương ứng <strong><%= fieldQuantity %> sản phẩm</strong>).
                        Ở mỗi khung giờ hệ thống nhận tối đa <strong><%= fieldQuantity %> đơn đặt thuê</strong>.
                        Khi cả <%= fieldQuantity %> sản phẩm trong cùng khung giờ đã có khách đặt, khung giờ đó sẽ tự động khóa.
                    </p>
                </div>

                <div class="venue-spec-list">
                    <div class="venue-spec-item">
                        <span><span class="app-icon icon-map" aria-hidden="true"></span></span>
                        <span>Địa chỉ: <strong><%= field.getAddress() != null ? escapeHtml(field.getAddress()) : "TP. Hồ Chí Minh" %></strong></span>
                    </div>
                    <div class="venue-spec-item">
                        <span><span class="app-icon icon-clock" aria-hidden="true"></span></span>
                        <span>Khung giờ mở cửa: <strong><%= openTimeStr %> - <%= closeTimeStr %></strong> hàng ngày</span>
                    </div>
                    <div class="venue-spec-item">
                        <span><span class="app-icon icon-court" aria-hidden="true"></span></span>
                        <span>Công suất phục vụ: <strong><%= fieldQuantity %> đơn đặt / 1 khung giờ</strong> (<%= fieldQuantity %> sản phẩm)</span>
                    </div>
                    <div class="venue-spec-item">
                        <span><span class="app-icon icon-wallet" aria-hidden="true"></span></span>
                        <span>Giá thuê niêm yết: <strong style="color: var(--primary); font-size: 16px;"><%= vndFormat.format(price) %> đ</strong> / giờ / 1 <%= productUnitLabel %></span>
                    </div>
                </div>

                <div style="font-size: 13.5px; color: var(--text); line-height: 1.5; margin-bottom: 12px;">
                    <strong>Giới thiệu cơ sở:</strong><br>
                    <%= field.getDescription() != null ? escapeHtml(field.getDescription()) : "Cơ sở thể thao hiện đại, phục vụ hội viên tận tình." %>
                </div>

                <div style="font-size: 13px; font-weight: 700; color: var(--dark); margin-top: 14px;">
                    Tiện ích nổi bật:
                </div>
                <div class="venue-amenities-wrap">
                    <%= amenitiesHtml %>
                </div>
            </div>

            <!-- CỘT PHẢI: BẢNG CHỌN KHUNG GIỜ, BẢNG CHỌN SẢN PHẨM & FORM ĐẶT SÂN -->
            <div class="booking-form-box">
                <div class="booking-form-header">
                    <h3><span><span class="app-icon icon-calendar" aria-hidden="true"></span></span> Bảng Chọn Khung Giờ & Đặt Sân</h3>
                    <p>Chọn ngày để xem tình trạng lấp đầy của <strong><%= fieldQuantity %> <%= productUnitLabel %></strong> theo từng khung giờ. Khung giờ đã đủ <%= fieldQuantity %>/<%= fieldQuantity %> đơn sẽ không thể bấm đặt.</p>
                </div>

                <form method="post" action="<%= contextPath %>/field-booking" id="bookingForm" class="booking-form" onsubmit="return validateBookingForm()">
                    <input type="hidden" name="csrfToken" value="<%= com.sportify.util.Csrf.token(request) %>">
                    <input type="hidden" name="fieldId" value="<%= field.getFieldId() %>">
                    <input type="hidden" name="courtNumber" id="selectedCourtNumber" value="">

                    <!-- CHỌN NGÀY -->
                    <div class="form-group">
                        <label class="form-label" for="bookingDate">1. Chọn ngày đặt sân (*)</label>
                        <input type="date" class="form-control" id="bookingDate" name="date"
                               min="<%= todayStr %>" value="<%= prefillDate %>" required onchange="onDateOrTimeChange()">
                    </div>

                    <!-- BẢNG CHỌN KHUNG GIỜ TRỰC QUAN -->
                    <div class="slot-picker-section">
                        <div class="slot-picker-header">
                            <div class="slot-picker-title">
                                <span><span class="app-icon icon-clock" aria-hidden="true"></span></span> 2. Bảng chọn khung giờ (<%= openTimeStr %> - <%= closeTimeStr %>)
                            </div>
                            <div class="slot-legend">
                                <span class="legend-item"><span class="legend-dot" style="background:#22c55e;"></span> Còn đủ <%= fieldQuantity %>/<%= fieldQuantity %></span>
                                <span class="legend-item"><span class="legend-dot" style="background:#f59e0b;"></span> Đã có người đặt</span>
                                <span class="legend-item"><span class="legend-dot" style="background:#ef4444;"></span> Đủ <%= fieldQuantity %>/<%= fieldQuantity %> đơn (Khóa)</span>
                            </div>
                        </div>
                        <p style="font-size: 12px; color: #64748b; margin-bottom: 10px;">
                            <span class="app-icon icon-info" aria-hidden="true"></span> Bấm vào một khung giờ còn trống dưới đây để chọn nhanh, hoặc điều chỉnh giờ bắt đầu - kết thúc ở mục 3.
                        </p>
                        <div id="timeSlotGrid" class="slot-grid"></div>
                    </div>

                    <!-- KHUNG GIỜ BẮT ĐẦU & KẾT THÚC -->
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label" for="bookingStartTime">3. Giờ bắt đầu (*)</label>
                            <input type="time" class="form-control" id="bookingStartTime" name="startTime"
                                   value="<%= defStartStr %>" step="1800" required onchange="onManualTimeInput()">
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="bookingEndTime">Giờ kết thúc (*)</label>
                            <input type="time" class="form-control" id="bookingEndTime" name="endTime"
                                   value="<%= defEndTimeStr %>" step="1800" required onchange="onManualTimeInput()">
                        </div>
                    </div>

                    <!-- BẢNG CHỌN SẢN PHẨM / SÂN CỤ THỂ TRONG KHUNG GIỜ -->
                    <div class="court-selector-wrap" role="group" aria-labelledby="courtSelectorLabel">
                        <div id="courtSelectorLabel" class="form-label">4. Bảng chọn sản phẩm (<%= fieldQuantity %> <%= productUnitLabel %> trong khung giờ đã chọn)</div>
                        <div id="courtProductGrid" class="court-grid"></div>
                    </div>

                    <!-- THÔNG BÁO TRẠNG THÁI KHUNG GIỜ ĐANG CHỌN -->
                    <div id="slotStatusSummary" class="slot-status-summary-banner">
                        <span id="slotStatusText">Đang kiểm tra tình trạng sân trống...</span>
                        <strong id="slotRemainingBadge">Còn <%= fieldQuantity %>/<%= fieldQuantity %> sản phẩm</strong>
                    </div>

                    <!-- CẢNH BÁO NẾU KHUNG GIỜ ĐÃ ĐỦ 4/4 ĐƠN -->
                    <div id="slotConflictBanner" class="slot-conflict-banner" role="alert">
                        <span class="app-icon icon-ban" aria-hidden="true"></span> <strong>Khung giờ này đã kín chỗ (<%= fieldQuantity %>/<%= fieldQuantity %> sản phẩm đã được đặt)!</strong><br>
                        Tất cả <%= fieldQuantity %> <%= productUnitLabel %> trong khung giờ bạn chọn đều đã có đơn đặt trùng. Vui lòng chọn khung giờ khác còn sản phẩm trống.
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label" for="bookingName">5. Họ và tên người đặt (*)</label>
                            <input type="text" class="form-control" id="bookingName" name="customerName" autocomplete="name"
                                   placeholder="Nhập họ và tên người đặt sân..." required
                                   value="<%= user != null && user.getFullname() != null ? escapeHtml(user.getFullname()) : "" %>">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="bookingPhone">Số điện thoại liên hệ (*)</label>
                            <input type="tel" class="form-control" id="bookingPhone" name="phone" autocomplete="tel" inputmode="tel"
                                   placeholder="Ví dụ: 0901234567" pattern="[0-9+ ]{8,20}" required
                                   value="<%= user != null && user.getPhone() != null ? escapeHtml(user.getPhone()) : "" %>">
                        </div>
                    </div>

                    <!-- BIÊN NHẬN TẠM TÍNH -->
                    <div class="calc-box">
                        <div class="calc-details">
                            <span class="calc-label">Đơn giá</span>
                            <strong><%= vndFormat.format(price) %> đ / giờ / 1 <%= productUnitLabel %></strong>
                            <span id="calcDurationText" class="calc-duration">Thời lượng: 1.0 giờ</span>
                        </div>
                        <div class="calc-total" aria-live="polite">
                            <span class="calc-label">Tạm tính thanh toán</span>
                            <strong class="calc-price" id="calcPriceText"><%= vndFormat.format(price) %> đ</strong>
                        </div>
                    </div>

                    <div class="booking-form-actions">
                        <a href="<%= contextPath %>/home" class="btn-secondary">
                            Hủy bỏ
                        </a>
                        <button type="submit" id="btnSubmitBooking" class="btn-submit">
                            <span class="booking-submit-label">Xác nhận đặt sân</span> <span class="app-icon icon-arrow" aria-hidden="true"></span>
                        </button>
                    </div>
                </form>
            </div>

        </div>

        <!-- BẢNG LIỆT KÊ ĐẦY ĐỦ CÁC KHUNG GIỜ ĐÃ CÓ NGƯỜI ĐẶT CỦA SÂN NÀY -->
        <section class="booked-slots-panel" id="booked-slots-list">
            <div class="booked-slots-panel-header">
                <div>
                    <h3><span class="app-icon icon-file" aria-hidden="true"></span> Danh sách các khung giờ đã có người đặt — <%= escapeHtml(field.getFieldName()) %></h3>
                    <p style="font-size: 13px; color: var(--muted); margin: 4px 0 0;">
                        Hiển thị toàn bộ các khung giờ đã có khách đặt tại cơ sở này (tối đa <strong><%= fieldQuantity %> đơn / khung giờ</strong>).
                    </p>
                </div>
                <span style="font-size: 13px; font-weight: 700; color: var(--primary); background: var(--primary-light); padding: 6px 12px; border-radius: 20px;">
                    <%= fieldBookedSlots.size() %> khung giờ có lịch đặt • Tổng <%= fieldActiveBookings.size() %> đơn
                </span>
            </div>

            <% if (fieldBookedSlots.isEmpty()) { %>
            <div class="empty-appt" style="margin: 0;">
                <span class="app-icon icon-grid" aria-hidden="true"></span> Hiện chưa có khung giờ nào được đặt tại <strong><%= escapeHtml(field.getFieldName()) %></strong>. Tất cả <%= fieldQuantity %> <%= productUnitLabel %> đều đang trống!
            </div>
            <% } else { %>
            <div class="card-framed-box" style="margin-bottom: 0;">
                <table class="bookings-table">
                    <thead>
                        <tr>
                            <th>Ngày đặt</th>
                            <th>Khung giờ</th>
                            <th>Số đơn / Tổng sản phẩm</th>
                            <th>Tình trạng khung giờ</th>
                            <th>Chi tiết các sân đã đặt trong khung giờ</th>
                            <th>Thao tác nhanh</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (BookingDB.BookedSlotSummary slot : fieldBookedSlots) {
                            String slotDateIso = slot.getStartsAt().toLocalDate().toString();
                            String slotDateStr = slot.getStartsAt().toLocalDate().format(dateFmt);
                            String slotStartStr = slot.getStartsAt().toLocalTime().format(timeFmt);
                            String slotEndStr = slot.getEndsAt().toLocalTime().format(timeFmt);
                            boolean full = slot.isFull();
                        %>
                        <tr>
                            <td><strong><%= slotDateStr %></strong></td>
                            <td>
                                <strong style="color: var(--dark); font-size: 14px;"><%= slotStartStr %> - <%= slotEndStr %></strong>
                            </td>
                            <td>
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <strong style="font-size: 14px; color: <%= full ? "#dc2626" : "#d97706" %>;">
                                        <%= slot.getBookedCount() %> / <%= slot.getTotalQuantity() %> đơn
                                    </strong>
                                    <span style="font-size: 12px; color: var(--muted);">
                                        (Còn <%= slot.getRemainingCount() %> sân)
                                    </span>
                                </div>
                            </td>
                            <td>
                                <% if (full) { %>
                                <span class="slot-pill-tag slot-pill-full"><span class="app-icon icon-lock" aria-hidden="true"></span> Đã đủ <%= slot.getTotalQuantity() %>/<%= slot.getTotalQuantity() %> sân (Hết chỗ)</span>
                                <% } else { %>
                                <span class="slot-pill-tag slot-pill-avail"><span class="app-icon icon-clock" aria-hidden="true"></span> Đã đặt <%= slot.getBookedCount() %>/<%= slot.getTotalQuantity() %> • Còn <%= slot.getRemainingCount() %> sân trống</span>
                                <% } %>
                            </td>
                            <td>
                                <div class="order-mini-chips">
                                    <% for (Booking b : slot.getBookings()) {
                                        String stBadge = "CONFIRMED".equals(b.getStatus()) || "COMPLETED".equals(b.getStatus()) ? "Đã duyệt" : "Chờ duyệt";
                                    %>
                                    <span class="order-mini-chip" title="Mã đơn #<%= b.getBookingCode() %>">
                                        <strong>Sân #<%= b.getCourtNumber() %></strong>
                                        <span>• <%= escapeHtml(b.getCustomerName()) %></span>
                                        <small style="color: #0f7036;">(<%= stBadge %>)</small>
                                    </span>
                                    <% } %>
                                </div>
                            </td>
                            <td>
                                <% if (full) { %>
                                <button type="button" class="btn-cancel-sm" disabled style="opacity: 0.65; cursor: not-allowed; background: #f1f5f9; color: #64748b; border-color: #cbd5e1;">
                                    <span class="app-icon icon-ban" aria-hidden="true"></span> Hết sân (<%= slot.getTotalQuantity() %>/<%= slot.getTotalQuantity() %>)
                                </button>
                                <% } else { %>
                                <button type="button" class="btn-book-action" style="border: none; cursor: pointer; padding: 6px 12px; font-size: 12px;"
                                        onclick="quickPickSlot('<%= slotDateIso %>', '<%= slotStartStr %>', '<%= slotEndStr %>')">
                                    <span class="app-icon icon-calendar-check" aria-hidden="true"></span> Đặt sân còn trống (<%= slot.getRemainingCount() %>)
                                </button>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </section>

    </main>
</div>

<script>
    const currentFieldPrice = <%= price %>;
    const currentFieldOpen = '<%= openTimeStr %>';
    const currentFieldClose = '<%= closeTimeStr %>';
    const currentFieldQuantity = <%= fieldQuantity %>;
    const productUnitName = '<%= escapeJs(productUnitLabel) %>';

    // Dữ liệu thực tế từ database các đơn đang giữ chỗ (PENDING, CONFIRMED, COMPLETED) của sân này
    const existingBookings = [
        <% for (int i = 0; i < fieldActiveBookings.size(); i++) {
            Booking b = fieldActiveBookings.get(i);
            if (b.getStartsAt() == null || b.getEndsAt() == null) continue;
        %>
        {
            id: <%= b.getBookingId() %>,
            code: "<%= escapeJs(b.getBookingCode()) %>",
            date: "<%= b.getStartsAt().toLocalDate().toString() %>",
            start: "<%= b.getStartsAt().toLocalTime().format(timeFmt) %>",
            end: "<%= b.getEndsAt().toLocalTime().format(timeFmt) %>",
            courtNumber: <%= b.getCourtNumber() %>,
            customerName: "<%= escapeJs(b.getCustomerName()) %>",
            status: "<%= escapeJs(b.getStatus()) %>"
        }<%= (i < fieldActiveBookings.size() - 1) ? "," : "" %>
        <% } %>
    ];

</script>
<script src="<%= contextPath %>/assets/js/pages/booking.js?v=<%= bookingAssetVersion %>"></script>

</body>
</html>
