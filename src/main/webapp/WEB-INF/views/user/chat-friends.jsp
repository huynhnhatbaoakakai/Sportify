<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%@ page import="com.sportify.model.User" %>
<%
    String contextPath = request.getContextPath();
    User currentUser = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat với Bạn bè - Sportify</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/pages/chat-friends.css">
</head>
<body>


<% String activeMenu = "chat-friends"; %>
<%@ include file="/WEB-INF/views/common/sidebar.jspf" %>

    <!-- CHAT CONTAINER -->
    <div class="chat-container">
        <!-- Friends List -->
        <aside class="chat-sidebar">
            <div class="chat-sidebar-header">
                <h2>👥 Bạn bè (<span id="friendCount">...</span>)</h2>
            </div>
            <div class="chat-list" id="chatList">
                <div style="padding:20px; color:#999; font-size:13px;">Đang tải danh sách...</div>
            </div>
        </aside>

        <!-- Chat Area -->
        <section class="chat-main">
            <div class="chat-header">
                <div class="avatar avatar-online" id="currentAvatar">?</div>
                <div class="chat-header-info">
                    <h3 id="currentName">Chọn một người để nhắn tin</h3>
                    <div class="status" id="currentStatus"></div>
                </div>
            </div>

            <div class="chat-messages" id="chatMessages">
                <div class="chat-empty">← Chọn một người bạn để bắt đầu trò chuyện</div>
            </div>

            <div id="statusBar"></div>

            <div class="chat-input-area">
                <input type="text" id="messageInput" class="chat-input"
                       placeholder="Nhập tin nhắn... (Enter để gửi)"
                       onkeypress="handleEnter(event)" disabled>
                <button class="send-btn" id="sendBtn" onclick="sendMessage()" disabled>➤</button>
            </div>
        </section>
    </div>

<script>
    // Giá trị từ server cho file JS của trang
    const CTX = '<%= contextPath %>';
    const ME_ID = <%= currentUser.getId() %>;
</script>
<script src="<%= contextPath %>/assets/js/pages/chat-friends.js"></script>
</body>
</html>
