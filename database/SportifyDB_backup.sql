-- ====================================================================
-- SPORTIFY DATABASE BACKUP SCRIPT
-- Database: SportifyDB (Microsoft SQL Server)
-- Backup Date: 2026-10-12 02:34:29
-- Format: T-SQL Script (DDL Schema + Full DML Live Data)
-- Encoding: UTF-8 with BOM (Hỗ trợ tiếng Việt Unicode 100%)
-- Mục đích: Tối ưu commit GitHub, restore mượt mà trên mọi máy chủ SQL Server
-- ====================================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SportifyDB')
BEGIN
    CREATE DATABASE SportifyDB COLLATE SQL_Latin1_General_CP1_CI_AS;
END
GO

USE SportifyDB;
GO

-- ====================================================================
-- PHẦN 1: KHỞI TẠO CẤU TRÚC BẢNG (DDL SCHEMA)
-- ====================================================================

-- 1. BẢNG Users
IF OBJECT_ID('Users', 'U') IS NULL
BEGIN
    CREATE TABLE Users (
        id INT IDENTITY(1,1) PRIMARY KEY,
        fullname NVARCHAR(100) NOT NULL,
        email VARCHAR(100) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        avatar VARCHAR(255) NULL,
        phone VARCHAR(20) NULL,
        role VARCHAR(20) DEFAULT 'USER',
        created_at DATETIME DEFAULT GETDATE()
    );
END
GO

-- 2. BẢNG SportsFields
IF OBJECT_ID('SportsFields', 'U') IS NULL
BEGIN
    CREATE TABLE SportsFields (
        field_id   BIGINT IDENTITY(1,1) PRIMARY KEY,
        owner_id   INT NOT NULL DEFAULT 1 FOREIGN KEY REFERENCES Users(id), 
        field_name NVARCHAR(150) NOT NULL,
        sport_type NVARCHAR(30)  NOT NULL
            CONSTRAINT chk_sport_type CHECK (sport_type IN ('GYM','BASKETBALL','SWIMMING','PICKLEBALL')),
        address    NVARCHAR(255) NOT NULL,
        description NVARCHAR(500),
        price_per_hour DECIMAL(12,2) NOT NULL
            CONSTRAINT chk_price CHECK (price_per_hour > 0),
        open_time  TIME NOT NULL,
        close_time TIME NOT NULL,
        image_url  NVARCHAR(500),
        status     NVARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
            CONSTRAINT chk_status CHECK (status IN ('ACTIVE','INACTIVE')),
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        CONSTRAINT chk_time CHECK (close_time > open_time),
        CONSTRAINT uq_owner_name_address UNIQUE (owner_id, field_name, address)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.synonyms WHERE name = 'sports_fields')
BEGIN
    CREATE SYNONYM sports_fields FOR SportsFields;
END
GO

-- 3. BẢNG Appointments
IF OBJECT_ID('Appointments', 'U') IS NULL
BEGIN
    CREATE TABLE Appointments (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL FOREIGN KEY REFERENCES Users(id) ON DELETE CASCADE,
        title NVARCHAR(255) NOT NULL,
        appointment_date VARCHAR(20) NOT NULL,
        appointment_time VARCHAR(20) NOT NULL,
        type VARCHAR(50) NOT NULL DEFAULT 'court',
        note NVARCHAR(MAX) NULL,
        created_at DATETIME DEFAULT GETDATE()
    );
END
GO

-- 4. BẢNG TrainingSessions
IF OBJECT_ID('TrainingSessions', 'U') IS NULL
BEGIN
    CREATE TABLE TrainingSessions (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL FOREIGN KEY REFERENCES Users(id) ON DELETE CASCADE,
        duration_hours INT NOT NULL DEFAULT 1,
        session_date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
        note NVARCHAR(255) NULL
    );
END
GO

-- 5. BẢNG ChatSessions & Messages
IF OBJECT_ID('ChatSessions', 'U') IS NULL
BEGIN
    CREATE TABLE ChatSessions (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL FOREIGN KEY REFERENCES Users(id) ON DELETE CASCADE,
        partner_name NVARCHAR(100) NOT NULL,
        partner_icon NVARCHAR(20) NULL,
        role_name NVARCHAR(50) NULL,
        role_class NVARCHAR(50) NULL,
        is_online BIT DEFAULT 1
    );
END
GO

