package com.sportify.controller;

import com.sportify.data.NotificationDB;
import com.sportify.model.User;
import com.sportify.util.Csrf;
import com.sportify.util.JsonResponse;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

@WebServlet({"/notifications", "/notifications-api"})
public class NotificationServlet extends BaseServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        User user = currentUser(request);
        response.setHeader("Cache-Control", "no-store");
        if ("/notifications-api".equals(request.getServletPath())) {
            Map<String, Object> body = new LinkedHashMap<>();
            body.put("unreadCount", NotificationDB.countUnread(user.getId()));
            JsonResponse.ok(response, body);
        } else {
            request.setAttribute("notifications", NotificationDB.findByUser(user.getId()));
            render(request, response, "user/notifications");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!Csrf.isValid(request)) {
            response.sendError(403, "Biểu mẫu đã hết hiệu lực. Vui lòng tải lại trang."); return;
        }
        try {
            String id = request.getParameter("notificationId");
            Long notificationId = id == null || id.isBlank() ? null : Long.valueOf(id);
            if (notificationId != null && notificationId <= 0) throw new IllegalArgumentException();
            NotificationDB.markRead(currentUser(request).getId(), notificationId);
            redirect(request, response, "/notifications");
        } catch (IllegalArgumentException exception) { response.sendError(400, "Thông báo không hợp lệ."); }
    }
}
