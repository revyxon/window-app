import { NextRequest } from 'next/server';
import { getDb, COLLECTIONS } from '@/lib/firebase-admin';
import { isAdminAuthenticated, unauthorizedResponse, successResponse, errorResponse } from '@/lib/auth';
import { FieldValue } from 'firebase-admin/firestore';

// Force dynamic rendering
const CORS_HEADERS = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-API-Key',
};

export async function OPTIONS() {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
}

export const dynamic = 'force-dynamic';


// POST /api/updates/upload - Create a new update entry (APK URL provided separately)
export async function POST(request: NextRequest) {
    if (!isAdminAuthenticated(request)) {
        return unauthorizedResponse();
    }

    try {
        const body = await request.json();
        const { version, buildNumber, apkUrl, fileSize, releaseNotes, forceUpdate, skipAllowed } = body;

        if (!version || !buildNumber || !apkUrl || !fileSize) {
            return errorResponse('version, buildNumber, apkUrl, and fileSize are required', 400);
        }

        const db = await getDb();
        const updateData = {
            version,
            buildNumber: parseInt(buildNumber, 10),
            apkUrl,
            fileSize: parseInt(fileSize, 10),
            releaseNotes: releaseNotes || null,
            forceUpdate: forceUpdate === true,
            skipAllowed: skipAllowed === true,
            createdAt: FieldValue.serverTimestamp(),
        };

        const docRef = await db.collection(COLLECTIONS.UPDATES).add(updateData);

        return successResponse({
            success: true,
            message: 'Update created successfully',
            id: docRef.id,
            update: updateData,
        }, 201);

    } catch (error) {
        console.error('Create update error:', error);
        return errorResponse(`Failed to create update: ${error}`, 500);
    }
}

// GET /api/updates/upload - List all updates (admin only)
export async function GET(request: NextRequest) {
    if (!isAdminAuthenticated(request)) {
        return unauthorizedResponse();
    }

    try {
        const db = await getDb();
        const updatesSnapshot = await db.collection(COLLECTIONS.UPDATES)
            .orderBy('buildNumber', 'desc')
            .limit(20)
            .get();

        const updates = updatesSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data(),
            createdAt: doc.data().createdAt?.toDate?.()?.toISOString() || null,
        }));

        return successResponse({
            success: true,
            count: updates.length,
            updates,
        });

    } catch (error) {
        console.error('List updates error:', error);
        return errorResponse(`Failed to list updates: ${error}`, 500);
    }
}
