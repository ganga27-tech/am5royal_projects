// ============================================================================
// AM5 ROYAL • Vendor Stepper Card Component (7-Step Workflow Tracker)
// Mirrors Specification: Services → Registration → Slots → Business Reg → Payment → Temp Active (Edit) → Activated
// ============================================================================

import React, { useState } from 'react';
import { TelecallerOnboardedVendor } from '../../types';
import { getStepIndex, getStatusBadgeClass, formatDate } from '../../utils/formatters';
import { vendorActionsApi } from '../../api/vendorActionsApi';
import { callApi } from '../../api/callApi';
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
  FileText,
  Edit3,
  Mail,
  User,
  UserCheck,
  Tag,
  ChevronDown,
} from 'lucide-react';
import { StepDetailsModal } from './StepDetailsModal';
import { LeadDetailsModal } from '../leads/LeadDetailsModal';
import { EditVendorDetailsModal } from './EditVendorDetailsModal';

interface VendorStepperCardProps {
  vendor: TelecallerOnboardedVendor;
  onRefreshList: () => void;
}

export const VendorStepperCard: React.FC<VendorStepperCardProps> = ({
  vendor,
  onRefreshList,
}) => {
  const [selectedStepForModal, setSelectedStepForModal] = useState<string | null>(null);
  const [showLeadDetails, setShowLeadDetails] = useState(false);
  const [showEditDetails, setShowEditDetails] = useState(false);
  const [isApproving, setIsApproving] = useState(false);
  const [isRejecting, setIsRejecting] = useState(false);
  const [isUpdatingStatus, setIsUpdatingStatus] = useState(false);
  const [showConfirmApprove, setShowConfirmApprove] = useState(false);
  const [showConfirmReject, setShowConfirmReject] = useState(false);
  const [actionError, setActionError] = useState<string | null>(null);
  const [isCalling, setIsCalling] = useState(false);
  const [callFeedback, setCallFeedback] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  // Exact 7-step sequence per Specification (Registration before Slots)
  const steps = [
    'Services',
    'Registration',
    'Slots',
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

  // Handle CRM Status change (Section 5.4 / 10)
  const handleStatusChange = async (newStatus: string) => {
    if (!newStatus || newStatus === vendor.leadStatus) return;
    setIsUpdatingStatus(true);
    setActionError(null);
    try {
      await vendorActionsApi.updateLeadStatus(vendor.id, newStatus);
      onRefreshList();
    } catch (err) {
      setActionError(extractErrorMessage(err));
    } finally {
      setIsUpdatingStatus(false);
    }
  };

  // Handle IVR Click-to-Call
  const handleInitiateCall = async () => {
    if (isCalling) return;
    if (!vendor.mobileNumber) {
      setCallFeedback({ type: 'error', message: 'Vendor has no mobile number recorded.' });
      return;
    }
    setIsCalling(true);
    setCallFeedback(null);
    try {
      const res = await callApi.initiateCall({
        vendorId: vendor.id,
        phoneNumber: vendor.mobileNumber,
      });
      if (res.success) {
        setCallFeedback({
          type: 'success',
          message: `Call initiated to ${vendor.mobileNumber}!${res.call_session_id ? ` (Session: ${res.call_session_id.slice(0, 8)}...)` : ''}`,
        });
        setTimeout(() => {
          setCallFeedback(null);
        }, 6000);
      } else {
        setCallFeedback({
          type: 'error',
          message: res.message || 'Unable to initiate call.',
        });
      }
    } catch (err) {
      setCallFeedback({
        type: 'error',
        message: extractErrorMessage(err),
      });
    } finally {
      setIsCalling(false);
    }
  };

  const getSourceBadge = () => {
    const src = vendor.leadSource || '';
    if (src === 'company_mobile') {
      return { label: 'Company App', bg: '#f5f3ff', border: '#ddd6fe', color: '#6d28d9' };
    }
    if (src === 'freelancer') {
      return { label: 'Freelancer', bg: '#fffbeb', border: '#fde68a', color: '#b45309' };
    }
    return { label: 'Company Website', bg: '#eff6ff', border: '#bfdbfe', color: '#1d4ed8' };
  };

  const sourceBadge = getSourceBadge();

  return (
    <>
      <div
        className="card"
        style={{
          display: 'flex',
          flexDirection: 'column',
          gap: '1.15rem',
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
            alignItems: 'flex-start',
            justifyContent: 'space-between',
            flexWrap: 'wrap',
            gap: '1rem',
          }}
        >
          {/* Left: Store Icon + Multi-line Details */}
          <div style={{ display: 'flex', alignItems: 'flex-start', gap: '0.85rem' }}>
            <div
              style={{
                width: '46px',
                height: '46px',
                borderRadius: '12px',
                background: 'linear-gradient(135deg, var(--primary-light) 0%, #eef2ff 100%)',
                color: 'var(--primary)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                boxShadow: '0 2px 8px var(--primary-glow)',
                flexShrink: 0,
                marginTop: '0.1rem',
              }}
            >
              <Store size={22} />
            </div>

            <div>
              {/* Business Name & Source Badge */}
              <div style={{ display: 'flex', alignItems: 'center', flexWrap: 'wrap', gap: '0.5rem' }}>
                <h4 style={{ fontSize: '1.05rem', color: 'var(--text-main)', fontWeight: 700 }}>
                  {vendor.businessName || 'Business Name Pending'}
                </h4>

                <span
                  style={{
                    fontSize: '0.65rem',
                    fontWeight: 700,
                    padding: '0.15rem 0.5rem',
                    borderRadius: '9999px',
                    background: sourceBadge.bg,
                    border: `1px solid ${sourceBadge.border}`,
                    color: sourceBadge.color,
                    textTransform: 'uppercase',
                    letterSpacing: '0.04em',
                  }}
                >
                  {sourceBadge.label}
                </span>

                {vendor.serviceName && (
                  <span
                    style={{
                      fontSize: '0.675rem',
                      fontWeight: 600,
                      padding: '0.15rem 0.45rem',
                      borderRadius: '6px',
                      background: 'var(--bg-subtle)',
                      color: 'var(--text-muted)',
                    }}
                  >
                    {vendor.serviceName}
                  </span>
                )}
              </div>

              {/* Vendor Personal Details */}
              <div
                style={{
                  fontSize: '0.8rem',
                  color: 'var(--text-muted)',
                  marginTop: '0.35rem',
                  display: 'flex',
                  alignItems: 'center',
                  flexWrap: 'wrap',
                  gap: '0.45rem',
                }}
              >
                <span style={{ fontWeight: 600, color: 'var(--text-main)' }}>
                  {vendor.firstName} {vendor.lastName}
                </span>
                <span>•</span>
                <span style={{ fontFamily: 'monospace', fontWeight: 600, color: 'var(--text-main)' }}>
                  {vendor.mobileNumber}
                </span>
                {vendor.email && (
                  <>
                    <span>•</span>
                    <span>{vendor.email}</span>
                  </>
                )}
                {vendor.city && (
                  <>
                    <span>•</span>
                    <span>{vendor.city}</span>
                  </>
                )}
              </div>

              {/* Metadata Row: Lead Assignment, Created Date, ID */}
              <div
                style={{
                  fontSize: '0.725rem',
                  color: 'var(--text-subtle)',
                  marginTop: '0.35rem',
                  display: 'flex',
                  alignItems: 'center',
                  flexWrap: 'wrap',
                  gap: '0.6rem',
                }}
              >
                <span style={{ display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                  <UserCheck size={12} color="var(--primary)" />
                  <strong>Assigned To:</strong> {vendor.assignedTeamMember || 'Unassigned'}
                </span>
                <span>•</span>
                <span>Lead #{vendor.id}</span>
                <span>•</span>
                <span>Created: {formatDate(vendor.createdAt)}</span>
              </div>
            </div>
          </div>

          {/* Right Action Buttons */}
          <div style={{ display: 'flex', alignItems: 'center', flexWrap: 'wrap', gap: '0.5rem' }}>
            {/* Click-to-Call (Airtel IQ IVR) */}
            <button
              className="btn btn-sm btn-outline"
              onClick={handleInitiateCall}
              disabled={isCalling}
              style={{
                borderColor: isCalling ? '#f59e0b' : 'var(--primary-glow)',
                color: isCalling ? '#b45309' : 'var(--primary)',
                cursor: isCalling ? 'not-allowed' : 'pointer',
              }}
              title="Initiate Airtel IQ Click-to-Call"
            >
              {isCalling ? (
                <>
                  <Loader2 size={14} className="spin" />
                  <span>Connecting...</span>
                </>
              ) : (
                <>
                  <PhoneCall size={14} />
                  <span>Assist / Call</span>
                </>
              )}
            </button>

            {/* View Details (Section 9 Modal) */}
            <button
              className="btn btn-sm btn-outline"
              onClick={() => setShowLeadDetails(true)}
              title="View full lead details & activity history"
            >
              <FileText size={14} />
              <span>View Details</span>
            </button>

            {/* If Temporary Active: Show Edit Details + Approve & Reject */}
            {isUnderVerification && (
              <>
                <button
                  className="btn btn-sm btn-outline"
                  onClick={() => setShowEditDetails(true)}
                  style={{ borderColor: '#f59e0b', color: '#b45309' }}
                  title="Edit details before activation"
                >
                  <Edit3 size={14} />
                  <span>Edit Option</span>
                </button>

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

            {/* Update Status Dropdown per Section 5.4 */}
            <div style={{ position: 'relative' }}>
              <select
                className="form-select"
                value={vendor.leadStatus || 'New'}
                onChange={(e) => handleStatusChange(e.target.value)}
                disabled={isUpdatingStatus}
                style={{
                  padding: '0.35rem 0.65rem',
                  fontSize: '0.75rem',
                  height: '32px',
                  fontWeight: 600,
                  width: 'auto',
                }}
                title="Update Lead Status"
              >
                <option value="New">Status: New</option>
                <option value="Contacted">Status: Contacted</option>
                <option value="In Progress">Status: In Progress</option>
                <option value="Registration Pending">Status: Reg Pending</option>
                <option value="KYC Pending">Status: KYC Pending</option>
                <option value="Payment Pending">Status: Payment Pending</option>
                <option value="Activated">Status: Activated</option>
                <option value="Converted">Status: Converted</option>
                <option value="Not Interested">Status: Not Interested</option>
                <option value="Closed">Status: Closed</option>
              </select>
            </div>

            {/* Current Step Badge */}
            <span className={`badge ${getStatusBadgeClass(vendor.status)}`}>
              {vendor.status}
            </span>
          </div>
        </div>

        {/* Call Feedback Banner */}
        {callFeedback && (
          <div
            style={{
              padding: '0.5rem 0.85rem',
              background: callFeedback.type === 'success' ? '#ecfdf5' : 'var(--danger-light)',
              border: `1px solid ${callFeedback.type === 'success' ? '#a7f3d0' : '#fecaca'}`,
              borderRadius: 'var(--radius-sm)',
              color: callFeedback.type === 'success' ? '#065f46' : 'var(--danger)',
              fontSize: '0.8rem',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              gap: '0.4rem',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem' }}>
              {callFeedback.type === 'success' ? (
                <CheckCircle2 size={15} color="#059669" />
              ) : (
                <AlertTriangle size={15} />
              )}
              <span style={{ fontWeight: 500 }}>{callFeedback.message}</span>
            </div>
            <button
              onClick={() => setCallFeedback(null)}
              style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'inherit', padding: 0 }}
            >
              <XCircle size={14} />
            </button>
          </div>
        )}

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
                  onClick={() => {
                    if (step === 'Temp Active' && isUnderVerification) {
                      setShowEditDetails(true);
                    } else {
                      setSelectedStepForModal(step);
                    }
                  }}
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
                  {isCompleted ? `✓ ${step}` : step}
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
              ★ Temporary Active: Review details, edit if required, and approve when verified.
            </div>
          )}
        </div>
      </div>

      {/* Section 9: Detailed Lead Modal & Activity History */}
      {showLeadDetails && (
        <LeadDetailsModal
          isOpen={showLeadDetails}
          vendor={vendor}
          onClose={() => setShowLeadDetails(false)}
        />
      )}

      {/* Edit Vendor Details Modal (Temporary Active Stage) */}
      {showEditDetails && (
        <EditVendorDetailsModal
          isOpen={showEditDetails}
          vendor={vendor}
          onClose={() => setShowEditDetails(false)}
          onSuccess={onRefreshList}
        />
      )}

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
              Are you sure you want to reject <strong>{vendor.businessName || vendor.firstName}</strong>?
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
                  'Yes, Reject'
                )}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};
