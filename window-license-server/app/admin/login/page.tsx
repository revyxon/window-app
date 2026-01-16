'use client';
import * as React from 'react';
import Box from '@mui/material/Box';
import Paper from '@mui/material/Paper';
import Typography from '@mui/material/Typography';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import Alert from '@mui/material/Alert';
import InputAdornment from '@mui/material/InputAdornment';
import IconButton from '@mui/material/IconButton';
import CircularProgress from '@mui/material/CircularProgress';

// Icons
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';
import LockOutlinedIcon from '@mui/icons-material/LockOutlined';

import { useRouter } from 'next/navigation';
import { login } from '@/app/actions/auth';

export default function LoginPage() {
    const router = useRouter();
    const [password, setPassword] = React.useState('');
    const [showPassword, setShowPassword] = React.useState(false);
    const [error, setError] = React.useState('');
    const [loading, setLoading] = React.useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError('');

        try {
            const result = await login(password);
            if (result.success) {
                // Force hard refresh to ensure middleware picks up the cookie
                window.location.href = '/admin';
            } else {
                setError(result.error || 'Login failed');
                setLoading(false);
            }
        } catch (e) {
            setError('An unexpected error occurred');
            setLoading(false);
        }
    };

    return (
        <Box
            sx={{
                minHeight: '100vh',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                bgcolor: '#f1f5f9'
            }}
        >
            <Paper
                elevation={1}
                sx={{
                    p: 4,
                    width: '100%',
                    maxWidth: 400,
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    borderRadius: 2
                }}
            >
                <Box sx={{ p: 2, bgcolor: 'primary.main', borderRadius: '50%', color: 'white', mb: 2 }}>
                    <LockOutlinedIcon sx={{ fontSize: 32 }} />
                </Box>

                <Typography variant="h5" fontWeight={700} gutterBottom>
                    Admin Login
                </Typography>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 4 }}>
                    Sign in to access the license server
                </Typography>

                <Box component="form" onSubmit={handleSubmit} sx={{ width: '100%' }}>
                    {error && (
                        <Alert severity="error" sx={{ mb: 3 }}>
                            {error}
                        </Alert>
                    )}

                    <TextField
                        fullWidth
                        label="Password"
                        type={showPassword ? 'text' : 'password'}
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        disabled={loading}
                        sx={{ mb: 3 }}
                        InputProps={{
                            endAdornment: (
                                <InputAdornment position="end">
                                    <IconButton
                                        onClick={() => setShowPassword(!showPassword)}
                                        edge="end"
                                    >
                                        {showPassword ? <VisibilityOff /> : <Visibility />}
                                    </IconButton>
                                </InputAdornment>
                            ),
                        }}
                    />

                    <Button
                        type="submit"
                        fullWidth
                        variant="contained"
                        size="large"
                        disabled={loading}
                        sx={{ height: 48, fontWeight: 700 }}
                    >
                        {loading ? <CircularProgress size={24} color="inherit" /> : 'Sign In'}
                    </Button>
                </Box>
            </Paper>
        </Box>
    );
}
