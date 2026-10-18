-- ====================================================================
-- SPORTIFY DATABASE BACKUP & RESTORE SCRIPT (MERGED FROM sportii.sql)
-- Database: SportifyDB (Microsoft SQL Server)
-- Updated Date: 2026-10-19
-- Format: T-SQL Script (DDL Schema + Full DML Data from sportii.sql)
-- Encoding: UTF-8
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
-- DỌN DẸP SYNONYM & BẢNG CŨ ĐỂ ĐẢM BẢO SCHEMA ĐỒNG BỘ 100% VỚI sportii.sql
-- ====================================================================
IF EXISTS (SELECT 1 FROM sys.synonyms WHERE name = 'sports_fields') DROP SYNONYM sports_fields;
IF EXISTS (SELECT 1 FROM sys.synonyms WHERE name = 'friend_messages') DROP SYNONYM friend_messages;
IF EXISTS (SELECT 1 FROM sys.synonyms WHERE name = 'post_likes') DROP SYNONYM post_likes;
IF EXISTS (SELECT 1 FROM sys.synonyms WHERE name = 'post_comments') DROP SYNONYM post_comments;
IF EXISTS (SELECT 1 FROM sys.synonyms WHERE name = 'chat_sessions') DROP SYNONYM chat_sessions;
IF EXISTS (SELECT 1 FROM sys.synonyms WHERE name = 'training_sessions') DROP SYNONYM training_sessions;
GO

IF OBJECT_ID('notifications', 'U') IS NOT NULL DROP TABLE notifications;
IF OBJECT_ID('booking_events', 'U') IS NOT NULL DROP TABLE booking_events;
IF OBJECT_ID('field_blocks', 'U') IS NOT NULL DROP TABLE field_blocks;
IF OBJECT_ID('reviews', 'U') IS NOT NULL DROP TABLE reviews;
IF OBJECT_ID('bookings', 'U') IS NOT NULL DROP TABLE bookings;
IF OBJECT_ID('chat_messages', 'U') IS NOT NULL DROP TABLE chat_messages;
IF OBJECT_ID('PostComments', 'U') IS NOT NULL DROP TABLE PostComments;
IF OBJECT_ID('PostLikes', 'U') IS NOT NULL DROP TABLE PostLikes;
IF OBJECT_ID('Posts', 'U') IS NOT NULL DROP TABLE Posts;
IF OBJECT_ID('FriendMessages', 'U') IS NOT NULL DROP TABLE FriendMessages;
IF OBJECT_ID('Messages', 'U') IS NOT NULL DROP TABLE Messages;
IF OBJECT_ID('ChatSessions', 'U') IS NOT NULL DROP TABLE ChatSessions;
IF OBJECT_ID('TrainingSessions', 'U') IS NOT NULL DROP TABLE TrainingSessions;
IF OBJECT_ID('Appointments', 'U') IS NOT NULL DROP TABLE Appointments;
IF OBJECT_ID('SportsFields', 'U') IS NOT NULL DROP TABLE SportsFields;
IF OBJECT_ID('Users', 'U') IS NOT NULL DROP TABLE Users;
GO

-- ====================================================================
-- PHẦN 1: KHỞI TẠO CẤU TRÚC BẢNG (DDL SCHEMA)
-- ====================================================================

-- 1. BẢNG Users (Đồng bộ từ public.users trong sportii.sql)
CREATE TABLE Users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    fullname NVARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    avatar VARCHAR(255) NULL,
    phone VARCHAR(20) NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    gender NVARCHAR(20) NULL,
    date_of_birth DATE NULL,
    address NVARCHAR(500) NULL
);
GO

