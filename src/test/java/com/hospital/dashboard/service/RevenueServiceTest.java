package com.hospital.dashboard.service;

import com.hospital.dashboard.model.HospitalStay;
import com.hospital.dashboard.repository.HospitalStayRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.Collections;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class RevenueServiceTest {

    @Mock
    private HospitalStayRepository stayRepository;

    @InjectMocks
    private RevenueService revenueService;

    @Test
    void testCalculateTotalRevenue_Empty() {
        when(stayRepository.findAll()).thenReturn(Collections.emptyList());
        BigDecimal total = revenueService.calculateTotalRevenue();
        assertEquals(BigDecimal.ZERO, total);
    }

    @Test
    void testCalculateTotalRevenue_WithData() {
        HospitalStay stay1 = new HospitalStay();
        stay1.setStartDate(LocalDate.of(2023, 1, 1));
        stay1.setEndDate(LocalDate.of(2023, 1, 5)); // 4 days
        stay1.setDailyRate(BigDecimal.valueOf(100));

        HospitalStay stay2 = new HospitalStay();
        stay2.setStartDate(LocalDate.of(2023, 2, 1));
        stay2.setEndDate(LocalDate.of(2023, 2, 1)); // 0 days -> 1 day min
        stay2.setDailyRate(BigDecimal.valueOf(200));

        // Null checks
        HospitalStay stay3 = new HospitalStay();

        when(stayRepository.findAll()).thenReturn(Arrays.asList(stay1, stay2, stay3));

        BigDecimal total = revenueService.calculateTotalRevenue();

        // Stay1: 4 * 100 = 400
        // Stay2: 1 * 200 = 200
        // Stay3: 0
        // Total: 600
        assertEquals(BigDecimal.valueOf(600), total);
    }
}
