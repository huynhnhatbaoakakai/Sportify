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
    <title>Hồ sơ cá nhân - Sportify</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css">
    <style>
        body {
            background: var(--background);
            display: flex;
            height: 100vh;
            overflow: hidden;
        }

        /* SIDEBAR NAVIGATION (Copied from home.jsp) */
        .sidebar {
            width: 280px;
            background: var(--white);
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            padding: 20px 0;
            flex-shrink: 0;
        }

        .sidebar-brand {
            padding: 0 25px 20px;
            margin-bottom: 20px;
            border-bottom: 1px solid var(--border);
        }

        .sidebar-menu {
            display: flex;
            flex-direction: column;
            gap: 10px;
            padding: 0 15px;
        }

        .menu-item {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 12px 20px;
            border-radius: 12px;
            color: var(--text);
            font-weight: 600;
            transition: 0.2s;
        }

        .menu-item:hover, .menu-item.active {
            background: var(--primary-light);
            color: var(--primary);
        }

        .menu-icon {
            font-size: 20px;
        }

        /* MAIN CONTENT AREA */
        .main-wrapper {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
        }

        /* TOP NAVBAR */
        .top-navbar {
            height: 72px;
            background: var(--white);
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            padding: 0 30px;
            position: sticky;
            top: 0;
            z-index: 10;
        }

        .page-title {
            font-size: 20px;
            color: var(--dark);
        }

        /* CONTENT */
        .content-area {
            padding: 30px;
            max-width: 900px;
            margin: 0 auto;
            width: 100%;
        }
        
        .profile-container {
            background: var(--white);
            border-radius: 20px;
            border: 1px solid var(--border);
            box-shadow: 0 5px 20px rgba(0,0,0,0.02);
            overflow: hidden;
        }
        
        .profile-header {
            background: linear-gradient(135deg, #effbf3, #ffffff);
            padding: 40px;
            display: flex;
            align-items: center;
            gap: 30px;
            border-bottom: 1px solid var(--border);
        }
        
        .profile-avatar-large {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background: var(--primary);
            color: var(--white);
            font-size: 48px;
            font-weight: bold;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 4px solid var(--white);
            box-shadow: 0 10px 20px rgba(21,148,71,0.2);
            position: relative;
        }
        
        .edit-avatar-btn {
            position: absolute;
            bottom: 5px;
            right: 5px;
            width: 32px;
            height: 32px;
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            color: var(--dark);
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .profile-title h2 {
            font-size: 26px;
            color: var(--dark);
            margin-bottom: 5px;
        }
        
        .profile-title p {
            color: var(--muted);
            font-size: 15px;
        }
        
        .profile-body {
            padding: 40px;
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        
        .form-group.full-width {
            grid-column: span 2;
        }
        
        .form-group label {
            font-weight: 600;
            color: var(--text);
            font-size: 14px;
        }
        
        .form-group input, .form-group select, .form-group textarea {
            padding: 14px 18px;
            border: 1px solid var(--border);
            border-radius: 12px;
            background: var(--background);
            font-size: 15px;
            font-family: inherit;
            color: var(--dark);
            outline: none;
            transition: 0.2s;
        }
        
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            border-color: var(--primary);
            background: var(--white);
            box-shadow: 0 0 0 3px var(--primary-light);
        }
        
        .form-actions {
            margin-top: 35px;
            display: flex;
            justify-content: flex-end;
            gap: 15px;
        }
        
        .btn-save {
            background: var(--primary);
            color: var(--white);
            border: none;
            padding: 12px 25px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 15px;
            cursor: pointer;
            transition: 0.2s;
        }
        
        .btn-save:hover {
            background: var(--primary-dark);
        }
        
        .btn-cancel {
            background: transparent;
            color: var(--muted);
            border: 1px solid var(--border);
            padding: 12px 25px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 15px;
            cursor: pointer;
            transition: 0.2s;
        }
        
        .btn-cancel:hover {
            background: #f1f5f9;
            color: var(--dark);
        }
    </style>
</head>
<body>

    <!-- SIDEBAR NAVIGATION -->
    <aside class="sidebar">
        <div class="sidebar-brand">
            <a class="brand" href="<%= contextPath %>/home.jsp">
                <span class="brand-icon">S</span>
                <span>SPORTIFY</span>
            </a>
        </div>
        
        <nav class="sidebar-menu">
            <a href="<%= contextPath %>/home.jsp" class="menu-item">
                <span class="menu-icon">🏠</span>
                <span>Trang chủ</span>
            </a>
            
            <div style="margin: 15px 0 5px 20px; font-size: 12px; color: var(--muted); font-weight: bold; text-transform: uppercase;">
                Giao tiếp
            </div>
            
            <a href="<%= contextPath %>/chat.jsp" class="menu-item">
                <span class="menu-icon">💬</span>
                <span>Chat với Dịch vụ</span>
            </a>
            
            <a href="<%= contextPath %>/chat-friends.jsp" class="menu-item">
                <span class="menu-icon">👥</span>
                <span>Chat với Bạn bè</span>
            </a>
            
            <div style="margin: 15px 0 5px 20px; font-size: 12px; color: var(--muted); font-weight: bold; text-transform: uppercase;">
                Cá nhân
            </div>
            
            <a href="<%= contextPath %>/profile.jsp" class="menu-item active">
                <span class="menu-icon">👤</span>
                <span>Hồ sơ cá nhân</span>
            </a>
        </nav>
    </aside>

    <!-- MAIN CONTENT -->
    <div class="main-wrapper">
        <header class="top-navbar">
            <h1 class="page-title">Thông tin tài khoản</h1>
        </header>
        
        <main class="content-area">
            <div class="profile-container">
                <div class="profile-header">
                    <div class="profile-avatar-large">
                        K
                        <div class="edit-avatar-btn" title="Thay đổi ảnh đại diện">📷</div>
                    </div>
                    <div class="profile-title">
                        <h2>Khoa Nguyễn</h2>
                        <p>Thành viên từ Tháng 9, 2026</p>
                    </div>
                </div>
                
                <div class="profile-body">
                    <form action="#" method="POST">
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="fullname">Họ và tên</label>
                                <input type="text" id="fullname" value="Khoa Nguyễn">
                            </div>
                            
                            <div class="form-group">
                                <label for="phone">Số điện thoại</label>
                                <input type="tel" id="phone" value="0901234567">
                            </div>
                            
                            <div class="form-group full-width">
                                <label for="email">Địa chỉ Email</label>
                                <input type="email" id="email" value="khoa.nguyen@email.com" readonly style="background: #f1f5f9; cursor: not-allowed;">
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

