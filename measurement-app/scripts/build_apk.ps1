$ErrorActionPreference = "Stop"

Write-Host "Starting Deep Clean & Build Process..." -ForegroundColor Cyan

# 1. Clean native Gradle cache (fixes 'finalized' property errors)
$gradleCache = "android\.gradle"
if (Test-Path $gradleCache) {
    Write-Host "Removing android\.gradle cache..."
    Remove-Item -Path $gradleCache -Recurse -Force -ErrorAction SilentlyContinue
}

# 2. Flutter Clean
Write-Host "Running flutter clean..."
flutter clean

# 3. Build APK
Write-Host "Building Release APK (arm64-v8a)..."
flutter build apk --release --target-platform android-arm64 --verbose

if ($LASTEXITCODE -eq 0) {
    Write-Host "--------------------------------------------------" -ForegroundColor Green
    Write-Host "BUILD SUCCESS!" -ForegroundColor Green
    Write-Host "APK Location: build\app\outputs\apk\release\app-release.apk" -ForegroundColor Green
    Write-Host "--------------------------------------------------" -ForegroundColor Green
} else {
    Write-Host "--------------------------------------------------" -ForegroundColor Red
    Write-Host "BUILD FAILED" -ForegroundColor Red
    Write-Host "Please check the logs above." -ForegroundColor Red
    exit 1
}
