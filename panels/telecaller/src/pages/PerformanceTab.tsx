// ============================================================================
// AM5 ROYAL • Tab 0: Performance Overview Tab
// Metrics Cards, Commission Withdrawal Trigger, and Direct Onboarded Vendors
// ============================================================================

import React, { useEffect, useState } from 'react';
import { telecallerApi } from '../api/telecallerApi';
import { TelecallerDashboardStats, TelecallerOnboardedVendor } from '../types';
import { formatCurrency, formatDate, getStatusBadgeClass } from '../utils/formatters';
import { extractErrorMessage } from '../api/client';
import {
  TrendingUp,
  Award,
  Wallet,
  Calendar,
  Store,
  RefreshCw,
  AlertCircle,
  Loader2,
  ChevronDown,
  ArrowUpRight,
} from 'lucide-react';
import { WithdrawalModal } from '../components/withdrawal/WithdrawalModal';

export const PerformanceTab: React.FC = () => {
  const [stats, setStats] = useState<TelecallerDashboardStats | null>(null);
  const [vendors, setVendors] = useState<TelecallerOnboardedVendor[]>([]);
  const [totalVendors, setTotalVendors] = useState(0);
  const [skip, setSkip] = useState(0);
  const limit = 20;

  const [isLoadingStats, setIsLoadingStats] = useState(true);
  const [isLoadingVendors, setIsLoadingVendors] = useState(true);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Date filter state
  const [dateFilter, setDateFilter] = useState<string>('all');
  const [startDate, setStartDate] = useState<string | undefined>();
  const [endDate, setEndDate] = useState<string | undefined>();

  // Withdrawal modal state
  const [isWithdrawalOpen, setIsWithdrawalOpen] = useState(false);

  useEffect(() => {
    fetchStats();
    fetchVendors(true);
  }, []);

  const fetchStats = async () => {
    setIsLoadingStats(true);
    try {
      const data = await telecallerApi.getStats();
      setStats(data);
    } catch (err) {
      console.error('Failed to load stats:', err);
    } finally {
      setIsLoadingStats(false);
    }
  };

  const fetchVendors = async (reset = false, customStart?: string, customEnd?: string) => {
    if (reset) {
      setIsLoadingVendors(true);
      setSkip(0);
    } else {
      setIsLoadingMore(true);
    }
    setError(null);

    const currentSkip = reset ? 0 : skip;
    const effectiveStart = customStart !== undefined ? customStart : startDate;
    const effectiveEnd = customEnd !== undefined ? customEnd : endDate;

    try {
      const response = await telecallerApi.getOnboardedVendors({
        skip: currentSkip,
        limit,
        startDate: effectiveStart,
        endDate: effectiveEnd,
        leadSource: 'direct_telecaller',
      });

      if (reset) {
        setVendors(response.vendors);
      } else {
        setVendors((prev) => [...prev, ...response.vendors]);
      }
      setTotalVendors(response.total);
      if (!reset) {
        setSkip(currentSkip + limit);
      } else {
        setSkip(limit);
      }
    } catch (err) {
      setError(extractErrorMessage(err));
    } finally {
      setIsLoadingVendors(false);
      setIsLoadingMore(false);
    }
  };

  const handleDateFilterSelect = (filter: string) => {
    setDateFilter(filter);
    const now = new Date();
    let start: string | undefined;
    let end: string | undefined = now.toISOString().split('T')[0];

    if (filter === 'today') {
      start = end;
    } else if (filter === 'week') {
      const day = now.getDay() || 7;
      const mon = new Date(now);
      mon.setDate(now.getDate() - day + 1);
      start = mon.toISOString().split('T')[0];
    } else if (filter === 'month') {
      const firstDay = new Date(now.getFullYear(), now.getMonth(), 1);
      start = firstDay.toISOString().split('T')[0];
    } else if (filter === '30days') {
      const past = new Date(now);
      past.setDate(now.getDate() - 30);
      start = past.toISOString().split('T')[0];
    } else {
      start = undefined;
      end = undefined;
    }

    setStartDate(start);
    setEndDate(end);
    fetchVendors(true, start, end);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
      {/* Page Title & Intro */}
      <div>
        <h2 style={{ fontSize: '1.75rem', color: 'var(--text-main)' }}>
          My Performance Overview
        </h2>
        <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem', marginTop: '0.25rem' }}>
          Real-time metrics tracking your direct partner conversions, referral payouts, and commissions.
        </p>
      </div>

      {/* 3 Large KPI Metric Cards */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))',
          gap: '1.25rem',
        }}
      >
        {/* Card 1: Weekly Onboarding */}
        <div className="card" style={{ position: 'relative', overflow: 'hidden' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: '0.85rem', fontWeight: 600, color: 'var(--text-muted)' }}>
              Weekly Onboardings
            </span>
            <div
              style={{
                width: '40px',
                height: '40px',
                borderRadius: '12px',
                background: 'var(--primary-light)',
                color: 'var(--primary)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <TrendingUp size={20} />
            </div>
          </div>
          <div
            style={{
              fontFamily: 'var(--font-heading)',
              fontSize: '2.5rem',
              fontWeight: 800,
              color: 'var(--primary-dark)',
              marginTop: '0.75rem',
            }}
          >
            {isLoadingStats ? '—' : stats?.weeklyOnboardings ?? 0}
          </div>
          <p style={{ fontSize: '0.75rem', color: 'var(--text-subtle)', marginTop: '0.25rem' }}>
            Direct partner registrations achieved this week
          </p>
        </div>

        {/* Card 2: Monthly Conversions & Bonus */}
        <div className="card" style={{ position: 'relative', overflow: 'hidden' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: '0.85rem', fontWeight: 600, color: 'var(--text-muted)' }}>
              Monthly Conversions
            </span>
            <div
              style={{
                width: '40px',
                height: '40px',
                borderRadius: '12px',
                background: 'var(--secondary-light)',
                color: 'var(--secondary)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Award size={20} />
            </div>
          </div>
          <div
            style={{
              fontFamily: 'var(--font-heading)',
              fontSize: '2.5rem',
              fontWeight: 800,
              color: 'var(--secondary)',
              marginTop: '0.75rem',
            }}
          >
            {isLoadingStats ? '—' : stats?.monthlyConversions ?? 0}
          </div>
          <div
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '0.35rem',
              fontSize: '0.75rem',
              color: '#065f46',
              background: 'var(--success-light)',
              padding: '0.2rem 0.5rem',
              borderRadius: '6px',
              fontWeight: 700,
              marginTop: '0.4rem',
            }}
          >
            <span>Payout Bonus: +{formatCurrency(stats?.monthlyPayoutBonus ?? 0)}</span>
          </div>
        </div>

        {/* Card 3: Incentives & Commission Payout */}
        <div
          className="card"
          style={{
            background: 'linear-gradient(135deg, #ffffff 0%, #fffbeb 100%)',
            border: '1.5px solid rgba(245, 158, 11, 0.3)',
            boxShadow: '0 8px 24px -4px rgba(245, 158, 11, 0.15)',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: '0.85rem', fontWeight: 600, color: '#92400e' }}>
              Incentives & Commission
            </span>
            <div
              style={{
                width: '40px',
                height: '40px',
                borderRadius: '12px',
                background: 'var(--gold-light)',
                color: 'var(--gold)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Wallet size={20} />
            </div>
          </div>
          <div
            style={{
              fontFamily: 'var(--font-heading)',
              fontSize: '2.5rem',
              fontWeight: 800,
              color: '#b45309',
              marginTop: '0.75rem',
            }}
          >
            {isLoadingStats ? '—' : formatCurrency(stats?.estimatedReferralPayout ?? 0)}
          </div>
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              marginTop: '0.5rem',
              paddingTop: '0.5rem',
              borderTop: '1px dashed rgba(245, 158, 11, 0.3)',
            }}
          >
            <span style={{ fontSize: '0.75rem', color: '#78350f', fontWeight: 600 }}>
              Withdrawable: {formatCurrency(stats?.withdrawableBalance ?? 0)}
            </span>
            <button
              className="btn btn-sm btn-gold"
              onClick={() => setIsWithdrawalOpen(true)}
              disabled={isLoadingStats || (stats?.withdrawableBalance ?? 0) <= 0}
            >
              <span>Request Payout</span>
              <ArrowUpRight size={14} />
            </button>
          </div>
        </div>
      </div>

      {/* Direct Onboarded Vendors Table Container */}
      <div className="card" style={{ padding: '1.75rem' }}>
        {/* Table Header Controls */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            flexWrap: 'wrap',
            gap: '1rem',
            marginBottom: '1.5rem',
          }}
        >
          <div>
            <h3 style={{ fontSize: '1.2rem', color: 'var(--text-main)' }}>
              Directly Onboarded Vendors
            </h3>
            <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
              Vendors onboarded directly through your telecaller link and portal
            </p>
          </div>

          {/* Date Filter Dropdown */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
            <div className="form-control-wrapper" style={{ minWidth: '180px' }}>
              <select
                className="form-select"
                value={dateFilter}
                onChange={(e) => handleDateFilterSelect(e.target.value)}
                style={{ padding: '0.5rem 0.85rem', fontSize: '0.85rem' }}
              >
                <option value="all">All Time</option>
                <option value="today">Today</option>
                <option value="week">This Week</option>
                <option value="month">This Month</option>
                <option value="30days">Last 30 Days</option>
              </select>
            </div>

            <button
              className="btn btn-sm btn-outline"
              onClick={() => {
                fetchStats();
                fetchVendors(true);
              }}
              title="Refresh Records"
            >
              <RefreshCw size={14} />
              <span>Refresh</span>
            </button>
          </div>
        </div>

        {/* Vendors List Table */}
        {isLoadingVendors ? (
          <div style={{ textAlign: 'center', padding: '4rem 0' }}>
            <Loader2 size={32} className="spinner" color="var(--primary)" />
            <p style={{ marginTop: '0.85rem', color: 'var(--text-muted)', fontSize: '0.875rem' }}>
              Loading onboarded partners...
            </p>
          </div>
        ) : error ? (
          <div
            style={{
              padding: '1.25rem',
              background: 'var(--danger-light)',
              borderRadius: 'var(--radius-md)',
              color: 'var(--danger)',
              display: 'flex',
              alignItems: 'center',
              gap: '0.75rem',
            }}
          >
            <AlertCircle size={20} />
            <span>{error}</span>
          </div>
        ) : vendors.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '4rem 1rem' }}>
            <Store size={40} color="var(--text-subtle)" style={{ margin: '0 auto 0.75rem auto' }} />
            <p style={{ fontWeight: 700, color: 'var(--text-main)', fontSize: '1rem' }}>
              No direct vendors found for this period.
            </p>
            <p style={{ fontSize: '0.825rem', color: 'var(--text-muted)', marginTop: '0.35rem' }}>
              Start registering new partners using the "Add New Vendor" action to build your portfolio.
            </p>
          </div>
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
              <thead>
                <tr style={{ borderBottom: '1.5px solid var(--border-subtle)' }}>
                  <th style={{ padding: '0.75rem 1rem', fontSize: '0.75rem', fontWeight: 700, color: 'var(--text-subtle)', textTransform: 'uppercase' }}>
                    Business & Partner
                  </th>
                  <th style={{ padding: '0.75rem 1rem', fontSize: '0.75rem', fontWeight: 700, color: 'var(--text-subtle)', textTransform: 'uppercase' }}>
                    Mobile Number
                  </th>
                  <th style={{ padding: '0.75rem 1rem', fontSize: '0.75rem', fontWeight: 700, color: 'var(--text-subtle)', textTransform: 'uppercase' }}>
                    City
                  </th>
                  <th style={{ padding: '0.75rem 1rem', fontSize: '0.75rem', fontWeight: 700, color: 'var(--text-subtle)', textTransform: 'uppercase' }}>
                    Date Registered
                  </th>
                  <th style={{ padding: '0.75rem 1rem', fontSize: '0.75rem', fontWeight: 700, color: 'var(--text-subtle)', textTransform: 'uppercase', textAlign: 'right' }}>
                    Status
                  </th>
                </tr>
              </thead>
              <tbody>
                {vendors.map((v) => (
                  <tr
                    key={v.id}
                    style={{
                      borderBottom: '1px solid var(--border-subtle)',
                      transition: 'background 0.15s ease',
                    }}
                    onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = 'var(--bg-subtle)')}
                    onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = 'transparent')}
                  >
                    <td style={{ padding: '1rem' }}>
                      <div style={{ fontWeight: 700, fontSize: '0.925rem', color: 'var(--text-main)' }}>
                        {v.businessName || 'Business Name Pending'}
                      </div>
                      <div style={{ fontSize: '0.775rem', color: 'var(--text-muted)' }}>
                        {v.firstName} {v.lastName}
                      </div>
                    </td>
                    <td style={{ padding: '1rem', fontFamily: 'monospace', fontSize: '0.875rem' }}>
                      {v.mobileNumber}
                    </td>
                    <td style={{ padding: '1rem', fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                      {v.city || '—'}
                    </td>
                    <td style={{ padding: '1rem', fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                      {formatDate(v.createdAt)}
                    </td>
                    <td style={{ padding: '1rem', textAlign: 'right' }}>
                      <span className={`badge ${getStatusBadgeClass(v.status)}`}>
                        {v.status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>

            {/* Load More Button */}
            {vendors.length < totalVendors && (
              <div style={{ textAlign: 'center', marginTop: '1.5rem' }}>
                <button
                  className="btn btn-outline btn-sm"
                  onClick={() => fetchVendors(false)}
                  disabled={isLoadingMore}
                >
                  {isLoadingMore ? (
                    <>
                      <Loader2 size={14} className="spinner" />
                      <span>Loading More Partners...</span>
                    </>
                  ) : (
                    <span>Load More ({totalVendors - vendors.length} remaining)</span>
                  )}
                </button>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Withdrawal Modal */}
      {isWithdrawalOpen && (
        <WithdrawalModal
          isOpen={isWithdrawalOpen}
          withdrawableBalance={stats?.withdrawableBalance ?? 0}
          onClose={() => setIsWithdrawalOpen(false)}
          onWithdrawalSuccess={() => {
            fetchStats();
          }}
        />
      )}
    </div>
  );
};
