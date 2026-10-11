# Sportify — quét backend phục vụ vấn đáp

## 1. Phạm vi, handle và mức xác minh

- **Handle repository:** `D:/Projects/Sportify` (Windows: `D:\Projects\Sportify`).
- **Handle tài liệu:** `D:/Projects/Sportify/docs/viva/BACKEND_SCAN.md`.
- Đã đọc toàn bộ **17 file Java production**, **2 file Java test** trong `src/test`, `pom.xml`, persistence descriptor nguồn, deployment descriptor nguồn và toàn bộ hai file trong `database` (`reviews.sql`, `README.md`). Đọc thêm các JSP liên quan để đối chiếu form, output escaping và đăng nhập giả lập.
- **STATIC / có code:** các kết luận dưới đây dựa trên source và line, không phải kết quả chạy ứng dụng.
- **RUNTIME / verified:** chưa xác minh Tomcat, WAR đang triển khai, HTTP response thực tế, schema thực tế hoặc dữ liệu PostgreSQL. Không chạy Maven, không chạy test, không khởi động ứng dụng, không kết nối DB và không thực thi migration/seed. Không coi các `.class` sẵn trong `target` là chứng cứ runtime thành công.
- Chỉ tạo tài liệu trong `docs/viva`; không sửa sản phẩm, không commit/push. Không chép giá trị mật khẩu/credential vào tài liệu.
- Line là line của snapshot nguồn khi đọc; nếu source đổi, cần đối chiếu lại. Các URL có host/cổng dưới đây là **ví dụ**, không phải endpoint đã xác nhận đang hoạt động.

### Quy ước evidence

Để tránh lặp đường dẫn dài, dùng các alias sau; `Alias.java:Lx–Ly` luôn tương ứng đúng file trong bảng:

| Alias | Đường dẫn relative từ repository | Số dòng |
|---|---|---:|
| ChatServlet.java | `src/main/java/com/sportify/controller/ChatServlet.java` | 99 |
| CreateFieldServlet.java | `src/main/java/com/sportify/controller/CreateFieldServlet.java` | 138 |
| ManageFieldsServlet.java | `src/main/java/com/sportify/controller/ManageFieldsServlet.java` | 43 |
| ManageReviewsServlet.java | `src/main/java/com/sportify/controller/ManageReviewsServlet.java` | 63 |
| OwnerAccessLogoutServlet.java | `src/main/java/com/sportify/controller/OwnerAccessLogoutServlet.java` | 33 |
| OwnerAccessServlet.java | `src/main/java/com/sportify/controller/OwnerAccessServlet.java` | 77 |
| ReplyReviewServlet.java | `src/main/java/com/sportify/controller/ReplyReviewServlet.java` | 63 |
| ToggleFieldStatusServlet.java | `src/main/java/com/sportify/controller/ToggleFieldStatusServlet.java` | 59 |
| UpdateFieldServlet.java | `src/main/java/com/sportify/controller/UpdateFieldServlet.java` | 130 |
| OwnerAccessFilter.java | `src/main/java/com/sportify/filter/OwnerAccessFilter.java` | 63 |
| ChatMessageDB.java | `src/main/java/com/sportify/data/ChatMessageDB.java` | 65 |
| DBUtil.java | `src/main/java/com/sportify/data/DBUtil.java` | 23 |
| ReviewDB.java | `src/main/java/com/sportify/data/ReviewDB.java` | 149 |
| SportFieldDB.java | `src/main/java/com/sportify/data/SportFieldDB.java` | 194 |
| ChatMessage.java | `src/main/java/com/sportify/model/ChatMessage.java` | 88 |
| Review.java | `src/main/java/com/sportify/model/Review.java` | 116 |
| SportField.java | `src/main/java/com/sportify/model/SportField.java` | 214 |

Các setter/getter trong ba model đã đọc đầy đủ: `ChatMessage.java:L49–87`, `Review.java:L53–115`, `SportField.java:L119–213`. Chúng chủ yếu đọc/gán property, không phải một lớp validation nghiệp vụ độc lập.

## 2. Stack thực tế và kiến trúc

