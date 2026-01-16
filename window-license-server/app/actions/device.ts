'use server'

import { getDb, COLLECTIONS } from '@/lib/firebase-admin';
import { revalidatePath } from 'next/cache';

export async function toggleDeviceLock(deviceId: string, currentStatus: string) {
    try {
        const db = await getDb();
        const newStatus = currentStatus === 'locked' ? 'active' : 'locked';

        await db.collection(COLLECTIONS.DEVICES).doc(deviceId).update({
            status: newStatus,
            lockReason: newStatus === 'locked' ? 'Admin manual lock' : null
        });

        // Use revalidating to refresh data
        revalidatePath(`/admin/users/${deviceId}`);
        return { success: true, status: newStatus };
    } catch (error) {
        console.error('Toggle lock error:', error);
        return { success: false, error: 'Failed to update status' };
    }
}
