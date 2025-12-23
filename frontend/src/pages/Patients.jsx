import React, { useState, useEffect } from 'react';
import {
  Box, Typography, Button, TextField, MenuItem, Table, TableBody, TableCell,
  TableContainer, TableHead, TableRow, Paper, IconButton, Chip, Stack, InputAdornment,
  Dialog, DialogTitle, DialogContent, DialogActions
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import SearchIcon from '@mui/icons-material/Search';
import FilterListIcon from '@mui/icons-material/FilterList';
import FileDownloadIcon from '@mui/icons-material/FileDownload';
import EditIcon from '@mui/icons-material/Edit';
import DeleteOutlineIcon from '@mui/icons-material/DeleteOutline';
import DeleteConfirmationDialog from '../components/DeleteConfirmationDialog';
import patientService from '../services/patientService';

const Patients = () => {
  const [patients, setPatients] = useState([]);
  const [open, setOpen] = useState(false);
  const [currentPatient, setCurrentPatient] = useState({ firstName: '', lastName: '', birthDate: '', ssn: '' });
  const [isEdit, setIsEdit] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    fetchPatients();
  }, []);

  const fetchPatients = async () => {
    try {
      const data = await patientService.getAllPatients();
      setPatients(data);
    } catch (error) {
      console.error("Error fetching patients:", error);
    }
  };

  const handleOpen = (patient = null) => {
    if (patient) {
      setCurrentPatient(patient);
      setIsEdit(true);
    } else {
      setCurrentPatient({ firstName: '', lastName: '', birthDate: '', ssn: '' });
      setIsEdit(false);
    }
    setOpen(true);
  };

  const handleClose = () => {
    setOpen(false);
  };

  const handleSave = async () => {
    try {
      if (isEdit) {
        await patientService.updatePatient(currentPatient.id, currentPatient);
      } else {
        await patientService.createPatient(currentPatient);
      }
      fetchPatients();
      handleClose();
    } catch (error) {
      console.error("Error saving patient:", error);
    }
  };

  // Delete Dialog Handling
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [patientToDelete, setPatientToDelete] = useState(null);

  const handleDeleteClick = (patient) => {
    setPatientToDelete(patient);
    setDeleteDialogOpen(true);
  };

  const handleConfirmDelete = async () => {
    if (patientToDelete) {
      try {
        await patientService.deletePatient(patientToDelete.id);
        fetchPatients();
      } catch (error) {
        console.error("Error deleting patient:", error);
      }
    }
    setDeleteDialogOpen(false);
    setPatientToDelete(null);
  };

  const handleCancelDelete = () => {
    setDeleteDialogOpen(false);
    setPatientToDelete(null);
  };

  const filteredPatients = patients.filter(patient =>
    `${patient.firstName} ${patient.lastName}`.toLowerCase().includes(searchTerm.toLowerCase()) ||
    patient.ssn?.includes(searchTerm)
  );

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Box>
          <Typography variant="h4" gutterBottom sx={{ color: 'text.primary', fontWeight: 700 }}>
            Gestion des patients
          </Typography>
          <Typography variant="body1" color="text.secondary">
            {patients.length} patients enregistrés
          </Typography>
        </Box>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => handleOpen()}
          sx={{ bgcolor: 'primary.dark', '&:hover': { bgcolor: 'black' }, textTransform: 'none', borderRadius: 2, px: 3 }}
        >
          Nouveau patient
        </Button>
      </Box>

      <Paper sx={{ p: 2, mb: 4, display: 'flex', gap: 2, alignItems: 'center', borderRadius: 3, boxShadow: '0px 2px 10px rgba(0,0,0,0.02)' }}>
        <TextField
          placeholder="Rechercher par nom, ID ou assurance..."
          variant="outlined"
          size="small"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          sx={{ flexGrow: 1, '& .MuiOutlinedInput-root': { borderRadius: 2, bgcolor: '#F8FAFC' } }}
          InputProps={{ startAdornment: (<InputAdornment position="start"><SearchIcon color="action" /></InputAdornment>) }}
        />
        <Button variant="outlined" startIcon={<FilterListIcon />} sx={{ borderRadius: 2, textTransform: 'none', color: 'text.primary', borderColor: '#E2E8F0' }}>Filtrer</Button>
        <Button variant="outlined" startIcon={<FileDownloadIcon />} sx={{ borderRadius: 2, textTransform: 'none', color: 'text.primary', borderColor: '#E2E8F0' }}>Exporter</Button>
      </Paper>

      <TableContainer component={Paper} sx={{ borderRadius: 3, boxShadow: '0px 2px 10px rgba(0,0,0,0.02)' }}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>ID</TableCell>
              <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>NOM COMPLET</TableCell>
              <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>DATE DE NAISSANCE</TableCell>
              <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>SSN</TableCell>
              <TableCell align="right" sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>ACTIONS</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredPatients.map((patient) => (
              <TableRow key={patient.id} hover>
                <TableCell sx={{ color: 'text.secondary' }}>P{patient.id}</TableCell>
                <TableCell sx={{ fontWeight: 500 }}>{patient.firstName} {patient.lastName}</TableCell>
                <TableCell sx={{ color: 'text.secondary' }}>{patient.birthDate}</TableCell>
                <TableCell sx={{ color: 'text.secondary' }}>{patient.ssn}</TableCell>
                <TableCell align="right">
                  <Stack direction="row" spacing={1} justifyContent="flex-end">
                    <IconButton size="small" onClick={() => handleOpen(patient)} sx={{ color: 'primary.main', bgcolor: '#EFF6FF', borderRadius: 1 }}><EditIcon fontSize="small" /></IconButton>
                    <IconButton size="small" onClick={() => handleDeleteClick(patient)} sx={{ color: 'error.main', bgcolor: '#FEF2F2', borderRadius: 1 }}><DeleteOutlineIcon fontSize="small" /></IconButton>
                  </Stack>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      <Dialog open={open} onClose={handleClose}>
        <DialogTitle>{isEdit ? 'Modifier le patient' : 'Nouveau patient'}</DialogTitle>
        <DialogContent>
          <TextField
            autoFocus
            margin="dense"
            label="Prénom"
            fullWidth
            value={currentPatient.firstName}
            onChange={(e) => setCurrentPatient({ ...currentPatient, firstName: e.target.value })}
          />
          <TextField
            margin="dense"
            label="Nom"
            fullWidth
            value={currentPatient.lastName}
            onChange={(e) => setCurrentPatient({ ...currentPatient, lastName: e.target.value })}
          />
          <TextField
            margin="dense"
            label="Date de Naissance"
            type="date"
            fullWidth
            InputLabelProps={{ shrink: true }}
            value={currentPatient.birthDate}
            onChange={(e) => setCurrentPatient({ ...currentPatient, birthDate: e.target.value })}
          />
          <TextField
            margin="dense"
            label="Numéro de Sécurité Sociale"
            fullWidth
            value={currentPatient.ssn}
            onChange={(e) => setCurrentPatient({ ...currentPatient, ssn: e.target.value })}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={handleClose}>Annuler</Button>
          <Button onClick={handleSave} variant="contained">Enregistrer</Button>
        </DialogActions>
      </Dialog>
      <DeleteConfirmationDialog
        open={deleteDialogOpen}
        onClose={handleCancelDelete}
        onConfirm={handleConfirmDelete}
        itemName={patientToDelete ? `${patientToDelete.firstName} ${patientToDelete.lastName}` : null}
      />
    </Box>
  );
};

export default Patients;
