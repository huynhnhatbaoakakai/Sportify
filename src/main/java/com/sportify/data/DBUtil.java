package com.sportify.data;

import com.sportify.config.DatabaseConfig;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

public final class DBUtil {
    private static EntityManagerFactory entityManagerFactory;
    private DBUtil() { }

    public static synchronized EntityManagerFactory getEntityManagerFactory() {
        if (entityManagerFactory == null || !entityManagerFactory.isOpen()) {
            entityManagerFactory = Persistence.createEntityManagerFactory("sportifyPU", DatabaseConfig.getJpaProperties());
        }
        return entityManagerFactory;
    }

    public static synchronized void closeEntityManagerFactory() {
        if (entityManagerFactory != null && entityManagerFactory.isOpen()) entityManagerFactory.close();
        entityManagerFactory = null;
    }
}
