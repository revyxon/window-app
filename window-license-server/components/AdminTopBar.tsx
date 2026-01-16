'use client';
import * as React from 'react';
import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import IconButton from '@mui/material/IconButton';
import Badge from '@mui/material/Badge';
import Box from '@mui/material/Box';
import Avatar from '@mui/material/Avatar';
import Tooltip from '@mui/material/Tooltip';

// Icons
import NotificationsIcon from '@mui/icons-material/Notifications';
import HelpOutlineIcon from '@mui/icons-material/HelpOutline';

interface AdminTopBarProps {
    drawerWidth: number;
}

export default function AdminTopBar({ drawerWidth }: AdminTopBarProps) {
    return (
        <AppBar position="fixed" sx={{ width: `calc(100% - ${drawerWidth}px)`, ml: `${drawerWidth}px`, bgcolor: 'background.paper', color: 'text.primary', boxShadow: 'none', borderBottom: '1px solid #e2e8f0' }}>
            <Toolbar>
                <Typography variant="h6" noWrap component="div" sx={{ flexGrow: 1, fontWeight: 600, fontSize: '1.25rem' }}>
                    Dashboard
                </Typography>

                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Tooltip title="Documentation">
                        <IconButton color="inherit">
                            <HelpOutlineIcon />
                        </IconButton>
                    </Tooltip>
                    <Tooltip title="Notifications">
                        <IconButton color="inherit">
                            <Badge badgeContent={0} color="error">
                                <NotificationsIcon />
                            </Badge>
                        </IconButton>
                    </Tooltip>
                    <Box sx={{ ml: 1, borderLeft: '1px solid #e2e8f0', pl: 2, display: 'flex', alignItems: 'center', gap: 1.5 }}>
                        <Box sx={{ textAlign: 'right', display: { xs: 'none', md: 'block' } }}>
                            <Typography variant="subtitle2" sx={{ fontWeight: 600, lineHeight: 1.2 }}>Admin Operator</Typography>
                            <Typography variant="caption" color="text.secondary">sysadmin</Typography>
                        </Box>
                        <Avatar sx={{ bgcolor: 'primary.light', width: 36, height: 36 }}>A</Avatar>
                    </Box>
                </Box>
            </Toolbar>
        </AppBar>
    );
}
