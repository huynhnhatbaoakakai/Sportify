<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%!
    private static String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    String contextPath = request.getContextPath();
    String errorMessage =
            (String) request.getAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Truy cập khu vực quản lý sân Sportify">

    <title>Truy cập khu vực chủ sân - Sportify</title>

    <link rel="stylesheet"
          href="<%= contextPath %>/assets/css/owner-access.css">
</head>

<body>
<main class="owner-access-page">
    <section class="owner-access-card" aria-labelledby="owner-access-title">
        <a class="owner-access-logo"
           href="<%= contextPath %>/home.jsp"
           aria-label="Sportify - Trang chủ">
            <img src="<%= contextPath %>/assets/images/logo.jpeg"
                 alt="Sportify">
        </a>

        <div class="owner-access-heading">
            <span class="owner-access-kicker">KHU VỰC QUẢN LÝ</span>
            <h1 id="owner-access-title">Truy cập khu vực chủ sân</h1>
            <p>Nhập mật khẩu truy cập để quản lý thông tin và trạng thái các sân của bạn.</p>
        </div>

        <% if (errorMessage != null) { %>
        <p class="owner-access-error" role="alert">
            <%= escapeHtml(errorMessage) %>
        </p>
        <% } %>

        <form class="owner-access-form"
              method="post"
              action="<%= contextPath %>/owner/access">
            <label for="owner-password">Mật khẩu truy cập</label>
            <input id="owner-password"
                   name="password"
                   type="password"
                   required
                   autocomplete="current-password"
                   autofocus>

            <button type="submit">Vào Dashboard</button>
        </form>

        <a class="owner-access-back" href="<%= contextPath %>/home.jsp">
            Quay về trang chủ
        </a>
    </section>
</main>
</body>
</html>
