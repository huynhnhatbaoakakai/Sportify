package com.sportify.controller.booking;

import com.sportify.data.AvailabilityDB;
import com.sportify.util.JsonResponse;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/availability-api")
public class AvailabilityApiServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setHeader("Cache-Control", "no-store");
        try {
            Long fieldId = Long.valueOf(request.getParameter("fieldId"));
            LocalDate date = LocalDate.parse(request.getParameter("date"));
            AvailabilityDB.Day day = AvailabilityDB.getDay(fieldId, date);
            if (day == null) JsonResponse.error(response, 404, "Không tìm thấy sân.");
            else JsonResponse.ok(response, day);
        } catch (IllegalArgumentException | java.time.DateTimeException | NullPointerException exception) {
            JsonResponse.error(response, 400, "Sân hoặc ngày không hợp lệ.");
        } catch (RuntimeException exception) {
            getServletContext().log("Không thể tải lịch trống.", exception);
            JsonResponse.error(response, 503, "Không thể tải lịch trống. Vui lòng thử lại.");
        }
    }
}
