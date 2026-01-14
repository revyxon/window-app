import admin from 'firebase-admin';

async function testStorage() {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });

    const storage = admin.storage();
    try {
        console.log('--- STORAGE BUCKETS ---');
        const [buckets] = await storage.getBuckets();
        buckets.forEach(b => console.log(`- ${b.name}`));

        if (buckets.length === 0) {
            console.log('⚠️ No buckets found. Please create a bucket in Firebase Console.');
        }
    } catch (e) {
        console.error('❌ Error listing buckets:', e.message);
    }
}

testStorage();