IF OBJECT_ID('Messages', 'U') IS NULL
BEGIN
    CREATE TABLE Messages (
        id INT IDENTITY(1,1) PRIMARY KEY,
        session_id INT NOT NULL FOREIGN KEY REFERENCES ChatSessions(id) ON DELETE CASCADE,
        sender VARCHAR(20) NOT NULL,
        message_text NVARCHAR(MAX) NOT NULL,
        created_at VARCHAR(50) NOT NULL
    );
END
GO

-- 6. BẢNG FriendMessages
IF OBJECT_ID('FriendMessages', 'U') IS NULL
BEGIN
    CREATE TABLE FriendMessages (
        id INT IDENTITY(1,1) PRIMARY KEY,
        sender_id INT NOT NULL FOREIGN KEY REFERENCES Users(id),
        receiver_id INT NOT NULL FOREIGN KEY REFERENCES Users(id),
        message_text NVARCHAR(MAX) NOT NULL,
        created_at VARCHAR(20) NOT NULL
    );
END
GO

-- 7. BẢNG Posts, PostLikes, PostComments
IF OBJECT_ID('Posts', 'U') IS NULL
BEGIN
    CREATE TABLE Posts (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT FOREIGN KEY REFERENCES Users(id),
        content NVARCHAR(MAX) NOT NULL,
        created_at DATETIME DEFAULT GETDATE()
    );
END
GO

IF OBJECT_ID('PostLikes', 'U') IS NULL
BEGIN
    CREATE TABLE PostLikes (
        id INT IDENTITY(1,1) PRIMARY KEY,
        post_id INT FOREIGN KEY REFERENCES Posts(id) ON DELETE CASCADE,
        user_id INT FOREIGN KEY REFERENCES Users(id),
        UNIQUE(post_id, user_id)
    );
END
GO

IF OBJECT_ID('PostComments', 'U') IS NULL
BEGIN
    CREATE TABLE PostComments (
        id INT IDENTITY(1,1) PRIMARY KEY,
        post_id INT FOREIGN KEY REFERENCES Posts(id) ON DELETE CASCADE,
        user_id INT FOREIGN KEY REFERENCES Users(id),
        content NVARCHAR(MAX) NOT NULL,
        created_at DATETIME DEFAULT GETDATE()
    );
END
GO

-- 8. BẢNG bookings
IF OBJECT_ID('bookings', 'U') IS NULL
BEGIN
    CREATE TABLE bookings (
        booking_id BIGINT IDENTITY(1,1) PRIMARY KEY,
        field_id BIGINT NOT NULL CONSTRAINT fk_bookings_field REFERENCES SportsFields(field_id),
        customer_id INT NULL,
        customer_name NVARCHAR(100) NOT NULL,
        customer_phone VARCHAR(20) NULL,
        starts_at DATETIME2 NOT NULL,
        ends_at DATETIME2 NOT NULL,
        total_price DECIMAL(12, 2) NOT NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT ck_bookings_customer_name CHECK (LEN(LTRIM(RTRIM(customer_name))) > 0),
        CONSTRAINT ck_bookings_time CHECK (ends_at > starts_at AND CAST(starts_at AS DATE) = CAST(ends_at AS DATE)),
        CONSTRAINT ck_bookings_price CHECK (total_price > 0),
        CONSTRAINT ck_bookings_status CHECK (
            status IN ('PENDING', 'CONFIRMED', 'REJECTED', 'COMPLETED', 'CANCELLED')
        )
    );

    CREATE INDEX idx_bookings_field_created ON bookings (field_id, created_at DESC, booking_id DESC);
    CREATE INDEX idx_bookings_field_status_start ON bookings (field_id, status, starts_at);
    CREATE INDEX idx_bookings_customer ON bookings (customer_id, starts_at DESC);
END
GO

-- 9. BẢNG reviews
IF OBJECT_ID('reviews', 'U') IS NULL
BEGIN
    CREATE TABLE reviews (
        review_id BIGINT IDENTITY(1,1) PRIMARY KEY,
        field_id BIGINT NOT NULL CONSTRAINT fk_reviews_field REFERENCES SportsFields(field_id),
        customer_name NVARCHAR(100) NOT NULL,
        rating INT NOT NULL,
        comment NVARCHAR(MAX) NOT NULL,
        owner_reply NVARCHAR(MAX) NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        replied_at DATETIME2 NULL
    );

    CREATE INDEX idx_reviews_field ON reviews(field_id);
END
GO

