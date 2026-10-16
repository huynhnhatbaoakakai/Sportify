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
                User user = new User(
                        rs.getInt("id"),
                        rs.getString("fullname"),
                        rs.getString("email"),
                        rs.getString("password"));
                user.setRole(rs.getString("role"));
                user.setPhone(rs.getString("phone"));
                return user;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnections();
        }
        return null;
    }

    public User getUserById(int userId) {
        try {
            String query = "SELECT * FROM Users WHERE id = ?";
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(query);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                User user = new User(
                        rs.getInt("id"),
                        rs.getString("fullname"),
                        rs.getString("email"),
                        rs.getString("password"));
                user.setRole(rs.getString("role"));
                user.setPhone(rs.getString("phone"));
                return user;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnections();
        }
        return null;
    }

    public java.util.Map<Integer, User> getAllUsersMap() {
        java.util.Map<Integer, User> map = new java.util.HashMap<>();
        try {
            String query = "SELECT * FROM Users";
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(query);
            rs = ps.executeQuery();
            while (rs.next()) {
                User user = new User(
                        rs.getInt("id"),
                        rs.getString("fullname"),
                        rs.getString("email"),
                        rs.getString("password"));
                user.setRole(rs.getString("role"));
                user.setPhone(rs.getString("phone"));
                map.put(user.getId(), user);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnections();
        }
        return map;
    }

    public void updatePhoneIfEmpty(int userId, String phone) {
        if (phone == null || phone.trim().isEmpty()) return;
        try {
            String query = "UPDATE Users SET phone = ? WHERE id = ? AND (phone IS NULL OR LTRIM(RTRIM(phone)) = '')";
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, phone.trim());
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnections();
        }
    }

    public int resolveOrCreateUser(String fullname, String phone) {
        if (phone != null && !phone.trim().isEmpty()) {
            try {
                String query = "SELECT id FROM Users WHERE phone = ?";
                conn = DBContext.getConnection();
                ps = conn.prepareStatement(query);
                ps.setString(1, phone.trim());
                rs = ps.executeQuery();
                if (rs.next()) return rs.getInt("id");
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                closeConnections();
            }
        }
        if (fullname != null && !fullname.trim().isEmpty()) {
            try {
                String query = "SELECT id FROM Users WHERE fullname = ?";
                conn = DBContext.getConnection();
                ps = conn.prepareStatement(query);
                ps.setString(1, fullname.trim());
                rs = ps.executeQuery();
                if (rs.next()) return rs.getInt("id");
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                closeConnections();
            }
        }
        try {
            String email = "guest_" + System.currentTimeMillis() + "@sportify.vn";
            User user = new User(fullname != null && !fullname.trim().isEmpty() ? fullname.trim() : "Khách hàng", email, "123456");
            user.setRole("USER");
            user.setPhone(phone != null && !phone.trim().isEmpty() ? phone.trim() : "0900000000");
            registerUser(user);
            User created = checkLogin(email, "123456");
            if (created != null) return created.getId();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 6;
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
            String query = "INSERT INTO Users (fullname, email, password, role, phone) VALUES (?, ?, ?, ?, ?)";
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, user.getFullname());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword()); // In production, password should be hashed
            ps.setString(4, user.getRole() != null ? user.getRole() : "USER");
            ps.setString(5, user.getPhone());
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
                User user = new User(
                        rs.getInt("id"),
                        rs.getString("fullname"),
                        rs.getString("email"),
                        rs.getString("password"));
                user.setRole(rs.getString("role"));
                user.setPhone(rs.getString("phone"));
                list.add(user);
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
