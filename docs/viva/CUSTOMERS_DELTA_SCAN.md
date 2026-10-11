# Sportify — delta khách hàng và đối chiếu snapshot viva

## 1. Handle, phạm vi và mức xác minh

- Repository/source root: `D:/Projects/Sportify` (Windows `D:\Projects\Sportify`), không phải `C:/Users/20huy`. Các source roots: `src/main`, `src/test`, `database`; Maven descriptor: `pom.xml`.
- Docs root: `D:/Projects/Sportify/docs/viva`. Tài liệu mới: `CUSTOMERS_DELTA_SCAN.md`; snapshot hashes: `SOURCE_MANIFEST.json`. Giữ nguyên `BACKEND_SCAN.md` và `FRONTEND_SCAN.md` để bảo toàn snapshot cũ.
- Đọc hết sáu source customers mới, hai customer test source, `database/CUSTOMERS.md`, toàn bộ dashboard JSP/JS/CSS hiện tại, persistence descriptor (che credential), pom, OwnerAccessFilter, DBUtil, Review và reviews JSP; đọc hết hai báo cáo cũ để đối chiếu. Inventory/hash toàn bộ file text trong phạm vi manifest **không đồng nghĩa đã phân tích lại toàn bộ từng source ngoài delta**.
- **ACTUAL-SOURCE** = có đường đi JPA/query trong source; **MOCK** = hardcoded/DOM-only; **PARTIAL** = có implementation nhưng thiếu nghiệp vụ/auth; **RUNTIME-UNVERIFIED** = chưa có chứng cứ chạy mới. Không đồng nhất actual-source với PostgreSQL đang có dữ liệu hay HTTP đã thành công.
- Không build/test/run ứng dụng/browser; không kết nối DB, migration/seed, commit/push; chỉ ghi hai tài liệu trong `docs/viva`. Không chép giá trị credential, password demo hoặc thông tin cá nhân từ fixture/UI vào báo cáo.
- Snapshot manifest UTC `2026-10-11T14:06:21.777584+00:00`. Hash SHA256 trên **raw bytes**, không normalize newline/encoding; dòng tính bằng UTF-8-sig `splitlines()` gồm dòng trống. File đang làm việc/untracked cũng nằm trong snapshot, không dùng index/HEAD hay `target` làm nguồn chính.

## 2. Inventory chạy lại bằng Python

| Phạm vi | File text | Dòng | Bytes |
|---|---:|---:|---:|
| `src/main` | 44 | 8.425 | 264.805 |
| `src/test` | 4 | 403 | 18.202 |
| `database` | 1 | 52 | 2.985 |
| `pom.xml` | 1 | 92 | 2.895 |
| Tổng text manifest | 50 | 8.972 | 288.887 |

64 file ứng viên = 50 text được hash + 14 ảnh binary bị loại. Quy tắc phân loại: có NUL hoặc không decode UTF-8-sig → loại; tên/path/bytes/lý do được liệt kê ở `excluded_files`, không lưu nội dung binary. Không quét `.git`, `target`, cache, docs vì ngoài roots được yêu cầu. Đây là file/line inventory, **không phải LOC executable theo pygount**.

`src/main`: **20 Java, 13 JSP, 5 CSS, 4 JS, 2 XML**. So với báo cáo cũ: 17 Java production → 20; 2 test Java → 4; 19 JSP/CSS/JS → 22 (thêm customers JSP/CSS/JS). Tổng Java cả production/test là 24. Frontend cũ cộng README/PROJECT_STATUS thành 21 file/6.155 dòng là phạm vi khác, không so trực tiếp với 44 file toàn src/main.

### Source chính và alias evidence

Mọi path dưới đây relative từ repository; trích `File:Lx–Ly` dùng đúng snapshot này.

