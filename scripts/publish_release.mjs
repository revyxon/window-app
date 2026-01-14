import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Helper for __dirname in ESM
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// --- CONFIGURATION ---
// Path relative to this script file
const APK_PATH = path.resolve(__dirname, '../measurement-app/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk');
const PUBSPEC_PATH = path.resolve(__dirname, '../measurement-app/pubspec.yaml');

// Environment Variables
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const GITHUB_REPO = process.env.GITHUB_REPO; // format: owner/repo

async function publishToGitHub() {
    console.log('🚀 Starting GitHub Release Automation...');

    if (!GITHUB_TOKEN || !GITHUB_REPO) {
        console.error('❌ Error: Missing GITHUB_TOKEN or GITHUB_REPO environment variables.');
        console.log('   Please set them before running the script.');
        console.log('   Example: $env:GITHUB_TOKEN="ghp_..."; $env:GITHUB_REPO="username/repo"; node scripts/publish_release.mjs');
        process.exit(1);
    }

    const [owner, repo] = GITHUB_REPO.split('/');

    // 0. Ensure Repo Exists
    console.log(`🔍 Checking if repo ${GITHUB_REPO} exists...`);
    const checkRepoRes = await fetch(`https://api.github.com/repos/${GITHUB_REPO}`, {
        headers: { 'Authorization': `Bearer ${GITHUB_TOKEN}` }
    });

    if (checkRepoRes.status === 404) {
        console.log(`⚠️ Repo not found. Creating ${GITHUB_REPO}...`);
        const createRepoRes = await fetch(`https://api.github.com/user/repos`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${GITHUB_TOKEN}`,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                name: repo,
                private: true, // Defaulting to private for safety
                description: 'Window Measurement App'
            })
        });

        if (!createRepoRes.ok) {
            const err = await createRepoRes.text();
            throw new Error(`Failed to create repo: ${createRepoRes.status} - ${err}`);
        }
        console.log('✅ Repository created successfully.');
    } else if (!checkRepoRes.ok) {
        const err = await checkRepoRes.text();
        throw new Error(`Failed to check repo: ${checkRepoRes.status} - ${err}`);
    } else {
        console.log('✅ Repository exists.');
    }

    // 1. Read Version
    if (!fs.existsSync(PUBSPEC_PATH)) {
        console.error(`❌ Error: pubspec.yaml not found at ${PUBSPEC_PATH}`);
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
    const tagName = `v${version}+${buildNumber}`;
    console.log(`📦 Version: ${version}, Build: ${buildNumber}`);
    console.log(`Ti Tag: ${tagName}`);

    try {
        // 2. Read APK (Lazy check inside try to allow build to finish if we were running sequentially, but here we expect it done)
        if (!fs.existsSync(APK_PATH)) {
            console.error(`❌ Error: APK file not found at ${APK_PATH}`);
            console.error('   Did you run: flutter build apk --release --target-platform android-arm64 --split-per-abi ?');
            process.exit(1);
        }
        const apkStats = fs.statSync(APK_PATH);
        const fileSize = apkStats.size;

        // 3. Create Release
        console.log(`📡 Creating Release ${tagName} on ${GITHUB_REPO}...`);

        const releaseNotes = `
# 🚀 Enquiry System Launch (v${version})

We are excited to introduce the comprehensive **Enquiry Management System**!

## ✨ New Features
*   **Enquiry Management**: Create, view, and manage customer enquiries directly in the app.
*   **Status Workflow**: Track leads through "Pending", "Converted", and "Dismissed" stages.
*   **Unified Navigation**: New bottom navigation bar for quick access to Home, Enquiries, Agreements, and Settings.
*   **Quick Actions**: New expandable Floating Action Button (FAB) for creating measurements and enquiries.
*   **Offline First**: Full offline support for enquiries with automatic cloud synchronization.

## 🛠 Improvements
*   Enhanced UI/UX with consistent styling across all screens.
*   Improved performance and stability.

_Built automatically by Antigravity_
`;

        const createReleaseRes = await fetch(`https://api.github.com/repos/${GITHUB_REPO}/releases`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${GITHUB_TOKEN}`,
                'Accept': 'application/vnd.github.v3+json',
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                tag_name: tagName,
                target_commitish: 'master',
                name: `v${version} - Enquiry System Launch`,
                body: releaseNotes.trim(),
                draft: false,
                prerelease: false,
                generate_release_notes: false
            })
        });

        let release;
        if (createReleaseRes.status === 422) {
            console.log('⚠️ Release already exists. Fetching existing release...');
            const getReleaseRes = await fetch(`https://api.github.com/repos/${GITHUB_REPO}/releases/tags/${tagName}`, {
                headers: { 'Authorization': `Bearer ${GITHUB_TOKEN}` }
            });
            if (!getReleaseRes.ok) throw new Error('Failed to get existing release');
            release = await getReleaseRes.json();
            console.log('✅ Found existing release.');
        } else if (!createReleaseRes.ok) {
            const err = await createReleaseRes.text();
            throw new Error(`Failed to create release: ${createReleaseRes.status} - ${err}`);
        } else {
            release = await createReleaseRes.json();
            console.log('✅ Release created successfully.');
        }

        // 4. Upload Asset
        console.log('📤 Uploading APK to Release...');
        // GitHub API upload URL template: .../assets{?name,label}
        const uploadUrl = release.upload_url.replace('{?name,label}', `?name=app-release.apk`);

        const apkBuffer = fs.readFileSync(APK_PATH);

        let downloadUrl;
        const uploadRes = await fetch(uploadUrl, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${GITHUB_TOKEN}`,
                'Content-Type': 'application/vnd.android.package-archive',
                'Content-Length': fileSize.toString()
            },
            body: apkBuffer
        });

        if (uploadRes.status === 422) {
            console.log('⚠️ Asset already uploaded. Using existing asset.');
            // Check if it's already in the release object
            const assets = release.assets || [];
            const existingAsset = assets.find(a => a.name === 'app-release.apk');

            if (existingAsset) {
                downloadUrl = existingAsset.browser_download_url;
            } else {
                // Re-fetch release info to get assets
                const getReleaseRes = await fetch(`https://api.github.com/repos/${GITHUB_REPO}/releases/tags/${tagName}`, {
                    headers: { 'Authorization': `Bearer ${GITHUB_TOKEN}` }
                });
                const r = await getReleaseRes.json();
                downloadUrl = r.assets.find(a => a.name === 'app-release.apk')?.browser_download_url;
            }
        } else if (!uploadRes.ok) {
            const err = await uploadRes.text();
            throw new Error(`Failed to upload asset: ${uploadRes.status} - ${err}`);
        } else {
            const asset = await uploadRes.json();
            console.log('✅ APK uploaded successfully.');
            downloadUrl = asset.browser_download_url;
        }

        if (!downloadUrl) throw new Error('Could not determine download URL');

        console.log('-----------------------------------');
        console.log(`🚀 Download URL: ${downloadUrl}`);
        console.log('-----------------------------------');

        // 5. Register with License Server
        console.log('📝 Registering update in database...');
        const BASE_URL = 'https://window-license-server.vercel.app';
        const API_KEY = '032007';

        const updateRes = await fetch(`${BASE_URL}/api/updates/upload`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-API-Key': API_KEY
            },
            body: JSON.stringify({
                version,
                buildNumber: parseInt(buildNumber),
                apkUrl: downloadUrl,
                fileSize,
                releaseNotes: releaseNotes.trim(),
                forceUpdate: false,
                skipAllowed: true
            })
        });

        const updateResult = await updateRes.json();
        if (!updateRes.ok) {
            throw new Error(`Failed to create update record: ${updateResult.message || 'Unknown error'}`);
        }

        console.log('\n✨ ALL DONE! Server updated. ✨');

    } catch (error) {
        console.error(`❌ FAILED: ${error.message}`);
        process.exit(1);
    }
}

publishToGitHub();
