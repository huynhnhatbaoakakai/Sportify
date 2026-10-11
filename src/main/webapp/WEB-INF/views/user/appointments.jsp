<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.sportify.model.User" %>
<%@ page import="com.sportify.model.Appointment" %>
<%@ page import="java.util.List" %>
<%-- Controller: com.sportify.controller.appointment.AppointmentServlet (/appointments) --%>
<%
    String contextPath = request.getContextPath();
    User user = (User) session.getAttribute("user");

    String successMsg = (String) request.getAttribute("successMsg");
    String errorMsg = (String) request.getAttribute("errorMsg");
    @SuppressWarnings("unchecked")
    List<Appointment> allAppts = (List<Appointment>) request.getAttribute("allAppts");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch hẹn - Sportify</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/pages/appointments.css">
</head>
<body>


<% String activeMenu = "appointments"; %>
<%@ include file="/WEB-INF/views/common/sidebar.jspf" %>

<!-- MAIN -->
<div class="main-wrapper">
    <header class="top-navbar">
        <h1 class="page-title">📅 Lịch hẹn</h1>
        <a href="<%= contextPath %>/profile" class="user-profile">
            <div class="profile-img"><%= user.getFullname().substring(0,1).toUpperCase() %></div>
            <div class="profile-name"><%= user.getFullname() %></div>
        </a>
    </header>

    <div class="content-area">

        <% if (successMsg != null) { %>
        <div class="alert alert-success"><%= successMsg %></div>
        <% } %>
        <% if (errorMsg != null) { %>
        <div class="alert alert-error"><%= errorMsg %></div>
        <% } %>
        <% if ("1".equals(request.getParameter("deleted"))) { %>
        <div class="alert alert-success">✅ Đã xóa lịch hẹn thành công!</div>
        <% } %>

        <%
            String prefillTitle = request.getParameter("title") != null ? request.getParameter("title") : "";
            String prefillType = request.getParameter("type") != null ? request.getParameter("type") : "court";
        %>

        <!-- TẠO LỊCH HẸN MỚI -->
        <div class="form-card">
            <h2>➕ Thêm lịch hẹn & Đặt dịch vụ mới</h2>
            <form method="POST" action="<%= contextPath %>/appointments">
                <div class="form-grid">
                    <div class="form-group full">
                        <label>📝 Tiêu đề dịch vụ / lịch hẹn *</label>
                        <input type="text" name="title" value="<%= prefillTitle %>" placeholder="VD: Đặt sân bóng Sunrise, Tập PT với thầy Anh, Thuê vợt Pickleball..." required>
                    </div>
                    <div class="form-group">
                        <label>📅 Ngày *</label>
                        <input type="date" name="date" required min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                    </div>
                    <div class="form-group">
                        <label>⏰ Giờ *</label>
                        <input type="time" name="time" required>
                    </div>
                    <div class="form-group full">
                        <label>🏷️ Loại dịch vụ *</label>
                        <div class="type-options">
                            <label class="type-option">
                                <input type="radio" name="type" value="court" <%= "court".equals(prefillType) ? "checked" : "" %>>
                                ⚽ Đặt sân
                            </label>
                            <label class="type-option">
                                <input type="radio" name="type" value="pt" <%= "pt".equals(prefillType) ? "checked" : "" %>>
                                💪 Thuê PT
                            </label>
                            <label class="type-option">
                                <input type="radio" name="type" value="gear" <%= "gear".equals(prefillType) ? "checked" : "" %>>
                                🎒 Thuê Gear
                            </label>
                            <label class="type-option">
                                <input type="radio" name="type" value="clothing" <%= "clothing".equals(prefillType) ? "checked" : "" %>>
                                👕 Thuê Trang phục
                            </label>
                        </div>
                    </div>
                    <div class="form-group full">
                        <label>📌 Ghi chú (tùy chọn)</label>
                        <textarea name="note" placeholder="Sân 5 người, cỡ áo L, mang theo bóng tập..."></textarea>
                    </div>
                </div>
                <div style="margin-top: 18px;">
                    <button type="submit" class="btn-add">📅 Lưu lịch hẹn / Đặt chỗ</button>
                </div>
            </form>
        </div>

        <!-- DANH SÁCH LỊCH HẸN -->
        <div class="list-card">
            <h2>📋 Danh sách lịch hẹn & Đặt chỗ</h2>

            <div class="tab-bar">
                <button class="tab-btn active" onclick="switchTab('upcoming', this)">🔜 Sắp tới</button>
                <button class="tab-btn" onclick="switchTab('past', this)">📂 Đã qua</button>
            </div>

            <%
                java.time.LocalDate today = java.time.LocalDate.now();
                boolean hasUpcoming = false;
                boolean hasPast = false;
                for (Appointment a : allAppts) {
                    if (a.getAppointmentDate() != null && a.getAppointmentDate().compareTo(today.toString()) >= 0) hasUpcoming = true;
                    else hasPast = true;
                }
            %>

            <!-- Tab Sắp tới -->
            <div class="tab-content active" id="tab-upcoming">
                <% if (!hasUpcoming) { %>
                <div class="empty-list">
                    <div class="big-icon">📭</div>
                    <p>Chưa có lịch hẹn nào sắp tới.<br>Hãy tạo lịch hẹn đầu tiên ở trên!</p>
                </div>
                <% } else {
                    for (Appointment a : allAppts) {
                        if (a.getAppointmentDate() == null || a.getAppointmentDate().compareTo(today.toString()) < 0) continue;
                        String itemType = a.getType() != null ? a.getType() : "court";
                        String badgeClass = "badge-court";
                        String tagClass = "tag-court";
                        String icon = "⚽";
                        String label = "Đặt sân";
                        if ("pt".equals(itemType)) {
                            badgeClass = "badge-pt";
                            tagClass = "tag-pt";
                            icon = "💪";
                            label = "Tập PT";
                        } else if ("gear".equals(itemType)) {
                            badgeClass = "badge-gear";
                            tagClass = "tag-gear";
                            icon = "🎒";
                            label = "Thuê Gear";
                        } else if ("clothing".equals(itemType)) {
                            badgeClass = "badge-clothing";
                            tagClass = "tag-clothing";
                            icon = "👕";
                            label = "Thuê Trang phục";
                        }
                %>
                <div class="appt-item">
                    <div class="appt-type-badge <%= badgeClass %>">
                        <%= icon %>
                    </div>
                    <div class="appt-info">
                        <div class="appt-title"><%= a.getTitle() %></div>
                        <div class="appt-meta">
                            <span class="appt-meta-item">📅 <%= a.getAppointmentDate() %></span>
                            <span class="appt-meta-item">⏰ <%= a.getAppointmentTime() %></span>
                            <span class="appt-tag <%= tagClass %>">
                                <%= label %>
                            </span>
                        </div>
                        <% if (a.getNote() != null && !a.getNote().isEmpty()) { %>
                        <div style="font-size: 12px; color: var(--muted); margin-top: 5px;">📌 <%= a.getNote() %></div>
                        <% } %>
                    </div>
                    <a href="<%= contextPath %>/appointments/delete?id=<%= a.getId() %>"
                       onclick="return confirm('Xóa lịch hẹn này?')"
                       class="btn-delete">🗑️ Xóa</a>
                </div>
                <% }} %>
            </div>

            <!-- Tab Đã qua -->
            <div class="tab-content" id="tab-past">
                <% if (!hasPast) { %>
                <div class="empty-list">
                    <div class="big-icon">📂</div>
                    <p>Chưa có lịch hẹn nào đã qua.</p>
                </div>
                <% } else {
                    for (Appointment a : allAppts) {
                        if (a.getAppointmentDate() == null || a.getAppointmentDate().compareTo(today.toString()) >= 0) continue;
                        String itemType = a.getType() != null ? a.getType() : "court";
                        String badgeClass = "badge-court";
                        String tagClass = "tag-court";
                        String icon = "⚽";
                        String label = "Đặt sân";
                        if ("pt".equals(itemType)) {
                            badgeClass = "badge-pt";
                            tagClass = "tag-pt";
                            icon = "💪";
                            label = "Tập PT";
                        } else if ("gear".equals(itemType)) {
                            badgeClass = "badge-gear";
                            tagClass = "tag-gear";
                            icon = "🎒";
                            label = "Thuê Gear";
                        } else if ("clothing".equals(itemType)) {
                            badgeClass = "badge-clothing";
                            tagClass = "tag-clothing";
                            icon = "👕";
                            label = "Thuê Trang phục";
                        }
                %>
                <div class="appt-item past-appt">
                    <div class="appt-type-badge <%= badgeClass %>">
                        <%= icon %>
                    </div>
                    <div class="appt-info">
                        <div class="appt-title"><%= a.getTitle() %></div>
                        <div class="appt-meta">
                            <span class="appt-meta-item">📅 <%= a.getAppointmentDate() %></span>
                            <span class="appt-meta-item">⏰ <%= a.getAppointmentTime() %></span>
                            <span class="appt-tag <%= tagClass %>">
                                <%= label %>
                            </span>
                        </div>
                        <% if (a.getNote() != null && !a.getNote().isEmpty()) { %>
                        <div style="font-size: 12px; color: var(--muted); margin-top: 5px;">📌 <%= a.getNote() %></div>
                        <% } %>
                    </div>
                    <a href="<%= contextPath %>/appointments/delete?id=<%= a.getId() %>"
                       onclick="return confirm('Xóa lịch hẹn này?')"
                       class="btn-delete">🗑️ Xóa</a>
                </div>
                <% }} %>
            </div>
        </div>
    </div>
</div>

<script src="<%= contextPath %>/assets/js/pages/appointments.js"></script>
</body>
</html>

