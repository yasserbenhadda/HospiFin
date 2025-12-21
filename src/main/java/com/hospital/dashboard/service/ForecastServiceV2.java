package com.hospital.dashboard.service;

import com.hospital.dashboard.model.Consumable;
import com.hospital.dashboard.model.HospitalStay;
import com.hospital.dashboard.model.MedicalAct;
import com.hospital.dashboard.repository.ConsumableRepository;
import com.hospital.dashboard.repository.HospitalStayRepository;
import com.hospital.dashboard.repository.MedicalActRepository;
import com.hospital.dashboard.repository.PersonnelRepository;
import com.hospital.dashboard.model.Personnel;
import org.apache.commons.math3.stat.regression.SimpleRegression;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
public class ForecastServiceV2 {

    @Autowired
    private MedicalActRepository medicalActRepository;
    @Autowired
    private ConsumableRepository consumableRepository;
    @Autowired
    private HospitalStayRepository stayRepository;
    @Autowired
    private PersonnelRepository personnelRepository;
    @Autowired
    private RevenueService revenueService;

    public Map<String, Object> getGlobalForecast(int days) {
        // Increase daily resolution threshold to cover 90 days
        boolean isDaily = days <= 120;
        Map<String, Object> response = new HashMap<>();

        // 1. Predictions per category
        Map<String, Object> medicalActsData = predictMedicalActsCosts(days, isDaily);
        response.put("medicalActs", medicalActsData);

        Map<String, Object> consumablesData = predictConsumablesCosts(days, isDaily);
        response.put("consumables", consumablesData);

        Map<String, Object> staysData = predictStaysCosts(days, isDaily);
        response.put("stays", staysData);

        // 2. Global Totals
        BigDecimal totalCurrent = ((BigDecimal) medicalActsData.get("currentTotal"))
                .add((BigDecimal) consumablesData.get("currentTotal"))
                .add((BigDecimal) staysData.get("currentTotal"));

        // Add Personnel Cost (Base Load)
        BigDecimal dailyPersonnelCost = personnelRepository.findAll().stream()
                .map(Personnel::getCostPerDay)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // Add 30 days of personnel cost to current total (to match DashboardService
        // logic)
        totalCurrent = totalCurrent.add(dailyPersonnelCost.multiply(BigDecimal.valueOf(30)));

        BigDecimal totalPredicted = ((BigDecimal) medicalActsData.get("predictedTotal"))
                .add((BigDecimal) consumablesData.get("predictedTotal"))
                .add((BigDecimal) staysData.get("predictedTotal"));

        // Add 30 days of personnel cost to predicted total
        totalPredicted = totalPredicted.add(dailyPersonnelCost.multiply(BigDecimal.valueOf(30)));

        response.put("globalTotal", totalCurrent);
        response.put("globalPrediction", totalPredicted);

        // 3. Aggregate Global History (Real + Predicted)
        Object actsHistoryRaw = medicalActsData.get("history");
        Object consHistoryRaw = consumablesData.get("history");
        Object staysHistoryRaw = staysData.get("history");

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> actsHistory = actsHistoryRaw instanceof List
                ? (List<Map<String, Object>>) actsHistoryRaw
                : new ArrayList<>();
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> consHistory = consHistoryRaw instanceof List
                ? (List<Map<String, Object>>) consHistoryRaw
                : new ArrayList<>();
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> staysHistory = staysHistoryRaw instanceof List
                ? (List<Map<String, Object>>) staysHistoryRaw
                : new ArrayList<>();

        // Merge all histories by date/month
        Map<String, Map<String, BigDecimal>> mergedMap = new TreeMap<>();
        mergeHistory(mergedMap, actsHistory);
        mergeHistory(mergedMap, consHistory);
        mergeHistory(mergedMap, staysHistory);

        List<Map<String, Object>> globalHistory = new ArrayList<>();
        for (Map.Entry<String, Map<String, BigDecimal>> entry : mergedMap.entrySet()) {
            Map<String, Object> point = new HashMap<>();
            point.put("month", entry.getKey()); // "month" key kept for compatibility, but contains date if daily
            // Only put "real" if it exists, otherwise leave entirely out (undefined in JS)
            BigDecimal realVal = entry.getValue().get("real");
            BigDecimal predVal = entry.getValue().get("predicted");
            BigDecimal basePred = predVal != null ? predVal : BigDecimal.ZERO;

            // Add personnel baseline
            // If isDaily, add 1 day cost. If monthly, add ~30 days cost.
            BigDecimal personnelAdder = isDaily ? dailyPersonnelCost
                    : dailyPersonnelCost.multiply(BigDecimal.valueOf(30));

            if (realVal != null) {
                // Add personnel cost to Real
                realVal = realVal.add(personnelAdder);
                point.put("real", realVal);
                point.put("cost", realVal);
            }

            // Add personnel cost to Predicted
            basePred = basePred.add(personnelAdder);
            point.put("predicted", basePred);

            globalHistory.add(point);
        }
        response.put("globalHistory", globalHistory);

        return response;
    }

