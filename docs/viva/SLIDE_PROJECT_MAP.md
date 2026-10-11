# Bản đồ toàn bộ slide ↔ source Sportify để ôn viva

## 1. Phạm vi, số lượng và giới hạn

Nguồn: [SLIDES_EXTRACT.json](SLIDES_EXTRACT.json). Đã đọc toàn bộ text trực tiếp, text Word nhúng và speaker notes, deduplicate các object representation có text trùng trong cùng slide. Python tính: **9 decks, 354 slide, 1.290 bản ghi embedded text, 262.983 ký tự embedded trước dedup, 15 slide có notes**.

Số slide là `slides[].number` theo **presentation order**, không XML ID, tên embedding hoặc số trang footer. Bảng125 nhóm nội dung bao phủ354/354 vị trí đúng một lần (kiểm sequence từng deck bằng Python). Có chỉ mục từng slide ở cuối để tìm cả cover/objectives/code continuation.

**Không đọc/không giả nội dung ảnh hoặc screenshot/diagram raster ở bước này. Một Visio Chapter01 slide6 chưa đọc text**: `ppt/embeddings/oleObject1.bin`, unresolved duy nhất; chỉ đọc được tiêu đề “Components of a web application”. Các ý giải thích khái niệm không phải OCR của hình. Nếu bước Visio/ảnh riêng bổ sung chứng cứ, cập nhật rõ nguồn mới.

**Chapter03/04/11/12 chưa cung cấp**: khoảng trống tài liệu, không suy đoán tên/nội dung hoặc nhận là đã học/đã áp dụng.

Đối chiếu POM và source src/main (Java/JSP/XML/JS), nhận diện tests hiện có. Không đọc .env hoặc công bố JDBC credentials/mã truy cập. “Áp dụng” là chứng cứ source cụ thể; “Chưa áp dụng” chỉ phạm vi source đọc; đề xuất không phải tính năng hiện có. **Bản đồ này là chứng cứ tĩnh, không kết quả build/HTTP/DB/browser/deployment runtime**.

### Kiểm kê

| Deck | Số slide thật |
|---|---:|
| Chapter 01 slides.pptx | 22 |
| Chapter 02 slides.pptx | 20 |
| Chapter 05 slides.pptx | 58 |
| Chapter 06 slides.pptx | 35 |
| Chapter 07 slides.pptx | 56 |
| Chapter 08 slides.pptx | 39 |
| Chapter 09 slides.pptx | 43 |
| Chapter 10 slides.pptx | 42 |
| Chapter 13 slides.pptx | 39 |
| **Tổng** | **354** |

### Chốt quan trọng khi viva

- **POM compiler source/target=17 (dòng18–19), WAR (10)**; không Java8 và không bằng chứng JVM runtime17. Cấu hình dependency: Jakarta Servlet API6.1.0 provided, Hibernate7.4.6.Final, PostgreSQL JDBC42.7.13 (34–51); không gọi là phiên bản mới nhất.
- Slide javax Servlet/JPA legacy khác source jakarta. W còn JavaEE descriptor4.0; cần kiểm thử container, không tự kết luận lỗi/thành công. Không sao chép JAR/import cũ mù quáng.
- DEMO_OWNER_ID và session OWNER_DEMO_AUTHORIZED chỉ demo, không account/role thật. login-process.jsp/register-process.jsp chỉ redirect, không user persistence; remember checkbox không xử lý cookie.
- Có JPA entity/DAO; chưa EL bean rendering/JSTL/custom tag. JChat isELIgnored=true; `${...}` JavaScript không phải EL server. Java if ≠ c:if; escapeHtml ≠ c:out.
- Session state server khác cookie ID browser; getSession source không thay browser evidence JSESSIONID. Logout removeAttribute không invalidate.
- Dirty checking managed entity khác bulk UPDATE; bulk DELETE không mặc định thực thi cascade/callback. Không lấy lời giản lược giáo trình làm bảo đảm hiện đại.

## 2. Sổ chứng cứ source

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

## 3. Bảng học theo chương

Cột nghĩa phục vụ giải thích viva; cột cuối phân biệt áp dụng thật, tương đương ý tưởng và đề xuất.

### Chapter01

