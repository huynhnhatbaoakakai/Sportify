package com.sportify.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.Test;

import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

public class ReviewServletTest {

    @Test
    public void acceptsOnlySupportedStarFilters() {
        assertNull(ManageReviewsServlet.parseRating(null));
        assertNull(ManageReviewsServlet.parseRating(" "));
        for (int stars = 1; stars <= 5; stars++) {
            assertEquals(Integer.valueOf(stars),
                    ManageReviewsServlet.parseRating(" " + stars + " "));
        }
        for (String value : new String[]{"0", "6", "-1", "1.5", "01", "5 OR 1=1", "<script>"}) {
            assertNull(ManageReviewsServlet.parseRating(value));
        }
    }

    @Test
    public void rejectsInvalidReviewIdsBeforeDatabaseAccess() throws Exception {
        for (String id : new String[]{null, "", " ", "0", "-1", "abc", "1 OR 1=1", "9223372036854775808"}) {
            Exchange exchange = new Exchange(id, "Cảm ơn bạn!", "5");
            exchange.submit();
            assertEquals("/sportify/owner/reviews?error=invalid&rating=5", exchange.redirect);
            assertEquals("UTF-8", exchange.requestEncoding);
            assertEquals("UTF-8", exchange.responseEncoding);
        }
    }

    @Test
    public void rejectsEmptyRepliesAndPreservesValidFilter() throws Exception {
        for (String reply : new String[]{null, "", " \t\n\r "}) {
            Exchange exchange = new Exchange("1", reply, "3");
            exchange.submit();
            assertEquals("/sportify/owner/reviews?error=empty&rating=3", exchange.redirect);
        }
    }

    @Test
    public void rejectsOversizedRepliesAndDropsUntrustedFilter() throws Exception {
        char[] content = new char[2001];
        java.util.Arrays.fill(content, 'a');
        Exchange exchange = new Exchange("1", new String(content), "5&success=replied");
        exchange.submit();
        assertEquals("/sportify/owner/reviews?error=length", exchange.redirect);
    }

    private static final class Exchange {
        private final Map<String, String> parameters = new HashMap<String, String>();
        private String redirect;
        private String requestEncoding;
        private String responseEncoding;

        private Exchange(String reviewId, String ownerReply, String rating) {
            parameters.put("reviewId", reviewId);
            parameters.put("ownerReply", ownerReply);
            parameters.put("rating", rating);
        }

        private void submit() throws Exception {
            HttpServletRequest request = (HttpServletRequest) Proxy.newProxyInstance(
                    getClass().getClassLoader(), new Class<?>[]{HttpServletRequest.class},
                    (proxy, method, args) -> {
                        if ("getParameter".equals(method.getName())) return parameters.get(args[0]);
                        if ("getContextPath".equals(method.getName())) return "/sportify";
                        if ("setCharacterEncoding".equals(method.getName())) {
                            requestEncoding = (String) args[0];
                            return null;
                        }
                        throw new AssertionError("Unexpected request call: " + method.getName());
                    });
            HttpServletResponse response = (HttpServletResponse) Proxy.newProxyInstance(
                    getClass().getClassLoader(), new Class<?>[]{HttpServletResponse.class},
                    (proxy, method, args) -> {
                        if ("sendRedirect".equals(method.getName())) {
                            redirect = (String) args[0];
                            return null;
                        }
                        if ("setCharacterEncoding".equals(method.getName())) {
                            responseEncoding = (String) args[0];
                            return null;
                        }
                        throw new AssertionError("Unexpected response call: " + method.getName());
                    });
            new ReplyReviewServlet().doPost(request, response);
        }
    }
}