- Maven WAR: `pom.xml:L7–10`; WAR final name `sportify`: `pom.xml:L56–57`.
- **Compiler source/target là Java 17, không phải Java 8:** `pom.xml:L16–20`. `Set.of` ở Create/Update và `String.isBlank` ở Toggle cũng không phải API Java 8. Đây là cấu hình source, không chứng minh JDK thực tế của máy hay Tomcat.
- Dependencies khai báo: JUnit 4.13.2 test scope (`pom.xml:L24–30`); Jakarta Servlet API 6.1.0 provided (`L32–38`); Hibernate ORM 7.4.6.Final (`L40–45`); PostgreSQL JDBC 42.7.13 (`L47–52`). Không phải Spring MVC/Spring Data; không có service layer riêng trong 17 file Java.
- Luồng chung: **HTTP/form → annotation servlet/filter → DAO tĩnh → JPA EntityManager/transaction → PostgreSQL → request attributes → JSP**.
- `src/main/webapp/WEB-INF/web.xml:L2–10` chỉ descriptor Servlet 4.0 namespace Java EE và display name; mapping thực tế nằm trong `@WebServlet`, `@WebFilter`. Namespace descriptor cũ và dependency Jakarta mới là điểm cần kiểm tra khi deploy, không kết luận lỗi deploy nếu chưa chạy.
- `src/main/resources/META-INF/persistence.xml:L11–22`: PU `sportifyPU`, `RESOURCE_LOCAL`, provider Hibernate, đăng ký cả ChatMessage, SportField, Review.
- PostgreSQL JDBC driver/URL: descriptor `L25–32`, `jdbc:postgresql://localhost:5432/sporttrent`. Credential được khai báo inline ở `L34–40`; **không ghi lại giá trị**. `hibernate.hbm2ddl.auto=validate` (`L47–49`), SQL logging bật (`L51–57`). Không tự tạo bảng bằng cấu hình này.
- `DBUtil.java:L8–16`: static EntityManagerFactory khởi tạo khi class được sử dụng, không phải mỗi request tạo một factory. `closeEntityManagerFactory()` (`L18–22`) có code nhưng không thấy listener/call-site lifecycle trong các Java nguồn đã quét.
- Validate áp dụng persistence unit chung: thiếu/mismatch bảng Review có thể khiến cả factory không dùng được, ảnh hưởng fields/chat, không chỉ reviews. Đây là rủi ro suy ra từ cấu hình + factory chung, chưa tái hiện runtime.
- `AGENT.md:L33–36` nói chưa có DAO/database, nhưng source hiện có DAO/entity và SQL. Hướng dẫn này mô tả giai đoạn cũ; không dùng làm kết luận tình trạng backend hiện tại.

## 3. Bản đồ URL → handler → dữ liệu → view

Giả định context `/sportify`, ví dụ base `http://localhost:8080/sportify`. Servlet thực tế dùng `request.getContextPath()`, không hardcode context.

| HTTP / URL relative | Method/evidence | Input | Output / view |
|---|---|---|---|
| GET `/owner/access` | `OwnerAccessServlet.doGet`, L24–44; mapping L12 | Session flag | Redirect `/owner/fields` nếu authorized; nếu không forward `/WEB-INF/views/owner-access.jsp` |
| POST `/owner/access` | `OwnerAccessServlet.doPost`, L46–76 | `password` | So sánh secret demo; đúng set session flag và redirect; sai forward với `errorMessage` |
| GET `/owner/access/logout` | `OwnerAccessLogoutServlet.doGet`, L17–32 | Session nếu tồn tại | Remove flag, redirect `/home.jsp` |
| GET `/owner/fields` | `ManageFieldsServlet.doGet`, L20–42; mapping L14 | Owner demo 1, không lấy owner từ client | `SportFieldDB.findByOwnerId`; attrs `fields`, `ownerId`; forward `/owner/dashboard.jsp` |
| POST `/owner/fields/create` | `CreateFieldServlet.doPost`, L28–127; mapping L16 | `fieldName,sportType,address,pricePerHour,openTime,closeTime,status` | Insert; redirect `?success=created#fields` hoặc `?error=invalid#fields` |
| POST `/owner/fields/update` | `UpdateFieldServlet.doPost`, L28–121; mapping L16 | Như create + `fieldId` | Owner-scoped lookup; 404 nếu không có; update; redirect `?success=updated#fields` |
| POST `/owner/fields/toggle` | `ToggleFieldStatusServlet.doPost`, L17–58; mapping L12 | `fieldId` | Toggle trạng thái; redirect `?success=toggled#fields`; ID parse lỗi → 400 |
| GET `/owner/reviews` | `ManageReviewsServlet.doGet`, L21–54; mapping L15 | `rating` optional | List và summary; forward `/owner/reviews.jsp`; invalid filter → 400; load failure → 503 |
| POST `/owner/reviews/reply` | `ReplyReviewServlet.doPost`, L17–58; mapping L11 | `reviewId,ownerReply,rating` | Update scoped owner; PRG, giữ filter hợp lệ |
| GET `/chat` | `ChatServlet.doGet`, L21–47; mapping L16 | `sender,receiver` optional | Select hội thoại hai chiều; attrs `sender,receiver,messages`; forward `/chat.jsp` |
| POST `/chat` | `ChatServlet.doPost`, L49–87 | `senderName,receiverName,messageText` | Persist nếu nonblank; redirect GET `/chat?sender=...&receiver=...` |

- `/owner/*` được `OwnerAccessFilter.doFilter` bảo vệ (`L15`, `L27–62`), trừ chính xác `/owner/access` và `/owner/access/logout`. Không có mapping bảo vệ `/chat` trong Java nguồn.
- Ví dụ URL đọc: `/sportify/owner/reviews?rating=5`; `/sportify/chat?sender=A&receiver=B`. Đây không phải API JSON; response là redirect hoặc JSP HTML.
- Chỉ override HTTP method nêu ở bảng; không có handler DELETE sân hay handler tạo review khách hàng trong source Java.

## 4. Field CRUD: rule, persistence và giới hạn

### 4.1 Nghiệp vụ thực hiện trong code

