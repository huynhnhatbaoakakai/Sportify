<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%
    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Đăng ký tài khoản - Sportify</title>

    <link rel="stylesheet"
          href="<%= contextPath %>/assets/css/style.css">
          
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/pages/register.css">
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/icons.css">
</head>

<body>

<header class="header">
    <div class="container navbar">
        <a class="brand" href="<%= contextPath %>/">
            <span class="brand-icon">S</span>
            <span>SPORTIFY</span>
        </a>
    </div>
</header>

<main>
    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <h1>Tạo tài khoản mới</h1>
                <p>Tham gia Sportify để trải nghiệm dịch vụ</p>
            </div>
            
            <form action="<%= contextPath %>/register" method="POST">
                <% 
                    String error = request.getParameter("error");
                    if ("password_mismatch".equals(error)) {
                %>
                    <div style="color: red; margin-bottom: 15px; text-align: center;">Mật khẩu xác nhận không khớp!</div>
                <% 
                    } else if ("email_exists".equals(error)) {
                %>
                    <div style="color: red; margin-bottom: 15px; text-align: center;">Email đã được sử dụng!</div>
                <% 
                    } else if ("db_error".equals(error)) {
                %>
                    <div style="color: red; margin-bottom: 15px; text-align: center;">Lỗi kết nối CSDL. Vui lòng kiểm tra lại cấu hình SQL!</div>
                <% 
                    }
                %>
                <div class="form-group">
                    <label for="fullname">Họ và tên</label>
                    <input type="text" id="fullname" name="fullname" placeholder="Nhập họ và tên của bạn" required>
                </div>
                
                <div class="form-group">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" placeholder="Nhập địa chỉ email" required>
                </div>
                
                <div class="form-group">
                    <label for="password">Mật khẩu</label>
                    <input type="password" id="password" name="password" placeholder="Tạo mật khẩu" required minlength="6">
                </div>
                
                <div class="form-group">
                    <label for="confirm_password">Xác nhận mật khẩu</label>
                    <input type="password" id="confirm_password" name="confirm_password" placeholder="Nhập lại mật khẩu" required minlength="6">
                </div>
                
                <button type="submit" class="auth-btn">Đăng ký ngay</button>
            </form>
            
            <div class="auth-links">
                Đã có tài khoản? <a href="<%= contextPath %>/login">Đăng nhập</a>
            </div>
        </div>
    </div>
</main>

<footer class="footer" style="padding: 20px 0; background: var(--white); color: var(--muted); border-top: 1px solid var(--border);">
    <div class="copyright" style="border: none; padding: 0;">
        © 2026 Sportify. Đồ án môn Web Programming.
    </div>
</footer>

</body>
</html>

