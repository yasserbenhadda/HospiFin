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
import DeleteConfirmationDialog from '../components/DeleteConfirmationDialog';
import consumableService from '../services/consumableService';
import medicationService from '../services/medicationService';
import patientService from '../services/patientService';

const Consumables = () => {
    const [consumables, setConsumables] = useState([]);
    const [medications, setMedications] = useState([]);
    const [patients, setPatients] = useState([]);
    const [open, setOpen] = useState(false);
    const [currentConsumable, setCurrentConsumable] = useState({ medication: null, quantity: '', date: '', patient: null, totalCost: '' });
    const [isEdit, setIsEdit] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        fetchConsumables();
        fetchMedications();
        fetchPatients();
    }, []);

    const fetchConsumables = async () => {
        try {
            const data = await consumableService.getAllConsumables();
            setConsumables(data);
        } catch (error) {
            console.error("Error fetching consumables:", error);
        }
    };

    const fetchMedications = async () => {
        try {
            const data = await medicationService.getAllMedications();
            setMedications(data);
        } catch (error) {
            console.error("Error fetching medications:", error);
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

    const handleOpen = (consumable = null) => {
        if (consumable) {
            setCurrentConsumable(consumable);
            setIsEdit(true);
        } else {
            setCurrentConsumable({ medication: null, quantity: '', date: '', patient: null, totalCost: '' });
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
                await consumableService.updateConsumable(currentConsumable.id, currentConsumable);
            } else {
                await consumableService.createConsumable(currentConsumable);
            }
            fetchConsumables();
            handleClose();
        } catch (error) {
            console.error("Error saving consumable:", error);
        }
    };

    // Delete Dialog Handling
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
    const [consumableToDelete, setConsumableToDelete] = useState(null);

    const handleDeleteClick = (consumable) => {
        setConsumableToDelete(consumable);
        setDeleteDialogOpen(true);
    };

    const handleConfirmDelete = async () => {
        if (consumableToDelete) {
            try {
                await consumableService.deleteConsumable(consumableToDelete.id);
                fetchConsumables();
            } catch (error) {
                console.error("Error deleting consumable:", error);
            }
        }
        setDeleteDialogOpen(false);
        setConsumableToDelete(null);
    };

    const handleCancelDelete = () => {
        setDeleteDialogOpen(false);
        setConsumableToDelete(null);
    };

    const filteredConsumables = consumables.filter(item =>
        item.medication?.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (item.patient && `${item.patient.firstName} ${item.patient.lastName}`.toLowerCase().includes(searchTerm.toLowerCase()))
    );

    return (
        <Box>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
                <Box>
                    <Typography variant="h4" gutterBottom sx={{ color: 'text.primary', fontWeight: 700 }}>
                        Consommations de médicaments
                    </Typography>
                    <Typography variant="body1" color="text.secondary">
                        {consumables.length} consommations enregistrées
                    </Typography>
                </Box>
                <Button
                    variant="contained"
                    startIcon={<AddIcon />}
                    onClick={() => handleOpen()}
                    sx={{ bgcolor: 'primary.dark', '&:hover': { bgcolor: 'black' }, textTransform: 'none', borderRadius: 2, px: 3 }}
                >
                    Nouvelle consommation
                </Button>
            </Box>

            <Paper sx={{ p: 2, mb: 4, display: 'flex', gap: 2, alignItems: 'center', borderRadius: 3, boxShadow: '0px 2px 10px rgba(0,0,0,0.02)' }}>
                <TextField
                    placeholder="Rechercher par médicament ou patient..."
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
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>MÉDICAMENT</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>QUANTITÉ</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>DATE</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>PATIENT</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>COÛT TOTAL</TableCell>
                            <TableCell align="right" sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>ACTIONS</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {filteredConsumables.map((item) => (
                            <TableRow key={item.id} hover>
                                <TableCell sx={{ color: 'text.secondary' }}>C{item.id}</TableCell>
                                <TableCell sx={{ fontWeight: 500 }}>{item.medication ? item.medication.name : 'N/A'}</TableCell>
                                <TableCell sx={{ color: 'text.secondary' }}>{item.quantity}</TableCell>
                                <TableCell sx={{ color: 'text.secondary' }}>{item.date}</TableCell>
                                <TableCell sx={{ color: 'text.secondary' }}>{item.patient ? `${item.patient.firstName} ${item.patient.lastName}` : 'N/A'}</TableCell>
                                <TableCell sx={{ fontWeight: 600 }}>{item.totalCost} €</TableCell>
                                <TableCell align="right">
                                    <Stack direction="row" spacing={1} justifyContent="flex-end">
                                        <IconButton size="small" sx={{ color: 'text.secondary' }}><VisibilityIcon fontSize="small" /></IconButton>
                                        <IconButton size="small" onClick={() => handleOpen(item)} sx={{ color: 'primary.main', bgcolor: '#EFF6FF', borderRadius: 1 }}><EditIcon fontSize="small" /></IconButton>
                                        <IconButton size="small" onClick={() => handleDeleteClick(item)} sx={{ color: 'error.main', bgcolor: '#FEF2F2', borderRadius: 1 }}><DeleteOutlineIcon fontSize="small" /></IconButton>
                                    </Stack>
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>

            <Dialog open={open} onClose={handleClose}>
                <DialogTitle>{isEdit ? 'Modifier la consommation' : 'Nouvelle consommation'}</DialogTitle>
                <DialogContent>
                    <TextField
                        select
                        margin="dense"
                        label="Médicament"
                        fullWidth
                        value={currentConsumable.medication ? currentConsumable.medication.id : ''}
                        onChange={(e) => {
                            const selectedMedication = medications.find(m => m.id === e.target.value);
                            setCurrentConsumable({ ...currentConsumable, medication: selectedMedication });
                        }}
                    >
                        {medications.map((med) => (
                            <MenuItem key={med.id} value={med.id}>
                                {med.name}
                            </MenuItem>
                        ))}
                    </TextField>
                    <TextField
                        margin="dense"
                        label="Quantité"
                        type="number"
                        fullWidth
                        value={currentConsumable.quantity}
                        onChange={(e) => setCurrentConsumable({ ...currentConsumable, quantity: e.target.value })}
                    />
                    <TextField
                        margin="dense"
                        label="Date"
                        type="date"
                        fullWidth
                        InputLabelProps={{ shrink: true }}
                        value={currentConsumable.date}
                        onChange={(e) => setCurrentConsumable({ ...currentConsumable, date: e.target.value })}
                    />
                    <TextField
                        select
                        margin="dense"
                        label="Patient"
                        fullWidth
                        value={currentConsumable.patient ? currentConsumable.patient.id : ''}
                        onChange={(e) => {
                            const selectedPatient = patients.find(p => p.id === e.target.value);
                            setCurrentConsumable({ ...currentConsumable, patient: selectedPatient });
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
                        label="Coût Total (€)"
                        type="number"
                        fullWidth
                        value={currentConsumable.totalCost}
                        onChange={(e) => setCurrentConsumable({ ...currentConsumable, totalCost: e.target.value })}
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
                itemName={consumableToDelete ? `Consommation #${consumableToDelete.id}` : null}
            />
        </Box>
    );
};

export default Consumables;
