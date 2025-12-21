import React, { useState, useEffect } from 'react';
import { Box, Typography, Paper, Grid, TextField, Button, Switch, FormControlLabel, Divider, List, ListItem, ListItemIcon, ListItemText, Stack, Alert, Snackbar } from '@mui/material';
import PersonOutlineIcon from '@mui/icons-material/PersonOutline';
import NotificationsNoneIcon from '@mui/icons-material/NotificationsNone';
import LockOutlinedIcon from '@mui/icons-material/LockOutlined';
import StorageOutlinedIcon from '@mui/icons-material/StorageOutlined';
import SaveIcon from '@mui/icons-material/Save';
import settingsService from '../services/settingsService';

const Settings = () => {
    const [activeTab, setActiveTab] = useState('profil');
    const [profile, setProfile] = useState({
        id: null,
        name: '',
        email: '',
        phone: '',
        service: '',
        role: ''
    });
    const [loading, setLoading] = useState(true);
    const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });
    const [notifications, setNotifications] = useState({
        alerts: true,
        reports: true,
        system: true,
    });

    useEffect(() => {
        const fetchProfile = async () => {
            try {
                const data = await settingsService.getCurrentProfile();
                setProfile(data);
            } catch (error) {
                console.error("Failed to load profile", error);
                setSnackbar({ open: true, message: 'Erreur lors du chargement du profil', severity: 'error' });
            } finally {
                setLoading(false);
            }
        };
        fetchProfile();
    }, []);

    const handleNotificationChange = (event) => {
        setNotifications({
            ...notifications,
            [event.target.name]: event.target.checked,
        });
    };

    const handleProfileChange = (e) => {
        setProfile({ ...profile, [e.target.name]: e.target.value });
    };

    const handleSaveProfile = async () => {
        try {
            await settingsService.updateProfile(profile.id, profile);
            setSnackbar({ open: true, message: 'Profil mis à jour avec succès', severity: 'success' });
            // Reload the page after successful save
            setTimeout(() => {
                window.location.reload();
            }, 1000);
        } catch (error) {
            console.error("Failed to update profile", error);
            setSnackbar({ open: true, message: 'Erreur lors de la mise à jour', severity: 'error' });
        }
    };

    const handleCloseSnackbar = () => setSnackbar({ ...snackbar, open: false });

    const menuItems = [
        { id: 'profil', label: 'Profil', icon: <PersonOutlineIcon /> },
        { id: 'notifications', label: 'Notifications', icon: <NotificationsNoneIcon /> },
        { id: 'securite', label: 'Sécurité', icon: <LockOutlinedIcon /> },
        { id: 'donnees', label: 'Données', icon: <StorageOutlinedIcon /> },
    ];

    // Force HMR update

    return (
        <Box sx={{ pb: 4 }}>
            <Snackbar open={snackbar.open} autoHideDuration={6000} onClose={handleCloseSnackbar}>
                <Alert onClose={handleCloseSnackbar} severity={snackbar.severity} sx={{ width: '100%' }}>
                    {snackbar.message}
                </Alert>
            </Snackbar>

            {/* Header */}
            <Box sx={{ mb: 4 }}>
                <Typography variant="h4" sx={{ fontWeight: 800, color: '#1E293B', mb: 0.5 }}>
                    Paramètres
                </Typography>
                <Typography variant="body2" color="text.secondary">
                    Configuration de votre compte
                </Typography>
            </Box>

            <Box sx={{ mb: 4 }}>
                <Typography variant="h5" sx={{ fontWeight: 700, color: '#1E293B', mb: 1 }}>
                    Paramètres
                </Typography>
                <Typography variant="body1" color="text.secondary">
                    Gérez vos préférences et paramètres de compte
                </Typography>
            </Box>

            <Grid container spacing={4}>
                {/* Sidebar Menu */}
                <Grid item xs={12} md={3}>
                    <Paper sx={{ borderRadius: 4, overflow: 'hidden', boxShadow: '0px 4px 20px rgba(0,0,0,0.02)', border: '1px solid #F1F5F9' }}>
                        <List component="nav" sx={{ p: 2 }}>
                            {menuItems.map((item) => (
                                <ListItem
                                    button
                                    key={item.id}
                                    selected={activeTab === item.id}
                                    onClick={() => setActiveTab(item.id)}
                                    sx={{
                                        borderRadius: 2,
                                        mb: 1,
                                        bgcolor: activeTab === item.id ? '#F1F5F9' : 'transparent',
                                        color: activeTab === item.id ? '#1E293B' : '#64748B',
                                        '&:hover': { bgcolor: '#F8FAFC' },
                                        '&.Mui-selected': { bgcolor: '#F1F5F9', color: '#1E293B' }
                                    }}
                                >
                                    <ListItemIcon sx={{ color: 'inherit', minWidth: 40 }}>
                                        {item.icon}
                                    </ListItemIcon>
                                    <ListItemText primary={item.label} primaryTypographyProps={{ fontWeight: 600, fontSize: '0.95rem' }} />
                                </ListItem>
                            ))}
                        </List>
                    </Paper>
                </Grid>

                {/* Main Content */}
                <Grid item xs={12} md={9}>
                    <Stack spacing={4}>

                        {/* Profile Section */}
                        <Paper sx={{ p: 4, borderRadius: 4, boxShadow: '0px 4px 20px rgba(0,0,0,0.02)', border: '1px solid #F1F5F9' }}>
                            <Typography variant="h6" sx={{ fontWeight: 700, mb: 3, color: '#1E293B' }}>Informations du profil</Typography>

                            <Grid container spacing={3}>
                                <Grid item xs={12} sm={6}>
                                    <Typography variant="subtitle2" sx={{ mb: 1, fontWeight: 600, color: '#475569' }}>Nom complet</Typography>
                                    <TextField
                                        fullWidth
                                        name="name"
                                        value={profile.name}
                                        onChange={handleProfileChange}
                                        variant="outlined"
                                        size="small"
                                        sx={{ '& .MuiOutlinedInput-root': { borderRadius: 2, bgcolor: '#F8FAFC' } }}
                                    />
                                </Grid>
                                <Grid item xs={12} sm={6}>
                                    <Typography variant="subtitle2" sx={{ mb: 1, fontWeight: 600, color: '#475569' }}>Rôle</Typography>
                                    <TextField
                                        fullWidth
                                        name="role"
                                        value={profile.role}
                                        onChange={handleProfileChange}
                                        variant="outlined"
                                        size="small"
                                        sx={{ '& .MuiOutlinedInput-root': { borderRadius: 2, bgcolor: '#F8FAFC' } }}
                                    />
                                </Grid>
                                <Grid item xs={12}>
                                    <Typography variant="subtitle2" sx={{ mb: 1, fontWeight: 600, color: '#475569' }}>Email</Typography>
                                    <TextField
                                        fullWidth
                                        name="email"
                                        value={profile.email}
                                        onChange={handleProfileChange}
                                        variant="outlined"
                                        size="small"
                                        sx={{ '& .MuiOutlinedInput-root': { borderRadius: 2, bgcolor: '#F8FAFC' } }}
                                    />
                                </Grid>
                                <Grid item xs={12}>
                                    <Typography variant="subtitle2" sx={{ mb: 1, fontWeight: 600, color: '#475569' }}>Téléphone</Typography>
                                    <TextField
                                        fullWidth
                                        name="phone"
                                        value={profile.phone}
                                        onChange={handleProfileChange}
                                        variant="outlined"
                                        size="small"
                                        sx={{ '& .MuiOutlinedInput-root': { borderRadius: 2, bgcolor: '#F8FAFC' } }}
                                    />
                                </Grid>
                                <Grid item xs={12}>
                                    <Typography variant="subtitle2" sx={{ mb: 1, fontWeight: 600, color: '#475569' }}>Service</Typography>
                                    <TextField
                                        fullWidth
                                        name="service"
                                        value={profile.service}
                                        onChange={handleProfileChange}
                                        variant="outlined"
                                        size="small"
                                        sx={{ '& .MuiOutlinedInput-root': { borderRadius: 2, bgcolor: '#F8FAFC' } }}
                                    />
                                </Grid>
                            </Grid>

                            <Box sx={{ mt: 4, display: 'flex', justifyContent: 'flex-end', gap: 2 }}>
                                <Button variant="outlined" sx={{ borderRadius: 2, color: '#64748B', borderColor: '#E2E8F0', textTransform: 'none', fontWeight: 600 }}>
                                    Annuler
                                </Button>
                                <Button
                                    variant="contained"
                                    onClick={handleSaveProfile}
                                    sx={{ borderRadius: 2, bgcolor: '#1E293B', textTransform: 'none', fontWeight: 600, '&:hover': { bgcolor: '#0F172A' } }}
                                >
                                    Enregistrer les modifications
                                </Button>
                            </Box>
                        </Paper>

                        {/* Notifications Section */}
                        <Paper sx={{ p: 4, borderRadius: 4, boxShadow: '0px 4px 20px rgba(0,0,0,0.02)', border: '1px solid #F1F5F9' }}>
                            <Typography variant="h6" sx={{ fontWeight: 700, mb: 3, color: '#1E293B' }}>Préférences de notifications</Typography>

                            <Stack spacing={3}>
                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                    <Box>
                                        <Typography variant="subtitle1" fontWeight={600}>Alertes de coûts</Typography>
                                        <Typography variant="body2" color="text.secondary">Recevoir des alertes lorsque les coûts dépassent le seuil</Typography>
                                    </Box>
                                    <Switch checked={notifications.alerts} onChange={handleNotificationChange} name="alerts" color="primary" />
                                </Box>
                                <Divider />
                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                    <Box>
                                        <Typography variant="subtitle1" fontWeight={600}>Rapports hebdomadaires</Typography>
                                        <Typography variant="body2" color="text.secondary">Recevoir un résumé hebdomadaire par email</Typography>
                                    </Box>
                                    <Switch checked={notifications.reports} onChange={handleNotificationChange} name="reports" color="primary" />
                                </Box>
                                <Divider />
                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                    <Box>
                                        <Typography variant="subtitle1" fontWeight={600}>Notifications système</Typography>
                                        <Typography variant="body2" color="text.secondary">Mises à jour et messages importants</Typography>
                                    </Box>
                                    <Switch checked={notifications.system} onChange={handleNotificationChange} name="system" color="primary" />
                                </Box>
                            </Stack>
                        </Paper>

                        {/* Security Section */}
                        <Paper sx={{ p: 4, borderRadius: 4, boxShadow: '0px 4px 20px rgba(0,0,0,0.02)', border: '1px solid #F1F5F9' }}>
                            <Typography variant="h6" sx={{ fontWeight: 700, mb: 3, color: '#1E293B' }}>Sécurité</Typography>

                            <Stack spacing={2}>
                                <Button
                                    variant="outlined"
                                    startIcon={<LockOutlinedIcon />}
                                    fullWidth
                                    sx={{
                                        justifyContent: 'flex-start',
                                        borderRadius: 2,
                                        py: 1.5,
                                        color: '#1E293B',
                                        borderColor: '#E2E8F0',
                                        bgcolor: '#F8FAFC',
                                        textTransform: 'none',
                                        fontWeight: 600,
                                        '&:hover': { bgcolor: '#F1F5F9', borderColor: '#CBD5E1' }
                                    }}
                                >
                                    Changer le mot de passe
                                </Button>
                                <Button
                                    variant="outlined"
                                    startIcon={<PersonOutlineIcon />}
                                    fullWidth
                                    sx={{
                                        justifyContent: 'flex-start',
                                        borderRadius: 2,
                                        py: 1.5,
                                        color: '#1E293B',
                                        borderColor: '#E2E8F0',
                                        bgcolor: '#F8FAFC',
                                        textTransform: 'none',
                                        fontWeight: 600,
                                        '&:hover': { bgcolor: '#F1F5F9', borderColor: '#CBD5E1' }
                                    }}
                                >
                                    Authentification à deux facteurs
                                </Button>
                            </Stack>
                        </Paper>

                    </Stack>
                </Grid>
            </Grid>
        </Box>
    );
};

export default Settings;