1. Owner cố định `DEMO_OWNER_ID = 1L`: Manage L17–18, Create L19, Update L19, Toggle L15. Đây là demo một owner, **không phải phân quyền đa tài khoản hoàn chỉnh**.
2. Create yêu cầu chuỗi nonblank và trim (`CreateFieldServlet.required`, L129–137); các trường parse ở `L37–71`.
3. Môn chỉ nhận `GYM`, `BASKETBALL`, `SWIMMING`, `PICKLEBALL` (Create L21–26/L79–83; Update L21–26/L78–80).
4. Giá `BigDecimal > 0` (Create L85–89; Update L82–84). Không có kiểm tra server riêng về precision/scale/trần giá theo numeric(12,2).
5. Giờ đóng **sau** giờ mở trong cùng ngày (Create L91–95; Update L86–88). Không hỗ trợ ca qua nửa đêm bằng rule này.
6. Chỉ `INACTIVE` được giữ; mọi input status khác/missing quy về `ACTIVE` (Create L73–77; Update L76/L90–92), không trả lỗi status lạ.
7. Không parse `description`, `imageUrl` từ form ở Create/Update. DAO update có copy hai property này (`SportFieldDB.java:L121–122/L133–134`) từ entity đã lấy; không suy ra có upload ảnh.
8. Read owner-scoped mới nhất trước (`SportFieldDB.findByOwnerId`, L15–34), nhưng chỉ sort `createdAt DESC`, không tie-break ID.
9. Update lookup `fieldId + ownerId` (`UpdateFieldServlet.java:L37–53`, `SportFieldDB.findByIdAndOwnerId:L36–65`) rồi DAO kiểm tra ownership lần nữa trong transaction (`update:L99–110`).
10. Toggle `ACTIVE → INACTIVE`, mọi trạng thái còn lại → `ACTIVE`; DAO check owner và trả false nếu missing/foreign (`SportFieldDB.toggleStatus:L149–185`). **Không DELETE bản ghi**. Có thể trình bày đây là tạm ngưng/kích hoạt, không gọi là hard delete hay soft-delete đã triển khai với cờ deleted.
11. Không có validation max length server cho name/address theo annotation; lỗi DB có thể đi ra exception. `@Column` không thay thế validation request.
12. `LocalTime.parse` có thể ném `DateTimeParseException` (không thuộc `IllegalArgumentException`): input giờ sai định dạng có thể vào catch `Exception` → ServletException thay vì redirect invalid (Create L59–71/L115–125; Update L68–74/L109–119). Đây là phân tích static, chưa thử HTTP.

### 4.2 Entity và transaction

- `SportField.java:L17–69` map `sports_fields`; PK `field_id` Long/IDENTITY; `owner_id` Long, không relationship User.
- `field_name` length150; `sport_type`30; `address`255; description; `price_per_hour` BigDecimal precision12 scale2; `open_time`, `close_time` LocalTime; `image_url`500; `status`20; timestamp LocalDateTime.
- `beforeInsert` `@PrePersist` (`L98–112`) set `createdAt`, `updatedAt`, default owner1 nếu null, default ACTIVE nếu blank. `beforeUpdate` `@PreUpdate` (`L114–117`) cập nhật `updatedAt`.
- Insert `SportFieldDB.insert:L67–85`: begin → persist → commit; runtime failure rollback; always close EM.
- Update `L87–147`: entity find trong EM mới, owner check, thay properties trên **managed entity**, commit qua dirty checking. Không cần `merge()` để cập nhật managed entity.
- Toggle `L149–185`: tương tự managed entity + transaction.
- **False success UI:** servlet update bỏ qua boolean DAO (`UpdateFieldServlet.java:L102–107`), toggle cũng bỏ qua (`ToggleFieldStatusServlet.java:L36–44`). Nếu DAO false, redirect vẫn báo success. Update đã lookup trước nên race/change giữa hai lần đọc mới có thể làm false; toggle không lookup trước, foreign/missing ID dễ đi đến nhánh này. Không có bằng chứng dữ liệu foreign bị sửa: DAO vẫn check owner.
- Không có `@Version`, locking hay cơ chế chống lost update trong model/DAO. Ownership field update check dựa trên entity load, không phải SQL UPDATE owner predicate nguyên tử như Review.

### 4.3 View evidence

`src/main/webapp/owner/dashboard.jsp`: escape helper L9–21; lấy attrs và redirect nếu không có list L23–32; đếm active từ list L34–40; output name/address escape L457–460; toggle form L473–479; create/update action và fields L527–604. `data-sport-type` output trực tiếp L447: servlet whitelist input, nhưng giá trị DB ngoài whitelist vẫn cần escape nếu muốn phòng thủ toàn diện.

## 5. Owner access: demo gate, không phải login thật

- `OwnerAccessFilter.java:L40–47`: chỉ hai path access/logout exempt; còn lại `getSession(false)` và yêu cầu flag `OWNER_DEMO_AUTHORIZED` là Boolean.TRUE (`L49–57`), không authorized → redirect access (`L59–61`). Annotation không khai báo dispatcherTypes khác; không nên mô tả filter đã kiểm tra mọi FORWARD/ERROR dispatcher.
- `OwnerAccessServlet.doGet:L30–43`: không tạo session chỉ để xem form; nếu đã authorized thì redirect fields.
- `doPost:L52–75`: parameter password so sánh constant secret demo khai báo `L15–16` (giá trị cố ý không chép). Đúng tạo/lấy session, set flag; sai request error và forward. Không UserDAO, hash password, role OWNER hay userId.
- Không thấy `changeSessionId`, rotate/invalidate session khi authorization thành công; có rủi ro session fixation. Không thấy rate limit/brute-force lockout.
- `OwnerAccessLogoutServlet.doGet:L23–31`: remove flag, **không invalidate toàn session**. Logout là GET có side effect.
- Access view nằm WEB-INF nên không truy cập JSP trực tiếp theo URL web thông thường (`OwnerAccessServlet.java:L21–22`); form POST/password ở `src/main/webapp/WEB-INF/views/owner-access.jsp:L60–69`.
- `src/main/webapp/login-process.jsp:L2–5` chỉ redirect home; `register-process.jsp:L2–5` chỉ redirect login với `registered=true`: dummy, không tạo user hay xác thực DB. Không nhầm hai trang này với owner demo gate.

