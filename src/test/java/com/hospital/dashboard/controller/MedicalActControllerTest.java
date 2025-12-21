package com.hospital.dashboard.controller;

import com.hospital.dashboard.model.MedicalAct;
import com.hospital.dashboard.repository.MedicalActRepository;
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
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(MedicalActController.class)
class MedicalActControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private MedicalActRepository medicalActRepository;

    @Test
    void testGetAllMedicalActs() throws Exception {
        MedicalAct act = new MedicalAct();
        act.setType("Surgery");
        given(medicalActRepository.findAll()).willReturn(Arrays.asList(act));

        mockMvc.perform(get("/api/medical-acts"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].type").value("Surgery"));
    }

    @Test
    void testCreateMedicalAct() throws Exception {
        MedicalAct act = new MedicalAct();
        act.setType("Consultation");
        given(medicalActRepository.save(any(MedicalAct.class))).willReturn(act);

        mockMvc.perform(post("/api/medical-acts")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"type\": \"Consultation\", \"cost\": 50.0}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.type").value("Consultation"));
    }

    @Test
    void testUpdateMedicalAct() throws Exception {
        MedicalAct existing = new MedicalAct();
        existing.setId(1L);
        existing.setType("Old Type");

        MedicalAct updated = new MedicalAct();
        updated.setId(1L);
        updated.setType("New Type");

        given(medicalActRepository.findById(1L)).willReturn(Optional.of(existing));
        given(medicalActRepository.save(any(MedicalAct.class))).willReturn(updated);

        mockMvc.perform(put("/api/medical-acts/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"type\": \"New Type\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.type").value("New Type"));
    }

    @Test
    void testDeleteMedicalAct() throws Exception {
        mockMvc.perform(delete("/api/medical-acts/1"))
                .andExpect(status().isOk());

        verify(medicalActRepository).deleteById(1L);
    }
}
