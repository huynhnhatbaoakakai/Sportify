package com.sportify.util;

import com.sportify.data.SportFieldDB;
import com.sportify.model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

public final class OwnerAccess {
    private OwnerAccess() { }

    public static User currentUser(HttpServletRequest request) {
        try {
            HttpSession session = request.getSession(false);
            Object attr = session == null ? null : session.getAttribute("user");
            return attr instanceof User ? (User) attr : null;
        } catch (Throwable ignored) {
            return null;
        }
    }

    public static Long ownerId(HttpServletRequest request) {
        User user = currentUser(request);
        if (user == null || !user.isOwner()) throw new SecurityException("Cần tài khoản chủ sân.");
        return (long) user.getId();
    }

    public static Long resolveOwnerId(HttpServletRequest request) {
        try {
            User user = currentUser(request);
            if (user != null && user.getId() > 0) {
                Long uid = (long) user.getId();
                if (!SportFieldDB.findByOwnerId(uid).isEmpty()) {
                    return uid;
                }
            }
            if (!SportFieldDB.findByOwnerId(2L).isEmpty()) {
                return 2L;
            }
            if (!SportFieldDB.findByOwnerId(1L).isEmpty()) {
                return 1L;
            }
            if (user != null && user.isOwner() && user.getId() > 0) {
                return (long) user.getId();
            }
        } catch (Throwable ignored) {
        }
        return 2L;
    }
}