| Alias | Path | Dòng |
|---|---|---:|
| ManageCustomersServlet.java | `src/main/java/com/sportify/controller/ManageCustomersServlet.java` | 57 |
| CustomerDB.java | `src/main/java/com/sportify/data/CustomerDB.java` | 112 |
| CustomerOverview.java | `src/main/java/com/sportify/model/CustomerOverview.java` | 43 |
| customers.jsp | `src/main/webapp/owner/customers.jsp` | 193 |
| owner-customers.js | `src/main/webapp/assets/js/owner-customers.js` | 27 |
| owner-customers.css | `src/main/webapp/assets/css/owner-customers.css` | 205 |
| dashboard.jsp | `src/main/webapp/owner/dashboard.jsp` | 630 |
| owner-dashboard.js | `src/main/webapp/assets/js/owner-dashboard.js` | 231 |
| owner-dashboard.css | `src/main/webapp/assets/css/owner-dashboard.css` | 1.087 |
| persistence.xml | `src/main/resources/META-INF/persistence.xml` | 62 |
| reviews.jsp | `src/main/webapp/owner/reviews.jsp` | 270 |
| OwnerAccessFilter.java | `src/main/java/com/sportify/filter/OwnerAccessFilter.java` | 63 |
| DBUtil.java | `src/main/java/com/sportify/data/DBUtil.java` | 23 |
| Review.java | `src/main/java/com/sportify/model/Review.java` | 116 |
| CustomerDBValidationTest.java | `src/test/java/com/sportify/data/CustomerDBValidationTest.java` | 23 |
| CustomerDBIntegrationTest.java | `src/test/java/com/sportify/data/CustomerDBIntegrationTest.java` | 157 |
| CUSTOMERS.md | `database/CUSTOMERS.md` | 52 |

## 3. Contract HTTP → methods → inputs → outputs

`<ctx>` là `request.getContextPath()`. URL thực: GET `<ctx>/owner/customers?q=...`; không hardcode context viết hoa/thường, host/cổng. `CUSTOMERS.md:L3` nêu URL Tomcat nhưng đây là lời tài liệu, **không có xác minh deployment trong scan này**.

| Method/evidence | Input chính xác | Validation/operation | Output chính xác |
|---|---|---|---|
| `ManageCustomersServlet.doGet(request,response)` L22–55; annotation L15 | Query `q`; không lấy `ownerId` client; owner constant `1L` L18–19 | Set UTF-8; normalize q; hai DAO reads | Forward `/owner/customers.jsp`; HTML, không JSON; request attrs dưới đây |
| `CustomerDB.normalizeSearch(String value)` L81–87 | null hoặc chuỗi bất kỳ | null → `""`; `trim()`; length sau trim >100 → IllegalArgumentException; không lowercase ở đây | Chuỗi trim (giữ hoa/thường để điền lại form); không mở EM |
| `CustomerDB.requireOwnerId(Long)` private L75–79 | ownerId | null/<=0 → IllegalArgumentException | void; validation trước khi public DAO mở EM |
| `CustomerDB.findByOwnerId(Long,String)` public L15–21 | ownerId, search | requireOwnerId; normalizeSearch; DBUtil factory.createEntityManager | `List<CustomerOverview>` từ overload; có thể throw lỗi persistence |
| `CustomerDB.findByOwnerId(EntityManager,Long,String)` package-private L23–51 | EM, ownerId, search | Query projection/group/scope/filter; không lặp requireOwnerId/normalizeSearch | `getResultList()`; `finally em.close()`; **overload nhận EM cũng sở hữu việc đóng EM** |
| `CustomerDB.getSummaryByOwnerId(Long)` public L53–57 | ownerId | requireOwnerId, tạo EM | `CustomerDB.Summary`; không nhận q |
| `CustomerDB.getSummaryByOwnerId(EntityManager,Long)` package-private L59–73 | EM, ownerId | aggregate toàn owner; không lặp requireOwnerId | Object[] Number → long → Summary; finally close EM |
| `CustomerDB()` private L12–13 | Không | Không cho khởi tạo DAO từ ngoài | Static utility, không service bean |
| `CustomerDB.Summary(long,long,long)` private L94–98 | customerNameCount, reviewCount, fieldCount | Gán final fields | DTO summary, không entity/table |
| `Summary.getCustomerNameCount/getReviewCount/getFieldCount` L100–109 | Không | Trả respective final long | Getter values; không query bổ sung |
| `CustomerOverview(String,Long,Long,Double,LocalDateTime)` L14–22 | Tên, COUNT review, COUNT DISTINCT field, AVG rating, MAX time | Gán final fields, wrapper số unbox sang primitive | Read-only DTO projection; **không @Entity**, không user account |
| `CustomerOverview.getCustomerName/getReviewCount/getFieldCount/getAverageRating/getLastReviewAt` L24–41 | Không | Getter trực tiếp | String / long / long / double / LocalDateTime; không DAO/validation |
| `customers.jsp.escapeHtml(String)` L7–11 | Chuỗi có thể null | null→empty; escape &, <, >, double quote, single quote | HTML-safe text/attribute cho name, search, error; không sanitize dữ liệu DB |
| `owner-customers.js.closeSidebar()` L6–9 | DOM body/toggle | remove sidebar-open, aria-expanded=false | DOM-only; không network/DB |

