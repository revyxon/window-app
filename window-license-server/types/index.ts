export interface Device {
    deviceId: string;
    status: 'active' | 'locked' | 'expired' | 'unregistered';
    registeredAt: string | null;
    lastActiveAt: string | null;
    appVersion: string | null;
    licenseExpiry: string | null;
    deviceInfo?: Record<string, any>;
    lockReason?: string;
    // New fields for Unified Overhaul
    forceCheck?: boolean;
    lastValidCheck?: string | null;
    graceStatus?: 'active' | 'grace_period' | 'expired';
}

export interface UpdateRelease {
    id: string;
    version: string;
    buildNumber: number;
    apkUrl: string;
    fileSize: number;
    releaseNotes: string | null;
    forceUpdate: boolean;
    skipAllowed: boolean;
    createdAt: string | null;
}

export interface LicenseResponse {
    isValid: boolean;
    status: string;
    message?: string;
    expiresAt?: string | null;
}

export interface Customer {
    id: string;
    name: string;
    phone: string;
    email?: string;
    address?: string;
    city?: string;
    deviceId: string;
    updatedAt: string | null;
    isDeleted?: boolean;
}

export interface Measurement {
    id: string;
    name: string;
    width: number;
    height: number;
    quantity: number;
    glassType?: string;
    customerId: string;
    deviceId: string;
    updatedAt: string | null;
    isDeleted?: boolean;
}

export interface Enquiry {
    id: string;
    customerName: string;
    phone: string;
    message: string;
    status: string;
    deviceId: string;
    date: string | null;
    isDeleted?: boolean;
}
