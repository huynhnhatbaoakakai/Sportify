package com.sportify.model;

import java.util.ArrayList;
import java.util.List;

public class Post {
    private int id;
    private int userId;
    private String authorName;
    private String content;
    private String createdAt;
    private int likeCount;
    private boolean likedByMe;
    private List<PostComment> comments = new ArrayList<>();

    // Thông tin đính kèm lịch đặt sân đã xác nhận (nếu có)
    private Long bookingId;
    private String bookingCode;
    private String postPurpose;
    private String fieldName;
    private String sportType;
    private String fieldAddress;
    private Integer courtNumber;
    private Integer fieldQuantity;
    private String bookingDate;
    private String bookingTime;
    private String bookingPrice;
    private String bookingStatus;
    private Integer bookingOwnerId;
    private String bookingOwnerName;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getAuthorName() {
        return authorName;
    }

    public void setAuthorName(String authorName) {
        this.authorName = authorName;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public int getLikeCount() {
        return likeCount;
    }

    public void setLikeCount(int likeCount) {
        this.likeCount = likeCount;
    }

    public boolean isLikedByMe() {
        return likedByMe;
    }

    public void setLikedByMe(boolean likedByMe) {
        this.likedByMe = likedByMe;
    }

    public List<PostComment> getComments() {
        return comments;
    }

    public void setComments(List<PostComment> comments) {
        this.comments = comments;
    }

    public Long getBookingId() { return bookingId; }
    public void setBookingId(Long bookingId) { this.bookingId = bookingId; }

    public String getBookingCode() { return bookingCode; }
    public void setBookingCode(String bookingCode) { this.bookingCode = bookingCode; }

    public String getPostPurpose() { return postPurpose; }
    public void setPostPurpose(String postPurpose) { this.postPurpose = postPurpose; }

    public String getFieldName() { return fieldName; }
    public void setFieldName(String fieldName) { this.fieldName = fieldName; }

    public String getSportType() { return sportType; }
    public void setSportType(String sportType) { this.sportType = sportType; }

    public String getFieldAddress() { return fieldAddress; }
    public void setFieldAddress(String fieldAddress) { this.fieldAddress = fieldAddress; }

    public Integer getCourtNumber() { return courtNumber; }
    public void setCourtNumber(Integer courtNumber) { this.courtNumber = courtNumber; }

    public Integer getFieldQuantity() { return fieldQuantity; }
    public void setFieldQuantity(Integer fieldQuantity) { this.fieldQuantity = fieldQuantity; }

    public String getBookingDate() { return bookingDate; }
    public void setBookingDate(String bookingDate) { this.bookingDate = bookingDate; }

    public String getBookingTime() { return bookingTime; }
    public void setBookingTime(String bookingTime) { this.bookingTime = bookingTime; }

    public String getBookingPrice() { return bookingPrice; }
    public void setBookingPrice(String bookingPrice) { this.bookingPrice = bookingPrice; }

    public String getBookingStatus() { return bookingStatus; }
    public void setBookingStatus(String bookingStatus) { this.bookingStatus = bookingStatus; }

    public Integer getBookingOwnerId() { return bookingOwnerId; }
    public void setBookingOwnerId(Integer bookingOwnerId) { this.bookingOwnerId = bookingOwnerId; }

    public String getBookingOwnerName() { return bookingOwnerName; }
    public void setBookingOwnerName(String bookingOwnerName) { this.bookingOwnerName = bookingOwnerName; }
}
