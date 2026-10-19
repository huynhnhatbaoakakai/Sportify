package com.sportify.controller;

import com.sportify.filter.OwnerAccessFilter;
import com.sportify.model.User;
import com.sportify.util.Csrf;
import com.sportify.util.OwnerAccess;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.Test;
import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.Map;
import static org.junit.Assert.*;

public class OwnerAuthorizationTest {
    @Test public void oldDemoFlagDoesNotGrantOwnerRights() throws Exception {
        Exchange exchange = new Exchange("USER", "GET", null);
        exchange.session.put("OWNER_DEMO_AUTHORIZED", true);
        exchange.run(); assertFalse(exchange.allowed); assertTrue(exchange.forwarded); assertEquals(403, exchange.status);
    }
    @Test public void anonymousUserIsSentToLogin() throws Exception {
        Exchange exchange = new Exchange(null, "GET", null);
        exchange.run(); assertFalse(exchange.allowed); assertEquals("/sportify/login", exchange.redirect);
    }
    @Test public void ownerGetUsesTheirOwnIdAndReceivesCsrfToken() throws Exception {
        Exchange exchange = new Exchange("OWNER", "GET", null);
        exchange.run(); assertTrue(exchange.allowed); assertEquals(Long.valueOf(7), OwnerAccess.ownerId(exchange.request));
        assertEquals("valid-token", exchange.attributes.get("csrfToken"));
    }
    @Test public void ownerPostsRequireMatchingCsrfToken() throws Exception {
        for (String token : new String[]{null, "wrong"}) {
            Exchange exchange = new Exchange("OWNER", "POST", token); exchange.run();
            assertFalse(exchange.allowed); assertEquals(403, exchange.status);
        }
        Exchange valid = new Exchange("OWNER", "POST", "valid-token"); valid.run(); assertTrue(valid.allowed);
    }

    private static final class Exchange {
        final Map<String, Object> session = new HashMap<>();
        final Map<String, Object> attributes = new HashMap<>();
        final HttpServletRequest request;
        final HttpServletResponse response;
        boolean allowed, forwarded;
        int status;
        String redirect;

        Exchange(String role, String method, String token) {
            if (role != null) { User user = new User(7, "Owner", "owner@example.invalid", null); user.setRole(role); session.put("user", user); }
            session.put(Csrf.SESSION_KEY, "valid-token");
            HttpSession httpSession = (HttpSession) Proxy.newProxyInstance(getClass().getClassLoader(), new Class<?>[]{HttpSession.class}, (proxy, operation, args) -> {
                if (operation.getName().equals("getAttribute")) return session.get(args[0]);
                if (operation.getName().equals("setAttribute")) { session.put((String) args[0], args[1]); return null; }
                throw new AssertionError(operation.getName());
            });
            request = (HttpServletRequest) Proxy.newProxyInstance(getClass().getClassLoader(), new Class<?>[]{HttpServletRequest.class}, (proxy, operation, args) -> {
                return switch (operation.getName()) {
                    case "getSession" -> role == null ? null : httpSession;
                    case "getContextPath" -> "/sportify";
                    case "getMethod" -> method;
                    case "getParameter" -> "csrfToken".equals(args[0]) ? token : "999";
                    case "setAttribute" -> { attributes.put((String) args[0], args[1]); yield null; }
                    case "getRequestDispatcher" -> Proxy.newProxyInstance(getClass().getClassLoader(), new Class<?>[]{RequestDispatcher.class}, (dispatcher, action, params) -> { forwarded = true; return null; });
                    default -> throw new AssertionError(operation.getName());
                };
            });
            response = (HttpServletResponse) Proxy.newProxyInstance(getClass().getClassLoader(), new Class<?>[]{HttpServletResponse.class}, (proxy, operation, args) -> {
                switch (operation.getName()) {
                    case "setStatus", "sendError" -> status = (Integer) args[0];
                    case "sendRedirect" -> redirect = (String) args[0];
                    default -> throw new AssertionError(operation.getName());
                }
                return null;
            });
        }
        void run() throws Exception { new OwnerAccessFilter().doFilter(request, response, (request, response) -> allowed = true); }
    }
}
