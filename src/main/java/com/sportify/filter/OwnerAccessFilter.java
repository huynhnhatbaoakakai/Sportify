package com.sportify.filter;

import com.sportify.model.User;
import com.sportify.util.Csrf;
import com.sportify.util.OwnerAccess;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebFilter("/owner/*")
public class OwnerAccessFilter implements Filter {
    @Override
    public void doFilter(ServletRequest source, ServletResponse target, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) source;
        HttpServletResponse response = (HttpServletResponse) target;
        User user = OwnerAccess.currentUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!user.isOwner()) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.setAttribute("errorMessage", "Tài khoản này chưa có quyền chủ sân. Hãy đăng nhập bằng tài khoản chủ sân của bạn.");
            request.getRequestDispatcher("/WEB-INF/views/owner-access.jsp").forward(request, response);
            return;
        }
        if ("POST".equals(request.getMethod()) && !Csrf.isValid(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Biểu mẫu đã hết hiệu lực. Vui lòng tải lại trang.");
            return;
        }
        request.setAttribute("csrfToken", Csrf.token(request));
        chain.doFilter(request, response);
    }
}