-- 2. BẢNG SportsFields (Đồng bộ từ public.sports_fields trong sportii.sql + quantity)
CREATE TABLE SportsFields (
    field_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    owner_id INT NOT NULL DEFAULT 2 FOREIGN KEY REFERENCES Users(id),
    field_name NVARCHAR(150) NOT NULL,
    sport_type NVARCHAR(30) NOT NULL
        CONSTRAINT chk_sports_fields_type CHECK (sport_type IN ('GYM', 'BASKETBALL', 'SWIMMING', 'PICKLEBALL', 'TABLE_TENNIS')),
    address NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX) NULL,
    price_per_hour DECIMAL(12,2) NOT NULL
        CONSTRAINT chk_sports_fields_price CHECK (price_per_hour > 0),
    open_time TIME NOT NULL,
    close_time TIME NOT NULL,
    image_url NVARCHAR(500) NULL,
    status NVARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
        CONSTRAINT chk_sports_fields_status CHECK (status IN ('ACTIVE', 'INACTIVE')),
    quantity INT NOT NULL DEFAULT 4
        CONSTRAINT chk_field_quantity CHECK (quantity > 0),
    auto_approve BIT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT chk_sports_fields_time CHECK (close_time > open_time),
    CONSTRAINT uq_sports_fields_owner_name_address UNIQUE (owner_id, field_name, address)
);
GO

CREATE SYNONYM sports_fields FOR SportsFields;
GO

