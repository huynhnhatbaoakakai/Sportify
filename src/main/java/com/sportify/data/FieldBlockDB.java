package com.sportify.data;

import com.sportify.model.Booking;
import com.sportify.model.FieldBlock;
import com.sportify.model.SportField;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.LockModeType;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;

public final class FieldBlockDB {
    private FieldBlockDB() { }
    public enum Result { CREATED, NOT_FOUND, INVALID_TIME, BOOKING_CONFLICT, BLOCK_CONFLICT }
    public record Outcome(Result result, List<String> affectedBookingCodes) { }

    public static Outcome create(Long fieldId, Long ownerId, LocalDateTime start, LocalDateTime end, String reason) {
        if (fieldId == null || fieldId <= 0 || ownerId == null || ownerId <= 0) throw new IllegalArgumentException("Sân không hợp lệ.");
        if (reason == null || reason.isBlank() || reason.trim().length() > 250) throw new IllegalArgumentException("Lý do khóa giờ phải từ 1 đến 250 ký tự.");
        if (start == null || end == null || !end.isAfter(start) || !end.isAfter(LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")))) {
            return new Outcome(Result.INVALID_TIME, List.of());
        }
        EntityManager em = DBUtil.getEntityManagerFactory().createEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            SportField field = em.find(SportField.class, fieldId, LockModeType.PESSIMISTIC_WRITE);
            if (field == null || !ownerId.equals(field.getOwnerId())) return rollback(transaction, Result.NOT_FOUND);
            List<Booking> affected = em.createQuery("SELECT b FROM Booking b WHERE b.field.fieldId=:fieldId " +
                            "AND b.status IN ('CONFIRMED','COMPLETED') AND b.startsAt<:end AND b.endsAt>:start ORDER BY b.startsAt", Booking.class)
                    .setParameter("fieldId", fieldId).setParameter("start", start).setParameter("end", end).getResultList();
            if (!affected.isEmpty()) {
                transaction.rollback();
                return new Outcome(Result.BOOKING_CONFLICT, affected.stream().map(Booking::getBookingCode).toList());
            }
            if (overlaps(em, fieldId, start, end)) return rollback(transaction, Result.BLOCK_CONFLICT);
            FieldBlock block = new FieldBlock();
            block.setField(field); block.setStartsAt(start); block.setEndsAt(end); block.setReason(reason.trim());
            block.setCreatedAt(LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")));
            em.persist(block);
            transaction.commit();
            return new Outcome(Result.CREATED, List.of());
        } catch (RuntimeException exception) {
            if (transaction.isActive()) transaction.rollback();
            throw exception;
        } finally { em.close(); }
    }

    static boolean overlaps(EntityManager em, Long fieldId, LocalDateTime start, LocalDateTime end) {
        return em.createQuery("SELECT COUNT(b) FROM FieldBlock b WHERE b.field.fieldId=:fieldId AND b.startsAt<:end AND b.endsAt>:start", Long.class)
                .setParameter("fieldId", fieldId).setParameter("start", start).setParameter("end", end).getSingleResult() > 0;
    }

    public static List<FieldBlock> findForDay(Long fieldId, Long ownerId, LocalDate date) {
        EntityManager em = DBUtil.getEntityManagerFactory().createEntityManager();
        try {
            return em.createQuery("SELECT b FROM FieldBlock b WHERE b.field.fieldId=:fieldId AND b.field.ownerId=:ownerId " +
                            "AND b.startsAt<:end AND b.endsAt>:start ORDER BY b.startsAt", FieldBlock.class)
                    .setParameter("fieldId", fieldId).setParameter("ownerId", ownerId)
                    .setParameter("start", date.atStartOfDay()).setParameter("end", date.plusDays(1).atStartOfDay()).getResultList();
        } finally { em.close(); }
    }

    public static boolean remove(Long blockId, Long ownerId) {
        EntityManager em = DBUtil.getEntityManagerFactory().createEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            List<Long> fields = em.createQuery("SELECT b.field.fieldId FROM FieldBlock b WHERE b.blockId=:id AND b.field.ownerId=:ownerId", Long.class)
                    .setParameter("id", blockId).setParameter("ownerId", ownerId).getResultList();
            if (fields.isEmpty()) { transaction.rollback(); return false; }
            em.find(SportField.class, fields.get(0), LockModeType.PESSIMISTIC_WRITE);
            FieldBlock block = em.find(FieldBlock.class, blockId, LockModeType.PESSIMISTIC_WRITE);
            if (block == null || !ownerId.equals(block.getField().getOwnerId())) { transaction.rollback(); return false; }
            em.remove(block); transaction.commit(); return true;
        } catch (RuntimeException exception) {
            if (transaction.isActive()) transaction.rollback(); throw exception;
        } finally { em.close(); }
    }

    private static Outcome rollback(EntityTransaction transaction, Result result) {
        transaction.rollback(); return new Outcome(result, List.of());
    }
}
