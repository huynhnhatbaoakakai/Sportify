package com.sportify.data;

import com.sportify.config.DBContext;
import com.sportify.dao.UserDAO;
import com.sportify.model.Booking;
import com.sportify.model.SportField;
import com.sportify.model.User;
import org.junit.*;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.*;
import static org.junit.Assert.*;

public class BookingAutomationIntegrationTest {
    private static final Map<String, String> PREVIOUS = new HashMap<>();
    private static boolean enabled;
    private final List<Long> fields = new ArrayList<>();
    private final List<Integer> accounts = new ArrayList<>();
    private User owner, customer;
    private SportField field;
    private LocalDate day;

    @BeforeClass public static void configureDisposableDatabase() {
        String url = System.getProperty("sportify.reviewTestUrl");
        Assume.assumeTrue(url != null);
        if (!url.matches("jdbc:postgresql://(?:localhost|127\\.0\\.0\\.1):[0-9]+/sportify_review_test")) throw new IllegalArgumentException("Disposable database required.");
        DBUtil.closeEntityManagerFactory();
        for (String key : new String[]{"url", "user", "password"}) {
            String property = "sportify.db." + key;
            PREVIOUS.put(property, System.getProperty(property));
            System.setProperty(property, key.equals("url") ? url : key.equals("user") ? "sportify_review_test" : "");
        }
        enabled = true;
    }

    @AfterClass public static void restoreConfiguration() {
        if (!enabled) return;
        DBUtil.closeEntityManagerFactory();
        PREVIOUS.forEach((key, value) -> { if (value == null) System.clearProperty(key); else System.setProperty(key, value); });
    }

    @Before public void createOwnFixtures() throws Exception {
        day = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")).plusDays(3);
        owner = account(); customer = account();
        execute("UPDATE public.users SET role='OWNER' WHERE id=?", owner.getId());
        owner.setRole("OWNER");
        field = new SportField((long) owner.getId(), "Automation " + UUID.randomUUID(), "PICKLEBALL", "Test address", "Mô tả",
                new BigDecimal("100000.00"), LocalTime.of(6, 0), LocalTime.of(22, 0), null, "ACTIVE");
        SportFieldDB.insert(field); fields.add(field.getFieldId());
    }

    @After public void removeOwnFixtures() throws Exception {
        for (Long id : fields) { execute("DELETE FROM public.bookings WHERE field_id=?", id); execute("DELETE FROM public.sports_fields WHERE field_id=?", id); }
        for (Integer id : accounts) execute("DELETE FROM public.users WHERE id=?", id);
    }

    private User account() {
        String email = "automation-" + UUID.randomUUID() + "@example.invalid";
        UserDAO dao = new UserDAO();
        assertEquals("SUCCESS", dao.registerUser(new User("Khách kiểm thử", email, "test-password")));
        User result = dao.checkLogin(email, "test-password");
        assertNotNull(result); accounts.add(result.getId()); return result;
    }
    private Long ownerId() { return (long) owner.getId(); }
    private BookingDB.CreateResult create(User user, int start, int end) {
        return BookingDB.createCustomerBooking(field.getFieldId(), user.getId(), user.getFullname(), null, day.atTime(start, 0), day.atTime(end, 0));
    }
    private Booking latest(User user) { return BookingDB.findByCustomerId(user.getId()).get(0); }
    private void automatic() { assertTrue(SportFieldDB.setAutoApproval(field.getFieldId(), ownerId(), true)); }

    @Test public void enablingAutomationOnlyAffectsNewBookingsAndAuditsBothModes() {
        assertEquals(BookingDB.CreateResult.CREATED, create(customer, 8, 9));
        Long pending = latest(customer).getBookingId();
        automatic();
        assertEquals("PENDING", BookingDB.findByCustomerId(customer.getId()).stream().filter(item -> item.getBookingId().equals(pending)).findFirst().orElseThrow().getStatus());
        assertEquals(BookingDB.CreateResult.AUTO_CONFIRMED, create(customer, 10, 11));
        assertTrue(latest(customer).isAutomaticallyConfirmed());
        assertEquals("CONFIRMED", latest(customer).getStatus());
        assertEquals(2, NotificationDB.countUnread(customer.getId()));
        assertEquals(2, NotificationDB.countUnread(owner.getId()));
        assertEquals("SYSTEM", BookingActivityDB.findByOwner(ownerId()).get(latest(customer).getBookingId()).get(0).actorType());
        assertEquals("CUSTOMER", BookingActivityDB.findByOwner(ownerId()).get(pending).get(0).actorType());
    }

