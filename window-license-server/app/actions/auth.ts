'use server'

import { cookies } from 'next/headers'
import { redirect } from 'next/navigation'

export async function login(prevState: any, formData: FormData) {
    const password = formData.get('password') as string
    const adminPassword = process.env.ADMIN_PASSWORD || 'admin' // Fallback for dev

    if (password === adminPassword) {
        cookies().set('admin_session', 'authenticated', {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            maxAge: 60 * 60 * 24 * 7, // 1 week
            path: '/',
        })
        return { success: true }
    } else {
        return { success: false, message: 'Invalid password' }
    }
}

export async function logout() {
    cookies().delete('admin_session')
    redirect('/admin/login')
}
