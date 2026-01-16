'use client';
import { createTheme } from '@mui/material/styles';
import { Roboto } from 'next/font/google';

const roboto = Roboto({
    weight: ['300', '400', '500', '700'],
    subsets: ['latin'],
    display: 'swap',
});

const theme = createTheme({
    typography: {
        fontFamily: roboto.style.fontFamily,
        button: {
            textTransform: 'none', // More modern feel
            fontWeight: 600,
        },
        h1: { fontSize: '2rem', fontWeight: 700 },
        h2: { fontSize: '1.75rem', fontWeight: 600 },
        h3: { fontSize: '1.5rem', fontWeight: 600 },
        h4: { fontSize: '1.25rem', fontWeight: 600 },
        h5: { fontSize: '1.1rem', fontWeight: 600 },
        h6: { fontSize: '1rem', fontWeight: 600 },
    },
    palette: {
        mode: 'light',
        primary: {
            main: '#2563eb', // Professional Deep Blue
            light: '#60a5fa',
            dark: '#1e40af',
            contrastText: '#fff',
        },
        secondary: {
            main: '#475569', // Slate
            light: '#94a3b8',
            dark: '#334155',
            contrastText: '#fff',
        },
        background: {
            default: '#f8fafc', // Very light slate
            paper: '#ffffff',
        },
        text: {
            primary: '#0f172a', // Slate 900
            secondary: '#64748b', // Slate 500
        },
        divider: '#e2e8f0',
    },
    shape: {
        borderRadius: 8, // Slightly softer but still professional
    },
    components: {
        MuiButton: {
            styleOverrides: {
                root: {
                    borderRadius: 8,
                    boxShadow: 'none',
                    '&:hover': {
                        boxShadow: 'none',
                    },
                },
                contained: {
                    '&:hover': {
                        boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)',
                    },
                },
            },
        },
        MuiCard: {
            styleOverrides: {
                root: {
                    boxShadow: '0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)', // Subtle shadow
                    border: '1px solid #e2e8f0',
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
        MuiTableCell: {
            styleOverrides: {
                head: {
                    fontWeight: 600,
                    backgroundColor: '#f8fafc',
                    color: '#475569',
                },
            },
        },
        // Desktop Density Tweaks
        MuiListItemButton: {
            styleOverrides: {
                root: {
                    borderRadius: 8,
                    marginBottom: 4,
                    '&.Mui-selected': {
                        backgroundColor: '#eff6ff', // Light Blue
                        color: '#2563eb',
                        '&:hover': {
                            backgroundColor: '#dbeafe',
                        },
                        '& .MuiListItemIcon-root': {
                            color: '#2563eb',
                        },
                    },
                },
            },
        },
    },
});

export default theme;