### Request attributes và HTTP status

- `search`: chuỗi normalize hoặc empty nếu validation thất bại (Servlet L28–35).
- Thành công reads: `customers: List<CustomerOverview>`, `customerNameCount: long`, `reviewCount: long`, `reviewedFieldCount: long` (L38–43); **fieldCount getter DAO → reviewedFieldCount attr**, không attr `fieldCount`.
- q >100 sau trim: `errorMessage` từ validation + HTTP **400**, nhưng **vẫn query danh sách không lọc (`search=""`) và summary**, không return sớm (L30–39). View input bị reset empty, không echo lại chuỗi quá dài.
- Lỗi RuntimeException/ExceptionInInitializerError/NoClassDefFoundError trong hai DAO calls: log server; attrs list empty + ba số 0; `loadFailed=Boolean.TRUE`; errorMessage cố định; status **503** (L44–52). Nếu trước đó 400 rồi DB lỗi thì 503 thay 400. Không coi empty list/0 fallback là dữ liệu thật.
- Thành công bình thường không set status riêng (mặc định container); chưa có HTTP response đo thực tế. Missing authorization → filter redirect access trước servlet/DAO. Không có override doPost hay customer mutation route; không claim tạo/sửa/xóa tài khoản.
- JSP thiếu `customers` → redirect `<ctx>/owner/customers` và return (L15–19), direct JSP không tự query. JSP giả định ba attr Number có đủ và MAX timestamp nonnull; controller đảm bảo attrs trong hai nhánh, schema review expected NOT NULL; DTO constructor không null-safe khi unbox số.

## 4. JPQL chính xác và ý nghĩa dữ liệu

### 4.1 Danh sách theo owner + q

`CustomerDB.java:L27–47` ghép các fragment **cố định**, bind params, không nối q thành JPQL:

```jpql
SELECT NEW com.sportify.model.CustomerOverview(
  review.customerName, COUNT(review),
  COUNT(DISTINCT field.fieldId), AVG(review.rating), MAX(review.createdAt))
FROM Review review JOIN review.field field
WHERE field.ownerId = :ownerId
-- fragment chỉ thêm khi search != null && !search.isEmpty():
AND LOWER(review.customerName) LIKE :search ESCAPE '!'
GROUP BY review.customerName
ORDER BY MAX(review.createdAt) DESC, review.customerName ASC
```

- Bind `ownerId` = 1L từ servlet (public DAO có thể nhận owner dương khác, nhưng endpoint không cho client chọn).
- Bind `search` = `"%" + search.toLowerCase(Locale.ROOT).replace("!","!!").replace("%","!%").replace("_","!_") + "%"` (L43–45). Thứ tự escape `!` trước wildcard quan trọng; `%`, `_`, `!` từ input được tìm literal, không mở rộng wildcard. Dấu nháy/injection chỉ nằm trong bound value.
- Case-insensitive dựa trên LOWER phía DB và Locale.ROOT phía Java; **không bỏ dấu tiếng Việt**, không normalize Unicode/NFD như booking search JS. Không hứa tìm không dấu hoặc mọi collation locale giống nhau khi chưa chạy DB.
- GROUP BY tên nguyên bản, không theo LOWER/trim/user ID; cùng tên có thể gộp nhiều người, khác hoa/thường/khoảng trắng có thể tách tùy DB collation. Filter owner xảy ra **trước aggregate** nên tên trùng ở owner khác không đóng góp số liệu.
- `reviewCount` = số đánh giá nhóm; `fieldCount` = số sân khác nhau được nhóm đó đánh giá; average = trung bình rating reviews trong nhóm; lastReviewAt = MAX timestamp. Không phải số booking, số lượt sử dụng, tổng chi tiêu, hoặc lần đăng nhập cuối.
- Sort last review DESC rồi tên ASC, không pagination/limit. Dùng JOIN thông thường vì projection DTO không cần truy cập lazy entity sau EM.close; không bắt buộc JOIN FETCH như reviews list.

