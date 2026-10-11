package com.sportify.controller.newsfeed;

import com.sportify.controller.BaseServlet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * GET /newsfeed → user/newsfeed.jsp. Bài viết được tải bằng JS qua {@link NewsfeedApiServlet}.
 */
@WebServlet("/newsfeed")
public class NewsfeedPageServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        render(req, resp, "user/newsfeed");
    }
}

