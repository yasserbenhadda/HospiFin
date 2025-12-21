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
public class Consumable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "medication_id")
    private Medication medication;

    private Integer quantity;
    private LocalDate date;

    @ManyToOne
    @JoinColumn(name = "patient_id")
    private Patient patient;

    private BigDecimal totalCost;
}
