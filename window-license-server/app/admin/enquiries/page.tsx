import { getAllEnquiries } from "@/lib/data"
import { DataTable } from "@/components/data-table"
import { columns } from "./columns"

export const dynamic = 'force-dynamic'

export default async function EnquiriesPage() {
    const enquiries = await getAllEnquiries()

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight">Enquiries</h2>
                    <p className="text-muted-foreground">Customer enquiries synced from devices.</p>
                </div>
            </div>
            <DataTable
                columns={columns}
                data={enquiries}
                filterColumn="customerName"
                filterPlaceholder="Filter by customer..."
            />
        </div>
    )
}
