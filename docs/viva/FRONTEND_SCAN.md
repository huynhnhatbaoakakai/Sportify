# Sportify — Frontend viva map (đọc source, chưa kiểm chứng runtime)

## 1. Phạm vi và cách hiểu trạng thái

Root: `D:/Projects/Sportify`. Đã đọc toàn bộ 19 file JSP/CSS/JavaScript nguồn và toàn bộ `README.md`, `PROJECT_STATUS.md` (21 file, 6.155 dòng theo Python `splitlines()`, gồm cả dòng trống). Đọc thêm đầy đủ controller/filter/DAO/model liên quan, `pom.xml`, `WEB-INF/web.xml` để nối giao diện với backend. Không coi `target`, `.git`, cache Maven `.review-checks-21de7108` là source sản phẩm. Không đọc/chép cấu hình kết nối có thông tin nhạy cảm vào báo cáo.

**DONE** dưới đây nghĩa là có implementation trong source, KHÔNG đồng nghĩa đã chạy thành công. **PARTIAL** nghĩa là UI/luồng có nhưng thiếu integration, quyền hoặc nghiệp vụ. **PLANNED** nghĩa là tài liệu/placeholder, không có implementation tương ứng trong tập source hiện tại. Không chạy Tomcat, browser, Maven hay query DB trong lượt scan này; mọi demo bên dưới là đề xuất cần thực hiện, không phải test đã pass.

Phạm vi trình bày cá nhân theo yêu cầu: owner dashboard, quản lý thông tin/trạng thái sân, chat và owner reviews. Không nhận booking là đóng góp cá nhân; phần booking trên dashboard chỉ được phân tích để tránh nói quá chức năng. Source hiện tại không chứng minh tác giả cá nhân; cần đối chiếu lịch sử Git/đóng góp riêng nếu hội đồng hỏi ai làm.

### Danh mục đã đọc hết

| File (path tương đối root) | Dòng `splitlines()` | Vai trò |
|---|---:|---|
| `README.md` | 12 | Danh sách trang còn thiếu (đã lỗi thời so với source) |
| `PROJECT_STATUS.md` | 44 | Snapshot giai đoạn dashboard mock |
| `src/main/webapp/index.jsp` | 418 | Landing, danh mục/card tĩnh, tìm kiếm DOM |
| `src/main/webapp/home.jsp` | 301 | Home giả lập sau login, kênh chủ sân |
| `src/main/webapp/login.jsp` | 199 | Form login, CSS inline |
| `src/main/webapp/login-process.jsp` | 7 | Redirect giả, không xác thực |
| `src/main/webapp/register.jsp` | 178 | Form register, CSS inline |
| `src/main/webapp/register-process.jsp` | 7 | Redirect giả, không tạo user |
| `src/main/webapp/profile.jsp` | 357 | Profile tĩnh/form chưa nối backend |
| `src/main/webapp/chat.jsp` | 611 | Message DB do servlet forward + sidebar mock |
| `src/main/webapp/chat-friends.jsp` | 522 | Chat bạn bè mock JavaScript |
| `src/main/webapp/owner/dashboard.jsp` | 630 | Fields DB + booking/metric mock |
| `src/main/webapp/owner/reviews.jsp` | 270 | Reviews DB, lọc, phản hồi |
| `src/main/webapp/WEB-INF/views/owner-access.jsp` | 80 | Form cổng owner demo |
| `src/main/webapp/assets/js/app.js` | 67 | Search/filter landing |
| `src/main/webapp/assets/js/owner-dashboard.js` | 231 | Sidebar, booking DOM, modal field POST |
| `src/main/webapp/assets/js/owner-reviews.js` | 58 | Sidebar, validate reply, pageshow |
| `src/main/webapp/assets/css/style.css` | 626 | Shared landing/auth/home/chat/profile |
| `src/main/webapp/assets/css/owner-dashboard.css` | 1087 | Owner layout, fields/modal, responsive |
| `src/main/webapp/assets/css/owner-reviews.css` | 266 | Review-specific styles |
| `src/main/webapp/assets/css/owner-access.css` | 184 | Owner gate styles |

Dòng số trích dẫn dưới đây theo file nguồn; một số reader bỏ dòng trống cuối file nên tổng hiển thị có thể lệch một dòng, không làm thay đổi vị trí evidence.

## 2. Kết luận cần nói đúng khi viva

