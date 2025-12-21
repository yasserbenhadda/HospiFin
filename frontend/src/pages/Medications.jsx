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
import VisibilityIcon from '@mui/icons-material/Visibility';
import medicationService from '../services/medicationService';

const Medications = () => {
    const [medications, setMedications] = useState([]);
    const [open, setOpen] = useState(false);
    const [currentMedication, setCurrentMedication] = useState({ name: '', category: '', unitCost: '', stock: '', unit: '' });
    const [isEdit, setIsEdit] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        fetchMedications();
    }, []);

    const fetchMedications = async () => {
        try {
            const data = await medicationService.getAllMedications();
            setMedications(data);
        } catch (error) {
            console.error("Error fetching medications:", error);
        }
    };

    const handleOpen = (medication = null) => {
        if (medication) {
            setCurrentMedication(medication);
            setIsEdit(true);
        } else {
            setCurrentMedication({ name: '', category: '', unitCost: '', stock: '', unit: '' });
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
                await medicationService.updateMedication(currentMedication.id, currentMedication);
            } else {
                await medicationService.createMedication(currentMedication);
            }
            fetchMedications();
            handleClose();
        } catch (error) {
            console.error("Error saving medication:", error);
        }
    };

    const handleDelete = async (id) => {
        if (window.confirm("Êtes-vous sûr de vouloir supprimer ce médicament ?")) {
            try {
                await medicationService.deleteMedication(id);
                fetchMedications();
            } catch (error) {
                console.error("Error deleting medication:", error);
            }
        }
    };

    const filteredMedications = medications.filter(med =>
        med.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        med.category.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <Box>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
                <Box>
                    <Typography variant="h4" gutterBottom sx={{ color: 'text.primary', fontWeight: 700 }}>
                        Gestion des médicaments
                    </Typography>
                    <Typography variant="body1" color="text.secondary">
                        {medications.length} médicaments en stock
                    </Typography>
                </Box>
                <Button
                    variant="contained"
                    startIcon={<AddIcon />}
                    onClick={() => handleOpen()}
                    sx={{ bgcolor: 'primary.dark', '&:hover': { bgcolor: 'black' }, textTransform: 'none', borderRadius: 2, px: 3 }}
                >
                    Nouveau médicament
                </Button>
            </Box>

            <Paper sx={{ p: 2, mb: 4, display: 'flex', gap: 2, alignItems: 'center', borderRadius: 3, boxShadow: '0px 2px 10px rgba(0,0,0,0.02)' }}>
                <TextField
                    placeholder="Rechercher par nom ou catégorie..."
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
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>NOM</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>CATÉGORIE</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>COÛT UNITAIRE</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>STOCK</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>UNITÉ</TableCell>
                            <TableCell align="right" sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>ACTIONS</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {filteredMedications.map((med) => (
                            <TableRow key={med.id} hover>
                                <TableCell sx={{ color: 'text.secondary' }}>M{med.id}</TableCell>
                                <TableCell sx={{ fontWeight: 500 }}>{med.name}</TableCell>
                                <TableCell sx={{ color: 'text.secondary' }}>{med.category}</TableCell>
                                <TableCell sx={{ color: 'text.secondary' }}>{med.unitCost} €</TableCell>
                                <TableCell>
                                    <Stack direction="row" alignItems="center" spacing={1}>
                                        <Typography variant="body2">{med.stock}</Typography>
                                        {med.stock < 100 && (
                                            <Chip label="Stock bas" size="small" sx={{ bgcolor: '#FEF2F2', color: 'error.main', fontSize: '0.7rem', height: 20 }} />
                                        )}
                                    </Stack>
                                </TableCell>
                                <TableCell sx={{ color: 'text.secondary' }}>{med.unit}</TableCell>
                                <TableCell align="right">
                                    <Stack direction="row" spacing={1} justifyContent="flex-end">
                                        <IconButton size="small" sx={{ color: 'text.secondary' }}><VisibilityIcon fontSize="small" /></IconButton>
                                        <IconButton size="small" onClick={() => handleOpen(med)} sx={{ color: 'primary.main', bgcolor: '#EFF6FF', borderRadius: 1 }}><EditIcon fontSize="small" /></IconButton>
                                        <IconButton size="small" onClick={() => handleDelete(med.id)} sx={{ color: 'error.main', bgcolor: '#FEF2F2', borderRadius: 1 }}><DeleteOutlineIcon fontSize="small" /></IconButton>
                                    </Stack>
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>

            <Dialog open={open} onClose={handleClose}>
                <DialogTitle>{isEdit ? 'Modifier le médicament' : 'Nouveau médicament'}</DialogTitle>
                <DialogContent>
                    <TextField
                        autoFocus
                        margin="dense"
                        label="Nom"
                        fullWidth
                        value={currentMedication.name}
                        onChange={(e) => setCurrentMedication({ ...currentMedication, name: e.target.value })}
                    />
                    <TextField
                        margin="dense"
                        label="Catégorie"
                        fullWidth
                        value={currentMedication.category}
                        onChange={(e) => setCurrentMedication({ ...currentMedication, category: e.target.value })}
                    />
                    <TextField
                        margin="dense"
                        label="Coût Unitaire (€)"
                        type="number"
                        fullWidth
                        value={currentMedication.unitCost}
                        onChange={(e) => setCurrentMedication({ ...currentMedication, unitCost: e.target.value })}
                    />
                    <TextField
                        margin="dense"
                        label="Stock"
                        type="number"
                        fullWidth
                        value={currentMedication.stock}
                        onChange={(e) => setCurrentMedication({ ...currentMedication, stock: e.target.value })}
                    />
                    <TextField
                        margin="dense"
                        label="Unité"
                        fullWidth
                        value={currentMedication.unit}
                        onChange={(e) => setCurrentMedication({ ...currentMedication, unit: e.target.value })}
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

export default Medications;
