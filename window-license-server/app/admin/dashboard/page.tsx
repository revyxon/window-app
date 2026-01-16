import { getDashboardStats } from "@/lib/data"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Activity, ShieldCheck, Lock, Smartphone, ServerCrash } from "lucide-react"

export const dynamic = 'force-dynamic'

export default async function DashboardPage() {
    const stats = await getDashboardStats()

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <h2 className="text-3xl font-bold tracking-tight">Control HQ</h2>
                <span className="text-sm text-muted-foreground font-mono">System Status: ONLINE</span>
            </div>

            {/* High Level Stats */}
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                <Card className="glass border-l-4 border-l-primary/50">
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Total Devices</CardTitle>
                        <Smartphone className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{stats.totalDevices}</div>
                        <p className="text-xs text-muted-foreground">Registered Units</p>
                    </CardContent>
                </Card>

                <Card className="glass border-l-4 border-l-green-500/50">
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Active Sessions</CardTitle>
                        <Activity className="h-4 w-4 text-green-500" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{stats.activeSessions}</div>
                        <p className="text-xs text-muted-foreground">Within 7-day Grace Period</p>
                    </CardContent>
                </Card>

                <Card className="glass border-l-4 border-l-destructive/50">
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Locked Devices</CardTitle>
                        <Lock className="h-4 w-4 text-destructive" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{stats.lockedDevices}</div>
                        <p className="text-xs text-muted-foreground">Administratively disabled</p>
                    </CardContent>
                </Card>

                <Card className="glass border-l-4 border-l-blue-500/50">
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Updates</CardTitle>
                        <ServerCrash className="h-4 w-4 text-blue-500" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{stats.totalUpdates}</div>
                        <p className="text-xs text-muted-foreground">Releases Published</p>
                    </CardContent>
                </Card>
            </div>

            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
                {/* Version Distribution */}
                <Card className="col-span-4 glass">
                    <CardHeader>
                        <CardTitle>Version Distribution</CardTitle>
                        <CardDescription>
                            Breakdown of app versions installed on devices.
                        </CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {Object.entries(stats.versionDistribution).map(([version, count]) => (
                                <div key={version} className="flex items-center">
                                    <div className="w-24 text-sm font-medium">{version}</div>
                                    <div className="flex-1 h-3 rounded-full bg-secondary overflow-hidden">
                                        <div
                                            className="h-full bg-primary"
                                            style={{ width: `${(count / stats.totalDevices) * 100}%` }}
                                        />
                                    </div>
                                    <div className="w-12 text-sm text-right text-muted-foreground">{count}</div>
                                </div>
                            ))}
                            {Object.keys(stats.versionDistribution).length === 0 && (
                                <p className="text-sm text-muted-foreground">No data available.</p>
                            )}
                        </div>
                    </CardContent>
                </Card>

                {/* Quick Tips / Info */}
                <Card className="col-span-3 glass">
                    <CardHeader>
                        <CardTitle>Admin Notice</CardTitle>
                        <CardDescription>System policies active.</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-4 text-sm">
                        <div className="flex items-start gap-2">
                            <ShieldCheck className="h-4 w-4 mt-0.5 text-green-600" />
                            <div>
                                <p className="font-medium">7-Day Grace Period</p>
                                <p className="text-muted-foreground">Devices can function offline for 7 days before auto-locking.</p>
                            </div>
                        </div>
                        <div className="flex items-start gap-2">
                            <Activity className="h-4 w-4 mt-0.5 text-blue-600" />
                            <div>
                                <p className="font-medium">Invisible Check</p>
                                <p className="text-muted-foreground">License validation happens silently 15s after startup.</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    )
}
