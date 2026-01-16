import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Paper from '@mui/material/Paper';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import Divider from '@mui/material/Divider';
import Switch from '@mui/material/Switch';
import FormControlLabel from '@mui/material/FormControlLabel';

export default function SettingsPage() {
    return (
        <Box maxWidth="md">
            <Box sx={{ mb: 4 }}>
                <Typography variant="h4" fontWeight={700}>Settings</Typography>
                <Typography color="text.secondary">System configuration and preferences.</Typography>
            </Box>

            <Paper sx={{ p: 4, mb: 4 }}>
                <Typography variant="h6" gutterBottom>Security</Typography>
                <Divider sx={{ mb: 3 }} />

                <Box component="form" sx={{ display: 'flex', flexDirection: 'column', gap: 2, maxWidth: 400 }}>
                    <TextField label="Current Admin Password" type="password" size="small" />
                    <TextField label="New Password" type="password" size="small" />
                    <TextField label="Confirm New Password" type="password" size="small" />
                    <Button variant="contained" sx={{ alignSelf: 'flex-start', mt: 1 }}>
                        Update Password
                    </Button>
                </Box>
            </Paper>

            <Paper sx={{ p: 4 }}>
                <Typography variant="h6" gutterBottom>System Policy</Typography>
                <Divider sx={{ mb: 3 }} />

                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                    <FormControlLabel
                        control={<Switch defaultChecked />}
                        label="Allow Offline Grace Period (7 Days)"
                    />
                    <FormControlLabel
                        control={<Switch defaultChecked />}
                        label="Auto-clean Activity Logs > 30 Days"
                    />
                    <FormControlLabel
                        control={<Switch />}
                        label="Maintenance Mode (Blocks all new sessions)"
                    />
                </Box>
            </Paper>
        </Box>
    );
}
