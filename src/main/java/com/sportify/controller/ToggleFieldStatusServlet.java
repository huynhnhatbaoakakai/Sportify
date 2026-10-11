package com.sportify.controller;

import com.sportify.data.SportFieldDB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/owner/fields/toggle")
public class ToggleFieldStatusServlet extends HttpServlet {

    private static final Long DEMO_OWNER_ID = 1L;

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            String fieldIdValue = request.getParameter("fieldId");

            if (fieldIdValue == null || fieldIdValue.isBlank()) {
                throw new IllegalArgumentException(
                        "Thiếu mã sân."
                );
            }

            Long fieldId = Long.valueOf(fieldIdValue);

            SportFieldDB.toggleStatus(
                    fieldId,
                    DEMO_OWNER_ID
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/owner/fields?success=toggled#fields"
            );

        } catch (IllegalArgumentException exception) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Mã sân không hợp lệ."
            );

        } catch (Exception exception) {
            throw new ServletException(
                    "Không thể thay đổi trạng thái sân.",
                    exception
            );
        }
    }
}