
```sql
SELECT b.booking_id, f.field_name, f.owner_id, b.customer_name, b.customer_phone,
       b.starts_at, b.ends_at, b.total_price, b.status, b.updated_at
FROM public.bookings b
JOIN public.sports_fields f ON f.field_id = b.field_id
WHERE f.owner_id = 1
ORDER BY b.created_at DESC, b.booking_id DESC;
```
