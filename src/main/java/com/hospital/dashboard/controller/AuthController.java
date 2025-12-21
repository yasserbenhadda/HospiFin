package com.hospital.dashboard.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")

public class AuthController {

    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> login(@RequestBody Map<String, String> credentials) {
        String email = credentials.get("email");
        String password = credentials.get("password");

        // Mock authentication logic
        if (email != null && !email.isEmpty() && "password".equals(password)) {
            Map<String, String> response = new HashMap<>();
            response.put("token", java.util.UUID.randomUUID().toString());
            response.put("message", "Login successful");
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.status(401).body(Map.of("message", "Invalid credentials"));
        }
    }
}
