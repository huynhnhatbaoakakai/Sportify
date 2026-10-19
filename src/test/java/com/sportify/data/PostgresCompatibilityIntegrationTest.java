package com.sportify.data;

import com.sportify.config.DBContext;
import com.sportify.dao.AppointmentDAO;
import com.sportify.dao.ChatDAO;
import com.sportify.dao.PostDAO;
import com.sportify.dao.SportFieldDAO;
import com.sportify.dao.UserDAO;
import com.sportify.model.Appointment;
import com.sportify.model.Booking;
import com.sportify.model.ChatMessage;
import com.sportify.model.ChatSession;
import com.sportify.model.Post;
import com.sportify.model.PostComment;
import com.sportify.model.SportField;
import com.sportify.model.User;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Assume;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.junit.Assert.*;

/** Exercises the application's JDBC and JPA paths against a disposable PostgreSQL database. */
public class PostgresCompatibilityIntegrationTest {

    private static final long OWNER_ID = 900001L;
    private static final Map<String, String> PREVIOUS_PROPERTIES = new HashMap<>();
    private static boolean enabled;
    private User user;
    private String email;
    private String peerEmail;

    @BeforeClass
    public static void useDisposableDatabase() {
        String url = System.getProperty("sportify.reviewTestUrl");
        Assume.assumeTrue("Requires a disposable PostgreSQL database", url != null);
        if (!url.matches("jdbc:postgresql://(?:localhost|127\\.0\\.0\\.1):[0-9]+/sportify_review_test")) {
            throw new IllegalArgumentException("Use a separate local sportify_review_test database.");
        }
        override("url", url);
        override("user", "sportify_review_test");
        override("password", "");
        enabled = true;
    }

    private static void override(String key, String value) {
        String property = "sportify.db." + key;
        PREVIOUS_PROPERTIES.put(property, System.getProperty(property));
        System.setProperty(property, value);
    }

    @AfterClass
    public static void closeApplicationFactory() {
        if (!enabled) return;
        try {
            DBUtil.closeEntityManagerFactory();
        } finally {
            PREVIOUS_PROPERTIES.forEach((key, value) -> {
                if (value == null) System.clearProperty(key);
                else System.setProperty(key, value);
            });
        }
    }

    @Before
    public void registerCustomer() {
        email = "pg-check-" + UUID.randomUUID() + "@example.invalid";
        peerEmail = "pg-peer-" + UUID.randomUUID() + "@example.invalid";
        UserDAO users = new UserDAO();
        assertEquals("SUCCESS", users.registerUser(new User("Khách PostgreSQL", email, "test-password")));
        assertEquals("EMAIL_EXISTS", users.registerUser(new User("Duplicate", email, "test-password")));
        assertNull(users.checkLogin(email, "wrong-password"));
        user = users.checkLogin(email, "test-password");
        assertNotNull(user);
    }

    @After
    public void removeOnlyOwnFixtures() throws Exception {
        if (user == null) return;
        execute("DELETE FROM public.bookings WHERE customer_id = ? OR field_id IN "
                + "(SELECT field_id FROM public.sports_fields WHERE owner_id = ?)", user.getId(), OWNER_ID);
        execute("DELETE FROM public.sports_fields WHERE owner_id = ?", OWNER_ID);
        execute("DELETE FROM public.users WHERE email IN (?, ?)", email, peerEmail);
    }

    @Test
    public void newsfeedFormatsDatesAndReturnsNewCommentId() {
        PostDAO posts = new PostDAO();
        assertTrue(posts.createPost(user.getId(), "Bài viết tiếng Việt 🏀"));
        Post post = posts.getAllPosts(user.getId()).stream()
                .filter(item -> item.getUserId() == user.getId()).findFirst().orElseThrow();
        assertTrue(post.getCreatedAt().matches("[0-9]{2}:[0-9]{2} [0-9]{2}/[0-9]{2}/[0-9]{4}"));
        assertTrue(posts.toggleLike(post.getId(), user.getId()));
        assertEquals(1, posts.getLikeCount(post.getId()));
        assertFalse(posts.toggleLike(post.getId(), user.getId()));
        assertEquals(0, posts.getLikeCount(post.getId()));
        PostComment comment = posts.addComment(post.getId(), user.getId(), "Bình luận mới", user.getFullname());
        assertNotNull(comment);
        assertTrue(comment.getId() > 0);
        Post reloaded = posts.getAllPosts(user.getId()).stream()
                .filter(item -> item.getId() == post.getId()).findFirst().orElseThrow();
        assertEquals("Bình luận mới", reloaded.getComments().get(0).getContent());
    }

