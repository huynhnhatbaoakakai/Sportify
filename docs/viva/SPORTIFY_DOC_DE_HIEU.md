# SPORTIFY — ĐỌC ĐỂ HIỂU VÀ TỰ GIẢI THÍCH CODE

Tài liệu đọc liền mạch • Dành cho người mới • Không cần trả lời câu hỏi giữa các phần

**Bản source sử dụng:** C:\Users\20huy\Desktop\workplace\Sportify-backup\Sportify

**Cách dùng:** đọc một mục, mở đúng file ghi ở cuối mục, tìm tên method bằng Ctrl+F và xem đoạn tương ứng. Không cần thuộc nguyên văn. Khi đọc xong một luồng, tự nói lại dữ liệu đến từ đâu và đi đâu. Không sửa source để luyện. Đây là tài liệu dựa trên README và source đã kiểm tra, không phải chứng nhận mọi chức năng đã chạy hoặc mọi test đã pass.

## 1. Trước hết, Sportify hiện tại là gì?

Theo README hiện tại, Sportify tập trung vào tìm/đặt sân, quản lý sân, xác nhận đơn, lịch sân, chat giữa tài khoản và Newsfeed. Thuê gear, trang phục và PT đã tắt; không dùng phần giới thiệu cũ để nói chúng đang hoạt động. Thanh toán online, online status thật và khách tạo review chưa được mô tả là đã triển khai.

Stack hiện tại: Java 17, Servlet/JSP, Maven WAR, Tomcat 11, PostgreSQL. Source có cả JDBC và JPA/Hibernate. Không nói toàn project chỉ dùng một trong hai.

Phần bạn khai báo trực tiếp thực hiện chủ yếu là Owner Dashboard, quản lý sân, model/database access sân, thêm/xem/sửa/đổi trạng thái, cùng các phần chat/review bạn thực sự tham gia. Booking do thành viên khác phụ trách. Đọc được BookingDB để hiểu tích hợp không đồng nghĩa đã tự viết toàn bộ BookingDB. Bản gần final có thể chứa thêm code tích hợp từ nhóm; chỉ nhận đúng phần có bằng chứng.

## 2. Browser, server, database — ba vai trò khác nhau

Browser là Chrome/Edge: nhận thao tác và hiển thị giao diện. Server chạy ứng dụng: nhận yêu cầu, kiểm tra, gọi truy cập dữ liệu, chuẩn bị kết quả. PostgreSQL lưu các bản ghi. Với luồng Servlet/JSP đang học, browser không tự kết nối PostgreSQL để SELECT sân.

HTTP request là yêu cầu browser gửi tới server. HTTP response là phản hồi server gửi lại, gồm status, headers và có thể có body HTML hoặc JSON. Không phải response nào cũng chứa trang HTML: API chat trả JSON cho JavaScript.

```text
Browser → HTTP request → Server
Server → truy vấn → PostgreSQL
Server ← dữ liệu ← PostgreSQL
Browser ← HTTP response ← Server
```

Tomcat là servlet container, không phải tên class xử lý nghiệp vụ của bạn. Tomcat chuyển request tới servlet thích hợp. Servlet là class Java xử lý request HTTP; JSP là template tạo HTML ở server. Browser nhận HTML kết quả, không chạy Java source bên trong JSP.

## 3. Tìm code trong project mà không bị lạc

README là mục lục tìm đường, không phải thứ phải thuộc hết. Controller nhận request; model mô tả dữ liệu; data/dao truy cập database; filter kiểm tra trước khi cho đi tiếp; util chứa helper; config/resources chứa cấu hình; webapp chứa JSP và tài nguyên giao diện.

| Bạn cần tìm | Vị trí |
|---|---|
| URL do class nào xử lý | src/main/java/com/sportify/controller/ và annotation @WebServlet |
| Object sân, getter/setter, mapping bảng | src/main/java/com/sportify/model/SportField.java |
| Query của dashboard owner | src/main/java/com/sportify/data/SportFieldDB.java |
| Kết nối/cấu hình database | config/DatabaseConfig.java, config/DBContext.java, data/DBUtil.java, resources/META-INF/persistence.xml |
| JSP owner | src/main/webapp/owner/dashboard.jsp, reviews.jsp, customers.jsp |
| JSP lịch owner | src/main/webapp/WEB-INF/views/owner/calendar.jsp |
| Tương tác modal sân | src/main/webapp/assets/js/owner-dashboard.js |

Có cả SportFieldDB trong data và SportFieldDAO trong dao. Luồng dashboard đang đọc dùng SportFieldDB/JPA; không học nhầm file chỉ vì tên giống. dao và data không phải hai bước bắt buộc chạy nối tiếp. Không đọc target như source: đó là output build, có thể khác code hiện tại.