| Slide thực | Nội dung nhóm | Nghĩa / điểm cần nói | Sportify: file/class/method hoặc Chưa áp dụng + đề xuất |
|---|---|---|---|
| 1–3 | Giới thiệu, mục tiêu nền tảng web Java | Nhận diện browser, web/app server, database; HTML mô tả nội dung còn HTTP vận chuyển request/response. | Áp dụng nền tảng: POM (WAR), CChat/JChat và DChat; không coi mục tiêu trên slide là tính năng đã hoàn thành. |
| 4–5 | Hai trang mẫu shopping cart | Ví dụ nhiều trang của cùng ứng dụng; chỉ đọc được tiêu đề, không suy đoán các control trong ảnh. | Chưa áp dụng giỏ hàng: Sportify có danh sách dịch vụ trong index.jsp nhưng không có Cart/LineItem backend; có thể đề xuất giỏ đặt sân. |
| 6 | Components of a web application; Visio nhúng | Chỉ xác nhận tiêu đề; một Visio Chapter01 slide6 chưa đọc text (`ppt/embeddings/oleObject1.bin`). | Chưa đủ chứng cứ để diễn giải sơ đồ này. Kiến trúc Sportify phải dựa source, không dùng nội dung Visio chưa đọc. |
| 7 | Static và dynamic web pages | Tài nguyên static được phục vụ trực tiếp; trang dynamic tạo response theo dữ liệu. Hình chưa đọc, ý nghĩa đối chiếu là kiến thức nền. | Áp dụng: assets/css/style.css, assets/js/app.js static; CFields.doGet → JFields render fields từ JPA là dynamic. |
| 8–9 | Servlet/JSP, JSF, Spring; Java SE/EE/JPA | Phân biệt API web, thư viện UI và API persistence; JPA không phải web framework. | Áp dụng Servlet/JSP + JPA Jakarta; chưa áp dụng JSF/Spring. POM source/target 17, không phải cấu hình Java 8 của giáo trình cũ. |
| 10–11 | Thành phần và kiến trúc Servlet/JSP | Tiêu đề sơ đồ đã đọc, không khẳng định chi tiết hình. Luồng ứng dụng thực cần tách presentation/business/data. | Áp dụng source: controller → data → model → JSP; CReviews.doGet gọi DReview rồi forward JReviews. |
| 12–13 | Cấu trúc document root, WEB-INF/classes/lib, META-INF | WEB-INF không truy cập trực tiếp bằng URL; Java/JAR trong WAR khác thư mục source Maven. | Áp dụng: src/main/webapp là web root; W; VAccess đặt dưới WEB-INF/views; src/main/java cho class; src/main/resources/META-INF/persistence.xml là cấu hình JPA, KHÔNG phải context.xml trên slide. |
| 14–15 | IDE NetBeans/Eclipse/IntelliJ | IDE hỗ trợ tạo/chạy/debug; screenshot không chứng minh IDE đang dùng. | Chưa xác minh IDE hiện tại; Sportify dùng bố cục Maven, có thể import vào các IDE này. |
| 16–17 | Tomcat, GlassFish, WildFly, Jetty, WebLogic, WebSphere | Phân biệt servlet container và full enterprise application server. | POM khai báo Servlet API provided, comment nói Tomcat cung cấp; không suy ra bản server đang chạy. Chưa xác minh runtime các server khác. |
| 18 | MySQL và các DB server khác | RDBMS lưu dữ liệu quan hệ; slide cũng nêu PostgreSQL/Oracle. | Áp dụng PostgreSQL: POM JDBC driver và PU Hibernate PostgreSQLDialect; không nhận là đang dùng MySQL. |
| 19–22 | Hosting, FileZilla, WinSCP, Synchronize | Nội dung tiêu đề về triển khai/đồng bộ từ xa; không suy diễn hình/chế độ kết nối. | Chưa có chứng cứ quy trình FTP/SFTP/hosting trong source đọc; đề xuất đóng gói WAR và triển khai qua kênh an toàn, không chứa secrets trong tài liệu. |

### Chapter02

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

### Chapter05

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

### Chapter06

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

### Chapter07

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

### Chapter08

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

### Chapter09

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

### Chapter10

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

### Chapter13

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

## 4. Speaker notes — tách khỏi slide body

15 slide có notes. Nguyên văn bên dưới chỉ gom whitespace, không coi notes là định nghĩa kỹ thuật chuẩn. Notes chỉ số không bổ sung nội dung. Những chữ AJK Note trên slide09/3 hoặc10/3,10/11 là body, đã map ở chương, không notes.

| Chương/slide | Notes từ extraction |
|---|---|
| Chapter05/22 | The scope of the User object is only available to the JSP, not available later in the session  chapter 7 These methods are most often used in conjunction with a RequestDispatcher object 22 |
| Chapter05/25 | Typically use this technique when you want to transfer control to a URL outside of your application Servlet engine  convert absolute URL  server send absolute URL to the browser. 25 |
| Chapter05/27 | How to validate data 27 |
| Chapter05/32 | How to work with xml file 32 |
| Chapter05/38 | 38 |
| Chapter06/4 | The Serializable is a tagging interface in the java.io package that indicate that a class contains get, set and is methods that another class can use to read and write an object’s instance variable to and from a persistence data source. The zero argument constructor use 3 statements to set all 3 instance variables equals to empty string. 4 |
| Chapter06/6 | the three rules for defining a JavaBean. The Serializable is a tagging interface in the java.io package that indicate that a class contains get, set and is methods that another class can use to read and write an object’s instance variable to and from a persistence data source. 6 |
| Chapter06/7 | Whenever you use EL, you begin by coding a dollar sign followed by an opening brace and a closing brace. The, you code the expression within the brace. 7 |
| Chapter06/19 | JSP directive JSP scriptlet JSP expression 19 |
| Chapter07/6 | Session hijacking. There are 2 types of cookies. A per-session cookies is store on the browser until the user close the browser, and a persistent cookies can be store on the user hard disk for up to 3 years. 6 |
| Chapter07/14 | It’s possible that the user may access the same servlet from multiple tabs within a browser as shown in this figure. In that case, all tabs within the browser run in different threads that have access to the same session object. 14 |
| Chapter07/16 | We can create a lock object based on the session ID and synchronized on that object. The intern() method is a little known method of the String class that allows you to store a string in a pool of string. The purpose is to save memory and reduce garbage collection by only storing one object of identical string in the pool, rather than creating separate object for a string, even if the string have identical content. 16 |
| Chapter07/18 | 18 |
| Chapter07/19 | Once you have stored a cookie on a browser’s PC, you can use it to make your web app work better for the user. 19 |
| Chapter10/3 | 3 |

**Đính chính notes:** Serializable là marker, không yêu cầu getter/setter và không tự persist. Redirect cũng dùng PRG nội bộ. Cookie3 năm không quy tắc phổ quát hiện đại. Các tab hoặc async trong một tab vẫn concurrent; intern/synchronized trong JVM không thay transaction/locking DB hoặc distributed lock. Session đóng browser không tự báo server invalidate ngay; timeout server và cookie browser là vòng đời khác nhau. Request scope còn qua forward, không request mới sau redirect.

