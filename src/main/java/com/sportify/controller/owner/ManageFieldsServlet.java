package com.sportify.controller.owner;

import com.sportify.controller.BaseServlet;
import com.sportify.dao.SportFieldDAO;
import com.sportify.model.SportField;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * GET /owner/fields → owner/dashboard.jsp (bảng điều khiển của chủ sân).
 * <p>
 * Attributes gửi cho view: {@code fields}, {@code ownerId}.
 */
@WebServlet("/owner/fields")
public class ManageFieldsServlet extends BaseServlet {
    private final SportFieldDAO sportFieldDAO = new SportFieldDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long ownerId = currentUser(request).getId();
        List<SportField> fields = sportFieldDAO.findByOwnerId(ownerId);

        request.setAttribute("fields", fields);
        request.setAttribute("ownerId", ownerId);

        render(request, response, "owner/dashboard");
    }
}