    private void mergeHistory(Map<String, Map<String, BigDecimal>> target, List<Map<String, Object>> source) {
        if (source == null)
            return;
        for (Map<String, Object> item : source) {
            String key = (String) item.get("month"); // Date key
            BigDecimal real = (BigDecimal) item.get("real");
            BigDecimal predicted = (BigDecimal) item.get("predicted");

            target.putIfAbsent(key, new HashMap<>());
            Map<String, BigDecimal> prices = target.get(key);

            if (real != null) {
                prices.merge("real", real, BigDecimal::add);
            }
            if (predicted != null) {
                prices.merge("predicted", predicted, BigDecimal::add);
            }
        }
    }

    private Map<String, Object> predictMedicalActsCosts(int days, boolean isDaily) {
        List<MedicalAct> acts = medicalActRepository.findAll();
        return calculatePrediction(acts, MedicalAct::getDate, MedicalAct::getCost, days, isDaily);
    }

    private Map<String, Object> predictConsumablesCosts(int days, boolean isDaily) {
        List<Consumable> consumables = consumableRepository.findAll();
        return calculatePrediction(consumables, Consumable::getDate, Consumable::getTotalCost, days, isDaily);
    }

    private Map<String, Object> predictStaysCosts(int days, boolean isDaily) {
        List<HospitalStay> stays = stayRepository.findAll();
        return calculatePrediction(stays, HospitalStay::getStartDate,
                stay -> revenueService.calculateStayRevenue(stay), days, isDaily);
    }

