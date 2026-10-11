USE SportifyDB;
GO

-- Xoá bảng nếu đã tồn tại để tránh lỗi
IF OBJECT_ID('SportsFields', 'U') IS NOT NULL
    DROP TABLE SportsFields;
GO

-- Bảng lưu thông tin sân thể thao / dịch vụ
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
    
    -- Đưa các ràng buộc liên quan đến nhiều cột xuống cuối bảng
    CONSTRAINT chk_time CHECK (close_time > open_time),
    CONSTRAINT uq_owner_name_address UNIQUE (owner_id, field_name, address)
);
GO

-- Insert 4 sân demo (owner_id=1 khớp với user id=1 trong bảng Users)
INSERT INTO SportsFields (owner_id, field_name, sport_type, address, description, price_per_hour, open_time, close_time)
VALUES
  (1, N'Phòng Gym FitZone',    'GYM',        N'Quận 7, TP.HCM',      N'Phòng gym đầy đủ thiết bị.', 80000,  '06:00', '22:00'),
  (1, N'Sân bóng rổ Sunrise',  'BASKETBALL', N'Quận 3, TP.HCM',      N'Sân bóng rổ trong nhà.',     180000, '07:00', '22:00'),
  (1, N'Hồ bơi Aqua Center',   'SWIMMING',   N'Quận 1, TP.HCM',      N'Hồ bơi giải trí.',           120000, '06:00', '21:00'),
  (1, N'Green Pickleball Court','PICKLEBALL', N'TP. Thủ Đức, TP.HCM', N'Sân pickleball ngoài trời.', 150000, '06:00', '22:00');
GO