## 5. Kịch bản viva bám source

### MVC đọc DB

GET /owner/reviews?rating=5 → FOwner kiểm flag session demo → CReviews.parseRating/doGet → DReview.findByOwnerId(DEMO_OWNER_ID,rating), JPQL JOIN FETCH/named params → finally EM.close → set request list/summary → forward JReviews → Java loop/escapeHtml. Summary tính toàn owner, list mới lọc rating. Account/role/userId thật vẫn TODO.

### POST phản hồi/PRG

JReviews POST hidden reviewId/rating + ownerReply → CReply validate → DReview.saveOwnerReply begin → bulk JPQL UPDATE ràng owner → executeUpdate/count → commit hoặc rollback + close → redirect success/error + rating → browser GET mới. Request attr POST không qua redirect; PRG không tự chống CSRF/idempotency/auth.

### Sửa sân không merge

CUpdate validate rồi DField.update tạo EM mới, find managed entity, kiểm owner, copy dữ liệu, commit dirty checking. Detached object truyền từ servlet không tự ghi DB. @PreUpdate timestamp chỉ entity operation; bulk review tự set repliedAt.

### Có gì/chưa có gì?

Source quản lý sân/chat messages/review feedback dùng JPA thật; runtime cần chứng cứ riêng. User login/register dummy, owner auth demo, booking/client friend chat có minh họa. Session có, explicit Cookie API chưa; view scriptlet chưa EL/JSTL/custom tag. Đề xuất core tags/escaping/includes là migration, không feature đang có.

## 6. Chỉ mục từng slide — presentation order

Tiêu đề từ Word embedded đầu tiên khi có, nếu không từ text trực tiếp bỏ footer. Mọi text/code continuation đã đọc và map ở mục3; chỉ mục không là OCR hình.

### Chapter 01 slides.pptx

| Vị trí | Tiêu đề/text nhận diện | Giới hạn media extraction |
|---:|---|---|
| 1 | Chapter 1 An introduction to web programming with Java | Không có giới hạn media được liệt kê |
| 2 | Objectives | Không có giới hạn media được liệt kê |
| 3 | Objectives (continued) | Không có giới hạn media được liệt kê |
| 4 | The first page of a shopping cart application | Ảnh chưa đọc: 1 |
| 5 | The second page of a shopping cart application | Ảnh chưa đọc: 1 |
| 6 | Components of a web application | Visio/OLE chưa đọc text |
| 7 | How a web server processes static web pages | Ảnh chưa đọc: 2 |
| 8 | Three approaches for developing Java web apps | Không có giới hạn media được liệt kê |
| 9 | Terminology | Không có giới hạn media được liệt kê |
| 10 | The components of a servlet/JSP application | Ảnh chưa đọc: 1 |
| 11 | The architecture for a servlet/JSP application | Ảnh chưa đọc: 1 |
| 12 | The directory structure for a web application | Ảnh chưa đọc: 1 |
| 13 | The directories and files for a web application | Không có giới hạn media được liệt kê |
| 14 | The NetBeans IDE | Ảnh chưa đọc: 1 |
| 15 | Popular IDEs for Java web development | Không có giới hạn media được liệt kê |
| 16 | Two popular web servers | Không có giới hạn media được liệt kê |
| 17 | Other popular web servers | Không có giới hạn media được liệt kê |
| 18 | A popular database server | Không có giới hạn media được liệt kê |
| 19 | An ISP that provides servlet/JSP web hosting | Ảnh chưa đọc: 1 |
| 20 | The FileZilla program | Ảnh chưa đọc: 1 |
| 21 | WinSCP | Ảnh chưa đọc: 1 |
| 22 | WinSCP – Synchronize | Ảnh chưa đọc: 1 |

### Chapter 02 slides.pptx

| Vị trí | Tiêu đề/text nhận diện | Giới hạn media extraction |
|---:|---|---|
| 1 | Chapter 2 How to structure a web application with the MVC pattern | Ảnh chưa đọc: 1 |
| 2 | Objectives | Ảnh chưa đọc: 2 |
| 3 | The Model 1 pattern | Ảnh chưa đọc: 2 |
| 4 | The Model 2 (MVC) pattern | Ảnh chưa đọc: 2 |
| 5 | Concepts and terminology | Ảnh chưa đọc: 2 |
| 6 | The HTML page that gets data from the user | Ảnh chưa đọc: 2 |
| 7 | The JSP that displays the data | Ảnh chưa đọc: 2 |
| 8 | The index.html file | Ảnh chưa đọc: 2 |
| 9 | The index.html file (continued) | Ảnh chưa đọc: 2 |
| 10 | The main.css file | Ảnh chưa đọc: 2 |
| 11 | The EmailListServlet class | Ảnh chưa đọc: 2 |
| 12 | The EmailListServlet class (continued) | Ảnh chưa đọc: 2 |
| 13 | The EmailListServlet class (continued) | Ảnh chưa đọc: 2 |
| 14 | The web.xml file | Ảnh chưa đọc: 2 |
| 15 | The web.xml file (continued) | Ảnh chưa đọc: 2 |
| 16 | The User class | Ảnh chưa đọc: 2 |
| 17 | The User class (continued) | Ảnh chưa đọc: 2 |
| 18 | The thanks.jsp file | Ảnh chưa đọc: 2 |
| 19 | The thanks.jsp file (continued) | Ảnh chưa đọc: 2 |
| 20 | Types of files in the MVC pattern | Ảnh chưa đọc: 2 |

