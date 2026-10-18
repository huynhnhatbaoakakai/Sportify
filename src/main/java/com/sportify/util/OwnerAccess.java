package com.sportify.util;

import com.sportify.model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

public final class OwnerAccess {
    private OwnerAccess() { }

    public static User currentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : (User) session.getAttribute("user");
    }

    public static Long ownerId(HttpServletRequest request) {
        User user = currentUser(request);
        if (user == null || !user.isOwner()) throw new SecurityException("Cần tài khoản chủ sân.");
        return (long) user.getId();
    }
}
