# Quản lý đánh giá và phản hồi

Code: [ReviewDB.java](../../src/main/java/com/sportify/data/ReviewDB.java),
[Review.java](../../src/main/java/com/sportify/model/Review.java).
Servlet: `ManageReviewsServlet`, `ReplyReviewServlet`.

## 1. Danh sách đánh giá theo chủ sân

Hàm: `findByOwnerId(ownerId, rating)`. `$1`: owner ID.
JOIN với sân để giới hạn quyền sở hữu và lấy tên sân cho JSP.

```sql
SELECT r.*, f.field_name, f.owner_id
FROM public.reviews r
JOIN public.sports_fields f ON f.field_id = r.field_id
WHERE f.owner_id = $1
ORDER BY r.created_at DESC, r.review_id DESC;
```

JPQL thực tế:

```java
"SELECT review FROM Review review " +
"JOIN FETCH review.field field " +
"WHERE field.ownerId = :ownerId " +
"ORDER BY review.createdAt DESC, review.reviewId DESC"
```

## 2. Lọc số sao

`$2`: số sao 1–5. Khi không chọn sao, không thêm điều kiện rating.

```sql
SELECT r.*, f.field_name, f.owner_id
FROM public.reviews r
JOIN public.sports_fields f ON f.field_id = r.field_id
WHERE f.owner_id = $1
  AND r.rating = $2
ORDER BY r.created_at DESC, r.review_id DESC;
```

## 3. Tổng số và điểm trung bình

Hàm: `getSummaryByOwnerId(ownerId)`. Không phụ thuộc bộ lọc sao.
JPA trả NULL cho AVG khi chưa có đánh giá; Java chuyển thành `0.0`.

```sql
SELECT COUNT(*) AS total_reviews,
       COALESCE(AVG(r.rating), 0) AS average_rating
FROM public.reviews r
JOIN public.sports_fields f ON f.field_id = r.field_id
WHERE f.owner_id = $1;
```

## 4. Thêm/cập nhật phản hồi

Hàm: `saveOwnerReply(reviewId, ownerId, ownerReply)`.
`$1`: review ID; `$2`: owner ID; `$3`: phản hồi đã trim; `$4`: thời gian phản hồi.

```sql
UPDATE public.reviews
SET owner_reply = $3,
    replied_at = $4
WHERE review_id = $1
  AND field_id IN (
      SELECT field_id
      FROM public.sports_fields
      WHERE owner_id = $2
  );
```

Điều kiện owner nằm ngay trong UPDATE. Số dòng cập nhật bằng 1 mới coi là thành công;
ID không tồn tại hoặc thuộc owner khác không được ghi. Phản hồi không rỗng, tối đa 2.000 ký tự.
Sau POST, servlet redirect về `/owner/reviews`, giữ bộ lọc sao.
