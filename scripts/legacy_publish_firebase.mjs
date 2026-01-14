import fs from 'fs';
import path from 'path';

// --- CONFIGURATION ---
const BASE_URL = 'https://window-license-server.vercel.app';
const API_KEY = '032007'; // Hardcoded as per project settings
const APK_PATH = path.resolve('measurement-app/build/app/outputs/flutter-apk/app-release.apk');
const PUBSPEC_PATH = path.resolve('measurement-app/pubspec.yaml');

async function publish() {
    console.log('🚀 Starting Automated APK Publish...');

    // 1. Read Version from pubspec.yaml
    if (!fs.existsSync(PUBSPEC_PATH)) {
        console.error('❌ Error: pubspec.yaml not found!');
        process.exit(1);
    }
    const pubspec = fs.readFileSync(PUBSPEC_PATH, 'utf8');
    const versionMatch = pubspec.match(/^version:\s*([\d.]+)\+(\d+)/m);
    if (!versionMatch) {
        console.error('❌ Error: Could not find version in pubspec.yaml');
        process.exit(1);
    }
    const version = versionMatch[1];
    const buildNumber = versionMatch[2];
    console.log(`📦 Version: ${version}, Build: ${buildNumber}`);

    // 2. Read APK File
    if (!fs.existsSync(APK_PATH)) {
        console.error('❌ Error: APK file not found! Run "flutter build apk --release" first.');
        process.exit(1);
    }
    const apkBuffer = fs.readFileSync(APK_PATH);
    const fileSize = apkBuffer.length;
    console.log(`📎 APK File Size: ${(fileSize / (1024 * 1024)).toFixed(2)} MB`);

    try {
        // 3. Get Signed Upload URL
        console.log('📡 Requesting signed upload URL...');
        const urlRes = await fetch(`${BASE_URL}/api/admin/updates/upload-url?fileName=app-v${version}-b${buildNumber}.apk`, {
            headers: { 'X-API-Key': API_KEY }
        });

        if (!urlRes.ok) {
            const errBody = await urlRes.text();
            throw new Error(`Failed to get upload URL: ${urlRes.status} - ${errBody}`);
        }

        const { uploadUrl, fileUrl, filePath } = await urlRes.json();
        console.log('✅ Signed URL received.');

        // 4. Upload to Google Cloud Storage
        console.log('📤 Uploading APK to storage... (this may take a minute)');
        const uploadRes = await fetch(uploadUrl, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/vnd.android.package-archive',
                'Content-Length': fileSize.toString()
            },
            body: apkBuffer
        });

        if (!uploadRes.ok) {
            const errBody = await uploadRes.text();
            throw new Error(`Upload failed with status ${uploadRes.status}: ${errBody}`);
        }
        console.log('✅ APK uploaded successfully.');

        // 5. Create Update Record in Firestore
        console.log('📝 Registering update in database...');
        const updateRes = await fetch(`${BASE_URL}/api/updates/upload`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-API-Key': API_KEY
            },
            body: JSON.stringify({
                version,
                buildNumber: parseInt(buildNumber),
                apkUrl: fileUrl,
                fileSize,
                releaseNotes: `Automated release v${version} build ${buildNumber}.\nSee RELEASE_NOTES.md for details.`,
                forceUpdate: false,
                skipAllowed: true
            })
        });

        const updateResult = await updateRes.json();
        if (!updateRes.ok) {
            throw new Error(`Failed to create update record: ${updateResult.message || 'Unknown error'}`);
        }

        console.log('\n✨ ALL DONE! ✨');
        console.log('-----------------------------------');
        console.log(`🚀 Update Published: v${version}+${buildNumber}`);
        console.log(`🔗 APK URL: ${fileUrl}`);
        console.log('-----------------------------------');

    } catch (error) {
        console.error(`\n❌ FAILED: ${error.message}`);
        process.exit(1);
    }
}

publish();
