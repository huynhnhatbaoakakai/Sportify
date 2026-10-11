-- ====================================================================
-- Sportify - CSDL Đồng bộ thống nhất trên Microsoft SQL Server
-- Database: SportifyDB
-- Tác vụ: Khởi tạo, bổ sung và đồng bộ toàn bộ bảng và dữ liệu mẫu
-- ====================================================================

USE SportifyDB;
GO

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
        role VARCHAR(20) DEFAULT 'USER', -- USER, OWNER, ADMIN
        created_at DATETIME DEFAULT GETDATE()
    );
END
ELSE
BEGIN
    -- Bổ sung các cột nếu thiếu
    IF COL_LENGTH('Users', 'avatar') IS NULL
        ALTER TABLE Users ADD avatar VARCHAR(255) NULL;
    IF COL_LENGTH('Users', 'phone') IS NULL
        ALTER TABLE Users ADD phone VARCHAR(20) NULL;
    IF COL_LENGTH('Users', 'role') IS NULL
        ALTER TABLE Users ADD role VARCHAR(20) DEFAULT 'USER';
    IF COL_LENGTH('Users', 'created_at') IS NULL
        ALTER TABLE Users ADD created_at DATETIME DEFAULT GETDATE();
END
GO

-- Cập nhật tài khoản hiện có id=1 thành ADMIN/OWNER
UPDATE Users SET role = 'ADMIN' WHERE id = 1 AND (role IS NULL OR role = 'USER');

-- Ưu tiên thêm các tài khoản mẫu từ 01_init_schema.sql nếu chưa có
IF NOT EXISTS (SELECT 1 FROM Users WHERE email = 'user@sportify.vn')
    INSERT INTO Users (fullname, email, password, role) VALUES (N'Nguyễn Văn A', 'user@sportify.vn', '123456', 'USER');

IF NOT EXISTS (SELECT 1 FROM Users WHERE email = 'owner@sportify.vn')
    INSERT INTO Users (fullname, email, password, role) VALUES (N'Trần Thị B', 'owner@sportify.vn', '123456', 'OWNER');
GO

-- 2. BẢNG Appointments (Lịch hẹn cá nhân)
IF OBJECT_ID('Appointments', 'U') IS NULL
BEGIN
    CREATE TABLE Appointments (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL FOREIGN KEY REFERENCES Users(id) ON DELETE CASCADE,
        title NVARCHAR(255) NOT NULL,
        appointment_date VARCHAR(20) NOT NULL,
        appointment_time VARCHAR(20) NOT NULL,
        type VARCHAR(50) NOT NULL DEFAULT 'court', -- 'court' hoặc 'pt'
        note NVARCHAR(MAX) NULL,
        created_at DATETIME DEFAULT GETDATE()
    );
END
GO

-- 3. BẢNG TrainingSessions (Giờ tập trong tháng)
IF OBJECT_ID('TrainingSessions', 'U') IS NULL
BEGIN
    CREATE TABLE TrainingSessions (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL FOREIGN KEY REFERENCES Users(id) ON DELETE CASCADE,
        duration_hours INT NOT NULL DEFAULT 1,
        session_date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
        note NVARCHAR(255) NULL
    );

    -- Dữ liệu mẫu
    INSERT INTO TrainingSessions (user_id, duration_hours, session_date, note)
    VALUES (1, 2, CAST(GETDATE() AS DATE), N'Tập gym buổi chiều');
END
GO

-- 4. BẢNG ChatSessions & Messages (Chat hệ thống cũ)
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
        sender VARCHAR(20) NOT NULL, -- 'me' hoặc 'them'
        message_text NVARCHAR(MAX) NOT NULL,
        created_at VARCHAR(50) NOT NULL
    );
END
GO

-- 5. BẢNG FriendMessages (Tin nhắn bạn bè)
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

