'use server'

import { cookies } from 'next/headers';

export async function login(password: string) {
    const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'admin';

    if (password === ADMIN_PASSWORD) {
        cookies().set('admin_session', 'true', {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'strict',
            maxAge: 60 * 60 * 24 * 7, // 1 week
            path: '/',
        });
        return { success: true };
    }

    return { success: false, error: 'Invalid password' };
}

export async function logout() {
    cookies().delete('admin_session');
    return { success: true };
}
