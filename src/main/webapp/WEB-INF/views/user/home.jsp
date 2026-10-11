<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.sportify.model.User" %>
<%@ page import="com.sportify.model.Appointment" %>
<%@ page import="java.util.List" %>
<%-- Controller: com.sportify.controller.home.HomeServlet (GET /home) --%>
<%
    String contextPath = request.getContextPath();
    User user = (User) session.getAttribute("user");

    int upcomingCount = (Integer) request.getAttribute("upcomingCount");
    int trainingHours = (Integer) request.getAttribute("trainingHours");
    @SuppressWarnings("unchecked")
    List<Appointment> upcomingAppts = (List<Appointment>) request.getAttribute("upcomingAppts");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang chủ - Sportify</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/pages/home.css">
</head>
<body>


<% String activeMenu = "home"; %>
<%@ include file="/WEB-INF/views/common/sidebar.jspf" %>

<div class="main-wrapper">
    <header class="top-navbar">
        <h1 class="page-title">Tổng quan</h1>
        <a href="<%= contextPath %>/profile" class="user-profile">
            <div class="profile-img"><%= user.getFullname().substring(0,1).toUpperCase() %></div>
            <div class="profile-name"><%= user.getFullname() %></div>
        </a>
    </header>

    <main class="content-area">
        <!-- WELCOME -->
        <div class="welcome-card">
            <div>
                <h2>Chào bạn, <%= user.getFullname() %>! 👋</h2>
                <p>Hôm nay là một ngày tuyệt vời để tập luyện.</p>
            </div>
            <div style="font-size: 75px;">🏃‍♂️</div>
        </div>

        <!-- STATS CARDS -->
        <div class="stats-grid">
            <!-- Lịch hẹn sắp tới - click sang appointments.jsp -->
            <a href="<%= contextPath %>/appointments" class="stat-card">
                <div class="stat-icon" style="background: var(--primary-light); color: var(--primary);">📅</div>
                <div class="stat-info">
                    <h4>Lịch hẹn sắp tới</h4>
                    <span><%= upcomingCount %></span>
                    <small><%= upcomingCount == 0 ? "Chưa có lịch nào" : "lịch đang chờ" %></small>
                </div>
            </a>

            <!-- Giờ tập tháng này - từ database -->
            <a href="<%= contextPath %>/appointments" class="stat-card">
                <div class="stat-icon" style="background: #fef3c7; color: #d97706;">🔥</div>
                <div class="stat-info">
                    <h4>Giờ tập tháng này</h4>
                    <span><%= trainingHours %>h</span>
                    <small><%= trainingHours == 0 ? "Hãy bắt đầu tập luyện!" : "giờ đã tập" %></small>
                </div>
            </a>
        </div>

        <!-- LỊCH HẸN SẮP TỚI -->
        <div class="section-header">
            <h3>📋 Lịch hẹn sắp tới</h3>
            <a href="<%= contextPath %>/appointments">Xem tất cả →</a>
        </div>

        <% if (upcomingAppts.isEmpty()) { %>
        <div class="empty-appt">
            📭 Chưa có lịch hẹn nào sắp tới.<br>
            <a href="<%= contextPath %>/appointments" style="color: var(--primary); font-weight: 600;">+ Thêm lịch hẹn ngay</a>
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
                <%= icon %>
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
