"use client"

import { ColumnDef } from "@tanstack/react-table"
import { Enquiry } from "@/types"
import { formatDate } from "@/lib/utils"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { ArrowUpDown } from "lucide-react"

export const columns: ColumnDef<Enquiry>[] = [
    {
        accessorKey: "date",
        header: ({ column }) => {
            return (
                <Button
                    variant="ghost"
                    onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
                >
                    Date
                    <ArrowUpDown className="ml-2 h-4 w-4" />
                </Button>
            )
        },
        cell: ({ row }) => <div className="font-mono text-xs">{formatDate(row.getValue("date"))}</div>,
    },
    {
        accessorKey: "customerName",
        header: "Customer",
    },
    {
        accessorKey: "phone",
        header: "Phone",
    },
    {
        accessorKey: "message",
        header: "Message",
        cell: ({ row }) => <div className="truncate max-w-[200px]" title={row.getValue("message")}>{row.getValue("message")}</div>
    },
    {
        accessorKey: "status",
        header: "Status",
        cell: ({ row }) => <Badge variant="outline">{row.getValue("status")}</Badge>
    },
]