    private <T> Map<String, Object> calculatePrediction(List<T> items,
            java.util.function.Function<T, LocalDate> dateExtractor,
            java.util.function.Function<T, BigDecimal> costExtractor,
            int daysToPredict, boolean isDaily) {

        Map<String, Object> result = new HashMap<>();

        // 1. Group Data & Calculate Seasonality
        Map<String, BigDecimal> groupedCosts = new TreeMap<>();
        BigDecimal currentTotal = BigDecimal.ZERO;

        // Seasonality Helpers
        Map<java.time.DayOfWeek, List<BigDecimal>> dayOfWeekValues = new EnumMap<>(java.time.DayOfWeek.class);
        for (java.time.DayOfWeek day : java.time.DayOfWeek.values()) {
            dayOfWeekValues.put(day, new ArrayList<>());
        }

        DateTimeFormatter formatter = isDaily ? DateTimeFormatter.ISO_LOCAL_DATE
                : DateTimeFormatter.ofPattern("yyyy-MM");

        for (T item : items) {
            LocalDate date = dateExtractor.apply(item);
            BigDecimal cost = costExtractor.apply(item);

            if (date != null && cost != null) {
                String key = date.format(formatter);
                groupedCosts.merge(key, cost, BigDecimal::add);
                currentTotal = currentTotal.add(cost);

                // Collect for seasonality (only makes sense for Daily)
                if (isDaily) {
                    dayOfWeekValues.get(date.getDayOfWeek()).add(cost);
                }
            }
        }

        // Calculate Seasonality Indices
        Map<java.time.DayOfWeek, Double> seasonalityIndices = new EnumMap<>(java.time.DayOfWeek.class);
        if (isDaily && !groupedCosts.isEmpty()) {
            BigDecimal globalSum = BigDecimal.ZERO;
            long globalCount = 0;

            // Calculate Global Average
            for (BigDecimal val : groupedCosts.values()) {
                globalSum = globalSum.add(val);
                globalCount++;
            }
            double globalAvg = globalCount > 0 ? globalSum.doubleValue() / globalCount : 0;

            // Calculate Index per Day
            for (java.time.DayOfWeek day : java.time.DayOfWeek.values()) {
                List<BigDecimal> values = dayOfWeekValues.get(day);
                if (values.isEmpty()) {
                    seasonalityIndices.put(day, 1.0); // Neutral
                } else {
                    double daySum = values.stream().mapToDouble(BigDecimal::doubleValue).sum();
                    double dayAvg = daySum / values.size();
                    double index = (globalAvg != 0) ? (dayAvg / globalAvg) : 1.0;
                    // Dampen the index specifically for the graph to not go to 0 completely (e.g.
                    // min 0.2)
                    // If index is < 0.2, likely missing data, boost it a bit for smoothing or keep
                    // raw.
                    // Let's keep raw but safeguard against extreme 0s if broad history suggests
                    // otherwise.
                    seasonalityIndices.put(day, index);
                }
            }
        }

        // 2. Regression
        SimpleRegression regression = new SimpleRegression();
        List<Map<String, Object>> history = new ArrayList<>();

        long firstTime = -1;

        for (Map.Entry<String, BigDecimal> entry : groupedCosts.entrySet()) {
            double xVal;
            if (isDaily) {
                xVal = LocalDate.parse(entry.getKey(), formatter).toEpochDay();
            } else {
                String[] parts = entry.getKey().split("-");
                xVal = (double) Integer.parseInt(parts[0]) * 12 + Integer.parseInt(parts[1]);
            }

            if (firstTime == -1)
                firstTime = (long) xVal;

            regression.addData(xVal, entry.getValue().doubleValue());
        }

        // 3. Build History
        // Filter Logic
        LocalDate limitDate = LocalDate.now().minusDays(daysToPredict);
        if (!isDaily) {
            limitDate = LocalDate.now().minusMonths(daysToPredict / 30);
        }

        for (Map.Entry<String, BigDecimal> entry : groupedCosts.entrySet()) {
            double xVal;
            LocalDate entryDate;
            if (isDaily) {
                entryDate = LocalDate.parse(entry.getKey(), formatter);
                xVal = entryDate.toEpochDay();
            } else {
                String[] parts = entry.getKey().split("-");
                entryDate = LocalDate.of(Integer.parseInt(parts[0]), Integer.parseInt(parts[1]), 1);
                xVal = (double) Integer.parseInt(parts[0]) * 12 + Integer.parseInt(parts[1]);
            }

            // FILTER APPLIED HERE
            if (entryDate.isBefore(limitDate)) {
                continue;
            }

            // Raw Regression Prediction
            double trend = regression.predict(xVal);

            // Apply Seasonality (Back-test on history to see fit)
            double predicted = trend;
            if (isDaily && seasonalityIndices.containsKey(entryDate.getDayOfWeek())) {
                predicted *= seasonalityIndices.get(entryDate.getDayOfWeek());
            }

            Map<String, Object> point = new HashMap<>();
            point.put("month", entry.getKey());
            point.put("real", entry.getValue());
            point.put("predicted", BigDecimal.valueOf(Math.max(0, predicted)));

            history.add(point);
        }

        // 4. Future Predictions
        double totalFuturePredicted = 0.0;
        long lastX = -1;
        if (!groupedCosts.isEmpty()) {
            String lastKey = ((TreeMap<String, BigDecimal>) groupedCosts).lastKey();
            if (isDaily) {
                lastX = LocalDate.parse(lastKey, formatter).toEpochDay();
            } else {
                String[] parts = lastKey.split("-");
                lastX = (long) Integer.parseInt(parts[0]) * 12 + Integer.parseInt(parts[1]);
            }
        }

        int steps = isDaily ? daysToPredict : (int) Math.ceil(daysToPredict / 30.0);

        if (lastX != -1) {
            for (int i = 1; i <= steps; i++) {
                double trend = regression.predict((double) lastX + i);
                double val = trend;

                // Smart Seasonality for Future
                if (isDaily) {
                    LocalDate futureDate = LocalDate.ofEpochDay(lastX + i);
                    if (seasonalityIndices.containsKey(futureDate.getDayOfWeek())) {
                        val *= seasonalityIndices.get(futureDate.getDayOfWeek());
                    }
                }

                totalFuturePredicted += Math.max(0, val);

                // Add Future Points to History
                Map<String, Object> futurePoint = new HashMap<>();
                String label;
                if (isDaily) {
                    label = LocalDate.ofEpochDay(lastX + i).format(formatter);
                } else {
                    long futureMonthIndex = lastX + i;
                    long year = futureMonthIndex / 12;
                    long month = futureMonthIndex % 12;
                    if (month == 0) {
                        month = 12;
                        year--;
                    }
                    label = String.format("%d-%02d", year, month);
                }

                futurePoint.put("month", label);
                // "real" key allows visualized continuity on frontend graph
                futurePoint.put("predicted", BigDecimal.valueOf(Math.max(0, val)));
                futurePoint.put("isPrediction", true);

                history.add(futurePoint);
            }
        }

        result.put("currentTotal", currentTotal);
        result.put("predictedTotal", BigDecimal.valueOf(totalFuturePredicted));
        result.put("history", history);

        // Explainability Metrics
        Map<String, Object> methodology = new HashMap<>();
        methodology.put("slope", regression.getSlope());
        methodology.put("seasonality", seasonalityIndices);
        result.put("methodology", methodology);

        return result;
    }
}
