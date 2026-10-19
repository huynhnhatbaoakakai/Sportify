package com.sportify.controller;

import com.sportify.data.AvailabilityDB;
import com.sportify.data.FieldBlockDB;
import com.sportify.data.SportFieldDB;
import com.sportify.model.SportField;
import com.sportify.util.OwnerAccess;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;

@WebServlet({"/owner/calendar", "/owner/blocks/create", "/owner/blocks/delete", "/owner/fields/approval"})
public class OwnerCalendarServlet extends BaseServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!"/owner/calendar".equals(request.getServletPath())) { response.sendError(405); return; }
        Long ownerId = OwnerAccess.ownerId(request);
        List<SportField> fields = SportFieldDB.findByOwnerId(ownerId);
        request.setAttribute("fields", fields);
        LocalDate date = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        Long fieldId = fields.isEmpty() ? null : fields.get(0).getFieldId();
        try {
            if (request.getParameter("date") != null) date = LocalDate.parse(request.getParameter("date"));
            if (request.getParameter("fieldId") != null) fieldId = Long.valueOf(request.getParameter("fieldId"));
        } catch (RuntimeException exception) { response.sendError(400, "Sân hoặc ngày không hợp lệ."); return; }
        SportField selected = fieldId == null ? null : SportFieldDB.findByIdAndOwnerId(fieldId, ownerId);
        if (fieldId != null && selected == null) { response.sendError(404, "Không tìm thấy sân của bạn."); return; }
        request.setAttribute("selectedField", selected);
        request.setAttribute("selectedDate", date);
        if (selected != null) {
            request.setAttribute("availability", AvailabilityDB.getDay(fieldId, date));
            request.setAttribute("blocks", FieldBlockDB.findForDay(fieldId, ownerId, date));
            request.setAttribute("calendarBookings", AvailabilityDB.ownerBookings(fieldId, ownerId, date));
        }
        request.setAttribute("calendarMessage", request.getSession().getAttribute("calendarMessage"));
        request.getSession().removeAttribute("calendarMessage");
        render(request, response, "owner/calendar");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Long ownerId = OwnerAccess.ownerId(request);
        Long fieldId;
        LocalDate date;
        try {
            fieldId = Long.valueOf(request.getParameter("fieldId"));
            String dateValue = request.getParameter("date");
            date = dateValue == null || dateValue.isBlank() ? LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")) : LocalDate.parse(dateValue);
            if (SportFieldDB.findByIdAndOwnerId(fieldId, ownerId) == null) { response.sendError(404, "Không tìm thấy sân của bạn."); return; }
            String message;
            switch (request.getServletPath()) {
                case "/owner/fields/approval" -> {
                    String enabled = request.getParameter("enabled");
                    if (!"true".equals(enabled) && !"false".equals(enabled)) throw new IllegalArgumentException("Chế độ không hợp lệ.");
                    boolean updated = SportFieldDB.setAutoApproval(fieldId, ownerId, Boolean.parseBoolean(enabled));
                    message = updated ? ("true".equals(enabled) ? "Đã bật tự xác nhận cho đơn mới. Đơn cũ vẫn xử lý thủ công." : "Đã chuyển sang duyệt thủ công.") : "Không tìm thấy sân.";
                }
                case "/owner/blocks/create" -> {
                    LocalDateTime start = LocalDateTime.parse(request.getParameter("startsAt"));
                    LocalDateTime end = LocalDateTime.parse(request.getParameter("endsAt"));
                    FieldBlockDB.Outcome result = FieldBlockDB.create(fieldId, ownerId, start, end, request.getParameter("reason"));
                    message = switch (result.result()) {
                        case CREATED -> "Đã khóa khoảng giờ. Khách sẽ không đặt được vào khoảng này.";
                        case BOOKING_CONFLICT -> "Chưa khóa giờ vì đã có đơn được xác nhận: " + String.join(", ", result.affectedBookingCodes()) + ". Vui lòng xử lý các đơn này trước.";
                        case BLOCK_CONFLICT -> "Khoảng giờ này trùng với một lịch khóa đã có.";
                        case INVALID_TIME -> "Khoảng giờ không hợp lệ hoặc đã kết thúc.";
                        default -> "Không tìm thấy sân của bạn.";
                    };
                }
                case "/owner/blocks/delete" -> {
                    Long blockId = Long.valueOf(request.getParameter("blockId"));
                    // Bind the block to the selected field as well as the authenticated owner.
                    boolean belongs = FieldBlockDB.findForDay(fieldId, ownerId, date).stream().anyMatch(block -> block.getBlockId().equals(blockId));
                    message = belongs && FieldBlockDB.remove(blockId, ownerId) ? "Đã mở lại khoảng giờ." : "Không tìm thấy lịch khóa.";
                }
                default -> { response.sendError(405); return; }
            }
            request.getSession().setAttribute("calendarMessage", message);
            redirect(request, response, "/owner/calendar?fieldId=" + fieldId + "&date=" + date);
        } catch (IllegalArgumentException | java.time.DateTimeException | NullPointerException exception) {
            request.getSession().setAttribute("calendarMessage", exception.getMessage() != null && exception.getMessage().startsWith("Tự xác nhận") ? exception.getMessage() : "Thông tin chưa hợp lệ. Hãy kiểm tra sân, ngày giờ và lý do.");
            redirect(request, response, "/owner/calendar");
        }
    }
}
