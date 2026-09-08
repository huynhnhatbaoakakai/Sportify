<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Dummy login process
    // Redirect to home.jsp after "successful" login
    response.sendRedirect(request.getContextPath() + "/home.jsp");
%>

