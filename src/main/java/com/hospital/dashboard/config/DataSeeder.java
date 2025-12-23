package com.hospital.dashboard.config;

import com.hospital.dashboard.model.*;
import com.hospital.dashboard.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;

import java.util.concurrent.ThreadLocalRandom;

@Component
public class DataSeeder implements CommandLineRunner {

        @Autowired
        private PatientRepository patientRepository;
        @Autowired
        private HospitalStayRepository stayRepository;
        @Autowired
        private MedicalActRepository medicalActRepository;
        @Autowired
        private MedicationRepository medicationRepository;
        @Autowired
        private ConsumableRepository consumableRepository;
        @Autowired
        private PersonnelRepository personnelRepository;

        private final java.security.SecureRandom random = new java.security.SecureRandom();

        @Override
        public void run(String... args) throws Exception {
                if (personnelRepository.findByEmail("house@hospital.com") != null || patientRepository.count() > 0) {
                        System.out.println("Cleaning up old random data to inject realistic trends...");
                        consumableRepository.deleteAll();
                        medicalActRepository.deleteAll();
                        stayRepository.deleteAll();
                        medicationRepository.deleteAll();
                        personnelRepository.deleteAll();
                        patientRepository.deleteAll();
                }

                if (patientRepository.count() == 0) {
                        seedPatients();
                        seedPersonnel();
                        seedMedications();
                        seedAdditionalMedications();
                        seedRealisticHistoricalData();
                }
        }

        private void seedPatients() {
                patientRepository.saveAll(Arrays.asList(
                                new Patient(null, "Jean", "Dupont", "1234567890123", LocalDate.of(1980, 5, 15)),
                                new Patient(null, "Marie", "Curie", "2345678901234", LocalDate.of(1975, 11, 7)),
                                new Patient(null, "Pierre", "Martin", "3456789012345", LocalDate.of(1990, 2, 20)),
                                new Patient(null, "Sophie", "Durand", "4567890123456", LocalDate.of(2001, 8, 30))));
        }

        private void seedPersonnel() {
                personnelRepository.saveAll(Arrays.asList(
                                new Personnel(null, "Dr. Sophie Martin", "ADMIN", "Administration",
                                                new BigDecimal("500.00"), "sophie.martin@hospital.com",
                                                "01 23 45 67 89"),
                                new Personnel(null, "Dr. Gregory House", "DOCTEUR", "Diagnostic",
                                                new BigDecimal("800.00"),
                                                "house@hospital.com", "06 12 34 56 78"),
                                new Personnel(null, "Isabelle Dubois", "INFIRMIÈRE", "Urgences",
                                                new BigDecimal("300.00"),
                                                "isabelle.dubois@hospital.com", "06 98 76 54 32"),
                                new Personnel(null, "Dr. Stephen Strange", "CHIRURGIEN", "Chirurgie",
                                                new BigDecimal("900.00"),
                                                "strange@hospital.com", "07 11 22 33 44"),
                                new Personnel(null, "Marc Levy", "ANESTHÉSISTE", "Bloc Opératoire",
                                                new BigDecimal("750.00"),
                                                "marc.levy@hospital.com", "06 55 44 33 22"),
                                new Personnel(null, "Claire Redfield", "AIDE-SOIGNANTE", "Gériatrie",
                                                new BigDecimal("250.00"),
                                                "claire.redfield@hospital.com", "07 88 99 00 11")));
        }

        private void seedMedications() {
                medicationRepository.saveAll(Arrays.asList(
                                new Medication(null, "Paracetamol", "Analgesic", new BigDecimal("5.00"), 100, "Box"),
                                new Medication(null, "Ibuprofen", "Anti-inflammatory", new BigDecimal("8.00"), 50,
                                                "Box"),
                                new Medication(null, "Amoxicillin", "Antibiotic", new BigDecimal("12.00"), 30, "Box"),
                                new Medication(null, "Spasfon", "Antispasmodic", new BigDecimal("6.00"), 80, "Box")));
        }

