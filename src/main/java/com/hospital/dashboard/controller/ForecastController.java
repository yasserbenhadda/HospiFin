package com.hospital.dashboard.controller;

import com.hospital.dashboard.service.ForecastServiceV2;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/forecasts")

public class ForecastController {

        @Autowired
        private ForecastServiceV2 forecastService;

        @GetMapping
        public Map<String, Object> getForecasts(
                        @org.springframework.web.bind.annotation.RequestParam(defaultValue = "30") int days) {
                return forecastService.getGlobalForecast(days);
        }

        @GetMapping("/test")
        public String getTest() {
                return "Control Check: I have access.";
        }
}
