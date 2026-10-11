-- =============================================
-- CSDL Sportify - Khởi tạo bảng cơ sở
-- Chạy trên SQL Server Management Studio (SSMS)
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SportifyDB')
BEGIN
    CREATE DATABASE SportifyDB;
END
GO

USE SportifyDB;
GO

-- 1. Bảng Users (Người dùng hệ thống)
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

    -- Dữ liệu mẫu ban đầu
    INSERT INTO Users (fullname, email, password, role)
    VALUES 
      (N'Nguyễn Văn A', 'user@sportify.vn', '123456', 'USER'),
      (N'Trần Thị B', 'owner@sportify.vn', '123456', 'OWNER');
END
GO

-- 2. Bảng Lịch hẹn (Appointments)
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

-- 3. Bảng Buổi tập (TrainingSessions) để tính giờ tập trong tháng
IF OBJECT_ID('TrainingSessions', 'U') IS NULL
BEGIN
    CREATE TABLE TrainingSessions (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL FOREIGN KEY REFERENCES Users(id) ON DELETE CASCADE,
        duration_hours INT NOT NULL DEFAULT 1,
        session_date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
        note NVARCHAR(255) NULL
    );

    -- Mẫu buổi tập tháng này
    INSERT INTO TrainingSessions (user_id, duration_hours, session_date, note)
    VALUES (1, 2, CAST(GETDATE() AS DATE), N'Tập gym buổi chiều');
END
GO

-- 4. Bảng Chat dịch vụ (ChatSessions & Messages)
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

-- 5. Bảng Chat bạn bè (FriendMessages)
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

