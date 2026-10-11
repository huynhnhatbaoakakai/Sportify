package com.sportify.model;

import java.time.LocalDateTime;

/** Read-only summary of customer names from reviews; this is not a user account. */
public final class CustomerOverview {

    private final String customerName;
    private final long reviewCount;
    private final long fieldCount;
    private final double averageRating;
    private final LocalDateTime lastReviewAt;

    public CustomerOverview(
            String customerName, Long reviewCount, Long fieldCount,
            Double averageRating, LocalDateTime lastReviewAt) {
        this.customerName = customerName;
        this.reviewCount = reviewCount;
        this.fieldCount = fieldCount;
        this.averageRating = averageRating;
        this.lastReviewAt = lastReviewAt;
    }

    public String getCustomerName() {
        return customerName;
    }

    public long getReviewCount() {
        return reviewCount;
    }

    public long getFieldCount() {
        return fieldCount;
    }

    public double getAverageRating() {
        return averageRating;
    }

    public LocalDateTime getLastReviewAt() {
        return lastReviewAt;
    }
}