Cách mở: Ctrl+P tìm tên file; Ctrl+F tìm method. Nếu Ctrl+click/F12 trong JSP không hoạt động, cứ mở thủ công. Các đường dẫn bắt đầu controller/model/data/util/config trong phần dưới đều nằm dưới src/main/java/com/sportify/; đường dẫn web được ghi rõ.

## 4. Một request xem sân đi vào đâu?

Mở controller/ManageFieldsServlet.java. Code mapping:

```java
@WebServlet({"/owner/fields", "/owner/bookings"})
public class ManageFieldsServlet extends HttpServlet {
```

@WebServlet là annotation khai báo mapping. Hai URL là /owner/fields và /owner/bookings. Tên class là ManageFieldsServlet. Không nói class được mapping tới “@WebServlet”: annotation là công cụ khai báo, các chuỗi URL mới là đường dẫn.

Với GET, cơ chế HttpServlet dispatch tới method doGet(request,response). request dùng đọc thông tin yêu cầu, session hoặc đặt dữ liệu cho view. response dùng thiết lập phản hồi, status, redirect. Các Filter bảo vệ URL có thể chặn trước khi servlet chạy; không suy thứ tự giữa các filter annotation khi chưa kiểm tra cấu hình.

GET thường để đọc/hiển thị; POST thường gửi thay đổi. Đây là cách thiết kế có chủ đích, không phải HTTP tự cấm người viết xử lý sai. Ví dụ source có logout/xóa lịch nhắc bằng GET: không biến chúng thành thực hành tốt chỉ vì có trong project. POST không tự mã hóa nội dung, bảo mật đường truyền cần HTTPS.

Servlet lifecycle cơ bản trong slide: init → service nhận/dispatch request → doGet/doPost → destroy khi container hủy servlet. Thường nhiều request dùng cùng servlet instance, vì vậy dữ liệu từng request nên local, không đặt vào biến instance mutable chung tùy tiện. Không cần override mọi lifecycle method để dùng servlet.

**Mở và tìm:** ManageFieldsServlet.java → @WebServlet, doGet.

## 5. Luồng xem danh sách sân: từ owner đến HTML

### 5.1. Ai đang xem?

Trong ManageFieldsServlet:

```java
List<SportField> fields =
        SportFieldDB.findByOwnerId(com.sportify.util.OwnerAccess.ownerId(request));
```

Đọc từ trong ra ngoài: OwnerAccess lấy ID tài khoản owner hiện tại → đưa ID vào findByOwnerId → nhận danh sách object SportField → biến fields giữ danh sách.

OwnerAccess.currentUser(request) tìm session bằng getSession(false); không có thì không tự tạo session mới. Nếu có, lấy session.getAttribute("user") và ép kiểu User. OwnerAccess.ownerId kiểm user tồn tại và isOwner(), rồi trả user.getId(). Getter getId đọc object User trong memory, không SELECT users lần nữa.

Bản mới không dùng DEMO_OWNER_ID=1 tại call-site này. ID của owner không lấy từ ô input tùy ý. Quyền OWNER và điều kiện ownerId khác nhau: role cho vào chức năng owner; ownerId giới hạn object nào được xem/sửa.

**Mở:** util/OwnerAccess.java → currentUser, ownerId.

### 5.2. Danh sách sân được truy vấn ở đâu?

Trong data/SportFieldDB.java → findByOwnerId:

```java
String jpql =
        "SELECT field FROM SportField field " +
        "WHERE field.ownerId = :ownerId " +
        "ORDER BY field.createdAt DESC";
```

Đây là JPQL: dùng tên entity SportField và property ownerId/createdAt. field là alias trong query, không phải biến fields bên servlet. WHERE chỉ lấy sân thuộc owner truyền vào; DESC xếp mới trước.

```java
TypedQuery<SportField> query =
        em.createQuery(jpql, SportField.class);
query.setParameter("ownerId", ownerId);
return query.getResultList();
```

Chuỗi jpql mới mô tả câu hỏi. createQuery tạo object truy vấn có kiểu kết quả SportField. setParameter gắn giá trị lọc cho :ownerId, không đổi chủ sở hữu của sân. getResultList thực hiện lấy danh sách. finally em.close đóng EntityManager; finally vẫn chạy khi try có return. Không có sân phù hợp là list rỗng, query lỗi có thể ném exception, không mặc định null.

EntityManager là công cụ JPA làm việc với entity trong một persistence context. Đóng nó không tắt PostgreSQL. EntityManagerFactory là factory dùng chung để tạo EM, không phải chính danh sách sân.

### 5.3. Servlet chuyển dữ liệu cho JSP thế nào?