- **DONE ở mức source:** field list/create/update/toggle có JPA transaction; reviews list/filter/count/average/reply có DAO và owner restriction; service chat insert/read có JPA. Đây là đường đi DB thật, không phải browser-only array. Chưa khẳng định PostgreSQL đang chạy hay schema hiện tại đầy đủ.
- **PARTIAL:** owner được cố định `DEMO_OWNER_ID = 1L`; cổng owner dùng shared password và session boolean, chưa user/role auth. Fields có Create/Read/Update và đổi trạng thái, **không có Delete**; không gọi là CRUD đầy đủ nếu hiểu D là xóa.
- **PARTIAL:** `chat.jsp` có DB body nhưng sidebar ba hội thoại vẫn mock, không có handler chọn hội thoại; không realtime, không bảo vệ danh tính sender/receiver.
- **PARTIAL:** login/register chỉ redirect; profile không lưu; home identity/statistics tĩnh. Các URL JSP công khai không yêu cầu login thật.
- **DONE UI/mock, không DONE nghiệp vụ booking:** lọc và xác nhận/từ chối chỉ sửa DOM, refresh khôi phục. Không nói đã lưu booking/đã tính doanh thu thật.
- **PLANNED/không thấy file tương ứng:** `services.jsp`, `service-detail.jsp`, `booking.jsp`, `my-bookings.jsp`, dashboard shop/trainer/admin trong README. Không suy diễn chúng tồn tại từ nút/href placeholder.
- `README.md:1–12` vẫn ghi login/register/dashboard còn thiếu, trong khi file đã có. `PROJECT_STATUS.md:39–44` ghi chỉ fake data, không PostgreSQL/Servlet/DAO; **đã mâu thuẫn source hiện tại**. Khi viva ưu tiên code, nói đây là snapshot cũ, không dùng nó để khẳng định toàn bộ hệ thống mock.
- Stack thực tế trong `pom.xml:16–20,32–52`: source/target **Java 17**, Jakarta Servlet API 6.1.0 provided, Hibernate 7.4.6.Final, PostgreSQL driver 42.7.13, WAR `sportify` (`56–57`). Không nói Java 8. `WEB-INF/web.xml:2–10` vẫn namespace Java EE/version 4.0, cần kiểm chứng tương thích container; chưa có runtime evidence để kết luận chạy/không chạy.

## 3. Bản đồ form → route → parameter → kết quả

Các path JSP dưới bảng đều bắt đầu `src/main/webapp/`; các servlet bắt đầu `src/main/java/com/sportify/controller/`. `<ctx>` = `request.getContextPath()`, không phải chuỗi cố định `/sportify`.

| Evidence form | Method/action | Parameter thực sự gửi | Backend/interaction |
|---|---|---|---|
| `index.jsp:77–85` | Không khai báo method/action (mặc định GET trang hiện tại nếu JS không chạy) | Input chỉ có id, **không name** | `app.js:51–54` preventDefault rồi `filterServices`; không query DB |
| `login.jsp:163–182` | POST `login-process.jsp` (relative) | `email`, `password`, `remember` nếu checked (không value nên mặc định `on`) | `login-process.jsp:3–5` bỏ qua mọi param, redirect `<ctx>/home.jsp`; không session/user/password check |
| `register.jsp:139–161` | POST `register-process.jsp` (relative) | `fullname`, `email`, `password`, `confirm_password` | `register-process.jsp:3–5` redirect `<ctx>/login.jsp?registered=true`; không INSERT, không so sánh password |
| `profile.jsp:308–349` | POST `#` | Không field nào có `name`, nên các giá trị profile không được serialize | Không controller/lưu DB; nút Hủy chưa có handler |
| `WEB-INF/views/owner-access.jsp:60–72` | POST `<ctx>/owner/access` | `password` | `OwnerAccessServlet.doPost:47–75`: đúng → set session boolean và redirect fields; sai → request errorMessage rồi forward view |
| `owner/dashboard.jsp:473–486` | POST `<ctx>/owner/fields/toggle` | hidden `fieldId` | `ToggleFieldStatusServlet.doPost:18–57`; DAO toggle; redirect `?success=toggled#fields`; invalid ID 400 |
| `owner/dashboard.jsp:527–624` | POST `<ctx>/owner/fields/create` hoặc `/update` do JS đổi action | `fieldId` (trống khi create), `fieldName`, `sportType`, `address`, `pricePerHour`, `status`, `openTime`, `closeTime` | `CreateFieldServlet.doPost:29–126`, `UpdateFieldServlet.doPost:29–120`; redirect success/error về fields |
| `owner/reviews.jsp:192–203` | GET `<ctx>/owner/reviews` | `rating` (trống hoặc 1–5) | `ManageReviewsServlet.doGet:22–53`, `parseRating:56–62`; lấy DB theo filter, forward view |
| `owner/reviews.jsp:249–259` | POST `<ctx>/owner/reviews/reply` | hidden `reviewId`, hidden `rating`, textarea `ownerReply` | `ReplyReviewServlet.doPost:18–57`, giữ filter qua `ratingQuery:60–62`; PRG success/error |
| `chat.jsp:477–499` | POST `<ctx>/chat` | hidden `senderName`, `receiverName`, `messageText` | `ChatServlet.doPost:50–87`: trim/nonblank → insert → URL-encode names → redirect GET conversation |
| `chat-friends.jsp:367–370` | Không form; onclick/onkeypress | Không HTTP params | `sendMessage` sửa array rồi render; không fetch/XHR/DB |

