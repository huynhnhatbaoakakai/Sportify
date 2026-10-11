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

### 3.1 Hiển thị Owner Dashboard và danh sách sân

1. Người dùng chọn quản lý sân hoặc mở owner dashboard link. Đúng entrypoint là servlet `/owner/fields`, không chỉ mở view JSP.
2. Browser request `<ctx>/owner/fields`; `#fields` nếu có là fragment phía browser, không parameter gửi server.
3. HTTP **GET**.
4. `ManageFieldsServlet.doGet`; trước đó `OwnerAccessFilter.doFilter` kiểm session flag demo trên `/owner/*`.
5. Nhánh này không dùng `request.getParameter` để nhận owner: controller dùng `DEMO_OWNER_ID=1L`.
6. Gate yêu cầu `OWNER_DEMO_AUTHORIZED==Boolean.TRUE`; đó chưa phải User/role validation. Read scope owner được DAO ràng buộc.
7. Không tạo sân mới; kết quả là `List<SportField>` từ JPA; SportField map sports_fields.
8. `SportFieldDB.findByOwnerId(DEMO_OWNER_ID)` → DBUtil EMF → EntityManager local.
9. JPQL `SELECT field FROM SportField field WHERE field.ownerId=:ownerId ORDER BY field.createdAt DESC`; bind owner1, getResultList, finally close EM. Hibernate sinh SQL SELECT sports_fields tương ứng, chưa capture runtime SQL.
10. `request.setAttribute("fields", fields)` và `request.setAttribute("ownerId",1L)`; không lưu list vào session. Session chỉ dùng flag gate.
11. `request.getRequestDispatcher("/owner/dashboard.jsp").forward(request,response)` cùng request; catch Exception bọc ServletException, không graceful empty-success.
12. `src/main/webapp/owner/dashboard.jsp` render cards/active count từ fields; booking và revenue vẫn mock. JSP thiếu fields tự redirect tới servlet.
13. Refresh GET gọi đọc lại DB, không submit POST; DOM-only booking thay đổi mất, field DB còn nếu DB read thành công. HTTP test hiện chưa thấy route hoạt động ở /sportify (404).

### 3.2 Thêm sân

1. Bấm nút thêm sân ở dashboard; `owner-dashboard.js::openFieldModal` reset form, dùng create action; submit `#fieldForm`.
2. Form action `<ctx>/owner/fields/create` lấy contextPath và dataset.createAction.
3. HTTP **POST**, form HTML bình thường, không AJAX.
4. `CreateFieldServlet.doPost` (annotation exact path) sau owner gate; setCharacterEncoding UTF-8 trước getParameter.
5. Lấy `fieldName,sportType,address,pricePerHour,openTime,closeTime,status`; không nhận ownerId, description, imageUrl từ form hiện tại.
6. `required(value,label)` nonblank/trim; parse BigDecimal/LocalTime; 4type whitelist; giá>0; close.isAfter(open); status khác INACTIVE quy ACTIVE. HTML min/step1000 không đồng nhất backend>0; server chưa maxlength riêng.
7. `new SportField()` rồi set owner1/name/type/address/price/open/close/status. @PrePersist beforeInsert gán timestamps/default.
8. `SportFieldDB.insert(field)` tạo EM và transaction.
9. Begin→`em.persist(field)`→commit; Hibernate sinh INSERT sports_fields/PK IDENTITY. Không SQL INSERT string trong servlet/JSP. Fail runtime rollback; finally EM.close.
10. Không set field kết quả vào request/session; truyền thông báo bằng URL query success/error sau write. Owner gate session không chứa sân mới.
11. Redirect `<ctx>/owner/fields?success=created#fields`; IllegalArgumentException redirect error=invalid; generic Exception ServletException. Malformed time parse có thể vào generic catch.
12. Browser GET lại ManageFieldsServlet→request fields→forward dashboard.jsp. View hiện không render notice field success/error query; danh sách là readback nguồn.
13. Refresh sau redirect là GET, không tự insert lại. Double submit trước redirect vẫn có thể; DB UNIQUE bảo vệ owner/name/address, không phải PRG tự chống duplicate. Chưa POST test trong scan.

### 3.3 Sửa sân

1. Bấm sửa card; openFieldModal(card) prefill từ data-*/DOM và đổi form action update; hidden fieldId.
2. POST đến `<ctx>/owner/fields/update`.
3. HTTP **POST**.
4. `UpdateFieldServlet.doPost`, owner filter; request UTF8 trước đọc params.
5. Lấy fieldId trước; rồi fieldName,sportType,address,pricePerHour,openTime,closeTime,status. Không tin hidden ID là quyền.
6. `SportFieldDB.findByIdAndOwnerId(fieldId,1L)` trước; null→sendError404/return. Validate required/whitelist/price>0/close>open; normalize status. Description/image input chưa có.
7. Không new field; dùng SportField lookup để set dữ liệu nhập. EM lookup đã đóng nên entity ở servlet detached; chưa tự ghi DB bằng setters.
8. `SportFieldDB.update(field,1L)` mở EM mới, transaction; `em.find(SportField.class,fieldId)` lấy currentField managed; verify owner lần nữa.
9. Copy properties lên managed currentField→commit dirty checking sinh UPDATE sports_fields; @PreUpdate cập nhật updated_at. Missing/foreign rollback false; runtime fail rollback. Không em.merge cần thiết cho currentField managed.
10. Không đặt entity vào request/session; boolean DAO hiện **bị bỏ qua** ở controller.
11. Redirect `<ctx>/owner/fields?success=updated#fields`; invalid redirect error=invalid;404 lookup; generic failure500 propagation. Boolean false vẫn có thể redirect success.
12. GET fields đọc lại list và forward dashboard.jsp; phải xem row/card thực chứ query success không đủ chứng minh đã lưu.
13. Refresh GET không gửi lại POST; thay đổi còn nếu commit/readback thành công. No @Version nên concurrent overwrite chưa được giải quyết. Chưa end-to-end test.

### 3.4 Tạm ngưng hoặc khôi phục sân

1. Bấm nút tạm ngưng/kích hoạt trong form `.field-toggle-form` của card sân.
2. Action `<ctx>/owner/fields/toggle`.
3. HTTP **POST**, JS chỉ xử lý submit UI, không tự persist.
4. `ToggleFieldStatusServlet.doPost` sau owner filter; request UTF8.
5. `request.getParameter("fieldId")`; owner controller cố định1, không owner param.
6. Null/isBlank→IllegalArgumentException; Long.valueOf parse. Không pre-check positive/exists trong servlet; DAO kiểm owner/existence. isBlank không API Java8, pom17 hiện phù hợp.
7. Không new SportField; DAO find existing managed entity để đọc status.
8. `SportFieldDB.toggleStatus(fieldId,1L)` mở EM/transaction.
9. em.find; missing/foreign rollback false. ACTIVE→INACTIVE, còn lại→ACTIVE; commit dirty-checking UPDATE sports_fields + @PreUpdate. Fail rollback, finally close.
10. Không request attr mutation; session không chứa status. DAO boolean **không được servlet dùng**.
11. Redirect success=toggled#fields dù DAO false; bad format400; generic500. Không coi success URL là audit trail.
12. GET fields→request list→forward dashboard.jsp; badge/active count dựa status đọc lại.
13. Refresh GET không toggle lại; row không bị DELETE. No booking enforcement ở source; simultaneous toggle không được bảo đảm bởi PRG. Chưa web POST verify.

### 3.5 Hiển thị và lọc đánh giá

1. Mở mục reviews hoặc submit form lọc số sao trên reviews.jsp.
2. GET `<ctx>/owner/reviews?rating=5` hoặc rating rỗng.
3. HTTP **GET**.
4. `ManageReviewsServlet.doGet` sau owner demo filter; request/response UTF8.
5. `request.getParameter("rating")`→`parseRating`; owner1 constant, không user/session identity thật.
6. Chỉ null/blank hoặc một ký tự1–5 sau trim. Invalid nonblank set400/error nhưng vẫn đọc list không filter. DAO requireOwnerId và rating bounds.
7. Không tạo Review mới; DAO trả List<Review> và ReviewDB.Summary.
8. `ReviewDB.findByOwnerId(1L,rating)` và `getSummaryByOwnerId(1L)`; hai EM/read query riêng.
9. List JPQL JOIN FETCH field owner predicate, optional rating, sort createdAt DESC/reviewId DESC; summary COUNT/AVG chỉ owner không rating. Hibernate SELECT reviews JOIN sports_fields; SQL web chưa capture. Finally close EM.
10. Request attrs `reviews,selectedRating,totalReviews,averageRating`; load error thêm empty list/0/loadFailed/errorMessage, HTTP503 và server log. Không session reviews.
11. Forward `/owner/reviews.jsp`; lỗi load vẫn forward với503, không giả list rỗng là DB thành công.
12. JSP escape customer/field/comment/reply; render filter/summary/reply form. loadFailed hiển thị notice/dấu— phù hợp. JOIN FETCH giúp fieldName đọc sau EM.close.
13. Refresh GET chỉ query lại. Summary không giảm theo filter. DB snapshot có5review avg3.0 owner1, nhưng HTTP widget chưa verify.