    @Test
    public void appointmentsBindDateAndTimeAndAggregateCurrentMonth() throws Exception {
        AppointmentDAO appointments = new AppointmentDAO();
        Appointment appointment = new Appointment();
        appointment.setUserId(user.getId());
        appointment.setTitle("Lịch tập PostgreSQL");
        appointment.setAppointmentDate(LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")).plusDays(2).toString());
        appointment.setAppointmentTime("09:30");
        appointment.setType("court");
        appointment.setNote("Kiểm thử ngày giờ");
        assertTrue(appointments.createAppointment(appointment));
        assertEquals(1, appointments.countUpcoming(user.getId()));
        assertEquals(1, appointments.getUpcomingAppointments(user.getId()).size());
        Appointment saved = appointments.getAllAppointments(user.getId()).get(0);
        assertEquals(LocalTime.of(9, 30), LocalTime.parse(saved.getAppointmentTime()));
        execute("INSERT INTO public.training_sessions (user_id, duration_hours, session_date) VALUES (?, 3, CURRENT_DATE)", user.getId());
        execute("INSERT INTO public.training_sessions (user_id, duration_hours, session_date) VALUES (?, 7, (date_trunc('month', CURRENT_DATE) - INTERVAL '1 day')::date)", user.getId());
        assertEquals(3, appointments.getTrainingHoursThisMonth(user.getId()));
        assertTrue(appointments.deleteAppointment(saved.getId(), user.getId()));
        assertTrue(appointments.getAllAppointments(user.getId()).isEmpty());
    }

    @Test
    public void profilePersistsAcrossLoginAndCanClearOptionalFields() {
        UserDAO users = new UserDAO();
        User profile = new User();
        profile.setFullname("  Nguyễn Hồ Sơ  ");
        profile.setPhone("+84901234567");
        profile.setGender("female");
        profile.setDateOfBirth(LocalDate.of(2001, 5, 20));
        profile.setAddress("Quận 7, TP. Hồ Chí Minh");
        User saved = users.updateProfile(user.getId(), profile);
        assertEquals("Nguyễn Hồ Sơ", saved.getFullname());
        assertNull(saved.getPassword());
        User reloaded = users.checkLogin(email, "test-password");
        assertEquals("+84901234567", reloaded.getPhone());
        assertEquals("female", reloaded.getGender());
        assertEquals(LocalDate.of(2001, 5, 20), reloaded.getDateOfBirth());
        assertEquals("Quận 7, TP. Hồ Chí Minh", reloaded.getAddress());
        assertNotNull(reloaded.getCreatedAt());
        User blank = new User();
        blank.setFullname("Giữ họ tên");
        assertNotNull(users.updateProfile(user.getId(), blank));
        reloaded = users.findById(user.getId());
        assertNull(reloaded.getPhone());
        assertNull(reloaded.getGender());
        assertNull(reloaded.getDateOfBirth());
        assertNull(reloaded.getAddress());
    }

    @Test
    public void profileCannotChangeIdentityPasswordRoleOrAnotherAccount() {
        UserDAO users = new UserDAO();
        assertEquals("SUCCESS", users.registerUser(new User("Other account", peerEmail, "test-password")));
        User other = users.checkLogin(peerEmail, "test-password");
        User forged = new User(other.getId(), "Updated own name", "forged@example.invalid", "replacement");
        forged.setRole("ADMIN");
        User saved = users.updateProfile(user.getId(), forged);
        assertEquals(user.getId(), saved.getId());
        assertEquals(email, saved.getEmail());
        assertEquals("USER", saved.getRole());
        assertNotNull(users.checkLogin(email, "test-password"));
        assertNull(users.checkLogin(email, "replacement"));
        assertEquals("Other account", users.findById(other.getId()).getFullname());
        forged.setPhone("bad-number");
        try {
            users.updateProfile(user.getId(), forged);
            fail("Invalid profile must not be persisted.");
        } catch (IllegalArgumentException expected) {
            assertEquals("Updated own name", users.findById(user.getId()).getFullname());
        }
    }

    @Test
    public void disabledRentalAppointmentsAreRejectedAndOldRowsArePreserved() throws Exception {
        AppointmentDAO appointments = new AppointmentDAO();
        Appointment appointment = new Appointment();
        appointment.setUserId(user.getId());
        appointment.setTitle("Court reminder");
        appointment.setAppointmentDate(LocalDate.now().plusDays(2).toString());
        appointment.setAppointmentTime("09:30");
        appointment.setType("court");
        assertTrue(appointments.createAppointment(appointment));
        for (String type : new String[]{"gear", "clothing", "pt", "unknown", "", null}) {
            appointment.setType(type);
            assertFalse("Disabled type: " + type, appointments.createAppointment(appointment));
        }
        for (String type : new String[]{"gear", "clothing", "pt"}) {
            execute("INSERT INTO public.appointments (user_id, title, appointment_date, appointment_time, type) "
                    + "VALUES (?, 'Legacy rental', CURRENT_DATE + 2, '10:00', ?)", user.getId(), type);
        }
        assertEquals(1, appointments.countUpcoming(user.getId()));
        assertEquals(1, appointments.getUpcomingAppointments(user.getId()).size());
        assertEquals(1, appointments.getAllAppointments(user.getId()).size());
        assertEquals("court", appointments.getAllAppointments(user.getId()).get(0).getType());
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT id FROM public.appointments WHERE user_id = ? AND type <> 'court'")) {
            statement.setInt(1, user.getId());
            try (java.sql.ResultSet rows = statement.executeQuery()) {
                int preserved = 0;
                while (rows.next()) {
                    assertFalse(appointments.deleteAppointment(rows.getInt(1), user.getId()));
                    preserved++;
                }
                assertEquals(3, preserved);
            }
        }
    }