    @Test public void manualModeKeepsPendingAndRejectsDuplicateRequests() {
        assertEquals(BookingDB.CreateResult.CREATED, create(customer, 8, 9));
        assertEquals(BookingDB.CreateResult.DUPLICATE, create(customer, 8, 9));
        assertEquals("PENDING", latest(customer).getStatus());
        assertEquals(1, NotificationDB.countUnread(customer.getId()));
    }

    @Test public void simultaneousAutomaticBookingsHaveOneWinner() throws Exception {
        automatic(); User other = account();
        ExecutorService workers = Executors.newFixedThreadPool(2); CountDownLatch start = new CountDownLatch(1);
        try {
            Future<BookingDB.CreateResult> first = workers.submit(() -> { start.await(); return create(customer, 8, 9); });
            Future<BookingDB.CreateResult> second = workers.submit(() -> { start.await(); return create(other, 8, 9); });
            start.countDown();
            List<BookingDB.CreateResult> results = List.of(first.get(30, TimeUnit.SECONDS), second.get(30, TimeUnit.SECONDS));
            assertTrue(results.contains(BookingDB.CreateResult.AUTO_CONFIRMED));
            assertTrue(results.contains(BookingDB.CreateResult.CONFLICT));
            assertEquals(1, NotificationDB.countUnread(owner.getId()));
            assertEquals(1, BookingDB.findByOwnerId(ownerId()).stream().filter(item -> item.getField().getFieldId().equals(field.getFieldId())).count());
        } finally { workers.shutdownNow(); }
    }

    @Test public void aBlockPreventsCreationAndManualConfirmationUntilRemoved() {
        assertEquals(BookingDB.CreateResult.CREATED, create(customer, 8, 9)); Long pending = latest(customer).getBookingId();
        assertEquals(FieldBlockDB.Result.CREATED, FieldBlockDB.create(field.getFieldId(), ownerId(), day.atTime(8, 0), day.atTime(9, 0), "Bảo trì").result());
        assertEquals(BookingDB.StatusChangeResult.BLOCKED, BookingDB.changeStatus(pending, ownerId(), "CONFIRMED"));
        automatic();
        assertEquals(BookingDB.CreateResult.BLOCKED, create(customer, 8, 9));
        assertEquals("PENDING", latest(customer).getStatus());
        assertEquals(1, NotificationDB.countUnread(customer.getId()));
        Long blockId = FieldBlockDB.findForDay(field.getFieldId(), ownerId(), day).get(0).getBlockId();
        assertTrue(FieldBlockDB.remove(blockId, ownerId()));
        assertEquals(BookingDB.StatusChangeResult.UPDATED, BookingDB.changeStatus(pending, ownerId(), "CONFIRMED"));
        assertFalse(latest(customer).isAutomaticallyConfirmed());
    }

    @Test public void creatingBlockReportsAffectedConfirmedBookingsAndAllowsAdjacentTime() {
        automatic(); assertEquals(BookingDB.CreateResult.AUTO_CONFIRMED, create(customer, 8, 9));
        FieldBlockDB.Outcome conflict = FieldBlockDB.create(field.getFieldId(), ownerId(), day.atTime(8, 30), day.atTime(9, 30), "Khách trực tiếp");
        assertEquals(FieldBlockDB.Result.BOOKING_CONFLICT, conflict.result());
        assertTrue(conflict.affectedBookingCodes().contains(latest(customer).getBookingCode()));
        assertTrue(FieldBlockDB.findForDay(field.getFieldId(), ownerId(), day).isEmpty());
        assertEquals(FieldBlockDB.Result.CREATED, FieldBlockDB.create(field.getFieldId(), ownerId(), day.atTime(9, 0), day.atTime(10, 0), "Bảo trì").result());
        assertEquals(FieldBlockDB.Result.BLOCK_CONFLICT, FieldBlockDB.create(field.getFieldId(), ownerId(), day.atTime(9, 30), day.atTime(10, 30), "Khóa trùng").result());
    }

