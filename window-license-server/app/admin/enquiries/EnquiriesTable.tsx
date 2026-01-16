'use client';
import * as React from 'react';
import { DataGrid, GridColDef, GridToolbar, GridRenderCellParams } from '@mui/x-data-grid';
import Paper from '@mui/material/Paper';
import Chip from '@mui/material/Chip';

interface EnquiriesTableProps {
    initialData: any[];
}

const columns: GridColDef[] = [
    { field: 'customerName', headerName: 'Customer', width: 180 },
    { field: 'phone', headerName: 'Phone', width: 150 },
    { field: 'message', headerName: 'Message', flex: 1, minWidth: 250 },
    {
        field: 'status',
        headerName: 'Status',
        width: 120,
        renderCell: (params: GridRenderCellParams) => (
            <Chip label={params.value} color={params.value === 'completed' ? 'success' : 'default'} size="small" variant="outlined" />
        )
    },
    {
        field: 'date',
        headerName: 'Date',
        width: 180,
        valueFormatter: (params) => params.value ? new Date(params.value).toLocaleString() : '-'
    },
];

export default function EnquiriesTable({ initialData }: EnquiriesTableProps) {
    return (
        <Paper sx={{ width: '100%', height: 600 }}>
            <DataGrid
                rows={initialData}
                columns={columns}
                getRowId={(row) => row.id}
                slots={{ toolbar: GridToolbar }}
                slotProps={{
                    toolbar: { showQuickFilter: true, quickFilterProps: { debounceMs: 500 } },
                }}
                initialState={{ pagination: { paginationModel: { pageSize: 15 } } }}
                pageSizeOptions={[15, 30, 50]}
                disableRowSelectionOnClick
                sx={{ border: 'none' }}
            />
        </Paper>
    );
}
