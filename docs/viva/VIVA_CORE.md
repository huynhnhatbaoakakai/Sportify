# SPORTIFY — BẢN ĐỒ VẤN ĐÁP CUỐI MÔN

> Bản đồ dựa trên source thực ở `D:\Projects\Sportify`, 9 slide decks được cung cấp, truy vấn PostgreSQL chỉ đọc và HTTP GET. Đây không phải báo cáo mọi chức năng đã chạy thành công. Không sửa source sản phẩm, không chạy migration/seed, không commit/push. Những thao tác demo được ghi dưới đây **chưa được thực hiện**, chỉ là kịch bản cho buổi bảo vệ.

## 0. Đọc bản đồ thế nào và trạng thái thật

- **DONE:** có bằng chứng hoạt động thật ở phạm vi ghi kèm; không suy rộng từ một SELECT sang toàn bộ chức năng web.
- **PARTIAL:** đã có implementation nhưng còn quyền/dữ liệu demo, thiếu tích hợp hoặc chưa xác nhận end-to-end.
- **PLANNED:** ý tưởng/placeholder, chưa thấy implementation trong source được quét.
- Mỗi nhận định cần phân biệt **SOURCE** (đọc code), **DB READ VERIFIED** (SELECT chạy được), **HTTP VERIFIED** (response quan sát), và **NOT TESTED** (không build/POST/end-to-end). Các báo cáo thành phần trước dùng DONE ở mức implementation; bản đồ tổng này dùng quy ước chặt hơn.

### Kết quả thực tế mới nhất

| Nội dung | Bằng chứng | Kết luận |
|---|---|---|
| Stack | `pom.xml` lines 10,18–19,34–51 | Maven WAR, **Java source/target 17**, Jakarta Servlet API 6.1.0 provided, Hibernate 7.4.6.Final, PostgreSQL JDBC 42.7.13; không phải cấu hình Java 8 ban đầu bạn mô tả |
| JVM của lệnh `java` trên máy | `java -version` | Java 21.0.11; **không chứng minh** process Tomcat dùng cùng JVM |
| Tomcat | GET `http://127.0.0.1:8080/sportify/owner/access`, `/owner/fields`, `/owner/reviews`, `/chat` | Cả bốn trả **404**, trang lỗi ghi Apache Tomcat/11.0.25. Chưa xác minh context deploy thật; không kết luận annotation sai hay Hibernate đã lỗi từ 404 này |
| PostgreSQL | [DATABASE_SCAN.md](DATABASE_SCAN.md), SELECT metadata/count | PostgreSQL 18.6, database **`sporttrent`**, 3 bảng public: `sports_fields`, `chat_messages`, `reviews` |
| Dữ liệu sân | SELECT count và owner distribution | **6 sân, đều owner_id=1**; không chứng minh ứng dụng mới thêm/sửa thành công |
| Chat/review | SELECT count/summary | **7 tin nhắn**, **5 đánh giá**; owner1 có điểm trung bình **3.0**, 3 đánh giá có owner_reply khác NULL |
| Thay đổi trong lúc scan | Lượt DB đầu không có reviews; lượt đọc lại đã có. Source thêm customers | Kết luận mới thay kết luận cũ. Tôi không tạo bảng/dữ liệu đó. Đây là snapshot, có thể thay khi bạn phát triển tiếp |
| Runtime write/build | Không chạy POST demo, Maven build/test, integration write test | Không có chứng cứ end-to-end lưu qua UI trong lần scan; không báo giả đã pass |

### Phạm vi chức năng

| Chức năng | Trạng thái | Đã có gì / thiếu gì |
|---|---|---|
| Kết nối PostgreSQL và đọc schema/count | **DONE — DB READ VERIFIED** | SELECT chạy thật, xem chứng cứ; chưa phải app JPA smoke test |
| Owner Dashboard + quản lý sân | **PARTIAL** | Model/DAO/Servlet/JSP/POST routes có; owner1 cố định, metrics trộn DB và mock, web routes đang404 |
| Tạo/sửa/tạm ngưng/khôi phục sân | **PARTIAL** | Có validation/transaction/owner checks; chưa POST xác nhận; update/toggle bỏ qua boolean DAO; không có Delete |
| Xem/lọc/thống kê/phản hồi review | **PARTIAL** | Bảng/entity/DAO/Servlet/view có; owner demo, chưa web demo; không có khách tạo review hay rule phải booking trước |
| Chat dịch vụ | **PARTIAL** | Read/persist bằng JPA; database có rows; tên do client gửi, không participant authorization, sidebar/header mock, không realtime |
| Mở Owner bằng password demo | **PARTIAL** | Filter + session boolean có; không tài khoản/role OWNER thật |
| Quản lý khách hàng owner mới xuất hiện | **PARTIAL** | Tổng hợp theo tên người đánh giá từ reviews; **không bảng users/customers, không lịch sử booking**; không tự nhận đây là phần bạn viết |
| Booking/xác nhận booking trên dashboard | **PARTIAL — UI mock** | JS sửa DOM, không backend booking trong tập source quét; **Booking do thành viên khác phụ trách**, không nhận là phần cá nhân |
| Login/register | **PARTIAL — form/dummy** | Process JSP chỉ redirect, không xác thực/đăng ký DB |
| Role khách/chủ shop/PT/admin, auth đầy đủ | **PLANNED** | Chưa thấy account/role persistence và role-based authorization thật |
| EL render bean, JSTL, custom JSP tags | **PLANNED/CHƯA ÁP DỤNG** | Slide có, source chưa sử dụng để render model. Không sửa code để làm cho giống slide trong nhiệm vụ này |

### Kiểm kê tài liệu

Đã đọc text trực tiếp, Word nhúng, speaker notes của **354 slide**: C01=22, C02=20, C05=58, C06=35, C07=56, C08=39, C09=43, C10=42, C13=39. Thứ tự theo `presentation.xml`, không tên file XML/embedding. Không file PPTX nào không mở được. Các bản xem trước EMF có text trùng Word đã đối chiếu bằng trích xuất EMR text; ảnh PNG được mở theo contact sheets. Visio C01/6 đã xem được bản PNG: Client computer/Web browser — Internet connection — Server computer/Web server/Database server. Chữ nhỏ không đọc rõ trong screenshot không được suy đoán. C03/04/11/12 **chưa được cung cấp**, không tự bổ sung nội dung.

Nguồn học: [SLIDES_EXTRACT.md](SLIDES_EXTRACT.md), [SLIDE_PROJECT_MAP.md](SLIDE_PROJECT_MAP.md), [BACKEND_SCAN.md](BACKEND_SCAN.md), [FRONTEND_SCAN.md](FRONTEND_SCAN.md), [DATABASE_SCAN.md](DATABASE_SCAN.md), [HTTP_SCAN.md](HTTP_SCAN.md), [CUSTOMERS_DELTA_SCAN.md](CUSTOMERS_DELTA_SCAN.md). Bản tổng ưu tiên kết quả DB/HTTP mới hơn các báo cáo tĩnh cũ.

