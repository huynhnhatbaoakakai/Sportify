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
          
    <style>
        .auth-container {
            min-height: calc(100vh - 72px - 100px);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 60px 20px;
        }
        
        .auth-card {
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 18px;
            box-shadow: var(--shadow);
            width: 100%;
            max-width: 440px;
            padding: 40px;
        }
        
        .auth-header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .auth-header h1 {
            color: var(--dark);
            font-size: 28px;
            margin-bottom: 8px;
        }
        
        .auth-header p {
            color: var(--muted);
            font-size: 15px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--text);
            font-size: 14px;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid var(--border);
            border-radius: 10px;
            background: var(--background);
            transition: 0.2s;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px var(--primary-light);
            background: var(--white);
        }
        
        .form-options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            font-size: 14px;
        }
        
        .form-options label {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            color: var(--muted);
        }
        
        .form-options a {
            color: var(--primary);
            font-weight: 600;
        }
        
        .form-options a:hover {
            text-decoration: underline;
        }
        
        .auth-btn {
            width: 100%;
            padding: 14px;
            border: none;
            border-radius: 10px;
            background: var(--primary);
            color: var(--white);
            font-weight: 700;
            font-size: 16px;
            cursor: pointer;
            transition: 0.2s;
        }
        
        .auth-btn:hover {
            background: var(--primary-dark);
        }
        
        .auth-links {
            text-align: center;
            margin-top: 25px;
            font-size: 14px;
            color: var(--muted);
        }
        
        .auth-links a {
            color: var(--primary);
            font-weight: 600;
            text-decoration: none;
        }
        
        .auth-links a:hover {
            text-decoration: underline;
        }
    </style>
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
            
            <form action="login-process.jsp" method="POST">
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
                Chưa có tài khoản? <a href="<%= contextPath %>/register.jsp">Đăng ký ngay</a>
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

