<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.sportify.data.NotificationDB,com.sportify.model.User,com.sportify.util.Html,java.util.List,java.time.format.DateTimeFormatter" %>
<%
    String contextPath = request.getContextPath();
    String activeMenu = "notifications";
    User user = (User) session.getAttribute("user");
    List<NotificationDB.Item> notifications = (List<NotificationDB.Item>) request.getAttribute("notifications");
    DateTimeFormatter format = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html><html lang="vi"><head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thông báo - Sportify</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/pages/home.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/booking-automation.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/icons.css">
</head><body>
    <%@ include file="/WEB-INF/views/common/sidebar.jspf" %>
    <main class="main-wrapper"><div class="notifications-content">
        <div class="automation-toolbar"><div><h1>Thông báo</h1><p>Kết quả đặt sân và cập nhật từ chủ sân. Hiển thị 50 thông báo gần nhất.</p></div>
            <form method="post" action="<%= contextPath %>/notifications">
                <input type="hidden" name="csrfToken" value="<%= Html.escape(request.getAttribute("csrfToken")) %>">
                <button class="automation-button secondary" type="submit">Đánh dấu tất cả đã đọc</button>
            </form>
            <% if (user.isOwner()) { %><a class="automation-button secondary" href="<%= contextPath %>/owner/calendar">Lịch sân</a><% } %>
        </div>
        <% if (notifications.isEmpty()) { %><div class="automation-panel automation-empty">Bạn chưa có thông báo. Các cập nhật đặt sân sẽ xuất hiện tại đây.</div><% } %>
        <% for (NotificationDB.Item item : notifications) { %>
        <article class="notification-item <%= item.read() ? "" : "unread" %>">
            <h3><%= Html.escape(item.title()) %></h3><p><%= Html.escape(item.body()) %></p>
            <div class="notification-meta"><time><%= item.createdAt().format(format) %></time>
                <% if (item.bookingId() != null) { %><a href="<%= contextPath %><%= user.isOwner() ? "/owner/bookings#booking-section" : "/home#my-bookings" %>">Xem đơn đặt sân</a><% } %>
                <% if (!item.read()) { %><form method="post" action="<%= contextPath %>/notifications">
                    <input type="hidden" name="csrfToken" value="<%= Html.escape(request.getAttribute("csrfToken")) %>">
                    <input type="hidden" name="notificationId" value="<%= item.id() %>">
                    <button class="automation-button secondary" type="submit">Đã đọc</button>
                </form><% } else { %><span>Đã đọc</span><% } %>
            </div>
        </article><% } %>
    </div></main>
</body></html>
