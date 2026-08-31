// ============================================================================
// AM5 ROYAL • Vendor Stepper Card Component (7-Step Workflow Tracker)
// Mirrors Flutter: _buildVendorStepperCard() / _approveVendor() / _rejectVendor()
// ============================================================================

import React, { useState } from 'react';
import { TelecallerOnboardedVendor } from '../../types';
import { getStepIndex, getStatusBadgeClass } from '../../utils/formatters';
import { vendorActionsApi } from '../../api/vendorActionsApi';
import { extractErrorMessage } from '../../api/client';
import {
  Store,
  PhoneCall,
  CheckCircle2,
  XCircle,
  Clock,
  Sparkles,
  Loader2,
  AlertTriangle,
} from 'lucide-react';
import { StepDetailsModal } from './StepDetailsModal';

interface VendorStepperCardProps {
  vendor: TelecallerOnboardedVendor;
  onRefreshList: () => void;
}

export const VendorStepperCard: React.FC<VendorStepperCardProps> = ({
  vendor,
  onRefreshList,
}) => {
  const [selectedStepForModal, setSelectedStepForModal] = useState<string | null>(null);
  const [isApproving, setIsApproving] = useState(false);
  const [isRejecting, setIsRejecting] = useState(false);
  const [showConfirmApprove, setShowConfirmApprove] = useState(false);
  const [showConfirmReject, setShowConfirmReject] = useState(false);
  const [actionError, setActionError] = useState<string | null>(null);

  const steps = [
    'Services',
    'Slots',
    'Registration',
    'Business Reg',
    'Payment',
    'Temp Active',
    'Activated',
  ];

  const currentStep = getStepIndex(vendor.status);
  const statusLower = vendor.status.toLowerCase().replace(/[\s_]+/g, ' ');
  const isUnderVerification = statusLower === 'temporary active' || statusLower === 'temp active';

  // Handle Approve
  const handleApprove = async () => {
    setIsApproving(true);
    setActionError(null);
    try {
      await vendorActionsApi.approveVendor(vendor.id);
      setShowConfirmApprove(false);
      onRefreshList();
    } catch (err) {
      setActionError(extractErrorMessage(err));
    } finally {
      setIsApproving(false);
    }
  };

  // Handle Reject
  const handleReject = async () => {
    setIsRejecting(true);
    setActionError(null);
    try {
      await vendorActionsApi.rejectVendor(vendor.id);
      setShowConfirmReject(false);
      onRefreshList();
    } catch (err) {
      setActionError(extractErrorMessage(err));
    } finally {
      setIsRejecting(false);
    }
  };

  const isCompanyLead =
    vendor.leadSource === 'company' ||
    vendor.leadSource === 'company_website' ||
    vendor.leadSource === 'company_mobile';

  return (
    <>
      <div
        className="card"
        style={{
          display: 'flex',
          flexDirection: 'column',
          gap: '1.25rem',
          border: isUnderVerification
            ? '1.5px solid rgba(245, 158, 11, 0.4)'
            : '1px solid var(--border-subtle)',
          boxShadow: isUnderVerification
            ? '0 6px 20px -4px rgba(245, 158, 11, 0.15)'
            : 'var(--shadow-sm)',
        }}
      >
        {/* Top: Vendor Info & Action Controls */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            flexWrap: 'wrap',
            gap: '1rem',
          }}
        >
          {/* Left: Store Icon + Names */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            <div
              style={{
                width: '48px',
                height: '48px',
                borderRadius: '14px',
                background: 'linear-gradient(135deg, var(--primary-light) 0%, #eef2ff 100%)',
                color: 'var(--primary)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                boxShadow: '0 2px 8px var(--primary-glow)',
                flexShrink: 0,
              }}
            >
              <Store size={22} />
            </div>

            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
                <h4 style={{ fontSize: '1.05rem', color: 'var(--text-main)' }}>
                  {vendor.businessName || 'Business Name Pending'}
                </h4>
                {vendor.leadSource && isCompanyLead && (
                  <span
                    style={{
                      fontSize: '0.65rem',
                      fontWeight: 700,
                      padding: '0.15rem 0.5rem',
                      borderRadius: '9999px',
                      background: '#fff7ed',
                      border: '1px solid #fed7aa',
                      color: '#c2410c',
                      textTransform: 'uppercase',
                    }}
                  >
                    {vendor.leadSource === 'company_mobile' ? 'Mobile App Lead' : 'Website Lead'}
                  </span>
                )}
              </div>
              <div
                style={{
                  fontSize: '0.8rem',
                  color: 'var(--text-muted)',
                  marginTop: '0.2rem',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.5rem',
                }}
              >
                <span>
                  {vendor.firstName} {vendor.lastName}
                </span>
                <span>•</span>
                <span style={{ fontFamily: 'monospace', fontWeight: 600, color: 'var(--text-main)' }}>
                  {vendor.mobileNumber}
                </span>
                {vendor.city && (
                  <>
                    <span>•</span>
                    <span>{vendor.city}</span>
                  </>
                )}
              </div>
            </div>
          </div>

          {/* Right Action Buttons */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
            {/* Quick dial launcher */}
            <a
              href={`tel:${vendor.mobileNumber}`}
              className="btn btn-sm btn-outline"
              style={{
                textDecoration: 'none',
                borderColor: 'var(--primary-glow)',
                color: 'var(--primary)',
              }}
              title="Direct Call Dialer"
            >
              <PhoneCall size={14} />
              <span>Assist / Call</span>
            </a>

            {/* If Temporary Active: Show Approve & Reject Actions */}
            {isUnderVerification && (
              <>
                <button
                  className="btn btn-sm btn-danger"
                  onClick={() => setShowConfirmReject(true)}
                  disabled={isRejecting || isApproving}
                >
                  <XCircle size={14} />
                  <span>Reject</span>
                </button>
                <button
                  className="btn btn-sm btn-success"
                  onClick={() => setShowConfirmApprove(true)}
                  disabled={isRejecting || isApproving}
                >
                  <CheckCircle2 size={14} />
                  <span>Approve Partner</span>
                </button>
              </>
            )}

            {/* Status pill */}
            <span className={`badge ${getStatusBadgeClass(vendor.status)}`}>
              {vendor.status}
            </span>
          </div>
        </div>

        {/* Error banner if action failed */}
        {actionError && (
          <div
            style={{
              padding: '0.5rem 0.85rem',
              background: 'var(--danger-light)',
              borderRadius: 'var(--radius-sm)',
              color: 'var(--danger)',
              fontSize: '0.8rem',
              display: 'flex',
              alignItems: 'center',
              gap: '0.4rem',
            }}
          >
            <AlertTriangle size={15} />
            <span>{actionError}</span>
          </div>
        )}

        {/* 7-Step Workflow Interactive Progress Bar */}
        <div>
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(7, 1fr)',
              gap: '0.4rem',
            }}
          >
            {steps.map((step, idx) => {
              const isCompleted = idx < currentStep;
              const isCurrent = idx === currentStep;

              let bg = '#f1f5f9';
              let color = '#64748b';
              let borderColor = '#e2e8f0';

              if (isCompleted) {
                bg = '#10b981';
                color = '#ffffff';
                borderColor = '#059669';
              } else if (isCurrent) {
                bg = 'var(--primary)';
                color = '#ffffff';
                borderColor = 'var(--primary-hover)';
              }

              return (
                <button
                  key={idx}
                  onClick={() => setSelectedStepForModal(step)}
                  style={{
                    padding: '0.55rem 0.25rem',
                    borderRadius: '10px',
                    border: `1px solid ${borderColor}`,
                    background: bg,
                    color: color,
                    fontFamily: 'var(--font-heading)',
                    fontSize: '0.725rem',
                    fontWeight: 700,
                    cursor: 'pointer',
                    textAlign: 'center',
                    whiteSpace: 'nowrap',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    boxShadow: isCurrent ? '0 4px 12px var(--primary-glow)' : 'none',
                    transition: 'all 0.15s ease',
                  }}
                  onMouseEnter={(e) => (e.currentTarget.style.transform = 'translateY(-1px)')}
                  onMouseLeave={(e) => (e.currentTarget.style.transform = 'translateY(0)')}
                  title={`Click to inspect ${step} step details`}
                >
                  {step}
                </button>
              );
            })}
          </div>

          {isUnderVerification && (
            <div
              style={{
                marginTop: '0.5rem',
                textAlign: 'center',
                fontSize: '0.775rem',
                color: '#b45309',
                fontStyle: 'italic',
                fontWeight: 600,
              }}
            >
              ★ Under Verification: Review KYC documents and approve when verified.
            </div>
          )}
        </div>
      </div>

      {/* 5-Step Detailed View Inspector Modal */}
      {selectedStepForModal && (
        <StepDetailsModal
          isOpen={Boolean(selectedStepForModal)}
          vendorId={vendor.id}
          vendorName={vendor.businessName || `${vendor.firstName} ${vendor.lastName}`}
          initialStep={selectedStepForModal}
          onClose={() => setSelectedStepForModal(null)}
        />
      )}

      {/* Confirmation Dialog: Approve Partner */}
      {showConfirmApprove && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 140,
            background: 'rgba(15, 23, 42, 0.5)',
            backdropFilter: 'blur(4px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '1rem',
          }}
        >
          <div className="card" style={{ maxWidth: '420px', width: '100%', textAlign: 'center' }}>
            <div
              style={{
                width: '48px',
                height: '48px',
                borderRadius: '50%',
                background: 'var(--success-light)',
                color: 'var(--success)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                margin: '0 auto 1rem auto',
              }}
            >
              <CheckCircle2 size={26} />
            </div>
            <h3 style={{ marginBottom: '0.5rem' }}>Approve Partner</h3>
            <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem', marginBottom: '1.5rem' }}>
              Are you sure you want to approve <strong>{vendor.businessName || vendor.firstName}</strong>? This will activate their profile and authorize customer bookings.
            </p>
            <div style={{ display: 'flex', gap: '0.75rem', justifyContent: 'center' }}>
              <button
                className="btn btn-outline"
                onClick={() => setShowConfirmApprove(false)}
                disabled={isApproving}
              >
                Cancel
              </button>
              <button
                className="btn btn-success"
                onClick={handleApprove}
                disabled={isApproving}
              >
                {isApproving ? (
                  <>
                    <Loader2 size={16} className="spinner" />
                    <span>Approving...</span>
                  </>
                ) : (
                  'Yes, Approve Partner'
                )}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Confirmation Dialog: Reject Partner */}
      {showConfirmReject && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 140,
            background: 'rgba(15, 23, 42, 0.5)',
            backdropFilter: 'blur(4px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '1rem',
          }}
        >
          <div className="card" style={{ maxWidth: '420px', width: '100%', textAlign: 'center' }}>
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
              <XCircle size={26} />
            </div>
            <h3 style={{ marginBottom: '0.5rem' }}>Reject Partner</h3>
            <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem', marginBottom: '1.5rem' }}>
              Are you sure you want to reject <strong>{vendor.businessName || vendor.firstName}</strong>? Their status will be set to rejected.
            </p>
            <div style={{ display: 'flex', gap: '0.75rem', justifyContent: 'center' }}>
              <button
                className="btn btn-outline"
                onClick={() => setShowConfirmReject(false)}
                disabled={isRejecting}
              >
                Cancel
              </button>
              <button
                className="btn btn-danger"
                onClick={handleReject}
                disabled={isRejecting}
              >
                {isRejecting ? (
                  <>
                    <Loader2 size={16} className="spinner" />
                    <span>Rejecting...</span>
                  </>
                ) : (
                  'Confirm Rejection'
                )}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};
