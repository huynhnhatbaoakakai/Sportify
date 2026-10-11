# Quản lý đặt sân

Code: [BookingDB.java](../../src/main/java/com/sportify/data/BookingDB.java),
[Booking.java](../../src/main/java/com/sportify/model/Booking.java),
`ManageFieldsServlet`, `UpdateBookingStatusServlet`.
Schema: [bookings.sql](../../database/bookings.sql).

## 1. Danh sách đơn thuộc sân của chủ sân

Hàm: `findByOwnerId(ownerId)`. `$1`: owner ID.

```sql
SELECT b.*, f.field_name, f.owner_id
FROM public.bookings b
JOIN public.sports_fields f ON f.field_id = b.field_id
WHERE f.owner_id = $1
ORDER BY b.created_at DESC, b.booking_id DESC;
```

JPQL dùng `JOIN FETCH booking.field` để JSP đọc được thông tin sân sau khi đóng EntityManager.
Hiện lọc trạng thái/tìm mã đơn, tên khách, tên sân, SĐT được JavaScript thực hiện trên danh sách đã tải.

## 2. Kiểm tra quyền sở hữu trước cập nhật

Hàm: `changeStatus(bookingId, ownerId, status)`.
`$1`: booking ID; `$2`: owner ID.

```sql
SELECT b.field_id
FROM public.bookings b
JOIN public.sports_fields f ON f.field_id = b.field_id
WHERE b.booking_id = $1
  AND f.owner_id = $2;
```

Không có dòng -> NOT_FOUND. Không trả dữ liệu riêng của đơn thuộc chủ sân khác.

## 3. Khóa sân rồi khóa đơn

Trong cùng transaction; thứ tự khóa giống nhau giữa các request để tránh tranh chấp.
Hai câu được thực hiện riêng: `$1` ở câu đầu là field ID đã đọc ở bước trên,
`$1` ở câu sau là booking ID.

```sql
SELECT f.*
FROM public.sports_fields f
WHERE f.field_id = $1
FOR UPDATE;

SELECT b.*
FROM public.bookings b
WHERE b.booking_id = $1
FOR UPDATE;
```

JPA dùng `em.find(..., LockModeType.PESSIMISTIC_WRITE)`.
Sau khi khóa, Java kiểm tra lại owner và sân của đơn, chỉ cho xử lý trạng thái PENDING.
Khi xác nhận, Java kiểm tra sân ACTIVE, lịch chưa qua, cùng ngày, nằm trong giờ mở/đóng cửa.

## 4. Kiểm tra lịch trùng trước xác nhận

`$1`: field ID; `$2`: booking ID đang xử lý; `$3`: startsAt; `$4`: endsAt.

```sql
SELECT COUNT(*) AS conflicts
FROM public.bookings other
WHERE other.field_id = $1
  AND other.booking_id <> $2
  AND other.status IN ('CONFIRMED', 'COMPLETED')
  AND other.starts_at < $4
  AND other.ends_at > $3;
```

Hai lịch sát nhau không trùng. Ví dụ lịch 08:00–09:00 và 09:00–10:00 được phép.
Có lịch trùng -> rollback, giữ nguyên PENDING và báo CONFLICT.

## 5. Xác nhận/từ chối

Trong code, entity đã khóa được gán `status`/`updatedAt`, sau đó commit.
SQL dưới đây gộp cả điều kiện đã kiểm tra trong Java để mô tả đầy đủ quy tắc.
`$1`: booking ID; `$2`: owner ID; `$3`: CONFIRMED hoặc REJECTED; `$4`: thời gian cập nhật.

```sql
UPDATE public.bookings
SET status = $3,
    updated_at = $4
WHERE booking_id = $1
  AND status = 'PENDING'
  AND field_id IN (
      SELECT field_id FROM public.sports_fields WHERE owner_id = $2
  );
```

Hibernate có thể UPDATE theo khóa chính sau các bước khóa/kiểm tra trong Java.
Sau POST, servlet redirect về `/owner/bookings`, không chỉ đổi trạng thái trên HTML.

## 6. Ràng buộc PostgreSQL chống ghi trùng từ luồng khác

Phần trong migration tạo bảng, không chạy lại tùy ý trên bảng đã có constraint:

```sql
CONSTRAINT ex_bookings_confirmed_time EXCLUDE USING GIST (
    field_id WITH =,
    tsrange(starts_at, ends_at, '[)') WITH &&
) WHERE (status IN ('CONFIRMED', 'COMPLETED'))
```

Migration dùng extension `btree_gist` đi kèm PostgreSQL. Vi phạm constraint trả SQLSTATE
`23P01`; lớp DB rollback và báo trùng lịch. Các đơn PENDING được phép trùng nhau.

Luồng khách tự tạo đơn chưa nằm trong thay đổi này; không có servlet INSERT đơn công khai.
