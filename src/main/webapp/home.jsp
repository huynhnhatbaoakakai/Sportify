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
    <title>Trang chủ - Sportify</title>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/style.css">
    <style>
        body {
            background: var(--background);
            display: flex;
            height: 100vh;
            overflow: hidden;
        }

        /* SIDEBAR NAVIGATION */
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
            justify-content: space-between;
            padding: 0 30px;
            position: sticky;
            top: 0;
            z-index: 10;
        }

        .page-title {
            font-size: 20px;
            color: var(--dark);
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 12px;
            cursor: pointer;
            padding: 5px;
            border-radius: 30px;
            transition: background 0.2s;
        }

        .user-profile:hover {
            background: var(--background);
        }

        .profile-img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: var(--primary);
            color: var(--white);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            font-weight: bold;
            object-fit: cover;
        }
        
        .profile-name {
            font-weight: 600;
            color: var(--dark);
            font-size: 14px;
        }

        /* CONTENT */
        .content-area {
            padding: 30px;
            max-width: 1200px;
            margin: 0 auto;
            width: 100%;
        }

        .welcome-card {
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            border-radius: 20px;
            padding: 40px;
            color: var(--white);
            margin-bottom: 30px;
            box-shadow: var(--shadow);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .welcome-card h2 {
            font-size: 28px;
            margin-bottom: 10px;
        }

        .welcome-card p {
            color: rgba(255, 255, 255, 0.8);
            font-size: 16px;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: var(--white);
            padding: 20px;
            border-radius: 16px;
            border: 1px solid var(--border);
            box-shadow: 0 4px 15px rgba(0,0,0,0.03);
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            background: var(--primary-light);
            color: var(--primary);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }
        
        .stat-info h4 {
            color: var(--muted);
            font-size: 13px;
            margin-bottom: 5px;
        }
        
        .stat-info span {
            color: var(--dark);
            font-size: 22px;
            font-weight: bold;
        }
    </style>
</head>
<body>

    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-brand">
            <a class="brand" href="<%= contextPath %>/home.jsp">
                <span class="brand-icon">S</span>
                <span>SPORTIFY</span>
            </a>
        </div>
        
        <nav class="sidebar-menu">
            <a href="<%= contextPath %>/home.jsp" class="menu-item active">
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
            
            <a href="<%= contextPath %>/profile.jsp" class="menu-item">
                <span class="menu-icon">👤</span>
                <span>Hồ sơ cá nhân</span>
            </a>
            <a href="<%= contextPath %>/index.jsp" class="menu-item" style="color: #ef4444; margin-top: auto;">
                <span class="menu-icon">🚪</span>
                <span>Đăng xuất</span>
            </a>
        </nav>
    </aside>

    <!-- MAIN CONTENT -->
    <div class="main-wrapper">
        <header class="top-navbar">
            <h1 class="page-title">Tổng quan</h1>
            
            <!-- THUMBNAIL PROFILE -->
            <a href="<%= contextPath %>/profile.jsp" class="user-profile">
                <div class="profile-img">K</div>
                <div class="profile-name">Khoa Nguyễn</div>
            </a>
        </header>
        
        <main class="content-area">
            <div class="welcome-card">
                <div>
                    <h2>Chào buổi sáng, Khoa!</h2>
                    <p>Hôm nay là một ngày tuyệt vời để tập luyện.</p>
                </div>
                <div style="font-size: 80px;">🏃‍♂️</div>
            </div>
            
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon">📅</div>
                    <div class="stat-info">
                        <h4>Lịch đặt sắp tới</h4>
                        <span>2</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon" style="background: #e0f2fe; color: #0284c7;">✉️</div>
                    <div class="stat-info">
                        <h4>Tin nhắn chưa đọc</h4>
                        <span>5</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon" style="background: #fef3c7; color: #d97706;">🔥</div>
                    <div class="stat-info">
                        <h4>Giờ tập tháng này</h4>
                        <span>12h</span>
                    </div>
                </div>
            </div>
        </main>
    </div>

</body>
</html>

