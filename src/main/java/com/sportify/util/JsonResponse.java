package com.sportify.util;

import com.google.gson.Gson;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Collections;

/**
 * Helper ghi JSON ra response, dùng chung cho các API servlet.
 */
public final class JsonResponse {

    private static final Gson GSON = new Gson();

    private JsonResponse() {
    }

    /** Ghi đối tượng {@code body} dưới dạng JSON với status 200. */
    public static void ok(HttpServletResponse resp, Object body) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().print(GSON.toJson(body));
    }

    /** Trả về {@code {"status":"success"}}. */
    public static void success(HttpServletResponse resp) throws IOException {
        ok(resp, Collections.singletonMap("status", "success"));
    }

    /** Trả về {@code {"error": message}} với status HTTP tương ứng. */
    public static void error(HttpServletResponse resp, int status, String message) throws IOException {
        resp.setStatus(status);
        ok(resp, Collections.singletonMap("error", message != null ? message : "Server error"));
    }
}

