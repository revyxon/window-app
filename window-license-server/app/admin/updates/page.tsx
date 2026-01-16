import { getAllUpdates } from "@/lib/data"
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import UpdatesClient from "./UpdatesClient";

export const dynamic = 'force-dynamic'

export default async function UpdatesPage() {
    const updates = await getAllUpdates();

    return (
        <Box>
            <Box sx={{ mb: 4 }}>
                <Typography variant="h4" fontWeight={700}>System Updates</Typography>
                <Typography color="text.secondary">Manage app versions and release channels.</Typography>
            </Box>
            <UpdatesClient initialUpdates={updates} />
        </Box>
    );
}