### 4.2 Summary toàn owner, độc lập q

`CustomerDB.java:L61–69`:

```jpql
SELECT COUNT(DISTINCT review.customerName), COUNT(review),
       COUNT(DISTINCT field.fieldId)
FROM Review review JOIN review.field field
WHERE field.ownerId = :ownerId
```

Ba COUNT trả Number được `.longValue()`. Khi owner không có review thì counts bằng 0 theo aggregate; expected tests không phải số liệu live. Summary **không lọc q**; `customers.size()` là số nhóm đang hiển thị còn card đầu là số tên distinct toàn owner. Sân không có review không được tính. Không cộng fieldCount các nhóm để tính summary vì cùng sân có thể được nhiều tên đánh giá.

Hai reads dùng **hai EM riêng, không transaction snapshot chung**; concurrent write có thể gây list/summary không khớp tức thời. Không begin/commit/persist/merge/executeUpdate trên đường customers production: đây là đọc aggregate, không khách hàng CRUD. JPQL do Hibernate chuyển SQL lúc chạy; chưa capture SQL runtime. SELECT trong `CUSTOMERS.md:L35–51` là SQL tham khảo cùng ngữ nghĩa, chưa thực thi.

## 5. View/JS/CSS và actual vs mock

| Vùng | Trạng thái source | Evidence/giới hạn |
|---|---|---|
| Customer rows và ba summary cards | ACTUAL-SOURCE, RUNTIME-UNVERIFIED | Servlet/DAO reads reviews + sports_fields; không customer mock array hoặc bảng customers |
| Customer account/CRM/booking history | CHƯA TRIỂN KHAI | DTO tên từ reviews, không email/phone/user ID/booking linkage; TODO DAO L25–26 |
| Search customer | ACTUAL-SOURCE | GET form `q`, maxlength100, value escaped (customers.jsp L141–149); server query, **không AJAX/DOM filter** |
| No matches / no reviews / DB failure | Có UI phân biệt source | L151–157: empty states theo search/loadFailed; retry route; error role=alert L111–113; cards `—` khi fail L118/124/130 |
| Owner identity | MOCK/DEMO | customers.jsp L55–57: identity text cố định; authorization flag demo và owner1, không account thật |
| Customer average/time | ACTUAL-SOURCE formatting | L178–181: số DTO, `vi_VN` một chữ số thập phân; dd/MM/yyyy HH:mm; datetime LocalDateTime không timezone conversion |
| Customer JS | DOM/UI-only | L1–27: sidebar toggle/close/overlay/Escape, close khi width>=851, ngày theo đồng hồ browser; không gửi/tải dữ liệu |
| Customer CSS | UI implementation, chưa browser verify | Scope `.owner-customers-page`; stats3→2 tại1100→1 tại600; input focus L66–69; table horizontal scroll L76–78; <=600 table thành row-card + data-label L160–205 |
| Shared dashboard CSS | UI dependency | Layout/sidebar/buttons/avatar/sr-only dùng chung; offcanvas<=850 L1000–1035; focus-visible L1083–1087; font/icon CDN cần mạng |
| Dashboard fields/cards/active count | ACTUAL-SOURCE như scan cũ | dashboard.jsp L26–40/188/414–490; không bị biến thành mock bởi thêm link customers |
| Dashboard bookings/revenue | MOCK như scan cũ | L192–229/284–384; JS L95–113 chỉ đổi DOM pending→confirmed/rejected, refresh reset; không customer DAO source |

