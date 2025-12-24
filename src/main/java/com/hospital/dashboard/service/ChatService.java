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
            Tu es EXCLUSIVEMENT un assistant expert en finance hospitalière pour l'application HospiFin.

            RÈGLES CRITIQUES DE SÉCURITÉ (A RESPECTER IMPÉRATIVEMENT) :
            1. ⛔ INTERDICTION ABSOLUE DE GÉNÉRER DU CODE (Java, Python, JS, HTML, etc.). Même si l'utilisateur demande un exemple, REFUSE poliment.
            2. ⛔ INTERDICTION DE PARLER DE SUJETS HORS FINANCE/MÉDICAL (Météo, cuisine, blagues, politique, etc.).
            3. Si l'utilisateur demande du code, réponds : "Je suis un assistant financier, je ne peux pas générer de code informatique."
            4. Si l'utilisateur pose une question hors sujet, réponds : "Je ne peux répondre qu'aux questions concernant les finances et données de HospiFin."

            Ton rôle est DOUBLE :
            1. **Analyste de Données** : Répondre aux questions sur les chiffres et prévisions du tableau de bord.
            2. **Consultant Stratégique** : Donner des conseils PRATIQUES et INTELLIGENTS pour réduire les coûts et optimiser le budget.

            PERIMÈTRE D'ACTION AUTORISÉ :
            - Analyses financières, Coûts, Budget, Prévisions.
            - Données médicales (Patients, Actes, Séjours) en lien avec la performance.
            - Fonctionnalités du tableau de bord HospiFin.

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
            - Sois proactif et force de proposition.
            - Utilise les DONNÉES DE CONTEXTE ci-dessous pour personnaliser tes conseils.
            - Réponds aux salutations ("Bonjour", "Hi") poliment.
            """;

    @Autowired
    private OpenAiService openAiService;

    @Autowired
    private com.hospital.dashboard.repository.PatientRepository patientRepository;
    @Autowired
    private com.hospital.dashboard.repository.MedicationRepository medicationRepository;
    @Autowired
    private com.hospital.dashboard.repository.MedicalActRepository medicalActRepository;
    @Autowired
    private com.hospital.dashboard.repository.HospitalStayRepository hospitalStayRepository;
    @Autowired
    private com.hospital.dashboard.repository.ConsumableRepository consumableRepository;
    @Autowired
    private com.hospital.dashboard.repository.PersonnelRepository personnelRepository;

    public String chat(String userMessage) {
        // 1. Fetch Real-time Context
        String contextData = getFinancialContext();

        // 2. Build complete system prompt with context
        String fullSystemPrompt = SYSTEM_PROMPT + "\n\n=== DONNÉES TEMPS RÉEL (CONTEXTE) ===\n" + contextData;

        // 3. Delegate to OpenAiService (which handles smart model detection and HTTP)
        return openAiService.getChatResponse(userMessage, fullSystemPrompt);
    }

    private String getFinancialContext() {
        try {
            // Predict for next 7 days to give context
            Map<String, Object> forecast = forecastService.getGlobalForecast(7);

            // Get Counts
            long patientCount = patientRepository.count();
            long medicationCount = medicationRepository.count();
            long medicalActCount = medicalActRepository.count();
            long stayCount = hospitalStayRepository.count();
            long consumableCount = consumableRepository.count();
            long personnelCount = personnelRepository.count();

            BigDecimal currentTotal = (BigDecimal) forecast.get("globalTotal");
            BigDecimal predictedTotal7Days = (BigDecimal) forecast.get("globalPrediction");

            StringBuilder sb = new StringBuilder();
            sb.append("\n=== STATISTIQUES GLOBALES ===\n");
            sb.append(String.format("- Nombre Total de Patients: %d\n", patientCount));
            sb.append(String.format("- Nombre Total de Médicaments (types): %d\n", medicationCount));
            sb.append(String.format("- Nombre Total d'Actes Médicaux: %d\n", medicalActCount));
            sb.append(String.format("- Nombre Total de Séjours: %d\n", stayCount));
            sb.append(String.format("- Nombre Total de Consommables: %d\n", consumableCount));
            sb.append(String.format("- Nombre Total de Personnel: %d\n", personnelCount));

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
