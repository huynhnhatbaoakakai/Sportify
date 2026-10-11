package com.sportify.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/owner/access")
public class OwnerAccessServlet extends HttpServlet {

    private static final String DEMO_PASSWORD =
            "123";

    private static final String SESSION_ATTRIBUTE =
            "OWNER_DEMO_AUTHORIZED";

    private static final String ACCESS_VIEW =
            "/WEB-INF/views/owner-access.jsp";

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session != null
                && Boolean.TRUE.equals(
                session.getAttribute(SESSION_ATTRIBUTE))) {

            response.sendRedirect(
                    request.getContextPath() + "/owner/fields"
            );
            return;
        }

        request.getRequestDispatcher(ACCESS_VIEW)
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String password = request.getParameter("password");

        if (DEMO_PASSWORD.equals(password)) {
            HttpSession session = request.getSession();
            session.setAttribute(
                    SESSION_ATTRIBUTE,
                    Boolean.TRUE
            );

            response.sendRedirect(
                    request.getContextPath() + "/owner/fields"
            );
            return;
        }

        request.setAttribute(
                "errorMessage",
                "Mật khẩu không đúng. Vui lòng thử lại."
        );

        request.getRequestDispatcher(ACCESS_VIEW)
                .forward(request, response);
    }
}