## 6. Review: owner-scoped listing, thống kê, reply

### 6.1 Model/schema

- `Review.java:L16–48`: table reviews; review_id Long IDENTITY; `field` ManyToOne LAZY optional=false, FK field_id; customer_name length100 tạm thay user relationship (TODO L31); rating Integer; comment/owner_reply TEXT; created_at nonnull/updatable=false; replied_at optional.
- Review không có PrePersist tự tạo `createdAt`. SQL migration đặt DEFAULT CURRENT_TIMESTAMP; vì không có endpoint persist review khách trong Java hiện tại, không khẳng định default sẽ tự hoạt động cho mọi lần JPA persist nếu sau này entity gửi null.
- `database/reviews.sql:L8–20`: PK identity, FK `public.sports_fields(field_id)`, rating CHECK BETWEEN1AND5, NOT NULL field/customer/rating/comment/created_at. Không có ON DELETE CASCADE trong FK được khai báo.
- Index `idx_reviews_field_created(field_id, created_at DESC, review_id DESC)` (`L22–23`). Chưa xác minh index đã tồn tại DB.

### 6.2 Read và summary

- `ManageReviewsServlet.parseRating:L56–62`: null/blank → không filter; chỉ một ký tự 1–5 sau trim. Không chấp nhận 01, số thập phân hoặc chuỗi SQL.
- Invalid nonblank filter → errorMessage và 400 nhưng vẫn list không filter (`doGet:L28–37`), không dừng query.
- `ReviewDB.findByOwnerId:L17–50`: requireOwnerId >0, validate rating; JPQL JOIN FETCH field để JSP còn đọc fieldName sau đóng EM; owner predicate; optional rating; sort createdAt DESC rồi reviewId DESC.
- `getSummaryByOwnerId:L52–74`: COUNT/AVG trên **tất cả review của owner**, không theo filter rating; AVG null →0.0. List và summary dùng hai EM/query riêng, không snapshot transaction chung nên concurrent write có thể khiến số liệu lệch nhất thời.
- Load failure catch runtime/initializer/class-def error, log server và render empty/0 + `loadFailed=true` + HTTP503 (`ManageReviewsServlet.java:L42–53`). UI phải phân biệt lỗi với chưa có dữ liệu.

### 6.3 Reply

- `ReplyReviewServlet.doPost:L28–46`: reviewId chỉ chữ số, parse Long, >0; reply nonblank; **raw length <=2000 trước trim**. Overlong/blank redirect lỗi; rating filter chỉ giữ nếu parse hợp lệ.
- `ReviewDB.saveOwnerReply` public (`L76–90`) lặp validation owner/id/reply, trim rồi gọi overload có EM. Overload package-private (`L92–124`) không tự lặp validation, dành cho nội bộ/test.
- Bulk JPQL UPDATE có owner predicate trong chính mutation (`L99–111`): review_id khớp và field_id thuộc subquery owner. Set ownerReply, repliedAt=LocalDateTime.now; executeUpdate, commit; true chỉ khi affected rows ==1 (`L113–115`). Đây là cơ chế chống IDOR ở cấp mutation cho owner parameter đang được truyền.
- False → `error=notfound`; invalid → `error=invalid`; failure → `error=save`; true → `success=replied`, giữ `&rating=N` (`ReplyReviewServlet.java:L48–62`). PRG tránh refresh gửi lại POST nhưng không phải cơ chế idempotency/chống submit đồng thời.
- Không có API tạo/xóa review khách, không kiểm tra đã booking/completed booking. Không được nói khách chỉ review sau sử dụng sân khi code không có rule đó.
- View `src/main/webapp/owner/reviews.jsp`: escaping helper L9–20; attrs/errors L21–55; form GET filter L192–200; output field/customer/comment/reply escaped L223–240; form reply POST/id/filter/textarea maxlength2000 L249–257. Escape `</textarea>` và HTML/script tại output, không xóa nội dung lúc lưu.

## 7. Chat: database-backed messages nhưng UI vẫn có mock

