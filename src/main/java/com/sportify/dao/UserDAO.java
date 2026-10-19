package com.sportify.dao;

import com.sportify.config.DBContext;
import com.sportify.model.User;
import com.sportify.util.PasswordHasher;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public User getUserById(int userId) { return findById(userId); }

    public java.util.Map<Integer, User> getAllUsersMap() {
        java.util.Map<Integer, User> users = new java.util.HashMap<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT " + PROFILE_COLUMNS + " FROM public.users");
             ResultSet result = statement.executeQuery()) {
            while (result.next()) { User user = readProfile(result); users.put(user.getId(), user); }
            return users;
        } catch (Exception exception) { throw new IllegalStateException("Không thể tải khách hàng.", exception); }
    }

    public void updatePhoneIfEmpty(int userId, String phone) {
        if (phone == null || phone.isBlank()) return;
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "UPDATE public.users SET phone=? WHERE id=? AND (phone IS NULL OR BTRIM(phone)='')")) {
            statement.setString(1, phone.trim()); statement.setInt(2, userId); statement.executeUpdate();
        } catch (Exception exception) { throw new IllegalStateException("Không thể lưu số điện thoại.", exception); }
    }

    public int resolveOrCreateUser(String fullname, String phone) {
        try (Connection connection = DBContext.getConnection()) {
            if (phone != null && !phone.isBlank()) {
                try (PreparedStatement lookup = connection.prepareStatement("SELECT id FROM public.users WHERE phone=? ORDER BY id LIMIT 1")) {
                    lookup.setString(1, phone.trim());
                    try (ResultSet result = lookup.executeQuery()) { if (result.next()) return result.getInt(1); }
                }
            }
            try (PreparedStatement insert = connection.prepareStatement(
                    "INSERT INTO public.users (fullname,email,password,role,phone) VALUES (?,?,?,'USER',?) RETURNING id")) {
                insert.setString(1, fullname == null || fullname.isBlank() ? "Khách hàng" : fullname.trim());
                insert.setString(2, "guest-" + java.util.UUID.randomUUID() + "@example.invalid");
                insert.setString(3, PasswordHasher.hash(java.util.UUID.randomUUID().toString()));
                insert.setString(4, blankToNull(phone));
                try (ResultSet result = insert.executeQuery()) { result.next(); return result.getInt(1); }
            }
        } catch (Exception exception) { throw new IllegalStateException("Không thể tạo hồ sơ khách hàng.", exception); }
    }
    private static final String PROFILE_COLUMNS = "id, fullname, email, role, phone, gender, date_of_birth, address, created_at";
    public User checkLogin(String email, String password) {
        if (email == null || password == null) return null;
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT " + PROFILE_COLUMNS + ", password FROM public.users WHERE LOWER(email) = LOWER(?)")) {
            statement.setString(1, email.trim());
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) return null;
                String stored = result.getString("password");
                if (!PasswordHasher.verify(password, stored)) return null;
                User user = readProfile(result);
                if (!PasswordHasher.isHashed(stored)) {
                    try (PreparedStatement upgrade = connection.prepareStatement(
                            "UPDATE public.users SET password = ? WHERE id = ? AND password = ?")) {
                        upgrade.setString(1, PasswordHasher.hash(password));
                        upgrade.setInt(2, user.getId());
                        upgrade.setString(3, stored);
                        upgrade.executeUpdate();
                    }
                }
                return user;
            }
        } catch (Exception exception) {
            throw new IllegalStateException("Không thể đăng nhập. Vui lòng thử lại.", exception);
        }
    }

    public boolean checkEmailExists(String email) {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT 1 FROM public.users WHERE LOWER(email) = LOWER(?)")) {
            statement.setString(1, email.trim());
            try (ResultSet result = statement.executeQuery()) { return result.next(); }
        } catch (Exception exception) {
            throw new IllegalStateException("Không thể kiểm tra email.", exception);
        }
    }

    public String registerUser(User user) {
        if (user == null || user.getFullname() == null || user.getFullname().isBlank()
                || user.getFullname().trim().length() > 100 || user.getEmail() == null
                || !user.getEmail().trim().matches("[^\\s@]+@[^\\s@]+\\.[^\\s@]+")
                || user.getEmail().trim().length() > 100 || user.getPassword() == null
                || user.getPassword().length() < 6 || user.getPassword().length() > 200) return "INVALID";
        try {
            if (checkEmailExists(user.getEmail())) return "EMAIL_EXISTS";
            try (Connection connection = DBContext.getConnection();
                 PreparedStatement statement = connection.prepareStatement(
                         "INSERT INTO public.users (fullname, email, password, role) VALUES (?, LOWER(?), ?, 'USER')")) {
                statement.setString(1, user.getFullname().trim());
                statement.setString(2, user.getEmail().trim());
                statement.setString(3, PasswordHasher.hash(user.getPassword()));
                return statement.executeUpdate() == 1 ? "SUCCESS" : "DB_ERROR";
            }
        } catch (SQLException exception) {
            return "23505".equals(exception.getSQLState()) ? "EMAIL_EXISTS" : "DB_ERROR";
        } catch (Exception exception) {
            return "DB_ERROR";
        }
    }

    public List<User> getAllUsersExcept(int currentUserId) {
        List<User> users = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT id, fullname, email, role FROM public.users WHERE id <> ? ORDER BY id")) {
            statement.setInt(1, currentUserId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) users.add(readUser(result));
            }
        } catch (Exception exception) {
            throw new IllegalStateException("Không thể tải danh sách người dùng.", exception);
        }
        return users;
    }

    public User findById(int userId) {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT " + PROFILE_COLUMNS + " FROM public.users WHERE id = ?")) {
            statement.setInt(1, userId);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? readProfile(result) : null;
            }
        } catch (Exception exception) {
            throw new IllegalStateException("Không thể tải hồ sơ.", exception);
        }
    }

    /** Only editable profile columns are written; the ID always comes from the authenticated session. */
    public User updateProfile(int userId, User profile) {
        String error = validateProfile(profile);
        if (error != null) throw new IllegalArgumentException(error);
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "UPDATE public.users SET fullname = ?, phone = ?, gender = ?, date_of_birth = ?, address = ? "
                     + "WHERE id = ? RETURNING " + PROFILE_COLUMNS)) {
            statement.setString(1, profile.getFullname().trim());
            statement.setString(2, blankToNull(profile.getPhone()));
            statement.setString(3, blankToNull(profile.getGender()));
            statement.setObject(4, profile.getDateOfBirth());
            statement.setString(5, blankToNull(profile.getAddress()));
            statement.setInt(6, userId);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? readProfile(result) : null;
            }
        } catch (Exception exception) {
            throw new IllegalStateException("Không thể lưu hồ sơ.", exception);
        }
    }

    public static String validateProfile(User profile) {
        if (profile == null || profile.getFullname() == null || profile.getFullname().isBlank()
                || profile.getFullname().trim().length() > 100) return "Họ tên phải có từ 1 đến 100 ký tự.";
        String phone = blankToNull(profile.getPhone());
        if (phone != null && !phone.matches("[+]?[0-9]{8,15}"))
            return "Số điện thoại cần có 8–15 chữ số, có thể bắt đầu bằng dấu +.";
        String gender = blankToNull(profile.getGender());
        if (gender != null && !java.util.Set.of("male", "female", "other").contains(gender))
            return "Vui lòng chọn giới tính hợp lệ.";
        if (profile.getDateOfBirth() != null && (profile.getDateOfBirth().getYear() < 1
                || profile.getDateOfBirth().isAfter(java.time.LocalDate.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh")))))
            return "Ngày sinh không được nằm trong tương lai.";
        if (profile.getAddress() != null && profile.getAddress().trim().length() > 500)
            return "Địa chỉ không được vượt quá 500 ký tự.";
        return null;
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    private static User readProfile(ResultSet result) throws SQLException {
        User user = readUser(result);
        user.setPhone(result.getString("phone"));
        user.setGender(result.getString("gender"));
        user.setDateOfBirth(result.getObject("date_of_birth", java.time.LocalDate.class));
        user.setAddress(result.getString("address"));
        user.setCreatedAt(result.getObject("created_at", java.time.LocalDateTime.class));
        return user;
    }

    private static User readUser(ResultSet result) throws SQLException {
        User user = new User(result.getInt("id"), result.getString("fullname"), result.getString("email"), null);
        user.setRole(result.getString("role"));
        return user;
    }
}
