import { LoginForm } from "./login-form"

export default function LoginPage() {
    return (
        <div className="flex min-h-screen items-center justify-center bg-muted/40 p-4">
            <div className="w-full max-w-sm space-y-4">
                <div className="text-center space-y-2">
                    <h1 className="text-2xl font-semibold tracking-tight">Admin Login</h1>
                    <p className="text-sm text-muted-foreground">Enter your admin password to continue</p>
                </div>
                <LoginForm />
            </div>
        </div>
    )
}
