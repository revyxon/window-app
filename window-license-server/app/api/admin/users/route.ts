import { NextRequest } from 'next/server';
import { getDb, COLLECTIONS } from '@/lib/firebase-admin';
import { isAdminAuthenticated, unauthorizedResponse, successResponse, errorResponse } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/admin/users - List all registered devices
export async function GET(request: NextRequest) {
    if (!isAdminAuthenticated(request)) {
        return unauthorizedResponse();
    }

    try {
        const db = await getDb();
        const devicesSnapshot = await db.collection(COLLECTIONS.DEVICES)
            .orderBy('lastActiveAt', 'desc')
            .limit(100)
            .get();

        const devices = devicesSnapshot.docs.map(doc => {
            const data = doc.data();
            return {
                deviceId: doc.id,
                status: data.status || 'active',
                registeredAt: data.registeredAt?.toDate?.()?.toISOString() || null,
                lastActiveAt: data.lastActiveAt?.toDate?.()?.toISOString() || null,
                appVersion: data.appVersion || null,
                licenseExpiry: data.licenseExpiry?.toDate?.()?.toISOString() || null,
            };
        });

        return successResponse({
            success: true,
            count: devices.length,
            devices,
        });

    } catch (error) {
        console.error('List users error:', error);
        return errorResponse(`Failed to list users: ${error}`, 500);
    }
}
