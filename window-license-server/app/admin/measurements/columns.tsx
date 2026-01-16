"use client"

import { ColumnDef } from "@tanstack/react-table"
import { Measurement } from "@/types"
import { formatDate } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import { ArrowUpDown } from "lucide-react"

export const columns: ColumnDef<Measurement>[] = [
    {
        accessorKey: "name",
        header: "Window Name",
        cell: ({ row }) => <div className="font-medium">{row.getValue("name")}</div>,
    },
    {
        id: "dimensions",
        header: "Dimensions (WxH)",
        cell: ({ row }) => {
            const w = row.original.width;
            const h = row.original.height;
            return <div className="font-mono text-xs">{w} x {h}</div>
        }
    },
    {
        accessorKey: "quantity",
        header: "Qty",
    },
    {
        accessorKey: "glassType",
        header: "Glass",
    },
    {
        accessorKey: "deviceId",
        header: "Source Device",
        cell: ({ row }) => <div className="font-mono text-xs text-muted-foreground">{row.getValue("deviceId")}</div>,
    },
    {
        accessorKey: "updatedAt",
        header: ({ column }) => {
            return (
                <Button
                    variant="ghost"
                    onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
                >
                    Last Updated
                    <ArrowUpDown className="ml-2 h-4 w-4" />
                </Button>
            )
        },
        cell: ({ row }) => formatDate(row.getValue("updatedAt")),
    },
]
