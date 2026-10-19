package com.sportify.data;

import org.junit.Test;

public class BookingDBValidationTest {
    @Test(expected = IllegalArgumentException.class)
    public void rejectsMissingOwner() { BookingDB.findByOwnerId(null); }

    @Test(expected = IllegalArgumentException.class)
    public void rejectsInvalidBookingId() { BookingDB.changeStatus(0L, 1L, "CONFIRMED"); }

    @Test(expected = IllegalArgumentException.class)
    public void rejectsUnsupportedTransition() { BookingDB.changeStatus(1L, 1L, "PAID"); }

    @Test(expected = IllegalArgumentException.class)
    public void rejectsMissingStatisticsDate() { BookingDB.getDashboardSummary(1L, null); }
}
