package com.hospital.dashboard.controller;

import com.hospital.dashboard.service.ChatService;
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

@WebMvcTest(ChatController.class)
class ChatControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ChatService chatService;

    @Test
    void testChat_Success() throws Exception {
        given(chatService.chat(anyString())).willReturn("AI Response");

        mockMvc.perform(post("/api/chat")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"message\": \"Hello\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.response").value("AI Response"));
    }

    @Test
    void testChat_EmptyMessage() throws Exception {
        mockMvc.perform(post("/api/chat")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"message\": \"\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.response").value("Message vide."));
    }
}
