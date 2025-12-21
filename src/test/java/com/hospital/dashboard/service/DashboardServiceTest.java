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
import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class DashboardServiceTest {

    @Mock
    private HospitalStayRepository stayRepository;
    @Mock
    private MedicalActRepository medicalActRepository;
    @Mock
    private ConsumableRepository consumableRepository;
    @Mock
    private PersonnelRepository personnelRepository;
    @Mock
    private ForecastServiceV2 forecastService;
    @Mock
    private RevenueService revenueService;

    @InjectMocks
    private DashboardService dashboardService;

    @Test
    void testGetDashboardSummary() {
        // Mock Data
        Personnel p = new Personnel();
        p.setCostPerDay(BigDecimal.valueOf(100));
        when(personnelRepository.findAll()).thenReturn(Arrays.asList(p));

        MedicalAct act = new MedicalAct();
        act.setDate(LocalDate.now());
        act.setCost(BigDecimal.valueOf(200));
        when(medicalActRepository.findAll()).thenReturn(Arrays.asList(act));

        Consumable cons = new Consumable();
        cons.setDate(LocalDate.now());
        cons.setTotalCost(BigDecimal.valueOf(50));
        when(consumableRepository.findAll()).thenReturn(Arrays.asList(cons));

        HospitalStay stay = new HospitalStay();
        stay.setStartDate(LocalDate.now().minusDays(1));
        stay.setEndDate(LocalDate.now().plusDays(1));
        stay.setDailyRate(BigDecimal.valueOf(300));

        // Fix NPE: Add Patient
        com.hospital.dashboard.model.Patient patient = new com.hospital.dashboard.model.Patient();
        patient.setFirstName("John");
        patient.setLastName("Doe");
        stay.setPatient(patient);
        stay.setPathology("Test Path");

        when(stayRepository.findAll()).thenReturn(Arrays.asList(stay));
        when(revenueService.calculateStayRevenue(stay)).thenReturn(BigDecimal.valueOf(600));

        // Mock Forecast
        Map<String, Object> forecast = new HashMap<>();
        forecast.put("globalPrediction", BigDecimal.valueOf(10000));
        when(forecastService.getGlobalForecast(anyInt())).thenReturn(forecast);

        Map<String, Object> summary = dashboardService.getDashboardSummary();

        assertNotNull(summary);
        assertTrue(summary.containsKey("totalRealCost"));
        assertTrue(summary.containsKey("totalPredictedCost"));
        assertEquals(BigDecimal.valueOf(10000.00).setScale(2), summary.get("totalPredictedCost"));
    }
}
