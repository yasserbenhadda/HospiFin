package com.hospital.dashboard.controller;

import com.hospital.dashboard.service.OpenAiService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(CustomAIController.class)
class CustomAIControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private OpenAiService openAiService;

    @Test
    void testAsk() throws Exception {
        given(openAiService.getChatResponse(anyString())).willReturn("AI Answer");

        mockMvc.perform(post("/api/custom-ai/ask")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"question\": \"What is your name?\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.answer").value("AI Answer"));
    }
}
