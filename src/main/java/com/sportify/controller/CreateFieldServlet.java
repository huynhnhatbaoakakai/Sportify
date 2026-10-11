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

@WebServlet("/owner/fields/create")
public class CreateFieldServlet extends HttpServlet {

    private static final Long DEMO_OWNER_ID = 1L;

    private static final Set<String> VALID_SPORT_TYPES = Set.of(
            "GYM",
            "BASKETBALL",
            "SWIMMING",
            "PICKLEBALL"
    );

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            String fieldName = required(
                    request.getParameter("fieldName"),
                    "Tên sân"
            );

            String sportType = required(
                    request.getParameter("sportType"),
                    "Môn thể thao"
            );

            String address = required(
                    request.getParameter("address"),
                    "Địa chỉ"
            );

            BigDecimal pricePerHour = new BigDecimal(
                    required(
                            request.getParameter("pricePerHour"),
                            "Giá thuê"
                    )
            );

            LocalTime openTime = LocalTime.parse(
                    required(
                            request.getParameter("openTime"),
                            "Giờ mở cửa"
                    )
            );

            LocalTime closeTime = LocalTime.parse(
                    required(
                            request.getParameter("closeTime"),
                            "Giờ đóng cửa"
                    )
            );

            String status = request.getParameter("status");

            if (!"INACTIVE".equals(status)) {
                status = "ACTIVE";
            }

            if (!VALID_SPORT_TYPES.contains(sportType)) {
                throw new IllegalArgumentException(
                        "Môn thể thao không hợp lệ."
                );
            }

            if (pricePerHour.compareTo(BigDecimal.ZERO) <= 0) {
                throw new IllegalArgumentException(
                        "Giá thuê phải lớn hơn 0."
                );
            }

            if (!closeTime.isAfter(openTime)) {
                throw new IllegalArgumentException(
                        "Giờ đóng cửa phải sau giờ mở cửa."
                );
            }

            SportField field = new SportField();

            field.setOwnerId(DEMO_OWNER_ID);
            field.setFieldName(fieldName);
            field.setSportType(sportType);
            field.setAddress(address);
            field.setPricePerHour(pricePerHour);
            field.setOpenTime(openTime);
            field.setCloseTime(closeTime);
            field.setStatus(status);

            SportFieldDB.insert(field);

            response.sendRedirect(
                    request.getContextPath()
                            + "/owner/fields?success=created#fields"
            );

        } catch (IllegalArgumentException exception) {
            response.sendRedirect(
                    request.getContextPath()
                            + "/owner/fields?error=invalid#fields"
            );

        } catch (Exception exception) {
            throw new ServletException(
                    "Không thể thêm sân vào database.",
                    exception
            );
        }
    }

    private String required(String value, String fieldLabel) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(
                    fieldLabel + " không được để trống."
            );
        }

        return value.trim();
    }
}