Customer page không có customer status ACTIVE/INACTIVE hoặc booking pending/confirmed trong DTO. Những trạng thái này thuộc **fields DB** và **booking DOM mock**, không được trình bày như customer lifecycle. Review replied/pending thuộc reply text ở reviews.jsp L218–226, không state của tài khoản khách.

JS customers không có focus trap/restore hoặc validation submit riêng; search vẫn hoạt động bằng HTML GET nếu JS không chạy. Responsive CSS source tồn tại nhưng chưa chứng minh keyboard/screen reader/mobile đã pass.

## 6. Owner/security/reliability

1. `OwnerAccessFilter.java:L15/L40–61` bảo vệ REQUEST owner URLs, exempt access/logout; session(false) + `OWNER_DEMO_AUTHORIZED == Boolean.TRUE`. `/owner/customers` và direct `/owner/customers.jsp` nằm scope này. Không suy ra mọi FORWARD/ERROR dispatcher đã được bảo vệ.
2. Servlet owner constant1 + TODO dùng session userId/OWNER (L18–19); DAO owner predicate ở **cả list và summary**, chống lẫn owner parameter, nhưng không biến shared demo gate thành multi-user auth.
3. Không infer identity từ chat sender/name hoặc booking DOM. Review.customerName là String, Review.field là LAZY relationship SportField (`Review.java:L27–33`); customer DTO không @Entity và không cần class registration persistence.
4. Parameter binding + escape LIKE hỗ trợ chống injection/wildcard abuse; không thay thế authorization hay uniqueness identity. Package-private overload bỏ validation công khai; tests/nội bộ phải cung cấp owner/search hợp lệ, và EM sẽ bị đóng.
5. XSS: customers.jsp escape tên L175, q attribute L145 và error L112; typed aggregate/time không nội suy chuỗi user vào JS. owner-customers.js dùng textContent ngày, không innerHTML user data. Không khẳng định toàn hệ thống an toàn: dashboard data-sport-type vẫn raw L447, chat/privacy/CSRF issues trong scan cũ chưa được sửa bởi customers.
6. Search length100 sau trim; Java String.length đếm UTF-16 code units, không phải grapheme; HTML maxlength không đủ nếu bypass. Không rate limit/pagination, LIKE contains + aggregate có thể tốn tài nguyên; chưa đo execution plan/index live.
7. Read-only customers không cần write transaction mới; các mutation fields/reply/access và logout GET vẫn có hạn chế CSRF/session rotation đã nêu trong scan cũ. Không có security upgrade chỉ vì thêm menu.
8. Persistence chung `sportifyPU` + hbm2ddl validate: thiếu/mismatch Review schema có thể làm EMF khởi tạo thất bại; customers bắt initializer/classdef errors rồi503, không dùng mock cứu lỗi. Log server/SQL logging có thể chứa dữ liệu; không chép credentials/log nhạy cảm vào docs.
9. Chưa biết DB collation/schema thật, index/query cost, actual cookies/TLS/timeout, status HTTP thực, JSP compile hay runtime constructor-projection compatibility. Static query đúng mục đích không phải bằng chứng chạy thành công.

## 7. Luồng customers đúng 13 bước (trace source, không log runtime)

