package com.hospital.dashboard.controller;

import com.hospital.dashboard.model.Medication;
import com.hospital.dashboard.repository.MedicationRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(MedicationController.class)
class MedicationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private MedicationRepository medicationRepository;

    @Test
    void testGetAllMedications() throws Exception {
        Medication m = new Medication();
        m.setName("Paracetamol");
        given(medicationRepository.findAll()).willReturn(Arrays.asList(m));

        mockMvc.perform(get("/api/medications"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].name").value("Paracetamol"));
    }

    @Test
    void testCreateMedication() throws Exception {
        Medication m = new Medication();
        m.setName("Ibuprofen");
        given(medicationRepository.save(any(Medication.class))).willReturn(m);

        mockMvc.perform(post("/api/medications")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"name\": \"Ibuprofen\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Ibuprofen"));
    }

    @Test
    void testUpdateMedication() throws Exception {
        Medication existing = new Medication();
        existing.setId(1L);
        existing.setName("Old");

        Medication updated = new Medication();
        updated.setId(1L);
        updated.setName("New");

        given(medicationRepository.findById(1L)).willReturn(Optional.of(existing));
        given(medicationRepository.save(any(Medication.class))).willReturn(updated);

        mockMvc.perform(put("/api/medications/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"name\": \"New\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("New"));
    }

    @Test
    void testDeleteMedication() throws Exception {
        mockMvc.perform(delete("/api/medications/1"))
                .andExpect(status().isOk());
        verify(medicationRepository).deleteById(1L);
    }
}
