import { NextRequest } from 'next/server';
import { getDb, COLLECTIONS } from '@/lib/firebase-admin';
import { isAdminAuthenticated, unauthorizedResponse, successResponse, errorResponse } from '@/lib/auth';

export const dynamic = 'force-dynamic';

// GET /api/admin/analytics - Get aggregate statistics
export async function GET(request: NextRequest) {
    if (!isAdminAuthenticated(request)) {
        return unauthorizedResponse();
    }

    try {
        const db = await getDb();

        // Get total devices
        const devicesSnapshot = await db.collection(COLLECTIONS.DEVICES).get();
        const totalDevices = devicesSnapshot.size;

        // Get active today (devices with lastActiveAt within 24 hours)
        const yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);

        const activeDevices = devicesSnapshot.docs.filter(doc => {
            const lastActive = doc.data().lastActiveAt?.toDate?.();
            return lastActive && lastActive > yesterday;
        });
        const activeToday = activeDevices.length;

        // Get total customers (approximate - use count query if available)
        const customersSnapshot = await db.collection(COLLECTIONS.CUSTOMERS)
            .where('is_deleted', '!=', true)
            .limit(1000)
            .get();
        const totalCustomers = customersSnapshot.size;

        // Get total windows
        const windowsSnapshot = await db.collection(COLLECTIONS.WINDOWS)
            .where('is_deleted', '!=', true)
            .limit(5000)
            .get();
        const totalWindows = windowsSnapshot.size;

        // Get recent activity
        const recentLogsSnapshot = await db.collection(COLLECTIONS.ACTIVITY_LOGS)
            .orderBy('timestamp', 'desc')
            .limit(20)
            .get();

        const recentActivity = recentLogsSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data(),
        }));

        // Device status breakdown
        const statusBreakdown = {
            active: 0,
            locked: 0,
            expired: 0,
        };
        devicesSnapshot.docs.forEach(doc => {
            const status = doc.data().status || 'active';
            if (status in statusBreakdown) {
                statusBreakdown[status as keyof typeof statusBreakdown]++;
            }
        });

        return successResponse({
            success: true,
            analytics: {
                totalDevices,
                activeToday,
                totalCustomers,
                totalWindows,
                statusBreakdown,
            },
            recentActivity,
        });

    } catch (error) {
        console.error('Analytics error:', error);
        return errorResponse(`Failed to get analytics: ${error}`, 500);
    }
}
