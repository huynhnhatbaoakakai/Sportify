<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="com.sportify.model.User" %>
<%@ page import="com.sportify.util.Html" %>

<%
    String contextPath = request.getContextPath();
    User currentUser = (User) session.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Sportify - Đặt sân và kết nối</title>
    <link rel="stylesheet"
          href="<%= contextPath %>/assets/css/style.css">

    <script defer
            src="<%= contextPath %>/assets/js/app.js"></script>
    <link rel="stylesheet" href="<%= contextPath %>/assets/css/icons.css">
</head>

<body>

<header class="header">
    <div class="container header-inner">

        <a class="header-logo" href="<%= contextPath %>/">
            <img src="<%= contextPath %>/assets/images/logo.jpeg"
                 alt="Sportify">
        </a>

        <nav class="header-menu">
            <a href="<%= contextPath %>/">Trang chủ</a>
            <a href="#sports">Môn thể thao</a>
            <a href="#services">Đặt sân & kết nối</a>
            <a href="#featured">Nổi bật</a>
            <% if (currentUser != null) { %>
            <a href="<%= contextPath %>/newsfeed">Newsfeed</a>
            <a href="<%= contextPath %>/appointments">Lịch nhắc</a>
            <a href="<%= contextPath %>/chat-friends">Tin nhắn</a>
            <% } %>
        </nav>

        <div class="header-actions">
            <% if (currentUser != null && currentUser.isOwner()) { %>
            <a class="btn" style="background: #0d2d1c; color: white;"
               href="<%= contextPath %>/owner/fields">
                <span class="app-icon icon-court" aria-hidden="true"></span> Quản lý sân
            </a>
            <% } %>
            <% if (currentUser == null) { %>
            <a class="btn btn-outline"
               href="<%= contextPath %>/login">Đăng nhập</a>

            <a class="btn btn-primary"
               href="<%= contextPath %>/register">Đăng ký</a>
            <% } else { %>
            <a class="btn btn-outline"
               href="<%= contextPath %>/home"><span class="app-icon icon-home" aria-hidden="true"></span> <%= Html.escape(currentUser.getFullname()) %></a>
            <a class="btn" style="background: #ef4444; color: white;"
               href="<%= contextPath %>/logout">Đăng xuất</a>
            <% } %>
        </div>

    </div>
</header>

<main>

    <!-- HERO -->
    <section class="hero" id="home">
        <div class="container hero-content">
            <div class="hero-text">
                <span class="eyebrow">TẬP LUYỆN DỄ DÀNG HƠN</span>

                <h1>
                    Đặt sân dễ dàng<br>
                    kết nối cùng đam mê
                </h1>

                <p>
                    Xem lịch trống, đặt sân và trao đổi trực tiếp với chủ sân.
                    Cùng cộng đồng chơi Gym, Bóng rổ, Bơi và Pickleball.
                </p>

                <form class="search-box" id="searchForm">
                    <input
                        id="searchInput"
                        type="search"
                        placeholder="Tìm sân hoặc môn thể thao..."
                        aria-label="Tìm kiếm sân">

                    <button type="submit">Tìm kiếm</button>
                </form>

                <p class="search-hint">
                    Gợi ý: Gym, Bóng rổ, Bơi, Pickleball
                </p>
            </div>

            <div class="hero-visual">
                <div class="hero-circle">
                    <span class="app-icon icon-gym" aria-hidden="true"></span>
                    <span class="app-icon icon-basketball" aria-hidden="true"></span>
                    <span class="app-icon icon-swimming" aria-hidden="true"></span>
                    <span class="app-icon icon-racket" aria-hidden="true"></span>
                </div>
            </div>
        </div>
    </section>

    <!-- SPORTS -->
    <section class="section" id="sports">
        <div class="container">
            <div class="section-heading">
                <div>
                    <span class="section-label">MÔN THỂ THAO</span>
                    <h2>Bạn muốn chơi môn gì?</h2>
                </div>

                <p>Chọn môn thể thao để xem sân hoặc cơ sở phù hợp.</p>
            </div>

            <div class="grid four-columns">
                <button class="category-card filter-button"
                        type="button"
                        data-query="gym">
                    <span class="category-icon app-icon icon-gym" aria-hidden="true"></span>
                    <strong>Gym</strong>
                    <small>Khám phá phòng tập</small>
                </button>

                <button class="category-card filter-button"
                        type="button"
                        data-query="bóng rổ">
                    <span class="category-icon app-icon icon-basketball" aria-hidden="true"></span>
                    <strong>Bóng rổ</strong>
                    <small>Chọn sân và khung giờ</small>
                </button>

                <button class="category-card filter-button"
                        type="button"
                        data-query="bơi">
                  <span class="category-icon app-icon icon-swimming" aria-hidden="true"></span>
                    <strong>Bơi</strong>
                    <small>Tìm hồ bơi phù hợp</small>
                </button>

                <button class="category-card filter-button"
                        type="button"
                        data-query="pickleball">
                  <span class="category-icon app-icon icon-racket" aria-hidden="true"></span>
                    <strong>Pickleball</strong>
                    <small>Đặt sân cùng bạn bè</small>
                </button>
            </div>
        </div>
    </section>

    <!-- ĐẶT SÂN VÀ KẾT NỐI -->
    <section class="section section-soft" id="services">
        <div class="container">
            <div class="section-heading">
                <div>
                    <span class="section-label">ĐẶT SÂN & KẾT NỐI</span>
                    <h2>Từ chọn sân đến buổi chơi</h2>
                </div>
                <p>Chủ sân và khách hàng trao đổi ngay trên Sportify.</p>
            </div>
            <div class="grid four-columns">
                <a class="service-type" href="<%= contextPath %>/home#fields">
                    <span class="type-icon app-icon icon-calendar" aria-hidden="true"></span>
                    <div><strong>Tìm và đặt sân</strong><small>Xem giá và lịch còn trống</small></div>
                </a>
                <a class="service-type" href="<%= contextPath %>/<%= currentUser != null && currentUser.isOwner() ? "owner/fields" : "home#my-bookings" %>">
                    <span class="type-icon app-icon icon-calendar-check" aria-hidden="true"></span>
                    <div><strong><%= currentUser != null && currentUser.isOwner() ? "Quản lý sân" : "Theo dõi đơn đặt sân" %></strong><small>Lịch sân và trạng thái xác nhận</small></div>
                </a>
                <a class="service-type" href="<%= contextPath %>/chat-friends">
                    <span class="type-icon app-icon icon-chat" aria-hidden="true"></span>
                    <div><strong>Nhắn tin trực tiếp</strong><small>Kết nối chủ sân và khách hàng</small></div>
                </a>
                <a class="service-type" href="<%= contextPath %>/newsfeed">
                    <span class="type-icon app-icon icon-users" aria-hidden="true"></span>
                    <div><strong>Cộng đồng thể thao</strong><small>Chia sẻ, thích và bình luận</small></div>
                </a>
            </div>
        </div>
    </section>

    <!-- FEATURED SERVICES -->
    <section class="section" id="featured">
        <div class="container">
            <div class="section-heading">
                <div>
                    <span class="section-label">ĐỀ XUẤT CHO BẠN</span>
                    <h2>Khám phá sân theo môn</h2>
                </div>

                <button class="clear-filter" id="clearFilter" type="button">
                    Hiện tất cả
                </button>
            </div>

            <p class="result-message" id="resultMessage">
                Đang hiển thị tất cả nhóm sân.
            </p>

            <div class="grid service-grid" id="serviceGrid">

                <article class="service-card"
                         data-search="venue gym phòng tập quận 7">
                   <div class="service-image">
                         <img src="<%= contextPath %>/assets/images/gymfitzone.jfif" alt="Phòng tập Gym">
