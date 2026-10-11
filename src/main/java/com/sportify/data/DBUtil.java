package com.sportify.data;

import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

public final class DBUtil {

    private static final EntityManagerFactory entityManagerFactory =
            Persistence.createEntityManagerFactory("sportifyPU");

    private DBUtil() {
    }

    public static EntityManagerFactory getEntityManagerFactory() {
        return entityManagerFactory;
    }

    public static void closeEntityManagerFactory() {
        if (entityManagerFactory.isOpen()) {
            entityManagerFactory.close();
        }
    }
}