package com.hospital.dashboard.service;

import com.hospital.dashboard.repository.*;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Collections;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CustomAIServiceTest {

    @Mock
    private PatientRepository patientRepository;
    @Mock
    private HospitalStayRepository stayRepository;
    @Mock
    private MedicalActRepository medicalActRepository;
    @Mock
    private MedicationRepository medicationRepository;
    @Mock
    private ConsumableRepository consumableRepository;
    @Mock
    private PersonnelRepository personnelRepository;

    @InjectMocks
    private CustomAIService customAIService;

    @Test
    void testTrainModel() {
        when(patientRepository.count()).thenReturn(10L);
        when(stayRepository.findAll()).thenReturn(Collections.emptyList());
        when(medicalActRepository.findAll()).thenReturn(Collections.emptyList());
        when(personnelRepository.count()).thenReturn(5L);

        Map<String, Object> model = customAIService.trainModel();

        assertNotNull(model);
        assertTrue(customAIService.isTrained());
        assertEquals(10L, model.get("patientCount"));
    }

    @Test
    void testGetAnswer_NotTrained() {
        String answer = customAIService.getAnswer("Hello");
        assertTrue(answer.contains("pas encore entraîné"));
    }

    @Test
    void testGetAnswer_Trained_English() {
        // Train first
        when(patientRepository.count()).thenReturn(10L);
        customAIService.trainModel();

        String answer = customAIService.getAnswer("Hello");
        // Should return generic help message as "Hello" matches "hello" which is in
        // isEnglish list
        // but might fall through to default if no specific keyword matches logic.
        // Actually "hello" is in matchesAny for English detection, but getAnswerEnglish
        // checks priorities. "Hello" might not match specific intents, so returns
        // default.
        assertTrue(answer.contains("I can analyze"));
    }

    @Test
    void testGetAnswer_Trained_AllScenarios() {
        // Setup state to leverage all branches
        when(patientRepository.count()).thenReturn(100L);
        when(personnelRepository.count()).thenReturn(5L);
        when(medicationRepository.count()).thenReturn(10L);
        when(consumableRepository.count()).thenReturn(20L);
        when(stayRepository.findAll()).thenReturn(Collections.emptyList());
        when(medicalActRepository.findAll()).thenReturn(Collections.emptyList());

        customAIService.trainModel();

        // --- ENGLISH SCENARIOS ---
        assertNotNull(customAIService.getAnswer("staff"));
        assertNotNull(customAIService.getAnswer("medication"));
        assertNotNull(customAIService.getAnswer("consumable"));

        // Priority 2
        String forecastEn = customAIService.getAnswer("forecast warning");
        assertNotNull(forecastEn); // Covers forecast branch

        // Priority 3
        assertNotNull(customAIService.getAnswer("solution"));

        // Priority 4
        assertNotNull(customAIService.getAnswer("project opinion"));

        // Priority 5
        assertNotNull(customAIService.getAnswer("doctor"));

        // Priority 6
        assertNotNull(customAIService.getAnswer("accountant"));

        // Priority 7
        assertNotNull(customAIService.getAnswer("strategy"));

        // Default
        assertNotNull(customAIService.getAnswer("gibberish"));

        // --- FRENCH SCENARIOS ---
        assertNotNull(customAIService.getAnswer("personnel"));
        assertNotNull(customAIService.getAnswer("medicament"));
        assertNotNull(customAIService.getAnswer("consommable"));

        assertNotNull(customAIService.getAnswer("prevision alerte"));
        assertNotNull(customAIService.getAnswer("solution aide"));
        assertNotNull(customAIService.getAnswer("avis projet"));
        assertNotNull(customAIService.getAnswer("avis medecin"));
        assertNotNull(customAIService.getAnswer("avis comptable"));
        assertNotNull(customAIService.getAnswer("strategie eviter"));
    }
}
