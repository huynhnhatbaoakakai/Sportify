package com.sportify.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.UUID;

public final class Csrf {
    public static final String SESSION_KEY = "SPORTIFY_CSRF_TOKEN";
    private Csrf() { }

    public static String token(HttpServletRequest request) {
        HttpSession session = request.getSession();
        synchronized (session) {
            String token = (String) session.getAttribute(SESSION_KEY);
            if (token == null) {
                token = UUID.randomUUID().toString();
                session.setAttribute(SESSION_KEY, token);
            }
            return token;
        }
    }

    public static boolean isValid(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        String expected = session == null ? null : (String) session.getAttribute(SESSION_KEY);
        String supplied = request.getParameter("csrfToken");
        return expected != null && supplied != null && MessageDigest.isEqual(
                expected.getBytes(StandardCharsets.UTF_8), supplied.getBytes(StandardCharsets.UTF_8));
    }
}
