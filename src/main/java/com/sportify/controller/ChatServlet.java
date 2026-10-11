package com.sportify.controller;

import com.sportify.data.ChatMessageDB;
import com.sportify.model.ChatMessage;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet("/chat")
public class ChatServlet extends HttpServlet {
private static final String DEFAULT_SENDER = "Khách hàng";
private static final String DEFAULT_RECEIVER = "Sân bóng Sunrise";

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String sender = getValueOrDefault(
                request.getParameter("sender"),
                DEFAULT_SENDER);

        String receiver = getValueOrDefault(
                request.getParameter("receiver"),
                DEFAULT_RECEIVER);

        List<ChatMessage> messages =
                ChatMessageDB.selectConversation(sender, receiver);

        request.setAttribute("sender", sender);
        request.setAttribute("receiver", receiver);
        request.setAttribute("messages", messages);

        request.getRequestDispatcher("/chat.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        request.setCharacterEncoding("UTF-8");

        String sender = getValueOrDefault(
                request.getParameter("senderName"),
                DEFAULT_SENDER);

        String receiver = getValueOrDefault(
                request.getParameter("receiverName"),
                DEFAULT_RECEIVER);

        String messageText = request.getParameter("messageText");

      if (messageText != null && !messageText.trim().isEmpty()) {
            ChatMessage message = new ChatMessage(
                    sender,
                    receiver,
                    messageText.trim());

            ChatMessageDB.insert(message);
        }

     String encodedSender = URLEncoder.encode(
        sender,
        StandardCharsets.UTF_8.name());
String encodedReceiver = URLEncoder.encode(
        receiver,
        StandardCharsets.UTF_8.name());

        response.sendRedirect(
                request.getContextPath()
                        + "/chat?sender=" + encodedSender
                        + "&receiver=" + encodedReceiver);
    }

    private String getValueOrDefault(
            String value,
            String defaultValue) {

        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }

        return value.trim();
    }
}