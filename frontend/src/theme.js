import { createTheme } from '@mui/material/styles';

const theme = createTheme({
    palette: {
        primary: {
            main: '#1E293B', // Dark slate blue for sidebar/headings
            light: '#334155',
            dark: '#0F172A',
        },
        secondary: {
            main: '#10B981', // Emerald green for success/growth
            light: '#34D399',
            dark: '#059669',
        },
        background: {
            default: '#F0F2F5', // Slightly darker to make white cards pop
            paper: '#FFFFFF',
        },
        text: {
            primary: '#1E293B',
            secondary: '#64748B',
        },
        success: {
            main: '#10B981',
        },
        warning: {
            main: '#F59E0B',
        },
        info: {
            main: '#3B82F6',
        },
    },
    typography: {
        fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
        h1: { fontWeight: 700, letterSpacing: '-0.02em' },
        h2: { fontWeight: 700, letterSpacing: '-0.01em' },
        h3: { fontWeight: 700, letterSpacing: '-0.01em' },
        h4: { fontWeight: 700, letterSpacing: '-0.01em' },
        h6: { fontWeight: 600, letterSpacing: '0.01em' },
        body1: { fontSize: '0.95rem' },
        button: { textTransform: 'none', fontWeight: 600 },
    },
    shape: {
        borderRadius: 16, // More rounded corners
    },
    components: {
        MuiButton: {
            styleOverrides: {
                root: {
                    borderRadius: 12,
                    boxShadow: 'none',
                    '&:hover': {
                        boxShadow: '0px 4px 12px rgba(0,0,0,0.1)',
                    },
                },
            },
        },
        MuiPaper: {
            styleOverrides: {
                root: {
                    backgroundImage: 'none',
                },
            },
        },
        MuiCard: {
            styleOverrides: {
                root: {
                    borderRadius: '16px',
                    boxShadow: '0px 4px 20px rgba(0, 0, 0, 0.05)',
                    border: '1px solid #E2E8F0',
                },
            },
        },
    },
});

export default theme;
