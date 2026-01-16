import { getAllDevices } from "@/lib/data"
import { DataTable } from "@/components/data-table"
import { columns } from "./columns"

export const dynamic = 'force-dynamic'

export default async function UsersPage() {
    const devices = await getAllDevices()

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <h2 className="text-3xl font-bold tracking-tight">Devices</h2>
            </div>
            <DataTable
                columns={columns}
                data={devices}
                filterColumn="deviceId"
                filterPlaceholder="Filter by Device ID..."
            />
        </div>
    )
}
