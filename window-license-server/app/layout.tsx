import './globals.css';
import React from 'react';
import { Toaster } from "@/components/ui/sonner"

export const metadata = {
    title: 'Window License Server',
    description: 'API Server for Window Measurement App',
};

export default function RootLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    return (
        <html lang="en">
            <body>
                {children}
                <Toaster />
            </body>
        </html>
    );
}
