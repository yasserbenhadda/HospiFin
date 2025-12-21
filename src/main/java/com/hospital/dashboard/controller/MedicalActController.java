package com.hospital.dashboard.controller;

import com.hospital.dashboard.model.MedicalAct;
import com.hospital.dashboard.repository.MedicalActRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

@RestController
@RequestMapping("/api/medical-acts")

public class MedicalActController extends BaseController<MedicalAct, Long> {

    @Autowired
    private MedicalActRepository medicalActRepository;

    @Override
    protected JpaRepository<MedicalAct, Long> getRepository() {
        return medicalActRepository;
    }

    @PutMapping("/{id}")
    public MedicalAct updateMedicalAct(@PathVariable Long id, @RequestBody MedicalAct medicalActDetails) {
        MedicalAct medicalAct = medicalActRepository.findById(id).orElseThrow();
        medicalAct.setType(medicalActDetails.getType());
        medicalAct.setDate(medicalActDetails.getDate());
        medicalAct.setPatient(medicalActDetails.getPatient());
        medicalAct.setPractitioner(medicalActDetails.getPractitioner());
        medicalAct.setCost(medicalActDetails.getCost());
        return medicalActRepository.save(medicalAct);
    }
}
