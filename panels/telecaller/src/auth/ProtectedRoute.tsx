// ============================================================================
// AM5 ROYAL • Protected Route Guard
// Ensures user is logged in as an active employee / telecaller
// ============================================================================

import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from './AuthContext';
import { Loader2 } from 'lucide-react';

interface ProtectedRouteProps {
  children: React.ReactNode;
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children }) => {
  const { isAuthenticated, isLoading, role } = useAuth();
  const location = useLocation();

  if (isLoading) {
    return (
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          minHeight: '100vh',
          background: 'var(--bg-app)',
          gap: '1rem',
        }}
      >
        <Loader2 className="spinner" size={40} color="var(--primary)" />
        <p style={{ fontFamily: 'var(--font-heading)', color: 'var(--text-muted)', fontSize: '0.9rem' }}>
          Verifying AM5 Royal Telecaller Session...
        </p>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  // Validate allowed roles: telecaller, tele_caller, admin
  const normalizedRole = role?.toLowerCase() || '';
  const isAllowedRole =
    normalizedRole.includes('tele') || normalizedRole === 'admin';

  if (!isAllowedRole) {
    return (
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          minHeight: '100vh',
          padding: '2rem',
          textAlign: 'center',
        }}
      >
        <h2 style={{ color: 'var(--danger)', marginBottom: '0.5rem' }}>Access Restricted</h2>
        <p style={{ color: 'var(--text-muted)', maxWidth: '400px', marginBottom: '1.5rem' }}>
          Your account role ({role}) does not have permission to access the Telecaller Operations Dashboard.
        </p>
        <button
          className="btn btn-outline"
          onClick={() => {
            window.location.href = '/login';
          }}
        >
          Return to Login
        </button>
      </div>
    );
  }

  return <>{children}</>;
};
