package com.sportify.data;

import org.junit.Test;
import java.time.LocalDateTime;
import java.util.List;
import static org.junit.Assert.*;

public class AvailabilityRulesTest {
    @Test public void currentMinuteIsNotAdvertisedAsBookable() {
        LocalDateTime open = LocalDateTime.of(2030, 1, 1, 6, 0), close = open.withHour(22);
        List<AvailabilityDB.Window> windows = AvailabilityDB.buildWindows(open, close, true, List.of(), List.of(), open.withHour(10).withMinute(20).withSecond(30));
        assertEquals("PAST", windows.get(0).status());
        assertEquals(open.withHour(10).withMinute(21), windows.get(1).startsAt());
        assertEquals("FREE", windows.get(1).status());
    }
    @Test public void inactiveFieldDoesNotAdvertiseFreeWindows() {
        LocalDateTime open = LocalDateTime.of(2030, 1, 1, 6, 0);
        List<AvailabilityDB.Window> windows = AvailabilityDB.buildWindows(open, open.withHour(22), false, List.of(), List.of(), open.minusDays(1));
        assertEquals(1, windows.size()); assertEquals("INACTIVE", windows.get(0).status());
    }
}
