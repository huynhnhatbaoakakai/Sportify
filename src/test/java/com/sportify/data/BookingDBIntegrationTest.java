package com.sportify.data;

import com.sportify.model.Booking;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Assume;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

import static org.junit.Assert.*;
import static com.sportify.data.BookingDB.StatusChangeResult.*;

/** Opt-in, isolated PostgreSQL only; never uses DBUtil or the application's DB credentials. */
public class BookingDBIntegrationTest {

    private static EntityManagerFactory factory;
    private static String url;
    private static Long ownedFieldId;
    private static Long foreignFieldId;
    private static final LocalDate DAY = LocalDate.of(2035, 1, 15);
    private static final LocalDateTime NOW = DAY.atTime(7, 0);

    @BeforeClass
    public static void connectToDisposableDatabase() throws Exception {
        url = System.getProperty("sportify.reviewTestUrl");
        Assume.assumeTrue("Requires a disposable PostgreSQL database", url != null);
        ownedFieldId = fieldIdForOwner(1L);
        foreignFieldId = fieldIdForOwner(2L);
        Map<String, Object> properties = new HashMap<String, Object>();
        properties.put("jakarta.persistence.jdbc.url", url);
        properties.put("jakarta.persistence.jdbc.user", "sportify_review_test");
        properties.put("jakarta.persistence.jdbc.password", "");
        properties.put("hibernate.show_sql", "false");
        factory = Persistence.createEntityManagerFactory("sportifyPU", properties);
    }

    @Before
    public void resetOnlyDisposableBookingFixtures() throws Exception {
        execute("DELETE FROM bookings");
        execute("UPDATE sports_fields SET status = 'ACTIVE' WHERE field_id = ?", ownedFieldId);
    }

    @After
    public void restoreDisposableFieldState() throws Exception {
        execute("UPDATE sports_fields SET status = 'ACTIVE' WHERE field_id = ?", ownedFieldId);
    }

    @AfterClass
    public static void closeFactory() { if (factory != null) factory.close(); }

    @Test
    public void ownedListExcludesForeignBookingsAndLoadsFieldsBeforeClose() throws Exception {
        insert(ownedFieldId, DAY.atTime(8, 0), DAY.atTime(9, 0), "PENDING", "100000.00");
        insert(ownedFieldId, DAY.atTime(10, 0), DAY.atTime(11, 0), "PENDING", "200000.00");
        insert(foreignFieldId, DAY.atTime(8, 0), DAY.atTime(9, 0), "PENDING", "900000.00");
        List<Booking> bookings = BookingDB.findByOwnerId(factory.createEntityManager(), 1L);
        assertEquals(2, bookings.size());
        for (Booking booking : bookings) {
            assertEquals(Long.valueOf(1), booking.getField().getOwnerId());
            assertNotNull(booking.getField().getFieldName());
        }
        assertFalse(bookings.get(1).getCreatedAt().isAfter(bookings.get(0).getCreatedAt()));
    }

    @Test
    public void cannotModifyForeignOrMissingBooking() throws Exception {
        Long foreign = insert(foreignFieldId, DAY.atTime(8, 0), DAY.atTime(9, 0), "PENDING", "100000.00");
        assertEquals(NOT_FOUND, change(foreign, "CONFIRMED"));
        assertEquals(NOT_FOUND, change(Long.MAX_VALUE, "REJECTED"));
        assertEquals("PENDING", find(foreign).getStatus());
    }

    @Test
    public void confirmsOrRejectsPendingOnlyAndPersistsAfterReload() throws Exception {
        Long confirmed = insert(ownedFieldId, DAY.atTime(8, 0), DAY.atTime(9, 0), "PENDING", "100000.00");
        Long rejected = insert(ownedFieldId, DAY.atTime(10, 0), DAY.atTime(11, 0), "PENDING", "100000.00");
        assertEquals(UPDATED, change(confirmed, "CONFIRMED"));
        assertEquals(UPDATED, change(rejected, "REJECTED"));
        assertEquals("CONFIRMED", find(confirmed).getStatus());
        assertEquals(NOW, find(confirmed).getUpdatedAt());
        assertEquals("REJECTED", find(rejected).getStatus());
        assertEquals(NOT_PENDING, change(confirmed, "REJECTED"));
        assertEquals(NOT_PENDING, change(rejected, "CONFIRMED"));
        assertEquals("CONFIRMED", find(confirmed).getStatus());
    }

