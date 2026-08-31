// ============================================================================
// AM5 ROYAL • Tab 4: Settings & Profile Management
// Mirrors Flutter: _buildSettingsTab()
// ============================================================================

import React, { useState } from 'react';
import { useAuth } from '../auth/AuthContext';
import { EditProfileModal } from '../components/profile/EditProfileModal';
import {
  User,
  Building,
  Mail,
  Phone,
  Shield,
  Coins,
  Edit3,
  CheckCircle,
  AlertTriangle,
  Info,
} from 'lucide-react';

export const SettingsTab: React.FC = () => {
  const { user } = useAuth();
  const [isEditOpen, setIsEditOpen] = useState(false);

  const hasBankDetails = Boolean(
    user?.bankName?.trim() &&
    user?.bankAccountNumber?.trim() &&
    user?.bankIfscCode?.trim()
  );

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
      {/* Title */}
      <div>
        <h2 style={{ fontSize: '1.75rem', color: 'var(--text-main)' }}>
          Profile & Account Settings
        </h2>
        <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem', marginTop: '0.25rem' }}>
          Manage your telecaller employee identity and commission payout banking credentials.
        </p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(360px, 1fr))', gap: '1.5rem' }}>
        {/* Personal Details Card */}
        <div className="card" style={{ padding: '1.75rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
              <div
                style={{
                  width: '42px',
                  height: '42px',
                  borderRadius: '12px',
                  background: 'var(--primary-light)',
                  color: 'var(--primary)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <User size={22} />
              </div>
              <div>
                <h3 style={{ fontSize: '1.15rem' }}>Employee Information</h3>
                <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                  Assigned operator credentials
                </p>
              </div>
            </div>

            <button
              className="btn btn-sm btn-outline"
              onClick={() => setIsEditOpen(true)}
              title="Edit Profile"
            >
              <Edit3 size={14} />
              <span>Edit Details</span>
            </button>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
              <User size={16} color="var(--text-subtle)" />
              <div>
                <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Full Name</div>
                <div style={{ fontWeight: 700, fontSize: '0.95rem' }}>
                  {user?.firstName} {user?.lastName}
                </div>
              </div>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
              <Mail size={16} color="var(--text-subtle)" />
              <div>
                <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Email Address</div>
                <div style={{ fontWeight: 600, fontSize: '0.95rem' }}>{user?.email || '—'}</div>
              </div>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
              <Phone size={16} color="var(--text-subtle)" />
              <div>
                <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Phone Number</div>
                <div style={{ fontWeight: 600, fontSize: '0.95rem', fontFamily: 'monospace' }}>
                  {user?.phoneNumber || '—'}
                </div>
              </div>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
              <Shield size={16} color="var(--text-subtle)" />
              <div>
                <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Assigned Role</div>
                <div style={{ fontWeight: 700, fontSize: '0.85rem', color: 'var(--primary)' }}>
                  {user?.role?.toUpperCase()}
                </div>
              </div>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
              <Coins size={16} color="var(--gold)" />
              <div>
                <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Referral Points Balance</div>
                <div style={{ fontWeight: 800, fontSize: '1.25rem', color: '#b45309' }}>
                  {user?.referralPoints ?? 0} Points
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Banking Information Card */}
        <div
          className="card"
          style={{
            padding: '1.75rem',
            background: 'linear-gradient(135deg, #ffffff 0%, #fffbeb 100%)',
            border: '1.5px solid rgba(245, 158, 11, 0.3)',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
              <div
                style={{
                  width: '42px',
                  height: '42px',
                  borderRadius: '12px',
                  background: 'var(--gold-light)',
                  color: 'var(--gold)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <Building size={22} />
              </div>
              <div>
                <h3 style={{ fontSize: '1.15rem', color: '#92400e' }}>Payout Bank Account</h3>
                <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                  Used for commission & bonus deposits
                </p>
              </div>
            </div>

            <button
              className="btn btn-sm btn-gold"
              onClick={() => setIsEditOpen(true)}
              title="Configure Bank Account"
            >
              <Edit3 size={14} />
              <span>{hasBankDetails ? 'Update Account' : 'Add Bank'}</span>
            </button>
          </div>

          {!hasBankDetails ? (
            <div
              style={{
                padding: '1.25rem',
                borderRadius: 'var(--radius-md)',
                background: 'var(--warning-light)',
                border: '1px solid #fde68a',
                color: '#92400e',
              }}
            >
              <div style={{ display: 'flex', gap: '0.75rem' }}>
                <AlertTriangle size={22} flex-shrink={0} />
                <div>
                  <div style={{ fontWeight: 700, fontSize: '0.95rem' }}>No Bank Account Linked</div>
                  <p style={{ fontSize: '0.8rem', marginTop: '0.25rem', lineHeight: 1.4 }}>
                    To receive your commission withdrawals directly, click "Add Bank" and enter your bank name, account number, and IFSC code.
                  </p>
                </div>
              </div>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.5rem',
                  color: '#065f46',
                  fontSize: '0.8rem',
                  fontWeight: 700,
                  marginBottom: '0.5rem',
                }}
              >
                <CheckCircle size={16} />
                <span>Verified Direct Deposit Account</span>
              </div>

              <div>
                <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Account Holder Name</div>
                <div style={{ fontWeight: 700, fontSize: '0.95rem' }}>
                  {user?.bankAccountName || `${user?.firstName} ${user?.lastName}`}
                </div>
              </div>

              <div>
                <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Bank Name</div>
                <div style={{ fontWeight: 600, fontSize: '0.95rem' }}>{user?.bankName}</div>
              </div>

              <div>
                <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Bank Account Number</div>
                <div style={{ fontWeight: 700, fontSize: '0.95rem', fontFamily: 'monospace' }}>
                  •••• {user?.bankAccountNumber?.slice(-4)}
                </div>
              </div>

              <div>
                <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>IFSC Code</div>
                <div style={{ fontWeight: 700, fontSize: '0.95rem', fontFamily: 'monospace' }}>
                  {user?.bankIfscCode}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* System info card */}
      <div
        className="card"
        style={{
          background: 'var(--bg-subtle)',
          padding: '1.25rem 1.5rem',
          display: 'flex',
          alignItems: 'center',
          gap: '1rem',
        }}
      >
        <Info size={20} color="var(--primary)" />
        <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
          <strong>AM5 ROYAL Telecaller Panel v1.0.0</strong> • Operating under official Partner Verification & Telecaller Attribution Policy.
        </div>
      </div>

      {/* Edit Profile Modal */}
      {isEditOpen && (
        <EditProfileModal isOpen={isEditOpen} onClose={() => setIsEditOpen(false)} />
      )}
    </div>
  );
};
