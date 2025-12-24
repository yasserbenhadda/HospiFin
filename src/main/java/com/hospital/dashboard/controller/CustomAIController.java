package com.hospital.dashboard.controller;

import com.hospital.dashboard.service.CustomAIService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/custom-ai")

public class CustomAIController {

    @Autowired
    private com.hospital.dashboard.service.ChatService chatService;

    @Autowired
    private com.hospital.dashboard.service.CustomAIService customAIService;

    @PostMapping("/ask")
    public Map<String, String> ask(@RequestBody Map<String, String> payload) {
        // Restriction Check: Ensure Model is Trained (Legacy check, keeping it)
        if (!customAIService.isTrained()) {
            customAIService.trainModel();
        }

        String question = payload.get("question");

        // Delegate to unified ChatService (same logic as Web, full context)
        String answer = chatService.chat(question);
        return Map.of("answer", answer);
    }
}
