import { NextRequest } from 'next/server';
import { getDb, COLLECTIONS, DEVICE_STATUS } from '@/lib/firebase-admin';
import { successResponse, errorResponse } from '@/lib/auth';
import type { LicenseResponse } from '@/types';

export const dynamic = 'force-dynamic';

// GET /api/devices/[deviceId]/license - Check license status
export async function GET(
    request: NextRequest,
    { params }: { params: { deviceId: string } }
) {
    try {
        const { deviceId } = params;

        if (!deviceId) {
            return errorResponse('deviceId is required', 400);
        }

        const db = await getDb();
        const deviceRef = db.collection(COLLECTIONS.DEVICES).doc(deviceId);
        const deviceDoc = await deviceRef.get();

        if (!deviceDoc.exists) {
            // Device not found - return invalid but allow registration
            const response: LicenseResponse = {
                isValid: false,
                status: 'unregistered',
                message: 'Device not registered. Please register first.',
            };
            return successResponse(response);
        }

        const data = deviceDoc.data();
        const status = data?.status || DEVICE_STATUS.ACTIVE;
        const licenseExpiry = data?.licenseExpiry?.toDate?.()?.toISOString() || null;

        // Check if locked
        if (status === DEVICE_STATUS.LOCKED) {
            const response: LicenseResponse = {
                isValid: false,
                status: 'locked',
                message: 'Your device access has been revoked. Contact support.',
            };
            return successResponse(response);
        }

        // Check if expired
        if (status === DEVICE_STATUS.EXPIRED ||
            (licenseExpiry && new Date(licenseExpiry) < new Date())) {
            const response: LicenseResponse = {
                isValid: false,
                status: 'expired',
                message: 'Your license has expired. Please renew.',
                expiresAt: licenseExpiry,
            };
            return successResponse(response);
        }

        // License is valid
        const response: LicenseResponse = {
            isValid: true,
            status: 'active',
            expiresAt: licenseExpiry,
        };
        return successResponse(response);

    } catch (error) {
        console.error('License check error:', error);
        return errorResponse(`License check failed: ${error}`, 500);
    }
}
