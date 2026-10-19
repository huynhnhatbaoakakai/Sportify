# SPORTIFY — GUIDE ÔN VẤN ĐÁP 4 GIỜ, MỞ CODE ĐẾN ĐÂU HIỂU ĐẾN ĐÓ

**Nguồn chính:** [README hiện tại](../../README.md), đối chiếu code trong bản `C:\Users\20huy\Desktop\workplace\Sportify-backup\Sportify`.

**Thời lượng:** 06:00–10:00 theo 4 giờ bạn dành để ôn, không phải xác nhận đồng hồ hiện tại hoặc giờ thi. Nếu bắt đầu muộn, dịch cả lịch theo thời điểm bắt đầu. Guide là kết quả đọc source, không phải chứng cứ build/runtime đã pass; không chạy server, seed, test ghi DB hay sửa sản phẩm trong lúc tạo guide.

## 0. Mục tiêu — không cố hiểu mọi file

Sau 4 giờ, nhắm tới khả năng **mở đúng đoạn code và giải thích**:

1. Luồng xem danh sách sân: URL → Servlet → owner trong session → query → request → JSP → getter/HTML.
2. Luồng thêm sân: form → POST → parameter → validation → setter/model → transaction/persist → redirect.
3. Chỗ khác của sửa/toggle; ownership không dựa hidden field hay ẩn nút.
4. Kết nối ở đâu; SQL/JDBC khác JPQL/JPA thế nào; request khác session.
5. Review và nhánh chat hiện tại nằm đâu; nói đúng phần bạn làm và giới hạn.

**Chưa học sâu:** toàn bộ BookingDB, thuật toán lịch, Newsfeed, mọi CSS selector, mọi test hay custom-tag implementation. Booking là phần thành viên khác, bạn chỉ cần hiểu điểm liên kết đủ trình bày toàn dự án. Không mặc định nhận mọi file trong clone là do bạn viết.

**Hiện trạng học:** bạn đã nhận diện nhiều khái niệm qua câu hỏi ngắn, nhưng chưa có bằng chứng tự kể trọn luồng. Không coi nhắn “t/ok” hoặc tìm đúng một tên là đã nắm toàn bộ. Dành thời gian tự nói thay vì chỉ đọc guide.

## 1. Lịch 240 phút — có nghỉ, có tự nói

| Giờ | Phút | Chặng | Kết quả phải tạo được |
|---|---:|---|---|
| 06:00–06:10 | 10 | Chuẩn bị editor, bản đồ project | Mở đúng root, biết controller/model/data/webapp nằm đâu |
| 06:10–06:45 | 35 | A. Đọc và hiển thị sân | Tự nối được URL → getter → HTML, phân biệt null/rỗng |
| 06:45–07:30 | 45 | B. Thêm/sửa/toggle sân | Trace một form đến commit/redirect; phân biệt getter/setter |
| 07:30–07:40 | 10 | Nghỉ | Đứng dậy, rời màn hình; không lướt thêm tài liệu |
| 07:40–08:15 | 35 | C. Session/quyền + database | Chỉ owner lấy từ đâu, JDBC/JPA kết nối ở đâu |
| 08:15–08:45 | 30 | D. Review/chat + liên kết phần nhóm | Chỉ reply UPDATE và nhánh chat friend_messages, không học nhầm legacy |
| 08:45–08:55 | 10 | Nghỉ | Dừng nạp kiến thức |
| 08:55–09:35 | 40 | E. Vấn đáp thử trên editor | Tự trả lời, chỉ code, ghi tối đa 3 điểm yếu để sửa |
| 09:35–10:00 | 25 | F. Tổng duyệt demo/tờ tra nhanh | Mở sẵn tab, tập giới thiệu, chốt lỗi chưa khắc phục |

### Quy tắc chống sa lầy

- Mỗi chặng: **đọc mục đích → mở file → tìm symbol → lần theo code → tự nói**. Không chép lại nguyên class.
- Khi gặp từ lạ, hỏi “nó nhận gì/trả gì/ảnh hưởng đâu?” trước khi tra sâu API.
- Một đoạn khó quá 5 phút: ghi dấu ?, học ý chính rồi tiếp tục. Không cài extension/đổi môi trường lúc đang ôn nếu vẫn mở file thủ công được.
- Không hỏi nhận diện mỗi dòng. Chỉ tự kiểm tra cuối một khối hành vi. Quên tên có thể tra; không hiểu dữ liệu đi đâu phải quay lại flow.
- Bắt đầu chặng E đúng giờ dù chặng trước chưa đủ. Ôn thụ động hết 4 giờ mà chưa tự nói là không đạt mục tiêu.
- Không chạy các lệnh migration/build “cho chắc” trên dữ liệu thật. Live demo cần môi trường/tài khoản được phép; đề nghị kiểm tra runtime riêng khi cần.

## 2. Chuẩn bị editor — chỉ 10 phút

Mở folder có **README.md, pom.xml, src cùng cấp**:

```text
C:\Users\20huy\Desktop\workplace\Sportify-backup\Sportify
```