        private void seedAdditionalMedications() {
                medicationRepository.saveAll(Arrays.asList(
                                new Medication(null, "Doliprane", "Analgesic", new BigDecimal("2.50"), 200, "Box"),
                                new Medication(null, "Smecta", "Digestive", new BigDecimal("6.50"), 100, "Box"),
                                new Medication(null, "Ventolin", "Respiratory", new BigDecimal("15.00"), 40, "Inhaler"),
                                new Medication(null, "Cardioaspirin", "Cardiovascular", new BigDecimal("10.00"), 60,
                                                "Box")));
        }

        private void seedRealisticHistoricalData() {
                List<Patient> patients = patientRepository.findAll();
                List<Medication> medications = medicationRepository.findAll();
                List<Personnel> personnelList = personnelRepository.findAll();

                LocalDate endDate = LocalDate.now();
                LocalDate startDate = endDate.minusMonths(6);
                long totalDays = java.time.temporal.ChronoUnit.DAYS.between(startDate, endDate);

                for (int i = 0; i <= totalDays; i++) {
                        LocalDate date = startDate.plusDays(i);

                        // Trend Logic: 30% growth over 6 months, weekends lower
                        double progress = (double) i / totalDays;
                        double growthFactor = 1.0 + (progress * 0.30);
                        boolean isWeekend = date.getDayOfWeek().getValue() >= 6;
                        double seasonality = isWeekend ? 0.6 : 1.1;
                        double dailyFactor = growthFactor * seasonality;

                        if (random.nextDouble() < (0.3 * dailyFactor)) {
                                createRandomStay(date, patients, dailyFactor);
                        }

                        int actCount = (int) Math.round(random.nextInt(3) * dailyFactor);
                        for (int k = 0; k < actCount; k++) {
                                createRandomMedicalAct(date, patients, personnelList, dailyFactor);
                        }

                        int consCount = (int) Math.round((random.nextInt(4) + 1) * dailyFactor);
                        for (int k = 0; k < consCount; k++) {
                                createRandomConsumable(date, patients, medications, dailyFactor);
                        }
                }
        }

        private void createRandomStay(LocalDate startDate, List<Patient> patients, double priceMultiplier) {
                HospitalStay stay = new HospitalStay(
                                null,
                                getRandom(patients),
                                startDate,
                                startDate.plusDays((long) random.nextInt(8) + 2),
                                generatePrice(150, priceMultiplier, 50),
                                getRandom("Grippe", "Chirurgie orthopédique", "Observation", "Urgences pédiatriques",
                                                "Checkup", "Rééducation"));
                stayRepository.save(stay);
        }

        private void createRandomMedicalAct(LocalDate date, List<Patient> patients, List<Personnel> personnelList,
                        double priceMultiplier) {
                String actType = getRandom("Consultation", "Radio Panoramique", "Prise de sang", "IRM Cérébrale",
                                "Chirurgie cardiaque", "Vaccination");
                int baseCost = switch (actType) {
                        case "Chirurgie cardiaque" -> 500;
                        case "IRM Cérébrale" -> 300;
                        case "Consultation" -> 30;
                        default -> 50;
                };

                MedicalAct act = new MedicalAct(
                                null,
                                actType,
                                date,
                                getRandom(patients),
                                getRandom(personnelList).getName(),
                                generatePrice(baseCost, priceMultiplier, 20));
                medicalActRepository.save(act);
        }

        private void createRandomConsumable(LocalDate date, List<Patient> patients, List<Medication> medications,
                        double priceMultiplier) {
                Medication medication = getRandom(medications);
                int quantity = random.nextInt(3) + 1;
                if (priceMultiplier > 1.2)
                        quantity++;

                Consumable consumable = new Consumable(
                                null,
                                medication,
                                quantity,
                                date,
                                getRandom(patients),
                                medication.getUnitCost().multiply(BigDecimal.valueOf(quantity)));
                consumableRepository.save(consumable);
        }

        private <T> T getRandom(List<T> list) {
                return list.get(random.nextInt(list.size()));
        }

        private String getRandom(String... items) {
                return items[random.nextInt(items.length)];
        }

        private BigDecimal generatePrice(int base, double multiplier, int variance) {
                return BigDecimal.valueOf(base * multiplier + random.nextInt(variance));
        }
}