    @Test
    public void oldTrainerAndShopChatsAreHiddenWithoutDeletingTheirHistory() throws Exception {
        execute("INSERT INTO public.chat_sessions (user_id, partner_name, role_class, is_online) "
                + "VALUES (?, 'Legacy trainer', 'role-pt', false), (?, 'Legacy shop', 'role-shop', false)",
                user.getId(), user.getId());
        ChatDAO chat = new ChatDAO();
        chat.initializeDefaultSessions(user.getId());
        chat.initializeDefaultSessions(user.getId());
        List<ChatSession> sessions = chat.getUserChatSessions(user.getId());
        assertEquals(1, sessions.size());
        assertEquals("role-court", sessions.get(0).getRoleClass());
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT COUNT(*) FROM public.chat_sessions WHERE user_id = ?")) {
            statement.setInt(1, user.getId());
            try (java.sql.ResultSet rows = statement.executeQuery()) {
                assertTrue(rows.next());
                assertEquals(3, rows.getInt(1));
            }
        }
    }

    @Test
    public void chatUsesBooleanAndRetainsConfiguredHistory() throws Exception {
        UserDAO users = new UserDAO();
        assertEquals("SUCCESS", users.registerUser(new User("Bạn kiểm thử", peerEmail, "test-password")));
        User peer = users.checkLogin(peerEmail, "test-password");
        assertNotNull(peer);
        ChatDAO chat = new ChatDAO();
        chat.initializeDefaultSessions(user.getId());
        List<ChatSession> sessions = chat.getUserChatSessions(user.getId());
        assertEquals(1, sessions.size());
        assertEquals("role-court", sessions.get(0).getRoleClass());
        ChatSession session = sessions.stream().filter(ChatSession::isOnline).findFirst().orElseThrow();
        execute("INSERT INTO public.friend_messages (sender_id,receiver_id,message_text,created_at) "
                + "SELECT ?, ?, 'Seed ' || n, '10:00' FROM generate_series(0,489) n", user.getId(), peer.getId());
        for (int index = 0; index < 12; index++) {
            chat.saveMessage(session.getId(), "me", "Tin " + index, "10:30");
            chat.saveFriendMessage(user.getId(), peer.getId(), "Bạn " + index, "10:30");
        }
        List<ChatMessage> messages = chat.getUserChatSessions(user.getId()).stream()
                .filter(item -> item.getId() == session.getId()).findFirst().orElseThrow().getMessages();
        assertEquals(10, messages.size());
        assertEquals("Tin 2", messages.get(0).getText());
        List<ChatMessage> friends = chat.getFriendMessages(peer.getId(), user.getId());
        assertEquals(500, friends.size());
        assertEquals("Seed 2", friends.get(0).getText());
        assertEquals("Bạn 11", friends.get(499).getText());
    }

    @Test
    public void numberedCourtsCanShareTimeAndKeepAvailabilityUntilFull() {
        SportField field = new SportField(OWNER_ID, "Cụm bóng bàn", "TABLE_TENNIS", "Test address", "Mô tả",
                new BigDecimal("100000"), LocalTime.of(6, 0), LocalTime.of(22, 0), null, "ACTIVE");
        field.setQuantity(2);
        SportFieldDB.insert(field);
        LocalDateTime start = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")).plusDays(2).atTime(8, 0);
        assertEquals(BookingDB.CreateResult.CREATED, BookingDB.createCustomerBooking(field.getFieldId(), user.getId(),
                user.getFullname(), null, start, start.plusHours(1), 1));
        assertTrue(AvailabilityDB.getDay(field.getFieldId(), start.toLocalDate()).windows().stream()
                .anyMatch(w -> w.status().equals("FREE") && !w.startsAt().isAfter(start) && w.endsAt().isAfter(start)));
        assertEquals(BookingDB.CreateResult.CREATED, BookingDB.createCustomerBooking(field.getFieldId(), user.getId(),
                user.getFullname(), null, start, start.plusHours(1), 2));
        List<Booking> bookings = BookingDB.findByCustomerId(user.getId());
        assertEquals(2, bookings.size());
        for (Booking booking : bookings) assertEquals(BookingDB.StatusChangeResult.UPDATED,
                BookingDB.changeStatus(booking.getBookingId(), OWNER_ID, "CONFIRMED"));
        assertTrue(AvailabilityDB.getDay(field.getFieldId(), start.toLocalDate()).windows().stream()
                .anyMatch(w -> w.status().equals("BOOKED") && w.startsAt().equals(start)));
        assertEquals(BookingDB.CreateResult.CONFLICT, BookingDB.createCustomerBooking(field.getFieldId(), user.getId(),
                user.getFullname(), null, start, start.plusHours(1)));
        assertTrue(new PostDAO().createPost(user.getId(), "Tìm người chơi bóng bàn", bookings.get(0).getBookingId(), "TIM_DOI"));
        Post post = new PostDAO().getAllPosts(user.getId()).stream().filter(p -> p.getUserId()==user.getId()).findFirst().orElseThrow();
        assertEquals(bookings.get(0).getBookingId(), post.getBookingId());
        assertEquals(2, post.getFieldQuantity().intValue());
    }

    @Test
    public void sequentialBookingsOnOneCourtDoNotConsumeASecondCourt() throws Exception {
        SportField field = new SportField(OWNER_ID, "Hai sân con", "PICKLEBALL", "Test address", "Mô tả",
                new BigDecimal("100000"), LocalTime.of(6, 0), LocalTime.of(22, 0), null, "ACTIVE");
        field.setQuantity(2); SportFieldDB.insert(field);
        LocalDateTime start = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")).plusDays(2).atTime(8, 0);
        for (int hour=0; hour<2; hour++) assertEquals(BookingDB.CreateResult.CREATED,
                BookingDB.createCustomerBooking(field.getFieldId(),user.getId(),user.getFullname(),null,
                        start.plusHours(hour),start.plusHours(hour+1),1));
        assertEquals(BookingDB.CreateResult.CREATED, BookingDB.createCustomerBooking(field.getFieldId(),user.getId(),
                user.getFullname(),null,start,start.plusHours(2),2));
        assertEquals(BookingDB.CreateResult.INVALID_TIME, BookingDB.createCustomerBooking(field.getFieldId(),user.getId(),
                user.getFullname(),null,start.plusHours(3),start.plusHours(4),3));
        for (int index=0; index<2; index++) execute("INSERT INTO public.bookings "
                + "(field_id,customer_name,starts_at,ends_at,total_price,status,court_number) VALUES (?, 'Legacy request', ?, ?, 100000, 'PENDING', 1)",
                field.getFieldId(), start.plusHours(4), start.plusHours(5));
        assertTrue(AvailabilityDB.getDay(field.getFieldId(),start.toLocalDate()).windows().stream()
                .anyMatch(w -> w.status().equals("FREE") && !w.startsAt().isAfter(start.plusHours(4)) && w.endsAt().isAfter(start.plusHours(4))));
        assertEquals(BookingDB.CreateResult.CREATED, BookingDB.createCustomerBooking(field.getFieldId(),user.getId(),
                user.getFullname(),null,start.plusHours(4),start.plusHours(5),2));
    }

    @Test
    public void jdbcFieldsAndJpaBookingsShareDatabaseAndPreserveDecimals() {
        SportField field = new SportField(OWNER_ID, "PG compatibility field", "GYM", "Test address", "Mô tả",
                new BigDecimal("80000.00"), LocalTime.of(6, 0), LocalTime.of(22, 0), null, "ACTIVE");
        SportFieldDAO fields = new SportFieldDAO();
        fields.insert(field);
        field = fields.findByOwnerId(OWNER_ID).get(0);
        field.setPricePerHour(new BigDecimal("90000.25"));
        assertTrue(fields.update(field, OWNER_ID));
        assertTrue(fields.toggleStatus(field.getFieldId(), OWNER_ID));
        assertEquals("INACTIVE", SportFieldDB.findById(field.getFieldId()).getStatus());
        assertTrue(fields.toggleStatus(field.getFieldId(), OWNER_ID));
        LocalDateTime start = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")).plusDays(2).atTime(8, 0);
        assertEquals(BookingDB.CreateResult.CREATED, BookingDB.createCustomerBooking(
                field.getFieldId(), user.getId(), user.getFullname(), null, start, start.plusHours(1)));
        Booking booking = BookingDB.findByCustomerId(user.getId()).get(0);
        assertEquals(new BigDecimal("90000.25"), booking.getTotalPrice());
        assertTrue(BookingDB.cancelByCustomer(booking.getBookingId(), user.getId()));
        assertFalse(BookingDB.cancelByCustomer(booking.getBookingId(), user.getId()));
        assertEquals(BookingDB.CreateResult.CREATED, BookingDB.createCustomerBooking(
                field.getFieldId(), user.getId(), user.getFullname(), null, start, start.plusHours(1)));
        booking = BookingDB.findByCustomerId(user.getId()).get(0);
        assertEquals(BookingDB.StatusChangeResult.UPDATED,
                BookingDB.changeStatus(booking.getBookingId(), OWNER_ID, "CONFIRMED"));
        assertEquals(BookingDB.CreateResult.CONFLICT, BookingDB.createCustomerBooking(
                field.getFieldId(), user.getId(), user.getFullname(), null, start, start.plusHours(1)));
    }

    private static void execute(String sql, Object... parameters) throws Exception {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            for (int index = 0; index < parameters.length; index++) statement.setObject(index + 1, parameters[index]);
            statement.executeUpdate();
        }
    }
}