-- 3. BẢNG Appointments (Đồng bộ từ public.appointments)
CREATE TABLE Appointments (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL FOREIGN KEY REFERENCES Users(id) ON DELETE CASCADE,
    title NVARCHAR(255) NOT NULL,
    appointment_date VARCHAR(20) NOT NULL,
    appointment_time VARCHAR(20) NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'court',
    note NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

-- 4. BẢNG TrainingSessions (Đồng bộ từ public.training_sessions)
CREATE TABLE TrainingSessions (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL FOREIGN KEY REFERENCES Users(id) ON DELETE CASCADE,
    duration_hours INT NOT NULL DEFAULT 1,
    session_date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    note NVARCHAR(255) NULL
);
GO

CREATE SYNONYM training_sessions FOR TrainingSessions;
GO

-- 5. BẢNG ChatSessions & Messages (Đồng bộ từ public.chat_sessions & public.messages)
CREATE TABLE ChatSessions (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL FOREIGN KEY REFERENCES Users(id) ON DELETE CASCADE,
    partner_name NVARCHAR(100) NOT NULL,
    partner_icon NVARCHAR(20) NULL,
    role_name NVARCHAR(50) NULL,
    role_class NVARCHAR(50) NULL,
    is_online BIT NOT NULL DEFAULT 1
);
GO

CREATE SYNONYM chat_sessions FOR ChatSessions;
GO

CREATE TABLE Messages (
    id INT IDENTITY(1,1) PRIMARY KEY,
    session_id INT NOT NULL FOREIGN KEY REFERENCES ChatSessions(id) ON DELETE CASCADE,
    sender VARCHAR(20) NOT NULL,
    message_text NVARCHAR(MAX) NOT NULL,
    created_at VARCHAR(50) NOT NULL
);
GO

-- 6. BẢNG FriendMessages (Đồng bộ từ public.friend_messages)
CREATE TABLE FriendMessages (
    id INT IDENTITY(1,1) PRIMARY KEY,
    sender_id INT NOT NULL FOREIGN KEY REFERENCES Users(id),
    receiver_id INT NOT NULL FOREIGN KEY REFERENCES Users(id),
    message_text NVARCHAR(MAX) NOT NULL,
    created_at VARCHAR(50) NOT NULL
);
GO

CREATE SYNONYM friend_messages FOR FriendMessages;
GO

-- 7. BẢNG Posts, PostLikes, PostComments (Đồng bộ từ public.posts, post_likes, post_comments + đính kèm lịch sân)
CREATE TABLE Posts (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL FOREIGN KEY REFERENCES Users(id) ON DELETE CASCADE,
    content NVARCHAR(MAX) NOT NULL,
    booking_id BIGINT NULL,
    post_purpose NVARCHAR(30) NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE PostLikes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    post_id INT NOT NULL FOREIGN KEY REFERENCES Posts(id) ON DELETE CASCADE,
    user_id INT NOT NULL FOREIGN KEY REFERENCES Users(id),
    CONSTRAINT post_likes_post_id_user_id_key UNIQUE (post_id, user_id)
);
GO

CREATE SYNONYM post_likes FOR PostLikes;
GO

CREATE TABLE PostComments (
    id INT IDENTITY(1,1) PRIMARY KEY,
    post_id INT NOT NULL FOREIGN KEY REFERENCES Posts(id) ON DELETE CASCADE,
    user_id INT NOT NULL FOREIGN KEY REFERENCES Users(id),
    content NVARCHAR(MAX) NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

CREATE SYNONYM post_comments FOR PostComments;
GO

-- 8. BẢNG bookings (Đồng bộ từ public.bookings + court_number)
CREATE TABLE bookings (
    booking_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    field_id BIGINT NOT NULL CONSTRAINT fk_bookings_field REFERENCES SportsFields(field_id),
    customer_name NVARCHAR(100) NOT NULL,
    customer_phone VARCHAR(20) NULL,
    starts_at DATETIME2 NOT NULL,
    ends_at DATETIME2 NOT NULL,
    total_price DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    customer_id INT NULL,
    confirmation_source VARCHAR(20) NOT NULL DEFAULT 'MANUAL',
    court_number INT NOT NULL DEFAULT 1,
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
GO

-- 9. BẢNG booking_events (Đồng bộ từ public.booking_events)
CREATE TABLE booking_events (
    event_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    booking_id BIGINT NOT NULL FOREIGN KEY REFERENCES bookings(booking_id) ON DELETE CASCADE,
    from_status VARCHAR(20) NULL,
    to_status VARCHAR(20) NOT NULL,
    actor_type VARCHAR(20) NOT NULL
        CONSTRAINT booking_events_actor_type_check CHECK (actor_type IN ('SYSTEM', 'OWNER', 'CUSTOMER')),
    actor_id INT NULL,
    reason NVARCHAR(500) NOT NULL,
    occurred_at DATETIME2 NOT NULL DEFAULT GETDATE()
);

CREATE INDEX idx_booking_events_booking ON booking_events (booking_id, occurred_at, event_id);
GO

-- 10. BẢNG field_blocks (Đồng bộ từ public.field_blocks)
CREATE TABLE field_blocks (
    block_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    field_id BIGINT NOT NULL FOREIGN KEY REFERENCES SportsFields(field_id) ON DELETE CASCADE,
    starts_at DATETIME2 NOT NULL,
    ends_at DATETIME2 NOT NULL,
    reason NVARCHAR(250) NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT field_blocks_check CHECK (ends_at > starts_at),
    CONSTRAINT field_blocks_reason_check CHECK (LEN(LTRIM(RTRIM(reason))) > 0)
);

CREATE INDEX idx_field_blocks_window ON field_blocks (field_id, starts_at, ends_at);
GO

-- 11. BẢNG notifications (Đồng bộ từ public.notifications)
CREATE TABLE notifications (
    notification_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    recipient_id INT NOT NULL FOREIGN KEY REFERENCES Users(id) ON DELETE CASCADE,
    booking_id BIGINT NULL FOREIGN KEY REFERENCES bookings(booking_id) ON DELETE SET NULL,
    title NVARCHAR(150) NOT NULL,
    body NVARCHAR(500) NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    read_at DATETIME2 NULL
);

CREATE INDEX idx_notifications_recipient ON notifications (recipient_id, created_at DESC, notification_id DESC);
GO

-- 12. BẢNG reviews (Đồng bộ từ public.reviews)
CREATE TABLE reviews (
    review_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    field_id BIGINT NOT NULL CONSTRAINT fk_reviews_field REFERENCES SportsFields(field_id),
    customer_name NVARCHAR(100) NOT NULL,
    rating INT NOT NULL CONSTRAINT ck_reviews_rating CHECK (rating >= 1 AND rating <= 5),
    comment NVARCHAR(MAX) NOT NULL,
    owner_reply NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    replied_at DATETIME2 NULL
);

CREATE INDEX idx_reviews_field ON reviews (field_id);
CREATE INDEX idx_reviews_field_created ON reviews (field_id, created_at DESC, review_id DESC);
GO

-- 13. BẢNG chat_messages (Đồng bộ từ public.chat_messages)
CREATE TABLE chat_messages (
    message_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    sender_name NVARCHAR(100) NOT NULL,
    receiver_name NVARCHAR(100) NOT NULL,
    message_text NVARCHAR(1000) NOT NULL,
    sent_at DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

-- ====================================================================
-- PHẦN 2: DỮ LIỆU THỰC TẾ TỪ sportii.sql (DML DATA INSERTS)
-- ====================================================================

EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
GO

-- 1. Dữ liệu bảng Users (từ sportii.sql + tài khoản tiện ích)
SET IDENTITY_INSERT [Users] ON;
INSERT INTO [Users] ([id], [fullname], [email], [password], [avatar], [phone], [role], [created_at], [gender], [date_of_birth], [address])
VALUES
    (1, N'hnb', '20hnb@gmail.com', 'pbkdf2-sha256$210000$MFCmMFzCZ2vXB+V2UHFr+w==$dHPS6Fpkjz4ZOPzcaGwgXlzb/4v7Prjh7Z1Pn/C+Ko0=', NULL, '0339361553', 'USER', '2026-10-17 09:43:08.730378', N'male', '2006-06-25', N'67/385/D6/2'),
    (2, N'Chủ sân Sportify', 'toilachusan@gmail.com', 'pbkdf2-sha256$210000$cZO7YiGjGIY9vv5IkwfWGA==$X/1VKtkfrVn1y4RXZM/PXXmbq03aFezfUYxC6vTL0bQ=', NULL, '0339361553', 'OWNER', '2026-10-17 10:19:28.683569', NULL, NULL, N'TP. Hồ Chí Minh'),
    (6, N'Nguyễn Văn A', 'user@sportify.vn', '123456', NULL, '0987654321', 'USER', '2026-10-11 23:41:12.550000', N'male', '2000-01-01', N'Quận 7, TP. Hồ Chí Minh'),
    (7, N'Trần Thị B', 'owner@sportify.vn', '123456', NULL, '0901234567', 'OWNER', '2026-10-11 23:41:12.553000', N'female', '1998-05-15', N'Quận 1, TP. Hồ Chí Minh');
SET IDENTITY_INSERT [Users] OFF;
GO

-- 2. Dữ liệu bảng SportsFields (6 sân từ sportii.sql + Cụm Sân Bóng Bàn Pro, mỗi danh mục 4 sản phẩm sân)
SET IDENTITY_INSERT [SportsFields] ON;
INSERT INTO [SportsFields] ([field_id], [owner_id], [field_name], [sport_type], [address], [description], [price_per_hour], [open_time], [close_time], [image_url], [status], [created_at], [updated_at], [auto_approve], [quantity])
VALUES
    (1, 2, N'Phòng Gym FitZone', N'GYM', N'Quận 7, TP.HCM', N'Phòng gym đầy đủ thiết bị tập luyện.', 80000.00, '06:00:00', '22:00:00', N'assets/images/gym.jpg', N'ACTIVE', '2026-09-17 08:37:03.085355', '2026-09-17 08:37:03.085355', 0, 4),
    (2, 2, N'Sân bóng rổ Sunrise', N'BASKETBALL', N'Quận 3, TP.HCM', N'Sân bóng rổ trong nhà.', 180000.00, '07:00:00', '22:00:00', N'assets/images/basketballcourt1.jpg', N'ACTIVE', '2026-09-17 08:37:03.085355', '2026-09-17 08:37:03.085355', 0, 4),
    (3, 2, N'Hồ bơi Aqua Center', N'SWIMMING', N'Quận 1, TP.HCM', N'Hồ bơi dành cho luyện tập và giải trí.', 120000.00, '06:00:00', '21:00:00', N'assets/images/swimming.jpg', N'ACTIVE', '2026-09-17 08:37:03.085355', '2026-09-17 08:37:03.085355', 0, 4),
    (4, 2, N'Green Pickleball Court', N'PICKLEBALL', N'TP. Thủ Đức, TP.HCM', N'Sân pickleball ngoài trời.', 150000.00, '06:00:00', '22:00:00', N'assets/images/pickleball.jpg', N'ACTIVE', '2026-09-17 08:37:03.085355', '2026-09-17 08:37:03.085355', 0, 4),
    (5, 2, N'Sân Cú Vọ', N'PICKLEBALL', N'Nguyễn Văn Lượng, Gò Vấp, TP.HCM', N'Cụm sân Pickleball tiêu chuẩn thi đấu, hỗ trợ tự động xác nhận.', 300000.00, '06:00:00', '22:00:00', N'assets/images/pickleball.jpg', N'ACTIVE', '2026-09-21 07:42:30.140470', '2026-10-17 11:30:51.125010', 1, 4),
    (6, 2, N'Sân Elite', N'BASKETBALL', N'57 Phan Đình Phùng', N'Sân bóng rổ chất lượng cao, mặt sân gỗ tiêu chuẩn.', 250000.00, '06:00:00', '22:00:00', N'assets/images/basketball.jpg', N'ACTIVE', '2026-09-21 09:19:34.080369', '2026-10-17 11:30:15.454420', 1, 4),
    (7, 2, N'Cụm Sân Bóng Bàn Pro', N'TABLE_TENNIS', N'Quận 10, TP.HCM', N'Hệ thống 4 sân bóng bàn tiêu chuẩn thi đấu, bàn chuẩn ITTF, sàn chống trượt.', 100000.00, '06:00:00', '22:00:00', N'assets/images/pickleball.jpg', N'ACTIVE', '2026-10-17 08:00:00.000000', '2026-10-17 08:00:00.000000', 0, 4);
SET IDENTITY_INSERT [SportsFields] OFF;
GO

-- 3. Dữ liệu bảng bookings (8 đơn từ sportii.sql + 4 đơn mẫu lấp đầy 4/4 sân bóng bàn)
SET IDENTITY_INSERT [bookings] ON;
INSERT INTO [bookings] ([booking_id], [field_id], [customer_name], [customer_phone], [starts_at], [ends_at], [total_price], [status], [created_at], [updated_at], [customer_id], [confirmation_source], [court_number])
VALUES
    (1, 1, N'hnb', '0339361553', '2026-10-12 08:00:00', '2026-10-12 09:30:00', 120000.00, 'CONFIRMED', '2026-10-11 22:18:08.403212', '2026-10-11 22:20:19.549275', 1, 'MANUAL', 1),
    (2, 1, N'Lê Thu Trang', '0901000002', '2026-10-12 08:30:00', '2026-10-12 10:00:00', 120000.00, 'REJECTED', '2026-10-11 22:17:08.403212', '2026-10-11 22:20:30.289294', NULL, 'MANUAL', 2),
    (3, 1, N'Phạm Hoàng Nam', '0901000003', '2026-10-12 10:00:00', '2026-10-12 11:30:00', 120000.00, 'REJECTED', '2026-10-11 22:16:08.403212', '2026-10-11 22:21:22.365618', NULL, 'MANUAL', 1),
    (4, 1, N'Nguyễn Văn A', '0987654321', '2026-10-12 13:00:00', '2026-10-12 14:30:00', 120000.00, 'CONFIRMED', '2026-10-11 22:15:08.403212', '2026-10-11 22:15:08.403212', 6, 'MANUAL', 1),
    (5, 1, N'Đỗ Minh Anh', '0901000005', '2026-10-11 06:00:00', '2026-10-11 07:30:00', 120000.00, 'COMPLETED', '2026-10-11 22:14:08.403212', '2026-10-11 22:14:08.403212', NULL, 'MANUAL', 1),
    (6, 1, N'Vũ Khánh Linh', '0901000006', '2026-10-11 10:00:00', '2026-10-11 11:30:00', 120000.00, 'REJECTED', '2026-10-11 22:13:08.403212', '2026-10-11 22:13:08.403212', NULL, 'MANUAL', 1),
    (7, 6, N'Chủ sân Sportify', '0339361553', '2026-10-17 16:45:00', '2026-10-17 19:45:00', 750000.00, 'CONFIRMED', '2026-10-17 11:33:27.240869', '2026-10-17 11:33:27.240869', 2, 'AUTOMATIC', 1),
    (8, 5, N'hnb', '0339361553', '2026-10-17 12:30:00', '2026-10-17 13:00:00', 150000.00, 'CONFIRMED', '2026-10-17 12:19:53.014328', '2026-10-17 12:19:53.014328', 1, 'AUTOMATIC', 1),
    (9, 7, N'hnb', '0339361553', '2026-10-19 18:00:00', '2026-10-19 19:00:00', 100000.00, 'CONFIRMED', '2026-10-18 10:00:00.000000', '2026-10-18 10:00:00.000000', 1, 'MANUAL', 1),
    (10, 7, N'Nguyễn Văn A', '0987654321', '2026-10-19 18:00:00', '2026-10-19 19:00:00', 100000.00, 'CONFIRMED', '2026-10-18 10:05:00.000000', '2026-10-18 10:05:00.000000', 6, 'MANUAL', 2),
    (11, 7, N'Đặng Văn F', '0983333333', '2026-10-19 18:00:00', '2026-10-19 19:00:00', 100000.00, 'CONFIRMED', '2026-10-18 10:10:00.000000', '2026-10-18 10:10:00.000000', NULL, 'MANUAL', 3),
    (12, 7, N'Vũ Thị G', '0984444444', '2026-10-19 18:00:00', '2026-10-19 19:00:00', 100000.00, 'PENDING', '2026-10-18 10:15:00.000000', '2026-10-18 10:15:00.000000', NULL, 'MANUAL', 4);
SET IDENTITY_INSERT [bookings] OFF;
GO

-- 4. Dữ liệu bảng booking_events (từ sportii.sql)
SET IDENTITY_INSERT [booking_events] ON;
INSERT INTO [booking_events] ([event_id], [booking_id], [from_status], [to_status], [actor_type], [actor_id], [reason], [occurred_at])
VALUES
    (1, 7, NULL, 'CONFIRMED', 'SYSTEM', NULL, N'Sân hoạt động, đúng giờ mở cửa và còn trống; hệ thống tự xác nhận.', '2026-10-17 11:33:27.225359'),
    (2, 8, NULL, 'CONFIRMED', 'SYSTEM', NULL, N'Sân hoạt động, đúng giờ mở cửa và còn trống; hệ thống tự xác nhận.', '2026-10-17 12:19:52.906658');
SET IDENTITY_INSERT [booking_events] OFF;
GO

-- 5. Dữ liệu bảng field_blocks (từ sportii.sql)
SET IDENTITY_INSERT [field_blocks] ON;
INSERT INTO [field_blocks] ([block_id], [field_id], [starts_at], [ends_at], [reason], [created_at])
VALUES
    (1, 5, '2026-10-18 20:35:00', '2026-10-18 22:00:00', N'Ví dụ :  Cúp điện', '2026-10-17 11:31:34.983474');
SET IDENTITY_INSERT [field_blocks] OFF;
GO

-- 6. Dữ liệu bảng notifications (từ sportii.sql)
SET IDENTITY_INSERT [notifications] ON;
INSERT INTO [notifications] ([notification_id], [recipient_id], [booking_id], [title], [body], [created_at], [read_at])
VALUES
    (1, 2, 7, N'Đặt sân được tự động xác nhận', N'SP000007 · Sân Elite · 17/10/2026 16:45–19:45. Sân hoạt động, đúng giờ mở cửa và còn trống; hệ thống tự xác nhận.', '2026-10-17 11:33:27.225359', '2026-10-17 11:34:03.470708'),
    (2, 1, 8, N'Đặt sân được tự động xác nhận', N'SP000008 · Sân Cú Vọ · 17/10/2026 12:30–13:00. Sân hoạt động, đúng giờ mở cửa và còn trống; hệ thống tự xác nhận.', '2026-10-17 12:19:52.906658', NULL),
    (3, 2, 8, N'Đặt sân được tự động xác nhận', N'SP000008 · Sân Cú Vọ · 17/10/2026 12:30–13:00. Sân hoạt động, đúng giờ mở cửa và còn trống; hệ thống tự xác nhận.', '2026-10-17 12:19:52.906658', NULL);
SET IDENTITY_INSERT [notifications] OFF;
GO

-- 7. Dữ liệu bảng reviews (5 dòng từ sportii.sql)
SET IDENTITY_INSERT [reviews] ON;
INSERT INTO [reviews] ([review_id], [field_id], [customer_name], [rating], [comment], [owner_reply], [created_at], [replied_at])
VALUES
    (1, 3, N'Lê Thu Trang', 3, N'Sân ổn nhưng khu thay đồ cần được vệ sinh thường xuyên hơn.', N'Cảm ơn góp ý của bạn. Chúng tôi sẽ tăng tần suất vệ sinh khu thay đồ.', '2026-10-08 20:44:34.223570', '2026-10-08 21:44:34.223570'),
    (2, 5, N'Đỗ Khánh Linh', 1, N'Trải nghiệm chưa tốt, nhân viên hỗ trợ còn chậm.', N'dạ không', '2026-10-06 20:44:34.223570', '2026-10-11 20:50:24.069259'),
    (3, 1, N'Nguyễn Minh Anh', 5, N'Sân sạch, nhân viên nhiệt tình. Mình sẽ quay lại!', N'Cảm ơn bạn đã ghé sân. Rất mong được đón bạn lần tới!', '2026-10-10 20:44:34.223570', '2026-10-10 21:44:34.223570'),
    (4, 4, N'Phạm Hoàng Nam', 2, N'Ánh sáng buổi tối chưa đều, mong sân cải thiện.', NULL, '2026-10-07 20:44:34.223570', NULL),
    (5, 2, N'Trần Quốc Bảo', 4, N'Không gian tốt, mong sân bổ sung thêm chỗ gửi xe.', NULL, '2026-10-09 20:44:34.223570', NULL);
SET IDENTITY_INSERT [reviews] OFF;
GO

-- 8. Dữ liệu bảng chat_messages (7 dòng từ sportii.sql)
SET IDENTITY_INSERT [chat_messages] ON;
INSERT INTO [chat_messages] ([message_id], [sender_name], [receiver_name], [message_text], [sent_at])
VALUES
    (1, N'Khách hàng', N'Sân bóng Sunrise', N'Tôi muốn đặt sân lúc 19 giờ tối nay.', '2026-09-15 16:17:39.010477'),
    (2, N'Khách hàng', N'Sân bóng Sunrise', N'Tôi muốn đặt sân lúc 19 giờ tối nay.', '2026-09-15 16:36:35.807447'),
    (3, N'Khách hàng', N'Sân bóng Sunrise', N'Tôi muốn đặt sân lúc 19 giờ tối nay.', '2026-09-17 07:44:18.630533'),
    (4, N'Khách hàng', N'Sân bóng Sunrise', N'Xin chao', '2026-09-17 07:44:55.917229'),
    (5, N'Khách hàng', N'Sân bóng Sunrise', N'Chào em', '2026-09-17 08:44:18.099516'),
    (6, N'Khách hàng', N'Sân bóng Sunrise', N'Chào em', '2026-09-17 08:44:19.594139'),
    (7, N'Khách hàng', N'Sân bóng Sunrise', N'alo', '2026-09-21 08:01:06.533705');
SET IDENTITY_INSERT [chat_messages] OFF;
GO

-- 9. Dữ liệu bảng FriendMessages (từ sportii.sql + dữ liệu chuyển nhượng lịch đặt sân)
SET IDENTITY_INSERT [FriendMessages] ON;
INSERT INTO [FriendMessages] ([id], [sender_id], [receiver_id], [message_text], [created_at])
VALUES
    (1, 1, 2, N'anh ơi', '11:07'),
    (2, 2, 1, N'nghe nè', '12:17'),
    (3, 1, 2, N'sân ở Nguyễn Văn Lượng á', '12:20'),
    (4, 1, 2, N'em lỡ làm rách thảm rồi ạ', '12:20'),
    (5, 1, 2, N'huhu', '12:20'),
    (6, 2, 1, N'dỡn mặt hả', '12:23'),
    (7, 1, 6, N'[BOOKING_ASSET_TRANSFER|9|SP000009|Cụm Sân Bóng Bàn Pro|TABLE_TENNIS|1|19/10/2026|18:00 - 19:00|100.000 đ|hnb|Nguyễn Văn A|Mình nhượng lại ca bóng bàn này cho bạn nhé!]', '15:30'),
    (8, 6, 1, N'[BOOKING_ASSET_TRANSFER|9|SP000009|Cụm Sân Bóng Bàn Pro|TABLE_TENNIS|1|19/10/2026|18:00 - 19:00|100.000 đ|Nguyễn Văn A|hnb|Cảm ơn bạn, mình chuyển lại lịch sân này cho bạn!]', '15:31');
SET IDENTITY_INSERT [FriendMessages] OFF;
GO

-- 10. Dữ liệu bảng Posts, PostLikes, PostComments (từ sportii.sql + bài đăng đính kèm lịch sân)
SET IDENTITY_INSERT [Posts] ON;
INSERT INTO [Posts] ([id], [user_id], [content], [booking_id], [post_purpose], [created_at])
VALUES
    (1, 1, N'Hmm , hôm nay lạnh nhỉ ' + CHAR(10) + N'!', NULL, NULL, '2026-10-17 11:07:33.601250'),
    (2, 1, N'Tối nay hội mình đã đặt sẵn sân Pickleball, rủ thêm 2 bạn giao lưu cùng!', 8, N'TIM_DOI', '2026-10-19 03:20:00.000000'),
    (3, 6, N'Mình bận đột xuất nên cần nhượng lại lịch đặt sân đã xác nhận #SP000010 tại Cụm Sân Bóng Bàn Pro (Sân #2) ngày 19/10/2026 khung giờ 18:00 - 19:00. Bạn nào lấy nhắn tin cho mình để chuyển quyền sở hữu lịch sân ngay nhé!', 10, N'PASS_SAN', '2026-10-19 03:22:00.000000');
SET IDENTITY_INSERT [Posts] OFF;
GO

SET IDENTITY_INSERT [PostLikes] ON;
INSERT INTO [PostLikes] ([id], [post_id], [user_id])
VALUES
    (1, 1, 1);
SET IDENTITY_INSERT [PostLikes] OFF;
GO

SET IDENTITY_INSERT [PostComments] ON;
INSERT INTO [PostComments] ([id], [post_id], [user_id], [content], [created_at])
VALUES
    (1, 1, 1, N'có ny thì thích hơn', '2026-10-17 11:07:40.818977');
SET IDENTITY_INSERT [PostComments] OFF;
GO

-- ====================================================================
-- BẬT LẠI TOÀN BỘ RÀNG BUỘC KHÓA NGOẠI VÀ KIỂM TRA TÍNH TOÀN VẸN
-- ====================================================================
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';
GO

PRINT N'>>> SPORTIFYDB RESTORE TỪ sportii.sql HOÀN TẤT THÀNH CÔNG 100%! <<<';
GO
