// ============================================================================
// AM5 ROYAL • Withdrawal Request Modal
// Validates Payout Balance, Bank Details Status, and Dispatches Withdrawal
// ============================================================================

import React, { useState } from 'react';
import { useAuth } from '../../auth/AuthContext';
import { vendorActionsApi } from '../../api/vendorActionsApi';
import { Validation } from '../../utils/validation';
import { formatCurrency } from '../../utils/formatters';
import { extractErrorMessage } from '../../api/client';
import {
  X,
  Wallet,
  AlertTriangle,
  CheckCircle2,
  Building,
  History,
  Loader2,
  ArrowRight,
} from 'lucide-react';
import { WithdrawalHistoryModal } from './WithdrawalHistoryModal';
import { EditProfileModal } from '../profile/EditProfileModal';

interface WithdrawalModalProps {
  isOpen: boolean;
  onClose: () => void;
  withdrawableBalance: number;
  onWithdrawalSuccess?: () => void;
}

export const WithdrawalModal: React.FC<WithdrawalModalProps> = ({
  isOpen,
  onClose,
  withdrawableBalance,
  onWithdrawalSuccess,
}) => {
  const { user } = useAuth();
  const [amount, setAmount] = useState<string>(
    withdrawableBalance > 0 ? String(Math.floor(withdrawableBalance)) : ''
  );
  const [amountError, setAmountError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [serverError, setServerError] = useState<string | null>(null);
  const [successNotice, setSuccessNotice] = useState<string | null>(null);

  // Secondary modals
  const [showHistory, setShowHistory] = useState(false);
  const [showEditBank, setShowEditBank] = useState(false);

  if (!isOpen) return null;

  const hasBankDetails = Boolean(
    user?.bankName?.trim() &&
    user?.bankAccountNumber?.trim() &&
    user?.bankIfscCode?.trim()
  );

  const handleAmountChange = (val: string) => {
    setAmount(val);
    const check = Validation.amount(val, withdrawableBalance);
    setAmountError(check.isValid ? null : check.error || 'Invalid amount');
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setServerError(null);

    const check = Validation.amount(amount, withdrawableBalance);
    if (!check.isValid) {
      setAmountError(check.error || 'Please enter a valid withdrawal amount');
      return;
    }

    if (!hasBankDetails) {
      setServerError('Please add your bank account details before requesting a withdrawal.');
      return;
    }

    setIsSubmitting(true);
    try {
      await vendorActionsApi.requestWithdrawal(parseFloat(amount));
      setSuccessNotice('Initiated! Amount will be credited to your bank account within 30 min - 24 hrs.');
      if (onWithdrawalSuccess) onWithdrawalSuccess();
      setTimeout(() => {
        onClose();
      }, 2500);
    } catch (err) {
      setServerError(extractErrorMessage(err));
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <>
      <div
        style={{
          position: 'fixed',
          inset: 0,
          zIndex: 100,
          background: 'rgba(15, 23, 42, 0.5)',
          backdropFilter: 'blur(6px)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          padding: '1.5rem',
        }}
      >
        <div
          className="card"
          style={{
            width: '100%',
            maxWidth: '520px',
            padding: 0,
            overflow: 'hidden',
            animation: 'fadeInDown 0.25s ease-out',
          }}
        >
          {/* Modal Header */}
          <div
            style={{
              padding: '1.25rem 1.5rem',
              borderBottom: '1px solid var(--border-subtle)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              background: 'linear-gradient(135deg, #fffbeb 0%, #ffffff 100%)',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem' }}>
              <div
                style={{
                  width: '36px',
                  height: '36px',
                  borderRadius: '10px',
                  background: 'var(--gold-light)',
                  color: 'var(--gold)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <Wallet size={20} />
              </div>
              <div>
                <h3 style={{ fontSize: '1.15rem', color: '#92400e' }}>
                  Commission & Incentive Withdrawal
                </h3>
                <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                  Transfer your earned referral points to your linked bank account
                </p>
              </div>
            </div>
            <button
              onClick={onClose}
              style={{
                background: 'transparent',
                border: 'none',
                cursor: 'pointer',
                color: 'var(--text-muted)',
                padding: '0.25rem',
              }}
            >
              <X size={20} />
            </button>
          </div>

          <div style={{ padding: '1.5rem' }}>
            {/* Balance Card */}
            <div
              style={{
                padding: '1.25rem',
                borderRadius: 'var(--radius-md)',
                background: 'linear-gradient(135deg, #1e1b4b 0%, #312e81 100%)',
                color: 'white',
                marginBottom: '1.25rem',
                boxShadow: '0 8px 24px -6px rgba(49, 46, 129, 0.4)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
              }}
            >
              <div>
                <div style={{ fontSize: '0.8rem', color: '#c7d2fe', fontWeight: 600 }}>
                  Available Withdrawable Balance
                </div>
                <div
                  style={{
                    fontFamily: 'var(--font-heading)',
                    fontSize: '2rem',
                    fontWeight: 800,
                    color: '#fef08a',
                    marginTop: '0.25rem',
                  }}
                >
                  {formatCurrency(withdrawableBalance)}
                </div>
              </div>

              <button
                type="button"
                className="btn btn-sm btn-outline"
                style={{
                  background: 'rgba(255, 255, 255, 0.12)',
                  borderColor: 'rgba(255, 255, 255, 0.2)',
                  color: 'white',
                }}
                onClick={() => setShowHistory(true)}
              >
                <History size={14} />
                <span>History</span>
              </button>
            </div>

            {/* Error or Success Alert */}
            {serverError && (
              <div
                style={{
                  padding: '0.75rem 1rem',
                  background: 'var(--danger-light)',
                  border: '1px solid var(--danger-border)',
                  borderRadius: 'var(--radius-md)',
                  color: 'var(--danger)',
                  fontSize: '0.85rem',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.5rem',
                  marginBottom: '1rem',
                }}
              >
                <AlertTriangle size={18} />
                <span>{serverError}</span>
              </div>
            )}

            {successNotice && (
              <div
                style={{
                  padding: '0.85rem 1rem',
                  background: 'var(--success-light)',
                  border: '1px solid var(--success)',
                  borderRadius: 'var(--radius-md)',
                  color: '#065f46',
                  fontSize: '0.85rem',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.5rem',
                  marginBottom: '1rem',
                  fontWeight: 600,
                }}
              >
                <CheckCircle2 size={18} color="var(--success)" />
                <span>{successNotice}</span>
              </div>
            )}

            {/* Bank Details Check */}
            {!hasBankDetails ? (
              <div
                style={{
                  padding: '1rem',
                  background: 'var(--warning-light)',
                  border: '1px solid #fde68a',
                  borderRadius: 'var(--radius-md)',
                  marginBottom: '1.25rem',
                }}
              >
                <div style={{ display: 'flex', gap: '0.65rem' }}>
                  <AlertTriangle size={20} color="var(--gold)" flex-shrink={0} />
                  <div>
                    <div style={{ fontWeight: 700, fontSize: '0.875rem', color: '#92400e' }}>
                      Bank Account Details Missing
                    </div>
                    <p style={{ fontSize: '0.775rem', color: '#78350f', margin: '0.25rem 0 0.75rem 0' }}>
                      Please provide your bank account number and IFSC code so we can deposit your withdrawal.
                    </p>
                    <button
                      type="button"
                      className="btn btn-sm btn-gold"
                      onClick={() => setShowEditBank(true)}
                    >
                      <Building size={14} />
                      <span>Add Bank Details Now</span>
                    </button>
                  </div>
                </div>
              </div>
            ) : (
              /* Bank Snapshot */
              <div
                style={{
                  padding: '0.85rem 1rem',
                  background: 'var(--bg-subtle)',
                  borderRadius: 'var(--radius-md)',
                  border: '1px solid var(--border-subtle)',
                  marginBottom: '1.25rem',
                }}
              >
                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    marginBottom: '0.5rem',
                  }}
                >
                  <span style={{ fontSize: '0.75rem', fontWeight: 700, color: 'var(--text-muted)' }}>
                    CREDIT DESTINATION
                  </span>
                  <button
                    type="button"
                    style={{
                      background: 'none',
                      border: 'none',
                      color: 'var(--primary)',
                      fontSize: '0.75rem',
                      fontWeight: 600,
                      cursor: 'pointer',
                    }}
                    onClick={() => setShowEditBank(true)}
                  >
                    Change Account
                  </button>
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.5rem', fontSize: '0.8rem' }}>
                  <div>
                    <span style={{ color: 'var(--text-subtle)' }}>Holder: </span>
                    <span style={{ fontWeight: 600 }}>{user?.bankAccountName || `${user?.firstName} ${user?.lastName}`}</span>
                  </div>
                  <div>
                    <span style={{ color: 'var(--text-subtle)' }}>Bank: </span>
                    <span style={{ fontWeight: 600 }}>{user?.bankName}</span>
                  </div>
                  <div>
                    <span style={{ color: 'var(--text-subtle)' }}>A/C: </span>
                    <span style={{ fontWeight: 600, fontFamily: 'monospace' }}>•••• {user?.bankAccountNumber?.slice(-4)}</span>
                  </div>
                  <div>
                    <span style={{ color: 'var(--text-subtle)' }}>IFSC: </span>
                    <span style={{ fontWeight: 600, fontFamily: 'monospace' }}>{user?.bankIfscCode}</span>
                  </div>
                </div>
              </div>
            )}

            {/* Withdrawal Form */}
            <form onSubmit={handleSubmit}>
              <div className="form-group">
                <label className="form-label">
                  Withdrawal Amount (₹) <span className="required-star">*</span>
                </label>
                <div className="form-control-wrapper">
                  <span className="input-icon-left" style={{ fontWeight: 700, color: 'var(--text-main)' }}>
                    ₹
                  </span>
                  <input
                    type="number"
                    className={`form-input has-left-icon ${amountError ? 'is-invalid' : ''}`}
                    placeholder="Enter amount to withdraw"
                    value={amount}
                    onChange={(e) => handleAmountChange(e.target.value)}
                    disabled={isSubmitting || withdrawableBalance <= 0 || !hasBankDetails}
                    step="1"
                    min="1"
                    max={withdrawableBalance}
                  />
                </div>
                {amountError ? (
                  <div className="form-error-msg">{amountError}</div>
                ) : (
                  <div className="form-help-text">
                    Max eligible right now: {formatCurrency(withdrawableBalance)}
                  </div>
                )}
              </div>

              {/* Action Buttons */}
              <div
                style={{
                  display: 'flex',
                  justifyContent: 'flex-end',
                  gap: '0.75rem',
                  marginTop: '1.5rem',
                  paddingTop: '1rem',
                  borderTop: '1px solid var(--border-subtle)',
                }}
              >
                <button type="button" className="btn btn-outline" onClick={onClose} disabled={isSubmitting}>
                  Cancel
                </button>
                <button
                  type="submit"
                  className="btn btn-gold"
                  disabled={
                    isSubmitting ||
                    withdrawableBalance <= 0 ||
                    !hasBankDetails ||
                    Boolean(amountError) ||
                    !amount
                  }
                >
                  {isSubmitting ? (
                    <>
                      <Loader2 size={16} className="spinner" />
                      <span>Processing Request...</span>
                    </>
                  ) : (
                    <>
                      <span>Submit Withdrawal Request</span>
                      <ArrowRight size={16} />
                    </>
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>

      {/* History Modal */}
      {showHistory && (
        <WithdrawalHistoryModal isOpen={showHistory} onClose={() => setShowHistory(false)} />
      )}

      {/* Edit Bank Profile Modal */}
      {showEditBank && (
        <EditProfileModal isOpen={showEditBank} onClose={() => setShowEditBank(false)} />
      )}
    </>
  );
};