```java
request.setAttribute("fields", fields);
request.getRequestDispatcher("/owner/dashboard.jsp")
        .forward(request, response);
```

setAttribute có hai đối số: "fields" là NHÃN CHUỖI; fields là BIẾN DỮ LIỆU. Đặt vào request không INSERT/UPDATE database.

Forward chuyển xử lý bên trong server tới JSP với cùng request. Attribute còn, không bắt browser gửi request mới, URL không tự thành dashboard.jsp.

Trong src/main/webapp/owner/dashboard.jsp:

```java
List<SportField> fields =
        (List<SportField>) request.getAttribute("fields");
```

getAttribute lấy object theo nhãn trong request, không truy vấn DB lần nữa. Vì trả Object tổng quát nên có casting List<SportField>. Casting không tạo list từ dữ liệu sai kiểu. Biến fields ở JSP là biến riêng, dữ liệu đi qua request chứ không phải do tên biến hai bên trùng nhau.

### 5.4. Null và danh sách rỗng không giống nhau

Null: không có object danh sách để dùng. List rỗng: có object danh sách, nhưng không chứa sân nào. Tưởng tượng không có hộp so với có hộp trống.

JSP kiểm fields==null rồi redirect controller để nạp lại dữ liệu. Nếu Servlet đã gắn list rỗng, fields==null là sai, không đi vào nhánh đó. Vòng lặp list rỗng chạy không lượt nào. Không dùng nhánh null để kết luận owner không có sân.

### 5.5. Getter và hiển thị

```java
for (SportField field : fields) {
    if ("ACTIVE".equalsIgnoreCase(field.getStatus())) {
        activeFieldCount++;
    }
}
```

fields là cả danh sách, field là một object ở lượt hiện tại. getStatus đọc status trong object. So sánh ACTIVE thì tăng biến đếm. Khối này không đổi status và không query từng sân.

```java
public String getStatus() {
    return status;
}
```

Getter là method đọc property object. Tương tự getFieldName lấy tên sân. Khi JSP dùng <%= activeFieldCount %>, đó là JSP expression xuất giá trị vào HTML. escapeHtml(field.getFieldName()) lấy tên, encode ký tự HTML rồi xuất. Browser nhận HTML kết quả; không gọi getter Java.

**Câu chuyện đầy đủ:** GET /owner/fields → filter → ManageFieldsServlet.doGet → OwnerAccess lấy owner → SportFieldDB.findByOwnerId/query → List< SportField > → request.setAttribute → forward dashboard.jsp → getAttribute/cast → loop/getter → HTML.

## 6. Model, bảng và các loại ID

Mở model/SportField.java:

```java
@Entity
@Table(name = "sports_fields")
public class SportField implements Serializable {
```

@Entity đánh dấu JPA entity. @Table nối class tới bảng. Mapping mô tả cách dữ liệu được đọc/ghi, không tự chạy query chỉ vì annotation xuất hiện. Serializable hỗ trợ tuần tự hóa object; không phải thứ tự động lưu object vào PostgreSQL.

```java
@Id
@GeneratedValue(strategy = GenerationType.IDENTITY)
@Column(name = "field_id")
private Long fieldId;
```

fieldId định danh sân, @Id là khóa entity, cột tương ứng field_id là PK theo schema. PK không trùng và không NULL. IDENTITY dùng ID do database sinh; schema phải tương thích, không bảo đảm số ID liên tục không có khoảng trống.

ownerId là ID chủ sở hữu, không phải PK của SportField. Một owner có nhiều sân cùng ownerId nhưng fieldId khác nhau. Trong model này ownerId là property số, không có @ManyToOne tới User.

@Column(name="field_name") private String fieldName: fieldName tên Java, field_name tên cột SQL. Getter đọc fieldName; setter setFieldName gán property object. Gọi setter riêng lẻ không chứng minh DB đã commit.

Review.field có @ManyToOne tới SportField qua field_id: nhiều đánh giá thuộc một sân. Foreign key liên kết bản ghi được tham chiếu; không phải mọi biến có đuôi Id đều tự trở thành FK chỉ vì tên. Đọc schema thực khi cần khẳng định constraint. BigDecimal dùng cho tiền, tránh dùng double để thay thế tùy tiện.

**Mở và tìm:** model/SportField.java → @Id, @Column, getFieldName, setFieldName; model/Review.java → ManyToOne. DDL ở database/init_all_postgresql.sql, không tự chạy lúc ôn.

## 7. Thêm sân: khác hoàn toàn việc chỉ đổi giao diện

### 7.1. Form gửi gì?

Mở src/main/webapp/owner/dashboard.jsp, tìm data-field-form. Form method=post, action tới /owner/fields/create; JavaScript đổi action thành /owner/fields/update khi sửa.