### Contract dữ liệu và validation fields

`owner/dashboard.jsp:538–608`: tên required/max150; address required/max255; enum sport `GYM/BASKETBALL/SWIMMING/PICKLEBALL`; price number/min1000/step1000; status `ACTIVE/INACTIVE`; time required mặc định 06:00–22:00. Không có form description/imageUrl dù model có (`SportField.java:38–56`).

`owner-dashboard.js:142–164` `openFieldModal(card)` reset form, đọc card DOM/data-* để prefill, đổi `fieldForm.action` theo `dataset.createAction/updateAction`; hidden fieldId từ card. `196–207` chặn close <= open, disable nút khi submit; submit hợp lệ là POST HTML bình thường, **không AJAX**. `187–194` toggle cũng POST bình thường.

`CreateFieldServlet:37–95` và `UpdateFieldServlet:55–92` validate required/enum/BigDecimal >0/LocalTime đóng sau mở, status khác INACTIVE mặc định ACTIVE. HTML min/step1000 **chặt hơn backend >0**; backend không enforce maxlength150/255 trong các servlet này. Thời gian sai parse có thể không vào catch IllegalArgumentException như kỳ vọng (cần runtime negative test), không khẳng định mọi lỗi đều hiện toast. Không hỗ trợ giờ đóng qua nửa đêm với quy tắc close > open hiện tại.

`SportFieldDB.findByOwnerId:15–34`: owner filter, mới nhất theo createdAt DESC. `insert:67–85`: persist/commit/rollback/close. `update:87–147`, `toggleStatus:149–185`: kiểm tra owner trong DAO. Update servlet lấy field bằng `findByIdAndOwnerId`, 404 nếu không có (`UpdateFieldServlet:37–53`). **Giới hạn:** servlet update/toggle bỏ qua boolean DAO trả về; toggle ID không tồn tại/khác owner có thể vẫn redirect success dù không đổi row. Đây không phải bypass ownership, mà là báo kết quả sai. `dashboard.jsp` không đọc `success/error` query nên field validation redirect cũng không có notice tương ứng.

## 4. Request/session, forward/redirect — giải thích bằng source

### Owner

1. Home link `home.jsp:240–243` → GET `/owner/access`.
2. `OwnerAccessFilter.java:15,40–61` áp dụng `/owner/*`; whitelist `/owner/access`, `/owner/access/logout`; còn lại cần session `OWNER_DEMO_AUTHORIZED == Boolean.TRUE`, không có thì redirect access. Dùng `getSession(false)` không tạo session chỉ để kiểm tra.
3. `OwnerAccessServlet.java:25–43`: đã được phép → redirect fields; chưa → forward `/WEB-INF/views/owner-access.jsp` (view không truy cập trực tiếp theo URL công khai). POST đúng password demo hardcoded → tạo/get session, set boolean (`54–65`); sai → `request.errorMessage` và forward (`69–75`). Không đưa giá trị password demo vào tài liệu.
4. `ManageFieldsServlet.java:26–34`: query owner 1 → request `fields`, `ownerId` → forward `/owner/dashboard.jsp`. JSP chỉ đọc `fields` (`dashboard.jsp:24–32`), không dùng ownerId để render identity. Truy cập dashboard.jsp trực tiếp khi đã qua filter nhưng thiếu request fields → redirect `/owner/fields`; có `return` để dừng render.
5. POST field → redirect GET fields → query lại DB → forward JSP. PRG tránh refresh trang GET gửi lại POST, nhưng không thay thế chống double submit phía server.
6. `OwnerAccessLogoutServlet.java:23–31`: chỉ remove boolean rồi redirect home, **không invalidate toàn session**. Logout là GET link (`dashboard.jsp:125`, `reviews.jsp:123`). `home.jsp:245–248` "Đăng xuất" chỉ link index, không clear owner session.

**Phân biệt:** forward giữ cùng request/attributes và URL servlet; redirect làm browser request mới, attributes cũ mất, query success/error còn. `#fields` là fragment browser dùng cuộn, server không nhận nó như parameter. Session tồn tại qua request nhưng hiện chỉ chứng minh quyền demo, không userId/role.

### Reviews

`ManageReviewsServlet.java:28–53` nhận rating, invalid nonblank → HTTP400 + request error nhưng vẫn nạp danh sách không lọc; DAO lỗi → HTTP503, empty list, zero attributes, `loadFailed=true`, errorMessage rồi forward. Request view gồm `reviews`, `selectedRating`, `totalReviews`, `averageRating`, `loadFailed`, `errorMessage`.

