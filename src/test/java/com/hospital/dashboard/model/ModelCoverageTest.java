package com.hospital.dashboard.model;

import org.junit.jupiter.api.Test;
import java.math.BigDecimal;
import java.time.LocalDate;
import static org.junit.jupiter.api.Assertions.*;

class ModelCoverageTest {

    @Test
    void testConsumable() {
        Consumable c1 = new Consumable();
        c1.setId(1L);
        c1.setQuantity(5);
        c1.setDate(LocalDate.now());
        c1.setTotalCost(BigDecimal.TEN);

        assertEquals(1L, c1.getId());
        assertEquals(5, c1.getQuantity());
        assertNotNull(c1.getDate());
        assertEquals(BigDecimal.TEN, c1.getTotalCost());

        Consumable c2 = new Consumable(1L, null, 5, LocalDate.now(), null, BigDecimal.TEN);
        assertNotNull(c2);
    }

    @Test
    void testHospitalStay() {
        HospitalStay s = new HospitalStay();
        s.setId(1L);
        s.setPathology("Flu");
        s.setDailyRate(BigDecimal.TEN);

        assertEquals(1L, s.getId());
        assertEquals("Flu", s.getPathology());
        assertEquals(BigDecimal.TEN, s.getDailyRate());

        HospitalStay s2 = new HospitalStay(1L, null, LocalDate.now(), LocalDate.now(), BigDecimal.TEN, "Flu");
        assertNotNull(s2);
    }

    @Test
    void testMedicalAct() {
        MedicalAct m = new MedicalAct();
        m.setId(1L);
        m.setType("Surgery");
        m.setPractitioner("Dr. House");

        assertEquals(1L, m.getId());
        assertEquals("Surgery", m.getType());
        assertEquals("Dr. House", m.getPractitioner());

        MedicalAct m2 = new MedicalAct(1L, "Surgery", LocalDate.now(), null, "Dr. House", BigDecimal.TEN);
        assertNotNull(m2);
    }

    @Test
    void testMedication() {
        Medication m = new Medication();
        m.setId(1L);
        m.setName("Pill");
        m.setStock(10);

        assertEquals(1L, m.getId());
        assertEquals("Pill", m.getName());
        assertEquals(10, m.getStock());

        Medication m2 = new Medication(1L, "Pill", "Cat", BigDecimal.ONE, 10, "Box");
        assertNotNull(m2);
    }

    @Test
    void testPatient() {
        Patient p = new Patient();
        p.setId(1L);
        p.setFirstName("John");
        p.setLastName("Doe");

        assertEquals(1L, p.getId());
        assertEquals("John", p.getFirstName());
        assertEquals("Doe", p.getLastName());

        Patient p2 = new Patient(1L, "John", "Doe", "123", LocalDate.now());
        assertNotNull(p2);
    }

    @Test
    void testPersonnel() {
        Personnel p = new Personnel();
        p.setId(1L);
        p.setName("Nurse Joy");
        p.setRole("NURSE");

        assertEquals(1L, p.getId());
        assertEquals("Nurse Joy", p.getName());
        assertEquals("NURSE", p.getRole());

        Personnel p2 = new Personnel(1L, "Nurse Joy", "NURSE", "ER", BigDecimal.TEN, "email", "phone");
        assertNotNull(p2);
    }
}