1. Mở README, Ctrl+Shift+V để xem Preview; dùng mục **Chức năng phía chủ sân**, **File dùng chung** và **Tra nhanh câu hỏi vấn đáp** làm chỉ mục.
2. Ctrl+P: tìm file. Ctrl+F: tìm tên method/từ khóa. Ctrl+G: tới dòng nếu cần. Ctrl+click/F12 không chạy trong JSP thì dùng hai phím đầu, không mất thời gian sửa IDE.
3. Chỉ mở tab của chặng hiện tại; tránh mở mười mấy tab ngay.
4. Không sửa source. Nếu muốn trace/ghi ý, ghi trên tablet hoặc một ghi chú trong docs/viva; không xóa code để luyện nhớ.

```text
src/main/java/com/sportify/
  controller/   nhận request, gọi xử lý, chọn response
  model/        object Java; một số là entity map bảng
  data/         chủ yếu JPA/JPQL; không phải tất cả đều JPA
  dao/          JDBC/SQL
  util/         helper owner, CSRF, HTML, mật khẩu
  filter/       chặn request không đủ quyền/token
  config/       cấu hình và kết nối database
src/main/resources/   persistence.xml và config
src/main/webapp/       JSP, CSS, JavaScript
```

**dao/ và data/ không phải hai bước luôn đi nối tiếp.** Luồng sân owner dùng SportFieldDB ở data; không học nhầm SportFieldDAO ở dao chỉ vì tên giống. Các link dưới tính đúng từ thư mục guide này.

## A. 35 phút — XEM DANH SÁCH SÂN

### A1. 8 phút: URL vào Servlet, owner lấy từ đâu?

Mở [ManageFieldsServlet.java](../../src/main/java/com/sportify/controller/ManageFieldsServlet.java). Tìm `@WebServlet`, `doGet`, `findByOwnerId`, `setAttribute`, `forward`.

```java
@WebServlet({"/owner/fields", "/owner/bookings"})
```

- Annotation là cách **khai báo mapping**, không phải tên URL hay tên class.
- URL /owner/fields và /owner/bookings cùng mapping tới class ManageFieldsServlet.
- HTTP GET được HttpServlet dispatch tới doGet. Filter kiểm tra truy cập trước khi cho request đi tiếp; chưa cần học thứ tự cụ thể của hai filter.

```java
List<SportField> fields =
        SportFieldDB.findByOwnerId(com.sportify.util.OwnerAccess.ownerId(request));
```

Đọc từ trong ra ngoài: OwnerAccess lấy ID user owner trong session → truyền vào findByOwnerId → nhận List<SportField> → biến fields giữ kết quả. **Không dùng owner demo1 ở đoạn này của bản mới.**

### A2. 9 phút: query được thực hiện ở đâu?

Mở [data/SportFieldDB.java](../../src/main/java/com/sportify/data/SportFieldDB.java), tìm `findByOwnerId`.

```java
String jpql =
        "SELECT field FROM SportField field " +
        "WHERE field.ownerId = :ownerId " +
        "ORDER BY field.createdAt DESC";
```

- JPQL dùng tên entity **SportField**, property **ownerId/createdAt**; không viết tên bảng sports_fields ở đây.
- field là alias trong truy vấn, không biến fields bên Servlet.
- WHERE giới hạn đúng owner; DESC mới tạo trước.
- Chuỗi mới mô tả truy vấn, chưa lấy danh sách.

```java
TypedQuery<SportField> query =
        em.createQuery(jpql, SportField.class);
query.setParameter("ownerId", ownerId);
return query.getResultList();
```

createQuery chuẩn bị query → setParameter bind **giá trị tìm**, không UPDATE owner → getResultList lấy danh sách → finally em.close dọn EntityManager trước khi method hoàn tất trả về. Không có kết quả là **list rỗng**; query lỗi có thể ném exception, không mặc định null. Đóng EM không phải tắt PostgreSQL.

### A3. 8 phút: entity/map/getter khác query

Mở [model/SportField.java](../../src/main/java/com/sportify/model/SportField.java). Tìm `@Entity`, `@Table`, `@Id`, `getStatus`, `getFieldName`.

```java
@Entity
@Table(name = "sports_fields")
public class SportField implements Serializable {
```

Entity do JPA quản lý, map class tới bảng. Annotation mapping **không tự chạy SELECT**.

```java
@Id
@GeneratedValue(strategy = GenerationType.IDENTITY)
@Column(name = "field_id")
private Long fieldId;
```

fieldId định danh sân; @Id đánh dấu khóa entity; @Column nối tới cột field_id; IDENTITY dùng cơ chế DB sinh ID (schema cũng phải tương thích). ownerId là **chủ của sân**, không phải PK của SportField. Một chủ có nhiều sân. ID tự sinh không hứa liên tục.

```java
public String getStatus() {
    return status;
}
```

Getter đọc property đã có trong object; không SELECT DB. Setter như setFieldName gán property của object; **setter riêng lẻ không bảo đảm dữ liệu đã commit DB**.

### A4. 7 phút: request → JSP → HTML

Quay ManageFieldsServlet:

```java
request.setAttribute("fields", fields);
```

Đối số đầu là **nhãn chuỗi**, đối số sau là **biến dữ liệu**. Gắn vào request, không INSERT DB.

```java
request.getRequestDispatcher("/owner/dashboard.jsp")
        .forward(request, response);
```