`owner/reviews.jsp:22–55` đọc attributes, thiếu reviews → redirect route; map query `error=empty/length/invalid/notfound/save` sang câu tiếng Việt cố định. `156–160` render error hoặc `success=replied`; không echo raw error query. Summary `162–180` hiển thị dấu `—` khi loadFailed/no rating data phù hợp, không giả lỗi DB thành zero reviews bình thường.

`ReplyReviewServlet.java:24–57`: validate ID số dương, reply nonblank <=2000, DAO lưu, redirect với `success=replied` hoặc error, giữ rating. `ReviewDB.java:28–49`: JOIN FETCH field (model quan hệ LAZY), owner filter, optional exact rating, sort createdAt DESC/reviewId DESC. `getSummaryByOwnerId:58–74` COUNT/AVG trên **mọi review của owner**, không dùng rating filter. `saveOwnerReply:76–124` trim, transaction UPDATE có ownership predicate ngay trong update, update repliedAt; sửa phản hồi cũ thay vì thêm reply thread. UI không tạo review của khách hay xóa review.

### Login/register và chat

`login-process.jsp` và `register-process.jsp` không gọi `getParameter`, DAO hoặc `session.setAttribute`. `registered=true` cũng không được login.jsp đọc để báo thành công. Browser required/email/minlength chỉ validation UI; confirm_password không được so khớp ở JS/server. Có thể vào home.jsp thẳng; lời chào Khoa là static (`home.jsp:258–292`). Không gọi login/register là auth thật.

`ChatServlet.java:16,22–46`: GET `/chat?sender=...&receiver=...`; fallback `Khách hàng`/`Sân bóng Sunrise` nếu null/blank qua `getValueOrDefault:89–98`; query hai chiều rồi set request `sender`, `receiver`, `messages`, forward `/chat.jsp`. `ChatMessageDB.java:38–64`: JPQL hai chiều sender↔receiver, ORDER BY sentAt ASC, bind params, close EntityManager. POST lấy **tên từ form**, không lấy user từ session; nonblank message insert (`67–74`), URL encode (`76–86`), redirect. `ChatMessage.java:14,24–34`: bảng `chat_messages`, name length100, message length1000, thời điểm mặc định LocalDateTime.now(). Đây là DB pathway, không phải websocket.

**Sai entrypoint đáng chú ý:** `home.jsp:221`, `profile.jsp:267`, `chat-friends.jsp:315` link **`/chat.jsp`**, không `/chat`. Direct JSP không gọi DAO; messages null và hiện empty (`chat.jsp:26–43,451–474`), hidden names fallback. Gửi lần đầu sẽ POST `/chat`, rồi redirect đúng route và nạp history. Demo DB phải mở `/chat` ngay từ đầu.

## 5. Dashboard metrics: nguồn số nào thật?

| Metric/evidence | Nguồn và mức độ |
|---|---|
| Sân đang hoạt động (`dashboard.jsp:34–40,180–190`) | Đếm fields DB của owner1 có status ACTIVE (ignoreCase). JS `updateActiveFieldCount:137–140` đếm rendered cards data-status active. Không đếm mọi sân mọi owner |
| Lịch đặt hôm nay (`192–202`) | Số **12 hardcoded**, không query/count bảng, không derived từ 6 row |
| Chờ xác nhận (`204–214`, welcome/sidebar) | Initial4; JS `updatePendingCount:61–67` đếm pending trong 6 row DOM. Confirm/reject chỉ làm số này thay đổi tại browser |
| Doanh thu hôm nay (`216–229`) | **4.850.000đ và +12,5% hardcoded**; không sum DB, không payment/revenue backend |
| Booking rows (`284–384`) | 6 row tĩnh: SP1024, SP1025, SP1022, SP1026, SP1018, SP1027; 4 pending/1 confirmed/1 completed. JS `40–48` đổi ngày theo today + dateOffset, không fetch lịch |
| Review tổng/điểm (`reviews.jsp:162–180`) | COUNT/AVG DB owner1, thống kê không bị lọc rating; có empty/error distinction |
| Home (`home.jsp:273–293`) | 2 lịch sắp tới, 5 chưa đọc, 12h tập là text tĩnh, không session/DB |

`owner-dashboard.js:69–80` filterBookings kết hợp status + normalized keyword, hidden row và cập nhật visible/total. `95–113` event delegation confirm/reject chỉ đổi dataset, badge, replaceChildren và toast; **không form POST/fetch/API**, không persist, reload reset. Nhãn "Dữ liệu minh họa" (`dashboard.jsp:173–176`) không có nghĩa fields cũng mock; trang đang trộn DB và mock.

## 6. JavaScript và CSS: giải thích được từng chức năng

