package com.sportify;

import com.google.gson.Gson;
import com.sportify.service.ChatService;

/**
 * Chạy thử thủ công (cần SQL Server đang chạy): in danh sách hội thoại bạn bè của user id=1 dạng JSON.
 */
public class TestChat {
    public static void main(String[] args) {
        try {
            // Assume logged in user is ID=1 for test
            ChatService chatService = new ChatService();
            System.out.println(new Gson().toJson(chatService.getFriendConversations(1)));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
