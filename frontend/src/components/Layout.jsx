import React, { useState, useEffect } from 'react';
import { Outlet, useLocation, Link } from 'react-router-dom';
import {
    Box,
    CssBaseline,
    AppBar,
    Toolbar,
    Typography,
    Drawer,
    List,
    ListItem,
    ListItemButton,
    ListItemIcon,
    ListItemText,
    Divider,
    IconButton,
    Badge,
    Avatar,
    InputBase
} from '@mui/material';
import { styled, alpha } from '@mui/material/styles';
import SearchIcon from '@mui/icons-material/Search';
import NotificationsNoneIcon from '@mui/icons-material/NotificationsNone';
import LocalHospitalIcon from '@mui/icons-material/LocalHospital';
import DashboardIcon from '@mui/icons-material/Dashboard';
import PeopleIcon from '@mui/icons-material/People';
import MedicalServicesIcon from '@mui/icons-material/MedicalServices';
import LocalPharmacyIcon from '@mui/icons-material/LocalPharmacy';
import HotelIcon from '@mui/icons-material/Hotel';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import SettingsIcon from '@mui/icons-material/Settings';
import WorkIcon from '@mui/icons-material/Work';
import SmartToyIcon from '@mui/icons-material/SmartToy';

import settingsService from '../services/settingsService';

const drawerWidth = 240;

// Search Bar Styling
const Search = styled('div')(({ theme }) => ({
    position: 'relative',
    borderRadius: theme.shape.borderRadius,
    backgroundColor: alpha(theme.palette.common.white, 0.15),
    '&:hover': {
        backgroundColor: alpha(theme.palette.common.white, 0.25),
    },
    marginRight: theme.spacing(2),
    marginLeft: 0,
    width: '100%',
    [theme.breakpoints.up('sm')]: {
        marginLeft: theme.spacing(3),
        width: 'auto',
    },
}));

const SearchIconWrapper = styled('div')(({ theme }) => ({
    padding: theme.spacing(0, 2),
    height: '100%',
    position: 'absolute',
    pointerEvents: 'none',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
}));

const StyledInputBase = styled(InputBase)(({ theme }) => ({
    color: 'inherit',
    '& .MuiInputBase-input': {
        padding: theme.spacing(1, 1, 1, 0),
        paddingLeft: `calc(1em + ${theme.spacing(4)})`,
        transition: theme.transitions.create('width'),
        width: '100%',
        [theme.breakpoints.up('md')]: {
            width: '20ch',
        },
    },
}));

const menuItems = [
    { text: 'Tableau de bord', icon: <DashboardIcon />, path: '/' },
    { text: 'Patients', icon: <PeopleIcon />, path: '/patients' },
    { text: 'Personnel', icon: <WorkIcon />, path: '/personnel' },
    { text: 'Séjours', icon: <HotelIcon />, path: '/stays' },
    { text: 'Actes Médicaux', icon: <MedicalServicesIcon />, path: '/medical-acts' },
    { text: 'Médicaments', icon: <LocalPharmacyIcon />, path: '/medications' },
    { text: 'Consommables', icon: <LocalPharmacyIcon />, path: '/consumables' },
    { text: 'Prévisions', icon: <TrendingUpIcon />, path: '/forecasts' },
    { text: 'Assistant IA', icon: <SmartToyIcon />, path: '/chat' },
    { text: 'Paramètres', icon: <SettingsIcon />, path: '/settings' },
];

