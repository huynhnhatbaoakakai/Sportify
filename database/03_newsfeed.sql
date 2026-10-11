-- Bảng lưu bài đăng trạng thái
CREATE TABLE Posts (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT FOREIGN KEY REFERENCES Users(id),
    content NVARCHAR(MAX) NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- Bảng lưu lượt tim (like)
CREATE TABLE PostLikes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    post_id INT FOREIGN KEY REFERENCES Posts(id) ON DELETE CASCADE,
    user_id INT FOREIGN KEY REFERENCES Users(id),
    UNIQUE(post_id, user_id)  -- Mỗi user chỉ like 1 lần
);
GO

-- Bảng lưu bình luận
CREATE TABLE PostComments (
    id INT IDENTITY(1,1) PRIMARY KEY,
    post_id INT FOREIGN KEY REFERENCES Posts(id) ON DELETE CASCADE,
    user_id INT FOREIGN KEY REFERENCES Users(id),
    content NVARCHAR(MAX) NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
);
GO