**Inventory cuối:** 20 Java production, 13 JSP, 5 CSS, 4 JS, 2 XML trong src/main; 4 Java test source. Xem SOURCE_MANIFEST.json cho file/hash snapshot. **`database/reviews.sql` và `database/README.md` đã đọc ở snapshot đầu nhưng không còn tồn tại ở snapshot cuối**; không thể mở lại hai file này hiện tại, và không coi nội dung DDL/seed cũ là file SQL nguồn còn trong repo. Thư mục database hiện chỉ có `database/CUSTOMERS.md` (tài liệu query tham khảo), không có file .sql. Schema/constraint/index mô tả trong bản tổng có chứng cứ SELECT metadata live riêng.

## 1. Kiến trúc project

```text
Browser (HTML form / JavaScript / CSS)
  → Tomcat mapping + OwnerAccessFilter (chỉ /owner/*)
  → Servlet controller (parameters, validation, điều phối)
  → Model + DAO/DB (JPA EntityManager, JPQL, transaction)
  → Hibernate → JDBC driver → PostgreSQL
  → DAO trả object/list/boolean
  → Servlet set request attributes → forward JSP → HTML response → Browser

POST ghi: Servlet → DAO commit → redirect → Browser GET mới
          → Servlet đọc lại DB → forward JSP.
```

Chuỗi `Browser → Servlet → Model/DAO → PostgreSQL → Servlet → JSP → Browser` là luồng logic; Model không tự gửi request, và JPA/JDBC là cầu nối thật ở giữa DAO và PostgreSQL. MVC của phần owner gần **Model 2** trong C02/4, không phải toàn bộ dự án MVC thuần vì còn process JSP dummy và inline JS/CSS.

### 1.1 Đường dẫn chuẩn — không phải tên giả

- **Controller (C):** `src/main/java/com/sportify/controller/`.
- **Data/DAO (D):** `src/main/java/com/sportify/data/`.
- **Model (M):** `src/main/java/com/sportify/model/`.
- **Web root (W):** `src/main/webapp/`.
- **Owner JSP:** `src/main/webapp/owner/`.
- **JavaScript:** `src/main/webapp/assets/js/`; **CSS:** `src/main/webapp/assets/css/`.

Tên ngắn `C/CreateFieldServlet.java`, `D/SportFieldDB.java`, `M/SportField.java`, `W/chat.jsp` dưới đây là alias ghép đúng với các prefix này, không đường dẫn mới.

### 1.2 File / class / method / input / output của mỗi tầng

| Tầng | File / class / method cụ thể | Trách nhiệm | Đầu vào | Đầu ra |
|---|---|---|---|---|
| Browser fields | `W/owner/dashboard.jsp`; `assets/js/owner-dashboard.js::openFieldModal`, `closeFieldModal`; field form và toggle form | Render cards, modal, đổi form action create/update, validation UI | request fields do JSP render, DOM data-* và input | POST named params; HTML/DOM. Không JS INSERT DB |
| Browser review | `W/owner/reviews.jsp`; `assets/js/owner-reviews.js` submit listener | GET filter, POST reply; không có tên function cho mọi anonymous listener | review list/summary, textarea | rating/reviewId/ownerReply |
| Browser chat | `W/chat.jsp`; inline `renderChatList`, `updateHeader` | Message body từ JSP; sidebar/header mock | messages attribute + mock array | HTML, form POST; không realtime |
| Filter | `src/main/java/com/sportify/filter/OwnerAccessFilter.java::doFilter` | Gate `/owner/*`, trừ access/logout | servletPath, session(false), `OWNER_DEMO_AUTHORIZED` | chain hoặc redirect access; **không kiểm role OWNER** |
| Read fields controller | `C/ManageFieldsServlet.java::doGet` | Điều phối list và dashboard | GET, owner1 constant | request `fields`,`ownerId`; forward dashboard |
| Field write controllers | `C/CreateFieldServlet.java::doPost/required`; `C/UpdateFieldServlet.java::doPost/required`; `C/ToggleFieldStatusServlet.java::doPost` | Parse/validate/request owner scope | form strings/fieldId, owner1 | DAO call; redirect/400/404/ServletException |
| Reviews controllers | `C/ManageReviewsServlet.java::doGet/parseRating`; `C/ReplyReviewServlet.java::doPost/ratingQuery` | List/filter/summary, validate reply | rating, reviewId, ownerReply | request list/summary/error; redirect kết quả |
| Owner access controllers | `C/OwnerAccessServlet.java::doGet/doPost`; `C/OwnerAccessLogoutServlet.java::doGet` | Demo password grant/remove session flag | password, session | forward access hoặc redirect; không tạo User |
| Chat controller | `C/ChatServlet.java::doGet/doPost/getValueOrDefault` | Conversation read/send, UTF8, redirect encode | GET sender/receiver; POST senderName/receiverName/messageText | request sender/receiver/messages hoặc redirect |
| Customers controller | `C/ManageCustomersServlet.java::doGet` | Tổng hợp khách theo tên review | q, owner1 | customers/search/summary/loadFailed attrs → customers.jsp |
| Model field | `M/SportField.java::SportField`, getters/setters, `beforeInsert`, `beforeUpdate` | JPA entity map sports_fields; callback timestamps | owner/name/type/address/BigDecimal/LocalTime/status | Entity properties; PK IDENTITY; không validate toàn nghiệp vụ |
| Model review | `M/Review.java`, `getField/getOwnerReply` và accessors | Entity reviews; ManyToOne field | customerName/rating/comment/reply/time | review + field relationship LAZY |
| Model chat | `M/ChatMessage.java::ChatMessage`, getters/setters | Entity chat_messages, sentAt mặc định now | sender/receiver/text | ChatMessage, generated ID |
| Model customer | `M/CustomerOverview.java` constructor/getters | DTO projection tổng hợp, **không entity** | name/count/distinct field count/avg/max timestamp | Read-only overview; không account identity |
| Field DAO | `D/SportFieldDB.java::findByOwnerId/findByIdAndOwnerId/insert/update/toggleStatus/rollback` | Owner-scoped JPQL; persist/managed mutation transaction | Long IDs, SportField | List/null/void/boolean; rollback và EM.close |
| Review DAO | `D/ReviewDB.java::findByOwnerId/getSummaryByOwnerId/saveOwnerReply/requireOwnerId`; `Summary` getters | JOIN FETCH, aggregate, owner-restricted bulk update | ownerId/rating/reviewId/reply | List/Summary/boolean affected=1 |
| Chat DAO | `D/ChatMessageDB.java::selectConversation/insert` | Query hai chiều, persist transaction | tên A/B hoặc message | list hoặc void |
| Customer DAO | `D/CustomerDB.java::normalizeSearch/findByOwnerId/getSummaryByOwnerId` | GROUP BY tên review, escaped LIKE query | ownerId/q | List<CustomerOverview>/Summary |
| Connection utility | `D/DBUtil.java::getEntityManagerFactory/closeEntityManagerFactory`, static initializer | EMF shared `Persistence.createEntityManagerFactory("sportifyPU")` | PU name/config | EMF; DAO tạo EM riêng, không shared EM |
| PostgreSQL config | `src/main/resources/META-INF/persistence.xml` | PU RESOURCE_LOCAL/provider/entity list/JDBC settings | config | Hibernate kết nối DB `sporttrent`; validate schema, **không tạo bảng**; credentials không chép vào docs |
| DB layer | `public.sports_fields`, `public.reviews`, `public.chat_messages`; `database/CUSTOMERS.md` (tham khảo read query) | Schema/constraint/persistence | SQL Hibernate hoặc DDL thủ công | rows/constraints; script SQL không tự chạy từ webapp |
| JSP response | `W/owner/dashboard.jsp`, `W/owner/reviews.jsp`, `W/chat.jsp`, `W/owner/customers.jsp`, `W/WEB-INF/views/owner-access.jsp` | Scriptlet/expression render + escape HTML | request attrs, error/query flags | HTML UTF8; browser không nhận source Java |
| Deployment/build | `pom.xml`; `W/WEB-INF/web.xml` | WAR/dependencies/compiler; descriptor display-name | Java/resources/webapp | WAR tên sportify dự kiến; mapping annotation, chưa WAR build mới |

