package com.sportify.config;

import com.sportify.data.DBUtil;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class AppLifecycle implements ServletContextListener {
    @Override
    public void contextDestroyed(ServletContextEvent event) { DBUtil.closeEntityManagerFactory(); }
}
