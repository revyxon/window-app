import { getAllMeasurements } from "@/lib/data"
import { DataTable } from "@/components/data-table"
import { columns } from "./columns"

export const dynamic = 'force-dynamic'

export default async function MeasurementsPage() {
    const measurements = await getAllMeasurements()

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight">Measurements</h2>
                    <p className="text-muted-foreground">All window dimensions synced to cloud.</p>
                </div>
            </div>
            <DataTable
                columns={columns}
                data={measurements}
                filterColumn="name"
                filterPlaceholder="Filter by window name..."
            />
        </div>
    )
}