### 1.3 Schema thực và quan hệ

- `sports_fields`: PK `field_id` bigint **IDENTITY BY DEFAULT**, owner_id bigint NOT NULL/default1; name150, type30, address255; description TEXT; price numeric(12,2); open/close TIME; image URL500; status20; created/updated TIMESTAMP. CHECK giá>0, close>open, 4 sport types, ACTIVE/INACTIVE; UNIQUE(owner_id,field_name,address).
- `reviews`: PK review_id bigint IDENTITY BY DEFAULT; FK field_id → sports_fields(field_id), NOT NULL; customer_name100; rating int CHECK1..5; comment TEXT NOT NULL; owner_reply TEXT nullable; created_at NOT NULL default current_timestamp; replied_at nullable. Index `(field_id,created_at DESC,review_id DESC)` đã thấy metadata. **Không ON DELETE CASCADE** trong FK hiện tại.
- `chat_messages`: PK message_id bigint, default sequence `chat_messages_message_id_seq` (serial-style, `is_identity=NO` không có nghĩa không sinh ID); names100/text1000 NOT NULL; sent_at TIMESTAMP NOT NULL default current_timestamp. Không FK user/conversation trong schema hiện tại.
- Review.field `@ManyToOne(fetch=LAZY,optional=false)` map quan hệ nhiều review–một sân. SportField không có collection `@OneToMany` ngược. owner_id là số, **chưa FK tới users**; chat names và customer_name không phải danh tính xác thực.
- Không có bảng owner_dashboard: dashboard là view/tập thống kê từ dữ liệu hiện có, không cần tạo bảng chỉ vì có một trang. Snapshot này không có users/bookings/customers/accounts trong các bảng public được truy vấn.

## 2. Bản đồ từng chức năng

`<ctx>` là context thực từ `request.getContextPath()`. `/sportify` là tên WAR dự kiến, các HTTP GET dưới context đó hiện404; bảng sau là **mapping source**, không tuyên bố endpoint đang chạy.

| Chức năng | URL | Servlet | Method | Model | DAO/DB | Bảng PostgreSQL | JSP | JavaScript |
|---|---|---|---|---|---|---|---|---|
| Hiển thị Owner Dashboard | `<ctx>/owner/fields` | C/ManageFieldsServlet.java | doGet | M/SportField.java | SportFieldDB.findByOwnerId | sports_fields | W/owner/dashboard.jsp | assets/js/owner-dashboard.js |
| Danh sách sân | cùng `/owner/fields`, fragment #fields chỉ browser | ManageFieldsServlet | doGet | SportField | findByOwnerId(1L) | sports_fields | dashboard.jsp | openFieldModal; updateActiveFieldCount |
| Thêm sân | `/owner/fields/create` | CreateFieldServlet | doPost; required | SportField | SportFieldDB.insert | sports_fields | dashboard.jsp sau GET mới | openFieldModal, fieldForm submit listener |
| Sửa sân | `/owner/fields/update` | UpdateFieldServlet | doPost; required | SportField | findByIdAndOwnerId; update | sports_fields | dashboard.jsp sau GET mới | openFieldModal đổi action/pre-fill |
| Tạm ngưng/khôi phục sân | `/owner/fields/toggle` | ToggleFieldStatusServlet | doPost | SportField | toggleStatus | sports_fields | dashboard.jsp sau GET mới | `.field-toggle-form` submit listener |
| Hiển thị/lọc review | `/owner/reviews?rating=...` | ManageReviewsServlet | doGet; parseRating | Review; ReviewDB.Summary | findByOwnerId; getSummaryByOwnerId | reviews JOIN sports_fields | W/owner/reviews.jsp | assets/js/owner-reviews.js; filter là GET form |
| Phản hồi review | `/owner/reviews/reply` | ReplyReviewServlet | doPost; ratingQuery | Review | saveOwnerReply | reviews + owner subquery sports_fields | reviews.jsp sau GET mới | reply submit/input/pageshow listeners |
| Đọc chat | `/chat?sender=...&receiver=...` | ChatServlet | doGet; getValueOrDefault | ChatMessage | selectConversation | chat_messages | W/chat.jsp | inline renderChatList/updateHeader chỉ mock sidebar |
| Gửi/lưu chat | `/chat` | ChatServlet | doPost | ChatMessage | insert | chat_messages | chat.jsp sau GET mới | Không AJAX sending; HTML POST form |
| Mở trang Owner | `/owner/access` | OwnerAccessServlet; OwnerAccessFilter | doGet/doPost; doFilter | Không User model | Không DAO | Không bảng password/user | W/WEB-INF/views/owner-access.jsp | Không JS riêng |
| Thoát quyền demo | `/owner/access/logout` | OwnerAccessLogoutServlet | doGet | Không | removeAttribute session | Không | redirect home.jsp | link GET |
| Xem/tìm khách theo review | `/owner/customers?q=...` | ManageCustomersServlet | doGet | CustomerOverview DTO | CustomerDB.findByOwnerId/getSummaryByOwnerId/normalizeSearch | reviews JOIN sports_fields, không customers table | W/owner/customers.jsp | assets/js/owner-customers.js |
| Login | `/login-process.jsp` từ form root | Không Servlet login riêng | JSP redirect, không đọc param | Không User | Không | Không | login.jsp → home.jsp | Không auth logic |
| Register | `/register-process.jsp` | Không Servlet register riêng | JSP redirect | Không User | Không | Không | register.jsp → login.jsp?registered=true | Không password matching thật |
| Search landing | trang index.jsp, JS preventDefault | Không | client only filterServices | card DOM | Không | Không | W/index.jsp | assets/js/app.js, query chưa khai báo |
| Xác nhận/từ chối booking minh họa | Không backend URL write | Không booking controller trong source quét | DOM click listener | mock rows | Không | Không booking table snapshot | dashboard.jsp | owner-dashboard.js filterBookings/updatePendingCount; không phần cá nhân |
| Chat bạn bè minh họa | chat-friends.jsp | Không | sendMessage/selectConv client | JS array | Không | Không | W/chat-friends.jsp | inline JS; refresh mất, EL/innerHTML rủi ro |

