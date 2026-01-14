import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';

// --- CONFIGURATION ---
// These will be prompted or read from env
const APK_PATH = path.resolve('measurement-app/build/app/outputs/flutter-apk/app-release.apk');
const PUBSPEC_PATH = path.resolve('measurement-app/pubspec.yaml');

// Helper to ask questions (since we run in non-interactive mostly, we'll expect ENV or args, 
// but for this "login" flow, we'll simulate it by checking ENV)

const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const GITHUB_REPO = process.env.GITHUB_REPO; // format: owner/repo

async function publishToGitHub() {
    console.log('🚀 Starting GitHub Release Automation...');

    if (!GITHUB_TOKEN || !GITHUB_REPO) {
        console.error('❌ Error: Missing GITHUB_TOKEN or GITHUB_REPO environment variables.');
        console.log('   Please set them before running the script.');
        console.log('   Example: $env:GITHUB_TOKEN="ghp_..."; $env:GITHUB_REPO="username/repo"; node publish_github.mjs');
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
    const tagName = `v${version}+${buildNumber}`;
    console.log(`📦 Version: ${version}, Build: ${buildNumber}`);
    console.log(`Ti Tag: ${tagName}`);

    // 2. Read APK
    if (!fs.existsSync(APK_PATH)) {
        console.error('❌ Error: APK file not found!');
        process.exit(1);
    }
    const apkStats = fs.statSync(APK_PATH);
    const fileSize = apkStats.size;

    try {
        // 3. Create Release
        console.log(`📡 Creating Release ${tagName} on ${GITHUB_REPO}...`);

        const createReleaseRes = await fetch(`https://api.github.com/repos/${GITHUB_REPO}/releases`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${GITHUB_TOKEN}`,
                'Accept': 'application/vnd.github.v3+json',
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                tag_name: tagName,
                target_commitish: 'master', // or main
                name: `v${version} Build ${buildNumber}`,
                body: `Automated release for version ${version} build ${buildNumber}.`,
                draft: false,
                prerelease: false,
                generate_release_notes: true
            })
        });

        if (!createReleaseRes.ok) {
            const err = await createReleaseRes.text();
            throw new Error(`Failed to create release: ${createReleaseRes.status} - ${err}`);
        }

        const release = await createReleaseRes.json();
        console.log('✅ Release created successfully.');

        // 4. Upload Asset
        console.log('📤 Uploading APK to Release...');
        const uploadUrl = release.upload_url.replace('{?name,label}', `?name=app-release.apk`);

        const apkBuffer = fs.readFileSync(APK_PATH);

        const uploadRes = await fetch(uploadUrl, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${GITHUB_TOKEN}`,
                'Content-Type': 'application/vnd.android.package-archive',
                'Content-Length': fileSize.toString()
            },
            body: apkBuffer
        });

        if (!uploadRes.ok) {
            const err = await uploadRes.text();
            throw new Error(`Failed to upload asset: ${uploadRes.status} - ${err}`);
        }

        const asset = await uploadRes.json();
        console.log('✅ APK uploaded successfully.');

        console.log('-----------------------------------');
        console.log(`🚀 Download URL: ${asset.browser_download_url}`);
        console.log('-----------------------------------');

    } catch (error) {
        console.error(`❌ FAILED: ${error.message}`);
        process.exit(1);
    }
}

publishToGitHub();
