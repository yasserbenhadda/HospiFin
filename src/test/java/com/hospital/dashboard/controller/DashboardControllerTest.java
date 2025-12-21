package com.hospital.dashboard.controller;

import com.hospital.dashboard.service.DashboardService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(DashboardController.class)
class DashboardControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private DashboardService dashboardService;

    @Test
    void testGetDashboardSummary() throws Exception {
        Map<String, Object> summary = new HashMap<>();
        summary.put("totalRealCost", BigDecimal.valueOf(5000));
        given(dashboardService.getDashboardSummary()).willReturn(summary);

        mockMvc.perform(get("/api/dashboard/summary"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalRealCost").value(5000));
    }
}
