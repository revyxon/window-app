import { getAllCustomers } from "@/lib/data"
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Paper from '@mui/material/Paper';
import CustomersTable from "./CustomersTable";

export const dynamic = 'force-dynamic'

export default async function CustomersPage() {
    const customers = await getAllCustomers();

    return (
        <Box>
            <Box sx={{ mb: 4 }}>
                <Typography variant="h4" fontWeight={700}>Customers</Typography>
                <Typography color="text.secondary">All customer profiles synced from devices.</Typography>
            </Box>
            <CustomersTable initialData={customers} />
        </Box>
    );
}
