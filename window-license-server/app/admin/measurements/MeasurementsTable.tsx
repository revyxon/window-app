'use client';
import * as React from 'react';
import { DataGrid, GridColDef, GridToolbar, GridRenderCellParams } from '@mui/x-data-grid';
import Paper from '@mui/material/Paper';
import Chip from '@mui/material/Chip';

interface MeasurementsTableProps {
    initialData: any[];
}

const columns: GridColDef[] = [
    { field: 'name', headerName: 'Window Name', flex: 1, minWidth: 150 },
    { field: 'width', headerName: 'Width', width: 100 },
    { field: 'height', headerName: 'Height', width: 100 },
    { field: 'quantity', headerName: 'Qty', width: 80 },
    { field: 'glassType', headerName: 'Glass Type', width: 150 },
    { field: 'customerId', headerName: 'Customer ID', width: 200 },
    { field: 'deviceId', headerName: 'Device', width: 200 },
];

export default function MeasurementsTable({ initialData }: MeasurementsTableProps) {
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
