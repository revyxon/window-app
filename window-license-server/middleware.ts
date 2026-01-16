import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
    const { pathname } = request.nextUrl;

    // Handle CORS preflight requests
    if (request.method === 'OPTIONS') {
        return new NextResponse(null, {
            status: 204,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-API-Key',
                'Access-Control-Max-Age': '86400',
            },
        });
    }

    // Admin Auth Protection
    if (pathname.startsWith('/admin')) {
        // Allow public access to login page
        if (pathname === '/admin/login') {
            return NextResponse.next();
        }

        // Check for auth cookie
        const authToken = request.cookies.get('admin_session');
        if (!authToken) {
            const loginUrl = new URL('/admin/login', request.url);
            // Optional: Add returnUrl param
            return NextResponse.redirect(loginUrl);
        }
    }

    const response = NextResponse.next();

    // Add CORS headers to all responses
    response.headers.set('Access-Control-Allow-Origin', '*');
    response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
    response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-API-Key');

    return response;
}

// Only apply to API routes and admin pages
export const config = {
    matcher: ['/api/:path*', '/admin/:path*'],
};