- `ChatServlet.getValueOrDefault:L89–98` trim tên; null/blank dùng sender `Khách hàng`, receiver `Sân bóng Sunrise` (L18–19). Tên không phải credential nên có thể nêu để hiểu demo.
- GET đọc `sender`, `receiver` từ query (`L30–39`); POST đọc **tên parameter khác** `senderName`, `receiverName`, `messageText` (`L57–65`). Không gắn tên với session user.
- POST chỉ kiểm tra message nonnull/nonblank, trim, new ChatMessage và insert (`L67–74`). Blank vẫn redirect nhưng không insert. Không server-side giới hạn message1000/tên100 như annotations; maxlength HTML không chặn request tự tạo.
- `ChatMessage.java:L13–34`: chat_messages; message_id Long IDENTITY; sender_name/receiver_name nonnull length100; message_text nonnull length1000; sent_at LocalDateTime.now ở field initializer. Không relationship User/Conversation/Field.
- `ChatMessageDB.insert:L15–36`: persist transaction/rollback/EM.close.
- `selectConversation:L38–64`: parameterized JPQL, hai hướng A→B hoặc B→A, sentAt ASC; không pagination, không ID tie-break khi timestamp trùng.
- Redirect URL encode sender/receiver UTF-8 (`ChatServlet.java:L76–86`); không phải output HTML escaping, hai cơ chế khác mục đích.
- `src/main/webapp/chat.jsp:L5–18` escape helper; attrs/defaults L23–44; render DB list/message text escaped L451–474; POST hidden name fields escaped và message maxlength1000 L477–499.
- Sidebar/header conversation vẫn mảng mock (`chat.jsp:L504–551`), `currentConversationId='c1'` L553, render/updateHeader L555–600, DOMContentLoaded L602–608. Header có thể vẫn hiện mock Sunrise dù query receiver khác. Không thấy WebSocket/polling/read-receipt/file attachment backend; nút attach chỉ type=button (`L486–488`). Không gọi chat là realtime.
- **Security nghiêm trọng:** client có thể tự chọn cặp tên GET để đọc hoặc POST mạo danh sender. Không owner filter trên /chat, không authentication/participant authorization. Parameterized query chỉ chống injection, không bảo vệ quyền riêng tư.

## 8. SQL / JPQL và điều gì thực sự đã được kiểm tra

### 8.1 Query có trong Java (JPQL, không phải SQL native)

| Method | Query/operation thực tế | Evidence |
|---|---|---|
| SportFieldDB.findByOwnerId | `SELECT field FROM SportField field WHERE field.ownerId=:ownerId ORDER BY field.createdAt DESC` | L19–30 |
| SportFieldDB.findByIdAndOwnerId | `WHERE field.fieldId=:fieldId AND field.ownerId=:ownerId` | L43–61 |
| SportFieldDB.insert/update/toggleStatus | `persist` / `find` + dirty checking; Hibernate sinh SQL | L67–185 |
| ReviewDB.findByOwnerId | `JOIN FETCH review.field field WHERE field.ownerId=:ownerId` + optional rating + two-key sort | L30–46 |
| ReviewDB.getSummaryByOwnerId | `SELECT COUNT(review), AVG(review.rating) ... review.field.ownerId=:ownerId` | L60–69 |
| ReviewDB.saveOwnerReply | UPDATE reply/time với field IN owner subquery | L100–115 |
| ChatMessageDB.selectConversation | Cặp tên hai chiều; `ORDER BY message.sentAt ASC` | L45–60 |
| ChatMessageDB.insert | `persist` với transaction | L15–35 |

Tham số dùng setParameter; concat JPQL ở review chỉ thêm fragment cố định dựa trên rating có/không, không nối trực tiếp input thành query. Không có SQL string nối user input trong 17 Java production file đã đọc.

### 8.2 SQL migration/seed có trong repository — KHÔNG chạy

`database/reviews.sql`: phần1 BEGIN/CREATE TABLE/CREATE INDEX/COMMIT L6–25; phần2 BEGIN/CTE/INSERT/COMMIT L32–75. Seed chọn owner_id1, ROW_NUMBER và fallback sân đầu; năm review mẫu 1–5 sao; no fields → không insert; NOT EXISTS theo field/name/comment để tránh chèn lại cùng mẫu (L34–73). Đây là write SQL, **không thực thi** trong lần quét này. `IF NOT EXISTS` không sửa schema cũ sai cấu trúc; NOT EXISTS seed không phải unique constraint chống hai transaction chạy đồng thời.

Trong thư mục `database` chỉ có SQL reviews; không có migration nguồn cho sports_fields/chat_messages tại vị trí đã quét. Không suy ra schema live từ annotation. `database/README.md:L15–19` mô tả manual deploy/migration và nói ứng dụng không tự chạy script.

### 8.3 SELECT tham khảo để owner kiểm tra sau — chưa thực thi

Không cần kết nối DB để hoàn thành static scan. Khi được phép kiểm tra riêng, chỉ chạy SELECT dưới đây; không dùng seed/integration test để kiểm tra production DB.

```sql
SELECT table_name, column_name, data_type, is_nullable,
       character_maximum_length, numeric_precision, numeric_scale
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('sports_fields', 'reviews', 'chat_messages')
ORDER BY table_name, ordinal_position;

SELECT field_id, owner_id, field_name, sport_type, address,
       price_per_hour, open_time, close_time, status, created_at, updated_at
FROM public.sports_fields
WHERE owner_id = 1
ORDER BY created_at DESC;

SELECT r.review_id, r.field_id, f.field_name, f.owner_id,
       r.customer_name, r.rating, r.comment, r.owner_reply,
       r.created_at, r.replied_at
FROM public.reviews r
JOIN public.sports_fields f ON f.field_id = r.field_id
WHERE f.owner_id = 1
ORDER BY r.created_at DESC, r.review_id DESC;

SELECT COUNT(*) AS total_reviews, AVG(r.rating) AS average_rating
FROM public.reviews r
JOIN public.sports_fields f ON f.field_id = r.field_id
WHERE f.owner_id = 1;

SELECT message_id, sender_name, receiver_name, message_text, sent_at
FROM public.chat_messages
WHERE (sender_name = 'A' AND receiver_name = 'B')
   OR (sender_name = 'B' AND receiver_name = 'A')
ORDER BY sent_at ASC;
```

