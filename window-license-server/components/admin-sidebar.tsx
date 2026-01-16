"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { LayoutDashboard, Users, UploadCloud, LogOut, Package, List } from "lucide-react"
import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"

const sidebarItems = [
    { icon: LayoutDashboard, label: "Dashboard", href: "/admin/dashboard" },
    { icon: Users, label: "Users", href: "/admin/users" },
    { icon: UploadCloud, label: "Updates", href: "/admin/updates" },
    { icon: Users, label: "Customers", href: "/admin/customers" }, // Re-using Users icon or find better
    { icon: List, label: "Measurements", href: "/admin/measurements" },
    { icon: List, label: "Enquiries", href: "/admin/enquiries" },
    { icon: List, label: "Logs", href: "/admin/logs" },
]

export function AdminSidebar({ className }: { className?: string }) {
    const pathname = usePathname()

    return (
        <div className={cn("pb-12 min-h-screen border-r bg-muted/10", className)}>
            <div className="space-y-4 py-4">
                <div className="px-3 py-2">
                    <div className="mb-6 px-4 flex items-center gap-2">
                        <Package className="h-6 w-6" />
                        <h2 className="text-lg font-bold tracking-tight">
                            Window Admin
                        </h2>
                    </div>
                    <div className="space-y-1">
                        {sidebarItems.map((item) => (
                            <Button
                                key={item.href}
                                variant={pathname.startsWith(item.href) ? "secondary" : "ghost"}
                                className={cn(
                                    "w-full justify-start",
                                    pathname.startsWith(item.href) && "bg-secondary"
                                )}
                                asChild
                            >
                                <Link href={item.href}>
                                    <item.icon className="mr-2 h-4 w-4" />
                                    {item.label}
                                </Link>
                            </Button>
                        ))}
                    </div>
                </div>

                {/* Bottom Actions */}
                <div className="px-3 py-2 mt-auto absolute bottom-4">
                    {/* Add Logout here later */}
                </div>
            </div>
        </div>
    )
}