    @Test public void simultaneousBlockAndAutomaticBookingCannotOverlap() throws Exception {
        automatic(); ExecutorService workers = Executors.newFixedThreadPool(2); CountDownLatch start = new CountDownLatch(1);
        try {
            Future<BookingDB.CreateResult> booking = workers.submit(() -> { start.await(); return create(customer, 8, 9); });
            Future<FieldBlockDB.Outcome> block = workers.submit(() -> { start.await(); return FieldBlockDB.create(field.getFieldId(), ownerId(), day.atTime(8, 0), day.atTime(9, 0), "Bảo trì"); });
            start.countDown();
            BookingDB.CreateResult bookingResult = booking.get(30, TimeUnit.SECONDS);
            FieldBlockDB.Result blockResult = block.get(30, TimeUnit.SECONDS).result();
            assertTrue((bookingResult == BookingDB.CreateResult.AUTO_CONFIRMED && blockResult == FieldBlockDB.Result.BOOKING_CONFLICT)
                    || (bookingResult == BookingDB.CreateResult.BLOCKED && blockResult == FieldBlockDB.Result.CREATED));
        } finally { workers.shutdownNow(); }
    }

    @Test public void foreignOwnerCannotChangePoliciesBlocksOrBookings() {
        Long foreignOwner = (long) customer.getId();
        assertFalse(SportFieldDB.setAutoApproval(field.getFieldId(), foreignOwner, true));
        assertEquals(FieldBlockDB.Result.NOT_FOUND, FieldBlockDB.create(field.getFieldId(), foreignOwner, day.atTime(8, 0), day.atTime(9, 0), "Forbidden").result());
        assertEquals(FieldBlockDB.Result.CREATED, FieldBlockDB.create(field.getFieldId(), ownerId(), day.atTime(8, 0), day.atTime(9, 0), "Bảo trì").result());
        Long blockId = FieldBlockDB.findForDay(field.getFieldId(), ownerId(), day).get(0).getBlockId();
        assertFalse(FieldBlockDB.remove(blockId, foreignOwner));
        assertTrue(FieldBlockDB.findForDay(field.getFieldId(), foreignOwner, day).isEmpty());
        assertEquals(BookingDB.CreateResult.CREATED, create(customer, 10, 11));
        assertEquals(BookingDB.StatusChangeResult.NOT_FOUND, BookingDB.changeStatus(latest(customer).getBookingId(), foreignOwner, "CONFIRMED"));
    }

    @Test public void availabilitySeparatesFreeReservedBlockedAndAdjacentWindowsWithoutCustomerDetails() {
        automatic(); assertEquals(BookingDB.CreateResult.AUTO_CONFIRMED, create(customer, 8, 9));
        assertEquals(FieldBlockDB.Result.CREATED, FieldBlockDB.create(field.getFieldId(), ownerId(), day.atTime(10, 0), day.atTime(11, 0), "Bảo trì mặt sân").result());
        AvailabilityDB.Day availability = AvailabilityDB.getDay(field.getFieldId(), day);
        assertTrue(availability.autoApprove());
        assertTrue(availability.windows().stream().anyMatch(window -> window.status().equals("BOOKED") && window.startsAt().equals(day.atTime(8, 0))));
        assertTrue(availability.windows().stream().anyMatch(window -> window.status().equals("FREE") && window.startsAt().equals(day.atTime(9, 0)) && window.endsAt().equals(day.atTime(10, 0))));
        assertTrue(availability.windows().stream().anyMatch(window -> window.status().equals("BLOCKED") && window.reason().equals("Bảo trì mặt sân")));
        String json = com.sportify.util.JsonResponse.getGson().toJson(availability);
        assertFalse(json.contains("customerName")); assertFalse(json.contains("customerId")); assertFalse(json.contains(customer.getEmail()));
    }

    @Test public void overnightBlocksAreClippedToEachDaysOpeningHours() {
        assertEquals(FieldBlockDB.Result.CREATED, FieldBlockDB.create(field.getFieldId(), ownerId(), day.atTime(20, 0), day.plusDays(1).atTime(8, 0), "Bảo trì qua đêm").result());
        List<AvailabilityDB.Window> today = AvailabilityDB.getDay(field.getFieldId(), day).windows();
        List<AvailabilityDB.Window> tomorrow = AvailabilityDB.getDay(field.getFieldId(), day.plusDays(1)).windows();
        assertTrue(today.stream().anyMatch(window -> window.status().equals("BLOCKED") && window.endsAt().equals(day.atTime(22, 0))));
        assertTrue(tomorrow.stream().anyMatch(window -> window.status().equals("BLOCKED") && window.startsAt().equals(day.plusDays(1).atTime(6, 0)) && window.endsAt().equals(day.plusDays(1).atTime(8, 0))));
    }

