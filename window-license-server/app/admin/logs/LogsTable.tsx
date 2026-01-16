'use client';
import * as React from 'react';
import { DataGrid, GridColDef, GridToolbar, GridRenderCellParams } from '@mui/x-data-grid';
import Paper from '@mui/material/Paper';
import Chip from '@mui/material/Chip';
import Typography from '@mui/material/Typography';

interface LogsTableProps {
    initialData: any[];
}

const columns: GridColDef[] = [
    {
        field: 'timestamp',
        headerName: 'Time',
        width: 200,
        valueFormatter: (params) => params.value ? new Date(params.value).toLocaleString() : '-'
    },
    {
        field: 'actionName',
        headerName: 'Action',
        width: 180,
        renderCell: (params) => (
            <Typography variant="body2" fontWeight={600}>{params.value}</Typography>
        )
    },
    {
        field: 'deviceId',
        headerName: 'Device',
        width: 220,
        renderCell: (params) => (
            <Typography variant="body2" sx={{ fontFamily: 'monospace' }}>{params.value}</Typography>
        )
    },
    { field: 'page', headerName: 'Screen/Context', width: 180 },
    {
        field: 'metadata',
        headerName: 'Details',
        flex: 1,
        minWidth: 300,
        renderCell: (params: GridRenderCellParams) => {
            const data = params.value;
            if (!data) return <span />;
            // Render basic key-value summary
            return (
                <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', py: 1 }}>
                    {Object.entries(data).map(([k, v]) => (
                        <Chip
                            key={k}
                            label={`${k}: ${v}`}
                            size="small"
                            variant="outlined"
                            sx={{ borderRadius: 1, fontSize: '0.75rem', height: 24 }}
                        />
                    ))}
                </Box>
            );
        }
    },
];

export default function LogsTable({ initialData }: LogsTableProps) {
    return (
        <Paper sx={{ width: '100%', height: 700 }}>
            <DataGrid
                rows={initialData}
                columns={columns}
                getRowId={(row) => row.id}
                slots={{ toolbar: GridToolbar }}
                slotProps={{
                    toolbar: { showQuickFilter: true, quickFilterProps: { debounceMs: 500 } },
                }}
                initialState={{
                    pagination: { paginationModel: { pageSize: 25 } },
                    sorting: { sortModel: [{ field: 'timestamp', sort: 'desc' }] }
                }}
                pageSizeOptions={[25, 50, 100]}
                disableRowSelectionOnClick
                sx={{ border: 'none' }}
                getRowHeight={() => 'auto'}
            />
        </Paper>
    );
}
