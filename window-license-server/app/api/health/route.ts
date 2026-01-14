import { NextRequest, NextResponse } from 'next/server';
import { getDb, getStorage } from '@/lib/firebase-admin';

export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
    const status: any = {
        api: 'ok',
        timestamp: new Date().toISOString(),
        env: {
            hasServiceAccount: !!process.env.FIREBASE_SERVICE_ACCOUNT,
            hasStorageBucket: !!process.env.FIREBASE_STORAGE_BUCKET,
            storageBucket: process.env.FIREBASE_STORAGE_BUCKET || 'not-set',
        }
    };

    try {
        const db = await getDb();
        status.firestore = 'connected';

        // Storage Diagnosis
        try {
            const storage = await getStorage();
            const [buckets] = await storage.getBuckets();
            status.storage = {
                status: 'connected',
                buckets: buckets.map(b => b.name)
            };
        } catch (storageErr: any) {
            status.storage = {
                status: 'error',
                message: storageErr.message
            };
        }

    } catch (error: any) {
        status.firebase_init = 'error';
        status.error = error.message || error;
    }

    return NextResponse.json(status);
}
