// ============================================================================
// AM5 ROYAL • Withdrawal History Modal
// Tracks previous payout requests and processing statuses
// ============================================================================

import React, { useEffect, useState } from 'react';
import { vendorActionsApi } from '../../api/vendorActionsApi';
import { WithdrawalRequest } from '../../types';
import { formatCurrency, formatDate } from '../../utils/formatters';
import { extractErrorMessage } from '../../api/client';
import { X, History, Clock, CheckCircle, XCircle, AlertCircle, Loader2 } from 'lucide-react';

interface WithdrawalHistoryModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const WithdrawalHistoryModal: React.FC<WithdrawalHistoryModalProps> = ({
  isOpen,
  onClose,
}) => {
  const [history, setHistory] = useState<WithdrawalRequest[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (isOpen) {
      fetchHistory();
    }
  }, [isOpen]);

  const fetchHistory = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const data = await vendorActionsApi.getWithdrawals();
      setHistory(data);
    } catch (err) {
      setError(extractErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 120,
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
          maxHeight: '85vh',
          display: 'flex',
          flexDirection: 'column',
          padding: 0,
          overflow: 'hidden',
          animation: 'fadeInDown 0.25s ease-out',
        }}
      >
        {/* Header */}
        <div
          style={{
            padding: '1.25rem 1.5rem',
            borderBottom: '1px solid var(--border-subtle)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            background: 'var(--bg-subtle)',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem' }}>
            <History size={20} color="var(--primary)" />
            <h3 style={{ fontSize: '1.15rem', color: 'var(--text-main)' }}>Withdrawal History</h3>
          </div>
          <button
            onClick={onClose}
            style={{
              background: 'transparent',
              border: 'none',
              cursor: 'pointer',
              color: 'var(--text-muted)',
            }}
          >
            <X size={20} />
          </button>
        </div>

        {/* Content */}
        <div style={{ padding: '1.5rem', overflowY: 'auto', flex: 1 }}>
          {isLoading ? (
            <div style={{ textAlign: 'center', padding: '3rem 0' }}>
              <Loader2 size={32} className="spinner" color="var(--primary)" />
              <p style={{ marginTop: '0.85rem', color: 'var(--text-muted)', fontSize: '0.875rem' }}>
                Fetching your withdrawal history...
              </p>
            </div>
          ) : error ? (
            <div
              style={{
                padding: '1rem',
                background: 'var(--danger-light)',
                borderRadius: 'var(--radius-md)',
                color: 'var(--danger)',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
              }}
            >
              <AlertCircle size={18} />
              <span>{error}</span>
            </div>
          ) : history.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '3rem 1rem' }}>
              <History size={40} color="var(--text-subtle)" style={{ margin: '0 auto 0.75rem auto' }} />
              <p style={{ fontWeight: 600, color: 'var(--text-muted)' }}>No withdrawal requests found.</p>
              <p style={{ fontSize: '0.8rem', color: 'var(--text-subtle)', marginTop: '0.25rem' }}>
                When you request commission payouts, your tracking records will appear here.
              </p>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.85rem' }}>
              {history.map((req) => {
                const isPending = req.status === 'pending';
                const isApproved = req.status === 'approved' || req.status === 'completed';
                const isRejected = req.status === 'rejected';

                return (
                  <div
                    key={req.id}
                    style={{
                      padding: '1rem 1.25rem',
                      borderRadius: 'var(--radius-md)',
                      border: '1px solid var(--border-subtle)',
                      background: 'var(--bg-surface)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      boxShadow: 'var(--shadow-sm)',
                    }}
                  >
                    <div>
                      <div
                        style={{
                          fontFamily: 'var(--font-heading)',
                          fontSize: '1.15rem',
                          fontWeight: 800,
                          color: 'var(--text-main)',
                        }}
                      >
                        {formatCurrency(req.amount)}
                      </div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '0.15rem' }}>
                        Requested on: {formatDate(req.created_at)}
                      </div>
                      {isPending && (
                        <div
                          style={{
                            fontSize: '0.725rem',
                            color: '#b45309',
                            fontWeight: 600,
                            marginTop: '0.35rem',
                          }}
                        >
                          initiated amount will be credited in 30 min - 24hrs
                        </div>
                      )}
                      {isRejected && req.admin_notes && (
                        <div style={{ fontSize: '0.725rem', color: 'var(--danger)', marginTop: '0.25rem' }}>
                          Reason: {req.admin_notes}
                        </div>
                      )}
                    </div>

                    <div style={{ textAlign: 'right' }}>
                      {isPending && (
                        <span
                          className="badge"
                          style={{
                            background: 'var(--warning-light)',
                            color: '#92400e',
                            border: '1px solid #fcd34d',
                          }}
                        >
                          <Clock size={12} />
                          <span>Processing</span>
                        </span>
                      )}
                      {isApproved && (
                        <span className="badge badge-active">
                          <CheckCircle size={12} />
                          <span>Sent</span>
                        </span>
                      )}
                      {isRejected && (
                        <span className="badge badge-rejected">
                          <XCircle size={12} />
                          <span>Rejected</span>
                        </span>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {/* Footer */}
        <div
          style={{
            padding: '1rem 1.5rem',
            borderTop: '1px solid var(--border-subtle)',
            display: 'flex',
            justifyContent: 'flex-end',
            background: 'var(--bg-subtle)',
          }}
        >
          <button className="btn btn-outline" onClick={onClose}>
            Close
          </button>
        </div>
      </div>
    </div>
  );
};
