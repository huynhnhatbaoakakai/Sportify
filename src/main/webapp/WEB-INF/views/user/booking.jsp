<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.sportify.model.User" %>
<%@ page import="com.sportify.model.SportField" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.time.LocalDate" %>
<%-- Controller: com.sportify.controller.booking.FieldBookingServlet (GET /field-booking?fieldId=...) --%>
<%
    String contextPath = request.getContextPath();
    User user = (User) session.getAttribute("user");
    SportField field = (SportField) request.getAttribute("field");
    if (field == null) {
        response.sendRedirect(contextPath + "/home");
        return;
    }

    NumberFormat vndFormat = NumberFormat.getInstance(new Locale("vi", "VN"));
    String todayStr = LocalDate.now().toString();

    String st = field.getSportType() != null ? field.getSportType().toUpperCase() : "GENERAL";
    String badgeClass = "badge-default";
    String badgeText = field.getSportType() != null ? field.getSportType() : "THỂ THAO";
    String badgeIcon = "court";
    String defaultImg = contextPath + "/assets/images/basketball.jpg";
    String amenitiesHtml = "";

    if ("GYM".equals(st)) {
        badgeClass = "badge-gym";
        badgeText = "Phòng Gym & Fitness";
        badgeIcon = "gym";
        defaultImg = contextPath + "/assets/images/gymfitzone.jfif";
        amenitiesHtml = "<span class='amenity-pill'>Full thiết bị tập</span><span class='amenity-pill'>Máy lạnh 24/7</span><span class='amenity-pill'>Phòng tắm nóng lạnh</span><span class='amenity-pill'>Wifi miễn phí</span>";
    } else if ("BASKETBALL".equals(st)) {
        badgeClass = "badge-basketball";
        badgeText = "Sân Bóng Rổ";
        badgeIcon = "basketball";
        defaultImg = contextPath + "/assets/images/basketballcourt1.jpg";
        amenitiesHtml = "<span class='amenity-pill'>Sàn gỗ chuẩn FIBA</span><span class='amenity-pill'>Đèn LED chiếu sáng</span><span class='amenity-pill'>Bãi giữ xe rộng</span><span class='amenity-pill'>Nước uống miễn phí</span>";
    } else if ("SWIMMING".equals(st)) {
        badgeClass = "badge-swimming";
        badgeText = "Hồ Bơi Thể Thao";
        badgeIcon = "swimming";
        defaultImg = contextPath + "/assets/images/swimmingpoolaqua.jfif";
        amenitiesHtml = "<span class='amenity-pill'>Làn bơi Olympic</span><span class='amenity-pill'>Nước ấm 4 mùa</span><span class='amenity-pill'>Cứu hộ chuyên nghiệp</span><span class='amenity-pill'>Phòng thay đồ VIP</span>";
    } else if ("PICKLEBALL".equals(st)) {
        badgeClass = "badge-pickleball";
        badgeText = "Sân Pickleball";
        badgeIcon = "racket";
        defaultImg = contextPath + "/assets/images/greenpickleballcourt.jfif";
        amenitiesHtml = "<span class='amenity-pill'>Mặt sân chuẩn thi đấu</span><span class='amenity-pill'>Đèn chơi ban đêm</span><span class='amenity-pill'>Đỗ xe ô tô</span><span class='amenity-pill'>Quầy căng tin</span>";
    }

    String imgSrc = field.getImageUrl() != null && !field.getImageUrl().trim().isEmpty() 
                    ? contextPath + "/" + field.getImageUrl() 
                    : defaultImg;

    String openTimeStr = field.getOpenTime() != null ? field.getOpenTime().toString().substring(0, 5) : "06:00";
    String closeTimeStr = field.getCloseTime() != null ? field.getCloseTime().toString().substring(0, 5) : "22:00";
    double price = field.getPricePerHour() != null ? field.getPricePerHour().doubleValue() : 0.0;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt lịch: <%= field.getFieldName() %> - Sportify</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/pages/home.css">
    <style>
        .booking-page-layout {
            display: grid;
            grid-template-columns: 1fr 1.15fr;
            gap: 24px;
            align-items: start;
            margin-top: 20px;
        }
        .venue-card-details {
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 18px;
            padding: 22px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.03);
        }
        .venue-img-wrap {
            position: relative;
            width: 100%;
            height: 220px;
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
            padding: 5px 12px;
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
        .venue-title {
            font-size: 20px;
            font-weight: 800;
            color: var(--dark);
            margin-bottom: 8px;
        }
        .venue-rating-row {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: #64748b;
            margin-bottom: 16px;
        }
        .venue-spec-list {
            background: #f8fafc;
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 14px 16px;
            margin-bottom: 16px;
            display: flex;
            flex-direction: column;
            gap: 8px;
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
            margin-top: 14px;
        }
        .amenity-pill {
            background: #f1f5f9;
            color: #475569;
            padding: 5px 10px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 500;
        }
        .booking-form-box {
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 18px;
            padding: 26px 28px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.03);
        }
        .booking-form-header {
            margin-bottom: 22px;
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
        @media (max-width: 860px) {
            .booking-page-layout {
                grid-template-columns: 1fr;
            }
        }
    </style>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/icons.css">
</head>
<body>

<% String activeMenu = "home"; %>
<%@ include file="/WEB-INF/views/common/sidebar.jspf" %>

<div class="main-wrapper">
    <header class="top-navbar">
        <div style="display: flex; align-items: center; gap: 14px;">
            <a href="<%= contextPath %>/home" class="back-link-btn">
                <span><span class="app-icon icon-arrow-left" aria-hidden="true"></span></span> Quay lại trang chủ
            </a>
            <h1 class="page-title" style="margin: 0;">Đặt lịch sân</h1>
        </div>
        <a href="<%= contextPath %>/profile" class="user-profile">
            <div class="profile-img"><%= user != null && user.getFullname() != null && !user.getFullname().isEmpty() ? user.getFullname().substring(0,1).toUpperCase() : "U" %></div>
            <div class="profile-name"><%= user != null ? user.getFullname() : "Người dùng" %></div>
        </a>
    </header>

    <main class="content-area">

        <div class="booking-page-layout">

            <!-- CỘT TRÁI: THÔNG TIN CHI TIẾT SÂN -->
            <div class="venue-card-details">
                <div class="venue-img-wrap">
                    <img src="<%= imgSrc %>" alt="<%= field.getFieldName() %>" onerror="this.src='<%= defaultImg %>'">
                    <span class="venue-badge <%= badgeClass %>">
                        <span><span class="app-icon icon-<%= badgeIcon %>" aria-hidden="true"></span></span> <%= badgeText %>
                    </span>
                </div>

                <h2 class="venue-title"><%= field.getFieldName() %></h2>

                <div class="venue-rating-row">

                    <strong>4.9 / 5</strong>
                    <span>(120+ lượt đặt)</span>
                    <span style="background: #eaf8ef; color: var(--primary-dark); padding: 2px 8px; border-radius: 6px; font-weight: 700; font-size: 11px;">Đối tác Sportify</span>
                </div>

                <div class="venue-spec-list">
                    <div class="venue-spec-item">
                        <span><span class="app-icon icon-map" aria-hidden="true"></span></span>
                        <span>Địa chỉ: <strong><%= field.getAddress() != null ? field.getAddress() : "TP. Hồ Chí Minh" %></strong></span>
                    </div>
                    <div class="venue-spec-item">
                        <span><span class="app-icon icon-clock" aria-hidden="true"></span></span>
                        <span>Khung giờ mở cửa: <strong><%= openTimeStr %> - <%= closeTimeStr %></strong> hàng ngày</span>
                    </div>
                    <div class="venue-spec-item">
                        <span><span class="app-icon icon-wallet" aria-hidden="true"></span></span>
                        <span>Giá thuê niêm yết: <strong style="color: var(--primary); font-size: 16px;"><%= vndFormat.format(price) %> đ</strong> / giờ</span>
                    </div>
                </div>

                <div style="font-size: 13.5px; color: var(--text); line-height: 1.5; margin-bottom: 12px;">
                    <strong>Giới thiệu cơ sở:</strong><br>
                    <%= field.getDescription() != null ? field.getDescription() : "Cơ sở thể thao hiện đại, phục vụ hội viên tận tình." %>
                </div>

                <div style="font-size: 13px; font-weight: 700; color: var(--dark); margin-top: 14px;">
                    Tiện ích nổi bật:
                </div>
                <div class="venue-amenities-wrap">
                    <%= amenitiesHtml %>
                </div>
            </div>

            <!-- CỘT PHẢI: GIAO DIỆN FORM ĐẶT LỊCH -->
            <div class="booking-form-box">
                <div class="booking-form-header">
                    <h3><span><span class="app-icon icon-calendar" aria-hidden="true"></span></span> Đặt Lịch Sân Trực Tuyến</h3>
                    <p>Chọn ngày và khung giờ bạn muốn đặt. Đơn sẽ gửi trực tiếp đến chủ sân để xác nhận giữ chỗ.</p>
                </div>

                <form method="post" action="<%= contextPath %>/field-booking" onsubmit="return validateBookingForm()">
                    <input type="hidden" name="fieldId" value="<%= field.getFieldId() %>">

                    <div class="form-group">
                        <label class="form-label" for="bookingDate">Ngày đặt lịch (*)</label>
                        <input type="date" class="form-control" id="bookingDate" name="date"
                               min="<%= todayStr %>" value="<%= todayStr %>" required onchange="calculateEstimate()">
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label" for="bookingStartTime">Giờ bắt đầu (*)</label>
                            <input type="time" class="form-control" id="bookingStartTime" name="startTime"
                                   value="<%= openTimeStr %>" step="1800" required onchange="calculateEstimate()">
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="bookingEndTime">Giờ kết thúc (*)</label>
                            <%
                                int openH = Integer.parseInt(openTimeStr.split(":")[0]);
                                int openM = Integer.parseInt(openTimeStr.split(":")[1]);
                                int defEndH = openH + 1;
                                int defEndM = openM + 30;
                                if (defEndM >= 60) { defEndH += 1; defEndM -= 60; }
                                String defEndTimeStr = String.format("%02d:%02d", defEndH, defEndM);
                            %>
                            <input type="time" class="form-control" id="bookingEndTime" name="endTime"
                                   value="<%= defEndTimeStr %>" step="1800" required onchange="calculateEstimate()">
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="bookingPhone">Số điện thoại liên hệ xác nhận (*)</label>
                        <input type="tel" class="form-control" id="bookingPhone" name="phone"
                               placeholder="Ví dụ: 0901234567" pattern="[0-9+ ]{8,20}"
                               value="<%= user != null && user.getEmail() != null ? "" : "" %>">
                    </div>

                    <!-- BIÊN NHẬN TẠM TÍNH -->
                    <div class="calc-box">
                        <div>
                            <div style="font-size: 13px; color: var(--muted); margin-bottom: 2px;">
                                Đơn giá: <strong><%= vndFormat.format(price) %> đ/giờ</strong>
                            </div>
                            <small id="calcDurationText" style="color: var(--muted); font-size: 12.5px;">Thời lượng: 1.5 giờ</small>
                        </div>
                        <div style="text-align: right;">
                            <div style="font-size: 12px; color: var(--muted);">Tạm tính thanh toán:</div>
                            <div class="calc-price" id="calcPriceText"><%= vndFormat.format(price * 1.5) %> đ</div>
                        </div>
                    </div>

                    <div style="display: flex; gap: 12px; margin-top: 22px;">
                        <a href="<%= contextPath %>/home" class="btn-secondary" style="text-decoration: none; text-align: center; flex: 1; display: inline-flex; align-items: center; justify-content: center;">
                            Hủy bỏ
                        </a>
                        <button type="submit" class="btn-submit" style="flex: 2; font-size: 14px;">
                            Xác nhận gửi yêu cầu đặt lịch <span class="app-icon icon-arrow" aria-hidden="true"></span>
                        </button>
                    </div>
                </form>
            </div>

        </div>

    </main>
</div>

<script>
    const currentFieldPrice = <%= price %>;
    const currentFieldOpen = '<%= openTimeStr %>';
    const currentFieldClose = '<%= closeTimeStr %>';

    function calculateEstimate() {
        const startVal = document.getElementById('bookingStartTime').value;
        const endVal = document.getElementById('bookingEndTime').value;
        if (!startVal || !endVal) return;

        const [sh, sm] = startVal.split(':').map(Number);
        const [eh, em] = endVal.split(':').map(Number);
        const startMinutes = sh * 60 + sm;
        const endMinutes = eh * 60 + em;

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

    function validateBookingForm() {
        const startVal = document.getElementById('bookingStartTime').value;
        const endVal = document.getElementById('bookingEndTime').value;
        if (!startVal || !endVal) {
            alert('Vui lòng chọn giờ bắt đầu và giờ kết thúc.');
            return false;
        }

        const [sh, sm] = startVal.split(':').map(Number);
        const [eh, em] = endVal.split(':').map(Number);
        const startMinutes = sh * 60 + sm;
        const endMinutes = eh * 60 + em;

        if (endMinutes <= startMinutes) {
            alert('Giờ kết thúc phải sau giờ bắt đầu.');
            return false;
        }

        const [oh, om] = currentFieldOpen.split(':').map(Number);
        const [ch, cm] = currentFieldClose.split(':').map(Number);
        const openMinutes = oh * 60 + om;
        const closeMinutes = ch * 60 + cm;

        if (startMinutes < openMinutes || endMinutes > closeMinutes) {
            alert('Khung giờ đặt phải nằm trong giờ mở cửa của sân (' + currentFieldOpen + ' - ' + currentFieldClose + ').');
            return false;
        }

        return true;
    }

    // Run initial calculate
    calculateEstimate();
</script>

</body>
</html>

