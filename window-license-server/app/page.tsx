import React from 'react';

export default function Home() {
    return (
        <div style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            minHeight: '100vh',
            fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif'
        }}>
            <div style={{
                backgroundColor: 'white',
                padding: '2rem',
                borderRadius: '12px',
                boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
                textAlign: 'center',
                maxWidth: '400px',
                width: '90%'
            }}>
                <h1 style={{ margin: '0 0 1rem 0', color: '#1a1a1a', fontSize: '1.5rem' }}>Window License Server</h1>
                <div style={{
                    display: 'inline-block',
                    padding: '0.5rem 1rem',
                    backgroundColor: '#dcfce7',
                    color: '#166534',
                    borderRadius: '9999px',
                    fontWeight: '600',
                    fontSize: '0.875rem',
                    marginBottom: '1.5rem'
                }}>
                    ● Active & Operational
                </div>
                <p style={{ color: '#6b7280', margin: 0, fontSize: '0.875rem' }}>
                    API endpoints are ready to accept connections.
                </p>
                <div style={{ marginTop: '2rem', paddingTop: '1rem', borderTop: '1px solid #e5e7eb', fontSize: '0.75rem', color: '#9ca3af' }}>
                    v1.0.0
                </div>
            </div>
        </div>
    );
}
