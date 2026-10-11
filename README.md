# Sportify - Nền Tảng Đặt Sân & Dịch Vụ Thể Thao Trọn Gói

Dự án Web Java Servlet/JSP (Jakarta EE 6, Apache Tomcat, SQL Server).
Tích hợp trọn bộ: **Giao diện Giới thiệu & Khám phá dịch vụ Booking**, **Mạng xã hội Newsfeed**, **Khung chat Dịch vụ & Bạn bè**, **Quản lý lịch hẹn & Đặt chỗ**, và **Bảng điều khiển Chủ sân**.

---

## 📁 Cấu Trúc Dự Án Sau Khi Gộp (Merged Architecture)

```text
Sportify/
├── database/                                # Toàn bộ script SQL khởi tạo CSDL (giữ nguyên gốc)
│   ├── 01_init_schema.sql                  # Bảng Users, Appointments, TrainingSessions, Chat...
│   ├── 02_sports_fields.sql                # Bảng SportsFields & dữ liệu mẫu sân thể thao
│   └── 03_newsfeed.sql                     # Bảng Posts, PostLikes, PostComments (mạng xã hội)
│
├── src/main/java/com/sportify/
│   ├── config/                             # Cấu hình kết nối CSDL
│   │   └── DBContext.java                  # JDBC connection tới SQL Server (localhost:1433)
│   ├── model/                              # POJO Entity classes
│   │   ├── User.java, Appointment.java, SportField.java,
│   │   ├── ChatSession.java, ChatMessage.java,
│   │   └── Post.java, PostComment.java
│   ├── dao/                                # Data Access Objects (tương tác CSDL qua JDBC)
│   │   ├── UserDAO.java, AppointmentDAO.java, SportFieldDAO.java,
│   │   ├── ChatDAO.java, PostDAO.java
│   ├── service/                            # Lớp xử lý nghiệp vụ (Business Logic)
│   │   └── ChatService.java                # Logic chat dịch vụ (auto-reply), chat bạn bè
│   ├── util/                               # Tiện ích dùng chung
│   │   └── JsonResponse.java               # Helper chuẩn hoá format JSON & HTTP status
│   ├── filter/                             # Filter bảo mật & xác thực
│   │   └── AuthFilter.java                 # Kiểm tra đăng nhập tập trung cho toàn bộ trang & API
│   └── controller/                         # Các Servlet điều hướng theo mô hình MVC
│       ├── BaseServlet.java                # Lớp cơ sở (render view, redirect, session user)
│       ├── auth/
│       │   ├── LoginServlet.java           # GET /login, POST /login
│       │   ├── RegisterServlet.java        # GET /register, POST /register
│       │   └── LogoutServlet.java          # GET /logout
│       ├── home/
│       │   └── HomeServlet.java            # GET /home (thống kê & lịch sắp tới)
│       ├── appointment/
│       │   └── AppointmentServlet.java     # GET /appointments, POST tạo lịch/đặt chỗ, GET xoá
│       ├── chat/
│       │   ├── ChatPageServlet.java        # GET /chat, GET /chat-friends
│       │   └── ChatApiServlet.java         # GET/POST /chat-api (JSON)
│       ├── newsfeed/
│       │   ├── NewsfeedPageServlet.java    # GET /newsfeed
│       │   └── NewsfeedApiServlet.java     # GET/POST /newsfeed-api (JSON)
│       ├── profile/
│       │   └── ProfileServlet.java         # GET /profile
│       └── owner/
│           ├── ManageFieldsServlet.java    # GET /owner/fields (bảng điều khiển chủ sân)
│           ├── CreateFieldServlet.java     # POST /owner/fields/create
│           └── ToggleFieldServlet.java     # POST /owner/fields/toggle (bật/tắt sân)
│
├── src/test/java/com/sportify/
│   └── TestChat.java                       # Script test thử nghiệm logic chat
│
└── src/main/webapp/
    ├── index.jsp                           # Trang Landing Page Booking (Khám phá sân, PT, gear, trang phục)
    ├── assets/
    │   ├── css/
    │   │   ├── style.css                   # CSS giao diện tổng quan, dịch vụ booking, hero visuals
    │   │   ├── owner-dashboard.css         # CSS quản lý chủ sân
    │   │   └── pages/                      # CSS theo từng màn hình
    │   │       ├── home.css, appointments.css, newsfeed.css,
    │   │       ├── chat.css, chat-friends.css, profile.css,
    │   │       └── login.css, register.css
    │   ├── js/
    │   │   ├── app.js                      # JS tìm kiếm & lọc dịch vụ booking (venue, pt, gear, clothing)
    │   │   ├── owner-dashboard.js          # JS quản lý chủ sân
    │   │   └── pages/                      # JS theo từng màn hình
    │   │       ├── appointments.js, chat.js, chat-friends.js, newsfeed.js
    │   └── images/
    │       ├── logo.jpeg                   # Logo Sportify
    │       └── services/                   # Hình ảnh sân bãi, PT, đồ tập, pickleball, gym, bơi...
    │
    └── WEB-INF/
        ├── web.xml                         # Cấu hình web chuẩn Jakarta EE 6 & bộ lọc UTF-8
        └── views/                          # JSP được bảo vệ an toàn (chỉ truy cập qua Servlet)
            ├── common/
            │   └── sidebar.jspf            # Menu sidebar dùng chung cho người dùng
            ├── auth/
            │   ├── login.jsp
            │   └── register.jsp
            ├── user/
            │   ├── home.jsp
            │   ├── appointments.jsp        # Màn hình Lịch hẹn & Đặt chỗ (Sân, PT, Gear, Đồ tập)
            │   ├── newsfeed.jsp            # Mạng xã hội thể thao
            │   ├── chat.jsp                # Chat với Dịch vụ / CSKH
            │   ├── chat-friends.jsp        # Chat với Bạn bè
            │   └── profile.jsp             # Hồ sơ cá nhân
            └── owner/
                └── dashboard.jsp           # Dashboard Quản lý dịch vụ & sân bãi
```