1. Browser bấm Khách hàng trên dashboard (`dashboard.jsp:L104–107`) hoặc reviews (`reviews.jsp:L105–108`), gửi GET `<ctx>/owner/customers`; form search gửi cùng route với `q` (customers.jsp L141–149).
2. Container định tuyến `@WebServlet("/owner/customers")` (ManageCustomersServlet L15); OwnerAccessFilter mapping `/owner/*` áp dụng cho request.
3. Filter kiểm tra session boolean; thiếu quyền redirect `<ctx>/owner/access` và dừng trước DAO, có quyền chain tiếp (Filter L49–61).
4. Servlet doGet đặt request/response UTF-8; chọn owner demo1, không nhận ownerId client (Servlet L18–26).
5. Servlet lấy q và normalize trim/null→empty/max100; quá dài set400/error, giữ search empty nhưng vẫn tiếp tục đọc (Servlet L28–35; DAO L81–87).
6. Public `findByOwnerId(owner1,search)` validate owner/search rồi lấy DBUtil factory `sportifyPU`, tạo EM (DAO L15–20; DBUtil L8–16).
7. Overload dựng constructor projection JOIN Review.field, WHERE owner và optional LOWER LIKE ESCAPE, GROUP BY tên, sort MAX time DESC/name ASC (DAO L27–37).
8. Query bind ownerId và search đã lower/escape !,% ,_; lấy List<CustomerOverview> và finally đóng EM (DAO L39–50; DTO L14–22).
9. Servlet gọi summary owner1; public DAO validate, tạo EM khác, COUNT distinct tên/review/distinct sân **không q** (Servlet L39; DAO L53–67).
10. Summary converts Number→long, tạo Summary rồi finally close EM; servlet set customers và ba attrs thống kê (DAO L68–72; Servlet L40–43).
11. Nếu hai reads lỗi, catch log + empty/zero + loadFailed/error và503; nếu không lỗi giữ dữ liệu/status trước đó; luôn forward `/owner/customers.jsp` (Servlet L44–55).
12. JSP đọc request attrs, render summary/notice/search/empty hoặc table, escape name/q/error; fail dùng dấu— và retry, không gọi 0 fallback là data (customers.jsp L15–27/111–181).
13. JS chỉ sidebar/ngày; user tìm lại/xóa tìm kiếm/retry là GET mới query DB, không POST customer write; từ trang có link reviews/fields/logout, không biến tên thành customer account (JS L1–27; JSP L61–85/148/156).

## 8. Delta so với BACKEND_SCAN / FRONTEND_SCAN cũ

| Claim/snapshot cũ | Điều cần bổ sung hoặc sửa cách diễn đạt hiện tại |
|---|---|
| BACKEND §1/§2/§8: 17 Java production; §11: 2 tests | Inventory hiện20 Java main,4 test; thêm ManageCustomersServlet/CustomerDB/CustomerOverview và2 customer tests. Kết luận “không nối user input thành query trong17file” là phạm vi cũ, không tự mở rộng toàn codebase; customers được kiểm tra riêng và cũng bind params |
| BACKEND §3 route map chỉ fields/reviews/chat/access | Thêm GET `/owner/customers`, q, attrs, 400 fallback-unfiltered và503 như contract trên; không thêm write endpoints |
| FRONTEND §1:19 JSP/CSS/JS | Hiện22; bổ sung193-line JSP,205-line CSS,27-line JS customers. Inventory README/PROJECT_STATUS cũ không phải scope srcmain |
| Dashboard customer/review entry links chưa được mô tả như route customers mới | Git diff **working tree vs index** cho dashboard đúng hai href: placeholder `#booking-section` → `<ctx>/owner/customers` và `<ctx>/owner/reviews` (L104/L108). Reviews JSP hiện có customers link L105; không có hash baseline cũ để chứng minh mọi thay đổi reviews byte-by-byte |
| BACKEND §2 đã nói persistence đăng ký Review | Working tree hiện đúng: ChatMessage/SportField/Review L20–22; diff vs index có thêm Review, nhưng đây **không phải claim mới trái BACKEND**, vì BACKEND đã mô tả working source lúc quét. Không nói customers đăng ký entity CustomerOverview: DTO không entity, không có class này trong PU |
| Dashboard fields/persistence lớn khác HEAD | Diff staged vs HEAD chứa implementation fields/gate đã được scan cũ mô tả. Không nhận các diff staged đó là tất cả “mới sau scan”. Line count dashboard630/JS231/CSS1087 vẫn trùng bảng scan cũ; trùng count không chứng minh nội dung hash giống |
| BACKEND §1/§6/§8/§11 dẫn `database/reviews.sql`, `database/README.md` | **Hai path không tồn tại ở snapshot hiện tại.** database chỉ `CUSTOMERS.md`52 dòng. Những DDL/index/seed/migration-file claims là evidence snapshot cũ, không được nói repo hiện còn các file đó. Entity Review vẫn tồn tại và PU validate, nhưng không lấy tài liệu cũ làm schema live evidence |
| FRONTEND/ BACKEND chưa có customer summaries | Thêm aggregate review-based read model và3 cards; không customer/user table, booking/payment source hay account auth |
| Booking mock, owner demo1, chat identities/tính realtime | Chưa bị customers thay đổi. Không gộp booking DOM/customerName/chat names thành identity. Giữ giới hạn cũ, không nhận booking là đóng góp cá nhân |
| BACKEND §11 không thấy tests fields/access/chat | Hai test mới customers không phải tests fields/access/chat; cần ghi “có customer tests nguồn nhưng chưa chạy”, không suy ra toàn hệ thống được coverage/pass |

