import { NextRequest, NextResponse } from 'next/server';
import { getDb, COLLECTIONS, DEVICE_STATUS } from '@/lib/firebase-admin';
import { successResponse, errorResponse } from '@/lib/auth';
import { FieldValue } from 'firebase-admin/firestore';

export const dynamic = 'force-dynamic';

// POST /api/devices/register - Register a new device
export async function POST(request: NextRequest) {
    try {
        const body = await request.json();
        const { deviceId, appVersion } = body;

        if (!deviceId) {
            return errorResponse('deviceId is required', 400);
        }

        const db = await getDb();
        const deviceRef = db.collection(COLLECTIONS.DEVICES).doc(deviceId);
        const deviceDoc = await deviceRef.get();

        const now = FieldValue.serverTimestamp();

        if (!deviceDoc.exists) {
            // New device registration
            await deviceRef.set({
                deviceId,
                status: DEVICE_STATUS.ACTIVE,
                registeredAt: now,
                lastActiveAt: now,
                appVersion: appVersion || null,
            });

            return successResponse({
                success: true,
                isNew: true,
                message: 'Device registered successfully',
                status: DEVICE_STATUS.ACTIVE,
            }, 201);
        } else {
            // Existing device - update last active
            await deviceRef.update({
                lastActiveAt: now,
                appVersion: appVersion || deviceDoc.data()?.appVersion,
            });

            const data = deviceDoc.data();
            return successResponse({
                success: true,
                isNew: false,
                status: data?.status || DEVICE_STATUS.ACTIVE,
            });
        }
    } catch (error) {
        console.error('Device registration error:', error);
        return errorResponse(`Registration failed: ${error}`, 500);
    }
}
