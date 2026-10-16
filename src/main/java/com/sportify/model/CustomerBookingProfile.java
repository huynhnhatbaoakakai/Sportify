package com.sportify.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Hồ sơ khách hàng đã đặt sân dành cho chủ sân.
 * Lưu trữ tên của người đã thật sự đặt lịch, số điện thoại, tài khoản (nếu có),
 * tổng số đơn, chi tiêu và toàn bộ lịch sử các lần đặt lịch.
 */
public class CustomerBookingProfile implements Serializable {

    private static final long serialVersionUID = 1L;

    private String customerKey;
    private String customerName;
    private String customerPhone;
    private Integer customerId;
    private String accountName;
    private String email;

    private int totalBookings = 0;
    private int pendingBookings = 0;
    private int confirmedBookings = 0;
    private int completedBookings = 0;
    private int rejectedBookings = 0;
    private int cancelledBookings = 0;
    private BigDecimal totalSpent = BigDecimal.ZERO;

    private LocalDateTime firstBookingAt;
    private LocalDateTime lastBookingAt;
    private String lastFieldName;
    private String lastBookingStatus;

    private List<Booking> bookingHistory = new ArrayList<>();

    public CustomerBookingProfile() {
    }

    public void addBooking(Booking booking) {
        if (booking == null) return;
        this.bookingHistory.add(booking);
        this.totalBookings++;

        if (booking.getTotalPrice() != null) {
            this.totalSpent = this.totalSpent.add(booking.getTotalPrice());
        }

        String status = booking.getStatus() != null ? booking.getStatus().toUpperCase() : "";
        switch (status) {
            case "PENDING":
                this.pendingBookings++;
                break;
            case "CONFIRMED":
                this.confirmedBookings++;
                break;
            case "COMPLETED":
                this.completedBookings++;
                break;
            case "REJECTED":
                this.rejectedBookings++;
                break;
            case "CANCELLED":
                this.cancelledBookings++;
                break;
            default:
                break;
        }

        LocalDateTime bookingTime = booking.getStartsAt() != null ? booking.getStartsAt() : booking.getCreatedAt();
        if (bookingTime != null) {
            if (this.firstBookingAt == null || bookingTime.isBefore(this.firstBookingAt)) {
                this.firstBookingAt = bookingTime;
            }
            if (this.lastBookingAt == null || bookingTime.isAfter(this.lastBookingAt)) {
                this.lastBookingAt = bookingTime;
                if (booking.getField() != null) {
                    this.lastFieldName = booking.getField().getFieldName();
                }
                this.lastBookingStatus = booking.getStatus();
            }
        }
    }

    public String getCustomerKey() {
        return customerKey;
    }

    public void setCustomerKey(String customerKey) {
        this.customerKey = customerKey;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
    }

    public String getAccountName() {
        return accountName;
    }

    public void setAccountName(String accountName) {
        this.accountName = accountName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public int getTotalBookings() {
        return totalBookings;
    }

    public void setTotalBookings(int totalBookings) {
        this.totalBookings = totalBookings;
    }

    public int getPendingBookings() {
        return pendingBookings;
    }

    public void setPendingBookings(int pendingBookings) {
        this.pendingBookings = pendingBookings;
    }

    public int getConfirmedBookings() {
        return confirmedBookings;
    }

    public void setConfirmedBookings(int confirmedBookings) {
        this.confirmedBookings = confirmedBookings;
    }

    public int getCompletedBookings() {
        return completedBookings;
    }

    public void setCompletedBookings(int completedBookings) {
        this.completedBookings = completedBookings;
    }

    public int getRejectedBookings() {
        return rejectedBookings;
    }

    public void setRejectedBookings(int rejectedBookings) {
        this.rejectedBookings = rejectedBookings;
    }

    public int getCancelledBookings() {
        return cancelledBookings;
    }

    public void setCancelledBookings(int cancelledBookings) {
        this.cancelledBookings = cancelledBookings;
    }

    public BigDecimal getTotalSpent() {
        return totalSpent;
    }

    public void setTotalSpent(BigDecimal totalSpent) {
        this.totalSpent = totalSpent;
    }

    public LocalDateTime getFirstBookingAt() {
        return firstBookingAt;
    }

    public void setFirstBookingAt(LocalDateTime firstBookingAt) {
        this.firstBookingAt = firstBookingAt;
    }

    public LocalDateTime getLastBookingAt() {
        return lastBookingAt;
    }

    public void setLastBookingAt(LocalDateTime lastBookingAt) {
        this.lastBookingAt = lastBookingAt;
    }

    public String getLastFieldName() {
        return lastFieldName;
    }

    public void setLastFieldName(String lastFieldName) {
        this.lastFieldName = lastFieldName;
    }

    public String getLastBookingStatus() {
        return lastBookingStatus;
    }

    public void setLastBookingStatus(String lastBookingStatus) {
        this.lastBookingStatus = lastBookingStatus;
    }

    public List<Booking> getBookingHistory() {
        return bookingHistory;
    }

    public void setBookingHistory(List<Booking> bookingHistory) {
        this.bookingHistory = bookingHistory;
    }

    public boolean isRegistered() {
        return customerId != null && customerId > 0;
    }

    public boolean isFrequentCustomer() {
        return totalBookings >= 2;
    }
}