### Chapter 05 slides.pptx

| Vị trí | Tiêu đề/text nhận diện | Giới hạn media extraction |
|---:|---|---|
| 1 | Chapter 5 How to develop servlets | Ảnh chưa đọc: 1 |
| 2 | Objectives | Ảnh chưa đọc: 2 |
| 3 | Objectives (continued) | Ảnh chưa đọc: 2 |
| 4 | A servlet that returns HTML | Ảnh chưa đọc: 2 |
| 5 | A servlet that returns HTML (continued) | Ảnh chưa đọc: 2 |
| 6 | Servlet concepts | Ảnh chưa đọc: 2 |
| 7 | XML tags that add servlet mapping to web.xml file | Ảnh chưa đọc: 2 |
| 8 | XML elements for working with servlet mapping | Ảnh chưa đọc: 2 |
| 9 | Some URL pattern examples | Ảnh chưa đọc: 2 |
| 10 | An annotation that maps a servlet to a URL | Ảnh chưa đọc: 2 |
| 11 | How to use servlet annotations | Ảnh chưa đọc: 2 |
| 12 | An HTTP request that uses the GET method | Ảnh chưa đọc: 2 |
| 13 | How to append parameters to a URL | Ảnh chưa đọc: 2 |
| 14 | A URL requested with the HTTP POST method | Ảnh chưa đọc: 2 |
| 15 | A Form tag that uses the POST method | Ảnh chưa đọc: 2 |
| 16 | Two methods of the HttpServletRequest object | Ảnh chưa đọc: 2 |
| 17 | Servlet code that gets text from a text box | Ảnh chưa đọc: 2 |
| 18 | A method of the GenericServlet class | Ảnh chưa đọc: 2 |
| 19 | Code that gets the absolute path for a file | Ảnh chưa đọc: 2 |
| 20 | How to work with the ServletContext object | Ảnh chưa đọc: 2 |
| 21 | Two methods of the HttpServletRequest object | Ảnh chưa đọc: 2 |
| 22 | How to set a request attribute | Ảnh chưa đọc: 2 |
| 23 | A method of the ServletContext object | Ảnh chưa đọc: 2 |
| 24 | How to forward the request to an HTML page | Ảnh chưa đọc: 2 |
| 25 | A method of the HttpServletResponse class | Ảnh chưa đọc: 2 |
| 26 | How to redirect a response… | Ảnh chưa đọc: 2 |
| 27 | The JSP displayed when an entry isn’t made | Ảnh chưa đọc: 2 |
| 28 | The code for the JSP | Ảnh chưa đọc: 2 |
| 29 | The code for the JSP (continued) | Ảnh chưa đọc: 2 |
| 30 | A doPost method that validates data | Ảnh chưa đọc: 2 |
| 31 | A doPost method that validates data (continued) | Ảnh chưa đọc: 2 |
| 32 | A complete web.xml file | Ảnh chưa đọc: 2 |
| 33 | A complete web.xml file (continued) | Ảnh chưa đọc: 2 |
| 34 | Concepts about the web.xml file | Ảnh chưa đọc: 2 |
| 35 | Initialization parameters in a web.xml file | Ảnh chưa đọc: 2 |
| 36 | XML elements for initialization parameters | Ảnh chưa đọc: 2 |
| 37 | An annotation that sets initialization parameters for a servlet | Ảnh chưa đọc: 2 |
| 38 | Initialization parameters | Ảnh chưa đọc: 2 |
| 39 | Two methods of the GenericServlet class | Ảnh chưa đọc: 2 |
| 40 | Code that gets an initialization parameter that’s… | Ảnh chưa đọc: 2 |
| 41 | XML elements for working with error handling | Ảnh chưa đọc: 2 |
| 42 | How to provide error-handling for an HTTP 404 status code | Ảnh chưa đọc: 2 |
| 43 | The JSP page for the 404 error | Ảnh chưa đọc: 2 |
| 44 | How to provide error-handling for all Java exceptions | Ảnh chưa đọc: 2 |
| 45 | The JSP when a Java exception is thrown | Ảnh chưa đọc: 2 |
| 46 | Five common methods of a servlet | Ảnh chưa đọc: 2 |
| 47 | The lifecycle of a servlet | Ảnh chưa đọc: 3 |
| 48 | A servlet with an instance variable | Ảnh chưa đọc: 2 |
| 49 | A servlet with an instance variable (continued) | Ảnh chưa đọc: 2 |
| 50 | Why you shouldn’t use instance variables in servlets | Ảnh chưa đọc: 2 |
| 51 | Common servlet problems | Ảnh chưa đọc: 2 |
| 52 | Code that prints debugging data to the console | Ảnh chưa đọc: 2 |
| 53 | How to print debugging data to the console | Ảnh chưa đọc: 2 |
| 54 | Two methods of the HttpServlet class | Ảnh chưa đọc: 2 |
| 55 | Servlet code that prints a variable to a log file | Ảnh chưa đọc: 2 |
| 56 | Servlet code that prints a stack trace to a log file | Ảnh chưa đọc: 2 |
| 57 | The location of a typical Tomcat log file | Ảnh chưa đọc: 2 |
| 58 | How to print debugging data to a log file | Ảnh chưa đọc: 2 |

### Chapter 06 slides.pptx

