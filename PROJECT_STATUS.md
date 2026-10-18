# Trạng thái Sportify

Cập nhật ngày 17/10/2026. Tài liệu chi tiết: [TINH_NANG_WEBSITE.md](TINH_NANG_WEBSITE.md).

## Đã hoạt động trong mã nguồn hiện tại

- Đăng ký, đăng nhập, quyền khách hàng và chủ sân.
- Tìm sân, xem lịch trống, gửi đơn, xác nhận thủ công hoặc tự động cho sân đủ điều kiện.
- Quản lý sân, khóa giờ, xử lý đơn, lịch sử và thông báo.
- Lưu hồ sơ cá nhân, chat trực tiếp, Newsfeed, thích và bình luận.
- Bộ icon SVG nét mảnh dùng chung cho giao diện khách và chủ sân.
- Giao diện đặt sân có bố cục riêng cho điện thoại.
- PostgreSQL là database đang dùng ở bản làm việc này.

## Cấu trúc chính

- `src/main/java`: Servlet, model và xử lý dữ liệu.
- `src/main/webapp/WEB-INF/views`: các trang người dùng và lịch chủ sân.
- `src/main/webapp/owner`: dashboard, khách hàng và đánh giá đang được Servlet sử dụng.
- `src/main/webapp/assets`: CSS, JavaScript và ảnh dùng chung.
- `database`: giữ script PostgreSQL, script và backup SQL Server của nhóm.
- `docs`: tài liệu thiết kế và ghi chú ôn tập.
- `target`: kết quả build do Maven tạo lại, không đưa vào Git.

## Những phần chưa có

Thanh toán trực tuyến, tải ảnh đại diện, màn hình khách đăng đánh giá, lịch lặp và trạng thái trực tuyến thật chưa được triển khai. Thuê gear, trang phục và PT đã tắt.

Backend hiện có phần riêng cho PostgreSQL. Muốn dùng đầy đủ trên SQL Server cần phần tương thích tương ứng; việc đổi icon và dọn file không thay đổi các truy vấn database hiện có.
