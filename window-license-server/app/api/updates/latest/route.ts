import { NextRequest } from 'next/server';
import { getDb, COLLECTIONS } from '@/lib/firebase-admin';
import { successResponse, errorResponse } from '@/lib/auth';

// Force dynamic rendering (no static generation)
export const dynamic = 'force-dynamic';

// GET /api/updates/latest - Get latest app version info
export async function GET(request: NextRequest) {
    try {
        const db = await getDb();

        // Get the latest update document
        const updatesSnapshot = await db.collection(COLLECTIONS.UPDATES)
            .orderBy('buildNumber', 'desc')
            .limit(1)
            .get();

        if (updatesSnapshot.empty) {
            return successResponse({
                success: true,
                hasUpdate: false,
                message: 'No updates available',
            });
        }

        const latestUpdate = updatesSnapshot.docs[0].data();

        return successResponse({
            success: true,
            hasUpdate: true,
            update: {
                version: latestUpdate.version,
                buildNumber: latestUpdate.buildNumber,
                apkUrl: latestUpdate.apkUrl,
                fileSize: latestUpdate.fileSize || 0,
                releaseNotes: latestUpdate.releaseNotes || null,
                forceUpdate: latestUpdate.forceUpdate || false,
                skipAllowed: latestUpdate.skipAllowed || false,
                createdAt: latestUpdate.createdAt?.toDate?.()?.toISOString() || null,
            },
        });

    } catch (error) {
        console.error('Get latest update error:', error);
        return errorResponse(`Failed to get update info: ${error}`, 500);
    }
}