-- 10. BẢNG chat_messages
IF OBJECT_ID('chat_messages', 'U') IS NULL
BEGIN
    CREATE TABLE chat_messages (
        message_id BIGINT IDENTITY(1,1) PRIMARY KEY,
        sender_name NVARCHAR(100) NOT NULL,
        receiver_name NVARCHAR(100) NOT NULL,
        message_text NVARCHAR(1000) NOT NULL,
        sent_at DATETIME2 NOT NULL DEFAULT GETDATE()
    );
END
GO

-- ====================================================================
-- PHẦN 2: DỮ LIỆU THỰC TẾ (DML DATA INSERTS)
-- ====================================================================

-- Tắt ràng buộc khóa ngoại tạm thời để nạp dữ liệu không bị xung đột thứ tự
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
GO

-- Dữ liệu bảng: Users (5 dòng)
DELETE FROM [Users];
SET IDENTITY_INSERT [Users] ON;
INSERT INTO [Users] ([id], [fullname], [email], [password], [avatar], [phone], [role], [created_at]) VALUES (1, N'Quản trị viên', N'admin@sportify.com', N'123456', NULL, NULL, N'ADMIN', NULL);
INSERT INTO [Users] ([id], [fullname], [email], [password], [avatar], [phone], [role], [created_at]) VALUES (4, N'Ngô Gia Bảo', N'1@1', N'123456', NULL, NULL, NULL, NULL);
INSERT INTO [Users] ([id], [fullname], [email], [password], [avatar], [phone], [role], [created_at]) VALUES (5, N'Trần Thị Trúc Linh', N'Bamboo2904@skibidi.thanhhoa', N'ngogia135', NULL, NULL, NULL, NULL);
INSERT INTO [Users] ([id], [fullname], [email], [password], [avatar], [phone], [role], [created_at]) VALUES (6, N'Nguyễn Văn A', N'user@sportify.vn', N'123456', NULL, NULL, N'USER', '2026-10-11 23:41:12.550');
INSERT INTO [Users] ([id], [fullname], [email], [password], [avatar], [phone], [role], [created_at]) VALUES (7, N'Trần Thị B', N'owner@sportify.vn', N'123456', NULL, NULL, N'OWNER', '2026-10-11 23:41:12.553');
SET IDENTITY_INSERT [Users] OFF;
GO

-- Dữ liệu bảng: SportsFields (4 dòng)
DELETE FROM [SportsFields];
SET IDENTITY_INSERT [SportsFields] ON;
INSERT INTO [SportsFields] ([field_id], [owner_id], [field_name], [sport_type], [address], [description], [price_per_hour], [open_time], [close_time], [image_url], [status], [created_at], [updated_at]) VALUES (1, 1, N'Phòng Gym FitZone', N'GYM', N'Quận 7, TP.HCM', N'Phòng gym đầy đủ thiết bị hiện đại, không gian rộng rãi.', 80000.00, '06:00:00', '22:00:00', N'assets/images/gymfitzone.jfif', N'ACTIVE', '2026-09-21 08:47:46.177', '2026-09-21 08:47:46.177');
INSERT INTO [SportsFields] ([field_id], [owner_id], [field_name], [sport_type], [address], [description], [price_per_hour], [open_time], [close_time], [image_url], [status], [created_at], [updated_at]) VALUES (2, 1, N'Sân bóng rổ Sunrise', N'BASKETBALL', N'Quận 3, TP.HCM', N'Sân bóng rổ trong nhà đạt chuẩn thi đấu, sàn gỗ cao cấp.', 180000.00, '07:00:00', '22:00:00', N'assets/images/basketballcourt1.jpg', N'ACTIVE', '2026-09-21 08:47:46.177', '2026-09-21 08:47:46.177');
INSERT INTO [SportsFields] ([field_id], [owner_id], [field_name], [sport_type], [address], [description], [price_per_hour], [open_time], [close_time], [image_url], [status], [created_at], [updated_at]) VALUES (3, 1, N'Hồ bơi Aqua Center', N'SWIMMING', N'Quận 1, TP.HCM', N'Hồ bơi 4 mùa nước ấm, view trên cao, làn bơi chuẩn Olympic.', 120000.00, '06:00:00', '21:00:00', N'assets/images/swimmingpoolaqua.jfif', N'ACTIVE', '2026-09-21 08:47:46.177', '2026-09-21 08:47:46.177');
INSERT INTO [SportsFields] ([field_id], [owner_id], [field_name], [sport_type], [address], [description], [price_per_hour], [open_time], [close_time], [image_url], [status], [created_at], [updated_at]) VALUES (4, 1, N'Green Pickleball Court', N'PICKLEBALL', N'TP. Thủ Đức, TP.HCM', N'Cụm sân pickleball ngoài trời thoáng đãng, đèn chiếu sáng ban đêm.', 150000.00, '06:00:00', '22:00:00', N'assets/images/greenpickleballcourt.jfif', N'ACTIVE', '2026-09-21 08:47:46.177', '2026-09-21 08:47:46.177');
SET IDENTITY_INSERT [SportsFields] OFF;
GO

