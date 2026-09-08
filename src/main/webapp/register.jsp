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
            max-width: 480px;
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
            margin-top: 10px;
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
                <h1>Tạo tài khoản mới</h1>
                <p>Tham gia Sportify để trải nghiệm dịch vụ</p>
            </div>
            
            <form action="register-process.jsp" method="POST">
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
                Đã có tài khoản? <a href="<%= contextPath %>/login.jsp">Đăng nhập</a>
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

