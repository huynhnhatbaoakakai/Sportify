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
            <div class="profile-img"><%= com.sportify.util.Html.escape(currentUser.getFullname().substring(0,1).toUpperCase()) %></div>
            <div class="profile-name"><%= com.sportify.util.Html.escape(currentUser.getFullname()) %></div>
        </a>
    </header>

    <div class="feed-content">

        <!-- CREATE POST -->
        <div class="create-post-box">
            <div class="create-post-header">
                <div class="create-post-avatar"><%= com.sportify.util.Html.escape(currentUser.getFullname().substring(0,1).toUpperCase()) %></div>
                <span style="font-weight:600; color:var(--dark);">Bạn đang nghĩ gì, <%= com.sportify.util.Html.escape(currentUser.getFullname()) %>?</span>
            </div>
            <textarea id="postContent" class="create-post-input"
                      placeholder="Chia sẻ hoạt động thể thao, rủ hội nhóm giao lưu hoặc nhượng lại lịch đặt sân của bạn..."></textarea>

            <!-- KHUNG XEM TRƯỚC LỊCH SÂN ĐÍNH KÈM -->
            <div id="attachedBookingPreview" style="display:none; margin-top:12px; background:linear-gradient(145deg,#f0fdf4,#ffffff); border:2px solid #86efac; border-radius:14px; padding:14px 16px;">
            </div>

            <!-- BẢNG CHỌN LỊCH ĐẶT SÂN ĐÃ XÁC NHẬN CỦA TÔI -->
            <div id="bookingSelectorPanel" style="display:none; margin-top:12px; background:#f8fafc; border:1.5px solid #cbd5e1; border-radius:14px; padding:14px 16px;">
                <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:10px;">
                    <strong style="font-size:13.5px; color:#0f172a;">💎 Chọn lịch đặt sân đã xác nhận của bạn để đính kèm:</strong>
                    <button type="button" onclick="toggleBookingSelector(false)" style="background:none; border:none; color:#64748b; cursor:pointer; font-weight:700;">Đóng ✕</button>
                </div>
                <div id="myConfirmedBookingsList" style="display:flex; flex-direction:column; gap:8px; max-height:220px; overflow-y:auto;">
                    <div style="font-size:13px; color:#64748b; padding:10px;">Đang tải lịch đặt sân...</div>
                </div>
            </div>

            <div class="create-post-footer" style="display:flex; align-items:center; justify-content:space-between; gap:10px; flex-wrap:wrap; margin-top:12px;">
                <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
                    <button type="button" onclick="toggleBookingSelector()"
                            style="display:inline-flex; align-items:center; gap:6px; background:#f0fdf4; color:#15803d; border:1.5px solid #86efac; border-radius:10px; padding:8px 14px; font-size:13px; font-weight:700; cursor:pointer;">
                        🏟️ Đính kèm lịch đặt sân (Rủ nhóm / Rao bán)
                    </button>
                </div>
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
    const ME_NAME = <%= com.sportify.util.JsonResponse.getGson().toJson(currentUser.getFullname()) %>;
</script>
<script src="<%= contextPath %>/assets/js/pages/newsfeed.js?v=<%= System.currentTimeMillis() %>"></script>
</body>
</html>