Input name="fieldName" khiến tên parameter gửi lên là fieldName. id="field-name" phục vụ label/DOM, không thay name. Input hidden fieldId/CSRF vẫn là dữ liệu client có thể sửa; hidden không là cơ chế authorization.

owner-dashboard.js → openFieldModal reset hoặc prefill form, đổi action và hidden ID. JavaScript hỗ trợ UI; form hợp lệ gửi POST HTML thông thường. Không có nghĩa JS tự INSERT sân. Client required/min/max thuận tiện nhưng bypass được; server phải validate.

### 7.2. Servlet nhận và kiểm tra

Mở controller/CreateFieldServlet.java → doPost. getParameter lấy string từ form; required kiểm null/blank rồi trim; BigDecimal parse giá, LocalTime parse giờ. Kiểm whitelist môn, giá>0, giờ đóng sau mở. Status khác INACTIVE quy ACTIVE.

Sau đó new SportField và các setter gán name/type/address/price/hours/status. Owner được lấy từ OwnerAccess.ownerId(request), không tin owner ID client nhập.

```java
SportField field = new SportField();
field.setOwnerId(com.sportify.util.OwnerAccess.ownerId(request));
field.setFieldName(fieldName);
```

Đến đây mới có object Java. Để ghi DB còn gọi SportFieldDB.insert(field).

### 7.3. Transaction là gì?

Trong SportFieldDB.insert:

```java
transaction.begin();
em.persist(field);
transaction.commit();
```

Transaction gom thao tác thành một giao dịch. Begin mở giao dịch; persist đưa entity mới vào persistence context để INSERT; commit xác nhận thay đổi. Nếu lỗi, rollback hoàn tác giao dịch và finally đóng EM. SQL có thể phát trước commit (đặc biệt IDENTITY), nhưng chưa commit không được gọi là đã lưu bền vững thành công.

SportField.beforeInsert gán createdAt/updatedAt qua @PrePersist; beforeUpdate cập nhật updatedAt qua @PreUpdate. Callback thời gian không thay validation request.

### 7.4. Redirect sau POST để làm gì?

Servlet gửi redirect về /owner/fields. Browser tạo GET mới, Servlet đọc DB và render lại. Đây là POST/Redirect/GET (PRG).

Forward: cùng request, attribute còn. Redirect: browser request mới, request attribute cũ không tự đi theo. Refresh sau PRG lặp GET, tránh tự gửi lại POST thành công. PRG không tự giải quyết double submit, CSRF hoặc transaction race.

Form hiện không có description/imageUrl dù model có thuộc tính; không tự nhận upload ảnh. Validation còn giới hạn: frontend giá min/step1000 nhưng server>0, server chưa kiểm mọi maxlength, giờ qua nửa đêm chưa hỗ trợ với close>open. Không cần sửa nóng những chỗ này trong giờ ôn.

## 8. Sửa sân và bật/tắt trạng thái

UpdateFieldServlet nhận fieldId rồi findByIdAndOwnerId(fieldId, sessionOwnerId). Không có sân khớp thì404. Đây là kiểm quyền theo object: biết fieldId không có nghĩa được sửa sân đó.

Sau validation/setters, SportFieldDB.update mở EM mới, find currentField có PESSIMISTIC_WRITE, kiểm owner lại, đổi thuộc tính trên managed entity rồi commit. Dirty checking giúp Hibernate UPDATE khi entity managed thay đổi, không cần em.merge cho currentField. Object trả từ query trước đã detached khi EM đóng; DAO tìm lại entity trong EM mới.

ToggleFieldStatusServlet gọi SportFieldDB.toggleStatus. DAO khóa sân, kiểm owner, ACTIVE đổi INACTIVE và ngược lại rồi commit. Đây là đổi trạng thái, không DELETE sân. Không nói chức năng đã có Delete đầy đủ hoặc tự hủy mọi booking khi ngưng sân.

Hạn chế hiện tại: Servlet update/toggle chưa dùng boolean DAO trả về, nên success query trong URL không tự chứng minh có row thay đổi. DAO vẫn có ownership check; báo thành công sai không đồng nghĩa sân owner khác đã bị sửa.

**Mở:** controller/UpdateFieldServlet.java → findByIdAndOwnerId; data/SportFieldDB.java → update/toggleStatus; controller/ToggleFieldStatusServlet.java → doPost.

## 9. Session, đăng nhập và quyền — bản mới không còn cổng password demo

LoginServlet.doPost gọi UserDAO.checkLogin(email,password). UserDAO dùng PreparedStatement tìm user, PasswordHasher.verify kiểm mật khẩu. Hợp lệ: LoginServlet hủy session cũ nếu có, tạo/lấy session mới lưu object user, redirect owner hoặc home. Có source login không tự chứng minh runtime đã được kiểm thử đầy đủ.