Không có source manifest của lần scan cũ trong hai MD để so sánh SHA256 trước/sau. `SOURCE_MANIFEST.json` mới là **baseline hiện tại**, không chứng minh ai tạo code, thời điểm implementation hoặc runtime status. Phạm vi đóng góp người dùng được khai báo là owner fields/dashboard, chat, reviews; **không tự quy customers là đóng góp cá nhân**, không nhận booking. Cần evidence tác giả riêng nếu muốn claim.

## 9. Test source đã đọc, KHÔNG chạy

- `CustomerDBValidationTest`: `rejectsMissingOwnerBeforeOpeningConnection` L7–10; `rejectsInvalidOwnerForSummary` L12–15; `rejectsOversizedSearchBeforeOpeningConnection` L17–22. Assertions expected IllegalArgumentException trước mở kết nối, không test HTTP/filter/JSP.
- `CustomerDBIntegrationTest`: opt-in `sportify.reviewTestUrl`, thiếu thì Assume skip (L33–36); **INSERT sports_fields/reviews fixtures** L45–66, factory L68–73; cleanup **DELETE** reviews/field L76–94. Không chạy dù tên “test” vì có write DB.
- `aggregatesOnlyOwnedReviewsForEachName` L96–110: cùng tên multi-field/foreign-owner, rating/sort; `searchesNamesWithoutExpandingLiteralWildcards` L112–124: %,_,!, uppercase, injection-string empty expected; `summaryCountsOwnedNamesReviewsAndDistinctFields` L126–132; `returnsEmptyResultsForOwnerWithoutReviews` L134–141.
- Expected fixture list6, summary6 tên/7 reviews/2 sân trong test **không phải kết quả query live**, không điền vào viva như dữ liệu đã xác nhận. Test gọi package-private EM overload, chưa chứng minh public DBUtil path/filter/servlet400/503/output-XSS/browser/accessibility. Literal HTML payload lưu/tìm không đồng nghĩa browser XSS test pass.

## 10. Câu trả lời viva và checklist chưa xác minh

- “Khách hàng lấy từ đâu?” → JPA JOIN reviews với sân owner1, GROUP BY customerName, projection read-only; chỉ tên đã đánh giá, không mọi khách đã booking.
- “Tìm theo tên có dùng JavaScript?” → GET q đi server, parameterized LIKE contains có escape wildcard; JS riêng chỉ sidebar/ngày.
- “Vì sao lọc tên mà card tổng không đổi?” → list nhận q, summary không nhận q, tính toàn reviews owner.
- “Hai người trùng tên?” → có thể gộp, vì chưa có stable customer ID; không suy danh tính từ chat/booking mẫu.
- “Khách hàng có lưu thêm DB không?” → trang này read-only, không customer insert/update/delete hoặc migration bảng mới; phụ thuộc reviews/sports_fields có sẵn, schema thực chưa xác nhận.
- “Đã chạy chưa?” → chỉ source+hash inventory, chưa Tomcat/query/test; không đưa fixture expectation thành kết quả.

Nếu được cấp scope runtime riêng: xác minh deployment/context thật, schema reviews/sports_fields, constructor JPQL, owner scope cùng tên ở2owners, q max100/101 và wildcard literal, summary độc lập q,400/503 distinction, mobile/keyboard/escape và readback source hash trước demo. Không thực hiện các bước đó trong nhiệm vụ docs-only này.
