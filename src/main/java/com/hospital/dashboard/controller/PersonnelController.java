package com.hospital.dashboard.controller;

import com.hospital.dashboard.model.Personnel;
import com.hospital.dashboard.repository.PersonnelRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

@RestController
@RequestMapping("/api/personnel")

public class PersonnelController extends BaseController<Personnel, Long> {

    @Autowired
    private PersonnelRepository personnelRepository;

    @Override
    protected JpaRepository<Personnel, Long> getRepository() {
        return personnelRepository;
    }

    @PutMapping("/{id}")
    public Personnel updatePersonnel(@PathVariable Long id, @RequestBody Personnel personnelDetails) {
        Personnel personnel = personnelRepository.findById(id).orElseThrow();
        personnel.setName(personnelDetails.getName());
        personnel.setRole(personnelDetails.getRole());
        personnel.setService(personnelDetails.getService());
        personnel.setCostPerDay(personnelDetails.getCostPerDay());
        personnel.setEmail(personnelDetails.getEmail());
        personnel.setPhone(personnelDetails.getPhone());
        return personnelRepository.save(personnel);
    }

    @GetMapping("/current")
    public Personnel getCurrentPersonnel() {
        // For now, we simulate the current user as the first one or a specific default
        // one
        return personnelRepository.findById(1L).orElseGet(() -> {
            Personnel defaultUser = new Personnel();
            defaultUser.setName("Sophie Martin");
            defaultUser.setRole("ADMIN");
            defaultUser.setService("Administration");
            defaultUser.setEmail("dr.sophie.martin@hopital.fr");
            defaultUser.setPhone("+33 1 23 45 67 89");
            defaultUser.setCostPerDay(java.math.BigDecimal.ZERO);
            return personnelRepository.save(defaultUser);
        });
    }
}
