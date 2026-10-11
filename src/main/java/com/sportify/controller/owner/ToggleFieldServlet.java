package com.sportify.controller.owner;

import com.sportify.controller.BaseServlet;
import com.sportify.dao.SportFieldDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * POST /owner/fields/toggle (fieldId) → bật/tắt trạng thái sân. Gọi bằng JS, chỉ trả status code.
 */
@WebServlet("/owner/fields/toggle")
public class ToggleFieldServlet extends BaseServlet {
    private final SportFieldDAO sportFieldDAO = new SportFieldDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        try {
            long fieldId = Long.parseLong(request.getParameter("fieldId"));
            boolean success = sportFieldDAO.toggleStatus(fieldId, currentUser(request).getId());

            if (success) {
                response.setStatus(HttpServletResponse.SC_OK);
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
