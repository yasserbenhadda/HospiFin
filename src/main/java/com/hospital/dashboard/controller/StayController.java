package com.hospital.dashboard.controller;

import com.hospital.dashboard.model.HospitalStay;
import com.hospital.dashboard.repository.HospitalStayRepository;
import com.hospital.dashboard.service.RevenueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.data.jpa.repository.JpaRepository;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/stays")

public class StayController extends BaseController<HospitalStay, Long> {

    @Autowired
    private HospitalStayRepository stayRepository;

    @Autowired
    private RevenueService revenueService;

    @Override
    protected JpaRepository<HospitalStay, Long> getRepository() {
        return stayRepository;
    }

    @PutMapping("/{id}")
    public HospitalStay updateStay(@PathVariable Long id, @RequestBody HospitalStay stayDetails) {
        HospitalStay stay = stayRepository.findById(id).orElseThrow();
        stay.setPatient(stayDetails.getPatient());
        stay.setStartDate(stayDetails.getStartDate());
        stay.setEndDate(stayDetails.getEndDate());
        stay.setDailyRate(stayDetails.getDailyRate());
        stay.setPathology(stayDetails.getPathology());
        return stayRepository.save(stay);
    }

    @GetMapping("/revenue")
    public BigDecimal getTotalRevenue() {
        return revenueService.calculateTotalRevenue();
    }
}
