package com.sportify.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;

import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "chat_messages")
public class ChatMessage implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "message_id")
    private Long messageId;

    @Column(name = "sender_name", nullable = false, length = 100, columnDefinition = "nvarchar(100)")
    private String senderName;

    @Column(name = "receiver_name", nullable = false, length = 100, columnDefinition = "nvarchar(100)")
    private String receiverName;

    @Column(name = "message_text", nullable = false, length = 1000, columnDefinition = "nvarchar(1000)")
    private String messageText;

    @Column(name = "sent_at", nullable = false)
    private LocalDateTime sentAt = LocalDateTime.now();

    // Fields for ChatDAO session-based chat
    @Transient
    private Integer id;

    @Transient
    private Integer sessionId;

    @Transient
    private String sender;

    @Transient
    private String text;

    @Transient
    private String time;

    public ChatMessage() {
    }

    public ChatMessage(String senderName, String receiverName, String messageText) {
        this.senderName = senderName;
        this.receiverName = receiverName;
        this.messageText = messageText;
    }

    public Long getMessageId() {
        return messageId;
    }

    public void setMessageId(Long messageId) {
        this.messageId = messageId;
    }

    public String getSenderName() {
        return senderName != null ? senderName : sender;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public String getReceiverName() {
        return receiverName;
    }

    public void setReceiverName(String receiverName) {
        this.receiverName = receiverName;
    }

    public String getMessageText() {
        return messageText != null ? messageText : text;
    }

    public void setMessageText(String messageText) {
        this.messageText = messageText;
    }

    public LocalDateTime getSentAt() {
        return sentAt;
    }

    public void setSentAt(LocalDateTime sentAt) {
        this.sentAt = sentAt;
    }

    // Getters and setters for ChatDAO
    public Integer getId() {
        return id != null ? id : (messageId != null ? messageId.intValue() : null);
    }

    public void setId(int id) {
        this.id = id;
    }

    public Integer getSessionId() {
        return sessionId;
    }

    public void setSessionId(int sessionId) {
        this.sessionId = sessionId;
    }

    public String getSender() {
        return sender != null ? sender : senderName;
    }

    public void setSender(String sender) {
        this.sender = sender;
    }

    public String getText() {
        return text != null ? text : messageText;
    }

    public void setText(String text) {
        this.text = text;
    }

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }
}
