// ============================================================================
// AM5 ROYAL • Header Component
// Branding, Telecaller Quick Stats, Quick Add Action, and Profile Controller
// ============================================================================

import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';
import { UserPlus, LogOut, User, Sparkles, ShieldCheck } from 'lucide-react';
import { EditProfileModal } from '../components/profile/EditProfileModal';

export const Header: React.FC = () => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [isProfileOpen, setIsProfileOpen] = useState(false);
  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);

  const displayName = user
    ? `${user.firstName} ${user.lastName}`.trim() || 'Telecaller'
    : 'AM5 ROYAL';

  const initials = user && user.firstName
    ? `${user.firstName[0]}${user.lastName ? user.lastName[0] : ''}`.toUpperCase()
    : 'TC';

  return (
    <>
      <header
        style={{
          background: 'rgba(255, 255, 255, 0.85)',
          backdropFilter: 'blur(16px)',
          borderBottom: '1px solid var(--border-subtle)',
          padding: '0.875rem 1.75rem',
          position: 'sticky',
          top: 0,
          zIndex: 40,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
        }}
      >
        {/* Left: Brand & Identity */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
          <div
            style={{
              width: '42px',
              height: '42px',
              borderRadius: '12px',
              background: 'linear-gradient(135deg, var(--primary) 0%, #312e81 100%)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: 'white',
              boxShadow: '0 4px 12px var(--primary-glow)',
            }}
          >
            <Sparkles size={22} color="#fcd34d" />
          </div>

          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <span
                style={{
                  fontFamily: 'var(--font-heading)',
                  fontWeight: 800,
                  fontSize: '1.25rem',
                  letterSpacing: '0.05em',
                  background: 'linear-gradient(135deg, var(--primary) 0%, #1e1b4b 100%)',
                  WebkitBackgroundClip: 'text',
                  WebkitTextFillColor: 'transparent',
                }}
              >
                AM5 ROYAL
              </span>
              <span
                style={{
                  fontSize: '0.65rem',
                  fontWeight: 700,
                  padding: '0.15rem 0.45rem',
                  borderRadius: '6px',
                  background: 'var(--primary-light)',
                  color: 'var(--primary)',
                  letterSpacing: '0.05em',
                }}
              >
                OPERATIONS
              </span>
            </div>
            <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)', fontWeight: 500 }}>
              Verification & Partner Operations Suite
            </p>
          </div>
        </div>

        {/* Right Actions: Quick Onboard, Profile, Logout */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.85rem' }}>
          {/* Add New Vendor Action Button */}
          <button
            className="btn btn-primary"
            onClick={() => navigate('/onboard')}
            style={{ padding: '0.55rem 1.15rem', fontSize: '0.85rem' }}
          >
            <UserPlus size={16} />
            <span>Add New Vendor</span>
          </button>

          {/* User Profile Pill */}
          <button
            onClick={() => setIsProfileOpen(true)}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '0.65rem',
              padding: '0.4rem 0.85rem 0.4rem 0.4rem',
              background: 'var(--bg-subtle)',
              border: '1px solid var(--border-subtle)',
              borderRadius: '9999px',
              cursor: 'pointer',
              transition: 'all 0.2s ease',
            }}
            onMouseEnter={(e) => (e.currentTarget.style.borderColor = 'var(--primary)')}
            onMouseLeave={(e) => (e.currentTarget.style.borderColor = 'var(--border-subtle)')}
            title="View Profile & Bank Settings"
          >
            <div
              style={{
                width: '32px',
                height: '32px',
                borderRadius: '50%',
                background: 'linear-gradient(135deg, var(--secondary) 0%, #0f766e 100%)',
                color: 'white',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontWeight: 700,
                fontSize: '0.8rem',
              }}
            >
              {initials}
            </div>
            <div style={{ textAlign: 'left' }}>
              <div
                style={{
                  fontFamily: 'var(--font-heading)',
                  fontSize: '0.8rem',
                  fontWeight: 700,
                  color: 'var(--text-main)',
                  maxWidth: '120px',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                  whiteSpace: 'nowrap',
                }}
              >
                {displayName}
              </div>
              <div style={{ fontSize: '0.675rem', color: 'var(--text-muted)' }}>
                {user?.referralPoints ?? 0} pts
              </div>
            </div>
          </button>

          {/* Logout Action */}
          <button
            onClick={() => setShowLogoutConfirm(true)}
            style={{
              width: '38px',
              height: '38px',
              borderRadius: '10px',
              border: '1px solid var(--border-subtle)',
              background: 'white',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              color: 'var(--text-muted)',
              transition: 'all 0.2s',
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.color = 'var(--danger)';
              e.currentTarget.style.borderColor = 'var(--danger-border)';
              e.currentTarget.style.backgroundColor = 'var(--danger-light)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.color = 'var(--text-muted)';
              e.currentTarget.style.borderColor = 'var(--border-subtle)';
              e.currentTarget.style.backgroundColor = 'white';
            }}
            title="Sign Out"
          >
            <LogOut size={17} />
          </button>
        </div>
      </header>

      {/* Edit Profile Modal */}
      {isProfileOpen && (
        <EditProfileModal isOpen={isProfileOpen} onClose={() => setIsProfileOpen(false)} />
      )}

      {/* Logout Confirmation Dialog */}
      {showLogoutConfirm && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 100,
            background: 'rgba(15, 23, 42, 0.45)',
            backdropFilter: 'blur(4px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '1rem',
          }}
        >
          <div
            className="card"
            style={{
              maxWidth: '400px',
              width: '100%',
              textAlign: 'center',
              animation: 'fadeInDown 0.2s ease-out',
            }}
          >
            <div
              style={{
                width: '48px',
                height: '48px',
                borderRadius: '50%',
                background: 'var(--danger-light)',
                color: 'var(--danger)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                margin: '0 auto 1rem auto',
              }}
            >
              <LogOut size={24} />
            </div>
            <h3 style={{ marginBottom: '0.5rem' }}>Sign Out</h3>
            <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem', marginBottom: '1.5rem' }}>
              Are you sure you want to end your current session? You will need to log in again with your credentials.
            </p>
            <div style={{ display: 'flex', gap: '0.75rem', justifyContent: 'center' }}>
              <button className="btn btn-outline" onClick={() => setShowLogoutConfirm(false)}>
                Cancel
              </button>
              <button
                className="btn btn-danger"
                onClick={() => {
                  setShowLogoutConfirm(false);
                  logout();
                }}
              >
                Sign Out
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};
