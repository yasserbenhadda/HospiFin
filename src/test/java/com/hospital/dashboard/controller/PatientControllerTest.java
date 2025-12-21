package com.hospital.dashboard.controller;

import com.hospital.dashboard.model.Patient;
import com.hospital.dashboard.repository.PatientRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(PatientController.class)
class PatientControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private PatientRepository patientRepository;

    @Test
    void testGetAllPatients() throws Exception {
        Patient p = new Patient();
        p.setFirstName("Alice");
        given(patientRepository.findAll()).willReturn(Arrays.asList(p));

        mockMvc.perform(get("/api/patients"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].firstName").value("Alice"));
    }

    @Test
    void testGetPatientById() throws Exception {
        Patient p = new Patient();
        p.setId(1L);
        p.setLastName("Smith");
        given(patientRepository.findById(1L)).willReturn(Optional.of(p));

        mockMvc.perform(get("/api/patients/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.lastName").value("Smith"));
    }

    @Test
    void testCreatePatient() throws Exception {
        Patient p = new Patient();
        p.setFirstName("Bob");
        given(patientRepository.save(any(Patient.class))).willReturn(p);

        mockMvc.perform(post("/api/patients")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"firstName\": \"Bob\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.firstName").value("Bob"));
    }

    @Test
    void testUpdatePatient() throws Exception {
        Patient existing = new Patient();
        existing.setId(1L);
        existing.setFirstName("Old");

        Patient updated = new Patient();
        updated.setId(1L);
        updated.setFirstName("New");

        given(patientRepository.findById(1L)).willReturn(Optional.of(existing));
        given(patientRepository.save(any(Patient.class))).willReturn(updated);

        mockMvc.perform(put("/api/patients/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"firstName\": \"New\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.firstName").value("New"));
    }

    @Test
    void testDeletePatient() throws Exception {
        mockMvc.perform(delete("/api/patients/1"))
                .andExpect(status().isOk());

        verify(patientRepository).deleteById(1L);
    }
}
