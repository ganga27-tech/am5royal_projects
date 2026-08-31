// ============================================================================
// AM5 ROYAL • My Performance Tab (Section 12 Specification)
// Detailed Individual Lead Performance: Source Breakdown, Funnel, Conversion Rate & Table
// ============================================================================

import React, { useEffect, useState } from 'react';
import { telecallerApi } from '../api/telecallerApi';
import { LeadPerformanceMetrics, TelecallerDashboardStats } from '../types';
import { formatCurrency } from '../utils/formatters';
import {
  TrendingUp,
  Target,
  Users,
  Globe,
  Smartphone,
  Briefcase,
  UserCheck,
  PhoneForwarded,
  Hourglass,
  Award,
  CheckCircle2,
  XCircle,
  Percent,
  Wallet,
  RefreshCw,
  Loader2,
} from 'lucide-react';
import { WithdrawalModal } from '../components/withdrawal/WithdrawalModal';

export const MyPerformanceTab: React.FC = () => {
  const [metrics, setMetrics] = useState<LeadPerformanceMetrics | null>(null);
  const [stats, setStats] = useState<TelecallerDashboardStats | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isWithdrawalOpen, setIsWithdrawalOpen] = useState(false);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setIsLoading(true);
    try {
      const [m, s] = await Promise.all([
        telecallerApi.getLeadPerformance(),
        telecallerApi.getStats(),
      ]);
      setMetrics(m);
      setStats(s);
    } catch {
      // Handled in telecallerApi fallback
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading || !metrics) {
    return (
      <div style={{ padding: '4rem', textAlign: 'center' }}>
        <Loader2 size={32} className="spinner" style={{ margin: '0 auto 1rem auto' }} />
        <p style={{ color: 'var(--text-muted)' }}>Loading individual performance metrics...</p>
      </div>
    );
  }

  const tableRows = [
    { metric: 'Total Leads', count: metrics.total_leads, icon: Users, color: 'var(--primary)' },
    { metric: 'Website Leads', count: metrics.website_leads, icon: Globe, color: '#0284c7' },
    { metric: 'Application Leads', count: metrics.application_leads, icon: Smartphone, color: '#7c3aed' },
    { metric: 'Freelancer Leads', count: metrics.freelancer_leads, icon: Briefcase, color: '#d97706' },
    { metric: 'Assigned Leads', count: metrics.assigned_leads, icon: UserCheck, color: '#059669' },
    { metric: 'Contacted Leads', count: metrics.contacted_leads, icon: PhoneForwarded, color: '#0891b2' },
    { metric: 'Leads In Progress', count: metrics.in_progress_leads, icon: Hourglass, color: '#eab308' },
    { metric: 'Converted Leads', count: metrics.converted_leads, icon: Award, color: '#16a34a' },
    { metric: 'Activated Vendors', count: metrics.activated_vendors, icon: CheckCircle2, color: '#10b981' },
    { metric: 'Pending Leads', count: metrics.pending_leads, icon: Hourglass, color: '#f59e0b' },
    { metric: 'Closed Leads', count: metrics.closed_leads, icon: XCircle, color: '#64748b' },
  ];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '1.75rem' }}>
      {/* Title Bar */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          flexWrap: 'wrap',
          gap: '1rem',
        }}
      >
        <div>
          <h2 style={{ fontSize: '1.75rem', color: 'var(--text-main)' }}>My Performance Console</h2>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem', marginTop: '0.25rem' }}>
            Section 12 Lead metrics, conversion performance, and operations payout status.
          </p>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          <button
            className="btn btn-outline"
            onClick={() => setIsWithdrawalOpen(true)}
            style={{ fontSize: '0.85rem' }}
          >
            <Wallet size={15} />
            <span>Withdraw Earnings (₹{stats?.withdrawableBalance.toFixed(0) || '0'})</span>
          </button>
          <button className="btn btn-outline" onClick={loadData} title="Refresh Metrics" style={{ padding: '0.6rem' }}>
            <RefreshCw size={16} />
          </button>
        </div>
      </div>

      {/* Top 4 KPI Highlights */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
          gap: '1rem',
        }}
      >
        {/* Total Leads */}
        <div className="card" style={{ padding: '1.25rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: '0.75rem', color: 'var(--text-subtle)', fontWeight: 600, textTransform: 'uppercase' }}>
              Total Leads Handled
            </span>
            <Users size={18} color="var(--primary)" />
          </div>
          <div style={{ fontSize: '1.85rem', fontWeight: 800, color: 'var(--text-main)', marginTop: '0.4rem' }}>
            {metrics.total_leads}
          </div>
          <div style={{ fontSize: '0.725rem', color: 'var(--text-muted)', marginTop: '0.25rem' }}>
            Web: {metrics.website_leads} • App: {metrics.application_leads} • Free: {metrics.freelancer_leads}
          </div>
        </div>

        {/* Contacted */}
        <div className="card" style={{ padding: '1.25rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: '0.75rem', color: 'var(--text-subtle)', fontWeight: 600, textTransform: 'uppercase' }}>
              Leads Contacted
            </span>
            <PhoneForwarded size={18} color="#0891b2" />
          </div>
          <div style={{ fontSize: '1.85rem', fontWeight: 800, color: '#0891b2', marginTop: '0.4rem' }}>
            {metrics.contacted_leads}
          </div>
          <div style={{ fontSize: '0.725rem', color: 'var(--text-muted)', marginTop: '0.25rem' }}>
            {metrics.assigned_leads} assigned to your desk
          </div>
        </div>

        {/* Activated Partners */}
        <div className="card" style={{ padding: '1.25rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: '0.75rem', color: 'var(--text-subtle)', fontWeight: 600, textTransform: 'uppercase' }}>
              Activated Partners
            </span>
            <CheckCircle2 size={18} color="#10b981" />
          </div>
          <div style={{ fontSize: '1.85rem', fontWeight: 800, color: '#10b981', marginTop: '0.4rem' }}>
            {metrics.activated_vendors}
          </div>
          <div style={{ fontSize: '0.725rem', color: 'var(--text-muted)', marginTop: '0.25rem' }}>
            {metrics.converted_leads} total converted
          </div>
        </div>

        {/* Conversion Rate */}
        <div className="card" style={{ padding: '1.25rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: '0.75rem', color: 'var(--text-subtle)', fontWeight: 600, textTransform: 'uppercase' }}>
              Conversion Rate
            </span>
            <Percent size={18} color="var(--primary)" />
          </div>
          <div style={{ fontSize: '1.85rem', fontWeight: 800, color: 'var(--primary)', marginTop: '0.4rem' }}>
            {metrics.conversion_rate}%
          </div>
          <div
            style={{
              height: '6px',
              borderRadius: '9999px',
              background: '#e2e8f0',
              marginTop: '0.5rem',
              overflow: 'hidden',
            }}
          >
            <div
              style={{
                width: `${Math.min(100, metrics.conversion_rate * 2.5)}%`,
                height: '100%',
                background: 'linear-gradient(90deg, var(--primary) 0%, var(--secondary) 100%)',
                borderRadius: '9999px',
              }}
            />
          </div>
        </div>
      </div>

      {/* Main Section 12 Specification Table */}
      <div className="card" style={{ padding: '1.5rem' }}>
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            marginBottom: '1.25rem',
          }}
        >
          <div>
            <h3 style={{ fontSize: '1.1rem', color: 'var(--text-main)' }}>
              Section 12 • Individual Lead Metric Breakdown
            </h3>
            <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: '0.15rem' }}>
              Standard lead conversion audit table as defined in the operations specification.
            </p>
          </div>

          <span
            style={{
              fontFamily: 'var(--font-heading)',
              fontSize: '0.75rem',
              fontWeight: 700,
              padding: '0.25rem 0.75rem',
              borderRadius: '9999px',
              background: 'var(--primary-light)',
              color: 'var(--primary)',
            }}
          >
            Conversion Rate: {metrics.conversion_rate}%
          </span>
        </div>

        <div style={{ overflowX: 'auto' }}>
          <table className="table" style={{ width: '100%' }}>
            <thead>
              <tr>
                <th style={{ width: '50px' }}>#</th>
                <th>Metric Name</th>
                <th style={{ textAlign: 'center', width: '180px' }}>Count</th>
                <th style={{ textAlign: 'right', width: '220px' }}>Share of Total</th>
              </tr>
            </thead>
            <tbody>
              {tableRows.map((row, idx) => {
                const Icon = row.icon;
                const sharePercent =
                  metrics.total_leads > 0
                    ? ((row.count / metrics.total_leads) * 100).toFixed(1)
                    : '0';

                return (
                  <tr key={row.metric}>
                    <td style={{ color: 'var(--text-subtle)', fontSize: '0.75rem', fontWeight: 600 }}>
                      {idx + 1}
                    </td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem' }}>
                        <div
                          style={{
                            width: '28px',
                            height: '28px',
                            borderRadius: '8px',
                            background: 'var(--bg-subtle)',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                          }}
                        >
                          <Icon size={15} color={row.color} />
                        </div>
                        <span style={{ fontWeight: 600, color: 'var(--text-main)', fontSize: '0.875rem' }}>
                          {row.metric}
                        </span>
                      </div>
                    </td>
                    <td style={{ textAlign: 'center' }}>
                      <span
                        style={{
                          fontFamily: 'monospace',
                          fontSize: '1rem',
                          fontWeight: 700,
                          color: 'var(--text-main)',
                        }}
                      >
                        {row.count}
                      </span>
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', gap: '0.5rem' }}>
                        <span style={{ fontSize: '0.775rem', color: 'var(--text-muted)' }}>
                          {sharePercent}%
                        </span>
                        <div
                          style={{
                            width: '80px',
                            height: '5px',
                            borderRadius: '9999px',
                            background: '#e2e8f0',
                            overflow: 'hidden',
                          }}
                        >
                          <div
                            style={{
                              width: `${Math.min(100, Number(sharePercent))}%`,
                              height: '100%',
                              background: row.color,
                              borderRadius: '9999px',
                            }}
                          />
                        </div>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>

      {/* Withdrawal Modal */}
      {isWithdrawalOpen && (
        <WithdrawalModal
          isOpen={isWithdrawalOpen}
          onClose={() => setIsWithdrawalOpen(false)}
          withdrawableBalance={stats?.withdrawableBalance || 0}
          onWithdrawalSuccess={loadData}
        />
      )}
    </div>
  );
};
