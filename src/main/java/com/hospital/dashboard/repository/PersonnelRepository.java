package com.hospital.dashboard.repository;

import com.hospital.dashboard.model.Personnel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PersonnelRepository extends JpaRepository<Personnel, Long> {
    Personnel findByEmail(String email);
}