Session giúp giữ state server qua nhiều request của một phiên. Request attribute dùng trong request hiện tại, giữ qua forward. Session không phải database: đóng browser không phải lệnh DELETE dữ liệu DB; cũng không bảo đảm server lập tức invalidate session.

OwnerAccessFilter bảo vệ /owner/*: không user→login; không OWNER→403; POST token sai→403; đủ điều kiện→chain.doFilter đi tiếp. Role khác ownership: OWNER không có nghĩa được sửa sân mọi người. Truy vấn/DAO vẫn giới hạn owner từ session.

CSRF token là giá trị session/form server kiểm tra để giảm request thay đổi state giả mạo. Token không thay authentication, authorization, validation hay SQL parameter binding. Chỉ tạo token không tự bảo vệ mọi route; phải có nơi kiểm.

HTML output encoding như Html.escape/escapeHtml khiến ký tự đặc biệt hiển thị như văn bản trong context HTML phù hợp; không nhầm với SQL injection protection. PreparedStatement không ngăn script chạy ở browser nếu output dùng sai cách.

**Mở:** controller/auth/LoginServlet.java; util/OwnerAccess.java; filter/OwnerAccessFilter.java; util/Csrf.java. Không nhận đây đều là phần tự viết nếu nhóm đã tích hợp.

## 10. “Kết nối SQL ở đâu?” — phải tách cấu hình, khởi tạo và truy vấn

| Việc | File/method cần chỉ |
|---|---|
| Đọc URL/user/password | config/DatabaseConfig.java: setting/getJdbcUrl/getUsername/getPassword |
| Tạo JDBC Connection | config/DBContext.java: getConnection → DriverManager.getConnection |
| Tạo JPA EntityManagerFactory | data/DBUtil.java: getEntityManagerFactory → Persistence.createEntityManagerFactory |
| Persistence unit/entities/provider | src/main/resources/META-INF/persistence.xml |
| Query sân qua JPA | data/SportFieldDB.java: findByOwnerId |
| SQL/JDBC đăng nhập | dao/UserDAO.java: checkLogin |
| Đóng factory khi undeploy | config/AppLifecycle.java: contextDestroyed |

DatabaseConfig ưu tiên JVM properties → environment → database.properties local → fallback. File local chứa secret không nên chiếu màn hình. URL mặc định sporttrent không chứng minh actual URL không bị override.

JPA là specification/API ánh xạ entity, Hibernate là implementation, JDBC driver PostgreSQL là cầu nối phía dưới. DBUtil tạo factory lazy/tái sử dụng, DAO tạo EntityManager local; không giữ một EntityManager static cho mọi request.

persistence.xml dùng hibernate.hbm2ddl.auto=validate: kiểm schema đã có, không tự tạo đầy đủ bảng. DDL/migration nằm database/. Maven pom.xml khai báo Java17, WAR, dependencies; Servlet API scope provided vì container cung cấp khi chạy. Tomcat không tự là full JPA provider.

JDBC UserDAO có SQL dùng bảng public.users và placeholder ?, setString bind giá trị rồi executeQuery. JPA SportFieldDB có JPQL dùng entity SportField và :ownerId, setParameter rồi getResultList. Hai cách cùng tồn tại, không gọi cả hai là một API.

Parameter binding tách input giá trị khỏi cấu trúc câu query, giảm SQL injection khi dùng đúng. Nó không tự kiểm quyền đọc/sửa và không thay XSS escaping. UserDAO.checkLogin còn có nhánh nâng cấp password legacy chưa hash sau xác thực; đừng tự gọi mọi đăng nhập là read-only DB.

## 11. ĐỌC RIÊNG PHẦN TỰ XÁC NHẬN — phân biệt sân với đơn

### 11.1. Hai dữ liệu thuộc hai đối tượng khác nhau

| Thuộc tính | Đối tượng | Giá trị/ý nghĩa |
|---|---|---|
| autoApprove | Sân SportField | true/false: cài đặt tự xác nhận đơn mới |
| status | Đơn Booking | PENDING/CONFIRMED/...: trạng thái một đơn cụ thể |

**autoApprove KHÔNG có nghĩa là PENDING.** false là công tắc tắt; true là công tắc bật. PENDING là trạng thái của đơn đang chờ duyệt.

Bật tự xác nhận cũng không phải bật hoạt động sân. Sân còn có status ACTIVE/INACTIVE riêng. Một sân bật autoApprove nhưng INACTIVE vẫn không được tạo booking hợp lệ trong luồng đã đọc.

### 11.2. Hãy theo một ví dụ theo thời gian

1. Sân pickleball đang autoApprove=false. Khách A gửi đơn hợp lệ; đơn A được lưu PENDING.
2. Chủ sân bấm Bật tự xác nhận. Server lưu autoApprove=true cho SÂN. **Đơn A vẫn PENDING.**
3. Khách B gửi ĐƠN MỚI hợp lệ và không xung đột. Server đọc cài đặt hiện tại; đơn B được tạo CONFIRMED.
4. Đơn A không tự đổi vì công tắc đã bật. Chủ sân phải xử lý đơn cũ. PENDING theo quy tắc hiện tại chưa giữ lịch như CONFIRMED; nếu sau đó có xung đột, xác nhận thủ công phải kiểm tra lại.
5. Nếu chủ sân tắt lại chế độ, các đơn đã CONFIRMED không tự quay về PENDING. Cài đặt áp dụng khi tạo đơn mới, không quét đổi trạng thái mọi đơn cũ.

Đây là ví dụ minh họa semantics code, không phải dữ liệu hoặc thao tác mới đã chạy trên DB của bạn.

### 11.3. Từ nút bật đến database

Mở src/main/webapp/WEB-INF/views/owner/calendar.jsp, tìm name="enabled":

```jsp
<input type="hidden" name="enabled"
       value="<%= !field.isAutoApprove() %>">
```

isAutoApprove đọc trạng thái hiện tại; ! đảo boolean. Đang false→gửi string "true" để bật. Đang true→gửi "false" để tắt. Form POST /owner/fields/approval kèm fieldId/date/csrfToken. JSP chỉ chuẩn bị form; chưa lưu DB.

OwnerCalendarServlet.doPost lấy owner từ session, fieldId từ parameter và kiểm sân thuộc owner. Nhánh /owner/fields/approval đọc enabled string, chỉ chấp nhận "true"/"false", Boolean.parseBoolean chuyển boolean rồi gọi SportFieldDB.setAutoApproval.

DAO setAutoApproval: begin → find sân với PESSIMISTIC_WRITE → kiểm owner → nếu bật phải supportsAutoApproval → setAutoApprove(enabled) → commit. Lỗi rollback/finally close. **Chỉ update cài đặt sân, không duyệt Booking cũ.** Servlet lưu calendarMessage vào session rồi redirect calendar; GET sau lấy và remove message. Đây là ví dụ flash message qua redirect.

### 11.4. Vì sao chỉ bóng rổ và pickleball?

SportField.supportsAutoApproval:

```java
return "BASKETBALL".equals(sportType) || "PICKLEBALL".equals(sportType);
```

Đây là business rule trong code: chỉ hai loại này được bật. Giao diện mô tả sân thuê riêng; gym/hồ bơi giữ duyệt thủ công. Có thể giải thích hướng thiết kế là giữ riêng sân theo khung giờ, không tự nhận đã có mô hình capacity đầy đủ cho gym/hồ bơi.

### 11.5. Đơn mới được tự xác nhận ở đoạn nào?

Mở data/BookingDB.java, method createCustomerBooking, tìm boolean automatic:

```java
boolean automatic = field.isAutoApprove() && field.supportsAutoApproval();
booking.setStatus(automatic ? "CONFIRMED" : "PENDING");
booking.setConfirmationSource(automatic ? "AUTOMATIC" : "MANUAL");
```

&& nghĩa là cần cả hai điều kiện. Dấu ? : chọn giá trị theo điều kiện: true chọn vế trước dấu :, false chọn vế sau.

Trước đó server đã kiểm sân ACTIVE, thời gian hợp lệ trong giờ mở, bắt đầu tương lai, không giờ khóa, không đụng đơn CONFIRMED/COMPLETED và không yêu cầu PENDING trùng của chính khách. Không hợp lệ thì từ chối, không tự xác nhận mù quáng.

Transaction khóa sân PESSIMISTIC_WRITE trước khi kiểm tra để các thao tác cùng tuân thủ khóa này xử lý nối tiếp trên cùng sân. Đây không phải JavaScript giữ chỗ; không vì có một lock mà hứa mọi case concurrency đã test. Sau persist, BookingActivityDB.record ghi lịch sử/thông báo cùng giao dịch rồi commit.

### 11.6. Những câu không nên nói

- Sai: bật công tắc thì mọi PENDING cũ thành CONFIRMED. Đúng: chỉ xét khi tạo đơn mới.
- Sai: tự động là scheduler chạy nền liên tục. Đúng: quyết định ngay trong request tạo đơn hiện tại.
- Sai: tự xác nhận nghĩa hết giờ tự COMPLETED. Đúng: đây là bước khác, chủ sân hoàn thành khi đủ điều kiện.
- Sai: JavaScript thấy giờ trống là đủ. Đúng: server vẫn kiểm tra lại/transaction khi tạo đơn.
- Sai: autoApprove là trạng thái booking. Đúng: đó là cài đặt sân; status của Booking là dữ liệu riêng.

**Cách kể gọn bằng hiểu biết:** chủ sân lưu cài đặt qua approval endpoint; lúc khách tạo đơn mới, server kiểm tra và đọc cài đặt để chọn CONFIRMED/PENDING. Cài đặt không làm thay trạng thái đơn cũ. Booking là phần tích hợp thành viên khác, không tự nhận toàn bộ logic.

## 12. Review và chat: reuse các luồng đã hiểu

### 12.1. Review

GET /owner/reviews?rating=5 → ManageReviewsServlet.parseRating → ReviewDB list(owner,rating) và summary(owner) → request attrs → forward owner/reviews.jsp. List có filter, summary COUNT/AVG toàn owner không theo filter. JOIN FETCH field để JSP đọc fieldName sau EM.close.

Form reply POST /owner/reviews/reply với reviewId/ownerReply/rating và CSRF token. ReplyReviewServlet validate ID dương, reply nonblank/raw length<=2000; gọi ReviewDB.saveOwnerReply. Bulk JPQL UPDATE ownerReply/repliedAt có điều kiện reviewId và field thuộc owner. executeUpdate/commit, true nếu một row. Servlet dùng kết quả success/notfound, redirect giữ filter.

Reply sửa một review, không tạo review mới. Load DB lỗi có503/loadFailed/notice; đừng gọi fallback empty là không có dữ liệu. Chưa có luồng khách tạo review hay rule đã booking mới được review trong phần đã mô tả. CustomerOverview nhóm theo tên review, không định danh mọi khách booking.

### 12.2. Chat hiện tại và nhánh cũ

Luồng chính README hiện tại: /chat-friends mở JSP; JavaScript gọi /chat-api; ChatApiServlet → ChatService → ChatDAO → friend_messages. ChatApiServlet lấy sender từ currentUser/session, receiverId từ parameter. POST action=sendFriendMessage, service rồi saveFriendMessage ghi JDBC. API trả JSON, JS render DOM.

startPolling trong assets/js/pages/chat-friends.js gọi lại mỗi2giây. Đây là HTTP polling, không WebSocket và không hứa tức thời tuyệt đối. Theo README/code có retention tối đa10tin/cặp khi gửi tuần tự, không hứa lịch sử vĩnh viễn.

Nhánh ChatServlet /chat-live và ChatMessageDB/chat_messages còn legacy. Action chat dịch vụ mẫu trả410. Không dùng ví dụ cũ senderName hidden của nhánh legacy để mô tả nhánh chính. Cũng không tự nhận toàn bộ chat mới của nhóm là đóng góp cá nhân.

## 13. Các khái niệm dễ nhầm — đọc lại khi thấy lạc

| Khái niệm | Đọc bằng lời |
|---|---|
| Annotation @WebServlet | Khai báo URL nào vào class |
| Class ManageFieldsServlet | Đơn vị Java chứa logic nhận request |
| Method doGet/doPost | Khối xử lý HTTP method tương ứng |
| Parameter | Dữ liệu client gửi; getParameter thường nhận string |
| Request attribute | Object server gắn vào request để xử lý/view dùng tiếp |
| Session attribute | Object server giữ cho phiên qua nhiều request |
| Getter / setter | Đọc / gán property object Java |
| JPQL / SQL | Entity-property Java / table-column database |
| EntityManager / EMF | Công cụ thao tác JPA local / factory tạo công cụ |
| persist / commit | Đăng ký entity mới để ghi / xác nhận giao dịch |
| Forward / redirect | Cùng request xử lý nội bộ / browser request mới |
| List rỗng / null | Có danh sách0phần tử / không có object danh sách |
| autoApprove / Booking.status | Cài đặt sân / trạng thái một đơn |
| Frontend/backend | UI và request phía browser / xử lý quyền-dữ liệu phía server |

Model-View-Controller ở luồng owner: SportField và lớp dữ liệu thuộc phần model theo kiến trúc rộng, JSP là view, Servlet controller điều phối. Không phải mọi chức năng có lớp service; nghiệp vụ Booking chủ yếu ở BookingDB, chat có ChatService. Không viết SQL trong JSP giúp tách render khỏi query/transaction/quyền.

JSP expression <%=...%> khác EL ${...}; JavaScript template literal cũng có ${...} nhưng không tự chứng minh đang dùng EL server. JSTL là tag library, custom tags là chủ đề khác; không nhận mọi kiến thức slide đã áp dụng nếu chưa chỉ đúng implementation. Tài liệu cũ có thể mô tả bản trước; source hiện tại là nơi đối chiếu.

## 14. Khi gặp lỗi, giải thích và tìm đúng tầng

404: resource/route không tìm thấy, hoặc handler cố tình trả404 cho object không thuộc owner. Kiểm context path/deploy/mapping trước, không kết luận PostgreSQL lỗi chỉ vì404.

403: bị từ chối quyền hoặc CSRF trong những handler đang đọc. 500: lỗi xử lý server/JSP/query/exception chưa xử lý. 503: review handler có thể trả khi không tải được dữ liệu. Đọc log/root cause để phân biệt DB ngừng, credential sai, thiếu bảng/cột, sai datatype; không đoán từ tên trang.

Nếu CSS/JS404: kiểm URL/contextPath và asset path. Không coi thiếu icon/font là DB lỗi. File trong WEB-INF phải đi qua server forward, không truy cập trực tiếp URL như public JSP.

Không khởi chạy seed/migration/test ghi dữ liệu thật để chữa cháy khi chưa được phép. Có test source không nghĩa test đã pass; integration test có thể skip hoặc cần DB tạm. Không nói đã demo lưu thành công nếu mới thấy banner success mà chưa refresh/readback.

## 15. Một bài trình bày có thể tự ghép, không cần học thuộc

Nói theo thứ tự: hệ thống giải quyết nhu cầu gì → stack → phần cá nhân → một flow mình hiểu → giới hạn thật. Với mỗi câu code: mục đích, file/method, input, xử lý, output. Không cố nhét mọi thuật ngữ vào một câu.

Ví dụ khung phần sân: “Khi mở URL quản lý sân, servlet nhận GET, lấy owner từ session, gọi query lấy sân của owner. Danh sách được đặt vào request rồi forward JSP. JSP lấy attribute, lặp các object và gọi getter để render HTML. Khi thêm sân, form gửi POST, servlet validate rồi tạo entity, DAO persist trong transaction. Thành công redirect để GET đọc lại dữ liệu.” Đây là khung để hiểu và thay bằng lời của bạn, không bằng chứng bạn đã thành thạo.

Nếu được hỏi điều chưa chắc: chỉ giới hạn thật, mở method kiểm tra. Không nhận Booking của thành viên khác. Không nói “không biết gì” rồi dừng; có thể trình bày phần liên kết mình hiểu và tách chi tiết chưa nắm.

## 16. Bản đồ mở file nhanh

| Cô hỏi | Mở file → tìm |
|---|---|
| URL/method nào? | controller/ManageFieldsServlet.java → @WebServlet/doGet |
| List sân lấy đâu? | data/SportFieldDB.java → findByOwnerId/getResultList |
| Getter/setter ở đâu? | model/SportField.java → getStatus/getFieldName/setFieldName |
| Data sang JSP? | ManageFieldsServlet→setAttribute/forward; owner/dashboard.jsp→getAttribute |
| Đếm và xuất HTML? | dashboard.jsp → activeFieldCount/getFieldName |
| Form gửi gì? | dashboard.jsp → data-field-form/name/action/method |
| Thêm sân? | CreateFieldServlet → doPost/required; SportFieldDB → insert/persist/commit |
| Sửa đúng owner? | UpdateFieldServlet→findByIdAndOwnerId; SportFieldDB→update |
| Session user ở đâu? | LoginServlet→setAttribute; OwnerAccess→currentUser/ownerId |
| Chặn URL owner? | filter/OwnerAccessFilter.java → doFilter/isOwner/Csrf.isValid |
| Kết nối/SQL ở đâu? | DatabaseConfig→setting; DBContext→getConnection; DBUtil→getEntityManagerFactory |
| Bật tự xác nhận? | WEB-INF/views/owner/calendar.jsp→enabled; OwnerCalendarServlet→approval; SportFieldDB→setAutoApproval |
| Tự tạo trạng thái đơn? | data/BookingDB.java→createCustomerBooking/boolean automatic |
| Reply review? | ReplyReviewServlet→ownerReply; ReviewDB→saveOwnerReply |
| Chat đúng nhánh? | controller/chat/ChatApiServlet→sendFriendMessage; dao/ChatDAO→saveFriendMessage; JS→startPolling |

**Điểm dừng:** đọc hết rồi quay lại đúng một luồng bạn chưa kể được. Không cần chứng minh đã hiểu toàn source bằng cách nhớ mọi tên. Ưu tiên xem sân, form lưu sân, owner/session/database; riêng tự xác nhận nhớ rõ CÀI ĐẶT SÂN khác TRẠNG THÁI ĐƠN và ĐƠN CŨ không tự đổi.
