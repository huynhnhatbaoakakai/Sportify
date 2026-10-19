<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.sportify.model.User" %>
<%@ page import="com.sportify.util.Html" %>
<%
    String contextPath = request.getContextPath();
    User user = (User) session.getAttribute("user");
    User profile = (User) request.getAttribute("profile");
    if (profile == null) profile = user;
    String fullname = profile.getFullname() == null ? "" : profile.getFullname();
    String initial = fullname.isBlank() ? "U" : fullname.substring(0, 1).toUpperCase();
    String gender = profile.getGender() == null ? "" : profile.getGender();
    String birthDate = request.getAttribute("profileDob") != null ? request.getAttribute("profileDob").toString()
            : profile.getDateOfBirth() == null ? "" : profile.getDateOfBirth().toString();
    String today = java.time.LocalDate.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh")).toString();
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
<div class="main-wrapper">
    <header class="top-navbar"><h1 class="page-title">Thông tin tài khoản</h1></header>
    <main class="content-area">
        <% if (request.getAttribute("successMsg") != null) { %>
        <div class="profile-message success" role="status"><%= Html.escape(request.getAttribute("successMsg")) %></div>
        <% } %>
        <% if (request.getAttribute("errorMsg") != null) { %>
        <div class="profile-message error" role="alert"><%= Html.escape(request.getAttribute("errorMsg")) %></div>
        <% } %>
        <div class="profile-container">
            <div class="profile-header">
                <div class="profile-avatar-large" aria-hidden="true"><%= Html.escape(initial) %></div>
                <div class="profile-title">
                    <h2><%= Html.escape(fullname) %></h2>
                    <p><%= profile.getCreatedAt() == null ? "Thành viên Sportify"
                            : "Thành viên từ " + profile.getCreatedAt().format(java.time.format.DateTimeFormatter.ofPattern("MM/yyyy")) %></p>
                </div>
            </div>
            <div class="profile-body">
                <form action="<%= contextPath %>/profile" method="post">
                    <input type="hidden" name="csrfToken" value="<%= Html.escape(request.getAttribute("csrfToken")) %>">
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="fullname">Họ và tên <span aria-hidden="true">*</span></label>
                            <input type="text" id="fullname" name="fullname" value="<%= Html.escape(fullname) %>" required maxlength="100" autocomplete="name">
                        </div>
                        <div class="form-group">
                            <label for="phone">Số điện thoại</label>
                            <input type="tel" id="phone" name="phone" value="<%= Html.escape(profile.getPhone()) %>" maxlength="20" autocomplete="tel" placeholder="Ví dụ: 0901234567" aria-describedby="phoneHelp">
                            <small id="phoneHelp">8–15 chữ số, có thể bắt đầu bằng dấu +.</small>
                        </div>
                        <div class="form-group full-width">
                            <label for="email">Địa chỉ email</label>
                            <input type="email" id="email" value="<%= Html.escape(profile.getEmail()) %>" readonly class="readonly-input" autocomplete="email" aria-describedby="emailHelp">
                            <small id="emailHelp">Email đăng nhập được giữ cố định.</small>
                        </div>
                        <div class="form-group">
                            <label for="gender">Giới tính</label>
                            <select id="gender" name="gender">
                                <option value="" <%= gender.isEmpty() ? "selected" : "" %>>Chưa chọn</option>
                                <option value="male" <%= "male".equals(gender) ? "selected" : "" %>>Nam</option>
                                <option value="female" <%= "female".equals(gender) ? "selected" : "" %>>Nữ</option>
                                <option value="other" <%= "other".equals(gender) ? "selected" : "" %>>Khác</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="dob">Ngày sinh</label>
                            <input type="date" id="dob" name="dob" value="<%= Html.escape(birthDate) %>" max="<%= today %>" autocomplete="bday">
                        </div>
                        <div class="form-group full-width">
                            <label for="address">Địa chỉ</label>
                            <textarea id="address" name="address" rows="3" maxlength="500" autocomplete="street-address" placeholder="Nhập địa chỉ của bạn"><%= Html.escape(profile.getAddress()) %></textarea>
                        </div>
                    </div>
                    <div class="form-actions">
                        <a href="<%= contextPath %>/profile" class="btn-cancel">Hủy thay đổi</a>
                        <button type="submit" class="btn-save">Lưu thay đổi</button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</div>
</body>
</html>

