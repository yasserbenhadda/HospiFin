package com.hospital.dashboard.controller;

import com.hospital.dashboard.model.Personnel;
import com.hospital.dashboard.repository.PersonnelRepository;
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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(PersonnelController.class)
class PersonnelControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private PersonnelRepository personnelRepository;

    @Test
    void testGetAllPersonnel() throws Exception {
        Personnel p1 = new Personnel();
        p1.setName("John Doe");
        given(personnelRepository.findAll()).willReturn(Arrays.asList(p1));

        mockMvc.perform(get("/api/personnel"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].name").value("John Doe"));
    }

    @Test
    void testCreatePersonnel() throws Exception {
        Personnel p1 = new Personnel();
        p1.setName("Jane Doe");
        given(personnelRepository.save(any(Personnel.class))).willReturn(p1);

        mockMvc.perform(post("/api/personnel")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"name\": \"Jane Doe\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Jane Doe"));
    }

    @Test
    void testGetCurrentPersonnel() throws Exception {
        Personnel p1 = new Personnel();
        p1.setId(1L);
        p1.setName("Sophie Martin");
        given(personnelRepository.findById(1L)).willReturn(Optional.of(p1));

        mockMvc.perform(get("/api/personnel/current"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Sophie Martin"));
    }
}
