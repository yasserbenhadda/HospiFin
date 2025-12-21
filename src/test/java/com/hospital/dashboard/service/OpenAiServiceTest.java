package com.hospital.dashboard.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class OpenAiServiceTest {

    @Mock
    private RestTemplate restTemplate;

    @InjectMocks
    private OpenAiService openAiService;

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(openAiService, "apiKey", "test-key");
    }

    @Test
    void testGetChatResponse_Success() {
        Map<String, Object> responseBody = new HashMap<>();
        Map<String, Object> choice = new HashMap<>();
        Map<String, Object> message = new HashMap<>();
        message.put("content", "AI Response");
        choice.put("message", message);
        responseBody.put("choices", Collections.singletonList(choice));

        ResponseEntity<Map> responseEntity = ResponseEntity.ok(responseBody);

        when(restTemplate.postForEntity(any(String.class), any(HttpEntity.class), eq(Map.class)))
                .thenReturn(responseEntity);

        String result = openAiService.getChatResponse("Hello");
        assertEquals("AI Response", result);
    }

    @Test
    void testGetChatResponse_QuotaExceeded() {
        when(restTemplate.postForEntity(any(String.class), any(HttpEntity.class), eq(Map.class)))
                .thenThrow(new HttpClientErrorException(HttpStatus.TOO_MANY_REQUESTS)); // 429

        String result = openAiService.getChatResponse("Hello");
        assertTrue(result.contains("quota d'utilisation"));
    }
}
