<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="com.sportify.model.User" %>
<%
    String contextPath = request.getContextPath();
    User user = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tin nhắn - Sportify</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/pages/chat.css">
</head>
<body>

<header class="header">
    <div class="container navbar" style="min-height: 60px;">
        <a class="brand" href="<%= contextPath %>/home">
            <span class="brand-icon" style="width: 30px; height: 30px; font-size: 16px;">S</span>
            <span style="font-size: 18px;">SPORTIFY</span>
        </a>
        <nav class="nav-links">
            <a href="<%= contextPath %>/home">Trang chủ</a>
            <a href="<%= contextPath %>/appointments">Lịch đặt</a>
            <a href="<%= contextPath %>/chat" style="color: var(--primary); font-weight: bold;">Tin nhắn</a>
        </nav>
        <div style="display: flex; align-items: center; gap: 10px;">
            <div class="avatar" style="width: 35px; height: 35px; font-size: 16px; background: var(--primary-light); color: var(--primary);">
                <%= user != null && user.getFullname() != null && !user.getFullname().isEmpty() ? user.getFullname().substring(0, 1).toUpperCase() : "U" %>
            </div>
            <span style="font-size: 14px; font-weight: 600;"><%= user != null ? user.getFullname() : "Người dùng" %></span>
        </div>
    </div>
</header>

<main class="chat-layout">
    <!-- Sidebar -->
    <aside class="chat-sidebar">
        <div class="chat-sidebar-header">
            <h2>Tin nhắn Dịch vụ</h2>
        </div>
        <div class="chat-search">
            <input type="text" placeholder="Tìm kiếm hội thoại...">
        </div>
        
        <div class="chat-list" id="chatList">
            <!-- Items rendered via JS -->
        </div>
    </aside>

    <!-- Main Chat -->
    <section class="chat-main">
        <div class="chat-header">
            <div class="avatar avatar-online" id="currentChatAvatar">🏢</div>
            <div class="chat-header-info">
                <h3><span id="currentChatName">Sân bóng Sunrise</span> <span class="chat-item-role role-court" id="currentChatRole" style="font-size: 10px; margin-left: 8px;">Chủ sân</span></h3>
                <div class="status">Đang hoạt động</div>
            </div>
        </div>

        <div class="chat-messages" id="chatMessages">
            <!-- Messages rendered via JS -->
        </div>

        <div class="chat-input-area">
            <button class="attach-btn" title="Đính kèm hình ảnh/file">📎</button>
            <input type="text" id="messageInput" class="chat-input" placeholder="Nhập tin nhắn..." onkeypress="handleEnter(event)">
            <button class="send-btn" title="Gửi" onclick="sendMessage()">➤</button>
        </div>
    </section>
</main>

<script>
    // Giá trị từ server cho file JS của trang
    const CTX = '<%= contextPath %>';
</script>
<script src="<%= contextPath %>/assets/js/pages/chat.js"></script>
</body>
</html>
