import { getRecentLogs } from "@/lib/data"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { formatDate } from "@/lib/utils"
import { Badge } from "@/components/ui/badge"

export const dynamic = 'force-dynamic'

export default async function LogsPage() {
    const logs = await getRecentLogs()

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight">System Logs</h2>
                    <p className="text-muted-foreground">Recent activity and security events (Last 100).</p>
                </div>
            </div>

            <Card className="glass">
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead className="w-[180px]">Timestamp</TableHead>
                            <TableHead>Event</TableHead>
                            <TableHead>Device ID</TableHead>
                            <TableHead>Details</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {logs.map((log) => (
                            <TableRow key={log.id}>
                                <TableCell className="font-mono text-xs text-muted-foreground">
                                    {formatDate(log.timestamp)}
                                </TableCell>
                                <TableCell>
                                    <Badge variant="outline">{log.action || 'Unknown'}</Badge>
                                </TableCell>
                                <TableCell className="font-mono text-xs">
                                    {log.deviceId}
                                </TableCell>
                                <TableCell className="text-sm">
                                    {/* Render details JSON or specific fields if available */}
                                    {JSON.stringify(log.details || log.metadata || {})}
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
                {logs.length === 0 && (
                    <div className="p-8 text-center text-muted-foreground">
                        No logs found.
                    </div>
                )}
            </Card>
        </div>
    )
}
