package com.hospital.dashboard.controller;

import com.hospital.dashboard.service.CustomAIService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/custom-ai")

public class CustomAIController {

    @Autowired
    private com.hospital.dashboard.service.OpenAiService openAiService;

    @Autowired
    private com.hospital.dashboard.service.ForecastServiceV2 forecastService;

    @Autowired
    private com.hospital.dashboard.service.CustomAIService customAIService;

    @PostMapping("/ask")
    public Map<String, String> ask(@RequestBody Map<String, String> payload) {
        // Restriction Check: Ensure Model is Trained
        if (!customAIService.isTrained()) {
            customAIService.trainModel();
        }

        String question = payload.get("question");

        // RAG: Fetch Context from Forecast Service
        Map<String, Object> forecast = forecastService.getGlobalForecast(7); // Next 7 days context
        String context = buildFinancialContext(forecast);

        String answer = openAiService.getChatResponse(question, context);
        return Map.of("answer", answer);
    }

    private String buildFinancialContext(Map<String, Object> forecast) {
        StringBuilder sb = new StringBuilder();
        sb.append("You are an expert financial analyst for Hospifin. ");
        sb.append("Use the following REAL DATA to answer the user's question. Do not hallucinate numbers. ");

        try {
            if (forecast.containsKey("globalPrediction")) {
                sb.append("Predicted Total Cost (Next 7 Days): ").append(forecast.get("globalPrediction"))
                        .append(" EUR. ");
            }
            if (forecast.containsKey("globalTotal")) {
                sb.append("Current Total Cost (Last 30 Days): ").append(forecast.get("globalTotal")).append(" EUR. ");
            }

            if (forecast.containsKey("methodology")) {
                Map<String, Object> method = (Map<String, Object>) forecast.get("methodology");
                if (method.containsKey("slope")) {
                    sb.append("Trend Slope (Linear Regression): ").append(method.get("slope")).append(" EUR/day. ");
                }
            }

            // Detailed breakdown if possible (simplified for context window)
            sb.append("The prediction uses a Linear Regression model with Seasonality adjustments. ");
            sb.append("If asked about specific days, explain that we calculate: y = ax + b * seasonality_index. ");
        } catch (Exception e) {
            sb.append("Data unavailable.");
        }

        return sb.toString();
    }
}
