const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

try {
    console.log('📦 Reading config...');
    const pubspec = fs.readFileSync('pubspec.yaml', 'utf8');
    const versionMatch = pubspec.match(/version: (.+)/);
    if (!versionMatch) throw new Error('Could not find version in pubspec.yaml');
    const version = versionMatch[1].trim();
    const tagName = `v${version}`;

    console.log(`🚀 Preparing Release ${tagName}`);

    // 2. Build APK
    console.log('🛠 Building APK (this may take a minute)...');
    execSync('flutter build apk --release', { stdio: 'inherit' });

    const apkPath = path.join('build', 'app', 'outputs', 'flutter-apk', 'app-release.apk');
    if (!fs.existsSync(apkPath)) throw new Error(`APK not found at ${apkPath}`);

    // 3. Git Operations
    console.log('git: Committing changes...');
    execSync('git add .', { stdio: 'inherit' });
    try {
        execSync(`git commit -m "chore: release ${tagName} - Dark Mode Overhaul"`, { stdio: 'inherit' });
    } catch (e) {
        console.log('ℹ️ Nothing to commit or commit failed. Continuing...');
    }

    console.log('🏷 Tagging...');
    try {
        // Delete tag if exists locally to avoid conflict (optional, but unsafe if remote exists)
        // execSync(`git tag -d ${tagName}`, { stdio: 'ignore' }); 
        execSync(`git tag ${tagName}`, { stdio: 'inherit' });
    } catch (e) {
        console.log(`⚠️ Tag ${tagName} might already exist locally.`);
    }

    console.log('⬆️ Pushing to remote...');
    try {
        execSync(`git push origin ${tagName}`, { stdio: 'inherit' });
        execSync('git push origin HEAD', { stdio: 'inherit' });
    } catch (e) {
        console.log('❌ Git Push failed. Please push manually.');
        // Don't stop, maybe we can still release if tag matches? 
        // Actually if push fails, GH release create will fail if tag isn't on remote? 
        // GH CLI creates tag if not exists.
    }

    // 4. Create GitHub Release
    console.log('🌐 Creating GitHub Release...');
    try {
        execSync('gh --version', { stdio: 'ignore' });
        // Use --verify-tag to ensure strictness? No.
        execSync(`gh release create ${tagName} "${apkPath}" -F RELEASE_NOTES.md -t "Measurement App ${tagName}"`, { stdio: 'inherit' });
        console.log('✅ Release Published Successfully!');
    } catch (e) {
        console.error('⚠️ GitHub CLI (gh) failed or not installed.');
        console.log('---------------------------------------------------');
        console.log('MANUAL STEPS REQUIRED:');
        console.log(`1. Go to https://github.com/revyxon/window-app/releases/new`);
        console.log(`2. Tag version: ${tagName}`);
        console.log(`3. Release title: Measurement App ${tagName}`);
        console.log(`4. Copy content from RELEASE_NOTES.md`);
        console.log(`5. Upload APK from: ${path.resolve(apkPath)}`);
        console.log('---------------------------------------------------');
    }

} catch (e) {
    console.error('❌ Script Failed:', e.message);
    process.exit(1);
}
