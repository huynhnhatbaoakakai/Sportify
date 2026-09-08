<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Dummy register process
    // Redirect to login.jsp after "successful" registration
    response.sendRedirect(request.getContextPath() + "/login.jsp?registered=true");
%>