## 3. Luồng dữ liệu chi tiết — 13 bước mỗi chức năng

<!-- FLOWS_INSERT -->

### 3.X SQL/JPQL: cách nói chính xác

DAO dùng **JPQL**, không viết trực tiếp `SELECT * FROM sports_fields` trong Java. JPQL dùng tên entity/property, Hibernate sinh SQL. Các SQL tương đương trong tài liệu là giải thích ngữ nghĩa, **không phải SQL đã capture từ một request web**.

```jpql
SELECT field FROM SportField field
WHERE field.ownerId = :ownerId ORDER BY field.createdAt DESC

SELECT field FROM SportField field
WHERE field.fieldId = :fieldId AND field.ownerId = :ownerId

SELECT review FROM Review review JOIN FETCH review.field field
WHERE field.ownerId = :ownerId
-- thêm AND review.rating = :rating nếu có filter
ORDER BY review.createdAt DESC, review.reviewId DESC

SELECT COUNT(review), AVG(review.rating)
FROM Review review WHERE review.field.ownerId = :ownerId

UPDATE Review review SET review.ownerReply = :ownerReply,
review.repliedAt = :repliedAt
WHERE review.reviewId = :reviewId AND review.field.fieldId IN
(SELECT field.fieldId FROM SportField field WHERE field.ownerId = :ownerId)

SELECT message FROM ChatMessage message
WHERE (message.senderName = :sender AND message.receiverName = :receiver)
OR (message.senderName = :receiver AND message.receiverName = :sender)
ORDER BY message.sentAt ASC
```

- Insert field/message: `transaction.begin → em.persist → commit`; fail rollback, finally close EM.
- Update/toggle field: `em.find` trả managed entity, kiểm owner, setter rồi commit; **dirty checking**, không cần merge managed entity. Entity lấy ở lookup trước đã detached khi EM đóng; DAO dùng EM mới để find lại, không dựa object detached tự lưu.
- Reply: bulk JPQL UPDATE + executeUpdate trả affected rows, success chỉ khi1. Gán repliedAt explicit; bulk query không mặc định chạy entity callbacks/cascade như thao tác entity.
- `@PrePersist SportField.beforeInsert` set timestamps/default owner1/status; `@PreUpdate beforeUpdate` updatedAt. Không dùng default owner này làm authorization.
- DB schema validation chỉ kiểm tương thích mapping; không chứng minh constraints/logic/auth đều đúng. Hiện có reviews không còn cảnh báo thiếu bảng đang diễn ra.

## 4. Liên hệ slide với project — phải chỉ được code

### 4.1 Bảng trọng tâm đúng yêu cầu

| Nội dung trong slide | Ý nghĩa | Sportify áp dụng ở đâu | File/Class/Method |
|---|---|---|---|
| HTTP request/response (C01/10; C05/12–15) | Browser gửi request, server trả response | Controller HTML/redirect, không API JSON | ChatServlet.doGet/doPost; JSP forward |
| GET/POST (C05/12–17) | GET đọc; POST thường đổi state, không tự mã hóa | GET fields/reviews, POST create/update/reply/chat; logout GET là điểm yếu | ManageFieldsServlet.doGet; CreateFieldServlet.doPost; OwnerAccessLogoutServlet.doGet |
| Lifecycle/multithreading (C05/46–50) | init→service dispatch→destroy, nhiều request threads | Override doGet/doPost, local request data; EMF shared/EM local | các controllers; DBUtil; DAO finally.close; chưa shutdown listener |
| URL mapping (C05/7–11) | Container nối URL handler | Annotation thật; web.xml không mapping | @WebServlet các controller, @WebFilter('/owner/*') |
| JSP (C06/14–16) | JSP dịch thành servlet, render server | Scriptlet/expression/declaration escapeHtml | owner/dashboard.jsp, owner/reviews.jsp, chat.jsp |
| JavaBean (C06/4–6) | Noarg/accessors; Serializable không tự persist | Entity POJO có constructors/accessors | SportField/Review/ChatMessage |
| EL (C08/3–39) | `${...}` server property/scope expressions | **Chưa áp dụng render bean**; chat isELIgnored=true, JS template literal không EL | chat.jsp page directive; đề xuất EL requestScope + JSTL escape |
| JSTL (C09/3–25) | Tags loops/conditions/escaping | **Chưa áp dụng**: không dependency/taglib | đề xuất c:forEach/c:out/c:choose trong owner JSP, không SQL tags trong view |
| Request scope (C05/21–24; C08/9–12) | Object sống trong request, qua forward | fields/reviews/messages attrs | ManageFieldsServlet.doGet/setAttribute; JSP getAttribute |
| Session scope (C07/9–13) | State server qua nhiều request | Demo authorization flag, không user identity | OwnerAccessServlet.doPost; OwnerAccessFilter.doFilter; Logout.removeAttribute |
| Forward/redirect (C05/23–26) | Forward cùng request, redirect request mới | Read forward; writes PRG; lỗi password forward | ManageFieldsServlet; ChatServlet; OwnerAccessServlet |
| MVC (C02/3–5) | Model/Controller/View tách trách nhiệm | Owner Model2 + data layer, toàn app còn dummy JSP | ManageFieldsServlet→SportFieldDB/SportField→dashboard.jsp |
| Form processing/validation (C02/8–13; C05/27–31) | name→parameter; server validate | whitelist/price/time/reply bounds | CreateFieldServlet.required/doPost; ReplyReviewServlet.doPost |
| JPA/JDBC (C13/4–9,19–32) | JPA spec; Hibernate implementation trên JDBC | Dùng JPA; driver JDBC dependency; không handwritten JDBC DAO | pom.xml; persistence.xml; DBUtil; SportFieldDB |
| CRUD (C13/29–39) | Create/read/update/delete | C/R/U và status; **chưa Delete** | SportFieldDB.insert/find/update/toggleStatus; không em.remove |
| PreparedStatement / injection | Bind giá trị tách query structure | **Chưa tự dùng PreparedStatement**; cơ chế liên quan là named JPQL parameters ở C13/28 | DAO query.setParameter; không giả Chapter JDBC chưa cung cấp |
| Entity relationship (C13/15–17) | Many reviews→one field; fetch khác cascade | Review.field ManyToOne LAZY + JOIN FETCH | Review annotations; ReviewDB.findByOwnerId |
| Maven/WAR (C01/12–13 directory tương ứng) | Build/package dependency | **Maven là công nghệ source; không khẳng định slide có hướng dẫn Maven riêng** | pom.xml packaging war/finalName/source/target/dependencies |
| Tomcat/container (C01/16–17) | Container phục vụ servlet/JSP | provided Servlet API; HTTP error xác nhận Tomcat11.0.25 | pom.xml; HTTP_SCAN; chưa deployment đúng /sportify |
| Filter | Middleware chain trước servlet | Có source; chưa xác nhận chuyên đề Filter trong 9 decks | OwnerAccessFilter.doFilter; liên hệ session C07 và mapping, không gán slide số giả |
| Authentication/authorization | Xác thực ai; quyền làm gì | Login dummy, owner gate demo; DAO owner scope không thay account auth | OwnerAccessServlet/Filter; owner constants; đề xuất userId/role session thật |
| Error handling (C05/41–45,54–58) | Status/log/view lỗi, không lộ stack trace | Review catch→503/log; field sendError400/404 hoặc500 propagation | ManageReviewsServlet; ReplyReviewServlet; web.xml chưa error-page |
| Encoding UTF8 | Giải mã form trước getParameter; output charset | Servlet POST setCharacterEncoding, JSP UTF8, URL encode chat | CreateFieldServlet.doPost; ChatServlet; JSP page directives; không gán slide cụ thể nếu chưa có riêng |
| Security/XSS (C09/7–10; C07 session/cookies) | Output encoding, quyền và session khác injection | escapeHtml JSP có; chat participant auth/CSRF thiếu | reviews.jsp/chat.jsp; Filter; DAO named binding; friends innerHTML cần kiểm |
| Cookies/URL/hidden (C07/17–37) | Cookie ID khác session attr; hidden có thể sửa | Hidden IDs/names, query rating/chat names; custom Cookie API chưa | chat/review forms; ChatServlet.URLEncoder; chưa remember-me |
| Custom tag/TLD/TEI (C10) | Encapsulate view handlers | **Chưa áp dụng toàn chương** | không .tld/.tag/handler; ưu tiên JSTL trước, custom badge chỉ đề xuất |

