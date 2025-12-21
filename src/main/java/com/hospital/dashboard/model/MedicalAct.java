package com.hospital.dashboard.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDate;
import java.math.BigDecimal;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MedicalAct {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String type;
    private LocalDate date;

    @ManyToOne
    @JoinColumn(name = "patient_id")
    private Patient patient;

    private String practitioner;
    private BigDecimal cost;
}