-- Dữ liệu bảng: Appointments (2 dòng)
DELETE FROM [Appointments];
SET IDENTITY_INSERT [Appointments] ON;
INSERT INTO [Appointments] ([id], [user_id], [title], [appointment_date], [appointment_time], [type], [note], [created_at]) VALUES (1, 1, N'Trận bóng đá giao hữu', N'2026-10-15', N'18:00', N'court', N'Tập luyện cùng đội bóng', '2026-10-11 23:49:48.537');
INSERT INTO [Appointments] ([id], [user_id], [title], [appointment_date], [appointment_time], [type], [note], [created_at]) VALUES (2, 4, N'213213', N'2026-12-03', N'14:13', N'court', N'123123213213', '2026-10-12 00:29:25.953');
SET IDENTITY_INSERT [Appointments] OFF;
GO

-- Dữ liệu bảng: TrainingSessions (1 dòng)
DELETE FROM [TrainingSessions];
SET IDENTITY_INSERT [TrainingSessions] ON;
INSERT INTO [TrainingSessions] ([id], [user_id], [duration_hours], [session_date], [note]) VALUES (1, 1, 2, '2026-10-11 00:00:00.000', N'Tập gym buổi chiều');
SET IDENTITY_INSERT [TrainingSessions] OFF;
GO

-- Bảng ChatSessions (0 dòng)

-- Bảng Messages (0 dòng)

-- Dữ liệu bảng: FriendMessages (9 dòng)
DELETE FROM [FriendMessages];
SET IDENTITY_INSERT [FriendMessages] ON;
INSERT INTO [FriendMessages] ([id], [sender_id], [receiver_id], [message_text], [created_at]) VALUES (1, 4, 5, N'jjjj', N'18:13');
INSERT INTO [FriendMessages] ([id], [sender_id], [receiver_id], [message_text], [created_at]) VALUES (2, 4, 1, N'aaaaa', N'18:13');
INSERT INTO [FriendMessages] ([id], [sender_id], [receiver_id], [message_text], [created_at]) VALUES (3, 4, 1, N'1232123123123', N'07:50');
INSERT INTO [FriendMessages] ([id], [sender_id], [receiver_id], [message_text], [created_at]) VALUES (4, 4, 5, N'21323123', N'07:50');
INSERT INTO [FriendMessages] ([id], [sender_id], [receiver_id], [message_text], [created_at]) VALUES (5, 4, 1, N'anh nho em qua', N'07:50');
INSERT INTO [FriendMessages] ([id], [sender_id], [receiver_id], [message_text], [created_at]) VALUES (6, 4, 1, N'tối nay làm ván pickle ball ko', N'07:51');
INSERT INTO [FriendMessages] ([id], [sender_id], [receiver_id], [message_text], [created_at]) VALUES (7, 1, 4, N'Chào bạn! Hệ thống đã fix xong lỗi!', N'00:25');
INSERT INTO [FriendMessages] ([id], [sender_id], [receiver_id], [message_text], [created_at]) VALUES (8, 4, 5, N'213123123', N'00:28');
INSERT INTO [FriendMessages] ([id], [sender_id], [receiver_id], [message_text], [created_at]) VALUES (9, 4, 5, N'123123', N'00:28');
SET IDENTITY_INSERT [FriendMessages] OFF;
GO

-- Dữ liệu bảng: Posts (2 dòng)
DELETE FROM [Posts];
SET IDENTITY_INSERT [Posts] ON;
INSERT INTO [Posts] ([id], [user_id], [content], [created_at]) VALUES (1, 4, N'Skibidiiiii', '2026-09-20 18:37:32.217');
INSERT INTO [Posts] ([id], [user_id], [content], [created_at]) VALUES (2, 4, N'Scuba dance + Skibidi', '2026-09-21 08:00:10.710');
SET IDENTITY_INSERT [Posts] OFF;
GO

