'use client'

import { useFormState, useFormStatus } from 'react-dom'
import { login } from '@/app/actions/auth'
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Card, CardContent, CardHeader, CardTitle, CardFooter } from "@/components/ui/card"
import { Lock } from 'lucide-react'
import { useEffect } from 'react'
import { useRouter } from 'next/navigation'

const initialState = {
    success: false,
    message: '',
}

function SubmitButton() {
    const { pending } = useFormStatus()
    return (
        <Button className="w-full" type="submit" disabled={pending}>
            {pending ? "Authenticating..." : "Login"}
        </Button>
    )
}

export function LoginForm() {
    const [state, formAction] = useFormState(login, initialState)
    const router = useRouter()

    useEffect(() => {
        if (state.success) {
            router.push('/admin/dashboard')
        }
    }, [state.success, router])

    return (
        <Card>
            <form action={formAction}>
                <CardHeader>
                    <CardTitle>Authentication</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                    <div className="space-y-2">
                        <Label htmlFor="password">Password</Label>
                        <div className="relative">
                            <Lock className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                            <Input
                                id="password"
                                name="password"
                                type="password"
                                placeholder="••••••••"
                                className="pl-9"
                                required
                            />
                        </div>
                    </div>
                    {state.message && (
                        <p className="text-sm text-destructive font-medium text-center">{state.message}</p>
                    )}
                </CardContent>
                <CardFooter>
                    <SubmitButton />
                </CardFooter>
            </form>
        </Card>
    )
}
