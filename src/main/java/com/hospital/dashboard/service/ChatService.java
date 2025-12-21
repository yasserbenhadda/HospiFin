package com.hospital.dashboard.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.*;

@Service
public class ChatService {

    private static final Logger logger = LoggerFactory.getLogger(ChatService.class);

    @Autowired
    private ForecastServiceV2 forecastService;

    @Value("${langchain4j.open-ai.chat-model.api-key}")
    private String apiKey;

    @Value("${langchain4j.open-ai.chat-model.base-url:https://api.openai.com/v1}")
    private String baseUrl;

    @Value("${langchain4j.open-ai.chat-model.model-name:gpt-4o-mini}")
    private String modelName;

    private static final String SYSTEM_PROMPT = """
            Tu es un assistant IA expert et consultant en finance hospitalière pour HospiFin.

            Ton rôle est DOUBLE :
            1. **Analyste de Données** : Répondre aux questions sur les chiffres et prévisions du tableau de bord.
            2. **Consultant Stratégique** : Donner des conseils PRATIQUES et INTELLIGENTS pour réduire les coûts et optimiser le budget.

            PERIMÈTRE D'ACTION :
            - Tu DOIS répondre aux questions sur : "Comment réduire les coûts ?", "Optimiser le budget", "Analyse des tendances", "Pourquoi les coûts augmentent ?".
            - Tu DOIS REFUSER uniquement les sujets totalement hors contexte (Météo, Football, Cuisine, Code Java général, etc.).

            INSTRUCTIONS SPÉCIALES "COMMENT C'EST CALCULÉ ?" :
            Si l'utilisateur demande "Comment as-tu prédit ça ?" ou "Détails du calcul" :
            1. Cite l'algorithme : "Régression Linéaire avec Ajustement Saisonnier".
            2. Donne la PENTE (Trend) : "J'ai détecté une tendance de X €/jour".
            3. Explique la SAISONNALITÉ : "Le Lundi est historiquement 1.2x plus cher, le Dimanche 0.8x...".
            4. Sois technique et pédagogue. Montre que tu as analysé les chiffres.

            BASE DE CONNAISSANCES (Stratégies d'optimisation) :
            - **Personnel** : Suggérer l'ajustement des plannings selon la saisonnalité, réduire les heures sup non critiques.
            - **Consommables** : Négocier les achats en volume, contrôler les stocks périmés, privilégier les génériques.
            - **Séjours** : Réduire la DMS (Durée Moyenne de Séjour) par une meilleure planification des sorties, éviter les réadmissions.
            - **Actes** : Auditer la rentabilité des blocs opératoires, optimiser le taux d'occupation.

            STYLE DE RÉPONSE :
            - Sois proactif et force de proposition. Ne dis JAMAIS "Je ne peux pas donner d'idées générales" si le sujet est la finance.
            - Utilise les DONNÉES DE CONTEXTE ci-dessous pour personnaliser tes conseils (ex: "Vu que vos coûts prévus augmentent ce week-end, je suggère de...").
            - Réponds aux salutations ("Bonjour", "Hi") poliment.
            """;

    private RestTemplate restTemplate = new RestTemplate();

    @SuppressWarnings("unchecked")
    public String chat(String userMessage) {
        // 1. Fetch Real-time Context
        String contextData = getFinancialContext();

        String url = baseUrl + "/chat/completions";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", "Bearer " + apiKey);
        headers.set("HTTP-Referer", "http://localhost:5173");
        headers.set("X-Title", "HospiFin Dashboard");

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", modelName);
        requestBody.put("messages", List.of(
                Map.of("role", "system", "content",
                        SYSTEM_PROMPT + "\n\n=== DONNÉES TEMPS RÉEL (CONTEXTE) ===\n" + contextData),
                Map.of("role", "user", "content", userMessage)));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.POST, entity, Map.class);
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
            return "Désolé, je n'ai pas pu générer une réponse.";
        } catch (Exception e) {
            logger.error("Error connecting to AI service", e);
            return "Erreur de connexion au service IA: " + e.getMessage();
        }
    }

    private String getFinancialContext() {
        try {
            // Predict for next 7 days to give context
            Map<String, Object> forecast = forecastService.getGlobalForecast(7);

            BigDecimal currentTotal = (BigDecimal) forecast.get("globalTotal");
            BigDecimal predictedTotal7Days = (BigDecimal) forecast.get("globalPrediction");

            StringBuilder sb = new StringBuilder();
            sb.append(String.format("- Total des coûts ACTUELS (historique): %.2f €\n", currentTotal));
            sb.append(String.format("- Prévision Total sur 7 jours: %.2f €\n", predictedTotal7Days));

            List<Map<String, Object>> history = (List<Map<String, Object>>) forecast.get("history");

            // Extract Methodology (Medical Acts as proxy for global trend)
            Map<String, Object> medicalActs = (Map<String, Object>) forecast.get("medicalActs");
            if (medicalActs != null && medicalActs.containsKey("methodology")) {
                Map<String, Object> method = (Map<String, Object>) medicalActs.get("methodology");
                Double slope = (Double) method.get("slope");
                Map<java.time.DayOfWeek, Double> seasonality = (Map<java.time.DayOfWeek, Double>) method
                        .get("seasonality");

                sb.append("\n=== MÉTHODOLOGIE PRÉDICTIVE (Détails Techniques) ===\n");
                sb.append(String.format("- Algorithme: Régression Linéaire Simple + Ajustement Saisonnier\n"));
                sb.append(String.format("- Tendance détectée (Pente): %.2f € / jour\n", slope));
                if (seasonality != null && !seasonality.isEmpty()) {
                    sb.append("- Saisonnalité (Facteurs multiplicateurs >1 = Coût élevé, <1 = Coût faible):\n");
                    seasonality.forEach((day, val) -> {
                        if (Math.abs(val - 1.0) > 0.05) { // Only show significant deviations
                            sb.append(String.format("  * %s : %.2fx\n", day, val));
                        }
                    });
                }
            }

            if (history != null) {
                sb.append("\n- Détail Prévisions (4 prochains jours):\n");
                // Filter for future predictions only (items with "isPrediction" or just ensure
                // they are future dates)
                // In getGlobalForecast, future items have "isPrediction": true
                history.stream()
                        .filter(m -> Boolean.TRUE.equals(m.get("isPrediction")))
                        .limit(4)
                        .forEach(m -> {
                            BigDecimal val = (BigDecimal) m.get("predicted");
                            sb.append(String.format("  * %s : %.2f €\n", m.get("month"), val));
                        });
            }
            return sb.toString();
        } catch (Exception e) {
            return "Données financières indisponibles pour le moment.";
        }
    }
}
