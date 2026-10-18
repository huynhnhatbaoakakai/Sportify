<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.sportify.model.User" %>
<%@ page import="com.sportify.model.Appointment" %>
<%@ page import="com.sportify.model.SportField" %>
<%@ page import="com.sportify.model.Booking" %>
<%@ page import="com.sportify.data.BookingDB" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%-- Controller: com.sportify.controller.home.HomeServlet (GET /home) --%>
<%
    String contextPath = request.getContextPath();
    long assetVer = System.currentTimeMillis();
    User user = (User) session.getAttribute("user");

    int upcomingCount = request.getAttribute("upcomingCount") != null ? (Integer) request.getAttribute("upcomingCount") : 0;
    int trainingHours = request.getAttribute("trainingHours") != null ? (Integer) request.getAttribute("trainingHours") : 0;
    @SuppressWarnings("unchecked")
    List<Appointment> upcomingAppts = (List<Appointment>) request.getAttribute("upcomingAppts");
    if (upcomingAppts == null) upcomingAppts = java.util.Collections.emptyList();

    @SuppressWarnings("unchecked")
    List<SportField> activeFields = (List<SportField>) request.getAttribute("activeFields");
    if (activeFields == null) activeFields = java.util.Collections.emptyList();

    @SuppressWarnings("unchecked")
    List<Booking> customerBookings = (List<Booking>) request.getAttribute("customerBookings");
    if (customerBookings == null) customerBookings = java.util.Collections.emptyList();

    @SuppressWarnings("unchecked")
    List<BookingDB.BookedSlotSummary> bookedSlots =
            (List<BookingDB.BookedSlotSummary>) request.getAttribute("bookedSlots");
    if (bookedSlots == null) bookedSlots = java.util.Collections.emptyList();

    // Group bookedSlots by fieldId for quick display on each field card
    Map<Long, List<BookingDB.BookedSlotSummary>> slotsByFieldMap = new HashMap<>();
    int fullSlotsCount = 0;
    for (BookingDB.BookedSlotSummary s : bookedSlots) {
        if (s.getFieldId() != null) {
            slotsByFieldMap.computeIfAbsent(s.getFieldId(), k -> new ArrayList<>()).add(s);
        }
        if (s.isFull()) {
            fullSlotsCount++;
        }
    }

    // Calculate total court products and category product counts
    int totalCourtProducts = 0;
    Map<String, Integer> categoryProductCount = new HashMap<>();
    for (SportField f : activeFields) {
        int q = f.getQuantity() > 0 ? f.getQuantity() : 1;
        totalCourtProducts += q;
        String stKey = f.getSportType() != null ? f.getSportType().toUpperCase() : "OTHER";
        categoryProductCount.put(stKey, categoryProductCount.getOrDefault(stKey, 0) + q);
    }

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
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Material+Symbols+Rounded:FILL@0..1&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css?v=<%= assetVer %>">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/pages/home.css?v=<%= assetVer %>">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/icons.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/order-chat.css?v=<%= assetVer %>">
    <style>
        /* Đảm bảo đóng khung thẻ sân & bố cục trang chủ luôn chuẩn xác không bị ảnh hưởng bởi cache */
        .home-section-block {
            background: #ffffff;
            border: 1px solid #dbe3ee;
            border-radius: 22px;
            padding: 26px 28px;
            margin-bottom: 28px;
            box-shadow: 0 6px 20px rgba(15, 23, 42, 0.04);
        }
        .court-cards-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 22px;
        }
        .court-product-card {
            background: #ffffff;
            border: 2px solid #dce6f2;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 8px 22px rgba(15, 23, 42, 0.06);
            display: flex;
            flex-direction: column;
            transition: all 0.25s ease;
        }
        .court-product-card:hover {
            border-color: #159447;
            box-shadow: 0 14px 32px rgba(21, 148, 71, 0.14);
            transform: translateY(-4px);
        }
        .court-card-banner {
            position: relative;
            width: 100%;
            height: 195px;
            background: #dcfce7;
            overflow: hidden;
            flex-shrink: 0;
        }
        .court-card-banner img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
            transition: transform 0.35s ease;
        }
        .court-product-card:hover .court-card-banner img {
            transform: scale(1.05);
        }
        .court-card-banner::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(to top, rgba(15, 23, 42, 0.82) 0%, rgba(15, 23, 42, 0.12) 55%, rgba(15, 23, 42, 0.28) 100%);
            pointer-events: none;
        }
        .court-banner-top-row {
            position: absolute;
            top: 12px;
            left: 14px;
            right: 14px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            z-index: 2;
        }
        .court- banner-bottom-row,
        .court-banner-bottom-row {
            position: absolute;
            bottom: 12px;
            left: 14px;
            right: 14px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 8px;
            z-index: 2;
        }
        .court-card-body {
            padding: 18px 20px;
            display: flex;
            flex-direction: column;
            gap: 12px;
            flex: 1;
        }
        .court-inventory-panel {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            border-radius: 12px;
            padding: 10px 13px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            flex-wrap: wrap;
        }
        .court-slots-panel {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 13px;
            padding: 11px 13px;
        }
        .court-card-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            background: #f8fafc;
            border-top: 1px solid #e2e8f0;
            padding: 14px 20px;
            margin-top: auto;
        }
        @media (max-width: 1050px) {
            .court-cards-grid {
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
        <div class="navbar-left">
            <h1 class="page-title">Trang chủ Sportify</h1>
            <span class="navbar-subtitle">Hệ thống đặt sân & quản lý số lượng sản phẩm sân theo khung giờ thực tế</span>
        </div>
        <div class="navbar-right">
            <a href="#booked-slots-schedule" class="nav-quick-pill">
                <span>🕒</span>
                <span><%= bookedSlots.size() %> khung giờ đang có lịch đặt</span>
            </a>
            <a href="<%= contextPath %>/profile" class="user-profile">
                <div class="profile-img"><%= user != null && user.getFullname() != null && !user.getFullname().isEmpty() ? user.getFullname().substring(0,1).toUpperCase() : "U" %></div>
                <div class="profile-name"><%= user != null ? user.getFullname() : "Người dùng" %></div>
            </a>
        </div>
    </header>

    <main class="content-area">

        <!-- THÔNG BÁO NẾU CÓ -->
        <% if (bookingMsg != null && !bookingMsg.trim().isEmpty()) { %>
        <div class="alert-banner <%= bookingOk ? "alert-success" : "alert-error" %>">
            <span><%= bookingOk ? "✅" : "⚠️" %> <%= bookingMsg %></span>
            <button type="button" class="close-alert" onclick="this.parentElement.remove()">✕</button>
        </div>
        <% } %>

        <!-- HERO BANNER GỌN GÀNG & HIỆN ĐẠI -->
        <section class="home-hero-banner">
            <div class="home-hero-body">
                <div class="home-hero-eyebrow">⚡ ĐẶT SÂN TRỰC TUYẾN THEO SỐ LƯỢNG SẢN PHẨM</div>
                <h2>Chào <%= user != null ? user.getFullname() : "bạn" %>! 👋</h2>
                <p>
                    Mỗi danh mục sân được chuẩn hóa theo <strong>số lượng sản phẩm (sân con)</strong> thực tế.
                    Ở mỗi khung giờ, hệ thống chỉ nhận tối đa bằng tổng số sân hiện có (ví dụ: <strong>4 sân bóng bàn = tối đa 4 đơn/khung giờ</strong>).
                    Khung giờ nào đã đặt kín đủ số sân sẽ tự động khóa nút đặt.
                </p>
                <div class="home-hero-actions">
                    <a href="#fields" class="btn-hero-primary">🏟️ Khám phá sân & Đặt lịch ngay</a>
                    <a href="#booked-slots-schedule" class="btn-hero-secondary">📋 Xem các khung giờ đã có người đặt (<%= bookedSlots.size() %>)</a>
                </div>
            </div>
            <div class="home-hero-aside">
                <div class="hero-stat-box">
                    <span class="hero-stat-num"><%= totalCourtProducts %></span>
                    <span class="hero-stat-label">Sản phẩm sân<br>đang mở thuê</span>
                </div>
                <div class="hero-stat-box">
                    <span class="hero-stat-num"><%= activeFields.size() %></span>
                    <span class="hero-stat-label">Danh mục cơ sở<br>hoạt động</span>
                </div>
            </div>
        </section>

        <!-- THÔNG BÁO TIN NHẮN TỪ CHỦ SÂN PHỤC VỤ ĐƠN HÀNG -->
        <div id="orderChatCustomerAlert" class="order-chat-live-alert" style="display: none;">
            <div class="live-alert-icon">
                <span class="material-symbols-rounded">chat_bubble</span>
                <span class="pulse-indicator"></span>
            </div>
            <div class="live-alert-info">
                <div class="live-alert-title">
                    <strong>Tin nhắn mới từ Chủ sân</strong>
                    <span class="live-alert-partner" id="liveAlertPartnerName">Chủ sân</span>
                </div>
                <p class="live-alert-snippet" id="liveAlertSnippet">"Đang tải tin nhắn..."</p>
            </div>
            <button type="button" class="btn-live-alert-action" id="liveAlertActionBtn" onclick="openLatestOrderChat()">
                <span>Xem đơn & Trả lời</span>
                <span class="material-symbols-rounded">arrow_forward</span>
            </button>
        </div>

        <!-- 4 THẺ CHỈ SỐ TỔNG QUAN (KPI STATS) -->
        <section class="stats-grid">
            <a href="#fields" class="stat-card">
                <div class="stat-icon" style="background: #dcfce7; color: #15803d;">🏟️</div>
                <div class="stat-info">
                    <h4>Tổng sản phẩm sân</h4>
                    <span><%= totalCourtProducts %> <small class="stat-unit">sân</small></span>
                    <small>Thuộc <%= activeFields.size() %> danh mục cơ sở đang mở</small>
                </div>
            </a>

            <a href="#booked-slots-schedule" class="stat-card">
                <div class="stat-icon" style="background: #dbeafe; color: #1d4ed8;">🕒</div>
                <div class="stat-info">
                    <h4>Khung giờ đã có khách đặt</h4>
                    <span><%= bookedSlots.size() %> <small class="stat-unit">khung giờ</small></span>
                    <small><%= fullSlotsCount > 0 ? (fullSlotsCount + " khung giờ đã kín 100% sân") : "Các khung giờ vẫn còn sân trống" %></small>
                </div>
            </a>

            <a href="#my-bookings" class="stat-card">
                <div class="stat-icon" style="background: var(--primary-light); color: var(--primary);"><span class="app-icon icon-court" aria-hidden="true"></span></div>
                <div class="stat-info">
                    <h4>Đơn đặt sân của bạn</h4>
                    <span><%= customerBookings.size() %> <small class="stat-unit">đơn</small></span>
                    <small><%= customerBookings.isEmpty() ? "Chưa có đơn đặt nào" : "Nhấn để xem & chat với chủ sân" %></small>
                </div>
            </a>

            <a href="<%= contextPath %>/appointments" class="stat-card">
                <div class="stat-icon" style="background: #fef3c7; color: #d97706;">🔥</div>
                <div class="stat-info">
                    <h4>Giờ tập tháng này</h4>
                    <span><%= trainingHours %>h</span>
                    <small><%= upcomingCount %> lịch hẹn cá nhân sắp tới</small>
                </div>
            </a>
        </section>

        <!-- ========================================================================= -->
        <!-- PHẦN 1: DANH MỤC SÂN & BẢNG CHỌN SẢN PHẨM CHO THUÊ (ĐÓNG KHUNG THẺ ĐẸP)   -->
        <!-- ========================================================================= -->
        <section class="home-section-block" id="fields">
            <div class="section-header-bar">
                <div>
                    <h3 class="section-title">🏟️ Danh mục Sân & Số lượng Sản phẩm cho thuê</h3>
                    <p class="section-desc">
                        Mỗi cơ sở được đóng khung thành một thẻ sản phẩm riêng biệt, hiển thị rõ số sân cho thuê, giới hạn đơn mỗi khung giờ và danh sách các khung giờ đã có người đặt.
                    </p>
                </div>
                <div class="search-box-wrap">
                    <span class="search-icon">🔍</span>
                    <input type="text" id="fieldSearchInput" placeholder="Tìm tên sân, môn thể thao, địa chỉ..." oninput="filterHomeFields()">
                </div>
            </div>

            <!-- BẢNG CHỌN DANH MỤC MÔN THỂ THAO KÈM SỐ LƯỢNG SẢN PHẨM -->
            <div class="category-tabs" id="categoryTabs">
                <button type="button" class="cat-tab active" data-category="ALL" onclick="selectCategoryTab(this, 'ALL')">
                    <span>✨ Tất cả danh mục</span>
                    <span class="cat-count"><%= totalCourtProducts %> sản phẩm</span>
                </button>
                <% if (categoryProductCount.containsKey("TABLE_TENNIS")) { %>
                <button type="button" class="cat-tab" data-category="TABLE_TENNIS" onclick="selectCategoryTab(this, 'TABLE_TENNIS')">
                    <span>🏓 Bóng bàn</span>
                    <span class="cat-count">Còn <%= categoryProductCount.get("TABLE_TENNIS") %> sân</span>
                </button>
                <% } %>
                <% if (categoryProductCount.containsKey("PICKLEBALL")) { %>
                <button type="button" class="cat-tab" data-category="PICKLEBALL" onclick="selectCategoryTab(this, 'PICKLEBALL')">
                    <span>🎾 Pickleball</span>
                    <span class="cat-count">Còn <%= categoryProductCount.get("PICKLEBALL") %> sân</span>
                </button>
                <% } %>
                <% if (categoryProductCount.containsKey("BASKETBALL")) { %>
                <button type="button" class="cat-tab" data-category="BASKETBALL" onclick="selectCategoryTab(this, 'BASKETBALL')">
                    <span>🏀 Bóng rổ</span>
                    <span class="cat-count">Còn <%= categoryProductCount.get("BASKETBALL") %> sân</span>
                </button>
                <% } %>
                <% if (categoryProductCount.containsKey("GYM")) { %>
                <button type="button" class="cat-tab" data-category="GYM" onclick="selectCategoryTab(this, 'GYM')">
                    <span>🏋️ Phòng Gym</span>
                    <span class="cat-count">Còn <%= categoryProductCount.get("GYM") %> khu</span>
                </button>
                <% } %>
                <% if (categoryProductCount.containsKey("SWIMMING")) { %>
                <button type="button" class="cat-tab" data-category="SWIMMING" onclick="selectCategoryTab(this, 'SWIMMING')">
                    <span>🏊 Hồ bơi</span>
                    <span class="cat-count">Còn <%= categoryProductCount.get("SWIMMING") %> làn</span>
                </button>
                <% } %>
            </div>

            <% if (activeFields.isEmpty()) { %>
            <div class="empty-appt">
                Hiện tại chưa có sân hoặc dịch vụ nào mở hoạt động.
            </div>
            <% } else { %>
            <div class="court-cards-grid" id="homeFieldsGrid">
                <% for (SportField f : activeFields) {
                    String st = f.getSportType() != null ? f.getSportType().toUpperCase() : "GENERAL";
                    String badgeClass = "badge-default";
                    String badgeText = f.getSportType() != null ? f.getSportType() : "THỂ THAO";
                    String badgeIcon = "🏟️";
                    String defaultImg = contextPath + "/assets/images/basketball.jpg";

                    if ("GYM".equals(st)) {
                        badgeClass = "badge-gym";
                        badgeText = "Phòng Gym";
                        badgeIcon = "🏋️";
                        defaultImg = contextPath + "/assets/images/gymfitzone.jfif";
                    } else if ("BASKETBALL".equals(st)) {
                        badgeClass = "badge-basketball";
                        badgeText = "Sân Bóng rổ";
                        badgeIcon = "🏀";
                        defaultImg = contextPath + "/assets/images/basketballcourt1.jpg";
                    } else if ("SWIMMING".equals(st)) {
                        badgeClass = "badge-swimming";
                        badgeText = "Hồ bơi";
                        badgeIcon = "🏊";
                        defaultImg = contextPath + "/assets/images/swimmingpoolaqua.jfif";
                    } else if ("PICKLEBALL".equals(st)) {
                        badgeClass = "badge-pickleball";
                        badgeText = "Sân Pickleball";
                        badgeIcon = "🎾";
                        defaultImg = contextPath + "/assets/images/greenpickleballcourt.jfif";
                    } else if ("TABLE_TENNIS".equals(st)) {
                        badgeClass = "badge-tabletennis";
                        badgeText = "Sân Bóng bàn";
                        badgeIcon = "🏓";
                        defaultImg = contextPath + "/assets/images/greenpickleballcourt.jfif";
                    }

                    String imgSrc = f.getImageUrl() != null && !f.getImageUrl().trim().isEmpty()
                                    ? contextPath + "/" + f.getImageUrl()
                                    : defaultImg;

                    String openTimeStr = f.getOpenTime() != null ? f.getOpenTime().toString().substring(0, 5) : "06:00";
                    String closeTimeStr = f.getCloseTime() != null ? f.getCloseTime().toString().substring(0, 5) : "22:00";
                    double price = f.getPricePerHour() != null ? f.getPricePerHour().doubleValue() : 0.0;
                    int fieldQty = f.getQuantity() > 0 ? f.getQuantity() : 1;
                    List<BookingDB.BookedSlotSummary> fieldSlots = slotsByFieldMap.getOrDefault(f.getFieldId(), java.util.Collections.emptyList());
                %>
                <!-- THẺ SÂN ĐƯỢC ĐÓNG KHUNG RÕ RÀNG -->
                <article class="court-product-card"
                         data-sport="<%= st %>"
                         data-search="<%= (f.getFieldName() + " " + badgeText + " " + (f.getAddress() != null ? f.getAddress() : "")).toLowerCase() %>">

                    <!-- ẢNH BÌA TRÊN CÙNG + BADGE MÔN + SỐ LƯỢNG SẢN PHẨM -->
                    <div class="court-card-banner">
                        <img src="<%= imgSrc %>" alt="<%= f.getFieldName() %>" onerror="this.src='<%= defaultImg %>'">
                        <div class="court-banner-top-row">
                            <span class="court-sport-badge <%= badgeClass %>">
                                <span><%= badgeIcon %></span> <%= badgeText %>
                            </span>
                            <span class="court-rating-pill">★ 4.9 Đánh giá</span>
                        </div>
                        <div class="court-banner-bottom-row">
                            <span class="court-product-pill">
                                📦 Còn <%= fieldQty %> sân cho thuê (<%= fieldQty %> sản phẩm)
                            </span>
                            <span class="court-hours-pill">
                                🕒 <%= openTimeStr %> - <%= closeTimeStr %>
                            </span>
                        </div>
                    </div>

                    <!-- NỘI DUNG CHÍNH TRONG THẺ -->
                    <div class="court-card-body">
                        <div>
                            <h4 class="court-card-title" title="<%= f.getFieldName() %>"><%= f.getFieldName() %></h4>
                            <p class="court-card-address" title="<%= f.getAddress() %>">
                                📍 <%= f.getAddress() != null ? f.getAddress() : "TP. Hồ Chí Minh" %>
                            </p>
                        </div>

                        <p class="court-card-desc">
                            <%= f.getDescription() != null ? f.getDescription() : "Cơ sở thể thao hiện đại, mặt sân tiêu chuẩn thi đấu, phục vụ hội viên tận tình." %>
                        </p>

                        <!-- HỘP ĐÓNG KHUNG SỐ LƯỢNG SẢN PHẨM & GIỚI HẠN ĐƠN -->
                        <div class="court-inventory-panel">
                            <div class="court-inv-left">
                                <span class="court-inv-dot"></span>
                                <span>Số lượng sản phẩm: <strong><%= fieldQty %> sân độc lập</strong></span>
                            </div>
                            <span class="court-inv-tag">Tối đa <%= fieldQty %> đơn / khung giờ</span>
                        </div>

                        <!-- HỘP ĐÓNG KHUNG CÁC KHUNG GIỜ ĐÃ CÓ NGƯỜI ĐẶT CỦA SÂN NÀY -->
                        <div class="court-slots-panel">
                            <div class="court-slots-header">
                                <span class="court-slots-title">🕒 Các khung giờ đã có người đặt:</span>
                                <span class="court-slots-badge"><%= fieldSlots.size() %> khung giờ</span>
                            </div>
                            <% if (fieldSlots.isEmpty()) { %>
                            <div class="court-slots-empty">
                                ✅ Tất cả các khung giờ hiện đang trống đủ <strong><%= fieldQty %>/<%= fieldQty %> sân</strong> — Có thể đặt bất kỳ giờ nào!
                            </div>
                            <% } else { %>
                            <div class="court-slots-list">
                                <% for (BookingDB.BookedSlotSummary slot : fieldSlots) {
                                    boolean slotFull = slot.isFull();
                                %>
                                <% if (slotFull) { %>
                                <div class="court-slot-item slot-is-full" title="Khung giờ này đã nhận đủ <%= slot.getFieldQuantity() %>/<%= slot.getFieldQuantity() %> đơn đặt, không thể đặt thêm">
                                    <span class="slot-item-time">🚫 <%= slot.getDateStr() %> • <%= slot.getStartTimeStr() %> - <%= slot.getEndTimeStr() %></span>
                                    <span class="slot-item-status">Đã kín <%= slot.getBookedCount() %>/<%= slot.getFieldQuantity() %> sân (Khóa đặt)</span>
                                </div>
                                <% } else { %>
                                <a href="<%= contextPath %>/field-booking?fieldId=<%= f.getFieldId() %>&date=<%= slot.getIsoDate() %>&startTime=<%= slot.getStartTimeStr() %>&endTime=<%= slot.getEndTimeStr() %>"
                                   class="court-slot-item slot-is-partial"
                                   title="Nhấn để đặt sân còn trống trong khung giờ này">
                                    <span class="slot-item-time">⚡ <%= slot.getDateStr() %> • <%= slot.getStartTimeStr() %> - <%= slot.getEndTimeStr() %></span>
                                    <span class="slot-item-status">Đã đặt <%= slot.getBookedCount() %>/<%= slot.getFieldQuantity() %> • Còn <%= slot.getRemainingCount() %> sân →</span>
                                </a>
                                <% } %>
                                <% } %>
                            </div>
                            <% } %>
                        </div>
                    </div>

                    <!-- CHÂN THẺ: GIÁ NIÊM YẾT & NÚT ĐẶT SÂN -->
                    <div class="court-card-footer">
                        <div class="court-price-box">
                            <span class="court-price-label">Giá thuê niêm yết</span>
                            <div class="court-price-value">
                                <%= vndFormat.format(price) %> đ <small>/ giờ / sân</small>
                            </div>
                        </div>

                        <a href="<%= contextPath %>/field-booking?fieldId=<%= f.getFieldId() %>" class="btn-court-book">
                            <span>📅</span> Chọn khung giờ & Đặt sân →
                        </a>
                    </div>
                </article>
                <% } %>
            </div>
            <% } %>
        </section>

        <!-- ========================================================================= -->
        <!-- PHẦN 2: BẢNG TỔNG HỢP ĐẦY ĐỦ CÁC KHUNG GIỜ ĐÃ CÓ NGƯỜI ĐẶT               -->
        <!-- ========================================================================= -->
        <section class="home-section-block" id="booked-slots-schedule">
            <div class="section-header-bar">
                <div>
                    <h3 class="section-title">📋 Bảng tổng hợp đầy đủ các khung giờ đã có người đặt</h3>
                    <p class="section-desc">
                        Theo dõi trực tiếp công suất từng khung giờ trên toàn hệ thống. Những khung giờ đã nhận đủ số đơn tối đa (ví dụ <strong>4/4 sân</strong>) sẽ tự động khóa nút đặt.
                    </p>
                </div>
                <div class="slot-filter-pills">
                    <button type="button" class="slot-pill active" onclick="filterBookedSchedule(this, 'ALL')">Tất cả (<%= bookedSlots.size() %>)</button>
                    <button type="button" class="slot-pill" onclick="filterBookedSchedule(this, 'AVAILABLE')">Còn sân trống (<%= bookedSlots.size() - fullSlotsCount %>)</button>
                    <button type="button" class="slot-pill" onclick="filterBookedSchedule(this, 'FULL')">Đã đủ đơn / Hết sân (<%= fullSlotsCount %>)</button>
                </div>
            </div>

            <% if (bookedSlots.isEmpty()) { %>
            <div class="empty-appt">
                🎉 Hiện chưa có khung giờ nào được đặt. Tất cả các sân đều đang trống 100% công suất!
            </div>
            <% } else { %>
            <div class="card-framed-box">
                <table class="bookings-table" id="publicBookedSlotsTable">
                    <thead>
                        <tr>
                            <th>Danh mục sân & Quy mô</th>
                            <th>Ngày thuê</th>
                            <th>Khung giờ</th>
                            <th>Số đơn đã đặt / Giới hạn</th>
                            <th>Các sân (sản phẩm) đã đặt</th>
                            <th>Trạng thái khung giờ</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (BookingDB.BookedSlotSummary slot : bookedSlots) {
                            boolean isFull = slot.isFull();
                            int pct = slot.getFieldQuantity() > 0 ? Math.min(100, (slot.getBookedCount() * 100) / slot.getFieldQuantity()) : 100;
                        %>
                        <tr class="schedule-slot-row" data-slot-state="<%= isFull ? "FULL" : "AVAILABLE" %>">
                            <td>
                                <div style="font-weight: 800; color: #0f172a; font-size: 14px;"><%= slot.getFieldName() %></div>
                                <small style="color: #64748b; font-weight: 600;">
                                    📦 Quy mô: <strong><%= slot.getFieldQuantity() %> sản phẩm (sân)</strong> • Tối đa <%= slot.getFieldQuantity() %> đơn/giờ
                                </small>
                            </td>
                            <td>
                                <span class="date-badge">📅 <%= slot.getDateStr() %></span>
                            </td>
                            <td>
                                <span class="time-range-badge">🕒 <%= slot.getStartTimeStr() %> - <%= slot.getEndTimeStr() %></span>
                            </td>
                            <td>
                                <div class="capacity-meter-wrap">
                                    <div class="capacity-numbers">
                                        <strong style="color: <%= isFull ? "#dc2626" : "#0284c7" %>;">
                                            <%= slot.getBookedCount() %> / <%= slot.getFieldQuantity() %> đơn đặt
                                        </strong>
                                        <span><%= isFull ? "Hết sân" : ("Còn " + slot.getRemainingCount() + " sân") %></span>
                                    </div>
                                    <div class="capacity-bar">
                                        <div class="capacity-fill <%= isFull ? "fill-full" : "fill-partial" %>" style="width: <%= pct %>%;"></div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="court-badges-wrap">
                                    <% for (Booking bItem : slot.getBookings()) {
                                        int cNum = bItem.getCourtNumber() > 0 ? bItem.getCourtNumber() : 1;
                                        boolean isConf = "CONFIRMED".equals(bItem.getStatus()) || "COMPLETED".equals(bItem.getStatus());
                                    %>
                                    <span class="court-unit-tag <%= isConf ? "unit-confirmed" : "unit-pending" %>"
                                          title="Mã đơn #<%= bItem.getBookingCode() %> - <%= isConf ? "Đã xác nhận" : "Chờ duyệt" %>">
                                        Sân #<%= cNum %> (<%= isConf ? "Đã duyệt" : "Chờ duyệt" %>)
                                    </span>
                                    <% } %>
                                </div>
                            </td>
                            <td>
                                <% if (isFull) { %>
                                <span class="status-pill status-rejected">
                                    🚫 Đã đủ <%= slot.getBookedCount() %>/<%= slot.getFieldQuantity() %> sân (Khóa đặt)
                                </span>
                                <% } else { %>
                                <span class="status-pill status-confirmed">
                                    ✅ Còn <%= slot.getRemainingCount() %>/<%= slot.getFieldQuantity() %> sân cho thuê
                                </span>
                                <% } %>
                            </td>
                            <td>
                                <% if (isFull) { %>
                                <button type="button" class="btn-slot-disabled" disabled title="Khung giờ này đã nhận đủ <%= slot.getFieldQuantity() %> đơn đặt thuê, không thể bấm đặt sân">
                                    🔒 Đã kín chỗ
                                </button>
                                <% } else { %>
                                <a href="<%= contextPath %>/field-booking?fieldId=<%= slot.getFieldId() %>&date=<%= slot.getIsoDate() %>&startTime=<%= slot.getStartTimeStr() %>&endTime=<%= slot.getEndTimeStr() %>"
                                   class="btn-slot-book">
                                    ⚡ Đặt sân trống
                                </a>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </section>

        <!-- ========================================================================= -->
        <!-- PHẦN 3A: KHO TÀI SẢN LỊCH ĐẶT SÂN SỞ HỮU (ĐÃ XÁC NHẬN - CHUYỂN NHƯỢNG)    -->
        <!-- ========================================================================= -->
        <%
            List<Booking> confirmedAssets = new java.util.ArrayList<>();
            for (Booking cb : customerBookings) {
                if ("CONFIRMED".equals(cb.getStatus())) {
                    confirmedAssets.add(cb);
                }
            }
        %>
        <section class="home-section-block" id="my-booking-assets">
            <div class="section-header-bar">
                <div>
                    <h3 class="section-title">💎 Tài sản lịch đặt sân sở hữu của bạn (Đã xác nhận)</h3>
                    <p class="section-desc">
                        Mỗi lịch đặt sân đã được chủ sân xác nhận là <strong>tài sản riêng của tài khoản <%= user != null ? user.getFullname() : "" %></strong>.
                        Bạn có thể <strong>chuyển quyền sở hữu</strong> cho bạn bè qua Tin nhắn hoặc <strong>đính kèm lên Newsfeed</strong> để rủ hội nhóm / rao bán lịch sân.
                    </p>
                </div>
                <span class="court-slots-badge" style="background:#dcfce7; color:#15803d; border:1px solid #86efac; font-size:12.5px; padding:6px 14px; font-weight:800;">
                    🎖️ Đang sở hữu <%= confirmedAssets.size() %> lịch sân đã xác nhận
                </span>
            </div>

            <% if (confirmedAssets.isEmpty()) { %>
            <div class="empty-appt" style="background:#f8fafc; border:1.5px dashed #cbd5e1;">
                💎 Hiện tài khoản của bạn chưa có lịch đặt sân nào ở trạng thái <strong>Đã xác nhận (CONFIRMED)</strong>.<br>
                <small style="color:#64748b;">Khi bạn đặt sân và được chủ sân xác nhận (hoặc nhận chuyển nhượng từ tài khoản khác qua Tin nhắn), vé sân sẽ xuất hiện tại đây như tài sản riêng của bạn.</small>
            </div>
            <% } else { %>
            <div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(340px, 1fr)); gap:18px; margin-bottom:10px;">
                <% for (Booking asset : confirmedAssets) {
                    String aDate = asset.getStartsAt() != null ? asset.getStartsAt().toLocalDate().format(dateFmt) : "";
                    String aStart = asset.getStartsAt() != null ? asset.getStartsAt().toLocalTime().format(timeFmt) : "";
                    String aEnd = asset.getEndsAt() != null ? asset.getEndsAt().toLocalTime().format(timeFmt) : "";
                    String aField = asset.getField() != null ? asset.getField().getFieldName() : ("Sân #" + asset.getBookingId());
                    String aSport = (asset.getField() != null && asset.getField().getSportType() != null) ? asset.getField().getSportType() : "";
                    String aAddr = (asset.getField() != null && asset.getField().getAddress() != null) ? asset.getField().getAddress() : "";
                    int aCourt = asset.getCourtNumber() > 0 ? asset.getCourtNumber() : 1;
                    int aMax = (asset.getField() != null && asset.getField().getQuantity() > 0) ? asset.getField().getQuantity() : 4;
                %>
                <div style="background:linear-gradient(145deg, #ffffff 0%, #f0fdf4 100%); border:2px solid #86efac; border-radius:16px; padding:18px; box-shadow:0 8px 20px rgba(21,148,71,0.08); display:flex; flex-direction:column; justify-content:space-between; gap:14px;">
                    <div>
                        <div style="display:flex; align-items:center; justify-content:space-between; gap:8px; margin-bottom:10px;">
                            <span style="background:#15803d; color:#fff; font-size:11px; font-weight:800; padding:4px 10px; border-radius:999px; letter-spacing:0.4px;">
                                💎 TÀI SẢN VÉ SÂN #<%= asset.getBookingCode() %>
                            </span>
                            <span style="background:#dcfce7; color:#166534; font-size:11.5px; font-weight:700; padding:3px 9px; border-radius:8px; border:1px solid #bbf7d0;">
                                ✅ Chủ sở hữu: <%= user != null ? user.getFullname() : asset.getCustomerName() %>
                            </span>
                        </div>
                        <h4 style="margin:0 0 6px 0; font-size:17px; font-weight:800; color:#0f172a;"><%= aField %></h4>
                        <% if (!aAddr.isEmpty()) { %>
                        <div style="font-size:12.5px; color:#475569; margin-bottom:10px;">📍 <%= aAddr %></div>
                        <% } %>
                        <div style="display:flex; flex-wrap:wrap; gap:8px; margin-bottom:10px;">
                            <span class="court-assigned-pill">🏟️ Sân #<%= aCourt %> / <%= aMax %> (<%= aSport %>)</span>
                            <span class="date-badge">📅 <%= aDate %></span>
                            <span class="time-range-badge">🕒 <%= aStart %> - <%= aEnd %></span>
                        </div>
                        <div style="font-size:13.5px; color:#1e293b; font-weight:700;">
                            💰 Giá trị lịch đặt: <span style="color:#15803d; font-size:15px; font-weight:800;"><%= vndFormat.format(asset.getTotalPrice()) %> đ</span>
                        </div>
                    </div>

                    <div style="border-top:1px dashed #bbf7d0; padding-top:12px; display:flex; flex-wrap:wrap; gap:8px;">
                        <a href="<%= contextPath %>/chat-friends?transferBookingId=<%= asset.getBookingId() %>"
                           style="flex:1; min-width:140px; text-align:center; background:#0284c7; color:#fff; text-decoration:none; padding:8px 12px; border-radius:10px; font-size:12.5px; font-weight:700; box-shadow:0 3px 8px rgba(2,132,199,0.2);">
                            🔁 Chuyển qua Tin nhắn
                        </a>
                        <a href="<%= contextPath %>/newsfeed?shareBookingId=<%= asset.getBookingId() %>&purpose=TIM_DOI"
                           style="flex:1; min-width:120px; text-align:center; background:#159447; color:#fff; text-decoration:none; padding:8px 10px; border-radius:10px; font-size:12.5px; font-weight:700;">
                            🤝 Rủ hội nhóm
                        </a>
                        <a href="<%= contextPath %>/newsfeed?shareBookingId=<%= asset.getBookingId() %>&purpose=PASS_SAN"
                           style="flex:1; min-width:120px; text-align:center; background:#ea580c; color:#fff; text-decoration:none; padding:8px 10px; border-radius:10px; font-size:12.5px; font-weight:700;">
                            🏷️ Rao bán sân
                        </a>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>
        </section>

        <!-- ========================================================================= -->
        <!-- PHẦN 3B: ĐƠN ĐẶT SÂN CỦA BẠN                                              -->
        <!-- ========================================================================= -->
        <section class="home-section-block" id="my-bookings">
            <div class="section-header-bar">
                <div>
                    <h3 class="section-title">📑 Toàn bộ lịch sử đơn đặt sân của bạn</h3>
                    <p class="section-desc">Quản lý các yêu cầu đặt sân, chuyển nhượng lịch đã duyệt hoặc nhắn tin trực tiếp với chủ sân.</p>
                </div>
                <% if (!customerBookings.isEmpty()) { %>
                <span class="court-slots-badge" style="font-size: 12.5px; padding: 5px 12px;"><%= customerBookings.size() %> đơn thuộc tài khoản</span>
                <% } %>
            </div>

            <% if (customerBookings.isEmpty()) { %>
            <div class="empty-appt">
                📭 Bạn chưa có đơn đặt sân nào.<br>
                <a href="#fields" style="color: #159447; font-weight: 700;">+ Chọn danh mục sân và đặt khung giờ ngay ở trên</a>
            </div>
            <% } else { %>
            <div class="card-framed-box">
                <table class="bookings-table">
                    <thead>
                        <tr>
                            <th>Mã đơn</th>
                            <th>Danh mục sân & Sản phẩm</th>
                            <th>Ngày đặt</th>
                            <th>Khung giờ</th>
                            <th>Tổng tiền</th>
                            <th>Trạng thái & Quyền sở hữu</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Booking b : customerBookings) {
                            String stClass = "status-pending";
                            String stText = "Chờ xác nhận";
                            if ("CONFIRMED".equals(b.getStatus())) {
                                stClass = "status-confirmed";
                                stText = "Đã xác nhận (Tài sản sở hữu)";
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
                            int courtNum = b.getCourtNumber() > 0 ? b.getCourtNumber() : 1;
                            int maxCourts = (b.getField() != null && b.getField().getQuantity() > 0) ? b.getField().getQuantity() : 1;
                        %>
                        <tr>
                            <td><strong style="color: #159447; font-weight: 800;">#<%= b.getBookingCode() %></strong></td>
                            <td>
                                <div style="font-weight: 700; color: #1e293b;"><%= fieldTitle %></div>
                                <div style="display:flex; align-items:center; gap:6px; margin-top:4px;">
                                    <span class="court-assigned-pill">🏟️ Sân #<%= courtNum %> / <%= maxCourts %></span>
                                    <% if (b.getField() != null && b.getField().getSportType() != null) { %>
                                    <small style="color: #64748b; font-weight: 600;"><%= b.getField().getSportType() %></small>
                                    <% } %>
                                </div>
                            </td>
                            <td><%= dateText %></td>
                            <td><strong><%= startTimeText %> - <%= endTimeText %></strong></td>
                            <td><strong style="color: #159447; font-size: 14.5px;"><%= vndFormat.format(b.getTotalPrice()) %> đ</strong></td>
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
                                <div style="display:flex;align-items:center;gap:6px;flex-wrap:wrap;">
                                    <button type="button" class="btn-chat-order-sm"
                                            onclick="openOrderChat(<%= b.getBookingId() %>)"
                                            title="Nhắn tin trao đổi với chủ sân về đơn đặt này">
                                        <span class="material-symbols-rounded">chat</span> Nhắn tin chủ sân
                                    </button>
                                    <% if ("CONFIRMED".equals(b.getStatus())) { %>
                                    <a href="<%= contextPath %>/chat-friends?transferBookingId=<%= b.getBookingId() %>"
                                       style="display:inline-flex;align-items:center;gap:4px;padding:6px 10px;border-radius:8px;background:#e0f2fe;color:#0369a1;font-size:12px;font-weight:700;text-decoration:none;border:1px solid #bae6fd;"
                                       title="Chuyển quyền sở hữu lịch sân này cho tài khoản khác qua Tin nhắn">
                                        🔁 Chuyển lịch sân
                                    </a>
                                    <a href="<%= contextPath %>/newsfeed?shareBookingId=<%= b.getBookingId() %>&purpose=TIM_DOI"
                                       style="display:inline-flex;align-items:center;gap:4px;padding:6px 10px;border-radius:8px;background:#fef3c7;color:#b45309;font-size:12px;font-weight:700;text-decoration:none;border:1px solid #fde68a;"
                                       title="Đính kèm lịch sân này lên Newsfeed để rủ hội nhóm hoặc rao bán">
                                        📢 Đăng Newsfeed
                                    </a>
                                    <% } %>
                                    <% if ("PENDING".equals(b.getStatus())) { %>
                                    <form method="post" action="<%= contextPath %>/field-booking/cancel" style="display:inline;"
                                          onsubmit="return confirm('Bạn có chắc chắn muốn hủy yêu cầu đặt sân này?');">
                                        <input type="hidden" name="bookingId" value="<%= b.getBookingId() %>">
                                        <button type="submit" class="btn-cancel-sm">Hủy đơn</button>
                                    </form>
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

        <!-- LỊCH HẸN CÁ NHÂN SẮP TỚI -->
        <section class="home-section-block">
            <div class="section-header-bar">
                <div>
                    <h3 class="section-title">📅 Lịch hẹn cá nhân sắp tới</h3>
                    <p class="section-desc">Các lịch tập luyện cá nhân và thuê dụng cụ của bạn.</p>
                </div>
                <a href="<%= contextPath %>/appointments" style="font-size: 13px; font-weight: 700; color: #159447; text-decoration: none;">Xem tất cả →</a>
            </div>

            <% if (upcomingAppts.isEmpty()) { %>
            <div class="empty-appt">
                📭 Chưa có lịch hẹn cá nhân nào sắp tới.<br>
                <a href="<%= contextPath %>/appointments" style="color: #159447; font-weight: 700;">+ Thêm lịch hẹn ngay</a>
            </div>
            <% } else {
                int shown = 0;
                for (Appointment a : upcomingAppts) {
                    if (shown >= 3) break;
                    String itemType = a.getType() != null ? a.getType() : "court";
                    String bg = "#e0f2fe";
                    String icon = "⚽";
                    String meta = "Đặt sân";
                    if ("pt".equals(itemType)) {
                        bg = "#fef3c7";
                        icon = "💪";
                        meta = "Tập với PT";
                    } else if ("gear".equals(itemType)) {
                        bg = "#f3e8ff";
                        icon = "🎒";
                        meta = "Thuê Gear";
                    } else if ("clothing".equals(itemType)) {
                        bg = "#fce7f3";
                        icon = "👕";
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
        </section>

    </main>
</div>

<!-- NÚT NỔI CHAT VỚI CHỦ SÂN (GÓC MÀN HÌNH) -->
<div class="order-chat-floating-btn" id="orderChatFloatingTrigger" onclick="openLatestOrderChat()" title="Mở tin nhắn với chủ sân">
    <span class="material-symbols-rounded">forum</span>
    <span>Chat với Chủ sân</span>
    <span class="floating-unread-dot" id="floatingUnreadDot" style="display: none;"></span>
</div>

<%@ include file="/WEB-INF/views/common/order-chat-modal.jspf" %>
<script>
    const CTX = '<%= contextPath %>';
    window.FIRST_CUSTOMER_BOOKING_ID = <%= !customerBookings.isEmpty() ? customerBookings.get(0).getBookingId() : "null" %>;

    let selectedHomeCategory = 'ALL';

    function selectCategoryTab(btn, category) {
        selectedHomeCategory = category;
        document.querySelectorAll('#categoryTabs .cat-tab').forEach(b => b.classList.remove('active'));
        if (btn) btn.classList.add('active');
        filterHomeFields();
    }

    function filterHomeFields() {
        const searchInput = document.getElementById('fieldSearchInput');
        const q = searchInput ? searchInput.value.trim().toLowerCase() : '';
        const cards = document.querySelectorAll('#homeFieldsGrid .court-product-card');

        cards.forEach(card => {
            const sport = card.getAttribute('data-sport') || '';
            const searchStr = card.getAttribute('data-search') || '';
            const matchCat = (selectedHomeCategory === 'ALL') || (sport === selectedHomeCategory);
            const matchText = !q || searchStr.includes(q);
            card.style.display = (matchCat && matchText) ? '' : 'none';
        });
    }

    function filterBookedSchedule(btn, state) {
        document.querySelectorAll('.slot-filter-pills .slot-pill').forEach(b => b.classList.remove('active'));
        if (btn) btn.classList.add('active');
        const rows = document.querySelectorAll('#publicBookedSlotsTable tbody .schedule-slot-row');
        rows.forEach(row => {
            const rowState = row.getAttribute('data-slot-state');
            row.style.display = (state === 'ALL' || rowState === state) ? '' : 'none';
        });
    }
</script>
<script defer src="<%= contextPath %>/assets/js/order-chat.js?v=<%= assetVer %>"></script>

</body>
</html>