    @Test
    public void blocksOverlapButAllowsAdjacentSlots() throws Exception {
        Long first = insert(ownedFieldId, DAY.atTime(8, 0), DAY.atTime(9, 0), "PENDING", "100000.00");
        Long overlap = insert(ownedFieldId, DAY.atTime(8, 30), DAY.atTime(9, 30), "PENDING", "100000.00");
        Long adjacent = insert(ownedFieldId, DAY.atTime(9, 0), DAY.atTime(10, 0), "PENDING", "100000.00");
        assertEquals(UPDATED, change(first, "CONFIRMED"));
        assertEquals(CONFLICT, change(overlap, "CONFIRMED"));
        assertEquals("PENDING", find(overlap).getStatus());
        assertEquals(UPDATED, change(adjacent, "CONFIRMED"));
    }

    @Test
    public void rejectsExpiredAndOutOfHoursConfirmations() throws Exception {
        Long expired = insert(ownedFieldId, DAY.minusDays(1).atTime(8, 0), DAY.minusDays(1).atTime(9, 0), "PENDING", "100000.00");
        Long early = insert(ownedFieldId, DAY.plusDays(1).atTime(5, 0), DAY.plusDays(1).atTime(6, 0), "PENDING", "100000.00");
        Long late = insert(ownedFieldId, DAY.plusDays(1).atTime(21, 30), DAY.plusDays(1).atTime(22, 30), "PENDING", "100000.00");
        assertEquals(INVALID_TIME, change(expired, "CONFIRMED"));
        assertEquals(INVALID_TIME, change(early, "CONFIRMED"));
        assertEquals(INVALID_TIME, change(late, "CONFIRMED"));
        assertEquals(UPDATED, change(expired, "REJECTED"));
    }

    @Test
    public void blocksInactiveFieldConfirmationButAllowsRejection() throws Exception {
        Long id = insert(ownedFieldId, DAY.atTime(8, 0), DAY.atTime(9, 0), "PENDING", "100000.00");
        execute("UPDATE sports_fields SET status = 'INACTIVE' WHERE field_id = ?", ownedFieldId);
        assertEquals(FIELD_INACTIVE, change(id, "CONFIRMED"));
        assertEquals("PENDING", find(id).getStatus());
        assertEquals(UPDATED, change(id, "REJECTED"));
    }

    @Test
    public void statisticsUseOwnedActiveBookingsAndCompletedRevenueOnly() throws Exception {
        insert(ownedFieldId, DAY.atTime(8, 0), DAY.atTime(9, 0), "PENDING", "100000.00");
        insert(ownedFieldId, DAY.atTime(10, 0), DAY.atTime(11, 0), "CONFIRMED", "200000.00");
        insert(ownedFieldId, DAY.atTime(12, 0), DAY.atTime(13, 0), "COMPLETED", "125000.50");
        insert(ownedFieldId, DAY.atTime(12, 0), DAY.atTime(13, 0), "REJECTED", "900000.00");
        insert(ownedFieldId, DAY.atTime(12, 0), DAY.atTime(13, 0), "CANCELLED", "900000.00");
        insert(ownedFieldId, DAY.plusDays(1).atTime(8, 0), DAY.plusDays(1).atTime(9, 0), "PENDING", "100000.00");
        insert(foreignFieldId, DAY.atTime(12, 0), DAY.atTime(13, 0), "COMPLETED", "999999.00");
        BookingDB.Summary summary = BookingDB.getDashboardSummary(factory.createEntityManager(), 1L, DAY);
        assertEquals(3, summary.getTodayCount());
        assertEquals(2, summary.getPendingCount());
        assertEquals(0, new BigDecimal("125000.50").compareTo(summary.getTodayRevenue()));
        BookingDB.Summary empty = BookingDB.getDashboardSummary(factory.createEntityManager(), 99L, DAY);
        assertEquals(0, empty.getTodayCount());
        assertEquals(0, empty.getPendingCount());
        assertEquals(0, empty.getTodayRevenue().compareTo(BigDecimal.ZERO));
    }