const Layout = ({ children }) => {
    const location = useLocation();
    const [user, setUser] = useState({ name: 'Chargement...', role: '', initials: '..' });

    useEffect(() => {
        const fetchUser = async () => {
            try {
                const profile = await settingsService.getCurrentProfile();
                const initials = profile.name ? profile.name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2) : 'U';
                setUser({
                    name: profile.name || 'Utilisateur',
                    role: profile.role || 'Personnel',
                    initials: initials
                });
            } catch (error) {
                // Silently fail or optimize - user might not be set up
                setUser({ name: 'Admin', role: 'Administrateur', initials: 'AD' });
            }
        };
        fetchUser();
    }, [location.pathname]);

    const getPageTitle = () => {
        const item = menuItems.find(item => item.path === location.pathname);
        return item ? item.text : 'HospiFin';
    };

    const getPageSubtitle = () => {
        return "Tableau de bord de gestion hospitalière";
    };

    return (
        <Box sx={{ display: 'flex' }}>
            <CssBaseline />

            {/* Topbar */}
            <AppBar
                position="fixed"
                sx={{
                    width: `calc(100% - ${drawerWidth}px)`,
                    ml: `${drawerWidth}px`,
                    bgcolor: 'background.default',
                    color: 'text.primary',
                    boxShadow: 'none',
                    borderBottom: '1px solid #E2E8F0',
                    zIndex: (theme) => theme.zIndex.drawer + 1
                }}
            >
                <Toolbar>
                    <Box sx={{ flexGrow: 1 }}>
                        <Typography variant="h5" component="div" sx={{ fontWeight: 700, color: 'primary.main' }}>
                            {getPageTitle()}
                        </Typography>
                        <Typography variant="body2" color="text.secondary">
                            {getPageSubtitle()}
                        </Typography>
                    </Box>

                    <Search>
                        <SearchIconWrapper>
                            <SearchIcon />
                        </SearchIconWrapper>
                        <StyledInputBase
                            placeholder="Rechercher..."
                            inputProps={{ 'aria-label': 'search' }}
                        />
                    </Search>

                    <IconButton size="large" color="inherit">
                        <Badge variant="dot" color="error">
                            <NotificationsNoneIcon />
                        </Badge>
                    </IconButton>

                    <Box sx={{ display: 'flex', alignItems: 'center', ml: 2 }}>
                        <Box sx={{ textAlign: 'right', mr: 1, display: { xs: 'none', md: 'block' } }}>
                            <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>{user.name}</Typography>
                            <Typography variant="caption" color="text.secondary">{user.role}</Typography>
                        </Box>
                        <Avatar sx={{ bgcolor: 'secondary.main', fontSize: '0.9rem', fontWeight: 700 }}>{user.initials}</Avatar>
                    </Box>
                </Toolbar>
            </AppBar>

            {/* Sidebar */}
            <Drawer
                variant="permanent"
                sx={{
                    width: drawerWidth,
                    flexShrink: 0,
                    [`& .MuiDrawer-paper`]: { width: drawerWidth, boxSizing: 'border-box', bgcolor: 'background.paper' },
                }}
            >
                <Toolbar sx={{ px: 2, py: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Box
                        component="img"
                        src="/logo.png"
                        alt="HospiFin Logo"
                        sx={{ height: 60, width: 'auto', borderRadius: 1 }}
                    />
                    <Box>
                        <Typography variant="h6" sx={{ lineHeight: 1.2, color: 'primary.main' }}>
                            HospiFin
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                            Prévisions financières
                        </Typography>
                    </Box>
                </Toolbar>
                <Divider sx={{ my: 1, mx: 2 }} />
                <Box sx={{ overflow: 'auto', px: 2 }}>
                    <List>
                        {menuItems.map((item) => (
                            <ListItem key={item.text} disablePadding sx={{ mb: 0.5 }}>
                                <ListItemButton
                                    component={Link}
                                    to={item.path}
                                    selected={location.pathname === item.path}
                                    sx={{
                                        borderRadius: 2,
                                        '&.Mui-selected': {
                                            bgcolor: 'primary.main',
                                            color: 'white',
                                            '&:hover': {
                                                bgcolor: 'primary.dark',
                                            },
                                            '& .MuiListItemIcon-root': {
                                                color: 'white',
                                            },
                                        },
                                    }}
                                >
                                    <ListItemIcon sx={{ minWidth: 40, color: 'text.secondary' }}>
                                        {item.icon}
                                    </ListItemIcon>
                                    <ListItemText
                                        primary={item.text}
                                        primaryTypographyProps={{ fontSize: '0.9rem', fontWeight: 500 }}
                                    />
                                </ListItemButton>
                            </ListItem>
                        ))}
                    </List>
                </Box>
                <Box sx={{ mt: 'auto', p: 2 }}>
                    <Box sx={{ p: 2, bgcolor: 'background.default', borderRadius: 2 }}>
                        <Typography variant="caption" display="block" color="text.secondary">
                            Version 1.0.0
                        </Typography>
                        <Typography variant="caption" display="block" color="text.secondary">
                            © 2025 HospiFin
                        </Typography>
                    </Box>
                </Box>
            </Drawer>

            {/* Main Content */}
            <Box component="main" sx={{ flexGrow: 1, p: 3, mt: 8, bgcolor: 'background.default', minHeight: '100vh' }}>
                {children}
            </Box>
        </Box>
    );
};

export default Layout;
