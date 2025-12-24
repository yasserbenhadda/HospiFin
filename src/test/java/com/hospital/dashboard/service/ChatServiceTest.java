package com.hospital.dashboard.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.math.BigDecimal;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ChatServiceTest {

    @Mock
    private ForecastServiceV2 forecastService; // Still needed if referenced in ChatService though technically deeper
                                               // mock

    @Mock
    private OpenAiService openAiService;

    @Mock
    private com.hospital.dashboard.repository.PatientRepository patientRepository;
    @Mock
    private com.hospital.dashboard.repository.MedicationRepository medicationRepository;
    @Mock
    private com.hospital.dashboard.repository.MedicalActRepository medicalActRepository;
    @Mock
    private com.hospital.dashboard.repository.HospitalStayRepository hospitalStayRepository;
    @Mock
    private com.hospital.dashboard.repository.ConsumableRepository consumableRepository;
    @Mock
    private com.hospital.dashboard.repository.PersonnelRepository personnelRepository;

    @InjectMocks
    private ChatService chatService;

    @BeforeEach
    void setUp() {
        // No reflection needed for restTemplate anymore
        // Values can be set if used directly, but they seem to be in OpenAiService now
        // or used for prompting
        ReflectionTestUtils.setField(chatService, "apiKey", "test-key");
        ReflectionTestUtils.setField(chatService, "baseUrl", "http://api.test");
        ReflectionTestUtils.setField(chatService, "modelName", "gpt-test");
    }

    @Test
    @SuppressWarnings("null")
    void testChat_Success() {
        // Mock ForecastService returning a Map structure expected by
        // getFinancialContext
        Map<String, Object> forecast = new HashMap<>();
        forecast.put("globalTotal", BigDecimal.TEN);
        forecast.put("globalPrediction", BigDecimal.ONE);
        when(forecastService.getGlobalForecast(anyInt())).thenReturn(forecast);

        // Mock OpenAiService response
        when(openAiService.getChatResponse(anyString(), anyString())).thenReturn("Hello, this is AI.");

        String result = chatService.chat("Hello");
        assertEquals("Hello, this is AI.", result);
    }

    @Test
    @SuppressWarnings("null")
    void testChat_Failure() {
        // Mock ForecastService returning basic map
        when(forecastService.getGlobalForecast(anyInt())).thenReturn(new HashMap<>());

        // Mock OpenAiService failure response
        when(openAiService.getChatResponse(anyString(), anyString())).thenReturn("Error from AI");

        String result = chatService.chat("Hello");
        assertEquals("Error from AI", result);
    }
}