A/B là tên demo cần thay bằng cặp được phép xem. Các SELECT là đối chiếu ngữ nghĩa JPQL/entity, **không phải SQL do Hibernate đã capture**. Không nêu row count live khi chưa query.

## 9. Bốn luồng 13 bước để trình bày vấn đáp

Mỗi luồng dưới đây có đúng 13 bước; là trace source, không phải log runtime.

### 9.1 Field CRUD (C/R/U + toggle thay cho D, không có delete)

1. Trình duyệt yêu cầu GET `/owner/fields` hoặc gửi POST create/update/toggle từ dashboard (`dashboard.jsp:L473–479/L527–604`).
2. Container định tuyến annotation servlet tương ứng (Manage L14; Create L16; Update L16; Toggle L12).
3. `OwnerAccessFilter.doFilter` xử lý `/owner/*`, kiểm tra session flag; thiếu flag redirect access trước DAO (`L40–61`).
4. Handler hợp lệ dùng owner demo1; POST đặt UTF-8 (Create/Update L34; Toggle L23), GET không nhận ownerId từ client.
5. Nhánh READ gọi `findByOwnerId`; POST lấy parameters; UPDATE/TOGGLE parse fieldId (Manage L27–31; Update L37–39; Toggle L26–34).
6. UPDATE lookup ID+owner và 404 nếu không có; CREATE/UPDATE required trim name/type/address/price/time (Update L41–74; Create L37–71/L129–137).
7. CREATE/UPDATE kiểm tra whitelist sport, giá>0, close>open và normalize status; TOGGLE chỉ cần ID parse (Create L73–95; Update L78–92).
8. CREATE dựng entity owner1 và properties; UPDATE sửa entity lookup; TOGGLE chuyển ID+owner cho DAO (Create L97–108; Update L94–102; Toggle L36–39).
9. DAO lấy factory `sportifyPU`, tạo EM; READ chạy parameterized JPQL; mutation bắt đầu transaction (DBUtil L8–16; SportFieldDB L15–30/L67–75/L87–98/L149–159).
10. UPDATE/TOGGLE DAO find lại entity và check owner; missing/foreign rollback false; INSERT persist (SportFieldDB L76/L99–110/L161–169).
11. Mutation sửa managed state, entity callbacks set timestamps và commit; failure rollback, finally close EM; READ lấy list rồi close (SportFieldDB L31–33/L78–84/L112–145/L171–183; SportField L98–117).
12. READ set attrs và forward dashboard; mutation PRG redirect result; update/toggle chưa xét boolean nên success banner không chắc có write (Manage L30–34; Create L110–125; Update L102–119; Toggle L41–56).
13. Dashboard render list/active count và form cho request tiếp; đổi INACTIVE là ngừng hoạt động, không xóa row và không chứng minh booking bị chặn (`dashboard.jsp:L26–40/L446–484`).

### 9.2 Owner access

1. User truy cập một URL owner được bảo vệ, ví dụ `/owner/fields` (`OwnerAccessFilter.java:L15`).
2. Filter đọc servletPath và phân biệt hai exempt path access/logout (`L40–47`).
3. Filter lấy session(false), đọc đúng Boolean flag, không query user DB (`L49–53`).
4. Chưa authorized → redirect `<context>/owner/access` (`L59–61`).
5. Trình duyệt gửi GET access; path exempt được chain tiếp đến servlet (`Filter L42–46`; Servlet mapping L12).
6. `OwnerAccessServlet.doGet` kiểm tra flag; authorized sẵn thì redirect fields và return (`L30–39`).
7. Nếu chưa có flag, forward view WEB-INF; view render form password (`Servlet L42–43`; access.jsp L60–69).
8. User gửi POST access; servlet set UTF-8, lấy parameter password (`Servlet L46–54`).
9. Servlet so sánh secret demo constant; không hash/lookup user/role (`L15–16/L56`).
10. Sai password: set errorMessage và forward lại form, không cấp flag (`L69–75`).
11. Đúng password: getSession và set OWNER_DEMO_AUTHORIZED Boolean.TRUE, không thấy đổi session ID (`L57–61`).
12. Redirect fields; GET tiếp đi qua filter và chain nếu flag true; các DAO vẫn dùng owner1 (`Servlet L63–66`; Filter L51–56).
13. Khi GET logout: remove flag nếu có session, redirect home; truy cập owner sau đó lại cần access, không invalidate toàn session (`OwnerAccessLogoutServlet.java:L23–31`).

### 9.3 Review list/filter/reply

