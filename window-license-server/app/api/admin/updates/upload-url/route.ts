import { NextRequest } from 'next/server';
import { getStorageBucket } from '@/lib/firebase-admin';
import { isAdminAuthenticated, unauthorizedResponse, successResponse, errorResponse } from '@/lib/auth';
import { randomUUID } from 'crypto';

const CORS_HEADERS = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-API-Key',
};

export async function OPTIONS() {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
}

export const dynamic = 'force-dynamic';


// GET /api/admin/updates/upload-url - Generate signed URL for APK upload
export async function GET(request: NextRequest) {
    // Check admin authentication
    if (!isAdminAuthenticated(request)) {
        return unauthorizedResponse();
    }

    const { searchParams } = new URL(request.url);
    const fileName = searchParams.get('fileName');
    const contentType = searchParams.get('contentType') || 'application/vnd.android.package-archive';

    if (!fileName) {
        return errorResponse('fileName is required', 400);
    }

    try {
        // Get storage bucket directly
        const bucket = await getStorageBucket();

        // Generate secure file path with UUID
        const fileExtension = fileName.split('.').pop() || 'apk';
        const secureFileName = `updates/${randomUUID()}.${fileExtension}`;
        const file = bucket.file(secureFileName);

        // Generate a 15-minute signed URL for PUT upload
        const [uploadUrl] = await file.getSignedUrl({
            version: 'v4',
            action: 'write',
            expires: Date.now() + 15 * 60 * 1000, // 15 minutes
            contentType,
        });

        // Construct the public download URL
        const bucketName = bucket.name;
        const fileUrl = `https://storage.googleapis.com/${bucketName}/${secureFileName}`;

        console.log(`Generated upload URL for: ${secureFileName}`);

        return successResponse({
            success: true,
            uploadUrl: uploadUrl,
            fileUrl: fileUrl,
            filePath: secureFileName,
        });

    } catch (error: any) {
        console.error('Signed URL generation error:', error);

        // Provide helpful error message
        if (error.message?.includes('storage')) {
            return errorResponse('Firebase Storage not configured. Please check FIREBASE_STORAGE_BUCKET environment variable.', 500);
        }

        return errorResponse(`Failed to generate upload URL: ${error.message || error}`, 500);
    }
}
