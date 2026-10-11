package com.sportify.controller.owner;

import com.sportify.controller.BaseServlet;
import com.sportify.dao.SportFieldDAO;
import com.sportify.model.SportField;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * POST /owner/fields/create → thêm sân mới rồi quay về /owner/fields.
 */
@WebServlet("/owner/fields/create")
public class CreateFieldServlet extends BaseServlet {
    private final SportFieldDAO sportFieldDAO = new SportFieldDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            SportField field = new SportField();
            field.setOwnerId(currentUser(request).getId());
            field.setFieldName(request.getParameter("fieldName"));
            field.setSportType(request.getParameter("sportType"));
            field.setAddress(request.getParameter("address"));
            field.setPricePerHour(Double.parseDouble(request.getParameter("pricePerHour")));
            field.setOpenTime(request.getParameter("openTime"));
            field.setCloseTime(request.getParameter("closeTime"));

            // Check time validity roughly
            if (field.getOpenTime().compareTo(field.getCloseTime()) >= 0) {
                redirect(request, response, "/owner/fields?error=invalid_time#fields");
                return;
            }

            sportFieldDAO.insert(field);
            redirect(request, response, "/owner/fields?success=created#fields");

        } catch (Exception e) {
            e.printStackTrace();
            redirect(request, response, "/owner/fields?error=invalid#fields");
        }
    }
}
