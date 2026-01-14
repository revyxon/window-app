import { NextRequest } from 'next/server';
import { getDb, COLLECTIONS } from '@/lib/firebase-admin';
import { successResponse, errorResponse } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// POST /api/devices/[deviceId]/activity - Push activity logs
export async function POST(
    request: NextRequest,
    { params }: { params: { deviceId: string } }
) {
    try {
        const { deviceId } = params;

        if (!deviceId) {
            return errorResponse('deviceId is required', 400);
        }

        const body = await request.json();
        const { logs } = body;

        if (!logs || !Array.isArray(logs) || logs.length === 0) {
            return errorResponse('logs array is required', 400);
        }

        const db = await getDb();
        const batch = db.batch();

        for (const log of logs) {
            if (!log.id) continue;

            const logRef = db.collection(COLLECTIONS.ACTIVITY_LOGS).doc(log.id);
            batch.set(logRef, {
                ...log,
                deviceId,
            }, { merge: true });
        }

        await batch.commit();

        return successResponse({
            success: true,
            count: logs.length,
            message: `${logs.length} activity logs saved`,
        });

    } catch (error) {
        console.error('Activity log error:', error);
        return errorResponse(`Failed to save activity logs: ${error}`, 500);
    }
}
