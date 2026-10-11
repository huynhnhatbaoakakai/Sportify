# Truy vấn SQL của các tính năng chủ sân

Project dùng **JPA/Hibernate**, persistence unit `sportifyPU`, PostgreSQL `sporttrent`.
Các câu SQL trong thư mục này là **SQL tương đương với hành vi của code hiện tại**,
không phải bản log nguyên văn do Hibernate sinh ra. Điều kiện kiểm tra trong Java
được ghi rõ, đặc biệt trước khi cập nhật sân hoặc trạng thái đặt sân.

| Tính năng | File |
|---|---|
| Quản lý sân: đọc, thêm, sửa, bật/tắt | [QUAN_LY_SAN.md](QUAN_LY_SAN.md) |
| Quản lý đặt sân: danh sách, xác nhận/từ chối, kiểm tra trùng | [QUAN_LY_DAT_SAN.md](QUAN_LY_DAT_SAN.md) |
| Khách hàng đã đánh giá: tổng hợp và tìm kiếm | [KHACH_HANG.md](KHACH_HANG.md) |
| Đánh giá: danh sách, lọc sao, phản hồi | [DANH_GIA.md](DANH_GIA.md) |
| Thống kê Dashboard: sân, lịch hôm nay, đơn chờ, doanh thu | [TONG_QUAN_DASHBOARD.md](TONG_QUAN_DASHBOARD.md) |
| Truy cập/đăng xuất owner tạm: hiện không có SQL | [TRUY_CAP_CHU_SAN.md](TRUY_CAP_CHU_SAN.md) |

## Tham số

- `$1`, `$2`... là tham số của prepared statement PostgreSQL, không phải nối chuỗi dữ liệu người dùng.
- Trong code JPA, tham số tương ứng có tên như `:ownerId`, `:fieldId`, `:bookingId` và được gán bằng `setParameter`.
- Hiện owner demo là `1L`; sau này lấy user ID từ session và kiểm tra role `OWNER`.
- Để chạy một đoạn có `$1` trong pgAdmin, dùng `PREPARE`/`EXECUTE`, ví dụ:

```sql
PREPARE xem_san_chu_so_huu(BIGINT) AS
SELECT f.*
FROM public.sports_fields f
WHERE f.owner_id = $1
ORDER BY f.created_at DESC;

EXECUTE xem_san_chu_so_huu(1);
DEALLOCATE xem_san_chu_so_huu;
```

Các đoạn INSERT/UPDATE là tài liệu để đọc và đối chiếu code. Chỉ chạy với tham số
đã kiểm tra; không chạy tùy ý trên dữ liệu đang sử dụng.

## Kết nối và schema

- [DBUtil.java](../../src/main/java/com/sportify/data/DBUtil.java): khởi tạo `EntityManagerFactory`.
- [persistence.xml](../../src/main/resources/META-INF/persistence.xml): driver/URL/JPA entity, `hibernate.hbm2ddl.auto=validate`.
- Khóa chính sân: `public.sports_fields.field_id` (`BIGINT`), chủ sở hữu: `owner_id`.
- Migration Booking: [database/bookings.sql](../../database/bookings.sql).
  Phải chạy PHẦN 1 trước khi triển khai WAR có entity `Booking`.

Không lưu mật khẩu DB trong các tài liệu này.
