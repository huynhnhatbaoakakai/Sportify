package com.sportify.config;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBContext {
    public static Connection getConnection() throws Exception {
        Class.forName("org.postgresql.Driver");
        return DriverManager.getConnection(
                DatabaseConfig.getJdbcUrl(), DatabaseConfig.getUsername(), DatabaseConfig.getPassword());
    }

    public static void main(String[] args) throws Exception {
        try (Connection connection = getConnection()) {
            System.out.println("Kết nối PostgreSQL thành công: " + connection.getCatalog());
        }
    }
}
