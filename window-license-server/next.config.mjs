/** @type {import('next').NextConfig} */
const nextConfig = {
    // API routes only - no frontend
    reactStrictMode: true,
    typescript: {
        ignoreBuildErrors: true,
    },
    eslint: {
        ignoreDuringBuilds: true,
    },
};

export default nextConfig;
