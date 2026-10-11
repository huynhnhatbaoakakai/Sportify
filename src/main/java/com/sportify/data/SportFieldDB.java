package com.sportify.data;

import com.sportify.model.SportField;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;

import java.util.List;

public final class SportFieldDB {

    private SportFieldDB() {
    }

    public static List<SportField> findByOwnerId(Long ownerId) {
        EntityManager em =
                DBUtil.getEntityManagerFactory().createEntityManager();

        String jpql =
                "SELECT field FROM SportField field " +
                "WHERE field.ownerId = :ownerId " +
                "ORDER BY field.createdAt DESC";

        try {
            TypedQuery<SportField> query =
                    em.createQuery(jpql, SportField.class);

            query.setParameter("ownerId", ownerId);

            return query.getResultList();
        } finally {
            em.close();
        }
    }

    /** Tất cả sân/dịch vụ đang hoạt động — hiển thị cho khách đặt lịch ở trang chủ. */
    public static List<SportField> findActive() {
        EntityManager em =
                DBUtil.getEntityManagerFactory().createEntityManager();
        try {
            return em.createQuery(
                    "SELECT field FROM SportField field " +
                    "WHERE field.status = 'ACTIVE' " +
                    "ORDER BY field.fieldId", SportField.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /** Lấy thông tin sân theo mã fieldId. */
    public static SportField findById(Long fieldId) {
        if (fieldId == null) return null;
        EntityManager em = DBUtil.getEntityManagerFactory().createEntityManager();
        try {
            return em.find(SportField.class, fieldId);
        } finally {
            em.close();
        }
    }

    public static SportField findByIdAndOwnerId(
            Long fieldId,
            Long ownerId) {

        EntityManager em =
                DBUtil.getEntityManagerFactory().createEntityManager();

        String jpql =
                "SELECT field FROM SportField field " +
                "WHERE field.fieldId = :fieldId " +
                "AND field.ownerId = :ownerId";

        try {
            TypedQuery<SportField> query =
                    em.createQuery(jpql, SportField.class);

            query.setParameter("fieldId", fieldId);
            query.setParameter("ownerId", ownerId);

            List<SportField> results = query.getResultList();

            if (results.isEmpty()) {
                return null;
            }

            return results.get(0);
        } finally {
            em.close();
        }
    }

    public static void insert(SportField field) {
        EntityManager em =
                DBUtil.getEntityManagerFactory().createEntityManager();

        EntityTransaction transaction = em.getTransaction();

        try {
            transaction.begin();

            em.persist(field);

            transaction.commit();
        } catch (RuntimeException exception) {
            rollback(transaction);
            throw exception;
        } finally {
            em.close();
        }
    }

    public static boolean update(
            SportField updatedField,
            Long ownerId) {

        EntityManager em =
                DBUtil.getEntityManagerFactory().createEntityManager();

        EntityTransaction transaction = em.getTransaction();

        try {
            transaction.begin();

            SportField currentField =
                    em.find(
                        SportField.class,
                        updatedField.getFieldId()
                    );

            if (currentField == null
                    || !ownerId.equals(currentField.getOwnerId())) {

                transaction.rollback();
                return false;
            }

            currentField.setFieldName(
                    updatedField.getFieldName());

            currentField.setSportType(
                    updatedField.getSportType());

            currentField.setAddress(
                    updatedField.getAddress());

            currentField.setDescription(
                    updatedField.getDescription());

            currentField.setPricePerHour(
                    updatedField.getPricePerHour());

            currentField.setOpenTime(
                    updatedField.getOpenTime());

            currentField.setCloseTime(
                    updatedField.getCloseTime());

            currentField.setImageUrl(
                    updatedField.getImageUrl());

            currentField.setStatus(
                    updatedField.getStatus());

            transaction.commit();
            return true;
        } catch (RuntimeException exception) {
            rollback(transaction);
            throw exception;
        } finally {
            em.close();
        }
    }

    public static boolean toggleStatus(
            Long fieldId,
            Long ownerId) {

        EntityManager em =
                DBUtil.getEntityManagerFactory().createEntityManager();

        EntityTransaction transaction = em.getTransaction();

        try {
            transaction.begin();

            SportField field =
                    em.find(SportField.class, fieldId);

            if (field == null
                    || !ownerId.equals(field.getOwnerId())) {

                transaction.rollback();
                return false;
            }

            if ("ACTIVE".equals(field.getStatus())) {
                field.setStatus("INACTIVE");
            } else {
                field.setStatus("ACTIVE");
            }

            transaction.commit();
            return true;
        } catch (RuntimeException exception) {
            rollback(transaction);
            throw exception;
        } finally {
            em.close();
        }
    }

    private static void rollback(
            EntityTransaction transaction) {

        if (transaction != null && transaction.isActive()) {
            transaction.rollback();
        }
    }
}