### 4.2 Đối chiếu đủ các nhóm nội dung của 9 chương

Bảng chi tiết bên dưới giữ số slide thật và alias file đã định nghĩa. Chủ đề không có trong code ghi Chưa áp dụng; không ép project phải giả có tính năng. **Nếu cô yêu cầu bắt buộc đầy đủ EL/JSTL/custom tags**, hiện source chưa đáp ứng; đây là khoảng trống cần xác nhận yêu cầu chứ không đổi tên scriptlet thành EL. Lần scan này không được sửa sản phẩm để lấp khoảng trống.

<!-- SLIDE_MAP_INSERT -->

## 5. Điểm yếu có thể bị hỏi vặn — trả lời dựa code

| Câu hỏi | Câu trả lời đúng, giới hạn và file nên mở |
|---|---|
| Vì sao hard-code owner_id=1? | Demo một owner khi chưa tích hợp login; constants ở field/review/customer controllers và default SportField.beforeInsert. Không phù hợp multi-owner thật. Phải thay bằng ownerId gắn user đã xác thực từ session/server, không getParameter ownerId |
| Password demo không an toàn thế nào? | Một shared secret trong OwnerAccessServlet; không account/hash/role/rate-limit/rotation; lộ code là lộ gate, không xác định ai thao tác. Không chiếu giá trị secret trong demo |
| Dashboard có cần bảng riêng? | Không: view tổng hợp; field list/active count từ sports_fields, review summary từ reviews. Booking/revenue hiện literal/DOM không phải bảng dashboard |
| Ngăn owner xem/sửa sân người khác ở đâu? | findByOwnerId; findByIdAndOwnerId; update/toggle owner equality; review UPDATE owner subquery. Nhưng owner parameter luôn1 và gate chung, chưa account auth thật |
| Hidden fieldId bảo mật không? | Không, client sửa được. Server owner-check cần thiết; Toggle DAO không đổi foreign row nhưng servlet vẫn redirect success vì bỏ boolean |
| Vì sao POST thêm/sửa/phản hồi? | Đổi DB/state, không dùng GET để link/crawler/reload vô tình đổi. POST **không encryption**, cần HTTPS/CSRF/authorization |
| Vì sao redirect sau POST? | PRG: browser GET mới, refresh không resubmit POST thành công; GET đọc DB mới. Không chống doubleclick/replay/concurrent updates server |
| Vì sao không SQL trong JSP? | View chỉ render, DAO chịu query/transaction/resource; dễ maintain/test và không trộn quyền/SQL/UI. Source dùng DAO/JPA, JSP không tự viết SQL |
| PreparedStatement chống injection thế nào? | Statement structure cố định, bind input thành giá trị, không executable syntax. Project chưa dùng trực tiếp PreparedStatement; JPQL named params/setParameter đạt mục đích tương tự, không gọi query string là SQL native |
| JS đổi giao diện đã lưu DB chưa? | Booking confirm/reject chỉ DOM, refresh reset; field form POST qua servlet/DAO mới có persistence nếu commit thành công. owner-dashboard.js handlers đối chiếu network/form |
| Khi nào dữ liệu mất sau refresh? | JS arrays/DOM (friend chat/booking mock) mất; DB rows đọc qua controller còn. Mở /chat.jsp trực tiếp thiếu messages attrs dù DB còn dữ liệu — không đồng nghĩa database mất |
| HTTP404 khác500 và503? | 404 không tìm resource/object;500 server exception/JSP/JPA failure;503 review load unavailable do handler. Hiện GET /sportify routes404 chưa chứng minh DB lỗi hay mapping bug; cần context/deploy logs |
| PostgreSQL ngừng thì sao? | DBUtil static factory có thể fail init; fields/chat không fallback thân thiện ở mọi nhánh; reviews/customer catch RuntimeException/InitializerError/NoClassDefFoundError→503 + notice; reply→error=save. Không nói tự reconnect factory sau fail đã làm |
| Tomcat11 liên quan jakarta thế nào? | Source import jakarta.servlet và dependency API6.1; không copy javax.servlet legacy slides. Tomcat không tự cung cấp Hibernate/JPA như full JavaEE server. web.xml namespace4.0 cũ cần kiểm chứng, không tự kết luận không chạy |
| Java8 và String.isBlank? | isBlank từ Java11, Set.of từJava9; pom hiện17 nên không lỗi chỉ vì Java8 mô tả cũ. Nếu compiler thật Java8 sẽ thiếu API. JDK của command=21, JVM Tomcat chưa xác nhận |
| Vì sao không xóa sân đã booking? | Giữ lịch sử/FK, chuyển ACTIVE/INACTIVE thay vì delete là hướng hợp lý. Source có toggle, FK reviews; **không có booking enforcement** để tuyên bố ngưng sân tự hủy/chặn bookings |
| Thay DEMO_OWNER_ID thế nào? | Login thật validate password hash, query User/role/owner relation, rotate session, store trusted userId/ownerId/role; Filter require role OWNER; controller lấy identity server; DAO vẫn owner predicates. Đây là **đề xuất**, chưa code |
| Kiểm role OWNER ở đâu? | Hiện không đâu thật: Filter chỉ Boolean OWNER_DEMO_AUTHORIZED. Production ở Filter/authorization layer, không chỉ hide menu hoặc JS |
| Escape output đã đầy đủ chưa? | Reviews/customer/chat message escapeHtml có; raw JSP expression không tự escape. Dashboard data-sport-type còn raw; friend innerHTML + JSP EL cần kiểm. HTML escaping không thay JS/URL encoding |
| Chat có mạo danh/đọc lén không? | Names từ GET/hidden POST, không user session/participant-check. Đổi tên có thể chọn hội thoại/mạo danh; JPQL binding không sửa vấn đề authorization. ChatServlet và ChatMessageDB |
| Vì sao JOIN FETCH reviews? | Review.field LAZY; DAO đóng EM trước JSP đọc fieldName, fetch field trong query tránh lazy loading sau close. Không nói LAZY tự load bất cứ lúc nào |
| Sửa sân cần em.merge không? | DAO em.find trong EM mới lấy managed entity rồi setters/commit dirty-checking. Object từ lookup trước detached; DAO không dựa detached object tự lưu. SportFieldDB.update |
| Review reply có insert review mới? | Không, bulk UPDATE ownerReply/repliedAt; count reviews không tăng; reply có thể ghi đè cũ. ReviewDB.saveOwnerReply |
| Lọc5sao làm average chỉ5sao? | Không, list filter; summary query mọi review owner. Snapshot DB owner1 avg3.0, không kết luận widget đã render live |
| Transaction giải quyết mọi cạnh tranh không? | Atomic write/rollback, nhưng không @Version/lock. Toggle/read-modify-write có race; update last-write-wins. PRG không idempotency; cần optimistic lock hoặc điều kiện mutation theo business rule |
| owner_id có FK user chưa? | Chưa, hiện bigint/default1, không bảng users/FK metadata. Review.field có FK; customer name không user account |
| Unique sân và lỗi trùng? | DB UNIQUE(owner_id,field_name,address); servlet chưa pre-check/handle constraint bằng thông báo riêng. Duplicate có thể vào generic ServletException/500; frontend notice field success/error chưa render |
| Validation browser/backend có đồng nhất? | HTML price min/step1000 nhưng server chỉ>0; max length có HTML/entity nhưng server field chưa check riêng. LocalTime parse malformed có thể throw DateTimeParseException vào generic catch. required không đảm bảo mọi type hợp lệ |
| Reviews từng bị thiếu bảng, giờ sao? | Lượt đầu absent, lượt mới **có**,5rows; không tiếp tục gọi thiếu hiện tại. hbm2ddl.validate không auto-create, nếu env khác chưa migration có thể fail cả EMF shared; không nói đã tái hiện JPA fail ở HTTP hiện404 |
| Đăng xuất đã invalidate? | OwnerAccessLogoutServlet chỉ remove boolean; home link index không revoke owner demo. Logout GET và thiếu rotation/CSRF là giới hạn |
| Phần của em và của nhóm? | Theo khai báo: owner dashboard/fields model&DAO/CRUD trạng thái/PostgreSQL/chat persistence/reviews đang hoàn thiện/owner gate demo. **Booking thành viên khác**. Source không chứng minh tác giả cá nhân và customers mới chưa được bạn xác nhận |
| Khách hàng owner lấy từ booking? | Không, CustomerDB GROUP BY review.customerName; cùng tên có thể gộp hai người, khác cách viết có thể tách một người. Không account/contact/history booking. CustomerOverview là DTO projection, không @Entity |
| Nếu search '%' sao? | CustomerDB dùng LIKE ESCAPE '!' và escape !,% ,_; named params chống injection nhưng không tự loại wildcard. Hai cơ chế khác nhau. Summary vẫn toàn owner, không theo q |

