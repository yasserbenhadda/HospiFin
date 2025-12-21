package com.hospital.dashboard.controller;

import com.hospital.dashboard.model.Consumable;
import com.hospital.dashboard.repository.ConsumableRepository;
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

@WebMvcTest(ConsumableController.class)
class ConsumableControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ConsumableRepository consumableRepository;

    @Test
    void testGetAllConsumables() throws Exception {
        Consumable c = new Consumable();
        com.hospital.dashboard.model.Medication m = new com.hospital.dashboard.model.Medication();
        m.setName("Aspirin");
        c.setMedication(m);
        given(consumableRepository.findAll()).willReturn(Arrays.asList(c));

        mockMvc.perform(get("/api/consumables"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].medication.name").value("Aspirin"));
    }

    @Test
    void testCreateConsumable() throws Exception {
        Consumable c = new Consumable();
        com.hospital.dashboard.model.Medication m = new com.hospital.dashboard.model.Medication();
        m.setName("Bandage");
        c.setMedication(m);
        given(consumableRepository.save(any(Consumable.class))).willReturn(c);

        mockMvc.perform(post("/api/consumables")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"medication\": {\"name\": \"Bandage\"}}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.medication.name").value("Bandage"));
    }

    @Test
    void testUpdateConsumable() throws Exception {
        Consumable existing = new Consumable();
        existing.setId(1L);
        com.hospital.dashboard.model.Medication mOld = new com.hospital.dashboard.model.Medication();
        mOld.setName("Old");
        existing.setMedication(mOld);

        Consumable updated = new Consumable();
        updated.setId(1L);
        com.hospital.dashboard.model.Medication mNew = new com.hospital.dashboard.model.Medication();
        mNew.setName("New");
        updated.setMedication(mNew);

        given(consumableRepository.findById(1L)).willReturn(Optional.of(existing));
        given(consumableRepository.save(any(Consumable.class))).willReturn(updated);

        mockMvc.perform(put("/api/consumables/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"medication\": {\"name\": \"New\"}}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.medication.name").value("New"));
    }

    @Test
    void testDeleteConsumable() throws Exception {
        mockMvc.perform(delete("/api/consumables/1"))
                .andExpect(status().isOk());

        verify(consumableRepository).deleteById(1L);
    }
}