| Vị trí | Tiêu đề/text nhận diện | Giới hạn media extraction |
|---:|---|---|
| 1 | Chapter 6 How to develop JSPs | Ảnh chưa đọc: 1 |
| 2 | Objectives | Ảnh chưa đọc: 2 |
| 3 | Objectives (continued) | Ảnh chưa đọc: 2 |
| 4 | The User bean class | Ảnh chưa đọc: 2 |
| 5 | The User bean class (continued) | Ảnh chưa đọc: 2 |
| 6 | How to code a JavaBean | Ảnh chưa đọc: 2 |
| 7 | How to display an attribute | Ảnh chưa đọc: 2 |
| 8 | How to display the property of an attribute | Ảnh chưa đọc: 2 |
| 9 | The sequence of scopes that Java searches to find the attribute | Ảnh chưa đọc: 2 |
| 10 | EL | Ảnh chưa đọc: 2 |
| 11 | NetBeans after the JSTL 1.2 library was added | Ảnh chưa đọc: 3 |
| 12 | A JSTL if tag for a validation message | Ảnh chưa đọc: 2 |
| 13 | JSTL | Ảnh chưa đọc: 2 |
| 14 | The five types of JSP tags | Ảnh chưa đọc: 2 |
| 15 | A directive, scriptlet, and expression | Ảnh chưa đọc: 2 |
| 16 | JSP tags | Ảnh chưa đọc: 2 |
| 17 | An HTML comment in a JSP | Ảnh chưa đọc: 2 |
| 18 | Comments | Ảnh chưa đọc: 2 |
| 19 | Code that uses JSP tags to access the User bean | Ảnh chưa đọc: 2 |
| 20 | The same code using standard JSP tags | Ảnh chưa đọc: 2 |
| 21 | The same code using EL | Ảnh chưa đọc: 2 |
| 22 | Advantages of standard JSP tags | Ảnh chưa đọc: 2 |
| 23 | The useBean tag | Ảnh chưa đọc: 2 |
| 24 | The getProperty tag | Ảnh chưa đọc: 2 |
| 25 | Standard JSP tags (useBean tags) | Ảnh chưa đọc: 2 |
| 26 | Escape sequences within attributes | Ảnh chưa đọc: 2 |
| 27 | A header file named header.html | Ảnh chưa đọc: 2 |
| 28 | A JSP file that uses both include files | Ảnh chưa đọc: 2 |
| 29 | The web page displayed in a browser | Ảnh chưa đọc: 2 |
| 30 | Another page with the same header and footer | Ảnh chưa đọc: 2 |
| 31 | How to include a file at compile-time | Ảnh chưa đọc: 2 |
| 32 | How to include a file at runtime | Ảnh chưa đọc: 2 |
| 33 | File includes | Ảnh chưa đọc: 2 |
| 34 | An error page for a common JSP error | Ảnh chưa đọc: 2 |
| 35 | Common JSP errors | Ảnh chưa đọc: 2 |

### Chapter 07 slides.pptx

| Vị trí | Tiêu đề/text nhận diện | Giới hạn media extraction |
|---:|---|---|
| 1 | Chapter 7 How to work with sessions and cookies | Ảnh chưa đọc: 1 |
| 2 | Objectives | Ảnh chưa đọc: 2 |
| 3 | Objectives (continued) | Ảnh chưa đọc: 2 |
| 4 | Why session tracking is difficult with HTTP | Ảnh chưa đọc: 2 |
| 5 | How Java keeps track of sessions | Ảnh chưa đọc: 2 |
| 6 | Session tracking and cookies | Ảnh chưa đọc: 2 |
| 7 | The Index page | Ảnh chưa đọc: 2 |
| 8 | The Cart page | Ảnh chưa đọc: 2 |
| 9 | A method of the request object | Ảnh chưa đọc: 2 |
| 10 | How to get a session object | Ảnh chưa đọc: 2 |
| 11 | Sessions | Ảnh chưa đọc: 2 |
| 12 | More methods of the session object | Ảnh chưa đọc: 2 |
| 13 | How to get the names of the attributes for a session | Ảnh chưa đọc: 2 |
| 14 | Three tabs accessing the same session object | Ảnh chưa đọc: 2 |
| 15 | How to provide thread-safe access to the session object | Ảnh chưa đọc: 2 |
| 16 | How to synchronize access to the session object | Ảnh chưa đọc: 2 |
| 17 | Examples of cookies | Ảnh chưa đọc: 2 |
| 18 | How cookies work | Ảnh chưa đọc: 2 |
| 19 | Typical uses for cookies | Ảnh chưa đọc: 2 |
| 20 | Cookies | Ảnh chưa đọc: 2 |
| 21 | Constructor of the Cookie class | Ảnh chưa đọc: 2 |
| 22 | The methods of the Cookie class | Ảnh chưa đọc: 2 |
| 23 | A method of the response object | Ảnh chưa đọc: 2 |
| 24 | How to create a cookie and set it in a response | Ảnh chưa đọc: 2 |
| 25 | JSP that shows all cookies for the current server | Ảnh chưa đọc: 2 |
| 26 | JSP code that displays all cookies | Ảnh chưa đọc: 2 |
| 27 | Servlet code that deletes all persistent cookies | Ảnh chưa đọc: 2 |
| 28 | Four methods of the Cookie class | Ảnh chưa đọc: 2 |
| 29 | Four methods of the Cookie class (continued) | Ảnh chưa đọc: 2 |
| 30 | A utility class that gets the value of a cookie | Ảnh chưa đọc: 2 |
| 31 | Code that uses the CookieUtil class to get the value of a cookie | Ảnh chưa đọc: 2 |
| 32 | The syntax for URL rewriting | Ảnh chưa đọc: 5 |
| 33 | More examples of URL rewriting | Ảnh chưa đọc: 2 |
| 34 | Two limitations of URL rewriting | Ảnh chưa đọc: 2 |
| 35 | A form with a hidden text field and a button | Ảnh chưa đọc: 5 |
| 36 | A form tag that uses EL to set hidden field values | Ảnh chưa đọc: 2 |
| 37 | URL rewriting and hidden fields | Ảnh chưa đọc: 2 |
| 38 | The Index page | Ảnh chưa đọc: 2 |
| 39 | The Register page | Ảnh chưa đọc: 2 |
| 40 | The Downloads page | Ảnh chưa đọc: 2 |
| 41 | The names of the jsp files | Ảnh chưa đọc: 2 |
| 42 | The web.xml file | Ảnh chưa đọc: 2 |
| 43 | The index.jsp file | Ảnh chưa đọc: 2 |
| 44 | The index.jsp file (continued) | Ảnh chưa đọc: 2 |
| 45 | The register.jsp file | Ảnh chưa đọc: 2 |
| 46 | The register.jsp file (continued) | Ảnh chưa đọc: 2 |
| 47 | The 8601_download.jsp file | Ảnh chưa đọc: 2 |
| 48 | The 8601_download.jsp file (continued) | Ảnh chưa đọc: 2 |
| 49 | The 8601_download.jsp file (continued) | Ảnh chưa đọc: 2 |
| 50 | The DownloadServlet class | Ảnh chưa đọc: 2 |
| 51 | The DownloadServlet class (continued) | Ảnh chưa đọc: 2 |
| 52 | The DownloadServlet class (continued) | Ảnh chưa đọc: 2 |
| 53 | The DownloadServlet class (continued) | Ảnh chưa đọc: 2 |
| 54 | The DownloadServlet class (continued) | Ảnh chưa đọc: 2 |
| 55 | The DownloadServlet class (continued) | Ảnh chưa đọc: 2 |
| 56 | The DownloadServlet class (continued) | Ảnh chưa đọc: 2 |

