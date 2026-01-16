import { getAllDevices } from "@/lib/data"
import UsersTable from "./UsersTable"
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';

export const dynamic = 'force-dynamic'

export default async function UsersPage() {
    const devices = await getAllDevices()

    return (
        <Box>
            <Box sx={{ mb: 4, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <Box>
                    <Typography variant="h4" fontWeight={700}>
                        License Control
                    </Typography>
                    <Typography color="text.secondary">
                        Manage device access, grace periods, and versions.
                    </Typography>
                </Box>
            </Box>
            <UsersTable initialDevices={devices} />
        </Box>
    )
}
