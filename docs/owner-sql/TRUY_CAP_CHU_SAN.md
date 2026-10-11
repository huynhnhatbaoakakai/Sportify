# Truy cập và đăng xuất chủ sân

Code: `OwnerAccessServlet`, `OwnerAccessFilter`, `OwnerAccessLogoutServlet`.

**Hiện tính năng này không có câu truy vấn SQL.** Project chưa có bảng người dùng/role OWNER.

- `OwnerAccessServlet` kiểm tra mật khẩu tạm trong Java, rồi đặt session attribute
  `OWNER_DEMO_AUTHORIZED = true`.
- `OwnerAccessFilter` bảo vệ `/owner/*` bằng session attribute trên.
- Đăng xuất xóa attribute; không có UPDATE/DELETE trong PostgreSQL.
- Các servlet dữ liệu đang dùng `DEMO_OWNER_ID = 1L`, có TODO thay bằng user ID
  trong session và kiểm tra role OWNER khi triển khai đăng nhập thật.

Không đưa SQL giả kiểu `SELECT * FROM users` vào tài liệu vì bảng đó chưa tồn tại.
Các truy vấn đọc/ghi dữ liệu sân, Booking, Review đều nằm trong file riêng của tính năng đó.
