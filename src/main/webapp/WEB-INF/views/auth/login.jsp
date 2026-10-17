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

    <title>Đăng nhập - Sportify</title>

    <link rel="stylesheet"
          href="<%= contextPath %>/assets/css/style.css">
          
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/pages/login.css">
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
                <h1>Chào mừng trở lại!</h1>
                <p>Đăng nhập để tiếp tục với Sportify</p>
            </div>
            
            <form action="<%= contextPath %>/login" method="POST">
                <% 
                    String error = request.getParameter("error");
                    String registered = request.getParameter("registered");
                    if ("invalid".equals(error)) {
                %>
                    <div style="color: red; margin-bottom: 15px; text-align: center;">Email hoặc mật khẩu không đúng!</div>
                <% 
                    }
                    if ("true".equals(registered)) {
                %>
                    <div style="color: green; margin-bottom: 15px; text-align: center;">Đăng ký thành công! Hãy đăng nhập.</div>
                <% 
                    }
                %>
                <div class="form-group">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" placeholder="Nhập địa chỉ email" required>
                </div>
                
                <div class="form-group">
                    <label for="password">Mật khẩu</label>
                    <input type="password" id="password" name="password" placeholder="Nhập mật khẩu" required>
                </div>
                
                <div class="form-options">
                    <label>
                        <input type="checkbox" name="remember"> Nhớ mật khẩu
                    </label>
                    <a href="#">Quên mật khẩu?</a>
                </div>
                
                <button type="submit" class="auth-btn">Đăng nhập</button>
            </form>
            
            <div class="auth-links">
                Chưa có tài khoản? <a href="<%= contextPath %>/register">Đăng ký ngay</a>
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

