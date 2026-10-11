# Khách hàng đã đánh giá

Code: [CustomerDB.java](../../src/main/java/com/sportify/data/CustomerDB.java),
[CustomerOverview.java](../../src/main/java/com/sportify/model/CustomerOverview.java),
[ManageCustomersServlet.java](../../src/main/java/com/sportify/controller/ManageCustomersServlet.java).

Hiện trang Khách hàng lấy dữ liệu từ `reviews`, chưa có bảng `customers` hay tài khoản
người dùng. Nhóm theo tên, nên hai khách cùng tên có thể gộp thành một dòng.
`CustomerOverview` là DTO, không phải JPA entity và không có bảng riêng.

## 1. Danh sách tổng hợp theo tên

Hàm: `findByOwnerId(ownerId, search)`. `$1`: owner ID.

```sql
SELECT r.customer_name,
       COUNT(*) AS review_count,
       COUNT(DISTINCT f.field_id) AS field_count,
       AVG(r.rating) AS average_rating,
       MAX(r.created_at) AS last_review_at
FROM public.reviews r
JOIN public.sports_fields f ON f.field_id = r.field_id
WHERE f.owner_id = $1
GROUP BY r.customer_name
ORDER BY MAX(r.created_at) DESC, r.customer_name ASC;
```

## 2. Tìm theo tên

`$2`: mẫu tìm kiếm đã chuyển thường, escape ký tự `!`, `%`, `_`, rồi bọc bởi `%`.
Ví dụ từ khóa `bảo` -> `%bảo%`, từ khóa `%` -> `%!%%`.

```sql
SELECT r.customer_name,
       COUNT(*) AS review_count,
       COUNT(DISTINCT f.field_id) AS field_count,
       AVG(r.rating) AS average_rating,
       MAX(r.created_at) AS last_review_at
FROM public.reviews r
JOIN public.sports_fields f ON f.field_id = r.field_id
WHERE f.owner_id = $1
  AND LOWER(r.customer_name) LIKE $2 ESCAPE '!'
GROUP BY r.customer_name
ORDER BY MAX(r.created_at) DESC, r.customer_name ASC;
```

Code tạo tham số:

```java
String escaped = search.toLowerCase(Locale.ROOT)
        .replace("!", "!!").replace("%", "!%").replace("_", "!_");
query.setParameter("search", "%" + escaped + "%");
```

## 3. Thống kê toàn bộ danh sách của chủ sân

Hàm: `getSummaryByOwnerId(ownerId)`. Không phụ thuộc từ khóa tìm kiếm.

```sql
SELECT COUNT(DISTINCT r.customer_name) AS customer_name_count,
       COUNT(*) AS review_count,
       COUNT(DISTINCT f.field_id) AS reviewed_field_count
FROM public.reviews r
JOIN public.sports_fields f ON f.field_id = r.field_id
WHERE f.owner_id = $1;
```

Trang này chỉ đọc, không có INSERT/UPDATE/DELETE khách hàng. Các tên khách trên đơn
Booking chưa được ghép vào đây; cần định danh customer/user ổn định để nối danh tính chính xác.
