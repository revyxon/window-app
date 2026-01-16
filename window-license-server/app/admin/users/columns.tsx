"use client"

import { ColumnDef } from "@tanstack/react-table"
import { Device } from "@/types"
import { Badge } from "@/components/ui/badge"
import { formatDate } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import { ArrowUpDown, Link as LinkIcon, Lock, RefreshCw, AlertTriangle, ShieldCheck } from "lucide-react"
import { forceDeviceCheck } from "@/app/actions/force-check"
import { useState } from "react"
import { toast } from "sonner" // Assuming sonner is installed, or just simple alert/console for now if not. We'll use simple feedback.

// Helper for Force Check Button
function ForceCheckButton({ deviceId, isForced }: { deviceId: string, isForced?: boolean }) {
    const [loading, setLoading] = useState(false)
    const [forced, setForced] = useState(isForced)

    const handleForceCheck = async () => {
        setLoading(true)
        const res = await forceDeviceCheck(deviceId)
        setLoading(false)
        if (res.success) {
            setForced(true)
        }
    }

    if (forced) {
        return <Badge variant="outline" className="text-xs text-orange-500 border-orange-200 bg-orange-50">Pending Check</Badge>
    }

    return (
        <Button
            variant="ghost"
            size="sm"
            onClick={handleForceCheck}
            disabled={loading}
            title="Force immediate validation on next ping"
        >
            <RefreshCw className={`h-3 w-3 ${loading ? 'animate-spin' : ''}`} />
        </Button>
    )
}

export const columns: ColumnDef<Device>[] = [
    {
        accessorKey: "deviceId",
        header: "Device / Model",
        cell: ({ row }) => (
            <div className="flex flex-col">
                <span className="font-mono text-xs font-medium">{row.getValue("deviceId")}</span>
                <span className="text-[10px] text-muted-foreground truncate max-w-[120px]">
                    {/* Accessing nested data would require custom accessor or type assertion */}
                    {(row.original as any).deviceInfo?.model || 'Unknown'}
                </span>
            </div>
        ),
    },
    {
        accessorKey: "status",
        header: "Status",
        cell: ({ row }) => {
            const status = row.getValue("status") as string
            const lastActive = row.getValue("lastActiveAt") as string

            // Calculate Grace Status
            let graceStatus = 'Active'
            let variant: "default" | "destructive" | "secondary" | "outline" = "default"

            if (status === 'locked') {
                graceStatus = 'LOCKED'
                variant = 'destructive'
            } else if (lastActive) {
                const diff = new Date().getTime() - new Date(lastActive).getTime()
                const days = diff / (1000 * 60 * 60 * 24)

                if (days > 7) {
                    graceStatus = 'Expired (Offline)'
                    variant = 'secondary'
                } else if (days > 5) {
                    graceStatus = 'Grace Ending'
                    variant = 'outline'
                }
            } else {
                graceStatus = 'Unseen'
                variant = 'secondary'
            }

            return (
                <div className="flex flex-col gap-1 items-start">
                    {/* Global Lock Status */}
                    {status === 'locked' && <Badge variant="destructive" className="flex items-center gap-1"><Lock className="h-3 w-3" /> Server Lock</Badge>}

                    {/* Session/Grace Status */}
                    {status !== 'locked' && (
                        <Badge variant={variant} className="flex items-center gap-1">
                            {variant === 'default' && <ShieldCheck className="h-3 w-3" />}
                            {variant === 'secondary' && <AlertTriangle className="h-3 w-3" />}
                            {graceStatus}
                        </Badge>
                    )}
                </div>
            )
        },
    },
    {
        accessorKey: "appVersion",
        header: "Version",
        cell: ({ row }) => <span className="text-secondary-foreground font-mono text-xs">{row.getValue("appVersion") || 'N/A'}</span>
    },
    {
        accessorKey: "lastActiveAt",
        header: ({ column }) => {
            return (
                <Button
                    variant="ghost"
                    onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
                >
                    Last Active
                    <ArrowUpDown className="ml-2 h-4 w-4" />
                </Button>
            )
        },
        cell: ({ row }) => (
            <div className="text-xs">
                {formatDate(row.getValue("lastActiveAt"))}
            </div>
        ),
    },
    {
        id: "actions",
        header: "Actions",
        cell: ({ row }) => {
            return (
                <div className="flex items-center gap-2">
                    <ForceCheckButton
                        deviceId={row.getValue("deviceId")}
                        isForced={(row.original as any).forceCheck}
                    />
                    <Button variant="outline" size="sm" asChild>
                        <a href={`/admin/users/${row.getValue("deviceId")}`}>
                            View
                        </a>
                    </Button>
                </div>
            )
        }
    }
]
