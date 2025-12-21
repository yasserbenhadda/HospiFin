package com.hospital.dashboard.config;

import com.hospital.dashboard.model.Patient;
import com.hospital.dashboard.model.Personnel;
import com.hospital.dashboard.repository.*;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.Collections;

import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class DataSeederTest {

    @Mock
    private PatientRepository patientRepository;
    @Mock
    private HospitalStayRepository stayRepository;
    @Mock
    private MedicalActRepository medicalActRepository;
    @Mock
    private MedicationRepository medicationRepository;
    @Mock
    private ConsumableRepository consumableRepository;
    @Mock
    private PersonnelRepository personnelRepository;

    @InjectMocks
    private DataSeeder dataSeeder;

    @Test
    void testRun_EmptyDatabase() throws Exception {
        when(personnelRepository.findByEmail(anyString())).thenReturn(null);
        when(patientRepository.count()).thenReturn(0L);

        // Mock finding seed data later in the process
        Patient mockPatient = new Patient();
        mockPatient.setFirstName("Test");

        Personnel mockPersonnel = new Personnel();
        mockPersonnel.setName("Dr. Test");

        com.hospital.dashboard.model.Medication mockMedication = new com.hospital.dashboard.model.Medication();
        mockMedication.setUnitCost(BigDecimal.TEN);

        when(patientRepository.findAll()).thenReturn(Arrays.asList(mockPatient));
        when(personnelRepository.findAll()).thenReturn(Arrays.asList(mockPersonnel));
        when(medicationRepository.findAll()).thenReturn(Arrays.asList(mockMedication));

        dataSeeder.run();

        verify(patientRepository, times(1)).saveAll(anyList());
        verify(personnelRepository, times(1)).saveAll(anyList());
        verify(medicationRepository, times(2)).saveAll(anyList());
    }

    @Test
    void testRun_CleanupScenario() throws Exception {
        // Condition: Existing legacy data detected
        when(personnelRepository.findByEmail("house@hospital.com")).thenReturn(new Personnel());

        // Mock finding seed data later in the process
        Patient mockPatient = new Patient();
        mockPatient.setFirstName("Test");

        Personnel mockPersonnel = new Personnel();
        mockPersonnel.setName("Dr. Test");

        com.hospital.dashboard.model.Medication mockMedication = new com.hospital.dashboard.model.Medication();
        mockMedication.setUnitCost(BigDecimal.TEN);

        when(patientRepository.findAll()).thenReturn(Arrays.asList(mockPatient));
        when(personnelRepository.findAll()).thenReturn(Arrays.asList(mockPersonnel));
        when(medicationRepository.findAll()).thenReturn(Arrays.asList(mockMedication));

        dataSeeder.run();

        // Should trigger delete calls
        verify(consumableRepository).deleteAll();
        verify(medicalActRepository).deleteAll();
        verify(stayRepository).deleteAll();
        verify(medicationRepository).deleteAll();
        verify(personnelRepository).deleteAll();
        verify(patientRepository).deleteAll();

        // And then seed
        verify(patientRepository, times(1)).saveAll(anyList());
    }
}