-- Dữ liệu bảng: PostLikes (2 dòng)
DELETE FROM [PostLikes];
SET IDENTITY_INSERT [PostLikes] ON;
INSERT INTO [PostLikes] ([id], [post_id], [user_id]) VALUES (1, 1, 5);
INSERT INTO [PostLikes] ([id], [post_id], [user_id]) VALUES (2, 2, 4);
SET IDENTITY_INSERT [PostLikes] OFF;
GO

-- Dữ liệu bảng: PostComments (1 dòng)
DELETE FROM [PostComments];
SET IDENTITY_INSERT [PostComments] ON;
INSERT INTO [PostComments] ([id], [post_id], [user_id], [content], [created_at]) VALUES (1, 1, 5, N'thích ghê', '2026-09-20 18:38:05.140');
SET IDENTITY_INSERT [PostComments] OFF;
GO

-- Dữ liệu bảng: bookings (10 dòng)
DELETE FROM [bookings];
SET IDENTITY_INSERT [bookings] ON;
INSERT INTO [bookings] ([booking_id], [field_id], [customer_name], [customer_phone], [starts_at], [ends_at], [total_price], [status], [created_at], [updated_at], [customer_id]) VALUES (1, 1, N'Trần Gia Huy', N'0901000001', '2026-10-12 08:00:00.000', '2026-10-12 09:30:00.000', 120000.00, N'PENDING', '2026-10-11 23:31:12.636', '2026-10-11 23:41:12.636', NULL);
INSERT INTO [bookings] ([booking_id], [field_id], [customer_name], [customer_phone], [starts_at], [ends_at], [total_price], [status], [created_at], [updated_at], [customer_id]) VALUES (2, 1, N'Lê Thu Trang', N'0901000002', '2026-10-12 08:30:00.000', '2026-10-12 10:00:00.000', 120000.00, N'PENDING', '2026-10-11 23:33:12.636', '2026-10-11 23:41:12.636', NULL);
INSERT INTO [bookings] ([booking_id], [field_id], [customer_name], [customer_phone], [starts_at], [ends_at], [total_price], [status], [created_at], [updated_at], [customer_id]) VALUES (3, 1, N'Phạm Hoàng Nam', N'0901000003', '2026-10-12 10:00:00.000', '2026-10-12 11:30:00.000', 120000.00, N'CONFIRMED', '2026-10-11 23:35:12.636', '2026-10-12 00:10:15.808', NULL);
INSERT INTO [bookings] ([booking_id], [field_id], [customer_name], [customer_phone], [starts_at], [ends_at], [total_price], [status], [created_at], [updated_at], [customer_id]) VALUES (4, 1, N'Nguyễn Quốc Bảo', N'0901000004', '2026-10-12 13:00:00.000', '2026-10-12 14:30:00.000', 120000.00, N'CONFIRMED', '2026-10-11 23:37:12.640', '2026-10-11 23:41:12.640', NULL);
INSERT INTO [bookings] ([booking_id], [field_id], [customer_name], [customer_phone], [starts_at], [ends_at], [total_price], [status], [created_at], [updated_at], [customer_id]) VALUES (5, 1, N'Đỗ Minh Anh', N'0901000005', '2026-10-11 06:00:00.000', '2026-10-11 07:30:00.000', 120000.00, N'COMPLETED', '2026-10-11 23:39:12.640', '2026-10-11 23:41:12.640', NULL);
INSERT INTO [bookings] ([booking_id], [field_id], [customer_name], [customer_phone], [starts_at], [ends_at], [total_price], [status], [created_at], [updated_at], [customer_id]) VALUES (6, 1, N'Vũ Khánh Linh', N'0901000006', '2026-10-11 10:00:00.000', '2026-10-11 11:30:00.000', 120000.00, N'REJECTED', '2026-10-11 23:40:12.640', '2026-10-11 23:41:12.640', NULL);
INSERT INTO [bookings] ([booking_id], [field_id], [customer_name], [customer_phone], [starts_at], [ends_at], [total_price], [status], [created_at], [updated_at], [customer_id]) VALUES (7, 2, N'Nguyễn Văn A', N'0987654321', '2026-10-13 15:00:00.000', '2026-10-13 16:30:00.000', 270000.00, N'CONFIRMED', '2026-10-12 01:15:05.848', '2026-10-12 01:17:41.337', 6);
INSERT INTO [bookings] ([booking_id], [field_id], [customer_name], [customer_phone], [starts_at], [ends_at], [total_price], [status], [created_at], [updated_at], [customer_id]) VALUES (8, 1, N'Nguyễn Văn A', N'0911223344', '2026-10-14 08:00:00.000', '2026-10-14 09:30:00.000', 120000.00, N'CANCELLED', '2026-10-12 01:18:17.994', '2026-10-12 01:18:18.127', 6);
INSERT INTO [bookings] ([booking_id], [field_id], [customer_name], [customer_phone], [starts_at], [ends_at], [total_price], [status], [created_at], [updated_at], [customer_id]) VALUES (9, 1, N'Ngô Gia Bảo', N'0767615217', '2026-10-12 06:00:00.000', '2026-10-12 07:30:00.000', 120000.00, N'REJECTED', '2026-10-12 01:36:31.910', '2026-10-12 01:36:55.009', 4);
INSERT INTO [bookings] ([booking_id], [field_id], [customer_name], [customer_phone], [starts_at], [ends_at], [total_price], [status], [created_at], [updated_at], [customer_id]) VALUES (10, 3, N'Nguyễn Văn A', N'0933445566', '2026-10-15 09:00:00.000', '2026-10-15 10:30:00.000', 180000.00, N'PENDING', '2026-10-12 01:45:40.530', '2026-10-12 01:45:40.530', 6);
SET IDENTITY_INSERT [bookings] OFF;
GO

