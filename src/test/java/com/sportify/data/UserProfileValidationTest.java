package com.sportify.data;

import com.sportify.dao.UserDAO;
import com.sportify.model.User;
import java.time.LocalDate;
import java.time.ZoneId;
import org.junit.Test;
import static org.junit.Assert.*;

public class UserProfileValidationTest {
    private User profile() {
        User user = new User();
        user.setFullname("Nguyễn Văn An");
        return user;
    }

    @Test public void optionalDetailsCanBeEmptyAndNamesMustBePresent() {
        assertNull(UserDAO.validateProfile(profile()));
        User user = profile();
        user.setFullname("   ");
        assertNotNull(UserDAO.validateProfile(user));
        user.setFullname("x".repeat(101));
        assertNotNull(UserDAO.validateProfile(user));
    }

    @Test public void rejectsFutureBirthDateAndAcceptsToday() {
        User user = profile();
        LocalDate today = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        user.setDateOfBirth(today.plusDays(1));
        assertNotNull(UserDAO.validateProfile(user));
        user.setDateOfBirth(today);
        assertNull(UserDAO.validateProfile(user));
    }

    @Test public void rejectsUnusablePhoneNumbersAndAcceptsCountryCode() {
        User user = profile();
        for (String value : new String[]{"123", "090abc4567", "++++++++++", "+1234567890123456"}) {
            user.setPhone(value);
            assertNotNull(value, UserDAO.validateProfile(user));
        }
        user.setPhone("+84901234567");
        assertNull(UserDAO.validateProfile(user));
    }

    @Test public void rejectsUnknownGenderAndOverlongAddress() {
        User user = profile();
        user.setGender("admin");
        assertNotNull(UserDAO.validateProfile(user));
        user.setGender("other");
        user.setAddress("x".repeat(501));
        assertNotNull(UserDAO.validateProfile(user));
        user.setAddress("Địa chỉ hợp lệ");
        assertNull(UserDAO.validateProfile(user));
    }
}
