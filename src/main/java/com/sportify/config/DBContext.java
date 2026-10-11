package com.sportify.config;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBContext {
    // Thông tin cấu hình chính xác từ SQL Server của bạn
    private static final String serverName = "localhost";
    private static final String portNumber = "1433";
    private static final String instance = "SQLEXPRESS"; // Tên Instance từ NGB\SQLEXPRESS
    private static final String dbName = "SportifyDB"; // Tên Database của bạn

    // Tài khoản đăng nhập SQL Server
    private static final String userID = "sa";
    private static final String password = "123"; // ⚠️ Đổi "123" thành mật khẩu tài khoản 'sa' mà bạn vừa đặt

    public static Connection getConnection() throws Exception {
        // Nạp Driver SQL Server
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

        // Chuỗi URL kết nối chuẩn
        String url = "jdbc:sqlserver://" + serverName + ":" + portNumber
                + ";instanceName=" + instance
                + ";databaseName=" + dbName
                + ";encrypt=true;trustServerCertificate=true;";

        return DriverManager.getConnection(url, userID, password);
    }

    // Hàm main để kiểm tra chạy thử trực tiếp
    public static void main(String[] args) {
        try {
            Connection conn = getConnection();
            if (conn != null && !conn.isClosed()) {
                System.out.println("=========================================");
                System.out.println("✅ KẾT NỐI DỮ LIỆU THÀNH CÔNG!");
                System.out.println("Database: " + dbName);
                System.out.println("Server: " + serverName + ":" + portNumber);
                System.out.println("=========================================");
                conn.close();
            }
        } catch (Exception e) {
            System.err.println("❌ KẾT NỐI THẤT BẠI!");
            e.printStackTrace();
        }
    }
}
