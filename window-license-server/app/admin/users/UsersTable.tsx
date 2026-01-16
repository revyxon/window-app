'use client';
import * as React from 'react';
import { DataGrid, GridColDef, GridRenderCellParams, GridToolbar } from '@mui/x-data-grid';
import Chip from '@mui/material/Chip';
import IconButton from '@mui/material/IconButton';
import Tooltip from '@mui/material/Tooltip';
import Box from '@mui/material/Box';
import Paper from '@mui/material/Paper';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogContentText from '@mui/material/DialogContentText';
import DialogTitle from '@mui/material/DialogTitle';
import Snackbar from '@mui/material/Snackbar';
import Alert from '@mui/material/Alert';

// Icons
import BlockIcon from '@mui/icons-material/Block';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import RefreshIcon from '@mui/icons-material/Refresh';
import LockOpenIcon from '@mui/icons-material/LockOpen';
import LockIcon from '@mui/icons-material/Lock';

// Actions
import { toggleDeviceLock } from '@/app/actions/device';
import { forceDeviceCheck } from '@/app/actions/force-check';

interface UsersTableProps {
    initialDevices: any[];
}

export default function UsersTable({ initialDevices }: UsersTableProps) {
    // Action State
    const [selectedDevice, setSelectedDevice] = React.useState<any>(null);
    const [lockDialogOpen, setLockDialogOpen] = React.useState(false);
    const [snackbar, setSnackbar] = React.useState<{ open: boolean, message: string, severity: 'success' | 'error' }>({ open: false, message: '', severity: 'success' });

    // Status Logic
    const getStatusColor = (status: string) => {
        switch (status) {
            case 'active': return 'success';
            case 'locked': return 'error';
            case 'expired': return 'warning';
            case 'unregistered': return 'default';
            default: return 'default';
        }
    };

    // Handlers
    const handleLockClick = (device: any) => {
        setSelectedDevice(device);
        setLockDialogOpen(true);
    };

    const handleConfirmLock = async () => {
        if (!selectedDevice) return;

        try {
            const result = await toggleDeviceLock(selectedDevice.deviceId, selectedDevice.status);
            if (result.success) {
                setSnackbar({ open: true, message: `Device ${result.status === 'locked' ? 'Locked' : 'Unlocked'} Successfully`, severity: 'success' });
            } else {
                setSnackbar({ open: true, message: result.error || 'Failed to update status', severity: 'error' });
            }
        } catch (e: any) {
            setSnackbar({ open: true, message: e.message, severity: 'error' });
        } finally {
            setLockDialogOpen(false);
            setSelectedDevice(null);
        }
    };

    const handleForceCheck = async (deviceId: string) => {
        try {
            const result = await forceDeviceCheck(deviceId);
            if (result.success) {
                setSnackbar({ open: true, message: 'Force check command sent', severity: 'success' });
            } else {
                setSnackbar({ open: true, message: result.error || 'Failed', severity: 'error' });
            }
        } catch (e: any) {
            setSnackbar({ open: true, message: e.message, severity: 'error' });
        }
    };

    const columns: GridColDef[] = [
        { field: 'deviceId', headerName: 'Device ID', flex: 1, minWidth: 250 },
        {
            field: 'status',
            headerName: 'Status',
            width: 120,
            renderCell: (params: GridRenderCellParams) => (
                <Chip
                    label={params.value?.toUpperCase()}
                    color={getStatusColor(params.value) as any}
                    size="small"
                    variant="outlined"
                    sx={{ fontWeight: 600 }}
                />
            )
        },
        {
            field: 'graceStatus',
            headerName: 'Grace',
            width: 120,
            renderCell: (params: GridRenderCellParams) => {
                const isGrace = params.value === 'grace_period';
                return isGrace ? (
                    <Chip label="GRACE" color="warning" size="small" />
                ) : (
                    <Typography variant="caption" color="text.secondary">-</Typography>
                );
            }
        },
        { field: 'appVersion', headerName: 'Version', width: 100 },
        {
            field: 'lastActiveAt',
            headerName: 'Last Active',
            width: 180,
            valueFormatter: (params) => {
                if (!params.value) return '-';
                return new Date(params.value).toLocaleString();
            }
        },
        {
            field: 'actions',
            headerName: 'Actions',
            width: 150,
            sortable: false,
            renderCell: (params: GridRenderCellParams) => (
                <Box>
                    <Tooltip title={params.row.status === 'locked' ? "Unlock Device" : "Lock Device"}>
                        <IconButton
                            color={params.row.status === 'locked' ? "success" : "error"}
                            onClick={() => handleLockClick(params.row)}
                            size="small"
                        >
                            {params.row.status === 'locked' ? <LockOpenIcon /> : <LockIcon />}
                        </IconButton>
                    </Tooltip>
                    <Tooltip title="Force Validation Check">
                        <IconButton
                            color="primary"
                            onClick={() => handleForceCheck(params.row.deviceId)}
                            size="small"
                        >
                            <RefreshIcon />
                        </IconButton>
                    </Tooltip>
                </Box>
            )
        }
    ];

    return (
        <Paper sx={{ width: '100%', height: 600 }}>
            <DataGrid
                rows={initialDevices}
                columns={columns}
                getRowId={(row) => row.deviceId}
                slots={{ toolbar: GridToolbar }}
                slotProps={{
                    toolbar: {
                        showQuickFilter: true,
                        quickFilterProps: { debounceMs: 500 },
                    },
                }}
                initialState={{
                    pagination: { paginationModel: { pageSize: 10 } },
                }}
                pageSizeOptions={[10, 25, 50]}
                disableRowSelectionOnClick
                sx={{ border: 'none' }}
            />

            {/* Lock Dialog */}
            <Dialog open={lockDialogOpen} onClose={() => setLockDialogOpen(false)}>
                <DialogTitle>
                    {selectedDevice?.status === 'locked' ? 'Unlock Device?' : 'Lock Device?'}
                </DialogTitle>
                <DialogContent>
                    <DialogContentText>
                        {selectedDevice?.status === 'locked'
                            ? `Are you sure you want to unlock ${selectedDevice?.deviceId}? They will regain access immediately.`
                            : `Are you sure you want to lock ${selectedDevice?.deviceId}? They will be blocked from using the app within 15 seconds.`}
                    </DialogContentText>
                </DialogContent>
                <DialogActions>
                    <Button onClick={() => setLockDialogOpen(false)}>Cancel</Button>
                    <Button onClick={handleConfirmLock} color={selectedDevice?.status === 'locked' ? 'success' : 'error'} variant="contained" autoFocus>
                        {selectedDevice?.status === 'locked' ? 'Unlock' : 'Lock Now'}
                    </Button>
                </DialogActions>
            </Dialog>

            {/* Snackbar */}
            <Snackbar open={snackbar.open} autoHideDuration={4000} onClose={() => setSnackbar({ ...snackbar, open: false })}>
                <Alert severity={snackbar.severity} sx={{ width: '100%' }}>
                    {snackbar.message}
                </Alert>
            </Snackbar>
        </Paper>
    );
}
