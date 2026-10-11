package com.sportify.data;

import org.junit.Test;

public class CustomerDBValidationTest {

    @Test(expected = IllegalArgumentException.class)
    public void rejectsMissingOwnerBeforeOpeningConnection() {
        CustomerDB.findByOwnerId(null, "");
    }

    @Test(expected = IllegalArgumentException.class)
    public void rejectsInvalidOwnerForSummary() {
        CustomerDB.getSummaryByOwnerId(0L);
    }

    @Test(expected = IllegalArgumentException.class)
    public void rejectsOversizedSearchBeforeOpeningConnection() {
        char[] oversized = new char[101];
        java.util.Arrays.fill(oversized, 'a');
        CustomerDB.findByOwnerId(1L, new String(oversized));
    }
}