Forward nội bộ, cùng request nên attrs còn; browser không request mới chỉ vì forward, URL không tự đổi thành JSP.

Mở [owner/dashboard.jsp](../../src/main/webapp/owner/dashboard.jsp), Ctrl+F `request.getAttribute("fields")`, rồi `activeFieldCount`, `getFieldName`.

```java
List<SportField> fields =
        (List<SportField>) request.getAttribute("fields");
```

getAttribute trả Object; casting nói kiểu mong đợi, không biến mọi object thành list. Biến fields của JSP khác biến bên Servlet; dữ liệu truyền qua attribute.

- `fields == null`: không có danh sách để dùng, chẳng hạn attr vắng; JSP redirect controller.
- List rỗng: có danh sách nhưng 0 sân; vòng lặp chạy 0 lượt, không vào nhánh null.
- for(SportField field : fields): mỗi lượt lấy một object, không query từng lượt.
- getStatus đọc trạng thái; ACTIVE thì activeFieldCount++.
- `<%= activeFieldCount %>` xuất giá trị vào HTML; getter/tính đếm đã chạy server.
- `<%= escapeHtml(field.getFieldName()) %>`: lấy tên → encode HTML → ghi HTML. Browser không nhận Java source để chạy.

### A5. 3 phút: tự kể không đọc mẫu

Đóng guide, giữ source. Chỉ code và kể: “Tôi mở URL nào, class/method nào nhận, owner từ đâu, query ở đâu, danh sách sang JSP thế nào, getter làm gì?”

**Đạt chặng A khi:** tự nối được các mắt xích, không chỉ đọc lại tên. Nếu nhầm request với DB hoặc null với list rỗng, ghi vào danh sách yếu để sửa. Liên hệ slide: C02 MVC, C05 Servlet/request/forward, C06 JSP/bean, C13 entity/JPQL.

## B. 45 phút — THÊM, SỬA, ĐỔI TRẠNG THÁI SÂN

### B1. 8 phút: nút giao diện gửi dữ liệu bằng gì?

Mở dashboard.jsp, tìm `data-field-form`; mở [owner-dashboard.js](../../src/main/webapp/assets/js/owner-dashboard.js), tìm `openFieldModal`.

```html
<!-- Trích các thuộc tính form; URL thực trong JSP có contextPath -->
<form method="post" action=".../owner/fields/create">
```

- method quyết định HTTP method; action là URL nhận form.
- name của input là tên parameter. `name="fieldName"` → getParameter("fieldName"); id dùng gắn label/DOM không thay name khi gửi form.
- Các name hiện tại: fieldId, fieldName, sportType, address, pricePerHour, status, openTime, closeTime, csrfToken.
- JS openFieldModal reset/prefill, đổi action create/update, hidden fieldId; submit hợp lệ là HTML POST bình thường, không fetch gửi sân.
- JS kiểm giờ/disable button là frontend; browser validation có thể bị bypass nên server vẫn phải kiểm tra.
- Description/imageUrl có trong model nhưng **form này chưa có input tương ứng**; không tự nhận upload ảnh.

### B2. 14 phút: đọc một luồng thêm hoàn chỉnh

Mở [CreateFieldServlet.java](../../src/main/java/com/sportify/controller/CreateFieldServlet.java). Đọc doPost theo 6 cụm, không đọc mọi import:

1. @WebServlet /owner/fields/create + doPost; UTF8 trước getParameter.
2. getParameter nhận string từ form. required kiểm null/blank rồi trim; BigDecimal parse giá, LocalTime parse giờ.
3. Whitelist GYM/BASKETBALL/SWIMMING/PICKLEBALL; giá>0; đóng sau mở; status khác INACTIVE quy ACTIVE.
4. new SportField + setters; owner từ OwnerAccess.ownerId(request), không lấy owner client gửi.
5. SportFieldDB.insert(field).
6. sendRedirect về /owner/fields?success=created#fields; invalid→error=invalid; exception khác bọc ServletException.

```java
SportField field = new SportField();
field.setOwnerId(com.sportify.util.OwnerAccess.ownerId(request));
field.setFieldName(fieldName);
```

Object vừa tạo là dữ liệu trong memory, chưa đủ gọi “đã lưu”. Các setter còn lại gán type/address/price/hours/status.

Trong SportFieldDB tìm `insert`:

```java
transaction.begin();
em.persist(field);
transaction.commit();
```

begin mở transaction → persist yêu cầu đưa entity mới vào persistence context để INSERT → commit xác nhận thay đổi; lỗi rollback, finally close EM. SQL có thể phát trước commit (đặc biệt IDENTITY); **không hiểu persist luôn chờ commit mới gửi SQL**. Giao dịch chưa commit không được coi là lưu bền vững thành công.

Trong SportField tìm `beforeInsert`, `beforeUpdate`: callback JPA @PrePersist gán created/updated timestamps; @PreUpdate cập nhật updatedAt. Timestamp callback không phải validation toàn bộ input.

**PRG:** POST thành công → redirect → browser GET list mới → query lại → JSP. Refresh sau đó lặp GET, không tự POST thêm sân. PRG không tự chống double submit/replay/CSRF.

### B3. 10 phút: sửa và toggle chỉ đọc điểm khác

