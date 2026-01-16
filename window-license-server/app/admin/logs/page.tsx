import { getRecentLogs } from "@/lib/data"
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import LogsTable from "./LogsTable";

export const dynamic = 'force-dynamic'

export default async function LogsPage() {
    const logs = await getRecentLogs();

    return (
        <Box>
            <Box sx={{ mb: 4 }}>
                <Typography variant="h4" fontWeight={700}>System Activity</Typography>
                <Typography color="text.secondary">Recent device telemetry and security events (Last 7 Days).</Typography>
            </Box>
            <LogsTable initialData={logs} />
        </Box>
    );
}
