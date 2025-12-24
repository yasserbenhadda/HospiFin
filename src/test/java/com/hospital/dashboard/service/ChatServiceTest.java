package com.hospital.dashboard.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ChatServiceTest {

    @Mock
    private ForecastServiceV2 forecastService;

    @Mock
    private RestTemplate restTemplate;

    @InjectMocks
    private ChatService chatService;

    @BeforeEach
    void setUp() {
        // Set values for @Value fields
        ReflectionTestUtils.setField(chatService, "apiKey", "test-key");
        ReflectionTestUtils.setField(chatService, "baseUrl", "http://api.test");
        ReflectionTestUtils.setField(chatService, "modelName", "gpt-test");

        // Ensure the RestTemplate mock is injected (in case InjectMocks failed due to
        // existing instance)
        ReflectionTestUtils.setField(chatService, "restTemplate", restTemplate);
    }

    @Test
    @SuppressWarnings("null")
    void testChat_Success() {
        // Mock ForecastService with DEEP structure for getFinancialContext
        Map<String, Object> forecast = new HashMap<>();
        forecast.put("globalTotal", BigDecimal.valueOf(1000));
        forecast.put("globalPrediction", BigDecimal.valueOf(1200));

        // Mock Methodology & Seasonality
        Map<String, Object> medicalActs = new HashMap<>();
        Map<String, Object> methodology = new HashMap<>();
        methodology.put("slope", 150.5);
        Map<java.time.DayOfWeek, Double> seasonality = new HashMap<>();
        seasonality.put(java.time.DayOfWeek.MONDAY, 1.2);
        seasonality.put(java.time.DayOfWeek.SUNDAY, 0.8);
        methodology.put("seasonality", seasonality);
        medicalActs.put("methodology", methodology);
        forecast.put("medicalActs", medicalActs);

        // Mock History for Predictions
        List<Map<String, Object>> history = new ArrayList<>();
        Map<String, Object> futurePoint = new HashMap<>();
        futurePoint.put("isPrediction", true);
        futurePoint.put("month", "2023-12-01");
        futurePoint.put("predicted", BigDecimal.valueOf(100));
        history.add(futurePoint);
        forecast.put("history", history);

        when(forecastService.getGlobalForecast(7)).thenReturn(forecast);

        // Mock OpenAI Response
        Map<String, Object> responseBody = new HashMap<>();
        Map<String, Object> choice = new HashMap<>();
        Map<String, Object> message = new HashMap<>();
        message.put("content", "Hello, this is AI.");
        choice.put("message", message);
        responseBody.put("choices", Collections.singletonList(choice));

        ResponseEntity<Map> responseEntity = ResponseEntity.ok(responseBody);

        when(restTemplate.exchange(anyString(), eq(HttpMethod.POST), any(HttpEntity.class), eq(Map.class)))
                .thenReturn(responseEntity);

        String result = chatService.chat("Hello");
        assertEquals("Hello, this is AI.", result);
    }

    @Test
    @SuppressWarnings("null")
    void testChat_Failure() {
        // Mock ForecastService
        when(forecastService.getGlobalForecast(7)).thenReturn(new HashMap<>());

        // Mock OpenAI Exception
        when(restTemplate.exchange(anyString(), eq(HttpMethod.POST), any(HttpEntity.class), eq(Map.class)))
                .thenThrow(new RuntimeException("API Down"));

        String result = chatService.chat("Hello");
        assertTrue(result.contains("Erreur de connexion"));
    }
}
