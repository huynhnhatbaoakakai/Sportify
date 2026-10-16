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
    String badgeIcon = "🏟️";
    String productUnitLabel = "sân";
    String defaultImg = contextPath + "/assets/images/basketball.jpg";
    String amenitiesHtml = "";

    if ("GYM".equals(st)) {
        badgeClass = "badge-gym";
        badgeText = "Phòng Gym & Fitness";
        badgeIcon = "🏋️";
        productUnitLabel = "khu tập / phòng";
        defaultImg = contextPath + "/assets/images/gymfitzone.jfif";
        amenitiesHtml = "<span class='amenity-pill'>🏋️ Full thiết bị tập</span><span class='amenity-pill'>❄️ Máy lạnh 24/7</span><span class='amenity-pill'>🚿 Phòng tắm nóng lạnh</span><span class='amenity-pill'>📶 Wifi miễn phí</span>";
    } else if ("BASKETBALL".equals(st)) {
        badgeClass = "badge-basketball";
        badgeText = "Sân Bóng Rổ";
        badgeIcon = "🏀";
        productUnitLabel = "sân bóng rổ";
        defaultImg = contextPath + "/assets/images/basketballcourt1.jpg";
        amenitiesHtml = "<span class='amenity-pill'>🏀 Sàn gỗ chuẩn FIBA</span><span class='amenity-pill'>💡 Đèn LED chiếu sáng</span><span class='amenity-pill'>🅿️ Bãi giữ xe rộng</span><span class='amenity-pill'>🥤 Nước uống miễn phí</span>";
    } else if ("SWIMMING".equals(st)) {
        badgeClass = "badge-swimming";
        badgeText = "Hồ Bơi Thể Thao";
        badgeIcon = "🏊";
        productUnitLabel = "làn bơi tiêu chuẩn";
        defaultImg = contextPath + "/assets/images/swimmingpoolaqua.jfif";
        amenitiesHtml = "<span class='amenity-pill'>🏊 Làn bơi Olympic</span><span class='amenity-pill'>🌡️ Nước ấm 4 mùa</span><span class='amenity-pill'>🛟 Cứu hộ chuyên nghiệp</span><span class='amenity-pill'>🚿 Phòng thay đồ VIP</span>";
    } else if ("PICKLEBALL".equals(st)) {
        badgeClass = "badge-pickleball";
        badgeText = "Sân Pickleball";
        badgeIcon = "🏓";
        productUnitLabel = "sân pickleball";
        defaultImg = contextPath + "/assets/images/greenpickleballcourt.jfif";
        amenitiesHtml = "<span class='amenity-pill'>🏓 Mặt sân chuẩn thi đấu</span><span class='amenity-pill'>💡 Đèn chơi ban đêm</span><span class='amenity-pill'>🅿️ Đỗ xe ô tô</span><span class='amenity-pill'>🥤 Quầy căng tin</span>";
    } else if ("TABLE_TENNIS".equals(st)) {
        badgeClass = "badge-pickleball";
        badgeText = "Sân Bóng Bàn";
        badgeIcon = "🏓";
        productUnitLabel = "sân bóng bàn";
        defaultImg = contextPath + "/assets/images/pickleball.jpg";
        amenitiesHtml = "<span class='amenity-pill'>🏓 Bàn chuẩn ITTF</span><span class='amenity-pill'>❄️ Điều hòa mát mẻ</span><span class='amenity-pill'>💡 Ánh sáng chống lóa</span><span class='amenity-pill'>🏓 Có sẵn vợt & bóng</span>";
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
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Material+Symbols+Rounded:FILL@0..1&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/pages/home.css?v=<%= System.currentTimeMillis() %>">
    <style>
        .booking-page-layout {
            display: grid;
            grid-template-columns: 1fr 1.35fr;
            gap: 24px;
            align-items: start;
            margin-top: 12px;
        }
        .venue-card-details {
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 22px;
            box-shadow: 0 8px 24px rgba(15, 23, 42, 0.04);
        }
        .venue-img-wrap {
            position: relative;
            width: 100%;
            height: 210px;
            border-radius: 14px;
            overflow: hidden;
            margin-bottom: 18px;
        }
        .venue-img-wrap img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }
        .venue-badge {
            position: absolute;
            top: 12px;
            left: 12px;
            padding: 6px 13px;
            border-radius: 20px;
            font-size: 11.5px;
            font-weight: 700;
            color: #fff;
            backdrop-filter: blur(4px);
            box-shadow: 0 2px 8px rgba(0,0,0,0.25);
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        .venue-qty-badge {
            position: absolute;
            bottom: 12px;
            right: 12px;
            padding: 6px 12px;
            border-radius: 10px;
            font-size: 12px;
            font-weight: 800;
            background: rgba(15, 23, 42, 0.85);
            color: #4ade80;
            backdrop-filter: blur(4px);
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .venue-title {
            font-size: 21px;
            font-weight: 800;
            color: var(--dark);
            margin-bottom: 8px;
        }
        .venue-rating-row {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 8px;
            font-size: 13px;
            color: #64748b;
            margin-bottom: 16px;
        }
        .inventory-highlight-box {
            background: linear-gradient(135deg, #f0fdf4, #dcfce7);
            border: 1px solid #86efac;
            border-radius: 14px;
            padding: 14px 16px;
            margin-bottom: 16px;
        }
        .inventory-highlight-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            margin-bottom: 6px;
        }
        .inventory-highlight-top strong {
            color: #166534;
            font-size: 14px;
            font-weight: 800;
        }
        .inventory-count-pill {
            background: #15803d;
            color: #fff;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 800;
        }
        .inventory-highlight-box p {
            margin: 0;
            font-size: 12.5px;
            color: #15803d;
            line-height: 1.45;
        }
        .venue-spec-list {
            background: #f8fafc;
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 14px 16px;
            margin-bottom: 16px;
            display: flex;
            flex-direction: column;
            gap: 9px;
            font-size: 13px;
        }
        .venue-spec-item {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #334155;
        }
        .venue-amenities-wrap {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 10px;
        }
        .amenity-pill {
            background: #f1f5f9;
            color: #475569;
            padding: 5px 10px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 600;
        }
        .booking-form-box {
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 26px 28px;
            box-shadow: 0 8px 24px rgba(15, 23, 42, 0.04);
        }
        .booking-form-header {
            margin-bottom: 20px;
            padding-bottom: 16px;
            border-bottom: 1px solid var(--border);
        }
        .booking-form-header h3 {
            font-size: 19px;
            font-weight: 800;
            color: var(--dark);
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 6px;
        }
        .booking-form-header p {
            font-size: 13px;
            color: var(--muted);
            margin: 0;
        }
        .back-link-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 14px;
            background: #f1f5f9;
            border: 1px solid var(--border);
            border-radius: 10px;
            font-size: 13px;
            font-weight: 600;
            color: var(--dark);
            text-decoration: none;
            transition: 0.2s;
        }
        .back-link-btn:hover {
            background: #e2e8f0;
            color: var(--primary-dark);
        }

        /* BẢNG CHỌN KHUNG GIỜ (TIME SLOT PICKER) */
        .slot-picker-section {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            padding: 16px;
            margin-bottom: 18px;
        }
        .slot-picker-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 12px;
        }
        .slot-picker-title {
            font-size: 13.5px;
            font-weight: 800;
            color: #1e293b;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .slot-legend {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
            font-size: 11.5px;
            color: #475569;
            font-weight: 600;
        }
        .legend-item {
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        .legend-dot {
            width: 10px;
            height: 10px;
            border-radius: 3px;
            display: inline-block;
        }
        .slot-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(132px, 1fr));
            gap: 10px;
        }
        .slot-btn {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            justify-content: space-between;
            padding: 10px 12px;
            border-radius: 11px;
            border: 1.5px solid #cbd5e1;
            background: #ffffff;
            cursor: pointer;
            text-align: left;
            transition: all 0.18s ease;
            position: relative;
        }
        .slot-btn:hover:not(:disabled) {
            border-color: var(--primary);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(21, 148, 71, 0.14);
        }
        .slot-btn.slot-available {
            border-color: #bbf7d0;
            background: #ffffff;
        }
        .slot-btn.slot-partial {
            border-color: #fde68a;
            background: #fffbeb;
        }
        .slot-btn.slot-selected {
            border-color: var(--primary) !important;
            background: #dcfce7 !important;
            box-shadow: 0 0 0 3px rgba(21, 148, 71, 0.18);
        }
        .slot-btn.slot-full {
            border-color: #fecaca;
            background: #fef2f2;
            cursor: not-allowed;
            opacity: 0.85;
        }
        .slot-btn.slot-past {
            border-color: #e2e8f0;
            background: #f1f5f9;
            cursor: not-allowed;
            opacity: 0.6;
        }
        .slot-time-text {
            font-size: 13px;
            font-weight: 800;
            color: #0f172a;
            margin-bottom: 4px;
        }
        .slot-btn.slot-full .slot-time-text {
            color: #991b1b;
            text-decoration: line-through;
        }
        .slot-cap-text {
            font-size: 11px;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: space-between;
            width: 100%;
        }
        .slot-available .slot-cap-text { color: #15803d; }
        .slot-partial .slot-cap-text { color: #b45309; }
        .slot-full .slot-cap-text { color: #dc2626; }
        .slot-past .slot-cap-text { color: #64748b; }
        .slot-bar {
            width: 100%;
            height: 4px;
            background: #e2e8f0;
            border-radius: 4px;
            overflow: hidden;
            margin-top: 6px;
        }
        .slot-bar-fill {
            height: 100%;
            border-radius: 4px;
            transition: width 0.2s;
        }

        /* BẢNG CHỌN SẢN PHẨM / SÂN CỤ THỂ (COURT SELECTOR) */
        .court-selector-wrap {
            margin-bottom: 18px;
        }
        .court-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(125px, 1fr));
            gap: 10px;
            margin-top: 8px;
        }
        .court-card-btn {
            padding: 10px 12px;
            border-radius: 11px;
            border: 1.5px solid #cbd5e1;
            background: #fff;
            cursor: pointer;
            display: flex;
            flex-direction: column;
            gap: 3px;
            text-align: left;
            transition: 0.18s;
        }
        .court-card-btn:hover:not(:disabled) {
            border-color: var(--primary);
            background: #f0fdf4;
        }
        .court-card-btn.active {
            border-color: var(--primary);
            background: #dcfce7;
            box-shadow: 0 0 0 2px rgba(21, 148, 71, 0.18);
        }
        .court-card-btn:disabled {
            background: #fef2f2;
            border-color: #fecaca;
            cursor: not-allowed;
            opacity: 0.85;
        }
        .court-card-btn strong {
            font-size: 13px;
            color: #0f172a;
        }
        .court-card-btn:disabled strong {
            color: #991b1b;
        }
        .court-card-btn span {
            font-size: 11px;
            font-weight: 700;
        }

        /* CẢNH BÁO KHI KHUNG GIỜ ĐỦ 4/4 ĐƠN */
        .slot-conflict-banner {
            display: none;
            background: #fef2f2;
            border: 1.5px solid #f87171;
            color: #991b1b;
            padding: 13px 16px;
            border-radius: 12px;
            margin-bottom: 16px;
            font-size: 13px;
            font-weight: 600;
            line-height: 1.45;
        }
        .slot-status-summary-banner {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            color: #166534;
            padding: 12px 15px;
            border-radius: 12px;
            margin-bottom: 16px;
            font-size: 13px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 8px;
        }
        .btn-submit:disabled {
            background: #94a3b8 !important;
            border-color: #94a3b8 !important;
            color: #f8fafc !important;
            cursor: not-allowed !important;
            box-shadow: none !important;
            transform: none !important;
        }

        /* DANH SÁCH KHUNG GIỜ ĐÃ CÓ NGƯỜI ĐẶT */
        .booked-slots-panel {
            margin-top: 26px;
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 24px 26px;
            box-shadow: 0 8px 24px rgba(15, 23, 42, 0.04);
        }
        .booked-slots-panel-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 16px;
        }
        .booked-slots-panel-header h3 {
            font-size: 17px;
            font-weight: 800;
            color: var(--dark);
            margin: 0;
        }
        .slot-pill-tag {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11.5px;
            font-weight: 700;
        }
        .slot-pill-full {
            background: #fee2e2;
            color: #b91c1c;
            border: 1px solid #fecaca;
        }
        .slot-pill-avail {
            background: #fef3c7;
            color: #b45309;
            border: 1px solid #fde68a;
        }
        .order-mini-chips {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
        }
        .order-mini-chip {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 9px;
            border-radius: 8px;
            background: #f1f5f9;
            border: 1px solid #e2e8f0;
            font-size: 11.5px;
            color: #334155;
            font-weight: 600;
        }
        @media (max-width: 960px) {
            .booking-page-layout {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>

<% String activeMenu = "home"; %>
<%@ include file="/WEB-INF/views/common/sidebar.jspf" %>

<div class="main-wrapper">
    <header class="top-navbar">
        <div style="display: flex; align-items: center; gap: 14px;">
            <a href="<%= contextPath %>/home" class="back-link-btn">
                <span>←</span> Quay lại trang chủ
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
                        <span><%= badgeIcon %></span> <%= badgeText %>
                    </span>
                    <span class="venue-qty-badge">
                        🏟️ Quy mô: <%= fieldQuantity %> <%= productUnitLabel %> (sản phẩm)
                    </span>
                </div>

                <h2 class="venue-title"><%= escapeHtml(field.getFieldName()) %></h2>

                <div class="venue-rating-row">
                    <span style="color: #f59e0b; font-weight: 700;">★★★★★</span>
                    <strong>4.9 / 5</strong>
                    <span>•</span>
                    <span style="background: #eaf8ef; color: var(--primary-dark); padding: 3px 9px; border-radius: 6px; font-weight: 700; font-size: 11.5px;">
                        Tổng <%= fieldQuantity %> sản phẩm cho thuê
                    </span>
                </div>

                <!-- HỘP QUY MÔ SẢN PHẨM CỦA DANH MỤC SÂN -->
                <div class="inventory-highlight-box">
                    <div class="inventory-highlight-top">
                        <strong>📦 Số lượng sản phẩm trong danh mục</strong>
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
                        <span>📍</span>
                        <span>Địa chỉ: <strong><%= field.getAddress() != null ? escapeHtml(field.getAddress()) : "TP. Hồ Chí Minh" %></strong></span>
                    </div>
                    <div class="venue-spec-item">
                        <span>🕒</span>
                        <span>Khung giờ mở cửa: <strong><%= openTimeStr %> - <%= closeTimeStr %></strong> hàng ngày</span>
                    </div>
                    <div class="venue-spec-item">
                        <span>🏟️</span>
                        <span>Công suất phục vụ: <strong><%= fieldQuantity %> đơn đặt / 1 khung giờ</strong> (<%= fieldQuantity %> sản phẩm)</span>
                    </div>
                    <div class="venue-spec-item">
                        <span>💰</span>
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
                    <h3><span>📅</span> Bảng Chọn Khung Giờ & Đặt Sân</h3>
                    <p>Chọn ngày để xem tình trạng lấp đầy của <strong><%= fieldQuantity %> <%= productUnitLabel %></strong> theo từng khung giờ. Khung giờ đã đủ <%= fieldQuantity %>/<%= fieldQuantity %> đơn sẽ không thể bấm đặt.</p>
                </div>

                <form method="post" action="<%= contextPath %>/field-booking" id="bookingForm" onsubmit="return validateBookingForm()">
                    <input type="hidden" name="fieldId" value="<%= field.getFieldId() %>">
                    <input type="hidden" name="courtNumber" id="selectedCourtNumber" value="">

                    <!-- CHỌN NGÀY -->
                    <div class="form-group" style="margin-bottom: 16px;">
                        <label class="form-label" for="bookingDate">1. Chọn ngày đặt sân (*)</label>
                        <input type="date" class="form-control" id="bookingDate" name="date"
                               min="<%= todayStr %>" value="<%= prefillDate %>" required onchange="onDateOrTimeChange()">
                    </div>

                    <!-- BẢNG CHỌN KHUNG GIỜ TRỰC QUAN -->
                    <div class="slot-picker-section">
                        <div class="slot-picker-header">
                            <div class="slot-picker-title">
                                <span>⏰</span> 2. Bảng chọn khung giờ (<%= openTimeStr %> - <%= closeTimeStr %>)
                            </div>
                            <div class="slot-legend">
                                <span class="legend-item"><span class="legend-dot" style="background:#22c55e;"></span> Còn đủ <%= fieldQuantity %>/<%= fieldQuantity %></span>
                                <span class="legend-item"><span class="legend-dot" style="background:#f59e0b;"></span> Đã có người đặt</span>
                                <span class="legend-item"><span class="legend-dot" style="background:#ef4444;"></span> Đủ <%= fieldQuantity %>/<%= fieldQuantity %> đơn (Khóa)</span>
                            </div>
                        </div>
                        <p style="font-size: 12px; color: #64748b; margin-bottom: 10px;">
                            💡 Bấm vào một khung giờ còn trống dưới đây để chọn nhanh, hoặc điều chỉnh giờ bắt đầu - kết thúc ở mục 3.
                        </p>
                        <div id="timeSlotGrid" class="slot-grid"></div>
                    </div>

                    <!-- KHUNG GIỜ BẮT ĐẦU & KẾT THÚC -->
                    <div class="form-row" style="margin-bottom: 14px;">
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
                    <div class="court-selector-wrap">
                        <label class="form-label">4. Bảng chọn sản phẩm (<%= fieldQuantity %> <%= productUnitLabel %> trong khung giờ đã chọn)</label>
                        <div id="courtProductGrid" class="court-grid"></div>
                    </div>

                    <!-- THÔNG BÁO TRẠNG THÁI KHUNG GIỜ ĐANG CHỌN -->
                    <div id="slotStatusSummary" class="slot-status-summary-banner">
                        <span id="slotStatusText">Đang kiểm tra tình trạng sân trống...</span>
                        <strong id="slotRemainingBadge">Còn <%= fieldQuantity %>/<%= fieldQuantity %> sản phẩm</strong>
                    </div>

                    <!-- CẢNH BÁO NẾU KHUNG GIỜ ĐÃ ĐỦ 4/4 ĐƠN -->
                    <div id="slotConflictBanner" class="slot-conflict-banner" role="alert">
                        🚫 <strong>Khung giờ này đã kín chỗ (<%= fieldQuantity %>/<%= fieldQuantity %> sản phẩm đã được đặt)!</strong><br>
                        Tất cả <%= fieldQuantity %> <%= productUnitLabel %> trong khung giờ bạn chọn đều đã có đơn đặt trùng. Vui lòng chọn khung giờ khác còn sản phẩm trống.
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label" for="bookingName">5. Họ và tên người đặt (*)</label>
                            <input type="text" class="form-control" id="bookingName" name="customerName"
                                   placeholder="Nhập họ và tên người đặt sân..." required
                                   value="<%= user != null && user.getFullname() != null ? escapeHtml(user.getFullname()) : "" %>">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="bookingPhone">Số điện thoại liên hệ (*)</label>
                            <input type="tel" class="form-control" id="bookingPhone" name="phone"
                                   placeholder="Ví dụ: 0901234567" pattern="[0-9+ ]{8,20}" required
                                   value="<%= user != null && user.getPhone() != null ? escapeHtml(user.getPhone()) : "" %>">
                        </div>
                    </div>

                    <!-- BIÊN NHẬN TẠM TÍNH -->
                    <div class="calc-box">
                        <div>
                            <div style="font-size: 13px; color: var(--muted); margin-bottom: 2px;">
                                Đơn giá: <strong><%= vndFormat.format(price) %> đ / giờ / 1 <%= productUnitLabel %></strong>
                            </div>
                            <small id="calcDurationText" style="color: var(--muted); font-size: 12.5px;">Thời lượng: 1.0 giờ</small>
                        </div>
                        <div style="text-align: right;">
                            <div style="font-size: 12px; color: var(--muted);">Tạm tính thanh toán:</div>
                            <div class="calc-price" id="calcPriceText"><%= vndFormat.format(price) %> đ</div>
                        </div>
                    </div>

                    <div style="display: flex; gap: 12px; margin-top: 20px;">
                        <a href="<%= contextPath %>/home" class="btn-secondary" style="text-decoration: none; text-align: center; flex: 1; display: inline-flex; align-items: center; justify-content: center;">
                            Hủy bỏ
                        </a>
                        <button type="submit" id="btnSubmitBooking" class="btn-submit" style="flex: 2; font-size: 14px;">
                            Xác nhận đặt sân ➔
                        </button>
                    </div>
                </form>
            </div>

        </div>

        <!-- BẢNG LIỆT KÊ ĐẦY ĐỦ CÁC KHUNG GIỜ ĐÃ CÓ NGƯỜI ĐẶT CỦA SÂN NÀY -->
        <section class="booked-slots-panel" id="booked-slots-list">
            <div class="booked-slots-panel-header">
                <div>
                    <h3>📋 Danh sách các khung giờ đã có người đặt — <%= escapeHtml(field.getFieldName()) %></h3>
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
                ✨ Hiện chưa có khung giờ nào được đặt tại <strong><%= escapeHtml(field.getFieldName()) %></strong>. Tất cả <%= fieldQuantity %> <%= productUnitLabel %> đều đang trống!
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
                                <span class="slot-pill-tag slot-pill-full">🔒 Đã đủ <%= slot.getTotalQuantity() %>/<%= slot.getTotalQuantity() %> sân (Hết chỗ)</span>
                                <% } else { %>
                                <span class="slot-pill-tag slot-pill-avail">⏳ Đã đặt <%= slot.getBookedCount() %>/<%= slot.getTotalQuantity() %> • Còn <%= slot.getRemainingCount() %> sân trống</span>
                                <% } %>
                            </td>
                            <td>
                                <div class="order-mini-chips">
                                    <% for (Booking b : slot.getBookings()) {
                                        String stBadge = "CONFIRMED".equals(b.getStatus()) || "COMPLETED".equals(b.getStatus()) ? "✅ Đã duyệt" : "⏳ Chờ duyệt";
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
                                    🚫 Hết sân (<%= slot.getTotalQuantity() %>/<%= slot.getTotalQuantity() %>)
                                </button>
                                <% } else { %>
                                <button type="button" class="btn-book-action" style="border: none; cursor: pointer; padding: 6px 12px; font-size: 12px;"
                                        onclick="quickPickSlot('<%= slotDateIso %>', '<%= slotStartStr %>', '<%= slotEndStr %>')">
                                    ⚡ Đặt sân còn trống (<%= slot.getRemainingCount() %>)
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

    function timeToMinutes(t) {
        if (!t || !t.includes(':')) return 0;
        const parts = t.split(':').map(Number);
        return parts[0] * 60 + parts[1];
    }

    function minutesToTime(m) {
        const hh = String(Math.floor(m / 60)).padStart(2, '0');
        const mm = String(m % 60).padStart(2, '0');
        return hh + ':' + mm;
    }

    function getOverlappingBookings(dateStr, startMin, endMin) {
        return existingBookings.filter(b => {
            if (b.date !== dateStr) return false;
            const bStart = timeToMinutes(b.start);
            const bEnd = timeToMinutes(b.end);
            return bStart < endMin && bEnd > startMin;
        });
    }

    function getPeakBookedCount(dateStr, startMin, endMin) {
        const overlaps = getOverlappingBookings(dateStr, startMin, endMin);
        if (overlaps.length === 0) return 0;
        let maxCount = overlaps.length;
        for (let t = startMin; t < endMin; t += 30) {
            const stepEnd = Math.min(t + 30, endMin);
            let stepCount = 0;
            overlaps.forEach(b => {
                if (timeToMinutes(b.start) < stepEnd && timeToMinutes(b.end) > t) {
                    stepCount++;
                }
            });
            if (stepCount > maxCount) maxCount = stepCount;
        }
        return maxCount;
    }

    function getUsedCourtMap(dateStr, startMin, endMin) {
        const overlaps = getOverlappingBookings(dateStr, startMin, endMin);
        const usedMap = {};
        overlaps.forEach(b => {
            let c = b.courtNumber || 1;
            if (c >= 1 && c <= currentFieldQuantity && !usedMap[c]) {
                usedMap[c] = b;
            } else {
                for (let fallback = 1; fallback <= currentFieldQuantity; fallback++) {
                    if (!usedMap[fallback]) {
                        usedMap[fallback] = b;
                        break;
                    }
                }
            }
        });
        return usedMap;
    }

    function renderTimeSlotGrid() {
        const grid = document.getElementById('timeSlotGrid');
        const dateStr = document.getElementById('bookingDate').value;
        const selectedStartMin = timeToMinutes(document.getElementById('bookingStartTime').value);
        const selectedEndMin = timeToMinutes(document.getElementById('bookingEndTime').value);

        const openMin = timeToMinutes(currentFieldOpen);
        const closeMin = timeToMinutes(currentFieldClose);

        const now = new Date();
        const todayIso = now.getFullYear() + '-' + String(now.getMonth() + 1).padStart(2, '0') + '-' + String(now.getDate()).padStart(2, '0');
        const nowMin = now.getHours() * 60 + now.getMinutes();

        let html = '';
        for (let m = openMin; m + 60 <= closeMin; m += 60) {
            const slotStart = m;
            const slotEnd = m + 60;
            const startLabel = minutesToTime(slotStart);
            const endLabel = minutesToTime(slotEnd);

            const overlaps = getOverlappingBookings(dateStr, slotStart, slotEnd);
            const bookedCount = Math.min(currentFieldQuantity, overlaps.length);
            const remaining = Math.max(0, currentFieldQuantity - bookedCount);
            const isFull = overlaps.length >= currentFieldQuantity;
            const isPast = (dateStr === todayIso && slotStart <= nowMin);
            const isSelected = (selectedStartMin <= slotStart && selectedEndMin >= slotEnd && selectedEndMin > selectedStartMin);

            let stateClass = 'slot-available';
            let statusLabel = 'Còn ' + remaining + '/' + currentFieldQuantity + ' sân';
            let barColor = '#22c55e';

            if (isPast) {
                stateClass = 'slot-past';
                statusLabel = 'Đã qua giờ';
                barColor = '#94a3b8';
            } else if (isFull) {
                stateClass = 'slot-full';
                statusLabel = '🔒 Đủ ' + currentFieldQuantity + '/' + currentFieldQuantity + ' (Hết)';
                barColor = '#ef4444';
            } else if (bookedCount > 0) {
                stateClass = 'slot-partial';
                statusLabel = 'Đã đặt ' + bookedCount + '/' + currentFieldQuantity + ' • Còn ' + remaining;
                barColor = '#f59e0b';
            }

            if (isSelected && !isFull && !isPast) {
                stateClass += ' slot-selected';
            }

            const pct = Math.min(100, Math.round((bookedCount / currentFieldQuantity) * 100));
            const disabledAttr = (isFull || isPast) ? 'disabled' : '';

            html += '<button type="button" class="slot-btn ' + stateClass + '" ' + disabledAttr +
                    ' onclick="selectSlotFromGrid(\'' + startLabel + '\', \'' + endLabel + '\')">' +
                    '<div class="slot-time-text">' + startLabel + ' - ' + endLabel + '</div>' +
                    '<div class="slot-cap-text"><span>' + statusLabel + '</span></div>' +
                    '<div class="slot-bar"><div class="slot-bar-fill" style="width:' + pct + '%; background:' + barColor + ';"></div></div>' +
                    '</button>';
        }
        grid.innerHTML = html;
    }

    function selectSlotFromGrid(startStr, endStr) {
        document.getElementById('bookingStartTime').value = startStr;
        document.getElementById('bookingEndTime').value = endStr;
        onDateOrTimeChange();
    }

    function quickPickSlot(dateStr, startStr, endStr) {
        document.getElementById('bookingDate').value = dateStr;
        document.getElementById('bookingStartTime').value = startStr;
        document.getElementById('bookingEndTime').value = endStr;
        onDateOrTimeChange();
        document.getElementById('bookingForm').scrollIntoView({ behavior: 'smooth', block: 'start' });
    }

    function selectCourtNumber(courtNo) {
        const hiddenInput = document.getElementById('selectedCourtNumber');
        hiddenInput.value = courtNo ? String(courtNo) : '';
        renderCourtSelectorAndValidate();
    }

    function renderCourtSelectorAndValidate() {
        const dateStr = document.getElementById('bookingDate').value;
        const startVal = document.getElementById('bookingStartTime').value;
        const endVal = document.getElementById('bookingEndTime').value;
        const startMin = timeToMinutes(startVal);
        const endMin = timeToMinutes(endVal);

        const courtGrid = document.getElementById('courtProductGrid');
        const hiddenCourt = document.getElementById('selectedCourtNumber');
        const conflictBanner = document.getElementById('slotConflictBanner');
        const summaryBanner = document.getElementById('slotStatusSummary');
        const statusText = document.getElementById('slotStatusText');
        const remainingBadge = document.getElementById('slotRemainingBadge');
        const submitBtn = document.getElementById('btnSubmitBooking');

        if (endMin <= startMin) {
            courtGrid.innerHTML = '<div style="grid-column: 1/-1; font-size: 12.5px; color: #dc2626;">Vui lòng chọn giờ kết thúc sau giờ bắt đầu.</div>';
            submitBtn.disabled = true;
            submitBtn.innerText = 'Khung giờ chưa hợp lệ';
            return;
        }

        const usedMap = getUsedCourtMap(dateStr, startMin, endMin);
        const usedCount = Object.keys(usedMap).length;
        const peakCount = getPeakBookedCount(dateStr, startMin, endMin);
        const effectiveBooked = Math.min(currentFieldQuantity, Math.max(usedCount, peakCount));
        const remaining = Math.max(0, currentFieldQuantity - effectiveBooked);
        const isAllFull = effectiveBooked >= currentFieldQuantity;

        // Nếu sân đang chọn bị trùng với đơn đã đặt thì tự động chuyển sang sân trống đầu tiên
        let currentSelected = parseInt(hiddenCourt.value, 10);
        if (isNaN(currentSelected) || currentSelected < 1 || currentSelected > currentFieldQuantity || usedMap[currentSelected]) {
            currentSelected = 0;
            for (let c = 1; c <= currentFieldQuantity; c++) {
                if (!usedMap[c]) {
                    currentSelected = c;
                    break;
                }
            }
            hiddenCourt.value = currentSelected > 0 ? String(currentSelected) : '';
        }

        let courtHtml = '';
        for (let c = 1; c <= currentFieldQuantity; c++) {
            const bookedOrder = usedMap[c];
            const isBusy = Boolean(bookedOrder) || isAllFull;
            const isSelected = (!isBusy && currentSelected === c);
            if (isBusy) {
                const who = bookedOrder ? bookedOrder.customerName : 'Đã kín';
                courtHtml += '<button type="button" class="court-card-btn" disabled>' +
                        '<strong>🔒 Sân #' + c + '</strong>' +
                        '<span style="color:#dc2626;">Đã đặt (' + who + ')</span>' +
                        '</button>';
            } else {
                courtHtml += '<button type="button" class="court-card-btn ' + (isSelected ? 'active' : '') + '" onclick="selectCourtNumber(' + c + ')">' +
                        '<strong>' + (isSelected ? '✅ ' : '🏟️ ') + 'Sân #' + c + '</strong>' +
                        '<span style="color:#15803d;">' + (isSelected ? 'Đang chọn đặt' : 'Còn trống • Bấm chọn') + '</span>' +
                        '</button>';
            }
        }
        courtGrid.innerHTML = courtHtml;

        if (isAllFull) {
            conflictBanner.style.display = 'block';
            summaryBanner.style.display = 'none';
            submitBtn.disabled = true;
            submitBtn.innerText = '🚫 Đã đủ ' + currentFieldQuantity + '/' + currentFieldQuantity + ' đơn - Không thể bấm đặt sân';
        } else {
            conflictBanner.style.display = 'none';
            summaryBanner.style.display = 'flex';
            statusText.innerHTML = 'Khung giờ <strong>' + startVal + ' - ' + endVal + '</strong> ngày <strong>' + dateStr + '</strong>: đã có <strong>' + effectiveBooked + '/' + currentFieldQuantity + '</strong> đơn đặt.';
            remainingBadge.innerText = 'Còn ' + remaining + '/' + currentFieldQuantity + ' ' + productUnitName + ' trống';
            submitBtn.disabled = false;
            submitBtn.innerText = 'Xác nhận đặt Sân #' + (currentSelected || 1) + ' (' + startVal + ' - ' + endVal + ') ➔';
        }
    }

    function calculateEstimate() {
        const startVal = document.getElementById('bookingStartTime').value;
        const endVal = document.getElementById('bookingEndTime').value;
        if (!startVal || !endVal) return;

        const startMinutes = timeToMinutes(startVal);
        const endMinutes = timeToMinutes(endVal);

        const diffMinutes = endMinutes - startMinutes;
        const durTextEl = document.getElementById('calcDurationText');
        const priceTextEl = document.getElementById('calcPriceText');

        if (diffMinutes <= 0) {
            durTextEl.innerText = 'Giờ kết thúc phải sau giờ bắt đầu';
            priceTextEl.innerText = '0 đ';
            return;
        }

        const hours = diffMinutes / 60;
        const total = Math.round(hours * currentFieldPrice);
        durTextEl.innerText = 'Thời lượng: ' + hours.toFixed(1) + ' giờ';
        priceTextEl.innerText = total.toLocaleString('vi-VN') + ' đ';
    }

    function onManualTimeInput() {
        calculateEstimate();
        renderTimeSlotGrid();
        renderCourtSelectorAndValidate();
    }

    function onDateOrTimeChange() {
        calculateEstimate();
        renderTimeSlotGrid();
        renderCourtSelectorAndValidate();
    }

    function validateBookingForm() {
        const dateStr = document.getElementById('bookingDate').value;
        const startVal = document.getElementById('bookingStartTime').value;
        const endVal = document.getElementById('bookingEndTime').value;
        if (!startVal || !endVal) {
            alert('Vui lòng chọn giờ bắt đầu và giờ kết thúc.');
            return false;
        }

        const startMinutes = timeToMinutes(startVal);
        const endMinutes = timeToMinutes(endVal);

        if (endMinutes <= startMinutes) {
            alert('Giờ kết thúc phải sau giờ bắt đầu.');
            return false;
        }

        const openMinutes = timeToMinutes(currentFieldOpen);
        const closeMinutes = timeToMinutes(currentFieldClose);

        if (startMinutes < openMinutes || endMinutes > closeMinutes) {
            alert('Khung giờ đặt phải nằm trong giờ mở cửa của sân (' + currentFieldOpen + ' - ' + currentFieldClose + ').');
            return false;
        }

        const usedMap = getUsedCourtMap(dateStr, startMinutes, endMinutes);
        const peakCount = getPeakBookedCount(dateStr, startMinutes, endMinutes);
        if (Object.keys(usedMap).length >= currentFieldQuantity || peakCount >= currentFieldQuantity) {
            alert('Khung giờ này đã nhận đủ ' + currentFieldQuantity + '/' + currentFieldQuantity + ' đơn đặt sân. Không thể đặt thêm!');
            return false;
        }

        return true;
    }

    // Khởi tạo bảng chọn khung giờ & bảng chọn sản phẩm ngay khi tải trang
    onDateOrTimeChange();
</script>

</body>
</html>