### Chapter 08 slides.pptx

| Vị trí | Tiêu đề/text nhận diện | Giới hạn media extraction |
|---:|---|---|
| 1 | Chapter 8 How to use EL(Expression Language) | Ảnh chưa đọc: 1 |
| 2 | Objectives | Ảnh chưa đọc: 2 |
| 3 | Code that accesses a User objectstored in the session object | Ảnh chưa đọc: 2 |
| 4 | Advantages of EL | Ảnh chưa đọc: 2 |
| 5 | How to access an attribute | Ảnh chưa đọc: 2 |
| 6 | How to access a property of an attribute | Ảnh chưa đọc: 2 |
| 7 | Sequence of scopes searched to find the attribute | Ảnh chưa đọc: 2 |
| 8 | The dot operator with JavaBeans and maps | Ảnh chưa đọc: 2 |
| 9 | Implicit EL objects for specifying scope | Ảnh chưa đọc: 2 |
| 10 | How to explicitly specify request scope | Ảnh chưa đọc: 2 |
| 11 | How to explicitly specify session scope | Ảnh chưa đọc: 2 |
| 12 | Implicit EL objects for scope | Ảnh chưa đọc: 2 |
| 13 | Syntax for the [ ] operator | Ảnh chưa đọc: 2 |
| 14 | How to use the [ ] operator with an array | Ảnh chưa đọc: 2 |
| 15 | How to use the [ ] operator with a list | Ảnh chưa đọc: 2 |
| 16 | [ ] operator (part 1) | Ảnh chưa đọc: 2 |
| 17 | How to access nested properties | Ảnh chưa đọc: 2 |
| 18 | Another way to access nested properties | Ảnh chưa đọc: 2 |
| 19 | Nested properties | Ảnh chưa đọc: 2 |
| 20 | How to access an attribute within the [ ] operator | Ảnh chưa đọc: 2 |
| 21 | How to use multiple [ ] operators | Ảnh chưa đọc: 2 |
| 22 | [ ] operator (part 2) | Ảnh chưa đọc: 2 |
| 23 | Other implicit EL objects | Ảnh chưa đọc: 2 |
| 24 | Implicit EL objects | Ảnh chưa đọc: 2 |
| 25 | How to get parameter values from the request | Ảnh chưa đọc: 2 |
| 26 | How to get an HTTP header | Ảnh chưa đọc: 2 |
| 27 | How to work with cookies | Ảnh chưa đọc: 2 |
| 28 | How to get a context initialization parameter | Ảnh chưa đọc: 2 |
| 29 | How to use the pageContext object | Ảnh chưa đọc: 2 |
| 30 | Arithmetic EL operators | Ảnh chưa đọc: 2 |
| 31 | Arithmetic EL operators (continued) | Ảnh chưa đọc: 2 |
| 32 | Relational operators | Ảnh chưa đọc: 2 |
| 33 | Relational operators (continued) | Ảnh chưa đọc: 2 |
| 34 | Logical operators | Ảnh chưa đọc: 2 |
| 35 | Other operators | Ảnh chưa đọc: 2 |
| 36 | Keywords you can use in expressions | Ảnh chưa đọc: 2 |
| 37 | EL expressions | Ảnh chưa đọc: 2 |
| 38 | How to disable EL | Ảnh chưa đọc: 2 |
| 39 | How to disable EL or scripting | Ảnh chưa đọc: 2 |

### Chapter 09 slides.pptx

