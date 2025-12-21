package com.hospital.dashboard.controller;

import com.hospital.dashboard.model.HospitalStay;
import com.hospital.dashboard.repository.HospitalStayRepository;
import com.hospital.dashboard.service.RevenueService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(StayController.class)
class StayControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private HospitalStayRepository stayRepository;

    @MockBean
    private RevenueService revenueService;

    @Test
    void testGetAllStays() throws Exception {
        HospitalStay s = new HospitalStay();
        s.setPathology("Flu");
        given(stayRepository.findAll()).willReturn(Arrays.asList(s));

        mockMvc.perform(get("/api/stays"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].pathology").value("Flu"));
    }

    @Test
    void testCreateStay() throws Exception {
        HospitalStay s = new HospitalStay();
        s.setPathology("Fracture");
        given(stayRepository.save(any(HospitalStay.class))).willReturn(s);

        mockMvc.perform(post("/api/stays")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"pathology\": \"Fracture\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.pathology").value("Fracture"));
    }

    @Test
    void testUpdateStay() throws Exception {
        HospitalStay existing = new HospitalStay();
        existing.setId(1L);
        existing.setPathology("Old");

        HospitalStay updated = new HospitalStay();
        updated.setId(1L);
        updated.setPathology("New");

        given(stayRepository.findById(1L)).willReturn(Optional.of(existing));
        given(stayRepository.save(any(HospitalStay.class))).willReturn(updated);

        mockMvc.perform(put("/api/stays/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"pathology\": \"New\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.pathology").value("New"));
    }

    @Test
    void testDeleteStay() throws Exception {
        mockMvc.perform(delete("/api/stays/1"))
                .andExpect(status().isOk());
        verify(stayRepository).deleteById(1L);
    }

    @Test
    void testGetTotalRevenue() throws Exception {
        given(revenueService.calculateTotalRevenue()).willReturn(BigDecimal.valueOf(1000));

        mockMvc.perform(get("/api/stays/revenue"))
                .andExpect(status().isOk())
                .andExpect(content().string("1000"));
    }
}