### JavaScript ngoài JSP

- `assets/js/app.js:9–15` `normalizeText`: lowercase, NFD bỏ dấu, đ→d. `17–49` `filterServices`: trim, match substring với card.dataset.search, đổi hidden, đếm visible. **Bug source xác định:** `39` dùng `query` nhưng không khai báo trong file/hàm; submit truyền `keyword`, nên có thể ReferenceError sau khi card đã bị hide/show, trước resultMessage/emptyState/scrollIntoView. Không khẳng định đã test browser. `51–67`: submit/chọn filter/clear gọi cùng hàm. Landing có 7 card tĩnh (`index.jsp:225–375`), detail buttons không có listener/link, CSS link lặp (`20–25`).
- `assets/js/owner-dashboard.js`: `showToast:9–14` textContent + 3,5s; `closeSidebar:16–19` và handlers21–32; date34–48; `normalizeSearch:56–59`; `updatePendingCount:61–67`; `filterBookings:69–80`; notification115–117; `updateActiveFieldCount:137–140`; `openFieldModal:142–164`; `closeFieldModal:166–170`; handlers172–207; Escape + Tab trap209–226; init228–230. Focus restore có kiểm tra isConnected; Tab trap chỉ button/input/select (có thể include hidden input fieldId, cần test keyboard); không tự assume accessibility hoàn chỉnh.
- `assets/js/owner-reviews.js`: `closeSidebar:7–10`, sidebar12–23, ngày25–28. Reply submit30–44 dùng trim và setCustomValidity/reportValidity, disable submit; input45–47 clear validity. `pageshow:51–57` restore buttons khi history/bfcache, label theo details summary. Dashboard JS chưa có restore pageshow tương tự.

### JavaScript inline

- `chat.jsp:504–551` array 3 mock conversation. `renderChatList:555–581` render sidebar preview bằng innerHTML; `updateHeader:583–600` lấy c1, đổi text/class/avatar. DOMContentLoaded602–608 gọi cả hai và scroll. **Không có selectConversation click handler**, không render mock message array vào body; body là JSP messages DB. Header luôn mock c1, có thể không khớp receiver GET tùy chọn. Search input/attach button là UI chưa hoạt động.
- `chat-friends.jsp:375–413` mock 3 conversations. `renderFriendList:417–441`; `renderFriendMessages:443–461`; `updateFriendHeader:463–476`; `selectConv:478–483`; `sendMessage:485–505` trim rồi push array/time, rerender; `handleEnter:507–511`; onload513–517. Không localStorage/fetch/DB. **Cần kiểm chứng JSP EL:** nhiều template dùng `\${...}` (`426–457`), nhưng timeStr493 dùng `${...}` không escape, và page không `isELIgnored=true`; JSP có thể can thiệp biểu thức JavaScript/compile lỗi. Không kết luận hành vi HTML trả về chỉ từ nhìn raw JSP.

### CSS (đã đọc toàn bộ, không chỉ selector search)

- `style.css:16–27` token xanh/background/border/shadow; grid/card/header/footer; responsive900px `483–500`, 600px `502–537`; cuối file override icon/image/header `538–626`. Header landing dùng `.header-menu` nhưng responsive rule 900 chỉ hide `.nav-links`, nên cần kiểm tra landing overflow ở màn nhỏ. Shared CSS không có breakpoint cho sidebar inline280px của home/profile/friends hay chat sidebar320px; các trang này còn body height100vh/overflow hidden, nên không coi responsive tốt như owner.
- `owner-dashboard.css:3–15` tokens, sidebar fixed260px `70–84`, main margin-left `220–223`, stats4col `370–375`, booking min-width980px và horizontal scroll `519–527`, fields2col `733–737`, modal `865–882`, `[hidden] display:none!important` `856–858`, body lock860–863, toast954–974. Breakpoint1100 stats2col/topbar identity hidden (`990–998`), 850 sidebar offcanvas + overlay (`1000–1035`), 600 single-col fields/form/stats và compact (`1037–1081`); focus-visible1083–1087. CSS chủ động giữ bảng rộng cuộn ngang, không chuyển row thành card.
- `owner-reviews.css`: scope `.owner-reviews-page` tránh đụng trang khác; summary2col1–3; notice success/error5–23; card overflow-wrap87–94; comment/reply white-space pre-wrap162–167 giữ xuống dòng; textarea resize/focus216–234; responsive600242–266 single-column/full-width submit.
- `owner-access.css`: tokens3–13; body min-width32021–29; card centered/grid41–55; error92–101; focus/CTA124–155; breakpoint520170–184. Không JS riêng; lỗi server render qua request.
- Auth/home/chat/profile vẫn có CSS inline riêng trong JSP; duplication sidebar giữa home/profile/friends, không shared JSP include. Owner fonts Google CSS import + Material Symbols CDN: offline demo có thể mất font/icon, không đồng nghĩa DB hỏng.

