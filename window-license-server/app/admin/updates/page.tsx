import { getAllUpdates } from "@/lib/data"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { formatDate } from "@/lib/utils"
import { Download, UploadCloud } from "lucide-react"

export const dynamic = 'force-dynamic'

export default async function UpdatesPage() {
    const updates = await getAllUpdates()

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight">Update Releases</h2>
                    <p className="text-muted-foreground">Manage app versions and releases.</p>
                </div>
                <Button>
                    <UploadCloud className="mr-2 h-4 w-4" />
                    Publish New Update
                </Button>
            </div>

            <div className="grid gap-4">
                {updates.map((update) => (
                    <Card key={update.id}>
                        <CardHeader className="flex flex-row items-start justify-between space-y-0">
                            <div className="space-y-1">
                                <CardTitle className="text-xl">
                                    v{update.version} <span className="text-muted-foreground font-normal text-sm">#{update.buildNumber}</span>
                                </CardTitle>
                                <CardDescription>
                                    Released on {formatDate(update.createdAt)}
                                </CardDescription>
                            </div>
                            <div className="flex items-center gap-2">
                                {update.forceUpdate && <Badge variant="destructive">Force Cloud</Badge>}
                                <Button variant="outline" size="sm" asChild>
                                    <a href={update.apkUrl} target="_blank" rel="noopener noreferrer">
                                        <Download className="mr-2 h-4 w-4" />
                                        Download APK
                                    </a>
                                </Button>
                            </div>
                        </CardHeader>
                        <CardContent>
                            <div className="bg-muted/50 p-4 rounded-md text-sm whitespace-pre-wrap font-mono">
                                {update.releaseNotes || 'No release notes provided.'}
                            </div>
                        </CardContent>
                    </Card>
                ))}

                {updates.length === 0 && (
                    <div className="text-center py-12 text-muted-foreground">
                        No updates published yet.
                    </div>
                )}
            </div>
        </div>
    )
}
