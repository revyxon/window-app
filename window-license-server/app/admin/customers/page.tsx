import { getAllCustomers } from "@/lib/data"
import { DataTable } from "@/components/data-table"
import { columns } from "./columns"

export const dynamic = 'force-dynamic'

export default async function CustomersPage() {
    const customers = await getAllCustomers()

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight">Customers</h2>
                    <p className="text-muted-foreground">Synced customer database from all devices.</p>
                </div>
            </div>
            <DataTable
                columns={columns}
                data={customers}
                filterColumn="name"
                filterPlaceholder="Filter by name..."
            />
        </div>
    )
}
