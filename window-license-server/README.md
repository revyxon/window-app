# Window License Server

License and update management server for the Window Measurement App.

## Deployment

Deploy to Vercel:

1. Push this folder to a Git repository
2. Import to Vercel
3. Set environment variables (see below)
4. Deploy

## Environment Variables

Set these in Vercel project settings:

- `FIREBASE_SERVICE_ACCOUNT`: JSON string of Firebase Admin SDK service account credentials
- `ADMIN_API_KEY`: Secret API key for admin endpoints (used in Authorization header)

### Getting Firebase Service Account

1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Copy the entire JSON content
4. Paste as the value of `FIREBASE_SERVICE_ACCOUNT` (as a single line)

## API Endpoints

### Device Endpoints (Public)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/devices/register` | POST | Register a device |
| `/api/devices/[deviceId]/license` | GET | Check license status |
| `/api/devices/[deviceId]/activity` | POST | Push activity logs |

### Update Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/updates/latest` | GET | Get latest version info (public) |
| `/api/updates/upload` | POST | Create new update (admin) |
| `/api/updates/upload` | GET | List all updates (admin) |

### Admin Endpoints (Requires API Key)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/admin/users` | GET | List all devices |
| `/api/admin/users/[deviceId]` | GET | Get device details |
| `/api/admin/users/[deviceId]` | PATCH | Lock/unlock device |
| `/api/admin/analytics` | GET | Get dashboard analytics |

### Authentication

Admin endpoints require `Authorization: Bearer YOUR_API_KEY` header.

### Example: Lock a Device

```bash
curl -X PATCH https://your-domain.vercel.app/api/admin/users/DEVICE_ID \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"status": "locked"}'
```

### Example: Create an Update

```bash
curl -X POST https://your-domain.vercel.app/api/updates/upload \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "version": "1.1.0",
    "buildNumber": 2,
    "apkUrl": "https://storage.example.com/app-v1.1.0.apk",
    "releaseNotes": "Bug fixes and improvements",
    "mandatory": false
  }'
```

## Local Development

```bash
npm install
npm run dev
```

Create `.env.local` file with:
```
FIREBASE_SERVICE_ACCOUNT={"type":"service_account",...}
ADMIN_API_KEY=your-secret-key
```