### 3.6 Phản hồi đánh giá

1. Mở reply details của review và submit textarea ownerReply; JS trim validity, disable nút; có pageshow restore.
2. Form action `<ctx>/owner/reviews/reply`.
3. HTTP **POST**.
4. `ReplyReviewServlet.doPost` sau owner gate, set UTF8.
5. `request.getParameter("reviewId")`, `ownerReply`, `rating`; rating chỉ để giữ filter khi quay lại.
6. ID digits parse Long>0; reply nonblank, raw length<=2000 rồi trim; filter hợp lệ1–5 mới giữ. Public DAO validate owner/id/reply lại. Hidden reviewId chưa chứng minh quyền.
7. Không new Review/reply row; cập nhật property ownerReply/repliedAt của review tồn tại.
8. `ReviewDB.saveOwnerReply(reviewId,1L,ownerReply)`; public overload tạo EM, internal overload transaction/bulk query.
9. Bulk JPQL UPDATE set reply/time WHERE reviewId match và fieldId IN owner subquery; bind tất cả; executeUpdate→commit→true nếu affected=1; catch rollback, finally close. UPDATE SQL Hibernate, không native SQL literal.
10. Không request/session reply result; chọn URL success/error từ boolean/exception. Không tăng tổng review.
11. Redirect `/owner/reviews?success=replied` hoặc error=empty/length/invalid/notfound/save, thêm rating hợp lệ qua ratingQuery. Khác field toggle: false được xử lý.
12. Browser GET reviews→DAO list/summary→attrs→forward reviews.jsp; HTML/textarea output escape ngăn đóng textarea từ dữ liệu. Chưa browser XSS test.
13. Refresh GET không lặp POST; sửa reply ghi đè cùng row. PRG không CSRF/idempotency/locking. Chưa scan POST, DB có3reply không chứng minh ai viết.

### 3.7 Đọc hội thoại chat

