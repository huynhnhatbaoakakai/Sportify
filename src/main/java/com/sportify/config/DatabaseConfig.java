package com.sportify.config;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

/** Shared PostgreSQL settings for the JDBC DAOs and Hibernate. */
public final class DatabaseConfig {

    private static final Properties LOCAL = loadLocalProperties();

    private DatabaseConfig() {
    }

    public static String getJdbcUrl() {
        String url = setting("url", "jdbc:postgresql://localhost:5432/sporttrent");
        if (!url.startsWith("jdbc:postgresql:")) {
            throw new IllegalArgumentException("SPORTIFY_DB_URL phải là URL JDBC PostgreSQL.");
        }
        return url;
    }

    public static String getUsername() {
        return setting("user", "postgres");
    }

    public static String getPassword() {
        return setting("password", "");
    }

    public static Map<String, Object> getJpaProperties() {
        Map<String, Object> properties = new HashMap<>();
        properties.put("jakarta.persistence.jdbc.driver", "org.postgresql.Driver");
        properties.put("jakarta.persistence.jdbc.url", getJdbcUrl());
        properties.put("jakarta.persistence.jdbc.user", getUsername());
        properties.put("jakarta.persistence.jdbc.password", getPassword());
        return properties;
    }

    private static String setting(String name, String fallback) {
        String value = System.getProperty("sportify.db." + name);
        if (value == null) value = System.getenv("SPORTIFY_DB_" + name.toUpperCase(java.util.Locale.ROOT));
        if (value == null) value = LOCAL.getProperty("db." + name);
        return value == null ? fallback : value;
    }

    private static Properties loadLocalProperties() {
        Properties properties = new Properties();
        try (InputStream input = DatabaseConfig.class.getResourceAsStream("/database.properties")) {
            if (input != null) properties.load(new java.io.InputStreamReader(input, java.nio.charset.StandardCharsets.UTF_8));
        } catch (IOException exception) {
            throw new IllegalStateException("Không đọc được database.properties.", exception);
        }
        return properties;
    }
}
