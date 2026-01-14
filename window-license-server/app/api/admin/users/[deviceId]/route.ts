import { NextRequest } from 'next/server';
import { getDb, COLLECTIONS, DEVICE_STATUS } from '@/lib/firebase-admin';
import { isAdminAuthenticated, unauthorizedResponse, successResponse, errorResponse } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/admin/users/[deviceId] - Get user details with customers, windows, and activity
export async function GET(
    request: NextRequest,
    { params }: { params: { deviceId: string } }
) {
    if (!isAdminAuthenticated(request)) {
        return unauthorizedResponse();
    }

    try {
        const { deviceId } = params;
        const db = await getDb();

        // Get device info
        const deviceDoc = await db.collection(COLLECTIONS.DEVICES).doc(deviceId).get();
        if (!deviceDoc.exists) {
            return errorResponse('Device not found', 404);
        }

        const deviceData = deviceDoc.data();
        const device = {
            deviceId,
            status: deviceData?.status || 'active',
            registeredAt: deviceData?.registeredAt?.toDate?.()?.toISOString() || null,
            lastActiveAt: deviceData?.lastActiveAt?.toDate?.()?.toISOString() || null,
            appVersion: deviceData?.appVersion || null,
            licenseExpiry: deviceData?.licenseExpiry?.toDate?.()?.toISOString() || null,
            deviceInfo: deviceData?.deviceInfo || null,
            controls: deviceData?.controls || {
                canCreateCustomer: true,
                canEditCustomer: true,
                canDeleteCustomer: true,
                canCreateWindow: true,
                canEditWindow: true,
                canDeleteWindow: true,
                canExportData: true,
                canPrint: true,
                canShare: true,
            },
            lockReason: deviceData?.lockReason || null,
        };

        // Get customers (no orderBy to avoid index requirement)
        const customersSnapshot = await db.collection(COLLECTIONS.CUSTOMERS)
            .where('deviceId', '==', deviceId)
            .limit(50)
            .get();

        const customers = customersSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data(),
        })).sort((a: any, b: any) => {
            const aTime = a.created_at?.toDate?.() || new Date(0);
            const bTime = b.created_at?.toDate?.() || new Date(0);
            return bTime.getTime() - aTime.getTime();
        });

        // Get windows (no orderBy to avoid index requirement)
        const windowsSnapshot = await db.collection(COLLECTIONS.WINDOWS)
            .where('deviceId', '==', deviceId)
            .limit(100)
            .get();

        const windows = windowsSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data(),
        })).sort((a: any, b: any) => {
            const aTime = a.created_at?.toDate?.() || new Date(0);
            const bTime = b.created_at?.toDate?.() || new Date(0);
            return bTime.getTime() - aTime.getTime();
        });

        // Get recent activity logs (no orderBy to avoid index requirement)
        const logsSnapshot = await db.collection(COLLECTIONS.ACTIVITY_LOGS)
            .where('deviceId', '==', deviceId)
            .limit(100)
            .get();

        const activityLogs = logsSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data(),
            timestamp: doc.data().timestamp?.toDate?.()?.toISOString() || null,
        })).sort((a: any, b: any) => {
            const aTime = new Date(a.timestamp || 0);
            const bTime = new Date(b.timestamp || 0);
            return bTime.getTime() - aTime.getTime();
        }).slice(0, 50);

        return successResponse({
            success: true,
            device,
            customers,
            windows,
            activityLogs,
            stats: {
                customerCount: customers.length,
                windowCount: windows.length,
                activityCount: activityLogs.length,
            },
        });

    } catch (error) {
        console.error('Get user details error:', error);
        return errorResponse(`Failed to get user details: ${error}`, 500);
    }
}

// PATCH /api/admin/users/[deviceId] - Update user (lock/unlock, set expiry)
export async function PATCH(
    request: NextRequest,
    { params }: { params: { deviceId: string } }
) {
    if (!isAdminAuthenticated(request)) {
        return unauthorizedResponse();
    }

    try {
        const { deviceId } = params;
        const body = await request.json();
        const { status, licenseExpiry, controls, lockReason } = body;

        const db = await getDb();
        const deviceRef = db.collection(COLLECTIONS.DEVICES).doc(deviceId);
        const deviceDoc = await deviceRef.get();

        if (!deviceDoc.exists) {
            return errorResponse('Device not found', 404);
        }

        const updateData: any = {};

        if (status && [DEVICE_STATUS.ACTIVE, DEVICE_STATUS.LOCKED, DEVICE_STATUS.EXPIRED].includes(status)) {
            updateData.status = status;
        }

        if (licenseExpiry !== undefined) {
            updateData.licenseExpiry = licenseExpiry ? new Date(licenseExpiry) : null;
        }

        // Handle granular controls update
        if (controls && typeof controls === 'object') {
            updateData.controls = controls;
        }

        // Handle lock reason
        if (lockReason !== undefined) {
            updateData.lockReason = lockReason;
        }

        if (Object.keys(updateData).length === 0) {
            return errorResponse('No valid fields to update', 400);
        }

        await deviceRef.update(updateData);

        return successResponse({
            success: true,
            message: 'Device updated successfully',
            deviceId,
            updates: updateData,
        });

    } catch (error) {
        console.error('Update user error:', error);
        return errorResponse(`Failed to update user: ${error}`, 500);
    }
}
