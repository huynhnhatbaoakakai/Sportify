<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.sportify.model.User" %>
<%@ page import="com.sportify.model.Appointment" %>
<%@ page import="java.util.List" %>
<%@ page import="com.sportify.util.Html" %>
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
    <title>Lịch nhắc cá nhân - Sportify</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/pages/appointments.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/icons.css">
</head>
<body>


<% String activeMenu = "appointments"; %>
<%@ include file="/WEB-INF/views/common/sidebar.jspf" %>

<!-- MAIN -->
<div class="main-wrapper">
    <header class="top-navbar">
        <h1 class="page-title"><span class="app-icon icon-calendar" aria-hidden="true"></span> Lịch nhắc cá nhân</h1>
        <a href="<%= contextPath %>/profile" class="user-profile">
            <div class="profile-img"><%= Html.escape(user.getFullname().substring(0,1).toUpperCase()) %></div>
            <div class="profile-name"><%= Html.escape(user.getFullname()) %></div>
        </a>
    </header>

    <div class="content-area">

        <% if (successMsg != null) { %>
        <div class="alert alert-success"><%= Html.escape(successMsg) %></div>
        <% } %>
        <% if (errorMsg != null) { %>
        <div class="alert alert-error"><%= Html.escape(errorMsg) %></div>
        <% } %>
        <% if ("1".equals(request.getParameter("deleted"))) { %>
        <div class="alert alert-success"><span class="app-icon icon-check" aria-hidden="true"></span> Đã xóa lịch nhắc thành công!</div>
        <% } %>

        <%
            String prefillTitle = request.getParameter("title") != null ? request.getParameter("title") : "";
        %>

        <!-- TẠO LỊCH HẸN MỚI -->
        <div class="form-card">
            <h2><span class="app-icon icon-plus" aria-hidden="true"></span> Thêm lịch nhắc đi sân</h2>
            <p class="reminder-help">Lịch nhắc chỉ lưu cho cá nhân. Để chủ sân nhận đơn và giữ chỗ, hãy <a href="<%= contextPath %>/home#fields">chọn sân và đặt lịch</a>.</p>
            <form method="POST" action="<%= contextPath %>/appointments">
                <div class="form-grid">
                    <div class="form-group full">
                        <label><span class="app-icon icon-edit" aria-hidden="true"></span> Tiêu đề lịch nhắc *</label>
                        <input type="text" name="title" value="<%= Html.escape(prefillTitle) %>" placeholder="VD: Chơi bóng rổ cùng nhóm bạn..." required>
                    </div>
                    <div class="form-group">
                        <label><span class="app-icon icon-calendar" aria-hidden="true"></span> Ngày *</label>
                        <input type="date" name="date" required min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                    </div>
                    <div class="form-group">
                        <label><span class="app-icon icon-clock" aria-hidden="true"></span> Giờ *</label>
                        <input type="time" name="time" required>
                    </div>
                    <input type="hidden" name="type" value="court">
                    <div class="form-group full">
                        <label><span class="app-icon icon-pin" aria-hidden="true"></span> Ghi chú (tùy chọn)</label>
                        <textarea name="note" placeholder="Tên sân, nhóm bạn, nội dung cần chuẩn bị..."></textarea>
                    </div>
                </div>
                <div style="margin-top: 18px;">
                    <button type="submit" class="btn-add"><span class="app-icon icon-calendar" aria-hidden="true"></span> Lưu lịch nhắc</button>
                </div>
            </form>
        </div>

        <!-- DANH SÁCH LỊCH HẸN -->
        <div class="list-card">
            <h2><span class="app-icon icon-file" aria-hidden="true"></span> Danh sách lịch nhắc cá nhân</h2>

            <div class="tab-bar">
                <button class="tab-btn active" onclick="switchTab('upcoming', this)"><span class="app-icon icon-arrow" aria-hidden="true"></span> Sắp tới</button>
                <button class="tab-btn" onclick="switchTab('past', this)"><span class="app-icon icon-folder" aria-hidden="true"></span> Đã qua</button>
            </div>

            <%
                java.time.LocalDate today = java.time.LocalDate.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh"));
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
                    <div class="big-icon"><span class="app-icon icon-inbox" aria-hidden="true"></span></div>
                    <p>Chưa có lịch nhắc nào sắp tới.<br>Hãy tạo lịch nhắc đầu tiên ở trên!</p>
                </div>
                <% } else {
                    for (Appointment a : allAppts) {
                        if (a.getAppointmentDate() == null || a.getAppointmentDate().compareTo(today.toString()) < 0) continue;
                        String badgeClass = "badge-court";
                        String tagClass = "tag-court";
                        String icon = "court";
                        String label = "Nhắc đi sân";
                %>
                <div class="appt-item">
                    <div class="appt-type-badge <%= badgeClass %>">
                        <span class="app-icon icon-<%= icon %>" aria-hidden="true"></span>
                    </div>
                    <div class="appt-info">
                        <div class="appt-title"><%= Html.escape(a.getTitle()) %></div>
                        <div class="appt-meta">
                            <span class="appt-meta-item"><span class="app-icon icon-calendar" aria-hidden="true"></span> <%= a.getAppointmentDate() %></span>
                            <span class="appt-meta-item"><span class="app-icon icon-clock" aria-hidden="true"></span> <%= a.getAppointmentTime() %></span>
                            <span class="appt-tag <%= tagClass %>">
                                <%= label %>
                            </span>
                        </div>
                        <% if (a.getNote() != null && !a.getNote().isEmpty()) { %>
                        <div style="font-size: 12px; color: var(--muted); margin-top: 5px;"><span class="app-icon icon-pin" aria-hidden="true"></span> <%= Html.escape(a.getNote()) %></div>
                        <% } %>
                    </div>
                    <a href="<%= contextPath %>/appointments/delete?id=<%= a.getId() %>"
                       onclick="return confirm('Xóa lịch nhắc này?')"
                       class="btn-delete"><span class="app-icon icon-trash" aria-hidden="true"></span> Xóa</a>
                </div>
                <% }} %>
            </div>

            <!-- Tab Đã qua -->
            <div class="tab-content" id="tab-past">
                <% if (!hasPast) { %>
                <div class="empty-list">
                    <div class="big-icon"><span class="app-icon icon-folder" aria-hidden="true"></span></div>
                    <p>Chưa có lịch nhắc nào đã qua.</p>
                </div>
                <% } else {
                    for (Appointment a : allAppts) {
                        if (a.getAppointmentDate() == null || a.getAppointmentDate().compareTo(today.toString()) >= 0) continue;
                        String badgeClass = "badge-court";
                        String tagClass = "tag-court";
                        String icon = "court";
                        String label = "Nhắc đi sân";
                %>
                <div class="appt-item past-appt">
                    <div class="appt-type-badge <%= badgeClass %>">
                        <%= icon %>
                    </div>
                    <div class="appt-info">
                        <div class="appt-title"><%= Html.escape(a.getTitle()) %></div>
                        <div class="appt-meta">
                            <span class="appt-meta-item"><span class="app-icon icon-calendar" aria-hidden="true"></span> <%= a.getAppointmentDate() %></span>
                            <span class="appt-meta-item"><span class="app-icon icon-clock" aria-hidden="true"></span> <%= a.getAppointmentTime() %></span>
                            <span class="appt-tag <%= tagClass %>">
                                <%= label %>
                            </span>
                        </div>
                        <% if (a.getNote() != null && !a.getNote().isEmpty()) { %>
                        <div style="font-size: 12px; color: var(--muted); margin-top: 5px;"><span class="app-icon icon-pin" aria-hidden="true"></span> <%= Html.escape(a.getNote()) %></div>
                        <% } %>
                    </div>
                    <a href="<%= contextPath %>/appointments/delete?id=<%= a.getId() %>"
                       onclick="return confirm('Xóa lịch nhắc này?')"
                       class="btn-delete"><span class="app-icon icon-trash" aria-hidden="true"></span> Xóa</a>
                </div>
                <% }} %>
            </div>
        </div>
    </div>
</div>

<script src="<%= contextPath %>/assets/js/pages/appointments.js"></script>
</body>
</html>

