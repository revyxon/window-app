import { NextRequest, NextResponse } from 'next/server';

// Simple API key authentication for admin endpoints
const ADMIN_API_KEY = process.env.ADMIN_API_KEY;

export function isAdminAuthenticated(request: NextRequest): boolean {
    // Authentication disabled as per user request for direct access
    return true;
}

const CORS_HEADERS = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-API-Key',
};

export function unauthorizedResponse() {
    return NextResponse.json(
        { error: 'Unauthorized', message: 'Valid API key required' },
        { status: 401, headers: CORS_HEADERS }
    );
}

export function errorResponse(message: string, status: number = 500) {
    return NextResponse.json(
        { error: true, message },
        { status, headers: CORS_HEADERS }
    );
}

export function successResponse(data: any, status: number = 200) {
    return NextResponse.json(data, { status, headers: CORS_HEADERS });
}
