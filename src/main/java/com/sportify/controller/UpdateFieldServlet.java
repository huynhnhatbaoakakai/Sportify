package com.sportify.controller;

import com.sportify.data.SportFieldDB;
import com.sportify.model.SportField;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.Set;

@WebServlet("/owner/fields/update")
public class UpdateFieldServlet extends HttpServlet {


    private static final Set<String> VALID_TYPES = Set.of(
            "GYM",
            "BASKETBALL",
            "SWIMMING",
            "PICKLEBALL",
            "TABLE_TENNIS"
    );

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            Long fieldId = Long.valueOf(
                    required(request.getParameter("fieldId"))
            );

            Long ownerId = com.sportify.util.OwnerAccess.resolveOwnerId(request);

            SportField field =
                    SportFieldDB.findByIdAndOwnerId(
                            fieldId,
                            ownerId
                    );

            if (field == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Không tìm thấy sân."
                );
                return;
            }

            String fieldName =
                    required(request.getParameter("fieldName"));

            String sportType =
                    required(request.getParameter("sportType"));

            String address =
                    required(request.getParameter("address"));

            BigDecimal price = new BigDecimal(
                    required(request.getParameter("pricePerHour"))
            );

            LocalTime openTime = LocalTime.parse(
                    required(request.getParameter("openTime"))
            );

            LocalTime closeTime = LocalTime.parse(
                    required(request.getParameter("closeTime"))
            );

            String status = request.getParameter("status");

            int quantity = field.getQuantity();
            String quantityParam = request.getParameter("quantity");
            if (quantityParam != null && !quantityParam.trim().isEmpty()) {
                quantity = Integer.parseInt(quantityParam.trim());
                if (quantity <= 0) {
                    throw new IllegalArgumentException();
                }
            }

            if (!VALID_TYPES.contains(sportType)) {
                throw new IllegalArgumentException();
            }

            if (price.compareTo(BigDecimal.ZERO) <= 0) {
                throw new IllegalArgumentException();
            }

            if (!closeTime.isAfter(openTime)) {
                throw new IllegalArgumentException();
            }

            if (!"INACTIVE".equals(status)) {
                status = "ACTIVE";
            }

            field.setFieldName(fieldName);
            field.setSportType(sportType);
            field.setAddress(address);
            field.setPricePerHour(price);
            field.setOpenTime(openTime);
            field.setCloseTime(closeTime);
            field.setStatus(status);
            field.setQuantity(quantity);

            SportFieldDB.update(field, ownerId);

            response.sendRedirect(
                    request.getContextPath()
                            + "/owner/fields?success=updated#fields"
            );

        } catch (IllegalArgumentException exception) {
            response.sendRedirect(
                    request.getContextPath()
                            + "/owner/fields?error=invalid#fields"
            );

        } catch (Exception exception) {
            throw new ServletException(
                    "Không thể cập nhật sân.",
                    exception
            );
        }
    }

    private String required(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException();
        }

        return value.trim();
    }
}
