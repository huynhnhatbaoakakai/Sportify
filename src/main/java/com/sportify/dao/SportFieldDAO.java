package com.sportify.dao;

import com.sportify.model.SportField;
import com.sportify.config.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SportFieldDAO {

    public List<SportField> findByOwnerId(long ownerId) {
        List<SportField> list = new ArrayList<>();
        String sql = "SELECT * FROM sports_fields WHERE owner_id = ? ORDER BY created_at DESC";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, ownerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToSportField(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void insert(SportField field) {
        String sql = "INSERT INTO sports_fields (owner_id, field_name, sport_type, address, description, price_per_hour, open_time, close_time, status, quantity) "
                +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, field.getOwnerId());
            ps.setString(2, field.getFieldName());
            ps.setString(3, field.getSportType());
            ps.setString(4, field.getAddress());
            ps.setString(5, field.getDescription());
            ps.setBigDecimal(6, field.getPricePerHour());
            ps.setObject(7, field.getOpenTime());
            ps.setObject(8, field.getCloseTime());
            ps.setString(9, field.getStatus() != null ? field.getStatus() : "ACTIVE");
            ps.setInt(10, field.getQuantity());

            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean update(SportField field, long ownerId) {
        String sql = "UPDATE sports_fields SET field_name=?, sport_type=?, address=?, description=?, price_per_hour=?, open_time=?, close_time=?, quantity=?, updated_at=CURRENT_TIMESTAMP "
                +
                "WHERE field_id=? AND owner_id=?";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, field.getFieldName());
            ps.setString(2, field.getSportType());
            ps.setString(3, field.getAddress());
            ps.setString(4, field.getDescription());
            ps.setBigDecimal(5, field.getPricePerHour());
            ps.setObject(6, field.getOpenTime());
            ps.setObject(7, field.getCloseTime());
            ps.setInt(8, field.getQuantity());
            ps.setLong(9, field.getFieldId());
            ps.setLong(10, ownerId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean toggleStatus(long fieldId, long ownerId) {
        String sql = "UPDATE sports_fields SET status = CASE WHEN status = 'ACTIVE' THEN 'INACTIVE' ELSE 'ACTIVE' END, updated_at=CURRENT_TIMESTAMP "
                +
                "WHERE field_id = ? AND owner_id = ?";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, fieldId);
            ps.setLong(2, ownerId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private SportField mapRowToSportField(ResultSet rs) throws SQLException {
        SportField field = new SportField();
        field.setFieldId(rs.getLong("field_id"));
        field.setOwnerId(rs.getLong("owner_id"));
        field.setFieldName(rs.getString("field_name"));
        field.setSportType(rs.getString("sport_type"));
        field.setAddress(rs.getString("address"));
        field.setDescription(rs.getString("description"));
        field.setPricePerHour(rs.getBigDecimal("price_per_hour"));

        // Handle time conversion safely
        java.sql.Time open = rs.getTime("open_time");
        if (open != null)
            field.setOpenTime(open.toString().substring(0, 5));

        java.sql.Time close = rs.getTime("close_time");
        if (close != null)
            field.setCloseTime(close.toString().substring(0, 5));

        field.setImageUrl(rs.getString("image_url"));
        field.setStatus(rs.getString("status"));
        try {
            int qty = rs.getInt("quantity");
            field.setQuantity(qty > 0 ? qty : 4);
        } catch (SQLException ignored) {
            field.setQuantity(4);
        }

        java.sql.Timestamp created = rs.getTimestamp("created_at");
        if (created != null)
            field.setCreatedAt(created.toString());

        java.sql.Timestamp updated = rs.getTimestamp("updated_at");
        if (updated != null)
            field.setUpdatedAt(updated.toString());

        return field;
    }
}
