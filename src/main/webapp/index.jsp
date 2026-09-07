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

    <title>Sportify - Dịch vụ thể thao</title>

    <link rel="stylesheet"
          href="<%= contextPath %>/assets/css/style.css">

    <script defer
            src="<%= contextPath %>/assets/js/app.js"></script>
</head>

<body>

<header class="header">
    <div class="container navbar">
        <a class="brand" href="<%= contextPath %>/">
            <span class="brand-icon">S</span>
            <span>SPORTIFY</span>
        </a>

        <nav class="nav-links">
            <a href="#home">Trang chủ</a>
            <a href="#sports">Môn thể thao</a>
            <a href="#services">Dịch vụ</a>
            <a href="#featured">Nổi bật</a>
        </nav>

        <a class="btn btn-outline"
           href="<%= contextPath %>/login.jsp">
            Đăng nhập
        </a>
    </div>
</header>

<main>

    <!-- HERO -->
    <section class="hero" id="home">
        <div class="container hero-content">
            <div class="hero-text">
                <span class="eyebrow">TẬP LUYỆN DỄ DÀNG HƠN</span>

                <h1>
                    Mọi dịch vụ thể thao<br>
                    trong một nền tảng
                </h1>

                <p>
                    Tìm sân tập, thuê quần áo, dụng cụ và huấn luyện viên
                    cho Gym, Bóng rổ, Bơi và Pickleball.
                </p>

                <form class="search-box" id="searchForm">
                    <input
                        id="searchInput"
                        type="search"
                        placeholder="Tìm sân, dụng cụ hoặc PT..."
                        aria-label="Tìm kiếm dịch vụ">

                    <button type="submit">Tìm kiếm</button>
                </form>

                <p class="search-hint">
                    Gợi ý: Gym, Bóng rổ, Bơi, Pickleball, PT
                </p>
            </div>

            <div class="hero-visual">
                <div class="hero-circle">
                    <span>🏋️</span>
                    <span>🏀</span>
                    <span>🏊</span>
                    <span>🏓</span>
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

                <p>Chọn môn thể thao để xem các dịch vụ phù hợp.</p>
            </div>

            <div class="grid four-columns">
                <button class="category-card filter-button"
                        type="button"
                        data-query="gym">
                    <span class="category-icon">🏋️</span>
                    <strong>Gym</strong>
                    <small>Phòng tập, quần áo và PT</small>
                </button>

                <button class="category-card filter-button"
                        type="button"
                        data-query="bóng rổ">
                    <span class="category-icon">🏀</span>
                    <strong>Bóng rổ</strong>
                    <small>Sân, bóng và trang phục</small>
                </button>

                <button class="category-card filter-button"
                        type="button"
                        data-query="bơi">
                    <span class="category-icon">🏊</span>
                    <strong>Bơi</strong>
                    <small>Hồ bơi, đồ bơi và HLV</small>
                </button>

                <button class="category-card filter-button"
                        type="button"
                        data-query="pickleball">
                    <span class="category-icon">🏓</span>
                    <strong>Pickleball</strong>
                    <small>Sân, vợt và huấn luyện viên</small>
                </button>
            </div>
        </div>
    </section>

    <!-- SERVICE TYPES -->
    <section class="section section-soft" id="services">
        <div class="container">
            <div class="section-heading">
                <div>
                    <span class="section-label">LOẠI DỊCH VỤ</span>
                    <h2>Một nơi cho mọi nhu cầu</h2>
                </div>

                <p>Đặt lịch và quản lý dịch vụ nhanh chóng.</p>
            </div>

            <div class="grid four-columns">
                <button class="service-type filter-button"
                        type="button"
                        data-query="sân phòng tập">
                    <span>📅</span>
                    <div>
                        <strong>Thuê sân/phòng tập</strong>
                        <small>Chọn ngày và khung giờ</small>
                    </div>
                </button>

                <button class="service-type filter-button"
                        type="button"
                        data-query="quần áo">
                    <span>👕</span>
                    <div>
                        <strong>Thuê quần áo</strong>
                        <small>Chọn kích thước và thời gian thuê</small>
                    </div>
                </button>

                <button class="service-type filter-button"
                        type="button"
                        data-query="gear dụng cụ">
                    <span>🎒</span>
                    <div>
                        <strong>Thuê gear</strong>
                        <small>Vợt, bóng và phụ kiện</small>
                    </div>
                </button>

                <button class="service-type filter-button"
                        type="button"
                        data-query="pt huấn luyện viên">
                    <span>💪</span>
                    <div>
                        <strong>Thuê PT</strong>
                        <small>Đặt lịch huấn luyện cá nhân</small>
                    </div>
                </button>
            </div>
        </div>
    </section>

    <!-- FEATURED SERVICES -->
    <section class="section" id="featured">
        <div class="container">
            <div class="section-heading">
                <div>
                    <span class="section-label">ĐỀ XUẤT CHO BẠN</span>
                    <h2>Dịch vụ nổi bật</h2>
                </div>

                <button class="clear-filter" id="clearFilter" type="button">
                    Hiện tất cả
                </button>
            </div>

            <p class="result-message" id="resultMessage">
                Đang hiển thị tất cả dịch vụ.
            </p>

            <div class="grid service-grid" id="serviceGrid">

                <article class="service-card"
                         data-search="gym phòng tập quận 7">
                    <div class="service-image green">🏋️</div>

                    <div class="service-body">
                        <span class="badge">Gym</span>
                        <h3>Phòng Gym FitZone</h3>
                        <p>Quận 7, TP. Hồ Chí Minh</p>

                        <div class="service-footer">
                            <strong>60.000đ <small>/ giờ</small></strong>
                            <button type="button">Xem chi tiết</button>
                        </div>
                    </div>
                </article>

                <article class="service-card"
                         data-search="bóng rổ sân quận 3">
                    <div class="service-image orange">🏀</div>

                    <div class="service-body">
                        <span class="badge">Bóng rổ</span>
                        <h3>Sân bóng Sunrise</h3>
                        <p>Quận 3, TP. Hồ Chí Minh</p>

                        <div class="service-footer">
                            <strong>180.000đ <small>/ giờ</small></strong>
                            <button type="button">Xem chi tiết</button>
                        </div>
                    </div>
                </article>

                <article class="service-card"
                         data-search="bơi hồ bơi quận 1">
                    <div class="service-image blue">🏊</div>

                    <div class="service-body">
                        <span class="badge">Bơi</span>
                        <h3>Hồ bơi Aqua Center</h3>
                        <p>Quận 1, TP. Hồ Chí Minh</p>

                        <div class="service-footer">
                            <strong>50.000đ <small>/ lượt</small></strong>
                            <button type="button">Xem chi tiết</button>
                        </div>
                    </div>
                </article>

                <article class="service-card"
                         data-search="pickleball sân vợt quận 7">
                    <div class="service-image yellow">🏓</div>

                    <div class="service-body">
                        <span class="badge">Pickleball</span>
                        <h3>Green Pickleball Court</h3>
                        <p>Quận 7, TP. Hồ Chí Minh</p>

                        <div class="service-footer">
                            <strong>150.000đ <small>/ giờ</small></strong>
                            <button type="button">Xem chi tiết</button>
                        </div>
                    </div>
                </article>

                <article class="service-card"
                         data-search="gear dụng cụ vợt pickleball">
                    <div class="service-image purple">🎒</div>

                    <div class="service-body">
                        <span class="badge">Gear</span>
                        <h3>Bộ vợt Pickleball</h3>
                        <p>Hai vợt, bóng và túi đựng</p>

                        <div class="service-footer">
                            <strong>80.000đ <small>/ ngày</small></strong>
                            <button type="button">Xem chi tiết</button>
                        </div>
                    </div>
                </article>

                <article class="service-card"
                         data-search="pt huấn luyện viên gym cá nhân">
                    <div class="service-image red">💪</div>

                    <div class="service-body">
                        <span class="badge">PT</span>
                        <h3>PT Nguyễn Minh Anh</h3>
                        <p>5 năm kinh nghiệm huấn luyện</p>

                        <div class="service-footer">
                            <strong>250.000đ <small>/ buổi</small></strong>
                            <button type="button">Xem chi tiết</button>
                        </div>
                    </div>
                </article>

            </div>

            <div class="empty-state" id="emptyState" hidden>
                Không tìm thấy dịch vụ phù hợp.
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

            <p>Nền tảng dịch vụ thể thao dành cho mọi người.</p>
        </div>

        <div>
            <strong>Dịch vụ</strong>
            <a href="#sports">Môn thể thao</a>
            <a href="#services">Loại dịch vụ</a>
            <a href="#featured">Dịch vụ nổi bật</a>
        </div>

        <div>
            <strong>Liên hệ</strong>
            <p>Email: support@sportify.vn</p>
            <p>Hotline: 0123 456 789</p>
        </div>
    </div>

    <div class="copyright">
        © 2026 Sportify. Đồ án môn Web Programming.
    </div>
</footer>

</body>
</html>