import { getDeviceDetails } from "@/lib/data"
import { toggleDeviceLock } from "@/app/actions/device"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { formatDate } from "@/lib/utils"
import { ArrowLeft, Lock, Unlock, ShieldAlert, Smartphone } from "lucide-react"
import Link from "next/link"
import { notFound } from "next/navigation"

export const dynamic = 'force-dynamic'

export default async function DeviceDetailsPage({ params }: { params: { deviceId: string } }) {
    const device = await getDeviceDetails(params.deviceId)

    if (!device) {
        notFound()
    }

    const isLocked = device.status === 'locked'

    return (
        <div className="space-y-6 max-w-5xl mx-auto">
            <div className="flex items-center gap-4">
                <Link href="/admin/users">
                    <Button variant="ghost" size="icon">
                        <ArrowLeft className="h-4 w-4" />
                    </Button>
                </Link>
                <div>
                    <h2 className="text-2xl font-bold tracking-tight">Device Details</h2>
                    <p className="text-muted-foreground font-mono text-xs">{device.deviceId}</p>
                </div>
                <div className="ml-auto">
                    <form action={async () => {
                        'use server'
                        await toggleDeviceLock(device.deviceId, device.status)
                    }}>
                        <Button variant={isLocked ? "default" : "destructive"}>
                            {isLocked ? <Unlock className="mr-2 h-4 w-4" /> : <Lock className="mr-2 h-4 w-4" />}
                            {isLocked ? "Unlock Device" : "Lock Device"}
                        </Button>
                    </form>
                </div>
            </div>

            <div className="grid gap-6 md:grid-cols-2">
                <Card className="glass">
                    <CardHeader>
                        <CardTitle>Status & Info</CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div className="flex justify-between items-center border-b pb-2">
                            <span className="text-sm font-medium">Status</span>
                            <Badge variant={isLocked ? "destructive" : "default"}>{device.status.toUpperCase()}</Badge>
                        </div>
                        <div className="flex justify-between items-center border-b pb-2">
                            <span className="text-sm font-medium">App Version</span>
                            <span className="text-sm text-muted-foreground">{device.version}</span>
                        </div>
                        <div className="flex justify-between items-center border-b pb-2">
                            <span className="text-sm font-medium">Last Active</span>
                            <span className="text-sm text-muted-foreground">{formatDate(device.lastActive)}</span>
                        </div>
                        <div className="flex justify-between items-center border-b pb-2">
                            <span className="text-sm font-medium">Registered</span>
                            <span className="text-sm text-muted-foreground">{formatDate(device.registerDate)}</span>
                        </div>
                        <div className="flex justify-between items-center pt-2">
                            <span className="text-sm font-medium">Hardware</span>
                            <div className="flex items-center text-sm text-muted-foreground">
                                <Smartphone className="mr-2 h-3 w-3" />
                                {device.model} ({device.os})
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <Card className="glass">
                    <CardHeader>
                        <CardTitle>Activity Log</CardTitle>
                        <CardDescription>Recent actions from this device</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4 relative pl-4 border-l-2 border-muted">
                            {device.activities.map((log: any) => (
                                <div key={log.id} className="relative">
                                    <div className="absolute -left-[21px] top-1 h-3 w-3 rounded-full bg-primary ring-4 ring-background" />
                                    <div className="text-sm font-medium">{log.action || 'Unknown Action'}</div>
                                    <div className="text-xs text-muted-foreground">{formatDate(log.timestamp)}</div>
                                </div>
                            ))}
                            {device.activities.length === 0 && (
                                <div className="text-sm text-muted-foreground italic">No recent activity recorded.</div>
                            )}
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    )
}
