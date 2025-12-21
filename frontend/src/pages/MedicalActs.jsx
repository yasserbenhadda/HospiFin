import React, { useState, useEffect } from 'react';
import {
    Box, Typography, Button, TextField, MenuItem, Table, TableBody, TableCell,
    TableContainer, TableHead, TableRow, Paper, IconButton, Stack, InputAdornment,
    Dialog, DialogTitle, DialogContent, DialogActions
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import SearchIcon from '@mui/icons-material/Search';
import FilterListIcon from '@mui/icons-material/FilterList';
import FileDownloadIcon from '@mui/icons-material/FileDownload';
import EditIcon from '@mui/icons-material/Edit';
import DeleteOutlineIcon from '@mui/icons-material/DeleteOutline';
import VisibilityIcon from '@mui/icons-material/Visibility';
import medicalActService from '../services/medicalActService';
import patientService from '../services/patientService';

const MedicalActs = () => {
    const [acts, setActs] = useState([]);
    const [patients, setPatients] = useState([]);
    const [open, setOpen] = useState(false);
    const [currentAct, setCurrentAct] = useState({ type: '', date: '', patient: null, practitioner: '', cost: '' });
    const [isEdit, setIsEdit] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        fetchActs();
        fetchPatients();
    }, []);

    const fetchActs = async () => {
        try {
            const data = await medicalActService.getAllMedicalActs();
            setActs(data);
        } catch (error) {
            console.error("Error fetching medical acts:", error);
        }
    };

    const fetchPatients = async () => {
        try {
            const data = await patientService.getAllPatients();
            setPatients(data);
        } catch (error) {
            console.error("Error fetching patients:", error);
        }
    };

    const handleOpen = (act = null) => {
        if (act) {
            setCurrentAct(act);
            setIsEdit(true);
        } else {
            setCurrentAct({ type: '', date: '', patient: null, practitioner: '', cost: '' });
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
                await medicalActService.updateMedicalAct(currentAct.id, currentAct);
            } else {
                await medicalActService.createMedicalAct(currentAct);
            }
            fetchActs();
            handleClose();
        } catch (error) {
            console.error("Error saving medical act:", error);
        }
    };

    const handleDelete = async (id) => {
        if (window.confirm("Êtes-vous sûr de vouloir supprimer cet acte ?")) {
            try {
                await medicalActService.deleteMedicalAct(id);
                fetchActs();
            } catch (error) {
                console.error("Error deleting medical act:", error);
            }
        }
    };

    const filteredActs = acts.filter(act =>
        act.type.toLowerCase().includes(searchTerm.toLowerCase()) ||
        act.practitioner.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (act.patient && `${act.patient.firstName} ${act.patient.lastName}`.toLowerCase().includes(searchTerm.toLowerCase()))
    );

    return (
        <Box>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
                <Box>
                    <Typography variant="h4" gutterBottom sx={{ color: 'text.primary', fontWeight: 700 }}>
                        Actes médicaux
                    </Typography>
                    <Typography variant="body1" color="text.secondary">
                        {acts.length} actes enregistrés
                    </Typography>
                </Box>
                <Button
                    variant="contained"
                    startIcon={<AddIcon />}
                    onClick={() => handleOpen()}
                    sx={{ bgcolor: 'primary.dark', '&:hover': { bgcolor: 'black' }, textTransform: 'none', borderRadius: 2, px: 3 }}
                >
                    Nouvel acte
                </Button>
            </Box>

            <Paper sx={{ p: 2, mb: 4, display: 'flex', gap: 2, alignItems: 'center', borderRadius: 3, boxShadow: '0px 2px 10px rgba(0,0,0,0.02)' }}>
                <TextField
                    placeholder="Rechercher par type, patient ou praticien..."
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
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>TYPE D'ACTE</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>DATE</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>PATIENT</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>PRATICIEN</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>COÛT</TableCell>
                            <TableCell align="right" sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>ACTIONS</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {filteredActs.map((act) => (
                            <TableRow key={act.id} hover>
                                <TableCell sx={{ color: 'text.secondary' }}>A{act.id}</TableCell>
                                <TableCell sx={{ fontWeight: 500 }}>{act.type}</TableCell>
                                <TableCell sx={{ color: 'text.secondary' }}>{act.date}</TableCell>
                                <TableCell sx={{ color: 'text.secondary' }}>{act.patient ? `${act.patient.firstName} ${act.patient.lastName}` : 'N/A'}</TableCell>
                                <TableCell sx={{ color: 'text.secondary' }}>{act.practitioner}</TableCell>
                                <TableCell sx={{ fontWeight: 600 }}>{act.cost} €</TableCell>
                                <TableCell align="right">
                                    <Stack direction="row" spacing={1} justifyContent="flex-end">
                                        <IconButton size="small" sx={{ color: 'text.secondary' }}><VisibilityIcon fontSize="small" /></IconButton>
                                        <IconButton size="small" onClick={() => handleOpen(act)} sx={{ color: 'primary.main', bgcolor: '#EFF6FF', borderRadius: 1 }}><EditIcon fontSize="small" /></IconButton>
                                        <IconButton size="small" onClick={() => handleDelete(act.id)} sx={{ color: 'error.main', bgcolor: '#FEF2F2', borderRadius: 1 }}><DeleteOutlineIcon fontSize="small" /></IconButton>
                                    </Stack>
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>

            <Dialog open={open} onClose={handleClose}>
                <DialogTitle>{isEdit ? 'Modifier l\'acte' : 'Nouvel acte'}</DialogTitle>
                <DialogContent>
                    <TextField
                        margin="dense"
                        label="Type d'acte"
                        fullWidth
                        value={currentAct.type}
                        onChange={(e) => setCurrentAct({ ...currentAct, type: e.target.value })}
                    />
                    <TextField
                        margin="dense"
                        label="Date"
                        type="date"
                        fullWidth
                        InputLabelProps={{ shrink: true }}
                        value={currentAct.date}
                        onChange={(e) => setCurrentAct({ ...currentAct, date: e.target.value })}
                    />
                    <TextField
                        select
                        margin="dense"
                        label="Patient"
                        fullWidth
                        value={currentAct.patient ? currentAct.patient.id : ''}
                        onChange={(e) => {
                            const selectedPatient = patients.find(p => p.id === e.target.value);
                            setCurrentAct({ ...currentAct, patient: selectedPatient });
                        }}
                    >
                        {patients.map((patient) => (
                            <MenuItem key={patient.id} value={patient.id}>
                                {patient.firstName} {patient.lastName}
                            </MenuItem>
                        ))}
                    </TextField>
                    <TextField
                        margin="dense"
                        label="Praticien"
                        fullWidth
                        value={currentAct.practitioner}
                        onChange={(e) => setCurrentAct({ ...currentAct, practitioner: e.target.value })}
                    />
                    <TextField
                        margin="dense"
                        label="Coût (€)"
                        type="number"
                        fullWidth
                        value={currentAct.cost}
                        onChange={(e) => setCurrentAct({ ...currentAct, cost: e.target.value })}
                    />
                </DialogContent>
                <DialogActions>
                    <Button onClick={handleClose}>Annuler</Button>
                    <Button onClick={handleSave} variant="contained">Enregistrer</Button>
                </DialogActions>
            </Dialog>
        </Box>
    );
};

export default MedicalActs;
