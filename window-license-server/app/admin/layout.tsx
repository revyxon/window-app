import type { Metadata } from "next"
import { AdminSidebar } from "@/components/admin-sidebar"

export const metadata: Metadata = {
    title: "Window Admin",
    description: "Window Measurement App Admin Dashboard",
}

export default function AdminLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return (
        <div className="flex min-h-screen">
            <AdminSidebar className="hidden w-64 md:block fixed h-full" />
            <main className="flex-1 md:pl-64">
                <div className="p-8">
                    {children}
                </div>
            </main>
        </div>
    )
}
