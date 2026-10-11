# Thống kê Dashboard chủ sân

Code: [ManageFieldsServlet.java](../../src/main/java/com/sportify/controller/ManageFieldsServlet.java),
[BookingDB.java](../../src/main/java/com/sportify/data/BookingDB.java),
[dashboard.jsp](../../src/main/webapp/owner/dashboard.jsp).

## 1. Sân đang hoạt động

Code hiện lấy toàn bộ sân bằng `SportFieldDB.findByOwnerId`, rồi đếm ACTIVE trong JSP.
JavaScript đọc lại số card ACTIVE để cập nhật hiển thị. SQL tương đương:

```sql
SELECT COUNT(*) AS active_field_count
FROM public.sports_fields
WHERE owner_id = $1
  AND status = 'ACTIVE';
```

## 2. Lịch hôm nay, đơn chờ và doanh thu

Hàm: `BookingDB.getDashboardSummary(ownerId, date)`.
`$1`: owner ID; `$2`: 00:00 ngày thống kê; `$3`: 00:00 ngày tiếp theo.
Servlet lấy ngày theo `Asia/Ho_Chi_Minh`.

```sql
SELECT
    COALESCE(SUM(CASE
        WHEN b.starts_at >= $2 AND b.starts_at < $3
         AND b.status IN ('PENDING', 'CONFIRMED', 'COMPLETED')
        THEN 1 ELSE 0 END), 0) AS today_booking_count,

    COALESCE(SUM(CASE
        WHEN b.status = 'PENDING'
        THEN 1 ELSE 0 END), 0) AS pending_booking_count,

    COALESCE(SUM(CASE
        WHEN b.status = 'COMPLETED'
         AND b.starts_at >= $2 AND b.starts_at < $3
        THEN b.total_price ELSE 0 END), 0) AS today_booking_revenue
FROM public.bookings b
JOIN public.sports_fields f ON f.field_id = b.field_id
WHERE f.owner_id = $1;
```

JPQL thực tế trả NULL cho SUM khi chưa có đơn; Java đổi về 0/BigDecimal.ZERO.
Các bộ lọc trên bảng không làm thay đổi ba số liệu tổng quan này.

- Lịch hôm nay không tính REJECTED/CANCELLED.
- Đơn chờ tính tất cả PENDING của chủ sân, kể cả lịch ngày khác.
- Doanh thu là tổng giá đơn COMPLETED bắt đầu trong ngày, chưa phải tiền thanh toán thực nhận.
- Không còn số liệu 12 đơn, 4 đơn chờ, 4.850.000đ hoặc tăng trưởng 12,5% viết sẵn trong JSP.

## Ví dụ chạy trong pgAdmin cho ngày hiện tại

```sql
WITH bounds AS (
    SELECT (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Ho_Chi_Minh')::DATE::TIMESTAMP AS day_start,
           ((CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Ho_Chi_Minh')::DATE + 1)::TIMESTAMP AS day_end
)
SELECT
    COUNT(*) FILTER (WHERE b.starts_at >= t.day_start AND b.starts_at < t.day_end
                        AND b.status IN ('PENDING', 'CONFIRMED', 'COMPLETED')) AS today_booking_count,
    COUNT(*) FILTER (WHERE b.status = 'PENDING') AS pending_booking_count,
    COALESCE(SUM(b.total_price) FILTER (WHERE b.status = 'COMPLETED'
                        AND b.starts_at >= t.day_start AND b.starts_at < t.day_end), 0) AS today_booking_revenue
FROM public.bookings b
JOIN public.sports_fields f ON f.field_id = b.field_id
CROSS JOIN bounds t
WHERE f.owner_id = 1;
```
