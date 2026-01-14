import React from 'react';

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
            <body style={{ margin: 0, backgroundColor: '#f5f5f5' }}>{children}</body>
        </html>
    );
}