| Vị trí | Tiêu đề/text nhận diện | Giới hạn media extraction |
|---:|---|---|
| 1 | Chapter 9 How to use JSTL | Ảnh chưa đọc: 1 |
| 2 | Objectives | Ảnh chưa đọc: 2 |
| 3 | The primary JSTL libraries | Ảnh chưa đọc: 2 |
| 4 | NetBeans with the JSTL 1.2 library added | Ảnh chưa đọc: 3 |
| 5 | An introduction to JSTL | Ảnh chưa đọc: 2 |
| 6 | Browser that displays the JSTL documentation | Ảnh chưa đọc: 2 |
| 7 | XSS attacks | Ảnh chưa đọc: 2 |
| 8 | How to escape output entered by the user | Ảnh chưa đọc: 3 |
| 9 | How to escape output that displays cookies | Ảnh chưa đọc: 2 |
| 10 | How to display a default value | Ảnh chưa đọc: 2 |
| 11 | How to loop through a collection | Ảnh chưa đọc: 3 |
| 12 | How to loop through a comma-delimited string | Ảnh chưa đọc: 3 |
| 13 | How to parse a string | Ảnh chưa đọc: 3 |
| 14 | Attributes for advanced loops | Ảnh chưa đọc: 2 |
| 15 | Servlet code that creates an array of numbers | Ảnh chưa đọc: 2 |
| 16 | JSP code that uses advanced attributes | Ảnh chưa đọc: 3 |
| 17 | How to code an if statement | Ảnh chưa đọc: 3 |
| 18 | How to code an if/else statement | Ảnh chưa đọc: 3 |
| 19 | The if and choose tags | Ảnh chưa đọc: 2 |
| 20 | A link that doesn’t use the url tag | Ảnh chưa đọc: 2 |
| 21 | A browser with the session ID encoded in its URL | Ảnh chưa đọc: 3 |
| 22 | The url tag | Ảnh chưa đọc: 2 |
| 23 | Other tags in the JSTL core library | Ảnh chưa đọc: 2 |
| 24 | How to set a value in an attribute | Ảnh chưa đọc: 2 |
| 25 | How to catch an exception | Ảnh chưa đọc: 2 |
| 26 | The Index page | Ảnh chưa đọc: 2 |
| 27 | The Cart page | Ảnh chưa đọc: 2 |
| 28 | The Product class | Ảnh chưa đọc: 2 |
| 29 | The Product class (contined) | Ảnh chưa đọc: 2 |
| 30 | The LineItem class | Ảnh chưa đọc: 2 |
| 31 | The LineItem class (continued) | Ảnh chưa đọc: 2 |
| 32 | The Cart class | Ảnh chưa đọc: 2 |
| 33 | The Cart class (continued) | Ảnh chưa đọc: 2 |
| 34 | The index.jsp file | Ảnh chưa đọc: 2 |
| 35 | The index.jsp file (continued) | Ảnh chưa đọc: 2 |
| 36 | The index.jsp file (continued) | Ảnh chưa đọc: 2 |
| 37 | The CartServlet class | Ảnh chưa đọc: 2 |
| 38 | The CartServlet class (continued) | Ảnh chưa đọc: 2 |
| 39 | The CartServlet class (continued) | Ảnh chưa đọc: 2 |
| 40 | The CartServlet class (continued) | Ảnh chưa đọc: 2 |
| 41 | The cart.jsp file | Ảnh chưa đọc: 2 |
| 42 | The cart.jsp file (continued) | Ảnh chưa đọc: 2 |
| 43 | The cart.jsp file (continued) | Ảnh chưa đọc: 2 |

### Chapter 10 slides.pptx

| Vị trí | Tiêu đề/text nhận diện | Giới hạn media extraction |
|---:|---|---|
| 1 | Chapter 10 How to use custom JSP tags | Ảnh chưa đọc: 1 |
| 2 | Objectives | Ảnh chưa đọc: 2 |
| 3 | A taglib directive for a custom tag library | Ảnh chưa đọc: 3 |
| 4 | TLD file with two tag elements | Ảnh chưa đọc: 2 |
| 5 | Custom tags | Ảnh chưa đọc: 2 |
| 6 | A custom tag that doesn’t have a body | Ảnh chưa đọc: 2 |
| 7 | A custom tag that doesn’t have a body | Ảnh chưa đọc: 2 |
| 8 | A custom tag with a body | Ảnh chưa đọc: 3 |
| 9 | The tag element in the TLD file | Ảnh chưa đọc: 2 |
| 10 | The tag class | Ảnh chưa đọc: 2 |
| 11 | A custom tag with a body | Ảnh chưa đọc: 2 |
| 12 | How to use a custom tag that has attributes | Ảnh chưa đọc: 2 |
| 13 | A JSP that uses a custom tag that has attributes | Ảnh chưa đọc: 2 |
| 14 | Syntax for the attribute element in a tag element | Ảnh chưa đọc: 2 |
| 15 | A tag class that uses two attributes | Ảnh chưa đọc: 2 |
| 16 | A tag class that uses two attributes (continued) | Ảnh chưa đọc: 2 |
| 17 | The attribute child elements | Ảnh chưa đọc: 2 |
| 18 | An attribute element that uses the integer data type | Ảnh chưa đọc: 2 |
| 19 | A custom tag that has attributes | Ảnh chưa đọc: 2 |
| 20 | How to use a tag that reiterates its body | Ảnh chưa đọc: 3 |
| 21 | A tag element for the TLD | Ảnh chưa đọc: 2 |
| 22 | A tag class that reiterates the body (continued) | Ảnh chưa đọc: 2 |
| 23 | A tag class that reiterates the tag body (continued) | Ảnh chưa đọc: 2 |
| 24 | A tag class that reiterates the tag body (continued) | Ảnh chưa đọc: 2 |
| 25 | A custom tag that reiterates its body | Ảnh chưa đọc: 2 |
| 26 | An introduction to scripting variables | Ảnh chưa đọc: 2 |
| 27 | A custom JSP tag without scripting variables | Ảnh chưa đọc: 2 |
| 28 | Code in the tag class that adds the scripting variables to the pageContext object | Ảnh chưa đọc: 2 |
| 29 | Scripting variables | Ảnh chưa đọc: 2 |
| 30 | A TEI class that creates four scripting variables | Ảnh chưa đọc: 2 |
| 31 | VariableInfo constants | Ảnh chưa đọc: 2 |
| 32 | TEI class | Ảnh chưa đọc: 2 |
| 33 | Common methods and fields of the TagSupport class | Ảnh chưa đọc: 2 |
| 34 | Methods and fields of the TagSupport class | Ảnh chưa đọc: 2 |
| 35 | The pageContext object in the TagSupport class | Ảnh chưa đọc: 2 |
| 36 | Common methods of the PageContext class | Ảnh chưa đọc: 2 |
| 37 | The fields of the PageContext class for setting scope | Ảnh chưa đọc: 2 |
| 38 | Methods and fields of the BodyTagSupport class | Ảnh chưa đọc: 2 |
| 39 | Methods and fields of the BodyTagSupport class | Ảnh chưa đọc: 2 |
| 40 | The bodyContent object in the BodyTagSupport class | Ảnh chưa đọc: 2 |
| 41 | Common methods of the BodyContent class | Ảnh chưa đọc: 2 |
| 42 | Methods and fields of the BodyContent class | Ảnh chưa đọc: 2 |