    @Test public void completionRequiresOwnerConfirmationAfterTheEndAndOnlyThenCountsRevenue() {
        automatic(); assertEquals(BookingDB.CreateResult.AUTO_CONFIRMED, create(customer, 8, 9));
        Booking booking = latest(customer);
        assertEquals(BookingDB.StatusChangeResult.INVALID_TIME, BookingDB.changeStatus(booking.getBookingId(), ownerId(), "COMPLETED"));
        assertEquals(0, BookingDB.getDashboardSummary(ownerId(), day).getTodayRevenue().compareTo(BigDecimal.ZERO));
        assertEquals(BookingDB.StatusChangeResult.UPDATED, BookingDB.changeStatus(DBUtil.getEntityManagerFactory().createEntityManager(), booking.getBookingId(), ownerId(), "COMPLETED", day.atTime(9, 1)));
        assertEquals(new BigDecimal("100000.00"), BookingDB.getDashboardSummary(ownerId(), day).getTodayRevenue());
        assertEquals("OWNER", BookingActivityDB.findByOwner(ownerId()).get(booking.getBookingId()).get(0).actorType());
    }

    @Test public void notificationsAndCancellationAreScopedToTheAuthenticatedCustomer() {
        assertEquals(BookingDB.CreateResult.CREATED, create(customer, 8, 9));
        assertFalse(BookingDB.cancelByCustomer(latest(customer).getBookingId(), owner.getId()));
        assertTrue(BookingDB.cancelByCustomer(latest(customer).getBookingId(), customer.getId()));
        assertEquals(2, NotificationDB.countUnread(customer.getId()));
        long customerNotification = NotificationDB.findByUser(customer.getId()).get(0).id();
        assertEquals(0, NotificationDB.markRead(owner.getId(), customerNotification));
        assertEquals(2, NotificationDB.countUnread(customer.getId()));
        assertEquals(2, NotificationDB.markRead(owner.getId(), null));
        assertEquals(0, NotificationDB.countUnread(owner.getId()));
        assertEquals(2, NotificationDB.countUnread(customer.getId()));
    }

    @Test public void inactiveFieldsInvalidTimesAndCapacityServicesDoNotAutoConfirm() {
        automatic();
        assertTrue(SportFieldDB.toggleStatus(field.getFieldId(), ownerId()));
        assertEquals(BookingDB.CreateResult.FIELD_INACTIVE, create(customer, 8, 9));
        assertTrue(SportFieldDB.toggleStatus(field.getFieldId(), ownerId()));
        assertEquals(BookingDB.CreateResult.INVALID_TIME, create(customer, 5, 6));
        assertEquals(BookingDB.CreateResult.INVALID_TIME, create(customer, 9, 8));
        assertEquals(BookingDB.CreateResult.PAST_TIME, BookingDB.createCustomerBooking(field.getFieldId(), customer.getId(), "Test", null, day.minusDays(10).atTime(8, 0), day.minusDays(10).atTime(9, 0)));
        field.setSportType("GYM"); assertTrue(SportFieldDB.update(field, ownerId()));
        assertFalse(SportFieldDB.findById(field.getFieldId()).isAutoApprove());
        assertThrows(IllegalArgumentException.class, () -> SportFieldDB.setAutoApproval(field.getFieldId(), ownerId(), true));
        assertEquals(BookingDB.CreateResult.CREATED, create(customer, 8, 9));
    }

    @Test public void storedNewPasswordsAreHashedAndRolesComeFromDatabase() throws Exception {
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement("SELECT password FROM public.users WHERE id=?")) {
            statement.setInt(1, owner.getId());
            try (ResultSet result = statement.executeQuery()) { assertTrue(result.next()); assertTrue(result.getString(1).startsWith("pbkdf2-sha256$")); }
        }
        assertTrue(new UserDAO().checkLogin(owner.getEmail(), "test-password").isOwner());
        assertFalse(new UserDAO().checkLogin(customer.getEmail(), "test-password").isOwner());
    }

    private static void execute(String sql, Object... values) throws Exception {
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            for (int index = 0; index < values.length; index++) statement.setObject(index + 1, values[index]);
            statement.executeUpdate();
        }
    }
}
