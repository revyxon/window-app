'use server'

import { getDb, COLLECTIONS } from '@/lib/firebase-admin';
import { revalidatePath } from 'next/cache';

export async function forceDeviceCheck(deviceId: string) {
    try {
        const db = await getDb();
        await db.collection(COLLECTIONS.DEVICES).doc(deviceId).update({
            forceCheck: true
        });

        revalidatePath(`/admin/users`);
        revalidatePath(`/admin/users/${deviceId}`);
        return { success: true };
    } catch (error) {
        console.error('Force check error:', error);
        return { success: false, error: 'Failed to update' };
    }
}