</div>

                    <div class="service-body">
                        <span class="badge">Gym</span>
                        <h3>Phòng Gym FitZone</h3>
                        <p>Chọn cơ sở và khung giờ phù hợp.</p>

                        <div class="service-footer">
                            <strong>Giá theo sân</strong>
                            <a class="btn-book" href="<%= contextPath %>/home#fields">Xem sân</a>
                        </div>
                    </div>
                </article>

                <article class="service-card"
                         data-search="venue sân bóng rổ quận 3">
                    <div class="service-image">
                            <img
                                src="<%= contextPath %>/assets/images/basketballcourt1.jpg"
                                alt="Sân bóng rổ Sunrise">
                        </div>

                    <div class="service-body">
                        <span class="badge">Bóng rổ</span>
                        <h3>Sân bóng rổ</h3>
                        <p>Chọn cơ sở và khung giờ phù hợp.</p>

                        <div class="service-footer">
                            <strong>Giá theo sân</strong>
                            <a class="btn-book" href="<%= contextPath %>/home#fields">Xem sân</a>
                        </div>
                    </div>
                </article>

                <article class="service-card"
                        data-search="venue bơi hồ bơi quận 1">
                    <div class="service-image">
                                <img
                                    src="<%= contextPath %>/assets/images/swimmingpoolaqua.jfif"
                                    alt="Hồ bơi">
                            </div>

                    <div class="service-body">
                        <span class="badge">Bơi</span>
                        <h3>Hồ bơi Aqua Center</h3>
                        <p>Chọn cơ sở và khung giờ phù hợp.</p>

                        <div class="service-footer">
                            <strong>Giá theo sân</strong>
                            <a class="btn-book" href="<%= contextPath %>/home#fields">Xem sân</a>
                        </div>
                    </div>
                </article>

                <article class="service-card"
                         data-search="venue pickleball sân quận 7">
                   <div class="service-image">
                    <img
                        src="<%= contextPath %>/assets/images/greenpickleballcourt.jfif"
                        alt="Sân Pickleball">
                </div>

                    <div class="service-body">
                        <span class="badge">Pickleball</span>
                        <h3>Green Pickleball Court</h3>
                        <p>Chọn cơ sở và khung giờ phù hợp.</p>

                        <div class="service-footer">
                            <strong>Giá theo sân</strong>
                            <a class="btn-book" href="<%= contextPath %>/home#fields">Xem sân</a>
                        </div>
                    </div>
                </article>

            </div>

            <div class="empty-state" id="emptyState" hidden>
                Không tìm thấy nhóm sân phù hợp.
            </div>
        </div>
    </section>

</main>

<footer class="footer">
    <div class="container footer-content">
        <div>
            <a class="brand footer-brand" href="<%= contextPath %>/">
                <span class="brand-icon">S</span>
                <span>SPORTIFY</span>
            </a>

            <p>Đặt sân, quản lý sân và kết nối cộng đồng thể thao.</p>
        </div>

        <div>
            <strong>Khám phá</strong>
            <a href="#sports">Môn thể thao</a>
            <a href="#services">Đặt sân & kết nối</a>
            <a href="#featured">Khám phá sân theo môn</a>
        </div>

        <div>
            <strong>Liên hệ</strong>
            <p>Email: support@sportify.vn</p>
            <p>Hotline: 0767615217  </p>
        </div>
    </div>

    <div class="copyright">
        © 2026 Sportify. Đồ án môn Web Programming.
    </div>
</footer>

</body>
</html>