## 7. XSS, context path, quyền và giới hạn phải nhận

### XSS/context escaping

1. `dashboard.jsp:10–20` escapeHtml 5 ký tự; render tên/address/sport label bằng escapeHtml (`453–460`). Nhưng `data-sport-type="<%= field.getSportType() %>"` (`447`) **không escape attribute**. Form enum giảm rủi ro dữ liệu từ route bình thường nhưng row DB có dữ liệu không tin cậy vẫn là sink; không nói toàn dashboard an toàn tuyệt đối. ID/price/time typed values không cùng rủi ro chuỗi tùy ý.
2. `reviews.jsp:10–19,223–254` escape field/customer/comment/reply cả text/textarea. Escape `<` ngăn đóng textarea; CSS pre-wrap không phải sanitize. Query error map sang string cố định và escape (`34–55,157`), success match literal. Rating/ID typed integer/long.
3. `chat.jsp:6–17,467,482–485` escape message text và hidden identity attributes. `isELIgnored=true` (`21`) bảo toàn `${...}` JS template trong trang này. Header/sidebar innerHTML chỉ nhận mock literals hiện tại; nếu đổi thành DB/user content phải đổi sink hoặc escape.
4. `chat-friends.jsp:429–457` dùng innerHTML cho preview/msg text, `sendMessage` đưa user input vào array. Đây là **sink DOM XSS tiềm tàng** khi interpolation thực sự hoạt động; trước khi khẳng định exploit đang chạy phải xác minh JSP EL/backslash render. Nếu `${...}` giữ nguyên literal thì UI interpolation hỏng, không phải bằng chứng đã chống XSS. Khuyến nghị textContent/createElement thay vì nội suy text vào HTML.
5. `WEB-INF/views/owner-access.jsp:6–16,54–57` escape errorMessage. JSP `<%= ... %>` không tự escape; escaping HTML không tự bảo vệ JavaScript/URL context. Không copy password/DB credential/secret vào docs.

### Context path và authorization

- Các asset và owner/chat actions dùng request.getContextPath nên hỗ trợ context khác `/sportify`; servlet redirect cũng thêm ctx. `login/register` action relative hoạt động với URL JSP hiện tại ở root nhưng phụ thuộc nơi serve view. Không thay bằng `/owner/...` host-root cứng khi nói cách triển khai.
- Context path **không sửa** link `/chat.jsp` bỏ qua controller; đó là routing/data-contract issue riêng.
- Owner gate shared password hardcoded (`OwnerAccessServlet:15–19`) + boolean session: không account auth, không role OWNER, không đổi session ID sau grant; DAO scope owner1 cố định. `ManageReviewsServlet:18–19` và `ReplyReviewServlet:14–15` TODO dùng session userId/role. Logout GET và POST write forms không CSRF token trong source đọc. Production cần auth/role, rotation session, CSRF/rate-limit, không chỉ hide menu.
- Chat names đều từ GET/hidden POST, không auth; người gọi có thể đổi sender/receiver để đọc/ghi conversation tên khác. Bind JPQL parameters ngăn ghép chuỗi SQL injection, **không** ngăn impersonation. Không có websocket/polling/read receipt/delivery ack/attachment implementation.
- Chat frontend maxlength1000 nhưng servlet chỉ trim/nonblank, không kiểm độ dài message/name; entity column length không thay validation thân thiện. Fields success query có thể không phản ánh mutation vì bỏ qua boolean DAO; reviews có checking cập nhật1row tốt hơn.

## 8. Demo đề xuất cụ thể (chưa chạy; không tự sửa dữ liệu sản phẩm)

Dùng DB/demo environment được phép, field/review thử nghiệm có thể phục hồi; không thao tác dữ liệu thật trong buổi bảo vệ. `<ctx>` lấy theo deployed WAR, ví dụ `/sportify` chỉ là ví dụ, chưa xác minh deployment.

### A. Owner dashboard và quản lý sân — phần chính

