package com.sportify.controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/owner/access/logout")
public class OwnerAccessLogoutServlet extends HttpServlet {

    private static final String SESSION_ATTRIBUTE =
            "OWNER_DEMO_AUTHORIZED";

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session != null) {
            session.removeAttribute(SESSION_ATTRIBUTE);
        }

        response.sendRedirect(
                request.getContextPath() + "/home.jsp"
        );
    }
}
