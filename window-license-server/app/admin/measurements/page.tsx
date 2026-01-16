import { getAllMeasurements } from "@/lib/data"
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import MeasurementsTable from "./MeasurementsTable";

export const dynamic = 'force-dynamic'

export default async function MeasurementsPage() {
    const measurements = await getAllMeasurements();

    return (
        <Box>
            <Box sx={{ mb: 4 }}>
                <Typography variant="h4" fontWeight={700}>Measurements</Typography>
                <Typography color="text.secondary">Window specifications and quantities.</Typography>
            </Box>
            <MeasurementsTable initialData={measurements} />
        </Box>
    );
}