Mở [UpdateFieldServlet.java](../../src/main/java/com/sportify/controller/UpdateFieldServlet.java), tìm `findByIdAndOwnerId`:

- fieldId đến từ hidden field (sửa được ở client); owner đến từ session qua helper.
- Lookup cả ID và owner; không thấy→404, return. Tìm sân chỉ bằng ID là chưa đủ quyền.
- Validate giống thêm; setters rồi SportFieldDB.update.
- DAO update mở EM/transaction mới, find currentField với PESSIMISTIC_WRITE, kiểm owner lại, copy data lên managed entity, commit dirty checking. Không cần merge currentField đang managed. Object lookup trước đó đã detached sau EM.close.
- Bản hiện tại **có PESSIMISTIC_WRITE** ở update/toggle; không dùng kết luận cũ “không lock”. Không vì có lock mà hứa mọi concurrency case đều giải quyết.

Mở [ToggleFieldStatusServlet.java](../../src/main/java/com/sportify/controller/ToggleFieldStatusServlet.java) và SportFieldDB.toggleStatus:

- POST fieldId → parse → DAO owner check, lock → ACTIVE ↔ INACTIVE → commit → redirect.
- Không DELETE row, không “CRUD đủ Delete”. Giữ dữ liệu/lịch sử là lý do hợp lý dùng status; không tự suy trạng thái thay đổi sẽ hủy mọi booking.
- **Hạn chế có thật:** update/toggle controller chưa dùng boolean DAO trả về, nên URL success không tự chứng minh có row được cập nhật. DAO vẫn kiểm owner, không có nghĩa foreign row bị sửa.

### B4. 8 phút: nắm các cặp hay nhầm

| Cặp | Cách phân biệt và evidence |
|---|---|
| getParameter / getAttribute | Form/query client gửi string / object server đã gắn vào request |
| getter / setter | Đọc / gán property object; không tự chứng minh DB query/write |
| forward / redirect | Cùng request nội bộ / browser request mới, request attrs cũ không tự qua |
| GET / POST | Luồng đọc/hiển thị / gửi thay đổi; POST không tự mã hóa, vẫn cần HTTPS |
| Client/server validation | JS/HTML thuận tiện / server phải bảo vệ dữ liệu dù client bypass |
| Request/session/DB | Một request / trạng thái qua nhiều request của phiên / lưu dữ liệu độc lập phiên |

Điểm yếu có thể nói thật: HTML min/step giá1000 nhưng server>0; maxlength form/entity không thay validation server; giờ close>open chưa hỗ trợ qua nửa đêm. Không hứa mọi parse error được báo thân thiện: DateTimeParseException có thể rơi generic catch. Source đang có các điểm này, không sửa trong giờ ôn.

### B5. 5 phút: tự trace từ nút đến DB rồi ngược về

Dùng input minh họa, **không cần submit vào DB thật**: tên “Sân ôn tập”, môn PICKLEBALL, giá hợp lệ, giờ06:00–22:00. Chỉ code nơi đọc name → kiểm tra → setter → persist → commit → redirect. Tự trả lời: bỏ insert nhưng giữ setters thì có đủ lưu DB không? Bỏ redirect thì refresh sau POST có rủi ro gì?

**Đạt chặng B khi:** hiểu form name thành parameter và transaction/redirect làm gì, chỉ được ownership check. Liên hệ C05 forms/validation/redirect, C13 persistence/transaction.

## C. 35 phút — SESSION, QUYỀN VÀ KẾT NỐI DATABASE

### C1. 12 phút: người đang đăng nhập lấy từ đâu?

Mở [LoginServlet.java](../../src/main/java/com/sportify/controller/auth/LoginServlet.java), tìm `doPost`, rồi [OwnerAccess.java](../../src/main/java/com/sportify/util/OwnerAccess.java).

```text
POST /login email/password
 → UserDAO.checkLogin
 → User hợp lệ
 → invalidate session cũ nếu có
 → session mới setAttribute(SESSION_USER,user)
 → redirect owner/fields hoặc home
```

SESSION_USER là key user theo BaseServlet. Session giữ object User, không phải “mật khẩu lưu trong cookie”. Cookie session ID nếu container dùng cookie là thứ browser gửi để nhận lại phiên; flag/property nằm server.

OwnerAccess.currentUser: getSession(false) không tạo session, nếu có lấy session.getAttribute("user"). ownerId: thiếu user hoặc !isOwner thì exception; còn lại user.getId. **Owner ID ở luồng sân hiện từ session, không hardcode1, không tin input form**. Các default/legacy ở nơi khác nếu thấy không thay kết luận call-site này.