    @Test
    public void databaseConstraintRejectsConflictingWritesFromOtherClients() throws Exception {
        insert(ownedFieldId, DAY.atTime(8, 0), DAY.atTime(9, 0), "CONFIRMED", "100000.00");
        try {
            insert(ownedFieldId, DAY.atTime(8, 30), DAY.atTime(9, 30), "CONFIRMED", "100000.00");
            fail("Overlapping confirmed booking should fail");
        } catch (SQLException expected) {
            assertEquals("23P01", expected.getSQLState());
        }
        insert(ownedFieldId, DAY.atTime(9, 0), DAY.atTime(10, 0), "CONFIRMED", "100000.00");
    }

    @Test
    public void simultaneousConfirmationsHaveOnlyOneWinner() throws Exception {
        Long first = insert(ownedFieldId, DAY.atTime(8, 0), DAY.atTime(10, 0), "PENDING", "100000.00");
        Long second = insert(ownedFieldId, DAY.atTime(9, 0), DAY.atTime(11, 0), "PENDING", "100000.00");
        ExecutorService workers = Executors.newFixedThreadPool(2);
        CountDownLatch start = new CountDownLatch(1);
        try {
            Future<BookingDB.StatusChangeResult> left = workers.submit(() -> { start.await(); return change(first, "CONFIRMED"); });
            Future<BookingDB.StatusChangeResult> right = workers.submit(() -> { start.await(); return change(second, "CONFIRMED"); });
            start.countDown();
            List<BookingDB.StatusChangeResult> results = Arrays.asList(left.get(20, TimeUnit.SECONDS), right.get(20, TimeUnit.SECONDS));
            assertTrue(results.contains(UPDATED));
            assertTrue(results.contains(CONFLICT));
            int confirmed = ("CONFIRMED".equals(find(first).getStatus()) ? 1 : 0)
                    + ("CONFIRMED".equals(find(second).getStatus()) ? 1 : 0);
            assertEquals(1, confirmed);
        } finally {
            workers.shutdownNow();
        }
    }

    private static BookingDB.StatusChangeResult change(Long id, String status) {
        return BookingDB.changeStatus(factory.createEntityManager(), id, 1L, status, NOW);
    }

    private static Booking find(Long id) {
        EntityManager em = factory.createEntityManager();
        try { return em.find(Booking.class, id); } finally { em.close(); }
    }

    private static Connection connect() throws SQLException {
        return DriverManager.getConnection(url, "sportify_review_test", "");
    }

    private static Long fieldIdForOwner(Long ownerId) throws SQLException {
        try (Connection connection = connect(); PreparedStatement statement = connection.prepareStatement(
                "SELECT field_id FROM sports_fields WHERE owner_id = ? ORDER BY field_id LIMIT 1")) {
            statement.setLong(1, ownerId);
            try (ResultSet result = statement.executeQuery()) { assertTrue(result.next()); return result.getLong(1); }
        }
    }

    private static Long insert(Long fieldId, LocalDateTime start, LocalDateTime end, String status, String price)
            throws SQLException {
        try (Connection connection = connect(); PreparedStatement statement = connection.prepareStatement(
                "INSERT INTO bookings (field_id, customer_name, starts_at, ends_at, total_price, status) " +
                "VALUES (?, 'Khách kiểm thử', ?, ?, ?, ?) RETURNING booking_id")) {
            statement.setLong(1, fieldId);
            statement.setObject(2, start);
            statement.setObject(3, end);
            statement.setBigDecimal(4, new BigDecimal(price));
            statement.setString(5, status);
            try (ResultSet result = statement.executeQuery()) { assertTrue(result.next()); return result.getLong(1); }
        }
    }

    private static void execute(String sql, Object... parameters) throws SQLException {
        try (Connection connection = connect(); PreparedStatement statement = connection.prepareStatement(sql)) {
            for (int index = 0; index < parameters.length; index++) statement.setObject(index + 1, parameters[index]);
            statement.executeUpdate();
        }
    }
}
