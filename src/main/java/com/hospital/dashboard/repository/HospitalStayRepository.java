package com.hospital.dashboard.repository;

import com.hospital.dashboard.model.HospitalStay;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HospitalStayRepository extends JpaRepository<HospitalStay, Long> {
}