1. Người dùng mở URL servlet `/chat`, không entrypoint `/chat.jsp` còn ở một số links.
2. GET `<ctx>/chat?sender=A&receiver=B`; tên phải URL encode khi có ký tự đặc biệt.
3. HTTP **GET**.
4. `ChatServlet.doGet`; owner filter không bảo vệ chat vì mapping chỉ /owner/*.
5. Lấy `sender`,`receiver`; getValueOrDefault trim, null/blank dùng Khách hàng/Sân bóng Sunrise.
6. Không authentication/participant authorization; tên do client chọn. Binding params chỉ chống injection, không quyền đọc.
7. Không tạo message mới; nhận List<ChatMessage> map chat_messages.
8. `ChatMessageDB.selectConversation(sender,receiver)`→EntityManager local.
9. JPQL A→B OR B→A, named binding, ORDER BY sentAt ASC; finally close. Hibernate SQL SELECT chat_messages. Không pagination/id tie-break.
10. Request attrs `sender`,`receiver`,`messages`; không lấy logged-in user từ session.
11. Forward `/chat.jsp` cùng request. Không redirect GET bình thường.
12. JSP render message text escaped từ DB; inline renderChatList/updateHeader vẫn mock/c1, header có thể lệch receiver. Direct chat.jsp không query DAO nên history chưa có.
13. Refresh GET đọc DB, không insert; tab khác không được push vì không websocket/polling. DB có7rows không chứng minh realtime hoặc private chat đúng.

### 3.8 Gửi và lưu chat message

1. Nhập text và submit form gửi tin trong chat.jsp; attach chỉ button chưa backend.
2. Action `<ctx>/chat`.
3. HTTP **POST** HTML form, không AJAX/WebSocket.
4. `ChatServlet.doPost` set UTF8; không login/participant filter cho chat.
5. Lấy **senderName,receiverName,messageText** (khác tên params GET); hai names là hidden client có thể sửa.
6. Names trim/default; message null/blank không insert, vẫn redirect; text nonblank trim. Servlet chưa server max1000/names100 dù HTML/entity có giới hạn.
7. `new ChatMessage(senderName,receiverName,messageText.trim())`; sentAt field initializer LocalDateTime.now.
8. `ChatMessageDB.insert(message)` tạo EM/transaction.
9. Begin→persist→commit INSERT chat_messages; generation IDENTITY dùng DB-generated PK (schema serial-style sequence). Runtime fail rollback/rethrow, finally close.
10. Không giữ message list trong request/session POST; identities chưa gắn account.
11. URLEncoder encode names UTF8, redirect `<ctx>/chat?sender=...&receiver=...`; URL encoding không HTML escaping hay authorization.
12. Browser GET ChatServlet→selectConversation→attrs→forward chat.jsp→HTML body DB. Sidebar không phải DB conversation service.
13. Refresh GET không gửi lại tin; committed text còn qua DB read. Double submit/mạo danh vẫn có thể; scan chưa gửi message để verify write.

### 3.9 Mở Owner Dashboard bằng cổng demo hiện tại

1. Chọn kênh chủ sân/home link hoặc vào protected owner URL; thiếu flag bị filter redirect access; form password trên owner-access.jsp.
2. GET `<ctx>/owner/access` để xem; submit form tới cùng URL.
3. GET render, **POST** password grant; GET logout là side effect riêng.
4. `OwnerAccessServlet.doGet/doPost`; OwnerAccessFilter whitelist đúng access/logout, không bị redirect vòng ở hai path đó.
5. POST `request.getParameter("password")`; GET kiểm session(false). Không email/userId/role parameter thật.
6. So sánh password với constant demo (không ghi giá trị secret); sai không cấp quyền. Không hash/UserDAO/rate-limit/changeSessionId.
7. Không User model/entity tạo; đây là session gate demo, không auth account.
8. Không DAO/DB method; chỉ HttpSession API. Các field/review controllers vẫn tự dùng owner1 sau grant.
9. Không SQL hay bảng password. Khi browser GET fields tiếp mới DAO đọc sports_fields.
10. Đúng: getSession/setAttribute OWNER_DEMO_AUTHORIZED Boolean.TRUE. Sai: request.errorMessage; không authorized flag. Không identity/role session.
11. GET chưa authorized forward `/WEB-INF/views/owner-access.jsp`; đúng POST redirect fields; sai POST forward lại form. Logout removeAttribute, redirect home, không invalidate.
12. Access JSP UTF8/escape error, view trong WEB-INF không public trực tiếp; dashboard render qua GET fields sau grant.
13. Refresh sau đúng redirect là GET không gửi password lại; **refresh sau sai POST forward có thể resubmit password**. Session gate qua nhiều request nhưng không account role auth.

### 3.10 Xem và tìm khách hàng theo tên review (phần mới, chưa nhận là đóng góp cá nhân)

1. Bấm link Khách hàng từ dashboard/reviews hoặc submit form tìm kiếm customers.jsp.
2. URL `<ctx>/owner/customers?q=...`; không customer write endpoint.
3. HTTP GET.
4. ManageCustomersServlet.doGet sau OwnerAccessFilter gate; UTF8 request/response.
5. request.getParameter("q")→CustomerDB.normalizeSearch; owner1 constant.
6. Null→empty, trim, tối đa100code units; invalid set400/error nhưng vẫn đọc không filter. Public DAO requireOwnerId>0. Chưa account/role thật.
7. Không entity Customer mới; constructor projection CustomerOverview DTO gồm name/reviewCount/fieldCount/avg/lastReviewAt.
8. CustomerDB.findByOwnerId(1L,search); getSummaryByOwnerId(1L); EM riêng mỗi read.
9. JPQL SELECT NEW CustomerOverview FROM Review JOIN field WHERE owner; optional LOWER(name) LIKE bound search ESCAPE !, escape !,% ,_; GROUP BY raw name/sort MAXtime DESC/name ASC. Summary COUNT distinct names/reviews/fields toàn owner, không q. Hibernate sinh SELECT reviews JOIN sports_fields, không customers table.
10. Request attrs search/customers/customerNameCount/reviewCount/reviewedFieldCount; DAO error empty0/loadFailed/errorMessage/503/log. Không session data.
11. Forward /owner/customers.jsp; không PRG vì không POST, direct JSP thiếu customers redirect controller.
12. JSP escape name/search/error, render stats/table/empty/load failure. JS owner-customers.js chỉ sidebar/ngày; không AJAX search.
13. Refresh GET query lại, không write. Cùng tên có thể gộp nhiều người; không users/booking identities/history. Summary không theo q; không gọi read DTO là customer CRUD.

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

#### Alias source cho bảng chi tiết


Alias dùng trong bảng trỏ file thật. Dòng chỉ vị trí lúc đọc; tên method trong từng hàng là điểm tìm lại ưu tiên.

| Alias | File | Điểm đọc/dòng |
|---|---|---|
| `POM` | [pom.xml](../../pom.xml) | WAR:10; source/target17:18–19; dependencies34–51 |
| `W` | [src/main/webapp/WEB-INF/web.xml](../../src/main/webapp/WEB-INF/web.xml) | 1–10: minimal descriptor, chỉ display-name |
| `PU` | [src/main/resources/META-INF/persistence.xml](../../src/main/resources/META-INF/persistence.xml) | sportifyPU, RESOURCE_LOCAL, Hibernate provider,3 entity class; hbm2ddl.auto=validate; không nêu kết nối nhạy cảm |
| `CChat` | [src/main/java/com/sportify/controller/ChatServlet.java](../../src/main/java/com/sportify/controller/ChatServlet.java) | doGet:22; doPost:50; getValueOrDefault:89 |
| `CFields` | [src/main/java/com/sportify/controller/ManageFieldsServlet.java](../../src/main/java/com/sportify/controller/ManageFieldsServlet.java) | doGet:21 |
| `CCreate` | [src/main/java/com/sportify/controller/CreateFieldServlet.java](../../src/main/java/com/sportify/controller/CreateFieldServlet.java) | doPost:29; required:129 |
| `CUpdate` | [src/main/java/com/sportify/controller/UpdateFieldServlet.java](../../src/main/java/com/sportify/controller/UpdateFieldServlet.java) | doPost:29; required:123 |
| `CToggle` | [src/main/java/com/sportify/controller/ToggleFieldStatusServlet.java](../../src/main/java/com/sportify/controller/ToggleFieldStatusServlet.java) | doPost:18 |
| `CReviews` | [src/main/java/com/sportify/controller/ManageReviewsServlet.java](../../src/main/java/com/sportify/controller/ManageReviewsServlet.java) | doGet:22; parseRating:56 |
| `CReply` | [src/main/java/com/sportify/controller/ReplyReviewServlet.java](../../src/main/java/com/sportify/controller/ReplyReviewServlet.java) | doPost:18; ratingQuery:60 |
| `CAccess` | [src/main/java/com/sportify/controller/OwnerAccessServlet.java](../../src/main/java/com/sportify/controller/OwnerAccessServlet.java) | doGet:25; doPost:47 |
| `CLogout` | [src/main/java/com/sportify/controller/OwnerAccessLogoutServlet.java](../../src/main/java/com/sportify/controller/OwnerAccessLogoutServlet.java) | doGet:18 |
| `FOwner` | [src/main/java/com/sportify/filter/OwnerAccessFilter.java](../../src/main/java/com/sportify/filter/OwnerAccessFilter.java) | doFilter:28 |
| `DBUtil` | [src/main/java/com/sportify/data/DBUtil.java](../../src/main/java/com/sportify/data/DBUtil.java) | getEntityManagerFactory:14; closeEntityManagerFactory:18 |
| `DField` | [src/main/java/com/sportify/data/SportFieldDB.java](../../src/main/java/com/sportify/data/SportFieldDB.java) | findByOwnerId:15; findByIdAndOwnerId:36; insert:67; update:87; toggleStatus:149; rollback:187 |
| `DChat` | [src/main/java/com/sportify/data/ChatMessageDB.java](../../src/main/java/com/sportify/data/ChatMessageDB.java) | insert:15; selectConversation:38 |
| `DReview` | [src/main/java/com/sportify/data/ReviewDB.java](../../src/main/java/com/sportify/data/ReviewDB.java) | findByOwnerId:17; findByOwnerId:28; getSummaryByOwnerId:52; getSummaryByOwnerId:58; saveOwnerReply:76; saveOwnerReply:92; requireOwnerId:126; getTotalCount:141; getAverageRating:145 |
| `JChat` | [src/main/webapp/chat.jsp](../../src/main/webapp/chat.jsp) | L6; L21; L27; L30; L33; L477 |
| `JFields` | [src/main/webapp/owner/dashboard.jsp](../../src/main/webapp/owner/dashboard.jsp) | L10; L27; L473; L527 |
| `JReviews` | [src/main/webapp/owner/reviews.jsp](../../src/main/webapp/owner/reviews.jsp) | L10; L23; L28; L29; L30; L31; L33; L192; L249 |
| `VAccess` | [src/main/webapp/WEB-INF/views/owner-access.jsp](../../src/main/webapp/WEB-INF/views/owner-access.jsp) | L6; L22; L60 |
| `SportField` | [src/main/java/com/sportify/model/SportField.java](../../src/main/java/com/sportify/model/SportField.java) | beforeInsert:99; beforeUpdate:115; getFieldId:119; setFieldId:123; getOwnerId:127; setOwnerId:131; getFieldName:135; setFieldName:139; getSportType:143; setSportType:147; getAddress:151; setAddress:155; getDescription:159; setDescription:163; getPricePerHour:167; setPricePerHour:171; getOpenTime:175; setOpenTime:179; getCloseTime:183; setCloseTime:187; getImageUrl:191; setImageUrl:195; getStatus:199; setStatus:203; getCreatedAt:207; getUpdatedAt:211 |
| `Review` | [src/main/java/com/sportify/model/Review.java](../../src/main/java/com/sportify/model/Review.java) | getReviewId:53; setReviewId:57; getField:61; setField:65; getCustomerName:69; setCustomerName:73; getRating:77; setRating:81; getComment:85; setComment:89; getOwnerReply:93; setOwnerReply:97; getCreatedAt:101; setCreatedAt:105; getRepliedAt:109; setRepliedAt:113 |
| `ChatMessage` | [src/main/java/com/sportify/model/ChatMessage.java](../../src/main/java/com/sportify/model/ChatMessage.java) | getMessageId:49; setMessageId:53; getSenderName:57; setSenderName:61; getReceiverName:65; setReceiverName:69; getMessageText:73; setMessageText:77; getSentAt:81; setSentAt:85 |

Chứng cứ âm trong source đọc: không thấy `<c:`, `<fmt:`, `<jsp:`, taglib, getCookies/addCookie, encodeURL, getRealPath/getInitParameter, invalidate, synchronized, em.merge/em.remove, @OneToMany/@Temporal, error-page/session-config/jsp-config. Không suy từ đó ra cấu hình container ngoài repo. Có ReviewServletTest/ReviewDBIntegrationTest nhưng bước này không chạy tests.


**Ghi chú cập nhật media:** Bảng dưới được lập từ text trước bước đọc ảnh. Các chữ “ảnh chưa đọc/chỉ tiêu đề” mô tả giới hạn trích xuất lúc lập bảng, không phải file PPTX không mở được. Nay đã xem58 PNG references trên10 contact sheets và Visio C01/6;630 EMF text previews được đối chiếu với Word, phần khác chỉ bullet/numbering. Không suy chữ nhỏ không rõ trong ảnh. Kiến thức giải thích vẫn dựa text/ảnh đã đọc và source, không từ screenshot giả.



Cột nghĩa phục vụ giải thích viva; cột cuối phân biệt áp dụng thật, tương đương ý tưởng và đề xuất.

#### Chapter01

| Slide thực | Nội dung nhóm | Nghĩa / điểm cần nói | Sportify: file/class/method hoặc Chưa áp dụng + đề xuất |
|---|---|---|---|
| 1–3 | Giới thiệu, mục tiêu nền tảng web Java | Nhận diện browser, web/app server, database; HTML mô tả nội dung còn HTTP vận chuyển request/response. | Áp dụng nền tảng: POM (WAR), CChat/JChat và DChat; không coi mục tiêu trên slide là tính năng đã hoàn thành. |
| 4–5 | Hai trang mẫu shopping cart | Ví dụ nhiều trang của cùng ứng dụng; chỉ đọc được tiêu đề, không suy đoán các control trong ảnh. | Chưa áp dụng giỏ hàng: Sportify có danh sách dịch vụ trong index.jsp nhưng không có Cart/LineItem backend; có thể đề xuất giỏ đặt sân. |
| 6 | Components of a web application; Visio nhúng | Bổ sung sau: đã mở PNG preview Visio, thấy Client computer/Web browser — Internet connection — Server computer/Web server/Database server. | Áp dụng browser/server/PostgreSQL; source CFields/DField/JFields xác định flow cụ thể. Không có code cho mọi phần mềm/hình ví dụ trên slide. |
| 7 | Static và dynamic web pages | Tài nguyên static được phục vụ trực tiếp; trang dynamic tạo response theo dữ liệu. Ảnh đã mở theo contact sheet; browser HTTP request→web server→response; trang dynamic có engine/data. | Áp dụng: assets/css/style.css, assets/js/app.js static; CFields.doGet → JFields render fields từ JPA là dynamic. |
| 8–9 | Servlet/JSP, JSF, Spring; Java SE/EE/JPA | Phân biệt API web, thư viện UI và API persistence; JPA không phải web framework. | Áp dụng Servlet/JSP + JPA Jakarta; chưa áp dụng JSF/Spring. POM source/target 17, không phải cấu hình Java 8 của giáo trình cũ. |
| 10–11 | Thành phần và kiến trúc Servlet/JSP | Sơ đồ đã xem: browser request/response, web server & Servlet/JSP engine, JDK, database; architecture chia presentation/business rules/data access. Luồng ứng dụng thực cần tách presentation/business/data. | Áp dụng source: controller → data → model → JSP; CReviews.doGet gọi DReview rồi forward JReviews. |
| 12–13 | Cấu trúc document root, WEB-INF/classes/lib, META-INF | WEB-INF không truy cập trực tiếp bằng URL; Java/JAR trong WAR khác thư mục source Maven. | Áp dụng: src/main/webapp là web root; W; VAccess đặt dưới WEB-INF/views; src/main/java cho class; src/main/resources/META-INF/persistence.xml là cấu hình JPA, KHÔNG phải context.xml trên slide. |
| 14–15 | IDE NetBeans/Eclipse/IntelliJ | IDE hỗ trợ tạo/chạy/debug; screenshot không chứng minh IDE đang dùng. | Chưa xác minh IDE hiện tại; Sportify dùng bố cục Maven, có thể import vào các IDE này. |
| 16–17 | Tomcat, GlassFish, WildFly, Jetty, WebLogic, WebSphere | Phân biệt servlet container và full enterprise application server. | POM khai báo Servlet API provided, comment nói Tomcat cung cấp; không suy ra bản server đang chạy. Chưa xác minh runtime các server khác. |
| 18 | MySQL và các DB server khác | RDBMS lưu dữ liệu quan hệ; slide cũng nêu PostgreSQL/Oracle. | Áp dụng PostgreSQL: POM JDBC driver và PU Hibernate PostgreSQLDialect; không nhận là đang dùng MySQL. |
| 19–22 | Hosting, FileZilla, WinSCP, Synchronize | Nội dung tiêu đề về triển khai/đồng bộ từ xa; không suy diễn hình/chế độ kết nối. | Chưa có chứng cứ quy trình FTP/SFTP/hosting trong source đọc; đề xuất đóng gói WAR và triển khai qua kênh an toàn, không chứa secrets trong tài liệu. |

#### Chapter02

| Slide thực | Nội dung nhóm | Nghĩa / điểm cần nói | Sportify: file/class/method hoặc Chưa áp dụng + đề xuất |
|---|---|---|---|
| 1–2 | Mục tiêu tổ chức MVC | Tách trách nhiệm để sửa UI không phải sửa truy cập dữ liệu. | Áp dụng một phần, không MVC thuần cho toàn bộ dự án; dùng flow chủ sân làm ví dụ tốt. |
| 3–5 | Model 1 và Model 2; data access layer | Model 1 xử lý và trình bày trong JSP; Model 2 dùng servlet điều phối, bean model, JSP view; DAO/data là tầng truy cập riêng. | CFields + DField + SportField + JFields là Model 2. login-process.jsp/register-process.jsp xử lý redirect ngay trong JSP, vẫn là dummy; không có UserDAO thực. |
| 6–9 | Form HTML nhận dữ liệu, JSP hiển thị, POST/hidden action | `name` của control thành tên parameter; action là URL đích, method quyết định HTTP method. 6–7 chỉ có tiêu đề ảnh mẫu. | JFields form tạo sân → CCreate.doPost; JReviews form phản hồi có reviewId/rating → CReply.doPost. Không có emailList demo trong dự án. |
| 10 | CSS tách định dạng khỏi HTML | CSS kiểm soát font, spacing, selector; không xử lý nghiệp vụ server. | Áp dụng assets/css/style.css, owner-dashboard.css, owner-reviews.css; một số JSP vẫn có inline CSS. |
| 11–13 | Servlet controller: doPost, doGet, đọc parameter, gọi data, forward | Request attribute mang object tới view; forward dùng cùng request. doGet gọi doPost chỉ là mẫu, không phải quy tắc bắt buộc. | CChat.doGet đọc conversation → DChat.selectConversation → setAttribute → forward. CChat.doPost insert rồi redirect, KHÔNG ủy quyền GET sang thao tác ghi POST. |
| 14–15 | Deployment descriptor: mapping, timeout, welcome file | web.xml cấu hình deployment; annotation cũng có thể mapping. | W chỉ có display-name, không có mapping/session-timeout/welcome-file-list như ví dụ. Mapping thật ở @WebServlet/@WebFilter; không gán timeout 30 phút cho W. |
| 16–17 | JavaBean constructor, Serializable, getter/setter | Bean cung cấp interface property cho view; Serializable là marker hỗ trợ tuần tự hóa, không tự ghi DB. | ChatMessage và Review có zero-arg + getter/setter + Serializable. SportField cũng Serializable/zero-arg nhưng timestamp lifecycle chỉ getter; không nói tất cả property đều có setter. |
| 18–19 | thanks.jsp dùng EL và form quay lại | `${user.email}` gọi property getter, không phải Java scriptlet. | Chưa áp dụng EL bean rendering trong JSP hiện tại; JChat/JFields/JReviews dùng `<%= ... %>`. Đề xuất đổi hiển thị tên sân thành c:out/EL sau khi thêm JSTL Jakarta. |
| 20 | Các loại file MVC và định nghĩa tổng hợp | HTML, CSS, servlet, DD, bean, JSP có vai trò khác nhau; EL khác JSP Java expression. | Áp dụng bộ file tương ứng ở source; JPA entity vẫn là model POJO. Tách JavaScript `${...}` khỏi EL server, nhất là JChat isELIgnored=true. |

#### Chapter05

| Slide thực | Nội dung nhóm | Nghĩa / điểm cần nói | Sportify: file/class/method hoặc Chưa áp dụng + đề xuất |
|---|---|---|---|
| 1–3 | Mục tiêu phát triển servlet | Bao gồm mapping, validation, init params, error handling, logging và lifecycle. | Mapping/validation/logging có; các mục init param/custom error chưa có, xem từng hàng dưới. |
| 4–6 | HttpServlet, doGet/doPost, request/response, trả HTML | Container gọi handler theo HTTP method; servlet có thể dùng writer nhưng thường forward tới JSP để tách UI. | Áp dụng CChat/CFields/CReviews extends HttpServlet; trả HTML qua JSP, không có TestServlet dùng PrintWriter như demo. |
| 7–9 | XML servlet mapping và URL pattern | Servlet-name nối khai báo class với URL; exact path khác path wildcard. | Chưa dùng mapping XML trong W. Mapping annotation exact `/owner/fields`; wildcard `/owner/*` thuộc FOwner là filter, không phải mapping servlet XML. |
| 10–11 | @WebServlet và nhiều URL/name | Annotation cho container tìm handler, không cần mapping XML trùng lặp. | Áp dụng CChat @WebServlet('/chat'), CFields '/owner/fields', CCreate '/owner/fields/create', CReviews '/owner/reviews', CReply '/owner/reviews/reply'; chưa dùng nhiều URL/name tùy chỉnh. |
| 12–15 | GET, query string, POST, cách chọn method | GET nên đọc/idempotent, POST thường đổi dữ liệu; POST không làm dữ liệu tự mã hóa, vẫn cần HTTPS. 12/14 là ảnh chưa đọc. | CReviews.doGet lấy rating; JReviews filter method=get. CCreate/CUpdate/CReply dùng POST; CLogout.doGet vẫn thay đổi trạng thái quyền demo, nên đề xuất POST + CSRF cho logout. |
| 16–17 | getParameter/getParameterValues, checkbox, list nhiều giá trị | getParameter có thể null; multivalue cần mảng; checkbox không tick thường không có parameter. | Áp dụng getParameter ở CCreate/CReply/CChat; chưa dùng getParameterValues. login.jsp có remember checkbox nhưng login-process.jsp không xử lý, không thể nhận là remember-me đã có. |
| 18–20 | ServletContext, getRealPath, tài nguyên/global config/log | Context đại diện ứng dụng; real path chỉ phù hợp khi tài nguyên có file vật lý. | Áp dụng getServletContext().log ở CReviews/CReply; chưa áp dụng getRealPath hay file EmailList.txt. Dữ liệu thực đi qua JPA; tài nguyên đóng gói nên đọc stream khi cần. |
| 21–22 | Request attribute và primitive boxing | Attribute là object nội bộ server, không giống string parameter client; sống trong request và qua forward. | CFields đặt fields/ownerId; CReviews đặt reviews/totalReviews/averageRating/errorMessage/loadFailed; JReviews đọc và cast Number/Boolean. |
| 23–24 | RequestDispatcher.forward tới HTML/JSP/servlet | Chuyển nội bộ, browser không phát request mới, request attribute còn. | CFields forward '/owner/dashboard.jsp'; CReviews forward '/owner/reviews.jsp'; CAccess forward VAccess; không có forward sang servlet khác trong flow này. |
| 25–26 | sendRedirect và relative/absolute URL | Response yêu cầu browser request URL mới; attribute request cũ mất. Context path tránh hardcode tên WAR. | CChat.doPost dùng redirect + URLEncoder + contextPath; CCreate/CUpdate/CReply redirect sau POST (PRG). Chưa dùng redirect ra external server. |
| 27–31 | Server validation, giữ dữ liệu và thông báo trên form | Client required có thể bypass; validate null/empty trước ghi. Slide minh họa giữ User/message qua forward. | CCreate.required, kiểm tra type/giá/giờ; CReply validate reviewId/text/length; CAccess đặt errorMessage rồi forward. CCreate redirect error=invalid nên KHÔNG giữ các giá trị form như demo. |
| 32–34 | web.xml đầy đủ, deployment/redeploy | XML đúng schema/nesting; cấu hình server chỉ có hiệu lực khi container nạp lại. | W minimal 4.0 namespace Java EE, trong khi Java imports Jakarta và POM servlet 6.1.0: ghi nhận khác đời API cần kiểm thử tương thích runtime, không tự sửa trong tài liệu. |
| 35–40 | Context init param, servlet init param, ServletConfig | Context param dùng chung; servlet init riêng; getInitParameter khác request.getParameter. | Chưa áp dụng `<context-param>`, `<init-param>`, annotation initParams hay getInitParameter. Đề xuất tham số không nhạy cảm về hỗ trợ/cấu hình; secrets đưa ra môi trường, không chép vào web.xml. |
| 41–45 | Custom error-page theo status/exception | Mapping 404 và Throwable sang view lỗi; không nên lộ exception internals cho người dùng. 43/45 là ảnh chưa đọc. | Chưa có `<error-page>` hoặc error_404.jsp/error_java.jsp. Có sendError 400/404 ở CToggle/CUpdate và fallback 503 ở CReviews, nhưng đó KHÔNG phải custom error-page cấu hình. |
| 46–47 | init → service → doGet/doPost → destroy | Init khởi tạo một instance; service dispatch mỗi request; destroy giải phóng. Thường override handler, không service. | Controllers override doGet/doPost; không có controller override init/service/destroy. DBUtil.closeEntityManagerFactory có method nhưng chưa thấy listener gọi shutdown trong src/main. |
| 48–50 | Biến instance và servlet multithreading | Một servlet instance phục vụ nhiều thread; dữ liệu từng request nên local, shared mutable state cần cơ chế an toàn. | CCreate/CUpdate có hằng static/Set.of bất biến; dữ liệu nhập local. DBUtil giữ EMF dùng chung nhưng DAO tạo EM local; không được suy luận mọi static đều sai hoặc project đã chứng minh thread-safe toàn diện. |
| 51 | Lỗi compile/run/redeploy/HTML | Tách compile classpath, container state, mapping, stale deployment và HTML response. | Dùng POM/annotation/JSP để đối chiếu; runtime do bước kiểm thử riêng xác nhận. Không lấy source làm chứng cứ server đang chạy. |
| 52–53 | System.out/System.err debug console | Console phục vụ chẩn đoán nhưng không nên in dữ liệu người dùng/secret tùy tiện. | Chưa thấy servlet dùng println debug như demo; đề xuất logger có mức độ và redaction. |
| 54–58 | log(message, Throwable), stack trace và log server | Log server giữ chẩn đoán; vị trí phụ thuộc container, không mặc định đường dẫn Tomcat8 trong slide. | Áp dụng CReviews.doGet và CReply.doPost gọi getServletContext().log(..., exception). Người dùng nhận thông báo chung, không render stack trace ra JReviews. |

#### Chapter06

| Slide thực | Nội dung nhóm | Nghĩa / điểm cần nói | Sportify: file/class/method hoặc Chưa áp dụng + đề xuất |
|---|---|---|---|
| 1–3 | Mục tiêu JSP/JavaBean/EL/JSTL/include/legacy tags | JSP là template phía server, được chuyển thành servlet; tránh trộn nghiệp vụ vào view. | Áp dụng JSP nhưng phần lớn render vẫn dùng Java scriptlet; chưa dùng JSTL/include. |
| 4–6 | Quy tắc bean: zero-arg, accessors, Serializable | POJO/JavaBean thuận tiện cho view; Serializable không đồng nghĩa entity tự persist. | ChatMessage/Review phù hợp bean cơ bản, SportField có setter cho dữ liệu nghiệp vụ, timestamps được lifecycle quản lý; JPA dựa annotation, không chỉ Serializable. |
| 7–10 | EL attribute/property, 4 scope và dot operator | `${field.fieldName}` tra page → request → session → application rồi property getter; application attribute cần chú ý shared state. | Chưa áp dụng render bằng EL. CFields.setAttribute('fields') hiện được JFields cast List và gọi getFieldName trong scriptlet; đây là điểm chuyển đổi có thể đề xuất. |
| 11–13 | JSTL core, taglib, c:if | JSTL cung cấp xử lý view thông dụng; cần implementation + directive phù hợp API container. | Chưa áp dụng: POM không có dependency JSTL, JSP không có taglib/c:if. Đề xuất thay if errorMessage trong VAccess bằng c:if và c:out; dùng bản Jakarta tương thích, không chép javax JAR cũ. |
| 14–16 | Directive/scriptlet/expression/comment/declaration | `<%@ %>` cấu hình JSP, `<% %>` câu lệnh, `<%= %>` output, `<%! %>` khai báo cấp generated servlet, `<%-- --%>` comment server. | Áp dụng page/import + scriptlet + expression + declaration escapeHtml ở JChat/JFields/JReviews/VAccess. Declaration method không tự là lỗi thread-safety nếu không có shared mutable data. |
| 17–18 | HTML/JSP/Java comments | HTML comment gửi xuống client và vẫn xử lý JSP bên trong; JSP comment bỏ phía server; Java comment trong scriptlet không thực thi. | Có HTML comments ở JFields và Java comments ở process JSP. Chưa thấy JSP comment `<%--`; không dùng HTML comment để giấu secrets hoặc tắt JSP code. |
| 19–22 | Truy cập bean bằng Java, jsp:useBean/getProperty và EL | Standard action có thể tạo bean; EL chủ yếu đọc, gọn và hỗ trợ nested/null; scriptlet mạnh nhưng trộn Java/UI. | Áp dụng cách Java thủ công: JReviews gọi review.getField().getFieldName; chưa dùng jsp:useBean/getProperty hay EL. Không nói bean tạo bởi EL. |
| 23–25 | useBean/getProperty/setProperty, scope, XML syntax | id/name phải khớp; useBean tạo nếu chưa có trong scope, setProperty ghi property qua accessor. | Chưa áp dụng standard bean actions. Đề xuất giữ việc tạo/validate entity trong servlet thay vì cho JSP tự sửa model nghiệp vụ. |
| 26 | Escape trong attribute JSP action | Escaping cú pháp dấu nháy khác escaping HTML/XSS; chọn quote bao ngoài phù hợp. | Chưa áp dụng jsp:setProperty escape syntax. Có escapeHtml tự viết nhưng đó là output encoding, không phải escape Java/JSP attribute của ví dụ. |
| 27–30 | Header/footer reuse bằng include/import và hai trang mẫu | Tách layout tránh sao chép; 29–30 chỉ đọc tiêu đề ảnh. | Chưa có header/footer includes; sidebar/header bị lặp ở JSP. Đề xuất WEB-INF/includes với fragment dùng chung. |
| 31–33 | Compile-time include và runtime jsp:include/c:import | Directive ghép source khi dịch JSP; action/import xử lý resource lúc request; c:import còn có thể lấy tài nguyên ngoài. | Chưa áp dụng cả ba. Khi refactor cần chọn compile-time cho fragment tĩnh hoặc runtime cho phần động; không đưa URL người dùng tùy ý vào c:import. |
| 34–35 | JSP 404/500, vị trí file và đọc lỗi | 404 khác lỗi translation/compile/runtime 500; hình error page chưa đọc. | JFields/JReviews redirect nếu thiếu attribute để người dùng vào controller; chưa có JSP error page riêng. Kiểm thử thật vẫn cần để phát hiện lỗi phiên bản Jakarta/EL. |

#### Chapter07

| Slide thực | Nội dung nhóm | Nghĩa / điểm cần nói | Sportify: file/class/method hoặc Chưa áp dụng + đề xuất |
|---|---|---|---|
| 1–3 | Mục tiêu sessions, cookies, URL và hidden fields | HTTP không tự duy trì nghiệp vụ giữa request; các cơ chế truyền ID/dữ liệu có rủi ro khác nhau. | Session owner demo có; custom cookies chưa có; query string và hidden fields có. |
| 4–6 | HTTP stateless, session ID cookie và server session | Stateless không có nghĩa luôn đóng TCP ngay: HTTP có keep-alive/multiplexing. Cookie giữ ID; dữ liệu HttpSession nằm server. 4–5 sơ đồ chưa đọc. | CAccess/FOwner dùng HttpSession; việc container tạo JSESSIONID là cơ chế tiêu chuẩn, chưa là bằng chứng đã quan sát cookie runtime. Không gọi flag session là cookie chứa mật khẩu. |
| 7–8 | Index/Cart sample | Chỉ có tiêu đề ảnh ứng dụng giỏ hàng. | Chưa áp dụng cart session; không có Cart model. Không gán màn hình mẫu thành feature Sportify. |
| 9–11 | getSession, set/get/removeAttribute; vòng đời session | getSession() có thể tạo; getSession(false) không tạo. Đóng browser không báo server xóa session ngay, server thường timeout. | CAccess.doPost tạo session và set OWNER_DEMO_AUTHORIZED; FOwner.doFilter và CAccess.doGet dùng getSession(false); CLogout.removeAttribute chỉ bỏ quyền, không invalidate cả session. |
| 12–13 | getId/isNew/attributeNames/maxInactiveInterval/invalidate | Inactive interval tính bằng giây ở API; âm là không timeout do inactivity, không đảm bảo xóa ngay lúc đóng browser. | Chưa áp dụng các API trên; W không session-timeout. Đề xuất timeout hợp lý + invalidate khi logout tài khoản thật, changeSessionId khi xác thực để giảm session fixation. |
| 14–16 | Multi-tab concurrency, synchronized theo session ID | Nhiều request cùng session vẫn đồng thời, kể cả một tab có async request; không coi một cửa sổ là đảm bảo thread-safe. intern-lock trong slide là mẫu cũ, không tự áp dụng cho distributed deployment. | Chưa có synchronized/lock session. Flag demo là Boolean, không có cart read-modify-write; nếu xây booking cần transaction/locking DB, không chỉ synchronized JVM. |
| 17–20 | Cookie name/value, session/persistent, mục đích cá nhân hóa | Cookie gửi lại theo domain/path; persistent dựa Max-Age/Expires. Các giới hạn 20/300/3 năm trên slide là mô tả cũ, không bảo đảm cho browser hiện tại. | Session có khả năng dùng cookie container; chưa có custom preference/remember-me. login.jsp remember checkbox không được login-process.jsp xử lý. |
| 21–24 | Cookie constructor, setMaxAge/setPath, addCookie/getCookies | Tạo Cookie và thêm response; request.getCookies có thể null; path '/' có thể rộng hơn context ứng dụng. | Chưa áp dụng explicit Cookie API trong source. Đề xuất cookie ngôn ngữ/theme không nhạy cảm với path hẹp; remember-me phải dùng token ngẫu nhiên phía DB, không mật khẩu/email là quyền. |
| 25–27 | Hiển thị cookies qua EL/JSTL và xóa Max-Age=0 | `${cookie.name.value}` đọc incoming cookie; xóa phải cùng name/domain/path; vẫn addCookie trong response. | Chưa áp dụng render/xóa custom cookies; CLogout bỏ session attribute KHÔNG phải code xóa persistent cookie. Không đưa session ID/cookie cá nhân lên UI production. |
| 28–29 | Cookie domain/path/Secure/version | Secure chỉ gửi HTTPS; scope cookie không thay thế authorization. version cookie cũ không là checklist bảo mật hiện đại. | Chưa có cấu hình cookie Secure/HttpOnly/SameSite trong source đọc. Đề xuất cấu hình session cookie ở container/app trên HTTPS và SameSite phù hợp; không tuyên bố runtime hiện đã an toàn. |
| 30–31 | CookieUtil null-safe | Utility duyệt cookie theo name, trả default khi không có; khác quyền đăng nhập server. | Chưa áp dụng: không có CookieUtil. Có thể bổ sung nếu thực sự cần cookie preference, tránh tiện ích đọc tùy tiện dữ liệu nhạy cảm. |
| 32–34 | URL rewriting truyền query parameter và rủi ro | Query string cần URL encoding; có thể lộ trong history/referrer/log. Khác session URL encoding `;jsessionid`. Mốc 2000 ký tự là khái quát cũ, không ngưỡng phổ quát. | CChat.doPost encode sender/receiver bằng URLEncoder; CReply.ratingQuery giữ rating. Chưa có response.encodeURL/encodeRedirectURL hoặc session ID trong URL source. |
| 35–37 | Hidden fields và so sánh với URL rewriting | Hidden không hiển thị UI nhưng client đọc/sửa được; server phải validate và kiểm quyền, không giữ secrets. | JReviews hidden reviewId/rating; JFields hidden fieldId; JChat hidden senderName/receiverName. DReview.saveOwnerReply ràng owner trong UPDATE; owner demo vẫn hardcoded, chưa user authorization thật. |
| 38–42 | Download demo: index/register/downloads, file layout, mapping/timeout | 38–40 chỉ tiêu đề ảnh; 41–42 là cấu trúc demo MP3 + DD, không phải cấu trúc Sportify. | Chưa áp dụng download servlet/MP3/email registration. Sportify có controller/view/data tương tự kiến trúc, không đồng nhất nghiệp vụ. |
| 43–49 | JSP demo links/query/hidden/EL path download | Ví dụ điều hướng, POST registration và tạo URL MP3 theo productCode/session. | Áp dụng cơ chế link/contextPath/form ở JChat/JReviews, nhưng chưa MP3 endpoint hoặc productCode session. Đề xuất nếu thêm media phải kiểm quyền server, không chỉ giấu link. |
| 50–52 | DownloadServlet doGet/doPost điều phối action và forward | Controller chọn hành động và view; GET đọc, POST registration; request attribute giữ qua forward. | CChat có handlers tương tự về cơ chế, nhưng POST dùng redirect. Chưa có DownloadServlet/checkUser/registerUser; không nhận code demo là source dự án. |
| 53–54 | checkUser: session → email cookie → file UserIO | Cookie hỗ trợ tìm lại người dùng là ví dụ giáo trình, không đủ chứng minh danh tính an toàn. | Chưa áp dụng cookie login hoặc UserIO file. FOwner chỉ kiểm flag owner demo; đề xuất tài khoản/role/ownerId thật và session identity xác thực. |
| 55–56 | registerUser ghi file, set session, persistent emailCookie | Ví dụ kết hợp persistence/state; cookie chứa email không nên dùng như credential quyền truy cập. | Chưa áp dụng: register-process.jsp chỉ redirect, không ghi DB, không session user, không cookie. CAccess có flag demo độc lập, không thay cho đăng ký thật. |

#### Chapter08

| Slide thực | Nội dung nhóm | Nghĩa / điểm cần nói | Sportify: file/class/method hoặc Chưa áp dụng + đề xuất |
|---|---|---|---|
| 1–4 | Mục tiêu/ưu nhược EL, đối chiếu standard action | EL gọn, nested/collection/null-friendly; không tự tạo bean hoặc thay setter như useBean/setProperty. | Chưa áp dụng EL render model trong JSP; JChat chủ động isELIgnored=true. `${...}` trong JavaScript template literal KHÔNG phải chứng cứ áp dụng EL. |
| 5–8 | Attribute/property, dot với bean/map, lookup scope | Bean property qua getter, map qua key; page → request → session → application có thể gây shadow tên. | CFields đặt fields và JFields lấy bằng request.getAttribute; có nền dữ liệu nhưng chưa biểu thức EL. Đề xuất `${requestScope.fields}` với c:forEach sau migration. |
| 9–12 | pageScope/requestScope/sessionScope/applicationScope | Các map scope làm rõ nguồn dữ liệu khi trùng tên. | Chưa áp dụng EL implicit scope maps. Có request/session ở Java API, nhưng không đồng nghĩa đã dùng requestScope/sessionScope trong JSP. |
| 13–16 | Bracket với bean, array/list; literal key so với index | `['name']` là literal property/key; `[0]` lấy phần tử collection, không giống JavaScript array trong client. | Chưa áp dụng EL bracket; JFields/JReviews lặp Java List và DField dùng results.get(0) là Java, KHÔNG EL. Đề xuất dùng collection ở controller + c:forEach. |
| 17–19 | Nested bean properties | Chuỗi property cần dữ liệu có thể truy cập; với JPA lazy phải cân nhắc EntityManager đã đóng. | Có nested getter Java review.getField().getFieldName ở JReviews: ý tưởng có, cú pháp EL chưa. DReview JOIN FETCH bảo đảm field load trước em.close; có thể đổi sang `${review.field.fieldName}` + c:out. |
| 20–22 | Key động và bracket lồng | Key không quote được EL evaluate; quoted 'email' khác giá trị biến email; bracket lồng từ trong ra ngoài. | Chưa áp dụng map động EL; đề xuất chỉ dùng khi UI thực cần map, không thêm complexity để khớp slide. |
| 23–25 | Implicit param/paramValues và các object khác | param đọc string request, paramValues đọc mảng; attribute/model và parameter/client khác nhau. | Chưa áp dụng implicit EL objects. CReviews dùng Java request.getParameter('rating'), không `${param.rating}`; kiểm tra đầu vào vẫn ở server. |
| 26 | HTTP header qua header map | Header key có '-' cần bracket; header là input không tin cậy và cần encode khi render. | Chưa áp dụng `${header...}` hoặc header debug view; không cần expose request headers cho viva demo. |
| 27 | cookie map | Cookie object và value khác nhau; EL đọc cookie incoming, không tạo cookie. | Chưa áp dụng custom cookie/EL cookie; xem Chapter07 21–31 để bổ sung có mục đích. |
| 28 | initParam context parameter | Chỉ context-param của web.xml, không servlet init-param hoặc HTTP parameter. | Chưa có context-param và chưa dùng `${initParam...}`. Đề xuất contact support không nhạy cảm nếu cần cấu hình. |
| 29 | pageContext request/response/session/contextPath | Bridge tới các object JSP; không hiển thị session ID ở production. | Chưa dùng EL pageContext. Đường dẫn context hiện dùng request.getContextPath trong scriptlet; có thể đổi `${pageContext.request.contextPath}` nếu bật EL. |
| 30–31 | Số học +,-,*,div,mod và precedence | EL có ép kiểu/null semantics; không nên đưa tính tiền nghiệp vụ vào view. | Chưa áp dụng số học EL; giá bằng BigDecimal ở entity/controller và NumberFormat tại JFields. Đề xuất tính tiền booking trong service, chỉ format ở view. |
| 32–34 | So sánh eq/ne/lt/... và logic and/or/not | Biểu thức phục vụ condition view, không thay authorization ở filter/DAO. | Chưa áp dụng EL operators; condition ở JReviews/JFields là Java if/ternary. Có thể chuyển condition hiển thị sang c:if/c:choose, giữ kiểm quyền server. |
| 35–37 | empty, ternary, true/false/null và ép kiểu | empty còn nhận collection/map/array rỗng, không chỉ null/string; default null trong số học/boolean cần hiểu để tránh che lỗi dữ liệu. | Chưa áp dụng các operator EL; Java ternary/Collections.emptyList không là EL. Migration phải giữ phân biệt DB loadFailed với danh sách rỗng. |
| 38–39 | Tắt EL và tắt scripting theo page/app | isELIgnored tránh container hiểu nhầm `${...}`; scripting-invalid cấm scriptlet/declaration/expression theo cấu hình. | Áp dụng rõ: JChat:19–22 isELIgnored=true vì JS template literal. Chưa có jsp-config/el-ignored/scripting-invalid app-wide. Đề xuất di chuyển JS sang .js trước bật EL, rồi bỏ scriptlet dần; không bật cấm scripting ngay khi JSP còn Java. |

#### Chapter09

| Slide thực | Nội dung nhóm | Nghĩa / điểm cần nói | Sportify: file/class/method hoặc Chưa áp dụng + đề xuất |
|---|---|---|---|
| 1–6 | JSTL libraries core/fmt/sql/xml/functions, taglib, docs/TLV | JSTL có nhóm chức năng khác nhau; prefix là quy ước, URI xác định library. TLV ghi chú hiện ngay trên slide3, không phải speaker notes. | Chưa áp dụng JSTL: không dependency/taglib trong POM/JSP. Đề xuất core/fmt/functions Jakarta tương thích. SQL tags không nên dùng để kéo nghiệp vụ DB vào view; Sportify đã có DAO/JPA. |
| 7–10 | XSS, c:out, escapeXml/default, quotes trong attribute | EL raw không tự HTML-escape; c:out mặc định escape XML hợp lý cho text HTML. Output encoding phải đúng context, không phải một hàm an toàn cho mọi JS/URL. | Áp dụng ý tưởng escape bằng escapeHtml trong JChat/JFields/JReviews/VAccess, CHƯA c:out. JReviews encode tên sân/khách/comment/reply. chat-friends.jsp đưa msg.text vào innerHTML client, cần textContent/encoding; không nhận toàn hệ thống đã chống XSS. |
| 11 | c:forEach collection | Lặp danh sách model mà không đặt vòng for Java trong JSP. | Chưa áp dụng tag; tương đương nghiệp vụ là for Review ở JReviews và for SportField ở JFields. Đề xuất đổi sang c:forEach items='${requestScope.reviews}'. |
| 12–13 | c:forTokens phân tách chuỗi | Tách theo từng delimiter char; không thay parser định dạng phức tạp/CSV có quoting. | Chưa áp dụng; không có productCodes/email parsing bằng tag. Nếu cần nhiều môn thể thao nên chuẩn hóa list ở model thay vì lưu CSV chỉ để dùng forTokens. |
| 14–16 | begin/end/step/varStatus và vòng lặp lồng | index là chỉ số, count đếm iteration; first/last giúp style; không phải pagination DB thật. | Chưa áp dụng advanced JSTL loops. JReviews loop sao 1..5 là Java; đề xuất begin/end cho hiển thị stars, phân trang dữ liệu làm ở DAO. |
| 17–19 | c:if, choose/when/otherwise | if đơn không có else; choose chọn when đầu đúng rồi otherwise; condition này chỉ quyết định UI. | Chưa áp dụng tags; JReviews Java if phân biệt loadFailed, empty, hasReply. Đề xuất c:choose giữ nguyên nhánh, không thay filter quyền. |
| 20–22 | c:url/c:param, context-aware URL, session URL encoding/tracking-mode | c:url tránh hardcode context và có thể encode session ID; c:param encode giá trị, không HTML-encode mọi context. COOKIE tracking mode hạn chế session ID trong URL. | Chưa c:url/c:param hoặc `<tracking-mode>COOKIE</tracking-mode>`. Source dùng contextPath và URLEncoder ở CChat; không nói đã khóa tracking mode. Đề xuất cookie-only sau kiểm thử client. |
| 23–24 | c:set/c:remove và bean property | set attribute hoặc property target; scope phải explicit khi cần; thay đổi view state khác ghi DB. | Chưa áp dụng JSTL state tags. Có Java request.setAttribute và CLogout.session.removeAttribute nhưng không phải c:set/c:remove; model mutation nghiệp vụ giữ trong controller/data. |
| 25 | c:catch/c:redirect | Bắt Throwable trong body để view xử lý; redirect tạo request mới. Không che lỗi nghiệp vụ bằng tag rồi coi thành công. | Chưa áp dụng tags. CReviews catch lỗi DAO/log/fallback HTTP503 ở Java; CReply redirect sau kết quả. Đề xuất error view chung thay vì SQL/try-catch nghiệp vụ trong JSP. |
| 26–27 | Trang Index/Cart ví dụ | Chỉ tiêu đề hình, không nhận diện widget/trạng thái ảnh chưa đọc. | Chưa có backend cart; dữ liệu đặt sân demo trên JFields không tương đương Cart CRUD. |
| 28–31 | Product/LineItem và property tính giá tổng | Getter dẫn xuất tính total từ quantity × price và format currency; chỉ logic mẫu giỏ hàng. | SportField có BigDecimal pricePerHour, JFields format giá; chưa có LineItem/getTotal/Cart hay tiền booking tính server. Đề xuất BigDecimal và service nếu xây đặt sân. |
| 32–33 | Cart collection, add/remove/update theo productCode | Quản lý aggregate trong memory/session; cần xử lý concurrent updates. | Chưa áp dụng Cart.addItem/removeItem. JPA SportField quản lý sân là nghiệp vụ khác, không gọi toggle sân là remove cart. |
| 34–36 | index.jsp forms hidden productCode | POST mang hidden identifier của đối tượng; identifier không phải chứng cứ quyền thao tác. | Cơ chế tương tự JFields hidden fieldId và JReviews reviewId; chưa nghiệp vụ Add To Cart CD. |
| 37–40 | CartServlet: action default, parse quantity, data lookup, session và forward | Validate quantity trước thay cart; quantity=0 remove; demo ProductIO file không là JPA. | CCreate/CUpdate/CReply có validation/controller/data, nhưng không CartServlet/cart session/ProductIO. DField/DReview kiểm owner trong truy vấn/cập nhật; owner demo vẫn chưa account real. |
| 41–43 | cart.jsp loop/out/forms update/remove/shop/checkout | View kết hợp collection render, encode output, hidden identifier và POST action. | JReviews/JFields có forms và loop thủ công; chưa JSTL cart, checkout thật. Đề xuất chuyển view sang EL/JSTL như bài luyện, không khẳng định booking/checkout đã lưu DB. |

#### Chapter10

| Slide thực | Nội dung nhóm | Nghĩa / điểm cần nói | Sportify: file/class/method hoặc Chưa áp dụng + đề xuất |
|---|---|---|---|
| 1–2 | Mục tiêu custom JSP tag/TLD/handler | Tag đóng gói hành vi view dùng lại; không đồng nghĩa JSTL hoặc HTML custom element. | Chưa áp dụng toàn chương: không file .tld/.tag, không package tag handler trong src, JSP không taglib custom. Các đề xuất sau là bài tập, không source hiện có. |
| 3–5 | Directive custom library, TLD name/class/URI | TLD nối tên tag với class handler; prefix đặt tại JSP; body rỗng có self-closing syntax. | Chưa áp dụng. Đề xuất thư viện nhỏ sportify:statusBadge chỉ nếu JSTL/core chưa đáp ứng, tạo TLD dưới WEB-INF và handler Java; dùng schema/element đúng đời API, không sao chép mẫu tagclass cũ mù quáng. |
| 6–7 | TagSupport/doStartTag/JspWriter/SKIP_BODY | Handler tag không body lấy pageContext.getOut và ghi response, kết thúc bằng SKIP_BODY. | Chưa áp dụng; escapeHtml trong JSP declaration là Java method, KHÔNG handler custom tag. Nếu tạo statusBadge phải encode text/allowlist class. |
| 8–11 | Tag có body, conditional include, EVAL_BODY_INCLUDE | doStartTag quyết định include hay skip body; TLD khai body-content. | Chưa áp dụng IfWeekdayTag. Đề xuất condition giờ hoạt động bằng c:if trước; không dùng tag view thay kiểm quyền server. |
| 12–19 | Attribute definitions, required/rtexprvalue/type và setter | Container truyền attribute qua setter; handler có default cho optional, type cần khớp runtime expression. | Chưa áp dụng IfEmptyMarkTag/attributes handler. Có thể luyện tag badge status với whitelist; validation dữ liệu nhập vẫn giữ CCreate/CUpdate, không chỉ đánh dấu '*' trong view. |
| 20–25 | BodyTagSupport lặp body, doInitBody/doAfterBody, buffer | EVAL_BODY_BUFFERED đánh giá body vào buffer; EVAL_BODY_AGAIN lặp; SKIP_BODY dừng; pageContext attribute cung cấp data từng lượt. | Chưa áp dụng CartTag hay BodyTagSupport. Đề xuất dùng c:forEach cho reviews trước, custom iterator tag chỉ là bài học nâng cao cần test empty/null/buffer. |
| 26–32 | Scripting variables, TagExtraInfo/VariableInfo và scope | TEI mô tả biến cho JSP translator; AT_BEGIN/AT_END/NESTED là scope của scripting variable, không request/session lifecycle. | Chưa áp dụng TEI/CartTEI; không gán Java local trong JReviews thành scripting variable từ custom tag. Nếu xây mới nên ưu tiên EL thay pattern legacy này. |
| 33–34 | TagSupport lifecycle/constants/release | doStartTag/doEndTag, SKIP_BODY/EVAL_BODY_INCLUDE, EVAL_PAGE/SKIP_PAGE và release tài nguyên; slide33 chỉ tiêu đề ảnh/bảng chưa đọc. | Chưa áp dụng; release của tag khác destroy của servlet hay EntityManager.close của DAO. Đề xuất tài nguyên tag chỉ vòng đời render, không EntityManager shared. |
| 35–37 | PageContext API và bốn scope | getOut/request/response, set/getAttribute, findAttribute tra page→request→session→application; hằng PAGE/REQUEST/SESSION/APPLICATION_SCOPE. | Chưa có handler PageContext trực tiếp. JSP implicit request/session là cơ chế liên quan nhưng không bằng chứng sử dụng API trong custom tag. |
| 38–39 | BodyTagSupport processing hooks | doInitBody cho lượt đầu, doAfterBody cho lượt tiếp theo; slide38 chỉ tiêu đề hình/bảng. | Chưa áp dụng. Bài tập bổ sung cần chứng minh EVAL_BODY_AGAIN không lặp vô hạn và data thay đúng mỗi lượt. |
| 40–42 | BodyContent clearBody/getString/getEnclosingWriter/writeOut | BodyContent giữ phần render trước khi gửi ra; có thể sửa/buffer nhưng phải cân nhắc bộ nhớ. | Chưa áp dụng. Đề xuất test output tag bằng empty/one/many items; không cần custom buffer để làm CRUD Sportify hiện tại. |

#### Chapter13

| Slide thực | Nội dung nhóm | Nghĩa / điểm cần nói | Sportify: file/class/method hoặc Chưa áp dụng + đề xuất |
|---|---|---|---|
| 1–3 | Mục tiêu entity/DAO/O-R mapping/transactions | Entity mapping, PU, EMF/EM, truy vấn và transaction nối model Java tới RDBMS. | Áp dụng sâu ở DField/DChat/DReview và entities; không phải mọi thao tác mẫu đều đã có (merge/remove/bulk delete chưa). |
| 4–5 | JPA specification vs Hibernate/EclipseLink/TopLink, entity manager | JPA là spec chạy trên JDBC; Hibernate là implementation. Tomcat không tự cung cấp JPA full-stack như app server. | Áp dụng Hibernate trong POM và PU; PostgreSQL JDBC driver trong POM. DBUtil tự tạo EMF, DAO tự tạo/đóng EM; không phải container-managed JTA. |
| 6–7 | Thêm driver/library và persistence unit bằng IDE | Hình NetBeans chưa đọc; quy trình IDE cũ có thể thay bằng dependency/build chuẩn. | Áp dụng bằng Maven POM, không thao tác Add Library NetBeans đã xác minh. PU nằm src/main/resources/META-INF/persistence.xml. |
| 8–9 | persistence.xml: PU/provider/RESOURCE_LOCAL/entity discovery/cache | PU name nối code factory với config; RESOURCE_LOCAL do app quản transaction; shared-cache-mode chỉ điều chỉnh cache. | PU `sportifyPU`, version3.2, HibernatePersistenceProvider, RESOURCE_LOCAL, liệt kê 3 class; DBUtil dùng đúng tên. hbm2ddl.auto=validate chứ không create như ví dụ; không có shared-cache-mode explicit. Không chép JDBC credential. |
| 10–11 | @Entity/@Id/@GeneratedValue/@Table/@Column | Entity ánh xạ class; ID primary key; strategy IDENTITY khác AUTO mẫu; override table/column khi schema khác tên Java. | Áp dụng SportField→sports_fields, ChatMessage→chat_messages, Review→reviews; fieldId/messageId/reviewId IDENTITY. SportField pricePerHour precision12/scale2 cho số tiền. |
| 12–14 | Getter access vs field access | Vị trí @Id quyết định default access; field access dùng reflection, không gọi setter. Slide nói không mix là quy tắc giản lược; explicit @Access có thể phân định khi thực sự cần. | Áp dụng field access cho cả 3 entity: annotation ở private field. Setter ở CCreate/CUpdate là app code gọi, không chứng minh Hibernate dùng setter. |
| 15–17 | ManyToOne/OneToMany, fetch và cascade | ManyToOne nhiều bản ghi trỏ một; fetch LAZY/EAGER và cascade là hai điều độc lập, LAZY không tự giữ EM mở. | Review.field @ManyToOne(fetch=LAZY, optional=false) + JoinColumn field_id; DReview JOIN FETCH khi render. Chưa @OneToMany hay cascade ALL/PERSIST/MERGE/REMOVE; không suy ra delete sân tự xóa review. |
| 18 | @Temporal DATE/TIME/TIMESTAMP | @Temporal dành java.util.Date/Calendar; không dùng trên java.time types hiện đại. | Không áp dụng @Temporal nhưng có tương đương thời gian: SportField LocalTime/LocalDateTime, Review LocalDateTime, ChatMessage LocalDateTime; SportField.beforeInsert/beforeUpdate gán timestamp lifecycle. |
| 19–20 | Persistence.createEntityManagerFactory và utility EMF | EMF tạo từ đúng tên PU, đắt và dùng chung; lifecycle shutdown khác per-request EM. | DBUtil:8–16 static EMF sportifyPU/getEntityManagerFactory; closeEntityManagerFactory:18–22 có sẵn nhưng chưa thấy main listener gọi. Đề xuất ServletContextListener để cleanup, không nói hiện đã cleanup tự động. |
| 21–22 | em.find primary key, local EM, finally close | find trả null nếu ID không có; EM không thread-safe và cần giải phóng resources. | DField.update/toggleStatus dùng em.find và kiểm owner; mọi DAO luồng chính tạo local EM và finally close. Không dùng một static EntityManager cho toàn app. |
| 23–25 | TypedQuery/getResultList, JPQL entity properties, projections | JPQL dùng tên entity/property, không tên SQL table/column; list có thể rỗng; fetch relationship tránh truy cập lazy sau close. | DField.findByOwnerId JPQL field.ownerId/order createdAt; DChat.selectConversation có OR hai chiều; DReview.findByOwnerId JOIN FETCH review.field. Không cần ghép SQL từ client. |
| 26–28 | getSingleResult, NoResult/NonUnique, named parameters | Named :name gắn bằng setParameter, giúp tránh injection giá trị. Single result yêu cầu semantics rõ; aggregate thường có một dòng dù count0. | DReview.getSummaryByOwnerId dùng COUNT/AVG + getSingleResult và AVG null→0. DField.findByIdAndOwnerId dùng list/empty→null, không catch NoResultException như demo. Chưa thấy catch NonUniqueResultException. |
| 29–32 | begin/persist/merge/remove/flush/commit/rollback | Transaction bảo đảm atomic; flush đồng bộ nhưng chưa commit; merge trả managed copy, remove cần managed. Dirty checking managed entity có thể UPDATE mà không gọi merge. | DField.insert/DChat.insert dùng persist; DField.update/toggleStatus find managed, set field rồi commit (dirty checking); rollback kiểm isActive. Chưa gọi em.merge/em.remove/em.flush explicit; không mô tả insert là auto commit không transaction. |
| 33–35 | JPQL bulk UPDATE/DELETE, executeUpdate count | Bulk query cần transaction, trả số affected rows; có thể làm persistence context stale và không mặc định chạy entity cascade/callback. Không coi câu slide35 về tự xóa lineItems là bảo đảm JPQL bulk delete. | Áp dụng bulk UPDATE thật: DReview.saveOwnerReply set reply/repliedAt và ràng owner bằng subquery, executeUpdate rồi updated==1. Chưa bulk DELETE. repliedAt gán explicit, không dựa @PreUpdate của entity. |
| 36–39 | UserDB mẫu insert/update/delete/select/emailExists | Mẫu tổng hợp DAO local EM/transaction; không có nghĩa project có User entity và đăng ký. | Áp dụng kiến trúc DAO ở DField/DChat/DReview, nhưng không UserDB/emailExists/user CRUD. login/register process còn dummy; đề xuất User entity + account service + hash password + role/ownerId session, không fake login là hoàn chỉnh. |



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
