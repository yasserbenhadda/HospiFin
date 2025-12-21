package com.hospital.dashboard.service;

import com.hospital.dashboard.model.HospitalStay;
import com.hospital.dashboard.repository.HospitalStayRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
public class RevenueService {

    @Autowired
    private HospitalStayRepository stayRepository;

    public BigDecimal calculateTotalRevenue() {
        List<HospitalStay> stays = stayRepository.findAll();
        return stays.stream()
                .map(this::calculateStayRevenue)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public BigDecimal calculateStayRevenue(HospitalStay stay) {
        if (stay.getStartDate() == null || stay.getEndDate() == null || stay.getDailyRate() == null) {
            return BigDecimal.ZERO;
        }
        long days = ChronoUnit.DAYS.between(stay.getStartDate(), stay.getEndDate());
        if (days == 0)
            days = 1; // Minimum 1 day charge
        return stay.getDailyRate().multiply(BigDecimal.valueOf(days));
    }
}
