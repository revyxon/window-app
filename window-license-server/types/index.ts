// Device types
export interface Device {
    deviceId: string;
    status: 'active' | 'locked' | 'expired';
    licenseExpiry?: string;
    registeredAt: string;
    lastActiveAt: string;
    appVersion?: string;
    updateSkipCount?: number;
    lastSkippedVersion?: string;
}

// License check response
export interface LicenseResponse {
    isValid: boolean;
    status: string;
    message?: string;
    expiresAt?: string;
}

// Activity log entry
export interface ActivityLog {
    id: string;
    deviceId: string;
    actionName: string;
    page: string;
    context?: string;
    timestamp: string;
}

// Customer
export interface Customer {
    id: string;
    deviceId: string;
    name: string;
    location: string;
    phone?: string;
    framework: string;
    glassType?: string;
    ratePerSqft?: number;
    isFinalMeasurement: boolean;
    createdAt: string;
    updatedAt?: string;
    isDeleted: boolean;
}

// Window
export interface Window {
    id: string;
    deviceId: string;
    customerId: string;
    name: string;
    width: number;
    height: number;
    type: string;
    width2?: number;
    formula?: string;
    customName?: string;
    quantity: number;
    isOnHold: boolean;
    notes?: string;
    createdAt: string;
    updatedAt?: string;
    isDeleted: boolean;
}

// App update
export interface AppUpdate {
    version: string;
    buildNumber: number;
    apkUrl: string;
    fileSize: number;
    releaseNotes?: string;
    forceUpdate: boolean;
    skipAllowed: boolean;
    createdAt: string;
}

// Admin analytics
export interface Analytics {
    totalDevices: number;
    activeToday: number;
    totalCustomers: number;
    totalWindows: number;
    recentActivity: ActivityLog[];
}