1. Incognito mở `<ctx>/owner/fields`: mong đợi redirect access do chưa có boolean session. Nhập sai password demo: mong đợi view cùng URL access có thông báo escaped. Dùng thông tin truy cập demo được quản lý riêng, không chiếu secret lên slide/docs.
2. Sau grant: route `/owner/fields`, field cards lấy DB; chỉ vào vùng Quản lý sân, giải thích controller forward + request fields. Nói bốn metric có **một metric fields DB**, hai số hardcoded và pending DOM mock.
3. Thêm sân `Viva Pickleball`, sport PICKLEBALL, địa chỉ `Sân demo`, giá200000, 06:00–22:00, ACTIVE. Network cần POST create → redirect GET fields; refresh vẫn có sân mới; đối chiếu row demo `sports_fields` qua công cụ DB được phép. Chỉ sau khi thấy readback mới nói đã lưu.
4. Edit đổi tên `Viva Pickleball Updated`, giá250000; modal prefill từ DOM; Network action update; refresh/readback DB để chứng minh khác với DOM-only demo. Chưa có description/image input/Delete, nói rõ.
5. Tạm ngưng → POST toggle → GET → badge/card count giảm; refresh giữ INACTIVE; kích hoạt lại phục hồi. Tránh nói "xóa mềm" vì chưa có deletion semantics, chỉ active flag.
6. Negative case giờ22:00→06:00: JS chặn, toast; giải thích backend cũng check ordering. Nếu thử bypass HTML min/length, dùng môi trường test riêng, không gửi payload vào DB sản phẩm. Dashboard chưa có notice error=invalid, nên trình bày hạn chế feedback.
7. Viewport800/500px: sidebar overlay, Escape; modal Tab/focus restore; bảng vẫn cuộn ngang. Đây là checklist cần quan sát, không tuyên bố đã pass.

### B. Owner reviews — minh chứng persistence

1. Mở `<ctx>/owner/reviews`; cần schema/fixtures review của owner1, chuẩn bị riêng trước demo, không giả dữ liệu nếu DB lỗi. Summary DB hiển thị tất cả review.
2. Lọc rating5 → GET query rating=5; list chỉ5sao, **summary vẫn tổng owner**. Chọn số sao không có → empty state đúng, không coi là DB error.
3. Gửi `Cảm ơn bạn, chúng tôi sẽ cải thiện trải nghiệm.` ở row thử nghiệm; POST reviewId/rating/ownerReply → success=replied; refresh/readback owner_reply và replied_at. Sửa reply → cùng row, không thêm thread.
4. Nhập whitespace-only để thấy JS chặn; server cũng chặn. Error invalid rating8 có thể trình diễn GET riêng (400 notice). ID owner khác dùng fixture test; không sửa dữ liệu người khác. Lỗi DB: kỳ vọng503 và dấu— theo source, chỉ thử trên môi trường test có thể phục hồi.
5. Chuỗi `Viva <b>text</b> & "quote"` trong reply demo phải render như chữ, không HTML; không cần payload nguy hiểm. Khôi phục fixture sau demo nếu đã được phép.

### C. Chat — phân biệt DB và mock

1. Mở `<ctx>/chat?sender=VivaCustomer&receiver=VivaOwner` (không `/chat.jsp`). DB body có lịch sử hai chiều; nhắc header/sidebar vẫn Sunrise mock và names không user auth.
2. Gửi message thử không nhạy cảm → POST /chat → redirect URL encode → refresh vẫn có; đảo sender/receiver GET để xem cùng conversation. Readback `chat_messages` trên DB demo nếu được phép. Không nói realtime; tab khác phải tải lại.
3. Mở `/chat.jsp` trực tiếp và so sánh empty body trước POST để chứng minh entrypoint issue. Không giả thành đã có route guard.
4. `chat-friends.jsp` chỉ dùng để giải thích mock: push array, refresh mất, không DB; cần preflight JSP EL trước khi chọn làm live demo.

### D. Login/register/landing — giới hạn, không làm auth demo

- Gửi hai mật khẩu register khác nhau (đều >=6) có thể vẫn redirect theo source; không tạo user. Login nhập email hợp lệ bất kỳ và password nonempty chỉ đi home. Không dùng tài khoản thật, không chiếu password.
- Landing search có bug query undefined; preflight console trước demo. Không "sửa nóng" sản phẩm trong lượt scan này. Nếu filter lỗi, trình bày đúng vị trí app.js:39 và phạm vi tác động; detail button chưa route.
- Home logout index không revoke owner gate; nếu demo logout quyền owner phải dùng `/owner/access/logout` rồi kiểm tra lại protected URL.

## 9. Câu hỏi vặn bám source và hướng trả lời ngắn