Mở [OwnerAccessFilter.java](../../src/main/java/com/sportify/filter/OwnerAccessFilter.java): @WebFilter /owner/*; doFilter:

- Chưa user → redirect login.
- Không OWNER →403 + forward view thiếu quyền.
- POST token sai →403; valid mới chain.doFilter.
- Gắn csrfToken vào request để form dùng. Trong form name=csrfToken; helper [Csrf.java](../../src/main/java/com/sportify/util/Csrf.java) so với token session.

**Authentication**: xác minh bạn là ai. **Authorization**: được làm gì. Role OWNER không cho xem sân của mọi owner; DAO vẫn lọc owner. CSRF token giảm nguy cơ request đổi state giả mạo; không thay password/hash/authorization, không phải chống SQL injection. Source có nhiều filter annotation, đừng tự khẳng định thứ tự chạy AuthFilter trước OwnerAccessFilter nếu chưa kiểm cấu hình.

### C2. 13 phút: câu cô hỏi “kết nối SQL ở đâu?”

Không chỉ một file. Mở theo vai trò:

| Cần tìm | File và symbol |
|---|---|
| Cấu hình URL/user/password | [config/DatabaseConfig.java](../../src/main/java/com/sportify/config/DatabaseConfig.java): getJdbcUrl/getUsername/getPassword/setting |
| File mẫu cấu hình | [database.properties.example](../../src/main/resources/database.properties.example); file thật local không chiếu secret |
| JDBC tạo Connection | [config/DBContext.java](../../src/main/java/com/sportify/config/DBContext.java): getConnection→DriverManager.getConnection |
| JPA tạo/tái sử dụng EMF | [data/DBUtil.java](../../src/main/java/com/sportify/data/DBUtil.java): getEntityManagerFactory→Persistence.createEntityManagerFactory("sportifyPU", DatabaseConfig.getJpaProperties()) |
| Persistence unit/entities/Hibernate | [persistence.xml](../../src/main/resources/META-INF/persistence.xml): sportifyPU, RESOURCE_LOCAL, provider, class list, validate |
| Query sân | SportFieldDB.findByOwnerId: EM → createQuery/bind/getResultList/finally close |
| Đóng factory khi app dừng | [config/AppLifecycle.java](../../src/main/java/com/sportify/config/AppLifecycle.java): contextDestroyed |
| Build/library | [pom.xml](../../pom.xml): Java17, WAR, Servlet provided, Hibernate, PostgreSQL driver |

DatabaseConfig đọc ưu tiên: JVM properties → environment → database.properties → fallback. Default URL chỉ là **mặc định**, actual có thể override; không nói DB live chắc như default nếu chưa query.

**EMF**: factory dùng chung để tạo EntityManager, tốn chi phí khởi tạo; DBUtil tạo lazy/tái sử dụng, không tạo factory mỗi request. **EM**: đối tượng làm việc JPA cho một thao tác; DAO tạo local/đóng finally. **JPA** là API/spec; **Hibernate** là implementation; JDBC driver kết nối PostgreSQL phía dưới. Tomcat cung cấp Servlet/JSP, không tự là Hibernate.

`hibernate.hbm2ddl.auto=validate`: kiểm schema đã có, **không tự tạo đầy đủ bảng**. Tìm DDL ở [database/init_all_postgresql.sql](../../database/init_all_postgresql.sql); không chạy migration lúc ôn. SQLException/schema error không đồng nghĩa database chưa khởi động: đọc root cause.

### C3. 6 phút: tự chỉ ví dụ PreparedStatement và JPQL

Mở [dao/UserDAO.java](../../src/main/java/com/sportify/dao/UserDAO.java), method checkLogin:

```text
SQL: ... FROM public.users WHERE LOWER(email) = LOWER(?)
statement.setString(1,email.trim())
statement.executeQuery()
```

Đây là JDBC/SQL thật: bảng users, placeholder ?, binding setString. PasswordHasher.verify so sánh mật khẩu, không nối password vào SQL. Sau xác thực có nhánh nâng cấp password legacy chưa hash, vì vậy gọi checkLogin không luôn là read-only DB.

So với sân:

```text
JPQL: FROM SportField field WHERE field.ownerId=:ownerId
query.setParameter("ownerId",ownerId)
query.getResultList()
```

Binding coi input là **giá trị**, không cho nó đổi cấu trúc query. Không hứa chống mọi injection trên toàn codebase hoặc chống XSS/đọc dữ liệu trái quyền. Cả JDBC và JPA đang có trong bản mới; không nói “toàn project chỉ JPA”.

### C4. 4 phút: ba câu tự trả lời

- Session user được gắn và đọc ở hai chỗ nào? Request attribute list khác chỗ đó thế nào?
- Connection config, JDBC Connection và JPA factory là ba việc khác nhau ra sao?
- Hidden ownerId có nên làm nguồn authorization không? Hiện call-site lấy ownerId từ đâu?

**Đạt chặng C khi:** mở đúng config/query/helper và giải thích bằng vai trò, không chỉ kể tên file. Liên hệ C07 session, C13 JPA; PreparedStatement/security là kiến thức trực tiếp bám code.

## D. 30 phút — REVIEW, CHAT VÀ PHẠM VI NHÓM

### D1. 13 phút: reuse luồng đã hiểu cho review

Mở [ManageReviewsServlet.java](../../src/main/java/com/sportify/controller/ManageReviewsServlet.java), tìm parseRating/findByOwnerId/forward; rồi [ReviewDB.java](../../src/main/java/com/sportify/data/ReviewDB.java).

```text
GET /owner/reviews?rating=5
 → parseRating nhận1..5/null
 → list(ownerId,rating) + summary(ownerId)
 → request attrs → forward reviews.jsp
```

List lọc theo rating, summary COUNT/AVG toàn owner **không theo filter**. List JOIN FETCH review.field để JSP đọc fieldName sau EM.close. [Review.java](../../src/main/java/com/sportify/model/Review.java): ManyToOne field; field_id FK tới sân, nhiều review của một sân. Không tự suy ra customerName là user account hay khách phải booking trước khi review.

Mở [ReplyReviewServlet.java](../../src/main/java/com/sportify/controller/ReplyReviewServlet.java) và [owner/reviews.jsp](../../src/main/webapp/owner/reviews.jsp), tìm ownerReply:

```text
POST /owner/reviews/reply: reviewId,ownerReply,rating,csrfToken
 → filter role/token
 → ID dương, reply nonblank và <=2000
 → ReviewDB.saveOwnerReply(reviewId,sessionOwnerId,text)
 → UPDATE ownerReply/repliedAt, WHERE reviewId + sân thuộc owner
 → executeUpdate, commit, true nếu1row
 → redirect reviews giữ rating
```

Reply UPDATE row review, không INSERT một review mới. False được servlet xử lý error=notfound, khác field toggle bỏ boolean. JSP escape nội dung kể cả trong textarea; escape output khác sanitize lúc lưu. DB load lỗi: ManageReviewsServlet503/loadFailed/error, không nói “không có review” chỉ vì fallback empty.

### D2. 10 phút: chỉ đúng chat hiện tại, đừng học nhầm bản cũ

Dựa README mới: luồng chính **/chat-friends, /chat-api, friend_messages**, không phải chỉ nhánh ChatServlet cũ/chat_messages.

