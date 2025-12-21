package com.hospital.dashboard.controller;

import com.hospital.dashboard.model.Consumable;
import com.hospital.dashboard.repository.ConsumableRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

@RestController
@RequestMapping("/api/consumables")

public class ConsumableController extends BaseController<Consumable, Long> {

    @Autowired
    private ConsumableRepository consumableRepository;

    @Override
    protected JpaRepository<Consumable, Long> getRepository() {
        return consumableRepository;
    }

    @PutMapping("/{id}")
    public Consumable updateConsumable(@PathVariable Long id, @RequestBody Consumable consumableDetails) {
        Consumable consumable = consumableRepository.findById(id).orElseThrow();
        consumable.setMedication(consumableDetails.getMedication());
        consumable.setQuantity(consumableDetails.getQuantity());
        consumable.setDate(consumableDetails.getDate());
        consumable.setPatient(consumableDetails.getPatient());
        consumable.setTotalCost(consumableDetails.getTotalCost());
        return consumableRepository.save(consumable);
    }
}
