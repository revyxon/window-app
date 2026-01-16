'use client';
import * as React from 'react';
import Box from '@mui/material/Box';
import Paper from '@mui/material/Paper';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';
import Grid from '@mui/material/Grid';
import FormControlLabel from '@mui/material/FormControlLabel';
import Checkbox from '@mui/material/Checkbox';
import LinearProgress from '@mui/material/LinearProgress';
import Alert from '@mui/material/Alert';
import Stack from '@mui/material/Stack';
import Chip from '@mui/material/Chip';
import Divider from '@mui/material/Divider';

// Icons
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import SaveIcon from '@mui/icons-material/Save';

// Actions & Data
import { createRelease } from '@/app/actions/updates';

interface UpdatesClientProps {
    initialUpdates: any[];
}

export default function UpdatesClient({ initialUpdates }: UpdatesClientProps) {
    // Form State
    const [version, setVersion] = React.useState('');
    const [buildNumber, setBuildNumber] = React.useState('');
    const [notes, setNotes] = React.useState('');
    const [forceUpdate, setForceUpdate] = React.useState(false);
    const [file, setFile] = React.useState<File | null>(null);

    // Upload State
    const [uploading, setUploading] = React.useState(false);
    const [progress, setProgress] = React.useState(0); // Fake progress for better UX
    const [status, setStatus] = React.useState<{ type: 'success' | 'error' | null, msg: string }>({ type: null, msg: '' });

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files && e.target.files[0]) {
            setFile(e.target.files[0]);
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!file || !version || !buildNumber) {
            setStatus({ type: 'error', msg: 'Please fill all fields and select a file.' });
            return;
        }

        setUploading(true);
        setStatus({ type: null, msg: '' });

        try {
            // 1. Get Signed URL
            const res = await fetch(`/api/admin/updates/upload-url?fileName=${file.name}&contentType=${file.type}`);
            if (!res.ok) throw new Error('Failed to get upload URL');
            const { uploadUrl, fileUrl } = await res.json();

            // 2. Upload File (XHR for progress if needed, but fetch is simpler)
            // Simulated progress
            const interval = setInterval(() => {
                setProgress(prev => {
                    if (prev >= 90) return prev;
                    return prev + 10;
                });
            }, 500);

            await fetch(uploadUrl, {
                method: 'PUT',
                body: file,
                headers: { 'Content-Type': file.type },
            });

            clearInterval(interval);
            setProgress(100);

            // 3. Create Record
            const result = await createRelease({
                version,
                buildNumber: parseInt(buildNumber),
                apkUrl: fileUrl,
                fileSize: file.size,
                releaseNotes: notes,
                forceUpdate,
            });

            if (result.success) {
                setStatus({ type: 'success', msg: 'Version published successfully!' });
                // Reset form
                setVersion('');
                setBuildNumber('');
                setNotes('');
                setFile(null);
                setForceUpdate(false);
            } else {
                throw new Error(result.error);
            }

        } catch (error: any) {
            setStatus({ type: 'error', msg: error.message || 'Upload failed' });
        } finally {
            setUploading(false);
            setProgress(0);
        }
    };

    return (
        <Grid container spacing={4}>
            {/* Upload Form */}
            <Grid item xs={12} md={5}>
                <Paper sx={{ p: 4 }}>
                    <Typography variant="h6" gutterBottom fontWeight={600}>Publish New Version</Typography>
                    <Box component="form" onSubmit={handleSubmit} sx={{ display: 'flex', flexDirection: 'column', gap: 3, mt: 2 }}>

                        <Button
                            component="label"
                            variant="outlined"
                            startIcon={<CloudUploadIcon />}
                            sx={{ height: 60, textTransform: 'none', borderStyle: 'dashed' }}
                        >
                            {file ? file.name : 'Select APK File'}
                            <input type="file" accept=".apk" hidden onChange={handleFileChange} />
                        </Button>

                        <Stack direction="row" spacing={2}>
                            <TextField
                                label="Version (e.g. 1.0.4)"
                                fullWidth
                                size="small"
                                value={version}
                                onChange={(e) => setVersion(e.target.value)}
                            />
                            <TextField
                                label="Build Number"
                                type="number"
                                size="small"
                                sx={{ width: 140 }}
                                value={buildNumber}
                                onChange={(e) => setBuildNumber(e.target.value)}
                            />
                        </Stack>

                        <TextField
                            label="Release Notes"
                            multiline
                            rows={4}
                            placeholder="- Fixed bug\n- Added feature"
                            value={notes}
                            onChange={(e) => setNotes(e.target.value)}
                        />

                        <FormControlLabel
                            control={<Checkbox checked={forceUpdate} onChange={(e) => setForceUpdate(e.target.checked)} />}
                            label="Force Update (Required)"
                        />

                        {status.type && (
                            <Alert severity={status.type}>{status.msg}</Alert>
                        )}

                        {uploading && <LinearProgress variant="determinate" value={progress} />}

                        <Button
                            type="submit"
                            variant="contained"
                            startIcon={<SaveIcon />}
                            disabled={uploading}
                            size="large"
                        >
                            {uploading ? 'Uploading...' : 'Publish Release'}
                        </Button>
                    </Box>
                </Paper>
            </Grid>

            {/* History List */}
            <Grid item xs={12} md={7}>
                <Paper sx={{ p: 0, overflow: 'hidden' }}>
                    <Box sx={{ p: 3, borderBottom: '1px solid #e2e8f0' }}>
                        <Typography variant="h6" fontWeight={600}>Release History</Typography>
                    </Box>
                    <Stack separator={<Divider />}>
                        {initialUpdates.map((update) => (
                            <Box key={update.id} sx={{ p: 3 }}>
                                <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
                                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                                        <Typography variant="h6" color="primary.main">v{update.version}</Typography>
                                        <Chip
                                            label={`Build ${update.buildNumber}`}
                                            size="small"
                                            sx={{ bgcolor: '#f1f5f9' }}
                                        />
                                        {update.forceUpdate && <Chip label="Forced" color="error" size="small" />}
                                    </Box>
                                    <Typography variant="caption" color="text.secondary">
                                        {update.createdAt ? new Date(update.createdAt).toLocaleDateString() : 'Unknown Date'}
                                    </Typography>
                                </Box>
                                <Typography variant="body2" color="text.secondary" sx={{ whiteSpace: 'pre-line' }}>
                                    {update.releaseNotes || 'No release notes.'}
                                </Typography>
                                <Typography variant="caption" display="block" sx={{ mt: 1, color: '#94a3b8' }}>
                                    {(update.fileSize / 1024 / 1024).toFixed(2)} MB
                                </Typography>
                            </Box>
                        ))}
                        {initialUpdates.length === 0 && (
                            <Box sx={{ p: 4, textAlign: 'center', color: 'text.secondary' }}>
                                No releases found.
                            </Box>
                        )}
                    </Stack>
                </Paper>
            </Grid>
        </Grid>
    );
}