| Câu hỏi | Trả lời/evidence |
|---|---|
| Dashboard toàn dữ liệu giả hay thật? | Trộn: field cards/count qua `ManageFieldsServlet:27–34`, bookings/revenue hardcoded `dashboard.jsp:192–229,284–384` |
| Số12 bookings lấy từ đâu? | Literal200, không derived từ6row; không claim DB metric |
| Bấm xác nhận có lưu không? | Không; JS95–113 chỉ DOM, refresh reset. Không nhận booking là phần cá nhân |
| CRUD sân có D chưa? | Không Delete route/form; toggle ACTIVE/INACTIVE là đổi trạng thái, không xóa |
| Ai là chủ sân hiện tại? | Mọi field/review controller dùng owner1 demo, UI Minh static; chưa session userId/role |
| Vì sao forward mà không redirect list JSP? | Giữ request fields/reviews để view render; redirect mất attributes. JSP thiếu list tự redirect route |
| Form edit dùng endpoint nào? | `openFieldModal` JS148 đổi action update, hidden fieldId; create158 xóa ID và đổi create |
| Hidden ID có đủ bảo mật? | Không; server/DAO cần owner predicate. Field DAO có check; reviews UPDATE owner predicate99–107 |
| Toggle ID không tồn tại có thành công không? | DAO false, servlet bỏ qua và redirect success; DB không đổi nhưng feedback sai |
| Vì sao price front yêu cầu1000 nhưng backend nhận >0? | Validation không đồng nhất; browser bypass được; BigDecimal kiểm tra >0 ở servlet |
| Giờ mở22h đóng6h hỗ trợ không? | Không với close.isAfter(open); phải thiết kế overnight nếu nghiệp vụ cần |
| Review filter làm average đổi không? | Không, list filter nhưng DAO summary chỉ owner, không rating (`ReviewDB:58–74`) |
| Vì sao JOIN FETCH review.field? | Field LAZY trong model, view cần fieldName sau EM.close; DAO fetch trước khi render |
| Reply mới có tạo thêm review không? | Không, UPDATE ownerReply/repliedAt, summary review count không tăng |
| DB reviews lỗi có hiện0 giả không? | loadFailed=true, HTTP503, view dấu— và notice, không empty thông thường |
| Login/register đã hash password chưa? | Chưa có user persistence/auth; process JSP chỉ redirect, không đọc params |
| Confirm password khác nhau thì sao? | Không check equality hiện tại; minlength riêng không đảm bảo match |
| Đăng xuất home có logout owner không? | Không, link index; owner logout remove boolean mới thu hồi gate |
| Chat.jsp direct và /chat khác gì? | Direct view không query; servlet /chat set messages/sender/receiver rồi forward |
| Tin nhắn giữ sau reload có nghĩa realtime không? | Không; persistence JPA + POST/redirect/GET, không websocket/polling |
| Đổi hidden senderName thì sao? | Server tin tên người gửi, có impersonation; cần session-derived user ID |
| Sidebar chat chọn PT có thật không? | Không click handler trong chat.jsp; 3 mock conversation, currentConversationId c1 cố định |
| HTML escape có chống mọi XSS không? | Chỉ HTML text/attribute phù hợp; sportType data attr chưa escape; friends innerHTML và EL cần kiểm tra |
| `${...}` trong JSP có sao không? | JSP EL có thể xử lý trước JS; chat isELIgnored=true, friends không và escape không đồng nhất |
| Search landing lỗi dòng nào? | app.js39 dùng query chưa khai báo trong filterServices(keyword), ReferenceError khả dĩ |
| Context path dùng để bảo mật không? | Không, chỉ URL theo deployment; quyền do filter/session/DAO, routing do servlet |
| Responsive owner khác home/chat thế nào? | Owner breakpoint1100/850/600 có offcanvas; home/profile/chat fixed sidebar inline chưa có quy tắc tương ứng |
| Java8/Tomcat cũ chạy được không? | pom target17 và Jakarta Servlet6.1; không nói8. web.xml4.0 là điểm phải preflight container, chưa runtime verified |
| README nói chưa có DAO tại sao code có? | Tài liệu snapshot cũ; dẫn PROJECT_STATUS39–44 đối chiếu controllers/DAO hiện tại |
| Có thể nhận mọi code trên đây là cá nhân không? | Không từ snapshot source; chỉ mô tả phạm vi được khai báo và cần Git/evidence tác giả riêng |

## 10. Bằng chứng còn thiếu và ưu tiên trước buổi bảo vệ

1. **Chưa kiểm chứng runtime:** Java/container actual versions, WAR deployment, JSP compilation (đặc biệt friends EL), DB schema/connectivity, redirects/cookies/HTTP status, post-refresh persistence, responsive/accessibility. Không dùng class files sẵn có trong target làm bằng chứng build hiện tại.
2. Preflight live ưu tiên owner fields/reviews và `/chat`; kiểm tra success bằng refresh + DB demo readback, ghi screenshot/Network nếu được phép. Không dùng dữ liệu bịa khi DB unavailable.
3. Vấn đề source cần nhận: auth giả/shared owner gate, owner1 cố định, chat identity từ client, no CSRF, thiếu field Delete, field query notice chưa render, DAO false bị bỏ qua, landing query undefined, links chat.jsp bypass data controller, friends EL/innerHTML, metrics mock và README/status lỗi thời.
4. Báo cáo này chỉ tạo `docs/viva/FRONTEND_SCAN.md`; không sửa JSP/CSS/JS/Java/config, không commit/push, không chứa giá trị secret. Demo phía trên không được thực thi trong lượt scan.