1. User GET `/owner/reviews?rating=5` qua OwnerAccessFilter như mọi owner URL (Filter L15/L49–61).
2. `ManageReviewsServlet.doGet` set request/response UTF-8 (`L21–26`).
3. `parseRating` chỉ nhận 1–5; invalid nonblank set400/error nhưng vẫn tiếp tục list unfiltered (`L28–34/L56–62`).
4. Handler gọi DAO list owner1 + rating, và DAO summary owner1 không rating (`L37–41`).
5. DAO list JOIN FETCH field, scope owner, optional rating, sort mới nhất+ID; bind parameters (`ReviewDB.java:L30–46`).
6. DAO summary COUNT/AVG, empty average0; mỗi read EM đóng finally (`ReviewDB.java:L47–49/L58–73`).
7. Servlet set attrs và forward reviews JSP; failure set loadFailed/503; JSP hiển thị dữ liệu/error và escape text (`Manage L39–53`; reviews.jsp L157–179/L223–240).
8. User POST form reply chứa reviewId, ownerReply và rating đang lọc (`reviews.jsp:L249–257`).
9. Reply servlet set UTF-8, parse trusted filter, kiểm tra digit ID/Long>0, nonblank và raw length<=2000 (`ReplyReviewServlet.java:L21–46`).
10. Public DAO validate owner/id/reply lần nữa, trim, tạo EM rồi begin transaction (`ReviewDB.java:L76–97`).
11. Bulk UPDATE ràng buộc reviewId và field thuộc owner trong chính WHERE; set reply/time, bind params (`ReviewDB.java:L99–111`).
12. ExecuteUpdate/commit, true iff1; runtime failure rollback, EM close; servlet chọn success/notfound/invalid/save (`ReviewDB.java:L113–122`; Reply L48–55).
13. Redirect GET reviews giữ filter hợp lệ; list lại và escape reply kể cả textarea, refresh không tự lặp POST (`Reply L57–62`; reviews.jsp L240/L249–254`).

### 9.4 Chat read/send

1. Trình duyệt GET `/chat?sender=A&receiver=B` (ChatServlet mapping L16).
2. Không đi qua owner-only filter; không có participant auth trong ChatServlet (Filter mapping L15; Chat doGet L21–47).
3. Handler set UTF-8 request và response (`Chat L27–28`).
4. Lấy sender/receiver; trim/default nếu missing/blank (`Chat L30–36/L89–98`).
5. Gọi `ChatMessageDB.selectConversation(sender,receiver)` (`Chat L38–39`).
6. DAO tạo EM, bind sender/receiver trong điều kiện hai chiều, sort sentAt ASC (`ChatMessageDB.java:L42–60`).
7. DAO close EM; servlet set attrs rồi forward chat.jsp (`DAO L61–63`; Chat L41–46).
8. JSP render messages DB, tính sent/received theo currentSender, escape text; sidebar/header vẫn mock (`chat.jsp:L451–474/L504–608`).
9. User POST `/chat` với hidden senderName/receiverName + messageText (`chat.jsp:L477–499`).
10. doPost set UTF-8, trim/default names; nonblank message mới trim và dựng ChatMessage; blank bỏ insert (`Chat L55–74`; model L33–46).
11. DAO insert tạo EM/transaction begin/persist/commit; failure rollback/rethrow; close EM (`ChatMessageDB.java:L15–35`).
12. Servlet URL-encode hai tên UTF-8 và redirect GET `/chat?sender=...&receiver=...` (`Chat L76–86`).
13. GET tiếp đọc lại hội thoại và render; không push realtime, không chứng minh identities thật và không ngăn người khác đọc/mạo danh cặp tên.

## 10. Security và reliability: điều có / điều thiếu

| Chủ đề | Nhận xét static, không phải pentest | Evidence |
|---|---|---|
| SQL injection | JPQL parameter binding; whitelist fragments; không nối input trực tiếp | SportFieldDB L19–30/L43–55; ReviewDB L30–45/L100–111; ChatMessageDB L45–58 |
| Owner data access | Fields read/update/toggle và review read/reply check owner parameter; nhưng parameter luôn demo1, chưa auth user thực | Field servlet constants; Review servlet TODO; DAO methods nêu trên |
| Review forged ID | Owner condition nằm trong bulk UPDATE; foreign/missing → false, không báo thành công | ReviewDB L99–115; Reply L48–49 |
| Chat privacy/impersonation | Không auth/participant check; query/post names do client chọn | ChatServlet L30–39/L57–73; OwnerAccessFilter L15 |
| CSRF | Không thấy token/server validation Origin/Referer trên các mutation/access; logout GET cũng là side effect | Toàn bộ doPost; logout L17–31; JSP forms |
| Session | Boolean demo flag, không role; login không rotate session, logout không invalidate | OwnerAccessServlet L56–65; Logout L23–27 |
| Password/secrets | Secret demo và DB credential inline; không chép giá trị. Cần externalize và thay authentication trước production | OwnerAccessServlet L15–16; persistence.xml L34–40 |
| XSS | Escape HTML cho field names/address, review/customer/reply/textarea, chat message/hidden names; chưa audit toàn frontend | dashboard.jsp L9–21/L457–460; reviews.jsp L9–20/L223–254; chat.jsp L5–18/L467/L482–485 |
| Server validation | Field whitelist/price/hours và review reply bounds có; chat size/name bound chỉ HTML/entity, chưa server check | Create/Update rules; Reply L29–46; Chat L65–74; ChatMessage L24–31 |
| Concurrency | Không @Version; field update/toggle read-modify-write; summary/list separate reads; reply last-write-wins | SportField/Review models; DAO mutation/read paths |
| False success | Update/toggle bỏ boolean DAO; success URL cũng có thể tự gõ nên banner không phải audit trail | Update L102–107; Toggle L36–44; reviews.jsp L158 |
| Resource handling | DAO finally close EM, mutation rollback; factory close method không có lifecycle caller đã thấy | DBUtil L18–22; DAO finally/catch |
| Availability/logging | PU chung validate có thể làm mất nhiều tính năng; review graceful503/save error, fields/chat propagation; SQL/log exceptions có thể chứa dữ liệu | persistence.xml L47–57; ManageReviews L42–50; Reply L52–54; field catch; Chat doGet/doPost |

Không suy ra cookie Secure/HttpOnly/SameSite, HTTPS/TLS, reverse proxy, DB grants, connection pool hay actual session timeout khi chưa đọc/kiểm tra cấu hình runtime. `web.xml` hiện không khai báo security-constraint hoặc session-config.

## 11. Test inventory và giới hạn xác nhận

**Chỉ đọc test source. Không chạy, không lấy expected assertion làm kết quả đã pass.**

### `src/test/java/com/sportify/controller/ReviewServletTest.java`

- `acceptsOnlySupportedStarFilters` L16–27: null/blank,1–5 và input không hợp lệ.
- `rejectsInvalidReviewIdsBeforeDatabaseAccess` L29–38: null/blank/zero/negative/non-numeric/injection/overflow; assert redirect/error/UTF-8.
- `rejectsEmptyRepliesAndPreservesValidFilter` L40–47.
- `rejectsOversizedRepliesAndDropsUntrustedFilter` L49–56.
- `Exchange.submit` L70–96: dynamic proxies request/response, gọi trực tiếp ReplyReviewServlet.doPost; không thật Tomcat/filter/session/DB. Các nhánh test dừng trước DAO.

### `src/test/java/com/sportify/data/ReviewDBIntegrationTest.java`

- `connectToDisposableDatabase` L28–49: opt-in system property `sportify.reviewTestUrl`; Assume skip nếu không có; role/URL test riêng; **INSERT review owner2** L33–41 rồi khởi tạo PU. Đây **không phải read-only test**.
- `closeFactory` L51–54 đóng factory, không cleanup row đã insert.
- `listsOnlyOwnedReviewsNewestFirstWithFieldLoaded` L56–68.
- `filtersEveryStarRatingWithinOwnerScope` L70–78.
- `summaryExcludesOtherOwnersAndHandlesEmptyOwner` L80–89: expected fixture owner1 có5 review, avg3.0; đây là expected test, không row count live.
- `cannotReplyToForeignOrMissingReview` L91–101: vẫn gọi mutation transaction, kiểm tra foreign không đổi.
- `createsAndUpdatesReplyPersistedAcrossNewEntityManagers` L103–124: write reply rồi read bằng EM khác; chứa payload HTML để kiểm tra lưu literal, **không** kiểm tra browser/JSP XSS execution.
- Các integration method dùng overload DAO package-private nhận EM, không tự kiểm tra toàn public validation/DBUtil path.

Không tìm thấy tests fields/access/chat trong `src/test` đã đọc. Chưa chứng minh test discovery, passing, skipped hay deployment tương thích. Không chạy integration test vì có write DB; không chạy Maven test/package vì có thể tạo `target`, cache hay write ngoài docs/viva.

## 12. Câu trả lời vấn đáp ngắn và phần chưa làm

- **“Em làm backend gì?”** Owner dashboard đọc sports_fields, tạo/sửa/tạm ngưng sân; demo gate bằng session; owner xem/lọc/thống kê reviews và phản hồi; chat lưu/đọc messages bằng JPA. Booking không có Java servlet/model/DAO trong snapshot đã quét; các dòng booking dashboard là UI mẫu, không nhận là booking backend của mình.
- **“CRUD có Delete chưa?”** Chưa. Có toggle ACTIVE/INACTIVE, không xóa row.
- **“Phân quyền thế nào?”** Filter bảo vệ owner URL bằng flag demo; DAO scoping owner1 chống truy cập object khác owner parameter. Chưa userId/role thực; chat chưa bảo vệ participant.
- **“Dùng Java8?”** Không theo pom hiện tại: compiler source/target17. Chưa xác minh runtime JDK.
- **“Chạy DB rồi chứ?”** Lần quét này chưa kết nối DB/chưa chạy; có code và migration nguồn, không có bằng chứng runtime mới.
- **“SQL ở đâu?”** `database/reviews.sql` là DDL/seed thủ công; DAO Java dùng JPQL/persist/dirty checking; Hibernate sinh SQL lúc chạy. Chưa có capture SQL runtime.
- **“Review theo booking?”** Chưa có code rule đó. customerName vẫn string, không quan hệ user/booking.
- **“Chat realtime?”** Chưa; POST→redirect→GET, sidebar/header mock và identities bằng tên.

Ưu tiên khi được phép phát triển riêng: authentication/role+owner từ session; bảo vệ chat bằng participant IDs; CSRF/session rotation; không hardcode secrets; validation kích thước/giờ và handle false DAO results; migration đầy đủ fields/chat; optimistic locking/pagination/lifecycle EMF; tests access/fields/chat và runtime smoke test trên DB disposable. Đây là đề xuất, **không có sửa sản phẩm trong nhiệm vụ này**.
