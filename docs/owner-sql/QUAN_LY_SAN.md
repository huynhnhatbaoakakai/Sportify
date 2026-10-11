# Quản lý sân

Code: [SportFieldDB.java](../../src/main/java/com/sportify/data/SportFieldDB.java),
[SportField.java](../../src/main/java/com/sportify/model/SportField.java).
Servlet: `ManageFieldsServlet`, `CreateFieldServlet`, `UpdateFieldServlet`, `ToggleFieldStatusServlet`.

## 1. Danh sách sân của chủ sân

Hàm: `SportFieldDB.findByOwnerId(ownerId)`. `$1`: owner ID.

```sql
SELECT f.*
FROM public.sports_fields f
WHERE f.owner_id = $1
ORDER BY f.created_at DESC;
```

JPQL trong code:

```java
"SELECT field FROM SportField field " +
"WHERE field.ownerId = :ownerId " +
"ORDER BY field.createdAt DESC"
```

## 2. Lấy một sân để chỉnh sửa

Hàm: `findByIdAndOwnerId(fieldId, ownerId)`. `$1`: field ID; `$2`: owner ID.

```sql
SELECT f.*
FROM public.sports_fields f
WHERE f.field_id = $1
  AND f.owner_id = $2;
```

## 3. Thêm sân

Hàm: `insert(field)`, dùng `em.persist(field)` trong transaction.
Khóa `field_id` được PostgreSQL sinh. `SportField.beforeInsert()` đặt thời gian tạo/cập nhật.

```sql
INSERT INTO public.sports_fields (
    owner_id, field_name, sport_type, address, description,
    price_per_hour, open_time, close_time, image_url, status,
    created_at, updated_at
)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
RETURNING field_id;
```

Tham số theo thứ tự cột. Servlet hiện gán `owner_id = 1`, kiểm tra tên/địa chỉ,
môn thể thao, giá dương và giờ đóng sau giờ mở trước khi gọi lớp DB.

## 4. Cập nhật sân

Hàm: `update(updatedField, ownerId)`.
Code dùng `em.find(SportField.class, fieldId)`, kiểm tra owner trong Java, sửa thuộc tính
của entity được quản lý rồi commit. `@PreUpdate` cập nhật `updated_at`.
SQL dưới đây gộp điều kiện owner đã kiểm tra vào WHERE để thể hiện đầy đủ quy tắc:

```sql
UPDATE public.sports_fields
SET field_name = $3,
    sport_type = $4,
    address = $5,
    description = $6,
    price_per_hour = $7,
    open_time = $8,
    close_time = $9,
    image_url = $10,
    status = $11,
    updated_at = $12
WHERE field_id = $1
  AND owner_id = $2;
```

Hibernate thực tế có thể UPDATE theo khóa chính sau bước kiểm tra owner trong Java;
không có chuỗi UPDATE viết trực tiếp trong lớp này.

## 5. Bật/tắt hoạt động

Hàm: `toggleStatus(fieldId, ownerId)`. Code đọc sân theo ID, kiểm tra owner,
đổi `ACTIVE`/`INACTIVE` rồi commit. SQL tương đương:

```sql
UPDATE public.sports_fields
SET status = CASE WHEN status = 'ACTIVE' THEN 'INACTIVE' ELSE 'ACTIVE' END,
    updated_at = $3
WHERE field_id = $1
  AND owner_id = $2;
```

Các thao tác ghi đều begin/commit và rollback khi lỗi; `EntityManager` được đóng trong `finally`.
