
```sql
SELECT r.customer_name,
       COUNT(*) AS review_count,
       COUNT(DISTINCT r.field_id) AS field_count,
       AVG(r.rating) AS average_rating,
       MAX(r.created_at) AS last_review_at
FROM public.reviews r
JOIN public.sports_fields f ON f.field_id = r.field_id
WHERE f.owner_id = 1
GROUP BY r.customer_name
ORDER BY MAX(r.created_at) DESC, r.customer_name ASC;

SELECT COUNT(DISTINCT r.customer_name) AS customer_name_count,
       COUNT(*) AS review_count,
       COUNT(DISTINCT r.field_id) AS reviewed_field_count
FROM public.reviews r
JOIN public.sports_fields f ON f.field_id = r.field_id
WHERE f.owner_id = 1;
```
