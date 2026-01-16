import { getDb, COLLECTIONS } from './firebase-admin';
import { cache } from 'react';

export interface DashboardStats {
    totalDevices: number;
    activeSessions: number; // Users active within 7 days
    lockedDevices: number;
    totalUpdates: number;
    versionDistribution: Record<string, number>;
}

// Helper to safely convert Firestore timestamps or strings to Date
function safeDate(val: any): Date | null {
    if (!val) return null;
    try {
        if (typeof val.toDate === 'function') return val.toDate();
        if (val instanceof Date) return val;
        if (typeof val === 'string') return new Date(val);
        if (typeof val === 'number') return new Date(val);
    } catch (e) {
        console.error('Date parse error:', e);
    }
    return null;
}

// Cache the dashboard stats for 60 seconds
export const getDashboardStats = cache(async function (): Promise<DashboardStats> {
    try {
        const db = await getDb();

        // Total Devices
        const devicesSnapshot = await db.collection(COLLECTIONS.DEVICES).get();
        const totalDevices = devicesSnapshot.size;

        // Active Sessions (Grace Period: 7 Days)
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

        let activeSessions = 0;
        let lockedDevices = 0;
        const versionDistribution: Record<string, number> = {};

        devicesSnapshot.docs.forEach(doc => {
            const data = doc.data();

            // Count Locked
            if (data.status === 'locked') {
                lockedDevices++;
            }

            // Count Active Sessions (Last Active within 7 days)
            const lastActive = safeDate(data.lastActiveAt);
            if (lastActive && !isNaN(lastActive.getTime()) && lastActive > sevenDaysAgo) {
                activeSessions++;
            }

            // Version Distribution
            const ver = data.appVersion || 'Unknown';
            versionDistribution[ver] = (versionDistribution[ver] || 0) + 1;
        });

        // Updates count
        const updatesSnapshot = await db.collection(COLLECTIONS.UPDATES).count().get();
        const totalUpdates = updatesSnapshot.data().count;

        return {
            totalDevices,
            activeSessions,
            lockedDevices,
            totalUpdates,
            versionDistribution
        };
    } catch (error) {
        console.error("Dashboard Stats Error (returning defaults):", error);
        // Return zeros instead of crashing the page
        return {
            totalDevices: 0,
            activeSessions: 0,
            lockedDevices: 0,
            totalUpdates: 0,
            versionDistribution: {}
        };
    }
});

// Cache device list for 30 seconds
export const getAllDevices = cache(async function (): Promise<any[]> {
    try {
        const db = await getDb();
        const snapshot = await db.collection(COLLECTIONS.DEVICES)
            .orderBy('lastActiveAt', 'desc')
            .limit(200)
            .get();

        return snapshot.docs.map(doc => {
            const data = doc.data();
            return {
                deviceId: doc.id,
                status: data.status || 'active',
                registeredAt: safeDate(data.registeredAt)?.toISOString() || null,
                lastActiveAt: safeDate(data.lastActiveAt)?.toISOString() || null,
                appVersion: data.appVersion || null,
                licenseExpiry: safeDate(data.licenseExpiry)?.toISOString() || null,
                deviceInfo: data.deviceInfo || {},
                lockReason: data.lockReason || null,
                forceCheck: data.forceCheck || false,
                lastValidCheck: safeDate(data.lastValidCheck)?.toISOString() || null,
                graceStatus: data.graceStatus || 'active',
            };
        });
    } catch (error) {
        console.error("getAllDevices Error:", error);
        return [];
    }
});

export const getAllUpdates = cache(async function (): Promise<any[]> {
    try {
        const db = await getDb();
        const snapshot = await db.collection(COLLECTIONS.UPDATES)
            .orderBy('buildNumber', 'desc')
            .limit(50)
            .get();

        return snapshot.docs.map(doc => {
            const data = doc.data();
            return {
                id: doc.id,
                version: data.version,
                buildNumber: data.buildNumber,
                apkUrl: data.apkUrl,
                fileSize: data.fileSize,
                releaseNotes: data.releaseNotes,
                forceUpdate: data.forceUpdate,
                skipAllowed: data.skipAllowed,
                createdAt: safeDate(data.createdAt)?.toISOString() || null,
            };
        });
    } catch (error) {
        console.error("getAllUpdates Error:", error);
        return [];
    }
});

