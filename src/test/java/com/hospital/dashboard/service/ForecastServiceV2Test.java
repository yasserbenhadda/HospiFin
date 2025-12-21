package com.hospital.dashboard.service;

import com.hospital.dashboard.model.Consumable;
import com.hospital.dashboard.model.HospitalStay;
import com.hospital.dashboard.model.MedicalAct;
import com.hospital.dashboard.model.Personnel;
import com.hospital.dashboard.repository.ConsumableRepository;
import com.hospital.dashboard.repository.HospitalStayRepository;
import com.hospital.dashboard.repository.MedicalActRepository;
import com.hospital.dashboard.repository.PersonnelRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.Collections;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ForecastServiceV2Test {

    @Mock
    private MedicalActRepository medicalActRepository;

    @Mock
    private ConsumableRepository consumableRepository;

    @Mock
    private HospitalStayRepository stayRepository;

    @Mock
    private PersonnelRepository personnelRepository;
    @Mock
    private RevenueService revenueService;

    @InjectMocks
    private ForecastServiceV2 forecastService;

    @Test
    void testGetGlobalForecast_EmptyData() {
        when(medicalActRepository.findAll()).thenReturn(Collections.emptyList());
        when(consumableRepository.findAll()).thenReturn(Collections.emptyList());
        when(stayRepository.findAll()).thenReturn(Collections.emptyList());
        when(personnelRepository.findAll()).thenReturn(Collections.emptyList());

        Map<String, Object> result = forecastService.getGlobalForecast(30);

        assertNotNull(result);
        assertEquals(BigDecimal.ZERO, result.get("globalTotal"));
        // Personnel cost is zero, so global total should be zero
    }

    @Test
    void testGetGlobalForecast_WithData() {
        // Mock Personnel (Fixed Cost)
        Personnel p = new Personnel();
        p.setCostPerDay(BigDecimal.valueOf(100));
        when(personnelRepository.findAll()).thenReturn(Arrays.asList(p));

        // Mock Medical Act - Need at least 2 points for regression
        MedicalAct act1 = new MedicalAct();
        act1.setDate(LocalDate.now().minusMonths(2));
        act1.setCost(BigDecimal.valueOf(200));

        MedicalAct act2 = new MedicalAct();
        act2.setDate(LocalDate.now().minusMonths(1));
        act2.setCost(BigDecimal.valueOf(220));

        when(medicalActRepository.findAll()).thenReturn(Arrays.asList(act1, act2));

        // Mock Consumable
        Consumable cons1 = new Consumable();
        cons1.setDate(LocalDate.now().minusMonths(2));
        cons1.setTotalCost(BigDecimal.valueOf(50));

        Consumable cons2 = new Consumable();
        cons2.setDate(LocalDate.now().minusMonths(1));
        cons2.setTotalCost(BigDecimal.valueOf(55));

        when(consumableRepository.findAll()).thenReturn(Arrays.asList(cons1, cons2));

        // Mock Stay
        HospitalStay stay1 = new HospitalStay();
        stay1.setStartDate(LocalDate.now().minusMonths(2));
        stay1.setEndDate(LocalDate.now().minusMonths(2).plusDays(2));
        stay1.setDailyRate(BigDecimal.valueOf(300));

        HospitalStay stay2 = new HospitalStay();
        stay2.setStartDate(LocalDate.now().minusMonths(1));
        stay2.setEndDate(LocalDate.now().minusMonths(1).plusDays(2));
        stay2.setDailyRate(BigDecimal.valueOf(300));

        when(stayRepository.findAll()).thenReturn(Arrays.asList(stay1, stay2));
        when(revenueService.calculateStayRevenue(stay1)).thenReturn(BigDecimal.valueOf(600));
        when(revenueService.calculateStayRevenue(stay2)).thenReturn(BigDecimal.valueOf(600));

        Map<String, Object> result = forecastService.getGlobalForecast(30);

        assertNotNull(result);
        BigDecimal globalTotal = (BigDecimal) result.get("globalTotal");

        // Expected: 200 (Act) + 50 (Cons) + 600 (Stay: 300*2) + 100*30 (Personnel) =
        // 850 + 3000 = 3850
        // Use verify or approximate check
        assertTrue(globalTotal.compareTo(BigDecimal.valueOf(3000)) > 0);
    }
}
