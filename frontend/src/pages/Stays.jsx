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
import stayService from '../services/stayService';
import patientService from '../services/patientService';

const Stays = () => {
    const [stays, setStays] = useState([]);
    const [patients, setPatients] = useState([]);
    const [open, setOpen] = useState(false);
    const [currentStay, setCurrentStay] = useState({ patient: null, startDate: '', endDate: '', dailyRate: '', pathology: '' });
    const [isEdit, setIsEdit] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        fetchStays();
        fetchPatients();
    }, []);

    const fetchStays = async () => {
        try {
            const data = await stayService.getAllStays();
            setStays(data);
        } catch (error) {
            console.error("Error fetching stays:", error);
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

    const handleOpen = (stay = null) => {
        if (stay) {
            setCurrentStay(stay);
            setIsEdit(true);
        } else {
            setCurrentStay({ patient: null, startDate: '', endDate: '', dailyRate: '', pathology: '' });
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
                await stayService.updateStay(currentStay.id, currentStay);
            } else {
                await stayService.createStay(currentStay);
            }
            fetchStays();
            handleClose();
        } catch (error) {
            console.error("Error saving stay:", error);
        }
    };

    // Delete Dialog Handling
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
    const [stayToDelete, setStayToDelete] = useState(null);

    const handleDeleteClick = (stay) => {
        setStayToDelete(stay);
        setDeleteDialogOpen(true);
    };

    const handleConfirmDelete = async () => {
        if (stayToDelete) {
            try {
                await stayService.deleteStay(stayToDelete.id);
                fetchStays();
            } catch (error) {
                console.error("Error deleting stay:", error);
            }
        }
        setDeleteDialogOpen(false);
        setStayToDelete(null);
    };

    const handleCancelDelete = () => {
        setDeleteDialogOpen(false);
        setStayToDelete(null);
    };

    const filteredStays = stays.filter(stay =>
        stay.patient?.lastName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        stay.pathology?.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <Box>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
                <Box>
                    <Typography variant="h4" gutterBottom sx={{ color: 'text.primary', fontWeight: 700 }}>
                        Gestion des séjours
                    </Typography>
                    <Typography variant="body1" color="text.secondary">
                        {stays.length} séjours enregistrés
                    </Typography>
                </Box>
                <Button
                    variant="contained"
                    startIcon={<AddIcon />}
                    onClick={() => handleOpen()}
                    sx={{ bgcolor: 'primary.dark', '&:hover': { bgcolor: 'black' }, textTransform: 'none', borderRadius: 2, px: 3 }}
                >
                    Nouveau séjour
                </Button>
            </Box>

            <Paper sx={{ p: 2, mb: 4, display: 'flex', gap: 2, alignItems: 'center', borderRadius: 3, boxShadow: '0px 2px 10px rgba(0,0,0,0.02)' }}>
                <TextField
                    placeholder="Rechercher par patient ou pathologie..."
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
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>PATIENT</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>PATHOLOGIE</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>DATE DÉBUT</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>DATE FIN</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>TAUX JOURNALIER</TableCell>
                            <TableCell align="right" sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>ACTIONS</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {filteredStays.map((stay) => (
                            <TableRow key={stay.id} hover>
                                <TableCell sx={{ color: 'text.secondary' }}>S{stay.id}</TableCell>
                                <TableCell sx={{ fontWeight: 500 }}>{stay.patient ? `${stay.patient.firstName} ${stay.patient.lastName}` : 'N/A'}</TableCell>
                                <TableCell sx={{ color: 'text.secondary' }}>{stay.pathology}</TableCell>
                                <TableCell sx={{ color: 'text.secondary' }}>{stay.startDate}</TableCell>
                                <TableCell sx={{ color: 'text.secondary' }}>{stay.endDate}</TableCell>
                                <TableCell sx={{ fontWeight: 600 }}>{stay.dailyRate} €</TableCell>
                                <TableCell align="right">
                                    <Stack direction="row" spacing={1} justifyContent="flex-end">
                                        <IconButton size="small" onClick={() => handleOpen(stay)} sx={{ color: 'primary.main', bgcolor: '#EFF6FF', borderRadius: 1 }}><EditIcon fontSize="small" /></IconButton>
                                        <IconButton size="small" onClick={() => handleDeleteClick(stay)} sx={{ color: 'error.main', bgcolor: '#FEF2F2', borderRadius: 1 }}><DeleteOutlineIcon fontSize="small" /></IconButton>
                                    </Stack>
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>

            <Dialog open={open} onClose={handleClose}>
                <DialogTitle>{isEdit ? 'Modifier le séjour' : 'Nouveau séjour'}</DialogTitle>
                <DialogContent>
                    <TextField
                        select
                        margin="dense"
                        label="Patient"
                        fullWidth
                        value={currentStay.patient ? currentStay.patient.id : ''}
                        onChange={(e) => {
                            const selectedPatient = patients.find(p => p.id === e.target.value);
                            setCurrentStay({ ...currentStay, patient: selectedPatient });
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
                        label="Pathologie"
                        fullWidth
                        value={currentStay.pathology}
                        onChange={(e) => setCurrentStay({ ...currentStay, pathology: e.target.value })}
                    />
                    <TextField
                        margin="dense"
                        label="Date de Début"
                        type="date"
                        fullWidth
                        InputLabelProps={{ shrink: true }}
                        value={currentStay.startDate}
                        onChange={(e) => setCurrentStay({ ...currentStay, startDate: e.target.value })}
                    />
                    <TextField
                        margin="dense"
                        label="Date de Fin"
                        type="date"
                        fullWidth
                        InputLabelProps={{ shrink: true }}
                        value={currentStay.endDate}
                        onChange={(e) => setCurrentStay({ ...currentStay, endDate: e.target.value })}
                    />
                    <TextField
                        margin="dense"
                        label="Taux Journalier (€)"
                        type="number"
                        fullWidth
                        value={currentStay.dailyRate}
                        onChange={(e) => setCurrentStay({ ...currentStay, dailyRate: e.target.value })}
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
                itemName={stayToDelete ? `Séjour de ${stayToDelete.patient ? stayToDelete.patient.lastName : '...'}` : null}
            />
        </Box>
    );
};

export default Stays;
