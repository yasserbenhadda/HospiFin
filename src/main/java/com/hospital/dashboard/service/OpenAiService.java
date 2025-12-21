package com.hospital.dashboard.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class OpenAiService {

    private static final Logger logger = LoggerFactory.getLogger(OpenAiService.class);

    @Value("${openai.api.key}")
    private String apiKey;

    private RestTemplate restTemplate = new RestTemplate();
    // LM Studio Local Endpoint
    private static final String OPENAI_URL = "http://localhost:1234/v1/chat/completions";

    public String getChatResponse(String userMessage) {
        return getChatResponse(userMessage, null);
    }

    public String getChatResponse(String userMessage, String systemContext) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(apiKey != null ? apiKey : "lm-studio");

        String systemPrompt = (systemContext != null && !systemContext.isEmpty())
                ? systemContext
                : "You are a helpful medical assistant for a hospital financial dashboard. Keep answers short and professional.";

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", "local-model");
        requestBody.put("messages", List.of(
                Map.of("role", "system", "content", systemPrompt),
                Map.of("role", "user", "content", userMessage)));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(OPENAI_URL, entity, Map.class);
            Map<String, Object> body = response.getBody();
            if (body != null && body.containsKey("choices")) {
                Object choicesRaw = body.get("choices");
                if (choicesRaw instanceof List) {
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> choices = (List<Map<String, Object>>) choicesRaw;
                    if (!choices.isEmpty()) {
                        Object messageRaw = choices.get(0).get("message");
                        if (messageRaw instanceof Map) {
                            @SuppressWarnings("unchecked")
                            Map<String, Object> message = (Map<String, Object>) messageRaw;
                            Object content = message.get("content");
                            if (content != null) {
                                return content.toString();
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            logger.error("Error communicating with LM Studio", e);
            return "Erreur de communication avec l'IA locale (LM Studio). Vérifiez que le serveur tourne sur le port 1234.";
        }

        return "Pas de réponse de l'IA.";
    }
}
