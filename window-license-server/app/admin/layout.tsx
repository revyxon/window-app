'use client';
import * as React from 'react';
import Box from '@mui/material/Box';
import AdminSidebar from '../../components/AdminSidebar';
import AdminTopBar from '../../components/AdminTopBar';
import Toolbar from '@mui/material/Toolbar';

const DRAWER_WIDTH = 260;

export default function AdminLayout({ children }: { children: React.ReactNode }) {
    return (
        <Box sx={{ display: 'flex', minHeight: '100vh', bgcolor: '#f8fafc' }}>
            <AdminTopBar drawerWidth={DRAWER_WIDTH} />
            <AdminSidebar />
            <Box component="main" sx={{ flexGrow: 1, p: 3, width: { sm: `calc(100% - ${DRAWER_WIDTH}px)` } }}>
                <Toolbar /> {/* Spacer for fixed AppBar */}
                {children}
            </Box>
        </Box>
    );
}
