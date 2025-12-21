package com.hospital.dashboard.controller;

import com.hospital.dashboard.model.Medication;
import com.hospital.dashboard.repository.MedicationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

@RestController
@RequestMapping("/api/medications")

public class MedicationController extends BaseController<Medication, Long> {

    @Autowired
    private MedicationRepository medicationRepository;

    @Override
    protected JpaRepository<Medication, Long> getRepository() {
        return medicationRepository;
    }

    @PutMapping("/{id}")
    public Medication updateMedication(@PathVariable Long id, @RequestBody Medication medicationDetails) {
        Medication medication = medicationRepository.findById(id).orElseThrow();
        medication.setName(medicationDetails.getName());
        medication.setCategory(medicationDetails.getCategory());
        medication.setUnitCost(medicationDetails.getUnitCost());
        medication.setStock(medicationDetails.getStock());
        medication.setUnit(medicationDetails.getUnit());
        return medicationRepository.save(medication);
    }
}
