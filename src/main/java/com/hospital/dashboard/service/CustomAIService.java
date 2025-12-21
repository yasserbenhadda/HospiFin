package com.hospital.dashboard.service;

import com.hospital.dashboard.model.*;
import com.hospital.dashboard.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class CustomAIService {

    private enum Language {
        FR, EN
    }

    private static final Map<Language, Map<String, String>> TEMPLATES = new HashMap<>();

    static {
        Map<String, String> fr = new HashMap<>();
        fr.put("STAFF_COUNT", "👥 Nous avons actuellement {0} membres du personnel hospitalier.");
        fr.put("MED_COUNT", "💊 Le stock compte {0} types de médicaments différents.");
        fr.put("CONS_COUNT", "📦 Nous gérons {0} références de consommables médicaux.");
        fr.put("PROJECT_OPINION",
                "🏥 [Avis Projet] : L''hôpital est fonctionnel mais sous tension.\n👉 Explication : {0} {1}");
        fr.put("RATIO_CRITICAL",
                "Le ratio personnel/patient est critique ({0}). Cela indique une surcharge de travail structurelle.");
        fr.put("RATIO_STABLE", "Le ratio personnel est stable, permettant une prise en charge correcte.");
        fr.put("STOCK_LOW",
                "De plus, le stock de médicaments est FAIBLE, ce qui risque de provoquer des ruptures de soins.");
        fr.put("FORECAST_HEADER", "🔮 [Prévisions & Alertes] :\n");
        fr.put("ALERT_SURGERY",
                "⚠️ ALERTE ROUGE : Les coûts de Chirurgie explosent (+{0}%).\n   -> Cause probable : Augmentation du prix des prothèses ou volume d''actes non régulé.\n");
        fr.put("ALERT_STAFF",
                "⚠️ ALERTE ORANGE : Sous-effectif détecté.\n   -> Conséquence : Risque accru d''erreurs médicales et de burnout du personnel.\n");
        fr.put("NO_RISK", "✅ Aucun risque majeur détecté. Les indicateurs sont dans le vert.");
        fr.put("SOLUTIONS_HEADER", "🛠️ [Solutions Recommandées] :\n");
        fr.put("SOL_SURGERY",
                "Pour la Chirurgie :\n1. 📉 Audit des fournisseurs (Impact: -15% coûts) -> Identifiez les écarts de prix injustifiés.\n2. 🏥 Ambulatoire (Impact: Libère des lits) -> Réduit les coûts d''hébergement.\n3. 🤝 Renégociation (Impact: Immédiat) -> Faites jouer la concurrence.\n");
        fr.put("SOL_STAFF",
                "\nPour le Personnel :\n1. 🧑‍⚕️ Intérimaires (Impact: Rapide) -> Soulage l''équipe immédiatement.\n2. 📅 Optimisation IA (Impact: Structurel) -> Mieux répartir la charge existante.\n3. 🛏️ Fermeture de lits (Impact: Drastique) -> À utiliser en dernier recours pour la sécurité.\n");
        fr.put("DOC_OPINION",
                "👨‍⚕️ [Avis Docteur] : Nous avons {0} patients. Durée moyenne de séjour : {1} jours. Je recommande de réduire la durée pour limiter les infections.");
        fr.put("ACC_OPINION",
                "📊 [Avis Comptable] : Revenu total : {0} €. Alerte : La Chirurgie augmente de {1}%. C''est critique pour la rentabilité.");
        fr.put("STRATEGY",
                "💡 [Stratégie] : Pour éviter la hausse de 7% en Chirurgie :\n1. Renégocier les prothèses.\n2. Passer 20% en ambulatoire.\n3. Réduire le gaspillage.");
        fr.put("DEFAULT", "Je peux analyser le Projet, les Prévisions, donner des Alertes ou proposer des Solutions.");

        Map<String, String> en = new HashMap<>();
        en.put("STAFF_COUNT", "👥 We currently have {0} hospital staff members.");
        en.put("MED_COUNT", "💊 The inventory includes {0} different types of medications.");
        en.put("CONS_COUNT", "📦 We manage {0} references of medical consumables.");
        en.put("PROJECT_OPINION",
                "🏥 [Project Opinion]: The hospital is functional but under pressure.\n👉 Explanation: {0} {1}");
        en.put("RATIO_CRITICAL", "Staff-to-patient ratio is critical ({0}). This indicates structural overwork.");
        en.put("RATIO_STABLE", "Staffing is stable, allowing for proper care.");
        en.put("STOCK_LOW", "Also, medication stock is LOW, risking care interruptions.");
        en.put("FORECAST_HEADER", "🔮 [Forecasts & Warnings]:\n");
        en.put("ALERT_SURGERY",
                "⚠️ RED ALERT: Surgery costs are exploding (+{0}%).\n   -> Probable Cause: Rising prosthetics prices or unregulated procedure volume.\n");
        en.put("ALERT_STAFF",
                "⚠️ ORANGE ALERT: Understaffing detected.\n   -> Consequence: Increased risk of medical errors and staff burnout.\n");
        en.put("NO_RISK", "✅ No major risks detected. Indicators are green.");
        en.put("SOLUTIONS_HEADER", "🛠️ [Recommended Solutions]:\n");
        en.put("SOL_SURGERY",
                "For Surgery:\n1. 📉 Supplier Audit (Impact: -15% costs) -> Identify unjustified price variances.\n2. 🏥 Outpatient Shift (Impact: Frees beds) -> Reduces accommodation costs.\n3. 🤝 Renegotiation (Impact: Immediate) -> Leverage competition.\n");
        en.put("SOL_STAFF",
                "\nFor Staffing:\n1. 🧑‍⚕️ Temp Staff (Impact: Fast) -> Relieves the team immediately.\n2. 📅 AI Optimization (Impact: Structural) -> Better distribute existing load.\n3. 🛏️ Close Beds (Impact: Drastic) -> Use as last resort for safety.\n");
        en.put("DOC_OPINION",
                "👨‍⚕️ [Doctor Opinion]: We have {0} patients. Average stay duration: {1} days. I recommend reducing the stay duration to minimize infection risks.");
        en.put("ACC_OPINION",
                "📊 [Accountant Opinion]: Total Revenue: {0} €. Warning: Surgery costs are up by {1}%. This is critical for profitability.");
        en.put("STRATEGY",
                "💡 [Strategy]: To avoid the 7% Surgery increase:\n1. Renegotiate prosthetics contracts.\n2. Shift 20% to outpatient care.\n3. Reduce waste.");
        en.put("DEFAULT", "I can analyze the Project, Forecasts, give Warnings or propose Solutions.");

        TEMPLATES.put(Language.FR, fr);
        TEMPLATES.put(Language.EN, en);
    }

    @Autowired
    private PatientRepository patientRepository;

    @Autowired
    private HospitalStayRepository stayRepository;

    @Autowired
    private MedicalActRepository medicalActRepository;

    @Autowired
    private MedicationRepository medicationRepository;

    @Autowired
    private ConsumableRepository consumableRepository;

    @Autowired
    private PersonnelRepository personnelRepository;

    private Map<String, Object> trainedModel = new HashMap<>();
    private boolean isTrained = false;

    public Map<String, Object> trainModel() {
        // 1. Aggregate Real Data
        long patientCount = patientRepository.count();
        List<HospitalStay> stays = stayRepository.findAll();
        List<MedicalAct> acts = medicalActRepository.findAll();
        long medicationCount = medicationRepository.count();
        long consumableCount = consumableRepository.count();
        long personnelCount = personnelRepository.count();

        BigDecimal totalRevenue = BigDecimal.ZERO;
        for (HospitalStay stay : stays) {
            if (stay.getEndDate() != null && stay.getStartDate() != null && stay.getDailyRate() != null) {
                long days = stay.getEndDate().toEpochDay() - stay.getStartDate().toEpochDay();
                totalRevenue = totalRevenue.add(stay.getDailyRate().multiply(BigDecimal.valueOf(days)));
            }
        }
        for (MedicalAct act : acts) {
            if (act.getCost() != null) {
                totalRevenue = totalRevenue.add(act.getCost());
            }
        }

        double avgStayDuration = stays.stream()
                .filter(s -> s.getEndDate() != null && s.getStartDate() != null)
                .mapToLong(s -> s.getEndDate().toEpochDay() - s.getStartDate().toEpochDay())
                .average().orElse(0.0);

        // 2. Simulate/Calculate Trends (Heuristic for Demo)
        Map<String, Double> trends = new HashMap<>();
        trends.put("Chirurgie", 7.0); // +7%
        trends.put("Cardiologie", 2.5);
        trends.put("Maternité", -1.0);

        // 3. Advanced Metrics
        double staffToPatientRatio = patientCount > 0 ? (double) personnelCount / patientCount : 0.0;
        String stockStatus = medicationCount < 50 ? "LOW" : "NORMAL";

        // 4. Store "Learned" Knowledge
        trainedModel.put("patientCount", patientCount);
        trainedModel.put("totalRevenue", totalRevenue);
        trainedModel.put("avgStayDuration", avgStayDuration);
        trainedModel.put("stayCount", stays.size());
        trainedModel.put("actCount", acts.size());
        trainedModel.put("medicationCount", medicationCount);
        trainedModel.put("consumableCount", consumableCount);
        trainedModel.put("personnelCount", personnelCount);
        trainedModel.put("trends", trends);
        trainedModel.put("staffToPatientRatio", staffToPatientRatio);
        trainedModel.put("stockStatus", stockStatus);

        isTrained = true;

        return trainedModel;
    }

    public boolean isTrained() {
        return isTrained;
    }

    public String getAnswer(String question) {
        if (!isTrained) {
            return "Je ne suis pas encore entraîné. Veuillez cliquer sur 'Entraîner le modèle' d'abord. / I am not trained yet. Please click 'Train Model' first.";
        }

        String q = question.toLowerCase();
        boolean isEnglish = isEnglish(q);
        Language lang = isEnglish ? Language.EN : Language.FR;

        return getAnswerInternal(q, lang);
    }

    private String getAnswerInternal(String q, Language lang) {
        // --- SPECIFIC DATA ---
        if (matchesAny(q, "personnel", "staff", "equipe", "team")) {
            return format(lang, "STAFF_COUNT", trainedModel.get("personnelCount"));
        } else if (matchesAny(q, "medicament", "medication", "pharmacie", "drug", "pharmacy")) {
            return format(lang, "MED_COUNT", trainedModel.get("medicationCount"));
        } else if (matchesAny(q, "consommable", "materiel", "consumable", "material", "supply")) {
            return format(lang, "CONS_COUNT", trainedModel.get("consumableCount"));
        }
        // --- GENERAL PREDICTIONS & WARNINGS ---
        else if (matchesAny(q, "prevision", "futur", "avenir", "demain", "prediction", "warning", "alerte", "danger",
                "forecast", "future", "tomorrow", "alert")) {
            return getForecastsWithWarnings(lang);
        }
        // --- SOLUTIONS ---
        else if (matchesAny(q, "solution", "resoudre", "fix", "corriger", "aide", "solve", "help")) {
            return getSolutions(lang);
        }
        // --- PROJECT OPINION ---
        else if (matchesAny(q, "avis", "projet", "opinion", "general", "status", "etat", "project", "state")) {
            return getProjectOpinion(lang);
        }
        // --- DOCTOR PERSONA ---
        else if (matchesAny(q, "avis", "medical", "sante", "patient", "docteur", "doctor", "medecin", "health")) {
            return getDoctorOpinion(lang);
        }
        // --- ACCOUNTANT PERSONA ---
        else if (matchesAny(q, "avis", "financier", "finance", "comptable", "cout", "argent", "budget", "depense",
                "paye", "financial", "accountant", "cost", "money", "expense")) {
            return getAccountantOpinion(lang);
        }
        // --- STRATEGIC ADVICE ---
        else if (matchesAny(q, "augmentation", "hausse", "chirurgie", "skip", "eviter", "reduire", "increase", "rise",
                "surgery", "avoid", "reduce")) {
            return format(lang, "STRATEGY");
        } else {
            return format(lang, "DEFAULT");
        }
    }

    private String getProjectOpinion(Language lang) {
        double ratio = getSafeDouble(trainedModel, "staffToPatientRatio");
        String stock = getSafeString(trainedModel, "stockStatus");

        String ratioText = format(lang, ratio < 0.2 ? "RATIO_CRITICAL" : "RATIO_STABLE", String.format("%.2f", ratio));
        String stockText = "LOW".equals(stock) ? format(lang, "STOCK_LOW") : "";

        return format(lang, "PROJECT_OPINION", ratioText, stockText);
    }

    private String getForecastsWithWarnings(Language lang) {
        Map<String, Object> trends = getSafeMap(trainedModel, "trends");
        double surgeryTrend = getSafeDouble(trends, "Chirurgie");
        double ratio = getSafeDouble(trainedModel, "staffToPatientRatio");

        StringBuilder sb = new StringBuilder();
        sb.append(format(lang, "FORECAST_HEADER"));

        boolean hasAlert = false;
        if (surgeryTrend > 5.0) {
            sb.append(format(lang, "ALERT_SURGERY", surgeryTrend));
            hasAlert = true;
        }

        if (ratio < 0.2) {
            sb.append(format(lang, "ALERT_STAFF"));
            hasAlert = true;
        }

        if (!hasAlert) {
            sb.append(format(lang, "NO_RISK"));
        }

        return sb.toString();
    }

    private String getSolutions(Language lang) {
        Map<String, Object> trends = getSafeMap(trainedModel, "trends");
        double surgeryTrend = getSafeDouble(trends, "Chirurgie");
        double ratio = getSafeDouble(trainedModel, "staffToPatientRatio");

        StringBuilder sb = new StringBuilder();
        sb.append(format(lang, "SOLUTIONS_HEADER"));

        if (surgeryTrend > 5.0) {
            sb.append(format(lang, "SOL_SURGERY"));
        }

        if (ratio < 0.2) {
            sb.append(format(lang, "SOL_STAFF"));
        }

        return sb.toString();
    }

    private String getDoctorOpinion(Language lang) {
        long patients = getSafeLong(trainedModel, "patientCount");
        double duration = getSafeDouble(trainedModel, "avgStayDuration");
        return format(lang, "DOC_OPINION", patients, String.format("%.1f", duration));
    }

    private String getAccountantOpinion(Language lang) {
        String revenue = getSafeString(trainedModel, "totalRevenue");
        Map<String, Object> trends = getSafeMap(trainedModel, "trends");
        double surgeryTrend = getSafeDouble(trends, "Chirurgie");
        return format(lang, "ACC_OPINION", revenue, surgeryTrend);
    }

    private String format(Language lang, String key, Object... args) {
        String template = TEMPLATES.get(lang).getOrDefault(key, key);
        return java.text.MessageFormat.format(template, args);
    }

    private boolean isEnglish(String text) {
        return matchesAny(text, "hello", "hi", "what", "how", "give", "opinion", "cost", "money", "forecast", "future",
                "staff", "drug", "avoid", "skip", "prediction", "talk", "project", "solution", "solve", "fix", "help",
                "alert", "warning", "danger");
    }

    private boolean matchesAny(String text, String... keywords) {
        String[] words = text.split("\\s+");
        for (String keyword : keywords) {
            if (text.contains(keyword))
                return true;
            for (String word : words) {
                int threshold = keyword.length() > 4 ? 2 : 1;
                if (calculateLevenshteinDistance(word, keyword) <= threshold) {
                    return true;
                }
            }
        }
        return false;
    }

    private int calculateLevenshteinDistance(String x, String y) {
        int[][] dp = new int[x.length() + 1][y.length() + 1];
        for (int i = 0; i <= x.length(); i++)
            dp[i][0] = i;
        for (int j = 0; j <= y.length(); j++)
            dp[0][j] = j;
        for (int i = 1; i <= x.length(); i++) {
            for (int j = 1; j <= y.length(); j++) {
                int cost = (x.charAt(i - 1) == y.charAt(j - 1)) ? 0 : 1;
                dp[i][j] = Math.min(Math.min(dp[i - 1][j] + 1, dp[i][j - 1] + 1), dp[i - 1][j - 1] + cost);
            }
        }
        return dp[x.length()][y.length()];
    }

    private double getSafeDouble(Map<String, Object> map, String key) {
        if (map == null)
            return 0.0;
        Object value = map.get(key);
        if (value == null)
            return 0.0;
        if (value instanceof Number)
            return ((Number) value).doubleValue();
        try {
            return Double.parseDouble(String.valueOf(value));
        } catch (NumberFormatException e) {
            return 0.0;
        }
    }

    private long getSafeLong(Map<String, Object> map, String key) {
        if (map == null)
            return 0L;
        Object value = map.get(key);
        if (value == null)
            return 0L;
        if (value instanceof Number)
            return ((Number) value).longValue();
        try {
            return Long.parseLong(String.valueOf(value));
        } catch (NumberFormatException e) {
            return 0L;
        }
    }

    private String getSafeString(Map<String, Object> map, String key) {
        if (map == null)
            return "";
        Object value = map.get(key);
        return value != null ? String.valueOf(value) : "";
    }

    private Map<String, Object> getSafeMap(Map<String, Object> map, String key) {
        if (map == null)
            return new HashMap<>();
        Object value = map.get(key);
        if (value instanceof Map) {
            return (Map<String, Object>) value;
        }
        return new HashMap<>();
    }
}