Mở [ChatApiServlet.java](../../src/main/java/com/sportify/controller/chat/ChatApiServlet.java), tìm sendFriendMessage; [ChatService.java](../../src/main/java/com/sportify/service/ChatService.java), cùng method; [ChatDAO.java](../../src/main/java/com/sportify/dao/ChatDAO.java), saveFriendMessage; [pages/chat-friends.js](../../src/main/webapp/assets/js/pages/chat-friends.js), startPolling.

```text
JSP mở khung chat
 → JS fetch GET /chat-api?action=getFriends
 → servlet → ChatService → ChatDAO JDBC
 → JSON → JS render

Gửi: JS POST action=sendFriendMessage,receiverId,text,time
 → servlet lấy người gửi từ currentUser/session
 → service.sendFriendMessage
 → DAO.saveFriendMessage → friend_messages
```

- JSON là dữ liệu API, không phải JSP/HTML. Không mọi response đều là HTML.
- getResultList là query JPA của sân; chat JDBC dùng executeQuery/executeUpdate. Đừng ghép hai API làm một.
- startPolling setInterval(...,2000): browser hỏi lại mỗi2giây, **không WebSocket**. HTTP polling không bảo đảm tin tức thời tuyệt đối.
- Chat dịch vụ mẫu action getConversations/sendMessage trả410; legacy ChatServlet /chat-live và chat_messages còn source. Không dùng lời giải cũ “mọi chat giả” hay “mọi chat tin senderName client”.
- README ghi retention tối đa10tin/cặp khi gửi tuần tự; không nói lưu vĩnh viễn đầy đủ lịch sử hoặc có online status thật. Đừng tự nhận toàn bộ chat mới là tác phẩm cá nhân nếu nhóm đã ghép lại.

### D3. 7 phút: phần của nhóm và điều chưa làm

Đọc README mục **Những điểm dễ nhầm**. Nhớ có mục đích, không đọc BookingDB từ đầu:

- Booking thành viên khác. Dashboard hiện gọi BookingDB và có dữ liệu/stats pathways; **không nói mọi booking/metric còn mock như bản cũ**. Có source persistence không tự chứng minh runtime đang chạy.
- Nếu hỏi liên kết: sân sports_fields được bookings tham chiếu; khách gửi yêu cầu, owner xử lý; PENDING chờ duyệt, CONFIRMED/COMPLETED chiếm lịch theo README. Muốn giải thích locking sâu phải mở đúng BookingDB, không nhận đã tự viết.
- CustomerOverview từ GROUP BY review.customerName, không danh sách định danh mọi khách booking.
- Thuê gear/trang phục/PT đã tắt theo README. Chưa payment gateway, upload avatar, khách tạo review hoặc online status thật theo tài liệu hiện tại. Không giới thiệu chúng là tính năng đã chạy.
- Layout sidebar có include .jspf; scriptlet `<%=...%>` khác EL `${...}` và JSTL `<c:...>`. JS template literal `${...}` không tự chứng minh EL/JSTL server. Không tự tuyên bố mọi nội dung C08/09/10 đều áp dụng; chỉ file thật nếu hỏi.

**Đạt chặng D khi:** chỉ đúng reply mutation/owner predicate, phân biệt API JSON với JSP, chat mới với legacy, và không nhận phần người khác.

## E. 40 phút — VẤN ĐÁP THỬ, KHÔNG CHỈ ĐỌC

### Cách chạy khối này

- 5 phút: kể tổng quan và phần đóng góp, không đọc đoạn mẫu.
- 20 phút: chọn các câu dưới, tự nói20–45giây/câu, mở source chỉ vị trí. Được tra tên, nhưng phải giải thích dữ liệu đi đâu.
- 10 phút: sửa tối đa3 lỗi hiểu quan trọng; ưu tiên request/session/DB, form→POST→commit, owner/role.
- 5 phút: nói lại một flow không nhìn guide. Có thể nhắn tôi `/code` hoặc `/flow` để hỏi từng câu, chấm dựa câu trả lời thật.

