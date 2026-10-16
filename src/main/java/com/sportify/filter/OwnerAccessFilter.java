package com.sportify.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter("/owner/*")
public class OwnerAccessFilter implements Filter {

    private static final String SESSION_ATTRIBUTE =
            "OWNER_DEMO_AUTHORIZED";

    private static final String ACCESS_PATH =
            "/owner/access";

    private static final String LOGOUT_PATH =
            "/owner/access/logout";

    @Override
    public void doFilter(
            ServletRequest servletRequest,
            ServletResponse servletResponse,
            FilterChain filterChain)
            throws IOException, ServletException {

        HttpServletRequest request =
                (HttpServletRequest) servletRequest;

        HttpServletResponse response =
                (HttpServletResponse) servletResponse;

        String path = request.getServletPath();

        if (ACCESS_PATH.equals(path)
                || LOGOUT_PATH.equals(path)) {

            filterChain.doFilter(request, response);
            return;
        }

        HttpSession session = request.getSession(false);

        if (session != null) {
            com.sportify.model.User user = (com.sportify.model.User) session.getAttribute("user");
            if (user != null && ("OWNER".equalsIgnoreCase(user.getRole()) || "ADMIN".equalsIgnoreCase(user.getRole()))) {
                filterChain.doFilter(request, response);
                return;
            }

            if (Boolean.TRUE.equals(session.getAttribute(SESSION_ATTRIBUTE))) {
                filterChain.doFilter(request, response);
                return;
            }
        }

        response.sendRedirect(
                request.getContextPath() + ACCESS_PATH
        );
    }
}
