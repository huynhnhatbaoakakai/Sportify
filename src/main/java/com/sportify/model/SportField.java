package com.sportify.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name = "sports_fields")
public class SportField implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "field_id")
    private Long fieldId;

    @Column(name = "owner_id", nullable = false)
    private Long ownerId;

    @Column(name = "field_name", nullable = false, length = 150)
    private String fieldName;

    @Column(name = "sport_type", nullable = false, length = 30)
    private String sportType;

    @Column(name = "address", nullable = false, length = 255)
    private String address;

    @Column(name = "description", columnDefinition = "text")
    private String description;

    @Column(
        name = "price_per_hour",
        nullable = false,
        precision = 12,
        scale = 2
    )
    private BigDecimal pricePerHour;

    @Column(name = "open_time", nullable = false)
    private LocalTime openTime;

    @Column(name = "close_time", nullable = false)
    private LocalTime closeTime;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "status", nullable = false, length = 20)
    private String status;

    @Column(name = "quantity", nullable = false)
    private Integer quantity = 1;
    @Column(name = "auto_approve", nullable = false)
    private boolean autoApprove;

    public boolean isAutoApprove() { return autoApprove; }
    public void setAutoApprove(boolean autoApprove) { this.autoApprove = autoApprove; }
    public boolean supportsAutoApproval() {
        return "BASKETBALL".equals(sportType) || "PICKLEBALL".equals(sportType);
    }

    @Column(
        name = "created_at",
        nullable = false,
        updatable = false
    )
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public SportField() {
    }

    public SportField(
            Long ownerId,
            String fieldName,
            String sportType,
            String address,
            String description,
            BigDecimal pricePerHour,
            LocalTime openTime,
            LocalTime closeTime,
            String imageUrl,
            String status) {

        this.ownerId = ownerId;
        this.fieldName = fieldName;
        this.sportType = sportType;
        this.address = address;
        this.description = description;
        this.pricePerHour = pricePerHour;
        this.openTime = openTime;
        this.closeTime = closeTime;
        this.imageUrl = imageUrl;
        this.status = status;
        this.quantity = 1;
    }

    @PrePersist
    public void beforeInsert() {
        LocalDateTime now = LocalDateTime.now();

        createdAt = now;
        updatedAt = now;

        if (ownerId == null) {
            ownerId = 1L;
        }

        if (status == null || status.trim().isEmpty()) {
            status = "ACTIVE";
        }

        if (quantity == null || quantity <= 0) {
            quantity = 1;
        }
    }

    @PreUpdate
    public void beforeUpdate() {
        updatedAt = LocalDateTime.now();
        if (quantity == null || quantity <= 0) {
            quantity = 1;
        }
    }

    public Long getFieldId() {
        return fieldId;
    }

    public void setFieldId(Long fieldId) {
        this.fieldId = fieldId;
    }

    public Long getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(Long ownerId) {
        this.ownerId = ownerId;
    }

    public String getFieldName() {
        return fieldName;
    }

    public void setFieldName(String fieldName) {
        this.fieldName = fieldName;
    }

    public String getSportType() {
        return sportType;
    }

    public void setSportType(String sportType) {
        this.sportType = sportType;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public BigDecimal getPricePerHour() {
        return pricePerHour;
    }

    public void setPricePerHour(BigDecimal pricePerHour) {
        this.pricePerHour = pricePerHour;
    }

    public LocalTime getOpenTime() {
        return openTime;
    }

    public void setOpenTime(LocalTime openTime) {
        this.openTime = openTime;
    }

    public LocalTime getCloseTime() {
        return closeTime;
    }

    public void setCloseTime(LocalTime closeTime) {
        this.closeTime = closeTime;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public void setCreatedAt(String createdAt) {
        if (createdAt != null && !createdAt.isEmpty()) {
            try {
                this.createdAt = LocalDateTime.parse(createdAt.replace(" ", "T").substring(0, 19));
            } catch (Exception ignored) {}
        }
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        if (updatedAt != null && !updatedAt.isEmpty()) {
            try {
                this.updatedAt = LocalDateTime.parse(updatedAt.replace(" ", "T").substring(0, 19));
            } catch (Exception ignored) {}
        }
    }

    public void setPricePerHour(double price) {
        this.pricePerHour = BigDecimal.valueOf(price);
    }

    public void setOpenTime(String time) {
        if (time != null && !time.isEmpty()) {
            this.openTime = LocalTime.parse(time.length() > 5 ? time.substring(0, 5) : time);
        }
    }

    public void setCloseTime(String time) {
        if (time != null && !time.isEmpty()) {
            this.closeTime = LocalTime.parse(time.length() > 5 ? time.substring(0, 5) : time);
        }
    }

    public int getQuantity() { return quantity != null && quantity > 0 ? quantity : 1; }
    public void setQuantity(Integer quantity) { this.quantity = quantity != null && quantity > 0 ? quantity : 1; }
}