### Chapter 13 slides.pptx

| Vị trí | Tiêu đề/text nhận diện | Giới hạn media extraction |
|---:|---|---|
| 1 | Chapter 13 How to use JPA to work with a database | Ảnh chưa đọc: 1 |
| 2 | Objectives | Ảnh chưa đọc: 2 |
| 3 | Objectives (continued) | Ảnh chưa đọc: 2 |
| 4 | JPA… | Ảnh chưa đọc: 2 |
| 5 | Entities and the entity manager | Ảnh chưa đọc: 2 |
| 6 | NetBeans with a JDBC driver, JPA library, and persistence.xml file | Ảnh chưa đọc: 2 |
| 7 | How to add a JDBC driver and the JPA library | Ảnh chưa đọc: 2 |
| 8 | The persistence.xml file | Ảnh chưa đọc: 2 |
| 9 | A summary of the persistence.xml elements | Ảnh chưa đọc: 2 |
| 10 | A simple JPA entity | Ảnh chưa đọc: 2 |
| 11 | The class for a JPA entity | Ảnh chưa đọc: 2 |
| 12 | How to code getter annotations | Ảnh chưa đọc: 2 |
| 13 | How to code field annotations | Ảnh chưa đọc: 2 |
| 14 | Getter and field annotations | Ảnh chưa đọc: 2 |
| 15 | A JPA entity with relationships | Ảnh chưa đọc: 2 |
| 16 | Two elements of the @OneToMany annotation | Ảnh chưa đọc: 2 |
| 17 | Relationships in a JPA entity | Ảnh chưa đọc: 2 |
| 18 | The annotation for a temporal type | Ảnh chưa đọc: 2 |
| 19 | A utility class that gets an entity manager factory | Ảnh chưa đọc: 2 |
| 20 | A static method of the Persistence class | Ảnh chưa đọc: 2 |
| 21 | How to retrieve an entity by primary key | Ảnh chưa đọc: 2 |
| 22 | Method of the EntityManagerFactory class | Ảnh chưa đọc: 2 |
| 23 | How to retrieve multiple entities | Ảnh chưa đọc: 2 |
| 24 | A JPQL statement that selects one field | Ảnh chưa đọc: 2 |
| 25 | JPQL and the getResultList method | Ảnh chưa đọc: 2 |
| 26 | How to retrieve a single entity | Ảnh chưa đọc: 2 |
| 27 | Some exceptions thrown by getSingleResult | Ảnh chưa đọc: 2 |
| 28 | Named parameters and the setParameter method | Ảnh chưa đọc: 2 |
| 29 | How to wrap an operation in a transaction | Ảnh chưa đọc: 2 |
| 30 | How to insert a single entity | Ảnh chưa đọc: 2 |
| 31 | Methods of the EntityManager object | Ảnh chưa đọc: 2 |
| 32 | Transactions | Ảnh chưa đọc: 2 |
| 33 | How to update multiple entities | Ảnh chưa đọc: 2 |
| 34 | How to delete multiple entities | Ảnh chưa đọc: 2 |
| 35 | The executeUpdate method | Ảnh chưa đọc: 2 |
| 36 | The UserDB class | Ảnh chưa đọc: 2 |
| 37 | The UserDB class (continued) | Ảnh chưa đọc: 2 |
| 38 | The UserDB class (continued) | Ảnh chưa đọc: 2 |
| 39 | The UserDB class (continued) | Ảnh chưa đọc: 2 |

## 7. Kiểm tra cuối

125 nhóm bao phủ354/354 vị trí đúng một lần; mục6 có354 dòng slide. Mọi text trực tiếp/embedded/notes đã đọc, dedup object trùng; đủ cookies, EL, JSTL, custom tag/TEI/buffering, JPA/transactions/bulk. Một Visio Chapter01 slide6 chưa đọc text; không giả ảnh. Chương03/04/11/12 chưa cung cấp. Build/runtime/deployment/security acceptance cần bằng chứng riêng.