## 6. Chuẩn bị trình bày và demo cuối môn

### 6.1 Giới thiệu Sportify — khoảng 60–90 giây

“Sportify là đồ án Web Programming hướng đến việc tìm và sử dụng các dịch vụ thể thao: thuê sân hoặc phòng tập, thuê dụng cụ và trang phục, thuê huấn luyện viên, đồng thời trao đổi với nhà cung cấp. Dự án dự kiến nhiều vai trò như khách hàng, chủ sân, chủ cửa hàng, huấn luyện viên và admin.

Về kỹ thuật, nhóm sử dụng Java Servlet/JSP, Maven đóng gói WAR và Tomcat; frontend là HTML, CSS, JavaScript thuần. Source hiện cấu hình Java17. Dữ liệu được ánh xạ bằng JPA, Hibernate và lưu trong PostgreSQL. Luồng phần quản lý sân là browser gửi form tới servlet, servlet kiểm tra dữ liệu và gọi DAO, DAO làm việc với database; khi đọc, servlet đặt dữ liệu vào request rồi forward JSP; sau khi ghi dùng redirect để đọc lại.

Phần em tập trung là giao diện Owner Dashboard, quản lý thông tin và trạng thái sân, model/database access, cùng phần chat persistence và owner reviews đang hoàn thiện. Em không nhận phần booking vì thành viên khác phụ trách. Bản hiện tại còn owner ID và password demo, đăng nhập/phân quyền thật chưa hoàn chỉnh; dashboard cũng có số liệu minh họa. Em sẽ phân biệt rõ dữ liệu database với dữ liệu chỉ thay đổi ở giao diện.”

Không nói thời lượng đã đo tự động; đây là bản nói thử, tự căn theo nhịp thực tế của bạn.

### 6.2 Đóng góp cá nhân — khoảng 30–45 giây

“Phần trực tiếp của em chủ yếu là Owner Dashboard và quản lý sân. Em làm giao diện danh sách/modal, model SportField và database access, các luồng thêm, xem, sửa và chuyển ACTIVE/INACTIVE của sân. Em có thể chỉ luồng form tới CreateFieldServlet hoặc UpdateFieldServlet, rồi SportFieldDB và bảng sports_fields. Ngoài ra em tham gia phần lưu chat vào PostgreSQL và đang hoàn thiện owner reviews. Quyền owner hiện chỉ là demo, owner_id=1 và một cổng mật khẩu tạm; em chưa gọi đó là phân quyền thật. Booking do thành viên khác phụ trách, các thao tác booking minh họa trên dashboard không phải backend booking em làm.”