export const getDeviceDetails = cache(async function (deviceId: string) {
    try {
        const db = await getDb();
        const deviceDoc = await db.collection(COLLECTIONS.DEVICES).doc(deviceId).get();

        if (!deviceDoc.exists) return null;

        const data = deviceDoc.data();
        if (!data) return null;

        // Fetch recent activity
        const activitySnapshot = await db.collection(COLLECTIONS.ACTIVITY_LOGS)
            .where('deviceId', '==', deviceId)
            .orderBy('timestamp', 'desc')
            .limit(50)
            .get();

        const activities = activitySnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data(),
            timestamp: safeDate(doc.data().timestamp)?.toISOString() || null
        }));

        return {
            deviceId: deviceDoc.id,
            status: data.status || 'active',
            registerDate: safeDate(data.registeredAt)?.toISOString() || null,
            lastActive: safeDate(data.lastActiveAt)?.toISOString() || null,
            version: data.appVersion || 'Unknown',
            forceCheck: data.forceCheck || false,
            lastValidCheck: safeDate(data.lastValidCheck)?.toISOString() || null,
            graceStatus: data.graceStatus || 'active',
            model: data.deviceInfo?.model || 'Unknown Device',
            os: data.deviceInfo?.osVersion || 'Android',
            activities
        };
    } catch (error) {
        console.error("getDeviceDetails Error:", error);
        return null; // Return null to handle not found or error consistently
    }
});

export const getRecentLogs = cache(async function (): Promise<any[]> {
    try {
        const db = await getDb();
        const snapshot = await db.collection(COLLECTIONS.ACTIVITY_LOGS)
            .orderBy('timestamp', 'desc')
            .limit(100)
            .get();

        return snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data(),
            timestamp: safeDate(doc.data().timestamp)?.toISOString() || null
        }));
    } catch (error) {
        console.error("getRecentLogs Error:", error);
        return [];
    }
});

// --- Business Data Fetchers ---

export const getAllCustomers = cache(async function (): Promise<any[]> {
    try {
        const db = await getDb();
        // 'customers' is not in COLLECTIONS const yet, using string or add it later. 
        // Best to use the literal 'customers' as seen in FirestoreService.dart
        const snapshot = await db.collection('customers')
            .where('is_deleted', '==', 0) // Filter out deleted
            .orderBy('updated_at', 'desc')
            .limit(200)
            .get();

        return snapshot.docs.map(doc => {
            const data = doc.data();
            return {
                id: doc.id,
                name: data.name,
                phone: data.phone,
                email: data.email,
                address: data.address,
                city: data.city,
                deviceId: data.deviceId,
                updatedAt: safeDate(data.updated_at)?.toISOString() || null,
            };
        });
    } catch (error) {
        console.error("getAllCustomers Error:", error);
        return [];
    }
});

export const getAllMeasurements = cache(async function (): Promise<any[]> {
    try {
        const db = await getDb();
        const snapshot = await db.collection('windows')
            .where('is_deleted', '==', 0)
            .orderBy('updated_at', 'desc')
            .limit(200)
            .get();

        return snapshot.docs.map(doc => {
            const data = doc.data();
            return {
                id: doc.id,
                name: data.name,
                width: data.width,
                height: data.height,
                quantity: data.quantity,
                glassType: data.glass_type,
                customerId: data.customer_id,
                deviceId: data.deviceId,
                updatedAt: safeDate(data.updated_at)?.toISOString() || null,
            };
        });
    } catch (error) {
        console.error("getAllMeasurements Error:", error);
        return [];
    }
});

export const getAllEnquiries = cache(async function (): Promise<any[]> {
    try {
        const db = await getDb();
        const snapshot = await db.collection('enquiries')
            .where('is_deleted', '==', 0)
            .orderBy('date', 'desc')
            .limit(200)
            .get();

        return snapshot.docs.map(doc => {
            const data = doc.data();
            return {
                id: doc.id,
                customerName: data.customer_name,
                phone: data.phone,
                message: data.message,
                status: data.status,
                deviceId: data.deviceId,
                date: safeDate(data.date)?.toISOString() || null,
            };
        });
    } catch (error) {
        console.error("getAllEnquiries Error:", error);
        return [];
    }
});
