package com.sportify.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.Test;

import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertEquals;

public class BookingStatusServletTest {

    @Test
    public void rejectsMissingOrWrongCsrfTokenBeforeDatabaseAccess() throws Exception {
        for (String token : new String[]{null, "", "wrong-token"}) {
            Exchange exchange = new Exchange("1", "CONFIRMED", token);
            exchange.submit();
            assertEquals("/Sportify/owner/bookings?error=booking_csrf#booking-section", exchange.redirect);
        }
    }

    @Test
    public void rejectsInvalidBookingIdsWithValidCsrfToken() throws Exception {
        for (String id : new String[]{null, "", "0", "-1", "abc", "1 OR 1=1", "9223372036854775808"}) {
            Exchange exchange = new Exchange(id, "CONFIRMED", "test-token");
            exchange.submit();
            assertEquals("/Sportify/owner/bookings?error=booking_invalid#booking-section", exchange.redirect);
            assertEquals("UTF-8", exchange.requestEncoding);
            assertEquals("UTF-8", exchange.responseEncoding);
        }
    }

    @Test
    public void rejectsUnsupportedStatusAndInjectedStatus() throws Exception {
        for (String status : new String[]{null, "", "PENDING", "COMPLETED", "CANCELLED", "confirmed", "CONFIRMED' OR 1=1"}) {
            Exchange exchange = new Exchange("1", status, "test-token");
            exchange.submit();
            assertEquals("/Sportify/owner/bookings?error=booking_invalid#booking-section", exchange.redirect);
        }
    }

    private static final class Exchange {
        private final Map<String, String> parameters = new HashMap<String, String>();
        private String redirect;
        private String requestEncoding;
        private String responseEncoding;

        private Exchange(String id, String status, String token) {
            parameters.put("bookingId", id);
            parameters.put("status", status);
            parameters.put("csrfToken", token);
        }

        private void submit() throws Exception {
            HttpSession session = (HttpSession) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class<?>[]{HttpSession.class}, (proxy, method, args) -> {
                        if ("getAttribute".equals(method.getName())) return "test-token";
                        throw new AssertionError("Unexpected session call: " + method.getName());
                    });
            HttpServletRequest request = (HttpServletRequest) Proxy.newProxyInstance(
                    getClass().getClassLoader(), new Class<?>[]{HttpServletRequest.class},
                    (proxy, method, args) -> {
                        if ("getParameter".equals(method.getName())) return parameters.get(args[0]);
                        if ("getContextPath".equals(method.getName())) return "/Sportify";
                        if ("getSession".equals(method.getName())) return session;
                        if ("setCharacterEncoding".equals(method.getName())) {
                            requestEncoding = (String) args[0]; return null;
                        }
                        throw new AssertionError("Unexpected request call: " + method.getName());
                    });
            HttpServletResponse response = (HttpServletResponse) Proxy.newProxyInstance(
                    getClass().getClassLoader(), new Class<?>[]{HttpServletResponse.class},
                    (proxy, method, args) -> {
                        if ("sendRedirect".equals(method.getName())) { redirect = (String) args[0]; return null; }
                        if ("setCharacterEncoding".equals(method.getName())) { responseEncoding = (String) args[0]; return null; }
                        throw new AssertionError("Unexpected response call: " + method.getName());
                    });
            new UpdateBookingStatusServlet().doPost(request, response);
        }
    }
}