### 16 câu tập trung và tiêu chí tự kiểm

| Câu hỏi | Cần thể hiện được — không học thuộc nguyên văn |
|---|---|
| 1. Sportify làm gì; em làm phần nào? | Scope mới theo README, phần cá nhân theo thực tế, booking thành viên khác |
| 2. /owner/fields vào đâu? | Annotation mapping URL, tên class ManageFieldsServlet, method doGet |
| 3. Lấy sân của owner nào? | Session User→OwnerAccess.ownerId→query owner predicate; không input owner tùy ý |
| 4. Query sân nằm đâu, chạy ở dòng nào? | SportFieldDB.findByOwnerId: JPQL string/createQuery/setParameter/getResultList; không gọi getter là SELECT |
| 5. fields là gì? Null khác rỗng? | List objects, attr key khác variable; no matches empty list, attr vắng null, lỗi có thể exception |
| 6. Danh sách sang JSP thế nào? | setAttribute→forward cùng request→getAttribute/cast→loop→getter→HTML |
| 7. Getter khác setter và getAttribute? | Object property read/write khác scope lookup; không mặc định DB write |
| 8. Model map bảng nào? PK/FK đâu? | SportField @Entity/@Table/@Id/IDENTITY/@Column; Review ManyToOne; ownerId chưa mapping ManyToOne User |
| 9. Form thêm sân đi đâu? | action/method/name, doPost/getParameter, validation, setters, insert |
| 10. Đoạn nào lưu thật? | persist + transaction commit, rollback/finally; không chỉ JS/setAttribute/setter |
| 11. Vì sao redirect sau POST? | PRG/GET mới/refresh, attrs request cũ mất; không tự idempotency hay CSRF |
| 12. Làm sao không sửa sân owner khác? | Role filter + session owner + findByIdAndOwnerId + DAO check; hidden ID không quyền |
| 13. DB connect/SQL ở đâu? | DatabaseConfig/DBContext vs DBUtil/persistence; JDBC ? vs JPQL :ownerId |
| 14. Review reply lưu vào đâu? | ownerReply/repliedAt UPDATE reviews, owner predicate, affected rows, PRG |
| 15. Chat dùng gì? | session sender ID, service/DAO friend_messages, JSON/fetch, polling không WebSocket |
| 16.404/403/500/503 phân biệt thế nào? |404 route/resource hoặc missing field;403 quyền/token;500 lỗi server;503 review load fallback; chỉ root cause khi có log |

### Cách trả lời khi chưa biết

Dùng cấu trúc: **mục đích → file/method → input → xử lý → output → giới hạn**. Không cần nhét đủ sáu ý vào mọi câu nhỏ.

Khi cô hỏi sâu phần chưa nắm: “Đoạn này thuộc phần tích hợp/đặt sân của thành viên khác. Em hiểu nó gọi … và ảnh hưởng …; chi tiết … em chưa nắm chắc, em xin mở đúng method kiểm tra.” Đừng lấp khoảng trống bằng API hay tính năng tưởng tượng.

## F. 25 phút — CHỐT DEMO VÀ TỜ TRA NHANH

### 10 phút đầu: một chuỗi demo gọn, trên env được phép

Không cần demo mọi trang. Đây là **kịch bản bạn tự thực hiện sau preflight**, chưa được guide kiểm chứng:

1. Mở browser đúng app/context; đăng nhập owner của bạn (không chiếu password). Không có tài khoản OWNER thì ghi blocker, không tự sửa role DB khi chưa được phép.
2. Mở danh sách sân; chỉ mapping/query/request/JSP ở source.
3. Trên DB demo được phép: chọn thêm **hoặc** sửa một sân thử; Network POST→redirect→GET; refresh rồi SELECT row để chứng minh lưu. Nói “lưu thành công” chỉ sau readback.
4. Đổi ACTIVE/INACTIVE nếu được phép, đối chiếu DB. Không gọi đây là Delete.
5. Nếu còn thời gian: một reply review thử; không bắt buộc live chat/BookingDB phức tạp.
6. Chỉ khác biệt JavaScript UI với backend persistence bằng form/action/DAO, không giả mọi JS là dữ liệu mất sau refresh.

**Không chỉnh sản phẩm trong guide.** Nếu Tomcat/DB chưa chạy, giới hạn preflight và ghi lỗi; dùng source flow + chứng cứ cũ có chú thích đúng, không nói screenshot cũ là live. Đừng dành hết25phút cài lại môi trường. Không tắt DB để tạo lỗi ngay trước thi.

### 5 phút: giới thiệu bằng lời của mình

Khung60giây, không bản văn học thuộc:

- Nhu cầu: tìm/đặt sân và owner quản lý; cộng đồng/chat theo scope mới.
- Stack: Java17, Servlet/JSP, Tomcat11, MavenWAR, PostgreSQL; JPA và JDBC cùng tồn tại.
- Phần bạn trực tiếp làm: dashboard/fields model&DB access/add/edit/status, các phần chat/review bạn thực sự tham gia. Không nhận Booking người khác, không nhận mọi thay đổi bản tích hợp.
- Một flow minh họa bạn giải thích được.
- Một giới hạn thật thay vì tuyên bố hoàn hảo.