---

## 🚀 Danh Sách URL / Routes

| Đường dẫn (URL) | Phương thức | Mô tả |
|-----------------|-------------|-------|
| `/` hoặc `/index.jsp` | GET | Khám phá dịch vụ Booking (Sân, PT, Dụng cụ, Trang phục) |
| `/login` | GET / POST | Trang đăng nhập / Xác thực tài khoản |
| `/register` | GET / POST | Trang đăng ký / Tạo tài khoản mới |
| `/logout` | GET | Đăng xuất, xoá session |
| `/home` | GET | Dashboard cá nhân (Thống kê, lịch tập sắp tới) |
| `/appointments` | GET / POST | Lịch hẹn & Đặt chỗ (Hỗ trợ đặt sân, thuê PT, thuê gear, đồ tập) |
| `/appointments/delete?id={id}` | GET | Xoá lịch hẹn |
| `/newsfeed` | GET | Mạng xã hội thể thao (Đăng bài, xem tin) |
| `/newsfeed-api` | GET / POST | API tương tác bài viết (like, comment, post) |
| `/chat` | GET | Nhắn tin với Nhà cung cấp dịch vụ / Tư vấn viên |
| `/chat-friends` | GET | Nhắn tin kết nối bạn bè tập luyện |
| `/chat-api` | GET / POST | API nhắn tin thời gian thực |
| `/profile` | GET | Quản lý thông tin cá nhân |
| `/owner/fields` | GET | Bảng điều khiển quản lý sân (Dành cho chủ sân) |
| `/owner/fields/create` | POST | Thêm mới sân/dịch vụ thể thao |
| `/owner/fields/toggle` | POST | Bật/tắt trạng thái hoạt động sân |

---

## 🛠 Hướng Dẫn Cài Đặt & Chạy Dự Án

1. **Khởi tạo Database**:
   - Mở SQL Server Management Studio (SSMS).
   - Chạy tuần tự 3 file trong thư mục `database/`:
     1. `01_init_schema.sql`
     2. `02_sports_fields.sql`
     3. `03_newsfeed.sql`

2. **Cấu hình kết nối CSDL**:
   - Mở file `src/main/java/com/sportify/config/DBContext.java`.
   - Kiểm tra `serverName`, `portNumber`, `instance`, `userID`, `password` để khớp với SQL Server của bạn.

3. **Build dự án**:
   ```bash
   mvn clean package
   ```
   File WAR xuất ra tại `target/sportify.war`.

4. **Triển khai máy chủ**:
   - Deploy trên Apache Tomcat 10+ (hỗ trợ Jakarta EE 6 / Servlet 6.0).
   - Truy cập: `http://localhost:8080/sportify/` (hoặc root `/` tùy cấu hình server).
