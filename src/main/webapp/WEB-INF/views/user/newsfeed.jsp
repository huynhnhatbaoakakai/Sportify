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
    <title>Newsfeed - Sportify</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/pages/newsfeed.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/icons.css">
</head>
<body>


<% String activeMenu = "newsfeed"; %>
<%@ include file="/WEB-INF/views/common/sidebar.jspf" %>

<!-- MAIN CONTENT -->
<div class="main-wrapper">
    <header class="top-navbar">
        <h1 class="page-title"><span class="app-icon icon-news" aria-hidden="true"></span> Newsfeed</h1>
        <a href="<%= contextPath %>/profile" class="user-profile">
            <div class="profile-img"><%= currentUser.getFullname().substring(0,1).toUpperCase() %></div>
            <div class="profile-name"><%= currentUser.getFullname() %></div>
        </a>
    </header>

    <div class="feed-content">

        <!-- CREATE POST -->
        <div class="create-post-box">
            <div class="create-post-header">
                <div class="create-post-avatar"><%= currentUser.getFullname().substring(0,1).toUpperCase() %></div>
                <span style="font-weight:600; color:var(--dark);">Bạn đang nghĩ gì, <%= currentUser.getFullname() %>?</span>
            </div>
            <textarea id="postContent" class="create-post-input"
                      placeholder="Chia sẻ hoạt động thể thao của bạn hôm nay..."></textarea>
            <div class="create-post-footer">
                <button class="post-submit-btn" id="postBtn" onclick="createPost()">Đăng ngay</button>
            </div>
        </div>

        <!-- FEED LIST -->
        <div id="feedList">
            <div class="feed-loading"><span class="app-icon icon-clock" aria-hidden="true"></span> Đang tải bài viết...</div>
        </div>

    </div>
</div>

<script>
    // Giá trị từ server cho file JS của trang
    const CTX = '<%= contextPath %>';
    const ME_ID = <%= currentUser.getId() %>;
    const ME_NAME = '<%= currentUser.getFullname().replace("'", "\\'") %>';
</script>
<script src="<%= contextPath %>/assets/js/pages/newsfeed.js"></script>
</body>
</html>

