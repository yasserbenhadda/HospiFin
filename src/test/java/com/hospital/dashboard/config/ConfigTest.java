package com.hospital.dashboard.config;

import org.junit.jupiter.api.Test;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.Mockito.mock;

class ConfigTest {

    @Test
    void testWebConfig() {
        WebConfig config = new WebConfig();
        assertNotNull(config);
    }

    @Test
    void testCorsConfig() {
        CorsConfig config = new CorsConfig();
        assertNotNull(config.corsFilter());
    }
}