Nếu đóng góp chat/review có chia phần nhóm, chỉnh theo chứng cứ bạn xác nhận, không tự nhận tất cả các file đã đọc.

### 6.3 Preflight — bắt buộc trước live demo

1. **Hiện đang404**: xác định context path/deployment trong VS Code/Tomcat, xem startup/deploy log. File WAR finalName=sportify không bảo đảm IDE deploy cùng context. Không đổi mapping/đổ lỗi DB chỉ vì404.
2. Xác minh browser GET trang access thực render; owner gate; GET fields; GET reviews; GET `/chat` (không JSP trực tiếp).
3. DB connection đúng sporttrent; SELECT metadata/count trên DB demo. Đã có reviews ở snapshot mới, đừng chạy seed lại chỉ vì báo cáo trước ghi thiếu.
4. Xác minh WAR/JSP build nguồn hiện tại; scan **chưa chạy build** vì yêu cầu chỉ tạo docs/viva. Build/deploy cần thao tác riêng được phép, không lấy .class trong target làm chứng cứ mới.
5. Chọn dữ liệu demo không nhạy cảm và được phép sửa. Không chiếu secret/password/persistence credential hay nội dung chat cá nhân. Không test SQL/XSS nguy hiểm trên dữ liệu thật.

### 6.4 Trình tự demo đề xuất

| Bước | Mở/thực hiện | Điều cần giải thích/chứng minh |
|---|---|---|
| 1 | DB client, kết nối sporttrent; mở sports_fields metadata và SELECT owner1 | PK/owner/status/price/time; bảng có trước thao tác |
| 2 | VS Code: SportField, ManageFieldsServlet, SportFieldDB, dashboard.jsp | Mapping/model/query/setAttribute/forward không SQL trong JSP |
| 3 | Browser owner access → fields route đúng context | Filter gate demo, chưa role auth; tên owner UI tĩnh |
| 4 | Thêm “Viva Pickleball” ở DB demo: PICKLEBALL, address demo,200000,06:00–22:00,ACTIVE | Network POST create→redirect GET; input validation; new SportField; persist/transaction |
| 5 | Refresh, quay DB SELECT sân demo | Chỉ sau readback thấy row mới được nói “lưu thành công” |
| 6 | Edit tên/giá250000, refresh+SELECT | update + managed dirty checking; updated_at thay đổi; không description/image upload |
| 7 | Tạm ngưng, refresh+SELECT INACTIVE; khôi phục nếu được phép | Toggle không DELETE; active card count từ fields thật; không khẳng định booking tự bị chặn |
| 8 | Reviews: filter5, chọn row demo, gửi reply, reload+SELECT owner_reply/replied_at | Summary vẫn toàn owner; bulk UPDATE owner restricted; chưa tạo review customer |
| 9 | `/chat?sender=VivaCustomer&receiver=VivaOwner`, gửi text demo rồi reload+SELECT | Persist khác realtime; header/sidebar mock và danh tính tạm |
| 10 | Chỉ giải thích booking DOM bằng code hoặc minh họa riêng | Refresh mất vì không HTTP write; ghi rõ thành viên khác làm booking; không nhận doanh thu literal thật |

Các bước ghi dữ liệu này chưa chạy trong scan và cần database demo được phép. Không tự delete dữ liệu sau demo; phục hồi theo quy trình nhóm đã thống nhất.

### 6.5 Tabs và file mở sẵn

- Browser: access, `/owner/fields#fields`, `/owner/reviews`, `/chat` đúng context; DevTools Network/Console. Chưa dùng /sportify URL404 như URL demo thành công.
- DB: sports_fields, reviews, chat_messages, metadata/constraint tab; SELECT lọc row demo trước/sau.
- VS Code: `pom.xml`, `persistence.xml` (ẩn secrets), `ManageFieldsServlet`, `CreateFieldServlet`, `UpdateFieldServlet`, `ToggleFieldStatusServlet`, `SportField`, `SportFieldDB`; `OwnerAccessFilter`, `OwnerAccessServlet`; `ManageReviewsServlet`, `ReplyReviewServlet`, `Review`, `ReviewDB`; `ChatServlet`, `ChatMessageDB`, `chat.jsp`; `owner/dashboard.jsp`, `owner-dashboard.js`, `database/CUSTOMERS.md` và DB metadata. **Không đưa `database/reviews.sql` vào danh sách mở: file đã mất ở snapshot cuối.**
- Tomcat log/build output; tài liệu bản đồ này. Chỉ mở customers nếu demo phần nhóm hoặc đã xác nhận đóng góp.

### 6.6 Dữ liệu mẫu cần chuẩn bị — không phải dữ liệu đã tạo

- Sân demo owner1, đủ4sport options; giá hợp lệ, giờ cùng ngày; một ACTIVE và một INACTIVE.
- Review1..5sao, có/không reply; trường comment/reply xuống dòng và ký tự `<b> &` để chứng minh render text trong DB demo an toàn.
- Fixture owner2 phục vụ kiểm quyền **trong DB test riêng**, không giả live DB hiện có owner2: snapshot hiện toàn owner1.
- Cặp tên chat demo không nhạy cảm và hai chiều; một message tiếng Việt có dấu.
- Case invalid: blank, giá<=0, giờ đóng<=mở, reply whitespace/over2000, invalid rating, ID foreign/missing. Chỉ negative POST trong env test được phép.
- Demo login không dùng tài khoản thật vì process JSP dummy; không nói đã đăng ký một user bằng registered=true.

### 6.7 Kịch bản dự phòng

| Sự cố | Hành động demo an toàn | Điều không được nói |
|---|---|---|
| HTTP404 hiện tại | Kiểm context deploy, log app deploy, annotation handler, WAR đang phục vụ; nếu chưa khắc phục trình bày source trace và SELECT DB có chứng cứ | “Database hỏng” hoặc “mapping chắc sai” chỉ từ404 |
| Tomcat không chạy | Xem process/port/log, dùng bản nguồn + slide sơ đồ + DB SELECT/ảnh demo có ngày và chú thích nếu đã chuẩn bị | Không dùng screenshot cũ như giao diện live |
| PostgreSQL unavailable | Phân biệt connection refused/credential/schema; review/customer source có503 fallback, field/chat có thể exception; mở model/query/schema docs | Không đổi sang dữ liệu bịa và gọi DB thật |
| Thiếu migration/schema ở env khác | So sánh metadata với entity/tài liệu; validate không create; xin phép owner env trước migration, hiện repo không còn file .sql | Không tự dựng/chạy lại seed từ báo cáo cũ trên production để cứu demo |
| Build/API lỗi | Mở pom Java17 và dependency jakarta, compiler/JDK log; Set.of/isBlank không Java8 | Không sửa source nóng chưa đọc và không báo build pass khi chưa chạy |
| CSS/font/icon không load | Network404 asset/context path; CDN offline; owner CSS breakpoints | Không coi mất Material Symbols là lỗi PostgreSQL |
| JS search/friend chat lỗi | Console; app.js query undefined, JSP EL/innerHTML issue; chuyển demo sang luồng owner đã preflight | Không bảo mọi feature frontend hoạt động |

