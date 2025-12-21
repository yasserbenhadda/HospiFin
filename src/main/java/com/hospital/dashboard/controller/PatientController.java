package com.hospital.dashboard.controller;

import com.hospital.dashboard.model.Patient;
import com.hospital.dashboard.repository.PatientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/patients")

public class PatientController extends BaseController<Patient, Long> {

    @Autowired
    private PatientRepository patientRepository;

    @Override
    protected JpaRepository<Patient, Long> getRepository() {
        return patientRepository;
    }

    @PutMapping("/{id}")
    public Patient updatePatient(@PathVariable Long id, @RequestBody Patient patientDetails) {
        Patient patient = patientRepository.findById(id).orElseThrow();
        patient.setFirstName(patientDetails.getFirstName());
        patient.setLastName(patientDetails.getLastName());
        patient.setSsn(patientDetails.getSsn());
        patient.setBirthDate(patientDetails.getBirthDate());
        return patientRepository.save(patient);
    }
}