### 5 phút: mở sẵn tab theo thứ tự

README → ManageFieldsServlet → SportFieldDB → SportField → dashboard.jsp → CreateFieldServlet → OwnerAccess/OwnerAccessFilter → DatabaseConfig/DBUtil. ReplyReviewServlet/ReviewDB ở nhóm phụ. Browser+DB client+log ở cửa sổ khác. Không mở database.properties có secret trên màn chiếu.

### 5 phút cuối: kiểm tra checklist rồi dừng nạp

- [ ] Tôi tự kể được GET list mà không nhìn câu mẫu.
- [ ] Tôi trace được một POST từ name input đến transaction/redirect.
- [ ] Tôi chỉ đúng getter/setter/getParameter/getAttribute và phân biệt chúng.
- [ ] Tôi nói đúng owner từ session, role khác ownership.
- [ ] Tôi tìm đúng config/JDBC/JPA/query và bảng sân.
- [ ] Tôi biết bản chat hiện tại, không học nhầm legacy.
- [ ] Tôi đã xác nhận app/DB demo hoặc ghi rõ blocker; không tự nói đã pass tests.
- [ ] Tôi không nhận Booking thành phần cá nhân; biết giới hạn hiện tại.

Ô nào chưa làm được là dữ liệu ôn yếu, **không đánh dấu chỉ vì đã đọc**. Nếu còn ít phút, ôn A/B/C trước, không mở mới Newsfeed/custom tags.

## TỜ TRA NHANH — mở mục này khi cô yêu cầu chỉ code

| Từ/câu cần tìm | Ctrl+P file → Ctrl+F symbol |
|---|---|
| Mapping, class, doGet | ManageFieldsServlet.java → @WebServlet / doGet |
| List sân, JPQL/bind/execute | data/SportFieldDB.java → findByOwnerId / setParameter / getResultList |
| Data Java→JSP | ManageFieldsServlet.java → setAttribute / forward; owner/dashboard.jsp → getAttribute |
| List null/rỗng | dashboard.jsp → fields == null; SportFieldDB → results.isEmpty (lookup riêng) |
| Getter và setter | model/SportField.java → getFieldName / getStatus / setFieldName |
| Entity/table/PK/column | SportField.java → @Entity / @Table / @Id / @Column |
| Loop, JSP expression, escape | dashboard.jsp → activeFieldCount / getFieldName / escapeHtml |
| Form name/action/method | dashboard.jsp → data-field-form; JS→openFieldModal |
| Form processing/validation | CreateFieldServlet.java → doPost / getParameter / required / isAfter |
| Write/transaction | SportFieldDB.java → insert / persist / commit / rollback |
| Edit ownership/dirty checking | UpdateFieldServlet→findByIdAndOwnerId; SportFieldDB→update / currentField |
| Toggle không DELETE | ToggleFieldStatusServlet.java → doPost; SportFieldDB→toggleStatus |
| User session | LoginServlet.java → setAttribute; BaseServlet→SESSION_USER; OwnerAccess→getSession(false) |
| OWNER/token check | OwnerAccessFilter.java → isOwner / Csrf.isValid / chain.doFilter |
| Kết nối/cấu hình | DatabaseConfig.java → setting/getJpaProperties; DBContext→getConnection; DBUtil→getEntityManagerFactory |
| PU validate/schema | persistence.xml → sportifyPU / validate; database/init_all_postgresql.sql |
| JDBC PreparedStatement | dao/UserDAO.java → checkLogin / prepareStatement / setString / executeQuery |
| Review filter/reply | ManageReviewsServlet→parseRating; ReplyReviewServlet→ownerReply; ReviewDB→saveOwnerReply |
| Chat/API/polling | controller/chat/ChatApiServlet→sendFriendMessage; ChatDAO→saveFriendMessage; pages/chat-friends.js→startPolling |
| URL theo app context | Servlet getContextPath; JSP contextPath; không hardcode host-root |
| Maven/Tomcat/Java | pom.xml → compiler.source / packaging / provided; không xem target là source |
| Slide EL/JSTL/custom tags | Phân biệt scriptlet/expression/EL/JS templates; chỉ implementation thật, không nhận mọi slide đã dùng |

## Nhắc cuối: 6 nhầm lẫn phải tránh

1. @WebServlet là annotation; `/owner/fields` là URL; ManageFieldsServlet là class; doGet là method.
2. Chuỗi nhãn `"fields"` không phải biến fields. request/session storage không phải DB persistence.
3. Getter đọc object, setParameter bind điều kiện, setter gán object — không cái nào riêng lẻ đồng nghĩa đã query/commit.
4. SportField/ownerId là entity/property Java; sports_fields/owner_id là table/column SQL.
5. Bản này đã có source login/role/CSRF/locking/booking DB pathways; không dùng mô tả demo1 và mock toàn bộ của bản cũ. Nhưng source có code vẫn không phải chứng cứ runtime pass.
6. Bạn có4giờ **ôn có chọn lọc**, không4giờ để chứng minh hiểu toàn bộ source. Chỉ nói chắc phần đã trace và tự giải thích được.
