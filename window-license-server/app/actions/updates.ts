'use server'

import { getDb, COLLECTIONS } from '@/lib/firebase-admin';
import { revalidatePath } from 'next/cache';
import { FieldValue } from 'firebase-admin/firestore';

export interface CreateReleasePayload {
    version: string;
    buildNumber: number;
    apkUrl: string;
    fileSize: number;
    releaseNotes: string;
    forceUpdate: boolean;
}

export async function createRelease(data: CreateReleasePayload) {
    try {
        const db = await getDb();

        // Add new document to 'updates' collection
        await db.collection(COLLECTIONS.UPDATES).add({
            version: data.version,
            buildNumber: data.buildNumber,
            apkUrl: data.apkUrl,
            fileSize: data.fileSize,
            releaseNotes: data.releaseNotes,
            forceUpdate: data.forceUpdate,
            skipAllowed: !data.forceUpdate,
            createdAt: FieldValue.serverTimestamp(),
        });

        revalidatePath('/admin/updates');
        return { success: true };
    } catch (error) {
        console.error('Create Release Error:', error);
        return { success: false, error: 'Failed to create release record' };
    }
}
