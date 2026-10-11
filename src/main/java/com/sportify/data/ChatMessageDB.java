package com.sportify.data;

import com.sportify.model.ChatMessage;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;

import java.util.List;

public final class ChatMessageDB {

    private ChatMessageDB() {
    }

    public static void insert(ChatMessage message) {
        EntityManager em =
                DBUtil.getEntityManagerFactory().createEntityManager();

        EntityTransaction transaction = em.getTransaction();

        try {
            transaction.begin();

            em.persist(message);

            transaction.commit();
        } catch (RuntimeException exception) {
            if (transaction.isActive()) {
                transaction.rollback();
            }

            throw exception;
        } finally {
            em.close();
        }
    }

    public static List<ChatMessage> selectConversation(
            String sender,
            String receiver) {

        EntityManager em =
                DBUtil.getEntityManagerFactory().createEntityManager();

        String jpql =
                "SELECT message FROM ChatMessage message " +
                "WHERE (message.senderName = :sender " +
                "AND message.receiverName = :receiver) " +
                "OR (message.senderName = :receiver " +
                "AND message.receiverName = :sender) " +
                "ORDER BY message.sentAt ASC";

        try {
            TypedQuery<ChatMessage> query =
                    em.createQuery(jpql, ChatMessage.class);

            query.setParameter("sender", sender);
            query.setParameter("receiver", receiver);

            return query.getResultList();
        } finally {
            em.close();
        }
    }
}