## 7. Bộ câu hỏi luyện — chưa đưa đáp án trước khi hỏi tương tác

### 7.1 30 câu có khả năng xuất hiện

1. Sportify giải quyết nhu cầu gì và những role nào mới là dự kiến?
2. Phần đóng góp trực tiếp của em là gì, booking của ai?
3. Kiến trúc owner flow thuộc Model1 hay Model2 trong slide?
4. POM cấu hình Java phiên bản nào và WAR tên gì?
5. Tại sao Jakarta Servlet API dùng scope provided?
6. URL nào hiển thị dashboard, class/method nào nhận GET?
7. Đoạn nào lấy danh sách sân owner1 từ PostgreSQL?
8. Vì sao servlet setAttribute rồi forward JSP?
9. Form thêm sân gửi những name nào tới URL nào?
10. Server validate giá/môn/giờ ở method nào?
11. SportField map bảng/PK/cột nào, ID sinh thế nào?
12. @PrePersist và @PreUpdate làm gì ở SportField?
13. Insert DAO begin/persist/commit/rollback/close theo thứ tự nào?
14. Sửa sân kiểm quyền owner ở hai vị trí nào?
15. Vì sao sửa managed entity không cần em.merge?
16. Toggle trạng thái khác Delete như thế nào?
17. PRG giúp gì khi refresh và không giải quyết vấn đề gì?
18. Request parameter khác request attribute thế nào?
19. Session demo được tạo/đọc/xóa ở đâu, có user role chưa?
20. Filter bảo vệ path nào và whitelist path nào?
21. Review và field có quan hệ JPA/PostgreSQL gì?
22. Vì sao ReviewDB dùng JOIN FETCH?
23. Lọc rating có ảnh hưởng average summary không?
24. Reply parameters/validation/bulk UPDATE/affected rows nằm đâu?
25. Named JPQL parameters chống injection thế nào, project có trực tiếp PreparedStatement không?
26. Chat message persist ở class/method nào; conversation query hai chiều thế nào?
27. Chat DB khác friend-chat array và booking DOM ở điểm nào khi refresh?
28. Project đã dùng EL/JSTL/custom tags từ slide chưa? Chỉ đúng evidence hoặc khoảng trống.
29. Chẩn đoán404/500/503, context deploy và schema validate theo thứ tự nào?
30. Nếu triển khai thật, auth/role/CSRF/XSS/chat authorization cần cải thiện gì?

### 7.2 10 câu vặn sâu phần owner/code

1. Toggle một fieldId không tồn tại có sửa row không, vì sao servlet vẫn redirect success?
2. Object lấy bằng findByIdAndOwnerId đã đóng EM còn managed không, DAO update thực sự update object nào?
3. Hai request toggle đồng thời có chắc đổi hai lần về trạng thái ban đầu không; transaction có đủ không?
4. Khách sửa hidden reviewId thành ID owner khác: điều kiện nào trong UPDATE ngăn ghi?
5. Bảng reviews thiếu ở env khác vì sao có thể làm cả fields/chat fail dù không mở review page?
6. Có cột owner_id/default1 có nghĩa đã có FK và xác thực owner chưa?
7. Tên/địa chỉ trùng owner vi phạm constraint nào, UI/backend hiện phản hồi thế nào?
8. Tại sao required/time parse/status normalization chưa bảo đảm mọi input error vào cùng nhánh?
9. Một reply chứa `</textarea>` cần được escape ở context nào; PreparedStatement có ngăn XSS không?
10. Làm sao chuyển owner demo sang session identity thật mà vẫn giữ owner checks DAO và không nhận booking là phần mình?

## 8. Chế độ vấn đáp và theo dõi tiến độ

- `/scan`: đọc lại snapshot source/slide/DB read nếu quyền cho phép, cập nhật bản đồ; không sửa sản phẩm.
- `/viva`: từ tổng quan tới tìm code, flow, Servlet/JSP, DB, frontend/backend, debug, security.
- `/random`: chọn câu ngẫu nhiên bám slide/source bằng công cụ; `/code`: chỉ file/class/method/URL/table.
- `/flow`: request→DB→response; `/slide`: nội dung slide với số slide và áp dụng/chưa áp dụng.
- `/debug`: tình huống phù hợp source/runtime evidence; `/demo`: tập thuyết trình và preflight.
- `/rapid`: 15–20giây tự căn/thời gian thực nếu có công cụ; không giả đã đo thời gian user.
- `/weak`: luyện chủ đề có bằng chứng trả lời yếu; `/report`: tiến độ thật, không coi đã có tài liệu là đã nắm kiến thức.

Mỗi lượt **một câu**, không đáp án trước, chờ trả lời. Chấm10: kỹ thuật4 + đúng file/class/method3 + flow2 + trình bày1. Ghi rõ đúng/sai/thiếu/thuật ngữ/file cần mở, mẫu20–45giây rồi **một câu vặn sâu**. Chưa có câu trả lời của bạn nên chưa đánh giá mạnh/yếu hoặc cho điểm. Không hỏi Chapter chưa cung cấp như nội dung đã học; bảo mật cơ bản gắn trực tiếp source được phép.

Lưu tiến độ trong `docs/viva/VIVA_PROGRESS.md`, không ngoài phạm vi docs. Khi bản đồ đã tạo và kiểm tra xong, bắt đầu bằng **một câu tổng quan**, chưa đưa đáp án trong chat và chờ trả lời; các lệnh khác chuyển chế độ theo yêu cầu. Không hỏi khi bản đồ còn chưa hoàn tất.

## 9. Giới hạn và cách kiểm chứng lại

- Không có kết quả build/test/JSP compilation/end-to-end POST trong scan. Integration tests có write nên chưa chạy, expected assertions không phải output đã pass.
- HTTP404 ở context thử không chứng minh tính năng PLANNED; source có thể hoàn chỉnh một nhánh nhưng WAR chưa deploy/có context khác. Cũng không chứng minh ứng dụng chạy source hiện tại.
- Source đang được phát triển trong lúc scan; xem manifest và delta. DB READ output là snapshot, không audit tác giả hoặc chứng minh write của em.
- Các đường dẫn/method dùng file tồn tại, không gán service layer/Spring/UserDAO/BookingServlet không có. Câu SQL tương đương không giả làm SQL Hibernate log thực.
- Các screenshot slide đã xem phục vụ lý thuyết, không phải ảnh giao diện Sportify live. Không có ảnh Sportify demo mới trong nhiệm vụ này.
- Những điều bắt buộc cô muốn mà source chưa có được đánh dấu **Chưa áp dụng**; không đổi thuật ngữ để làm như đã đủ slide. Muốn triển khai bổ sung phải là nhiệm vụ riêng có quyền sửa source.
