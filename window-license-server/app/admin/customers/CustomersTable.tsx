'use client';
import * as React from 'react';
import { DataGrid, GridColDef, GridToolbar } from '@mui/x-data-grid';
import Paper from '@mui/material/Paper';

interface CustomersTableProps {
    initialData: any[];
}

const columns: GridColDef[] = [
    { field: 'name', headerName: 'Name', flex: 1, minWidth: 150 },
    { field: 'phone', headerName: 'Phone', width: 150 },
    { field: 'city', headerName: 'City', width: 150 },
    { field: 'address', headerName: 'Address', flex: 1, minWidth: 200 },
    { field: 'deviceId', headerName: 'Sync Source ID', width: 250 },
    {
        field: 'updatedAt',
        headerName: 'Last Sync',
        width: 180,
        valueFormatter: (params) => params.value ? new Date(params.value).toLocaleString() : '-'
    },
];

export default function CustomersTable({ initialData }: CustomersTableProps) {
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
