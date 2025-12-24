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

        String modelId = "local-model";
        try {
            // Attempt to auto-detect model for JIT loading
            ResponseEntity<Map> modelResponse = restTemplate.getForEntity("http://localhost:1234/v1/models", Map.class);
            Map<String, Object> modelBody = modelResponse.getBody();
            if (modelBody != null && modelBody.containsKey("data")) {
                List<Map<String, Object>> data = (List<Map<String, Object>>) modelBody.get("data");
                if (!data.isEmpty()) {
                    // Smart Selection: Find first model that is NOT an embedding model
                    for (Map<String, Object> modelNode : data) {
                        String id = (String) modelNode.get("id");
                        if (id != null) {
                            String lowerId = id.toLowerCase();
                            // Skip embedding, audio, or vision specific if needed (mostly embedding is the
                            // issue)
                            if (lowerId.contains("embed")) {
                                continue;
                            }
                            // Prefer instruct or chat models
                            modelId = id;
                            break;
                        }
                    }
                    // If we didn't find a non-embedding model, revert to first or specific fallback
                    if (modelId.equals("local-model")) {
                        modelId = (String) data.get(0).get("id");
                    }

                    logger.info("Auto-detected model: " + modelId);
                }
            }
        } catch (Exception e) {
            logger.warn("Failed to auto-detect model: " + e.getMessage());
        }

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", modelId);
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
            String errorMsg = e.getMessage();
            logger.error("Error communicating with LM Studio: " + errorMsg);

            if (errorMsg != null && errorMsg.contains("Model is not llm")) {
                logger.warn("Embedding model detected instead of Chat model. Switching to Fallback Mode.");
                return getFallbackResponse(userMessage);
            }

            logger.warn("LM Studio unreachable. Switching to Fallback Mode.");
            return getFallbackResponse(userMessage);
        }

        return getFallbackResponse(userMessage);
    }

    private String getFallbackResponse(String userMessage) {
        String msg = userMessage.toLowerCase();

        // Basic Keyword Matching for Fallback
        if (msg.contains("bonjour") || msg.contains("hello") || msg.contains("salut") || msg.contains("hi")) {
            return "Bonjour ! Je suis en mode de secours (IA indisponible). Je peux tout de même vous donner des informations sur le personnel, les stocks ou les prévisions.";
        }

        if (msg.contains("personnel") || msg.contains("staff") || msg.contains("equipe")) {
            return "👥 [Info Secours] Le personnel hospitalier est stable. Pour des détails précis, consultez la page Personnel.";
        }

        if (msg.contains("medicament") || msg.contains("stock") || msg.contains("pharmacie") || msg.contains("drug")) {
            return "💊 [Info Secours] Les stocks de médicaments sont suivis. Une alerte stock bas est active.";
        }

        if (msg.contains("prevision") || msg.contains("cout") || msg.contains("forecast") || msg.contains("budget")) {
            return "🔮 [Info Secours] Les prévisions indiquent une hausse des coûts en Chirurgie. Consultez le Tableau de bord pour les graphiques détaillés.";
        }

        if (msg.contains("solution") || msg.contains("strategie") || msg.contains("help") || msg.contains("aide")) {
            return "💡 [Info Secours] Stratégie recommandée : \n1. Auditer les fournisseurs.\n2. Optimiser les plannings.";
        }

        return "⚠️ Je n'arrive pas à joindre mon cerveau IA (LM Studio), mais je suis là ! Posez-moi une question sur le personnel, les stocks ou les prévisions.";
    }
}
