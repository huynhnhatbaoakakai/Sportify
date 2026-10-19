package com.sportify.dao;

import com.sportify.model.Appointment;
import com.sportify.config.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AppointmentDAO {

    // Lấy tất cả lịch hẹn sắp tới (hôm nay trở đi) của user
    public List<Appointment> getUpcomingAppointments(int userId) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT * FROM Appointments WHERE user_id = ? AND type = 'court' " +
                     "AND appointment_date >= CURRENT_DATE " +
                     "ORDER BY appointment_date ASC, appointment_time ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Đếm số lịch hẹn sắp tới
    public int countUpcoming(int userId) {
        String sql = "SELECT COUNT(*) FROM Appointments WHERE user_id = ? AND type = 'court' " +
                     "AND appointment_date >= CURRENT_DATE";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Tính tổng giờ tập trong tháng hiện tại (loại "pt")
    public int getTrainingHoursThisMonth(int userId) {
        String sql = "SELECT COALESCE(SUM(duration_hours), 0) FROM training_sessions " +
                     "WHERE user_id = ? " +
                     "AND session_date >= date_trunc('month', CURRENT_DATE)::date " +
                     "AND session_date < (date_trunc('month', CURRENT_DATE) + INTERVAL '1 month')::date";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Tạo lịch hẹn mới
    public boolean createAppointment(Appointment a) {
        if (a == null || !"court".equals(a.getType())) return false;
        String sql = "INSERT INTO Appointments (user_id, title, appointment_date, appointment_time, type, note) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, a.getUserId());
            ps.setString(2, a.getTitle());
            ps.setObject(3, java.time.LocalDate.parse(a.getAppointmentDate()));
            ps.setObject(4, java.time.LocalTime.parse(a.getAppointmentTime()));
            ps.setString(5, a.getType());
            ps.setString(6, a.getNote());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Xóa lịch hẹn
    public boolean deleteAppointment(int id, int userId) {
        String sql = "DELETE FROM Appointments WHERE id = ? AND user_id = ? AND type = 'court'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Lấy tất cả lịch hẹn (kể cả cũ) để hiển thị lịch sử
    public List<Appointment> getAllAppointments(int userId) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT * FROM Appointments WHERE user_id = ? AND type = 'court' " +
                     "ORDER BY appointment_date DESC, appointment_time DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private Appointment mapRow(ResultSet rs) throws SQLException {
        Appointment a = new Appointment();
        a.setId(rs.getInt("id"));
        a.setUserId(rs.getInt("user_id"));
        a.setTitle(rs.getString("title"));
        a.setAppointmentDate(rs.getString("appointment_date"));
        a.setAppointmentTime(rs.getString("appointment_time"));
        a.setType(rs.getString("type"));
        a.setNote(rs.getString("note"));
        return a;
    }
}

