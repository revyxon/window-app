'use client';
import * as React from 'react';
import Drawer from '@mui/material/Drawer';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Divider from '@mui/material/Divider';
import Toolbar from '@mui/material/Toolbar';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import { usePathname, useRouter } from 'next/navigation';

// Icons
import DashboardIcon from '@mui/icons-material/Dashboard';
import GroupIcon from '@mui/icons-material/Group';
import SecurityIcon from '@mui/icons-material/Security';
import SystemUpdateAltIcon from '@mui/icons-material/SystemUpdateAlt';
import HistoryIcon from '@mui/icons-material/History';
import SettingsIcon from '@mui/icons-material/Settings';
import BusinessIcon from '@mui/icons-material/Business';
import StraightenIcon from '@mui/icons-material/Straighten';
import AssignmentIcon from '@mui/icons-material/Assignment';

const DRAWER_WIDTH = 260;

const MENU_ITEMS = [
    { text: 'Dashboard', icon: <DashboardIcon />, path: '/admin' },
    { type: 'divider' },
    { text: 'License Control', icon: <SecurityIcon />, path: '/admin/users' },
    { text: 'App Updates', icon: <SystemUpdateAltIcon />, path: '/admin/updates' },
    { type: 'divider' },
    { text: 'Customers', icon: <GroupIcon />, path: '/admin/customers' },
    { text: 'Measurements', icon: <StraightenIcon />, path: '/admin/measurements' },
    { text: 'Enquiries', icon: <AssignmentIcon />, path: '/admin/enquiries' },
    { type: 'divider' },
    { text: 'Activity Logs', icon: <HistoryIcon />, path: '/admin/logs' },
    { text: 'Settings', icon: <SettingsIcon />, path: '/admin/settings' },
];

export default function AdminSidebar() {
    const router = useRouter();
    const pathname = usePathname();

    return (
        <Drawer
            variant="permanent"
            sx={{
                width: DRAWER_WIDTH,
                flexShrink: 0,
                [`& .MuiDrawer-paper`]: { width: DRAWER_WIDTH, boxSizing: 'border-box', borderRight: '1px solid #e2e8f0', bgcolor: '#fff' },
            }}
        >
            <Toolbar sx={{ px: 2 }}>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Box sx={{ width: 32, height: 32, bgcolor: 'primary.main', borderRadius: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'white', fontWeight: 'bold' }}>
                        W
                    </Box>
                    <Typography variant="h6" noWrap component="div" sx={{ fontWeight: 700, color: 'text.primary' }}>
                        WindowLicensing
                    </Typography>
                </Box>
            </Toolbar>
            <Divider />
            <Box sx={{ overflow: 'auto', px: 2, py: 2 }}>
                <List disablePadding>
                    {MENU_ITEMS.map((item, index) => {
                        if (item.type === 'divider') {
                            return <Divider key={index} sx={{ my: 1.5 }} />;
                        }
                        const isActive = pathname === item.path;
                        return (
                            <ListItem key={item.text} disablePadding>
                                <ListItemButton
                                    selected={isActive}
                                    onClick={() => router.push(item.path!)}
                                >
                                    <ListItemIcon sx={{ minWidth: 40, color: isActive ? 'primary.main' : 'text.secondary' }}>
                                        {item.icon}
                                    </ListItemIcon>
                                    <ListItemText
                                        primary={item.text}
                                        primaryTypographyProps={{ fontSize: '0.9rem', fontWeight: isActive ? 600 : 500 }}
                                    />
                                </ListItemButton>
                            </ListItem>
                        );
                    })}
                </List>
            </Box>
        </Drawer>
    );
}
