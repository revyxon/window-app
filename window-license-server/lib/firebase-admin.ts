let firebaseApp: any = null;

// Initialize Firebase Admin SDK (lazy init)
// Expects FIREBASE_SERVICE_ACCOUNT environment variable with JSON credentials
async function initFirebase() {
    if (firebaseApp) {
        return firebaseApp;
    }

    // Dynamic import to prevent build-time issues
    const admin = (await import('firebase-admin')).default;

    if (admin.apps.length > 0) {
        firebaseApp = admin.apps[0];
        return firebaseApp;
    }

    const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT;

    if (!serviceAccount) {
        // In build environment, we might not have the key, so just warn but ensure we don't crash
        // unless we are actually trying to use it.
        if (process.env.NODE_ENV === 'production') {
            throw new Error('FIREBASE_SERVICE_ACCOUNT environment variable is not set.');
        }
        return null;
    }

    try {
        const credentials = JSON.parse(serviceAccount);

        // Get storage bucket from env or use default based on project
        const storageBucket = process.env.FIREBASE_STORAGE_BUCKET || 'ddupvc.appspot.com';

        firebaseApp = admin.initializeApp({
            credential: admin.credential.cert(credentials),
            storageBucket: storageBucket,
        });

        console.log(`Firebase initialized with storage bucket: ${storageBucket}`);
        return firebaseApp;
    } catch (error) {
        throw new Error(`Failed to parse FIREBASE_SERVICE_ACCOUNT: ${error}`);
    }
}

// Get Firestore instance (throws if not configured)
export async function getDb() {
    await initFirebase();
    const admin = (await import('firebase-admin')).default;
    return admin.firestore();
}

// Get Storage instance with proper bucket
export async function getStorage() {
    await initFirebase();
    const admin = (await import('firebase-admin')).default;
    return admin.storage();
}

// Get Storage Bucket directly (preferred method)
export async function getStorageBucket() {
    await initFirebase();
    const admin = (await import('firebase-admin')).default;
    const bucketName = process.env.FIREBASE_STORAGE_BUCKET;
    if (bucketName) {
        return admin.storage().bucket(bucketName);
    }
    // Falls back to the default bucket configured in initializeApp
    // or auto-detected from service account
    return admin.storage().bucket();
}

// Collection names
export const COLLECTIONS = {
    DEVICES: 'devices',
    CUSTOMERS: 'customers',
    WINDOWS: 'windows',
    ACTIVITY_LOGS: 'activity_logs',
    UPDATES: 'updates',
};

// Device status constants
export const DEVICE_STATUS = {
    ACTIVE: 'active',
    LOCKED: 'locked',
    EXPIRED: 'expired',
};