-- 6. BẢNG SportsFields (Sân thể thao)
IF OBJECT_ID('SportsFields', 'U') IS NULL
BEGIN
    CREATE TABLE SportsFields (
        field_id   BIGINT IDENTITY(1,1) PRIMARY KEY,
        owner_id   INT NOT NULL DEFAULT 1 FOREIGN KEY REFERENCES Users(id), 
        field_name NVARCHAR(150) NOT NULL,
        sport_type NVARCHAR(30)  NOT NULL
            CONSTRAINT chk_sport_type CHECK (sport_type IN ('GYM','BASKETBALL','SWIMMING','PICKLEBALL')),
        address    NVARCHAR(255) NOT NULL,
        description NVARCHAR(MAX),
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

    INSERT INTO SportsFields (owner_id, field_name, sport_type, address, description, price_per_hour, open_time, close_time, image_url)
    VALUES
      (1, N'Phòng Gym FitZone',     'GYM',        N'Quận 7, TP.HCM',      N'Phòng gym đầy đủ thiết bị hiện đại, không gian rộng rãi.', 80000,  '06:00', '22:00', 'assets/images/gymfitzone.jfif'),
      (1, N'Sân bóng rổ Sunrise',   'BASKETBALL', N'Quận 3, TP.HCM',      N'Sân bóng rổ trong nhà đạt chuẩn thi đấu, sàn gỗ cao cấp.', 180000, '07:00', '22:00', 'assets/images/basketballcourt1.jpg'),
      (1, N'Hồ bơi Aqua Center',    'SWIMMING',   N'Quận 1, TP.HCM',      N'Hồ bơi 4 mùa nước ấm, view trên cao, làn bơi chuẩn Olympic.', 120000, '06:00', '21:00', 'assets/images/swimmingpoolaqua.jfif'),
      (1, N'Green Pickleball Court','PICKLEBALL', N'TP. Thủ Đức, TP.HCM', N'Cụm sân pickleball ngoài trời thoáng đãng, đèn chiếu sáng ban đêm.', 150000, '06:00', '22:00', 'assets/images/greenpickleballcourt.jfif');
END
GO

-- Đảm bảo synonym sports_fields tồn tại
IF NOT EXISTS (SELECT 1 FROM sys.synonyms WHERE name = 'sports_fields')
BEGIN
    CREATE SYNONYM sports_fields FOR SportsFields;
END
GO

-- 7. BẢNG Posts, PostLikes, PostComments (Mạng xã hội / Newsfeed)
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

-- 8. BẢNG bookings (Hệ thống đặt sân)
IF OBJECT_ID('bookings', 'U') IS NULL
BEGIN
    CREATE TABLE bookings (
        booking_id BIGINT IDENTITY(1,1) PRIMARY KEY,
        field_id BIGINT NOT NULL CONSTRAINT fk_bookings_field REFERENCES SportsFields(field_id),
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

    CREATE INDEX idx_bookings_field_created
        ON bookings (field_id, created_at DESC, booking_id DESC);

    CREATE INDEX idx_bookings_field_status_start
        ON bookings (field_id, status, starts_at);
END
GO

-- Liên kết đơn đặt sân với tài khoản khách hàng (khách đặt từ trang chủ)
IF COL_LENGTH('bookings', 'customer_id') IS NULL
BEGIN
    ALTER TABLE bookings ADD customer_id INT NULL;
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_bookings_customer' AND object_id = OBJECT_ID('bookings'))
BEGIN
    CREATE INDEX idx_bookings_customer ON bookings (customer_id, starts_at DESC);
END
GO

-- Dữ liệu mẫu bookings từ bookings.sql (Part 2)
IF NOT EXISTS (SELECT 1 FROM bookings)
BEGIN
    DECLARE @fid BIGINT, @price DECIMAL(12,2), @open_t TIME;
    SELECT TOP 1 @fid = field_id, @price = price_per_hour, @open_t = open_time 
    FROM SportsFields WHERE owner_id = 1 AND status = 'ACTIVE' ORDER BY field_id;

    IF @fid IS NOT NULL
    BEGIN
        DECLARE @today DATE = CAST(GETDATE() AS DATE);
        DECLARE @tomorrow DATE = DATEADD(DAY, 1, @today);

        -- Đơn 1: PENDING ngày mai 08:00 - 09:30
        INSERT INTO bookings (field_id, customer_name, customer_phone, starts_at, ends_at, total_price, status, created_at, updated_at)
        VALUES (@fid, N'Trần Gia Huy', '0901000001', 
                DATETIME2FROMPARTS(YEAR(@tomorrow), MONTH(@tomorrow), DAY(@tomorrow), 8, 0, 0, 0, 0),
                DATETIME2FROMPARTS(YEAR(@tomorrow), MONTH(@tomorrow), DAY(@tomorrow), 9, 30, 0, 0, 0),
                @price * 1.5, 'PENDING', DATEADD(MINUTE, -10, GETDATE()), GETDATE());

        -- Đơn 2: PENDING ngày mai 08:30 - 10:00 (trùng giờ để test)
        INSERT INTO bookings (field_id, customer_name, customer_phone, starts_at, ends_at, total_price, status, created_at, updated_at)
        VALUES (@fid, N'Lê Thu Trang', '0901000002', 
                DATETIME2FROMPARTS(YEAR(@tomorrow), MONTH(@tomorrow), DAY(@tomorrow), 8, 30, 0, 0, 0),
                DATETIME2FROMPARTS(YEAR(@tomorrow), MONTH(@tomorrow), DAY(@tomorrow), 10, 0, 0, 0, 0),
                @price * 1.5, 'PENDING', DATEADD(MINUTE, -8, GETDATE()), GETDATE());

        -- Đơn 3: PENDING ngày mai 10:00 - 11:30
        INSERT INTO bookings (field_id, customer_name, customer_phone, starts_at, ends_at, total_price, status, created_at, updated_at)
        VALUES (@fid, N'Phạm Hoàng Nam', '0901000003', 
                DATETIME2FROMPARTS(YEAR(@tomorrow), MONTH(@tomorrow), DAY(@tomorrow), 10, 0, 0, 0, 0),
                DATETIME2FROMPARTS(YEAR(@tomorrow), MONTH(@tomorrow), DAY(@tomorrow), 11, 30, 0, 0, 0),
                @price * 1.5, 'PENDING', DATEADD(MINUTE, -6, GETDATE()), GETDATE());

        -- Đơn 4: CONFIRMED ngày mai 13:00 - 14:30
        INSERT INTO bookings (field_id, customer_name, customer_phone, starts_at, ends_at, total_price, status, created_at, updated_at)
        VALUES (@fid, N'Nguyễn Quốc Bảo', '0901000004', 
                DATETIME2FROMPARTS(YEAR(@tomorrow), MONTH(@tomorrow), DAY(@tomorrow), 13, 0, 0, 0, 0),
                DATETIME2FROMPARTS(YEAR(@tomorrow), MONTH(@tomorrow), DAY(@tomorrow), 14, 30, 0, 0, 0),
                @price * 1.5, 'CONFIRMED', DATEADD(MINUTE, -4, GETDATE()), GETDATE());

        -- Đơn 5: COMPLETED hôm nay 06:00 - 07:30
        INSERT INTO bookings (field_id, customer_name, customer_phone, starts_at, ends_at, total_price, status, created_at, updated_at)
        VALUES (@fid, N'Đỗ Minh Anh', '0901000005', 
                DATETIME2FROMPARTS(YEAR(@today), MONTH(@today), DAY(@today), 6, 0, 0, 0, 0),
                DATETIME2FROMPARTS(YEAR(@today), MONTH(@today), DAY(@today), 7, 30, 0, 0, 0),
                @price * 1.5, 'COMPLETED', DATEADD(MINUTE, -2, GETDATE()), GETDATE());

        -- Đơn 6: REJECTED hôm nay 10:00 - 11:30
        INSERT INTO bookings (field_id, customer_name, customer_phone, starts_at, ends_at, total_price, status, created_at, updated_at)
        VALUES (@fid, N'Vũ Khánh Linh', '0901000006', 
                DATETIME2FROMPARTS(YEAR(@today), MONTH(@today), DAY(@today), 10, 0, 0, 0, 0),
                DATETIME2FROMPARTS(YEAR(@today), MONTH(@today), DAY(@today), 11, 30, 0, 0, 0),
                @price * 1.5, 'REJECTED', DATEADD(MINUTE, -1, GETDATE()), GETDATE());
    END
END
GO

-- 9. BẢNG reviews (Đánh giá sân của khách hàng)
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

-- Dữ liệu mẫu reviews
IF NOT EXISTS (SELECT 1 FROM reviews)
BEGIN
    DECLARE @rfid BIGINT;
    SELECT TOP 1 @rfid = field_id FROM SportsFields WHERE owner_id = 1 ORDER BY field_id;
    IF @rfid IS NOT NULL
    BEGIN
        INSERT INTO reviews (field_id, customer_name, rating, comment, owner_reply, created_at, replied_at)
        VALUES 
          (@rfid, N'Trần Gia Huy', 5, N'Sân rất đẹp, thiết bị hiện đại, vệ sinh sạch sẽ!', N'Cảm ơn bạn đã ủng hộ sân!', DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, DATEADD(HOUR, 1, GETDATE()))),
          (@rfid, N'Lê Thu Trang', 4, N'Không gian rộng rãi, nhân viên hỗ trợ nhiệt tình.', NULL, DATEADD(DAY, -1, GETDATE()), NULL),
          (@rfid, N'Nguyễn Quốc Bảo', 5, N'Chất lượng dịch vụ tuyệt vời, sẽ ghé lại thường xuyên!', N'Rất vui được phục vụ bạn!', GETDATE(), DATEADD(MINUTE, 30, GETDATE()));
    END
END
GO

-- 10. BẢNG chat_messages (Tin nhắn hỗ trợ khách hàng qua JPA)
IF OBJECT_ID('chat_messages', 'U') IS NULL
BEGIN
    CREATE TABLE chat_messages (
        message_id BIGINT IDENTITY(1,1) PRIMARY KEY,
        sender_name NVARCHAR(100) NOT NULL,
        receiver_name NVARCHAR(100) NOT NULL,
        message_text NVARCHAR(1000) NOT NULL,
        sent_at DATETIME2 NOT NULL DEFAULT GETDATE()
    );

    INSERT INTO chat_messages (sender_name, receiver_name, message_text, sent_at)
    VALUES 
      (N'Trần Gia Huy', N'Chủ Sân', N'Chào chủ sân, sân ngày mai có thể đặt thêm bóng tập không ạ?', DATEADD(MINUTE, -15, GETDATE())),
      (N'Chủ Sân', N'Trần Gia Huy', N'Chào bạn, bên mình có sẵn bóng và đồ tập miễn phí nhé!', DATEADD(MINUTE, -10, GETDATE()));
END
GO

