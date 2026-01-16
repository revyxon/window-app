import { getAllEnquiries } from "@/lib/data"
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import EnquiriesTable from "./EnquiriesTable";

export const dynamic = 'force-dynamic'

export default async function EnquiriesPage() {
    const enquiries = await getAllEnquiries();

    return (
        <Box>
            <Box sx={{ mb: 4 }}>
                <Typography variant="h4" fontWeight={700}>Enquiries</Typography>
                <Typography color="text.secondary">Incoming messages and requests.</Typography>
            </Box>
            <EnquiriesTable initialData={enquiries} />
        </Box>
    );
}
