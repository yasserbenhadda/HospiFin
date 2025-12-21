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
import personnelService from '../services/personnelService';

const Personnel = () => {
    const [personnelList, setPersonnelList] = useState([]);
    const [open, setOpen] = useState(false);
    const [currentPersonnel, setCurrentPersonnel] = useState({ name: '', role: '', service: '', costPerDay: '', email: '', phone: '' });
    const [isEdit, setIsEdit] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        fetchPersonnel();
    }, []);

    const fetchPersonnel = async () => {
        try {
            const data = await personnelService.getAllPersonnel();
            setPersonnelList(data);
        } catch (error) {
            console.error("Error fetching personnel:", error);
        }
    };

    const handleOpen = (personnel = null) => {
        if (personnel) {
            setCurrentPersonnel(personnel);
            setIsEdit(true);
        } else {
            setCurrentPersonnel({ name: '', role: '', service: '', costPerDay: '', email: '', phone: '' });
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
                await personnelService.updatePersonnel(currentPersonnel.id, currentPersonnel);
            } else {
                await personnelService.createPersonnel(currentPersonnel);
            }
            fetchPersonnel();
            handleClose();
        } catch (error) {
            console.error("Error saving personnel:", error);
        }
    };

    const handleDelete = async (id) => {
        if (window.confirm("Êtes-vous sûr de vouloir supprimer ce membre du personnel ?")) {
            try {
                await personnelService.deletePersonnel(id);
                fetchPersonnel();
            } catch (error) {
                console.error("Error deleting personnel:", error);
            }
        }
    };

    const filteredPersonnel = personnelList.filter(staff =>
        staff.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        staff.role.toLowerCase().includes(searchTerm.toLowerCase()) ||
        staff.service.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <Box>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
                <Box>
                    <Typography variant="h4" gutterBottom sx={{ color: 'text.primary', fontWeight: 700 }}>
                        Gestion du personnel
                    </Typography>
                    <Typography variant="body1" color="text.secondary">
                        {personnelList.length} membres du personnel
                    </Typography>
                </Box>
                <Button
                    variant="contained"
                    startIcon={<AddIcon />}
                    onClick={() => handleOpen()}
                    sx={{ bgcolor: 'primary.dark', '&:hover': { bgcolor: 'black' }, textTransform: 'none', borderRadius: 2, px: 3 }}
                >
                    Nouveau membre
                </Button>
            </Box>

            <Paper sx={{ p: 2, mb: 4, display: 'flex', gap: 2, alignItems: 'center', borderRadius: 3, boxShadow: '0px 2px 10px rgba(0,0,0,0.02)' }}>
                <TextField
                    placeholder="Rechercher par nom, rôle ou service..."
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
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>RÔLE</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>SERVICE</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>COÛT/JOUR</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>EMAIL</TableCell>
                            <TableCell sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>TÉLÉPHONE</TableCell>
                            <TableCell align="right" sx={{ fontWeight: 600, color: 'text.secondary', fontSize: '0.75rem' }}>ACTIONS</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {filteredPersonnel.map((staff) => (
                            <TableRow key={staff.id} hover>
                                <TableCell sx={{ color: 'text.secondary' }}>PR{staff.id}</TableCell>
                                <TableCell sx={{ fontWeight: 500 }}>{staff.name}</TableCell>
                                <TableCell>
                                    <Chip
                                        label={staff.role}
                                        size="small"
                                        variant="outlined"
                                        sx={{
                                            borderColor: '#E2E8F0',
                                            color: 'text.primary',
                                            fontWeight: 500,
                                            borderRadius: 4
                                        }}
                                    />
                                </TableCell>
                                <TableCell sx={{ color: 'text.secondary' }}>{staff.service}</TableCell>
                                <TableCell sx={{ fontWeight: 600 }}>{staff.costPerDay} €</TableCell>
                                <TableCell sx={{ color: 'text.secondary' }}>{staff.email}</TableCell>
                                <TableCell sx={{ color: 'text.secondary' }}>{staff.phone}</TableCell>
                                <TableCell align="right">
                                    <Stack direction="row" spacing={1} justifyContent="flex-end">
                                        <IconButton size="small" sx={{ color: 'text.secondary' }}><VisibilityIcon fontSize="small" /></IconButton>
                                        <IconButton size="small" onClick={() => handleOpen(staff)} sx={{ color: 'primary.main', bgcolor: '#EFF6FF', borderRadius: 1 }}><EditIcon fontSize="small" /></IconButton>
                                        <IconButton size="small" onClick={() => handleDelete(staff.id)} sx={{ color: 'error.main', bgcolor: '#FEF2F2', borderRadius: 1 }}><DeleteOutlineIcon fontSize="small" /></IconButton>
                                    </Stack>
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>

            <Dialog open={open} onClose={handleClose}>
                <DialogTitle>{isEdit ? 'Modifier le membre' : 'Nouveau membre'}</DialogTitle>
                <DialogContent>
                    <TextField
                        autoFocus
                        margin="dense"
                        label="Nom"
                        fullWidth
                        value={currentPersonnel.name}
                        onChange={(e) => setCurrentPersonnel({ ...currentPersonnel, name: e.target.value })}
                    />
                    <TextField
                        margin="dense"
                        label="Rôle"
                        fullWidth
                        value={currentPersonnel.role}
                        onChange={(e) => setCurrentPersonnel({ ...currentPersonnel, role: e.target.value })}
                    />
                    <TextField
                        margin="dense"
                        label="Service"
                        fullWidth
                        value={currentPersonnel.service}
                        onChange={(e) => setCurrentPersonnel({ ...currentPersonnel, service: e.target.value })}
                    />
                    <TextField
                        margin="dense"
                        label="Coût/Jour (€)"
                        type="number"
                        fullWidth
                        value={currentPersonnel.costPerDay}
                        onChange={(e) => setCurrentPersonnel({ ...currentPersonnel, costPerDay: e.target.value })}
                    />
                    <TextField
                        margin="dense"
                        label="Email"
                        fullWidth
                        value={currentPersonnel.email}
                        onChange={(e) => setCurrentPersonnel({ ...currentPersonnel, email: e.target.value })}
                    />
                    <TextField
                        margin="dense"
                        label="Téléphone"
                        fullWidth
                        value={currentPersonnel.phone}
                        onChange={(e) => setCurrentPersonnel({ ...currentPersonnel, phone: e.target.value })}
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

export default Personnel;
