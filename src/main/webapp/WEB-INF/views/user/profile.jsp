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
    <title>Hồ sơ cá nhân - Sportify</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/pages/profile.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/icons.css">
</head>
<body>


<% String activeMenu = "profile"; %>
<%@ include file="/WEB-INF/views/common/sidebar.jspf" %>

    <!-- MAIN CONTENT -->
    <div class="main-wrapper">
        <header class="top-navbar">
            <h1 class="page-title">Thông tin tài khoản</h1>
        </header>
        
        <main class="content-area">
            <div class="profile-container">
                <div class="profile-header">
                    <div class="profile-avatar-large">
                        <%= user.getFullname().substring(0,1).toUpperCase() %>
                        <div class="edit-avatar-btn" title="Thay đổi ảnh đại diện"><span class="app-icon icon-edit" aria-hidden="true"></span></div>
                    </div>
                    <div class="profile-title">
                        <h2><%= user.getFullname() %></h2>
                        <p>Thành viên từ Tháng 9, 2026</p>
                    </div>
                </div>
                
                <div class="profile-body">
                    <form action="#" method="POST">
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="fullname">Họ và tên</label>
                                <input type="text" id="fullname" value="<%= user.getFullname() %>">
                            </div>
                            
                            <div class="form-group">
                                <label for="phone">Số điện thoại</label>
                                <input type="tel" id="phone" value="">
                            </div>
                            
                            <div class="form-group full-width">
                                <label for="email">Địa chỉ Email</label>
                                <input type="email" id="email" value="<%= user.getEmail() %>" readonly style="background: #f1f5f9; cursor: not-allowed;">
                            </div>
                            
                            <div class="form-group">
                                <label for="gender">Giới tính</label>
                                <select id="gender">
                                    <option value="male" selected>Nam</option>
                                    <option value="female">Nữ</option>
                                    <option value="other">Khác</option>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label for="dob">Ngày sinh</label>
                                <input type="date" id="dob" value="2000-01-01">
                            </div>
                            
                            <div class="form-group full-width">
                                <label for="address">Địa chỉ</label>
                                <textarea id="address" rows="3">Quận 7, TP. Hồ Chí Minh</textarea>
                            </div>
                        </div>
                        
                        <div class="form-actions">
                            <button type="button" class="btn-cancel">Hủy</button>
                            <button type="submit" class="btn-save">Lưu thay đổi</button>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </div>

</body>
</html>

