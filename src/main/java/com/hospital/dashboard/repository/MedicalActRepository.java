package com.hospital.dashboard.repository;

import com.hospital.dashboard.model.MedicalAct;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MedicalActRepository extends JpaRepository<MedicalAct, Long> {
}
