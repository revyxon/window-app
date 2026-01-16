import { getDashboardStats } from '@/lib/data';
import Grid from '@mui/material/Grid';
import Paper from '@mui/material/Paper';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';

// Icons
import GroupIcon from '@mui/icons-material/Group';
import SecurityIcon from '@mui/icons-material/Security';
import SystemUpdateAltIcon from '@mui/icons-material/SystemUpdateAlt';
import AccessTimeIcon from '@mui/icons-material/AccessTime';
import ArrowForwardIcon from '@mui/icons-material/ArrowForward';
import Link from 'next/link';

export const dynamic = 'force-dynamic';

function StatCard({ title, value, icon, color, href }: { title: string, value: string | number, icon: React.ReactNode, color: string, href?: string }) {
    return (
        <Paper sx={{ p: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', height: '100%' }}>
            <Box>
                <Typography variant="overline" display="block" color="text.secondary" fontWeight={600} gutterBottom>
                    {title}
                </Typography>
                <Typography variant="h3" fontWeight={700} color="text.primary">
                    {value}
                </Typography>
                {href && (
                    <Button
                        component={Link}
                        href={href}
                        endIcon={<ArrowForwardIcon />}
                        sx={{ mt: 2, p: 0, '&:hover': { bgcolor: 'transparent', textDecoration: 'underline' } }}
                    >
                        View Details
                    </Button>
                )}
            </Box>
            <Box sx={{
                bgcolor: `${color}15`,
                color: color,
                p: 1.5,
                borderRadius: 2,
                display: 'flex'
            }}>
                {icon}
            </Box>
        </Paper>
    );
}

export default async function DashboardPage() {
    const stats = await getDashboardStats();

    return (
        <Box>
            <Box sx={{ mb: 4 }}>
                <Typography variant="h4" fontWeight={700} gutterBottom>
                    Overview
                </Typography>
                <Typography color="text.secondary">
                    Welcome back. Here is what's happening with your licenses today.
                </Typography>
            </Box>

            <Grid container spacing={3}>
                <Grid item xs={12} sm={6} md={3}>
                    <StatCard
                        title="Total Devices"
                        value={stats.totalDevices}
                        icon={<GroupIcon sx={{ fontSize: 32 }} />}
                        color="#2563eb"
                        href="/admin/users"
                    />
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                    <StatCard
                        title="Active Sessions"
                        value={stats.activeSessions}
                        icon={<AccessTimeIcon sx={{ fontSize: 32 }} />}
                        color="#16a34a"
                    />
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                    <StatCard
                        title="Locked Devices"
                        value={stats.lockedDevices}
                        icon={<SecurityIcon sx={{ fontSize: 32 }} />}
                        color="#dc2626"
                        href="/admin/users"
                    />
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                    <StatCard
                        title="Total Updates"
                        value={stats.totalUpdates}
                        icon={<SystemUpdateAltIcon sx={{ fontSize: 32 }} />}
                        color="#7c3aed"
                        href="/admin/updates"
                    />
                </Grid>
            </Grid>

            {/* Version Distribution Placeholder */}
            <Box sx={{ mt: 4 }}>
                <Paper sx={{ p: 3 }}>
                    <Typography variant="h6" fontWeight={600} gutterBottom>
                        Version Distribution
                    </Typography>
                    <Grid container spacing={2}>
                        {Object.entries(stats.versionDistribution).map(([version, count]) => (
                            <Grid item key={version}>
                                <Box sx={{ border: '1px solid #e2e8f0', borderRadius: 2, p: 2, minWidth: 120 }}>
                                    <Typography variant="subtitle2" color="text.secondary">v{version}</Typography>
                                    <Typography variant="h5" fontWeight={700}>{count}</Typography>
                                </Box>
                            </Grid>
                        ))}
                    </Grid>
                </Paper>
            </Box>
        </Box>
    );
}
