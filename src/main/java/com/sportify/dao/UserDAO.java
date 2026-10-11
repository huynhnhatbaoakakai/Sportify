package com.sportify.dao;

import com.sportify.model.User;
import com.sportify.config.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;

public class UserDAO {
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    public User checkLogin(String email, String password) {
        try {
            String query = "SELECT * FROM Users WHERE email = ? AND password = ?";
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, email);
            ps.setString(2, password);
            rs = ps.executeQuery();
            if (rs.next()) {
                return new User(
                        rs.getInt("id"),
                        rs.getString("fullname"),
                        rs.getString("email"),
                        rs.getString("password"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnections();
        }
        return null;
    }

    public boolean checkEmailExists(String email) {
        try {
            String query = "SELECT * FROM Users WHERE email = ?";
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, email);
            rs = ps.executeQuery();
            if (rs.next()) {
                return true; // email exists
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnections();
        }
        return false;
    }

    public String registerUser(User user) {
        if (checkEmailExists(user.getEmail())) {
            return "EMAIL_EXISTS";
        }

        try {
            String query = "INSERT INTO Users (fullname, email, password) VALUES (?, ?, ?)";
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, user.getFullname());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword()); // In production, password should be hashed
            int result = ps.executeUpdate();
            return result > 0 ? "SUCCESS" : "DB_ERROR";
        } catch (Exception e) {
            e.printStackTrace();
            return "DB_ERROR";
        } finally {
            closeConnections();
        }
    }

    public List<User> getAllUsersExcept(int currentUserId) {
        List<User> list = new java.util.ArrayList<>();
        try {
            String query = "SELECT * FROM Users WHERE id != ?";
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(query);
            ps.setInt(1, currentUserId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new User(
                        rs.getInt("id"),
                        rs.getString("fullname"),
                        rs.getString("email"),
                        rs.getString("password")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnections();
        }
        return list;
    }

    private void closeConnections() {
        try {
            if (rs != null)
                rs.close();
            if (ps != null)
                ps.close();
            if (conn != null)
                conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
