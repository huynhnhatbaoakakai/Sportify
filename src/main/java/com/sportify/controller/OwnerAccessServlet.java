package com.sportify.controller;

import com.sportify.util.OwnerAccess;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/owner/access")
public class OwnerAccessServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        if (OwnerAccess.currentUser(request) == null) {
            response.sendRedirect(request.getContextPath() + "/login");
        } else if (OwnerAccess.currentUser(request).isOwner()) {
            response.sendRedirect(request.getContextPath() + "/owner/fields");
        } else {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.setAttribute("errorMessage", "Bạn cần đăng nhập bằng tài khoản có quyền chủ sân.");
            request.getRequestDispatcher("/WEB-INF/views/owner-access.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Vui lòng đăng nhập bằng tài khoản chủ sân.");
    }
}