-- Dữ liệu bảng: reviews (3 dòng)
DELETE FROM [reviews];
SET IDENTITY_INSERT [reviews] ON;
INSERT INTO [reviews] ([review_id], [field_id], [customer_name], [rating], [comment], [owner_reply], [created_at], [replied_at]) VALUES (1, 1, N'Trần Gia Huy', 5, N'Sân rất đẹp, thiết bị hiện đại, vệ sinh sạch sẽ!', N'Cảm ơn bạn đã ủng hộ sân!', '2026-10-09 23:41:12.653', '2026-10-10 00:41:12.653');
INSERT INTO [reviews] ([review_id], [field_id], [customer_name], [rating], [comment], [owner_reply], [created_at], [replied_at]) VALUES (2, 1, N'Lê Thu Trang', 4, N'Không gian rộng rãi, nhân viên hỗ trợ nhiệt tình.', NULL, '2026-10-10 23:41:12.653', NULL);
INSERT INTO [reviews] ([review_id], [field_id], [customer_name], [rating], [comment], [owner_reply], [created_at], [replied_at]) VALUES (3, 1, N'Nguyễn Quốc Bảo', 5, N'Chất lượng dịch vụ tuyệt vời, sẽ ghé lại thường xuyên!', N'Rất vui được phục vụ bạn!', '2026-10-11 23:41:12.653', '2026-10-12 00:11:12.653');
SET IDENTITY_INSERT [reviews] OFF;
GO

-- Dữ liệu bảng: chat_messages (3 dòng)
DELETE FROM [chat_messages];
SET IDENTITY_INSERT [chat_messages] ON;
INSERT INTO [chat_messages] ([message_id], [sender_name], [receiver_name], [message_text], [sent_at]) VALUES (1, N'Trần Gia Huy', N'Chủ Sân', N'Chào chủ sân, sân ngày mai có thể đặt thêm bóng tập không ạ?', '2026-10-11 23:26:12.663');
INSERT INTO [chat_messages] ([message_id], [sender_name], [receiver_name], [message_text], [sent_at]) VALUES (2, N'Chủ Sân', N'Trần Gia Huy', N'Chào bạn, bên mình có sẵn bóng và đồ tập miễn phí nhé!', '2026-10-11 23:31:12.663');
INSERT INTO [chat_messages] ([message_id], [sender_name], [receiver_name], [message_text], [sent_at]) VALUES (3, N'Khách hàng', N'Sân bóng Sunrise', N'1', '2026-10-12 00:10:38.876');
SET IDENTITY_INSERT [chat_messages] OFF;
GO

-- ====================================================================
-- BẬT LẠI TOÀN BỘ RÀNG BUỘC KHÓA NGOẠI VÀ KIỂM TRA TÍNH TOÀN VẸN
-- ====================================================================
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';
GO

PRINT N'>>> SPORTIFYDB RESTORE HOÀN TẤT THÀNH CÔNG 100%! <<<';
GO
