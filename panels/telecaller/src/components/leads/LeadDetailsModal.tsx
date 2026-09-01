// ============================================================================
// AM5 ROYAL • Lead Details Modal (Section 9 Specification)
// Comprehensive View: Customer Info, Business Info, Lead Meta & Activity Timeline
// ============================================================================

import React, { useState } from 'react';
import { TelecallerOnboardedVendor } from '../../types';
import { formatDate } from '../../utils/formatters';
import { callApi } from '../../api/callApi';
import {
  X,
  User,
  Building,
  Calendar,
  Phone,
  Mail,
  MapPin,
  CheckCircle2,
  Clock,
  ArrowRight,
  ShieldCheck,
  PhoneCall,
  Activity,
  Layers,
  Loader2,
  AlertCircle,
} from 'lucide-react';

interface LeadDetailsModalProps {
  isOpen: boolean;
  vendor: TelecallerOnboardedVendor;
  onClose: () => void;
}

export const LeadDetailsModal: React.FC<LeadDetailsModalProps> = ({
  isOpen,
  vendor,
  onClose,
}) => {
  const [isCalling, setIsCalling] = useState(false);
  const [callNotice, setCallNotice] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  if (!isOpen) return null;

  // Handle IVR Click-to-Call
  const handleInitiateCall = async () => {
    if (isCalling) return;
    if (!vendor.mobileNumber) {
      setCallNotice({ type: 'error', message: 'No mobile number recorded for this lead.' });
      return;
    }
    setIsCalling(true);
    setCallNotice(null);
    try {
      const res = await callApi.initiateCall({
        vendorId: vendor.id,
        phoneNumber: vendor.mobileNumber,
      });
      if (res.success) {
        setCallNotice({
          type: 'success',
          message: `Call initiated to ${vendor.firstName} ${vendor.lastName} (${vendor.mobileNumber})!${res.call_session_id ? ` (Session: ${res.call_session_id.slice(0, 8)}...)` : ''}`,
        });
      } else {
        setCallNotice({
          type: 'error',
          message: res.message || 'Unable to initiate call.',
        });
      }
    } catch (err) {
      setCallNotice({
        type: 'error',
        message: 'Failed to connect call. Please try again.',
      });
    } finally {
      setIsCalling(false);
    }
  };

  // 8-stage Activity History pipeline per Section 9
  const stages = [
    'Lead Received',
    'Assigned',
    'Contacted',
    'Follow-up',
    'Registration',
    'KYC',
    'Payment',
    'Activated',
  ];

  const getStageIndex = (statusStr: string) => {
    const s = (statusStr || '').toLowerCase();
    if (s.includes('active') && !s.includes('temp')) return 7;
    if (s.includes('temp')) return 5;
    if (s.includes('pay')) return 6;
    if (s.includes('reg') || s.includes('slot') || s.includes('serv')) return 4;
    if (s.includes('contacted')) return 2;
    if (s.includes('follow')) return 3;
    return 1;
  };

  const currentStageIdx = getStageIndex(vendor.status);

  const getSourceLabel = (src?: string | null) => {
    if (!src) return 'Company Website';
    if (src === 'company_mobile') return 'Company Application';
    if (src === 'freelancer') return 'Freelancer Lead';
    return 'Company Website';
  };

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 150,
        background: 'rgba(15, 23, 42, 0.6)',
        backdropFilter: 'blur(6px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '1.5rem',
      }}
      onClick={onClose}
    >
      <div
        className="card"
        style={{
          width: '100%',
          maxWidth: '750px',
          maxHeight: '90vh',
          display: 'flex',
          flexDirection: 'column',
          padding: 0,
          overflow: 'hidden',
          animation: 'fadeIn 0.2s ease-out',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div
          style={{
            padding: '1.25rem 1.5rem',
            borderBottom: '1px solid var(--border-subtle)',
            background: 'linear-gradient(135deg, var(--bg-surface) 0%, rgba(248, 250, 252, 0.8) 100%)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
            <div
              style={{
                width: '40px',
                height: '40px',
                borderRadius: '10px',
                background: 'var(--primary-light)',
                color: 'var(--primary)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Activity size={20} />
            </div>
            <div>
              <h3 style={{ fontSize: '1.15rem', color: 'var(--text-main)' }}>
                Lead Details & Activity History
              </h3>
              <p style={{ fontSize: '0.775rem', color: 'var(--text-muted)' }}>
                Lead #{vendor.id} • {getSourceLabel(vendor.leadSource)}
              </p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="btn btn-sm btn-outline"
            style={{ borderRadius: '50%', width: '32px', height: '32px', padding: 0 }}
          >
            <X size={16} />
          </button>
        </div>

        {/* Call Notice Feedback Banner */}
        {callNotice && (
          <div
            style={{
              padding: '0.75rem 1.5rem',
              background: callNotice.type === 'success' ? '#ecfdf5' : '#fef2f2',
              borderBottom: `1px solid ${callNotice.type === 'success' ? '#a7f3d0' : '#fecaca'}`,
              color: callNotice.type === 'success' ? '#065f46' : '#991b1b',
              fontSize: '0.85rem',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              gap: '0.5rem',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              {callNotice.type === 'success' ? (
                <CheckCircle2 size={16} color="#059669" />
              ) : (
                <AlertCircle size={16} color="#dc2626" />
              )}
              <span style={{ fontWeight: 500 }}>{callNotice.message}</span>
            </div>
            <button
              onClick={() => setCallNotice(null)}
              style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'inherit', padding: 0 }}
            >
              ✕
            </button>
          </div>
        )}

        {/* Scrollable Content */}
        <div
          style={{
            padding: '1.5rem',
            overflowY: 'auto',
            display: 'flex',
            flexDirection: 'column',
            gap: '1.5rem',
          }}
        >
          {/* Top Activity History Timeline per Section 9 */}
          <div
            style={{
              padding: '1.25rem',
              background: 'var(--bg-subtle)',
              borderRadius: 'var(--radius-md)',
              border: '1px solid var(--border-subtle)',
            }}
          >
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                marginBottom: '1rem',
              }}
            >
              <h4
                style={{
                  fontSize: '0.85rem',
                  fontFamily: 'var(--font-heading)',
                  textTransform: 'uppercase',
                  letterSpacing: '0.05em',
                  color: 'var(--text-subtle)',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.4rem',
                }}
              >
                <Clock size={15} color="var(--primary)" />
                <span>Activity History Progression</span>
              </h4>
              <span
                style={{
                  fontSize: '0.725rem',
                  fontWeight: 700,
                  color: 'var(--primary)',
                  background: 'var(--primary-light)',
                  padding: '0.2rem 0.6rem',
                  borderRadius: '9999px',
                }}
              >
                Current: {vendor.status}
              </span>
            </div>

            {/* Stepper track */}
            <div
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(8, 1fr)',
                gap: '0.35rem',
                position: 'relative',
              }}
            >
              {stages.map((stage, idx) => {
                const isPassed = idx <= currentStageIdx;
                const isCurrent = idx === currentStageIdx;

                let bg = '#e2e8f0';
                let color = '#64748b';
                let border = '#cbd5e1';

                if (isCurrent) {
                  bg = 'var(--primary)';
                  color = '#ffffff';
                  border = 'var(--primary-hover)';
                } else if (isPassed) {
                  bg = '#10b981';
                  color = '#ffffff';
                  border = '#059669';
                }

                return (
                  <div
                    key={stage}
                    style={{
                      display: 'flex',
                      flexDirection: 'column',
                      alignItems: 'center',
                      textAlign: 'center',
                      gap: '0.4rem',
                    }}
                  >
                    <div
                      style={{
                        width: '28px',
                        height: '28px',
                        borderRadius: '50%',
                        background: bg,
                        color: color,
                        border: `1.5px solid ${border}`,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontSize: '0.7rem',
                        fontWeight: 700,
                        boxShadow: isCurrent ? '0 0 10px var(--primary-glow)' : 'none',
                      }}
                    >
                      {isPassed && !isCurrent ? '✓' : idx + 1}
                    </div>
                    <span
                      style={{
                        fontSize: '0.65rem',
                        fontWeight: isCurrent ? 700 : 500,
                        color: isCurrent ? 'var(--primary)' : 'var(--text-muted)',
                        lineHeight: 1.2,
                        wordBreak: 'break-word',
                      }}
                    >
                      {stage}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Customer & Business Details 2-Column Grid */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '1.25rem' }}>
            {/* Customer Details */}
            <div
              style={{
                padding: '1.25rem',
                border: '1px solid var(--border-subtle)',
                borderRadius: 'var(--radius-md)',
                background: 'white',
              }}
            >
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.5rem',
                  marginBottom: '1rem',
                  color: 'var(--primary)',
                  fontWeight: 700,
                  fontSize: '0.875rem',
                  fontFamily: 'var(--font-heading)',
                }}
              >
                <User size={16} />
                <span>Customer / Contact Details</span>
              </div>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem', fontSize: '0.825rem' }}>
                <div>
                  <div style={{ color: 'var(--text-subtle)', fontSize: '0.7rem' }}>Customer Name</div>
                  <div style={{ fontWeight: 600, color: 'var(--text-main)', marginTop: '0.1rem' }}>
                    {vendor.firstName} {vendor.lastName}
                  </div>
                </div>

                <div>
                  <div style={{ color: 'var(--text-subtle)', fontSize: '0.7rem' }}>Mobile Number</div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginTop: '0.1rem' }}>
                    <span style={{ fontFamily: 'monospace', fontWeight: 600 }}>{vendor.mobileNumber}</span>
                    <button
                      type="button"
                      onClick={handleInitiateCall}
                      disabled={isCalling}
                      className="btn btn-sm btn-outline"
                      style={{
                        padding: '0.15rem 0.5rem',
                        fontSize: '0.7rem',
                        color: isCalling ? '#b45309' : 'var(--primary)',
                        borderColor: isCalling ? '#f59e0b' : undefined,
                        cursor: isCalling ? 'not-allowed' : 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '0.25rem',
                      }}
                      title="Initiate Airtel IQ Click-to-Call"
                    >
                      {isCalling ? (
                        <>
                          <Loader2 size={11} className="spin" />
                          <span>Calling...</span>
                        </>
                      ) : (
                        <>
                          <PhoneCall size={11} />
                          <span>Call</span>
                        </>
                      )}
                    </button>
                  </div>
                </div>

                <div>
                  <div style={{ color: 'var(--text-subtle)', fontSize: '0.7rem' }}>Email Address</div>
                  <div style={{ color: 'var(--text-main)', marginTop: '0.1rem' }}>
                    {vendor.email || 'Not provided'}
                  </div>
                </div>

                <div>
                  <div style={{ color: 'var(--text-subtle)', fontSize: '0.7rem' }}>Location / City</div>
                  <div style={{ color: 'var(--text-main)', marginTop: '0.1rem' }}>
                    {vendor.city || 'Location Pending'}
                  </div>
                </div>
              </div>
            </div>

            {/* Business Details */}
            <div
              style={{
                padding: '1.25rem',
                border: '1px solid var(--border-subtle)',
                borderRadius: 'var(--radius-md)',
                background: 'white',
              }}
            >
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.5rem',
                  marginBottom: '1rem',
                  color: 'var(--secondary)',
                  fontWeight: 700,
                  fontSize: '0.875rem',
                  fontFamily: 'var(--font-heading)',
                }}
              >
                <Building size={16} />
                <span>Business Details</span>
              </div>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem', fontSize: '0.825rem' }}>
                <div>
                  <div style={{ color: 'var(--text-subtle)', fontSize: '0.7rem' }}>Business Name</div>
                  <div style={{ fontWeight: 600, color: 'var(--text-main)', marginTop: '0.1rem' }}>
                    {vendor.businessName || 'Business Registration Pending'}
                  </div>
                </div>

                <div>
                  <div style={{ color: 'var(--text-subtle)', fontSize: '0.7rem' }}>Service Category</div>
                  <div style={{ color: 'var(--text-main)', marginTop: '0.1rem' }}>
                    {vendor.serviceName || 'Home & Commercial Services'}
                  </div>
                </div>

                <div>
                  <div style={{ color: 'var(--text-subtle)', fontSize: '0.7rem' }}>Assigned Team Member</div>
                  <div style={{ color: 'var(--primary)', fontWeight: 600, marginTop: '0.1rem' }}>
                    {vendor.assignedTeamMember || 'Unassigned'}
                  </div>
                </div>

                <div>
                  <div style={{ color: 'var(--text-subtle)', fontSize: '0.7rem' }}>Lead Source & ID</div>
                  <div style={{ color: 'var(--text-main)', marginTop: '0.1rem' }}>
                    {getSourceLabel(vendor.leadSource)} (ID #{vendor.id})
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div
          style={{
            padding: '1rem 1.5rem',
            borderTop: '1px solid var(--border-subtle)',
            background: 'var(--bg-subtle)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <span style={{ fontSize: '0.775rem', color: 'var(--text-muted)' }}>
            Registered on: {formatDate(vendor.createdAt)}
          </span>

          <div style={{ display: 'flex', gap: '0.5rem' }}>
            <button
              type="button"
              onClick={handleInitiateCall}
              disabled={isCalling}
              className="btn btn-primary"
              style={{
                fontSize: '0.85rem',
                cursor: isCalling ? 'not-allowed' : 'pointer',
                opacity: isCalling ? 0.85 : 1,
                display: 'flex',
                alignItems: 'center',
                gap: '0.4rem',
              }}
              title="Initiate Airtel IQ Click-to-Call"
            >
              {isCalling ? (
                <>
                  <Loader2 size={14} className="spin" />
                  <span>Connecting Call...</span>
                </>
              ) : (
                <>
                  <PhoneCall size={14} />
                  <span>Assist / Call Customer</span>
                </>
              )}
            </button>
            <button className="btn btn-outline" onClick={onClose} style={{ fontSize: '0.85rem' }}>
              Close
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
