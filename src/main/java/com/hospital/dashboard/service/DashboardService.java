package com.hospital.dashboard.service;

import com.hospital.dashboard.model.*;
import com.hospital.dashboard.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class DashboardService {

        @Autowired
        private HospitalStayRepository stayRepository;
        @Autowired
        private MedicalActRepository medicalActRepository;
        @Autowired
        private ConsumableRepository consumableRepository;
        @Autowired
        private PersonnelRepository personnelRepository;
        @Autowired
        private ForecastServiceV2 forecastService;
        @Autowired
        private RevenueService revenueService;

        public Map<String, Object> getDashboardSummary() {
                Map<String, Object> summary = new HashMap<>();

                // 1. Calculate Totals (Current Month vs Previous Month for Trends)
                LocalDate now = LocalDate.now();
                LocalDate startOfMonth = now.minusDays(30); // Rolling 30 days as per UI "30 jours"
                LocalDate startOfPrevMonth = startOfMonth.minusDays(30);
                LocalDate endOfPrevMonth = startOfMonth.minusDays(1);

                // Real Cost
                BigDecimal currentRealCost = calculateTotalRealCost(startOfMonth, now);
                BigDecimal prevRealCost = calculateTotalRealCost(startOfPrevMonth, endOfPrevMonth);
                summary.put("totalRealCost", currentRealCost);
                summary.put("totalRealCostTrend", calculateTrend(currentRealCost, prevRealCost));

                // Predicted Cost (Real Logic via ForecastServiceV2)
                Map<String, Object> forecast = forecastService.getGlobalForecast(30);
                BigDecimal predictedCostRaw = (BigDecimal) forecast.get("globalPrediction");
                BigDecimal predictedCost = predictedCostRaw != null
                                ? predictedCostRaw.setScale(2, java.math.RoundingMode.HALF_UP)
                                : BigDecimal.ZERO;

                // Comparing Predicted (Next 30d) vs Real (Last 30d) for trend
                summary.put("totalPredictedCost", predictedCost);
                summary.put("totalPredictedCostTrend", calculateTrend(predictedCost, currentRealCost));

                // Avg Cost per Stay
                BigDecimal avgCost = calculateAvgCostPerStay(startOfMonth, now);
                BigDecimal prevAvgCost = calculateAvgCostPerStay(startOfPrevMonth, endOfPrevMonth);
                summary.put("avgCostPerStay", avgCost);
                summary.put("avgCostPerStayTrend", calculateTrend(avgCost, prevAvgCost));

                // Personnel Ratio
                double ratio = calculatePersonnelRatio(currentRealCost);
                double prevRatio = calculatePersonnelRatio(prevRealCost);
                summary.put("personnelCostRatio", ratio);
                summary.put("personnelCostRatioTrend", ratio - prevRatio); // Absolute diff for %

                // 2. Cost by Service (Department)
                summary.put("costByService", calculateCostByService());

                // 3. Cost by Category (New)
                summary.put("costByCategory", calculateCostByCategory(currentRealCost));

                // 4. Recent Stays
                summary.put("recentStays", getRecentStays());

                // 5. Smart Alert
                summary.put("smartAlert", generateSmartAlert(currentRealCost, prevRealCost));

                return summary;
        }

        private List<Map<String, Object>> calculateCostByCategory(BigDecimal totalCost) {
                return convertBreakdownToList(getBreakdown(null, null));
        }

        private List<Map<String, Object>> calculateCostByService() {
                // Reuse the same breakdown logic, or refine if service-specific logic is needed
                return convertBreakdownToList(getBreakdown(null, null));
        }

        private List<Map<String, Object>> convertBreakdownToList(Map<String, BigDecimal> breakdown) {
                List<Map<String, Object>> list = new ArrayList<>();
                breakdown.forEach((k, v) -> list.add(createCategoryMap(k, v)));
                return list;
        }

        private Map<String, Object> createCategoryMap(String name, BigDecimal value) {
                Map<String, Object> map = new HashMap<>();
                map.put("name", name);
                map.put("value", value);
                return map;
        }

        private BigDecimal calculateTotalRealCost(LocalDate start, LocalDate end) {
                Map<String, BigDecimal> breakdown = getBreakdown(start, end);
                return breakdown.values().stream().reduce(BigDecimal.ZERO, BigDecimal::add);
        }

        private BigDecimal calculateAvgCostPerStay(LocalDate start, LocalDate end) {
                // Optimisation: Reuse calculateTotal for stays
                List<HospitalStay> stays = stayRepository.findAll();
                BigDecimal totalCost = calculateTotal(stays,
                                s -> s.getStartDate() != null && s.getEndDate() != null
                                                && (start == null || !s.getStartDate().isAfter(end))
                                                && (end == null || !s.getEndDate().isBefore(start)),
                                revenueService::calculateStayRevenue);

                long count = stays.stream()
                                .filter(s -> s.getStartDate() != null && s.getEndDate() != null
                                                && (start == null || !s.getStartDate().isAfter(end))
                                                && (end == null || !s.getEndDate().isBefore(start)))
                                .count();

                if (count == 0)
                        return BigDecimal.ZERO;
                return totalCost.divide(BigDecimal.valueOf(count), 2, RoundingMode.HALF_UP);
        }

        private double calculatePersonnelRatio(BigDecimal totalCost) {
                if (totalCost.compareTo(BigDecimal.ZERO) == 0)
                        return 0;
                BigDecimal personnel = calculateTotal(personnelRepository.findAll(), p -> true,
                                Personnel::getCostPerDay)
                                .multiply(BigDecimal.valueOf(30));
                return personnel.divide(totalCost, 4, RoundingMode.HALF_UP).doubleValue() * 100;
        }

        private double calculateTrend(BigDecimal current, BigDecimal previous) {
                if (previous.compareTo(BigDecimal.ZERO) == 0)
                        return 100.0;
                return current.subtract(previous).divide(previous, 4, RoundingMode.HALF_UP).doubleValue() * 100;
        }

        private List<Map<String, Object>> getRecentStays() {
                return stayRepository.findAll().stream()
                                .filter(s -> s.getStartDate() != null && s.getEndDate() != null
                                                && s.getPatient() != null)
                                .sorted((s1, s2) -> s2.getStartDate().compareTo(s1.getStartDate()))
                                .limit(5)
                                .map(s -> {
                                        BigDecimal cost = revenueService.calculateStayRevenue(s);
                                        Map<String, Object> map = new HashMap<>();
                                        String firstName = s.getPatient().getFirstName() != null
                                                        ? s.getPatient().getFirstName()
                                                        : "";
                                        String lastName = s.getPatient().getLastName() != null
                                                        ? s.getPatient().getLastName()
                                                        : "";
                                        map.put("patientName", firstName + " " + lastName);
                                        map.put("department", s.getPathology() != null ? s.getPathology() : "N/A");
                                        map.put("status", s.getEndDate().isAfter(LocalDate.now()) ? "En cours"
                                                        : "Terminé");
                                        map.put("cost", cost);
                                        return map;
                                })
                                .collect(Collectors.toList());
        }

        private Map<String, Object> generateSmartAlert(BigDecimal current, BigDecimal prev) {
                Map<String, Object> alert = new HashMap<>();
                double trend = calculateTrend(current, prev);

                LocalDate now = LocalDate.now();
                LocalDate startOfMonth = now.minusDays(30);
                LocalDate startOfPrev = startOfMonth.minusDays(30);
                LocalDate endOfPrev = startOfMonth.minusDays(1);

                Map<String, BigDecimal> currentBreakdown = getBreakdown(startOfMonth, now);
                Map<String, BigDecimal> prevBreakdown = getBreakdown(startOfPrev, endOfPrev);

                String maxDriver = "Général";
                BigDecimal maxDelta = BigDecimal.ZERO;

                for (String key : currentBreakdown.keySet()) {
                        BigDecimal currVal = currentBreakdown.getOrDefault(key, BigDecimal.ZERO);
                        BigDecimal prevVal = prevBreakdown.getOrDefault(key, BigDecimal.ZERO);
                        BigDecimal delta = currVal.subtract(prevVal).abs();

                        if (delta.compareTo(maxDelta) > 0) {
                                maxDelta = delta;
                                maxDriver = key;
                        }
                }

                if (trend > 5) {
                        alert.put("type", "warning");
                        alert.put("title", "Alerte de prévision");
                        BigDecimal currMaxDriver = currentBreakdown.getOrDefault(maxDriver, BigDecimal.ZERO);
                        BigDecimal prevMaxDriver = prevBreakdown.getOrDefault(maxDriver, BigDecimal.ZERO);
                        alert.put("message", String.format(
                                        "Hausse globale de %.1f%%. Le principal facteur est '%s' qui a %s.",
                                        trend,
                                        maxDriver,
                                        currMaxDriver.compareTo(prevMaxDriver) > 0
                                                        ? "augmenté"
                                                        : "varié"));
                } else if (trend < -5) {
                        alert.put("type", "success");
                        alert.put("title", "Optimisation détectée");
                        alert.put("message", String.format(
                                        "Baisse des coûts de %.1f%%, principalement grâce à une réduction sur '%s'.",
                                        Math.abs(trend),
                                        maxDriver));
                } else {
                        alert.put("type", "info");
                        alert.put("title", "Stabilité");
                        alert.put("message",
                                        "Les coûts sont stables. Aucune anomalie majeure détectée sur les postes de dépenses.");
                }
                return alert;
        }

        private Map<String, BigDecimal> getBreakdown(LocalDate start, LocalDate end) {
                Map<String, BigDecimal> map = new HashMap<>();

                BigDecimal acts = calculateTotal(medicalActRepository.findAll(),
                                a -> isWithinDateRange(a.getDate(), start, end),
                                MedicalAct::getCost);

                BigDecimal cons = calculateTotal(consumableRepository.findAll(),
                                c -> isWithinDateRange(c.getDate(), start, end),
                                Consumable::getTotalCost);

                BigDecimal stays = calculateTotal(stayRepository.findAll(),
                                s -> isWithinDateRange(s.getStartDate(), start, end)
                                                && isWithinDateRange(s.getEndDate(), start, end),
                                revenueService::calculateStayRevenue);

                BigDecimal pers = calculateTotal(personnelRepository.findAll(),
                                p -> true,
                                Personnel::getCostPerDay).multiply(BigDecimal.valueOf(30));

                map.put("Actes Médicaux", acts);
                map.put("Consommables", cons);
                map.put("Séjours", stays);
                map.put("Personnel", pers);

                return map;
        }

        private boolean isWithinDateRange(LocalDate date, LocalDate start, LocalDate end) {
                if (date == null)
                        return false;
                if (start == null && end == null)
                        return true;
                return !date.isAfter(end) && !date.isBefore(start);
        }

        private <T> BigDecimal calculateTotal(List<T> items, java.util.function.Predicate<T> filter,
                        java.util.function.Function<T, BigDecimal> mapper) {
                return items.stream()
                                .filter(filter)
                                .map(mapper)
                                .filter(java.util.Objects::nonNull)
                                .reduce(BigDecimal.ZERO, BigDecimal::add);
        }
}
