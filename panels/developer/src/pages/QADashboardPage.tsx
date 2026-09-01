import React, { useEffect, useState } from 'react';
import { developerApi } from '../api/developerApi';
import { QADashboardStats } from '../types/developer';
import { StatusBadge } from '../components/StatusBadge';
import { SeverityBadge } from '../components/SeverityBadge';
import {
  ShieldAlert,
  Bug,
  CheckCircle2,
  XCircle,
  RotateCcw,
  Clock,
  Plus,
  ArrowRight,
  TrendingDown,
} from 'lucide-react';
import { Link } from 'react-router-dom';
import { CreateBugModal } from './CreateBugModal';

export const QADashboardPage: React.FC = () => {
  const [stats, setStats] = useState<QADashboardStats | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [isCreateBugOpen, setIsCreateBugOpen] = useState<boolean>(false);

  const fetchStats = async () => {
    try {
      const data = await developerApi.getQADashboard();
      setStats(data);
    } catch {
      setError('Failed to fetch QA telemetry.');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchStats();
  }, []);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-20">
        <div className="text-xs font-mono text-[#8B5CF6] animate-pulse">
          LOADING QA QUALITY ASSURANCE TELEMETRY...
        </div>
      </div>
    );
  }

  if (error || !stats) {
    return (
      <div className="p-4 rounded-lg bg-[#FB4B5F]/10 border border-[#FB4B5F]/30 text-xs text-[#FB4B5F]">
        {error || 'Error loading QA telemetry.'}
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="text-lg font-bold text-[#F1F5F9] uppercase tracking-wide flex items-center gap-2">
            <ShieldAlert className="w-5 h-5 text-[#8B5CF6]" /> QA Command & Verification Hub
          </h1>
          <p className="text-xs text-[#94A3B8] font-mono mt-0.5">
            DEFECT AUDITING, VERIFICATION PIPELINE & REOPEN TELEMETRY
          </p>
        </div>
        <button
          onClick={() => setIsCreateBugOpen(true)}
          className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-md text-xs font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] transition"
        >
          <Plus className="w-4 h-4" />
          Log New Defect
        </button>
      </div>

      {/* KPI Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Awaiting QA Verification */}
        <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247] flex items-center justify-between">
          <div>
            <div className="text-[11px] font-mono uppercase text-[#94A3B8]">Awaiting QA Testing</div>
            <div className="text-2xl font-bold font-mono text-[#FBBF24] mt-1">
              {stats.bugs_awaiting_qa_count}
            </div>
            <div className="text-[10px] text-[#FBBF24] font-mono mt-0.5">
              Ready for Verification
            </div>
          </div>
          <div className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] text-[#FBBF24]">
            <Clock className="w-5 h-5" />
          </div>
        </div>

        {/* Under QA Testing */}
        <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247] flex items-center justify-between">
          <div>
            <div className="text-[11px] font-mono uppercase text-[#94A3B8]">Currently Testing</div>
            <div className="text-2xl font-bold font-mono text-[#38BDF8] mt-1">
              {stats.under_qa_testing_count}
            </div>
            <div className="text-[10px] text-[#38BDF8] font-mono mt-0.5">In Test Runs</div>
          </div>
          <div className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] text-[#38BDF8]">
            <ShieldAlert className="w-5 h-5" />
          </div>
        </div>

        {/* Verified Defect Ratio */}
        <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247] flex items-center justify-between">
          <div>
            <div className="text-[11px] font-mono uppercase text-[#94A3B8]">Verified Passed</div>
            <div className="text-2xl font-bold font-mono text-[#34D399] mt-1">
              {stats.verified_bugs_count}
            </div>
            <div className="text-[10px] text-[#34D399] font-mono mt-0.5">Ready for release</div>
          </div>
          <div className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] text-[#34D399]">
            <CheckCircle2 className="w-5 h-5" />
          </div>
        </div>

        {/* Reopen Rate */}
        <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247] flex items-center justify-between">
          <div>
            <div className="text-[11px] font-mono uppercase text-[#94A3B8]">Reopen / Reject Rate</div>
            <div className="text-2xl font-bold font-mono text-[#FB4B5F] mt-1">
              {stats.reopen_rate_percent}%
            </div>
            <div className="text-[10px] text-[#FB4B5F] font-mono mt-0.5">
              {stats.reopened_bugs_count} Reopened Defects
            </div>
          </div>
          <div className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] text-[#FB4B5F]">
            <RotateCcw className="w-5 h-5" />
          </div>
        </div>
      </div>

      {/* Bugs Awaiting Verification Table */}
      <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
        <div className="flex items-center justify-between border-b border-[#263247] pb-3">
          <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
            Defects Awaiting QA Test Execution
          </h2>
          <span className="text-xs font-mono text-[#FBBF24]">
            {stats.awaiting_verification_bugs?.length || 0} Pending Runs
          </span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="border-b border-[#263247] text-[#94A3B8] font-mono uppercase text-[11px]">
                <th className="pb-2.5">Code</th>
                <th className="pb-2.5">Title</th>
                <th className="pb-2.5">Severity</th>
                <th className="pb-2.5">Assigned Developer</th>
                <th className="pb-2.5">Current Status</th>
                <th className="pb-2.5 text-right">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#263247]/60">
              {stats.awaiting_verification_bugs && stats.awaiting_verification_bugs.length > 0 ? (
                stats.awaiting_verification_bugs.map((bug) => (
                  <tr key={bug.id} className="hover:bg-[#151E2E]/60 transition">
                    <td className="py-3 font-mono font-bold text-[#22D3EE]">{bug.bug_code}</td>
                    <td className="py-3 font-medium text-[#F1F5F9] max-w-xs truncate">{bug.title}</td>
                    <td className="py-3">
                      <SeverityBadge severity={bug.severity} />
                    </td>
                    <td className="py-3 font-mono text-[#94A3B8]">
                      {bug.developer_name || 'Unassigned'}
                    </td>
                    <td className="py-3">
                      <StatusBadge status={bug.status} size="sm" />
                    </td>
                    <td className="py-3 text-right">
                      <Link
                        to={`/bugs/${bug.id}`}
                        className="inline-flex items-center gap-1 text-[11px] font-semibold text-[#22D3EE] hover:underline"
                      >
                        Inspect & Verify <ArrowRight className="w-3 h-3" />
                      </Link>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={6} className="py-8 text-center text-[#94A3B8] font-mono">
                    No defects currently awaiting QA test execution. All caught up!
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Developer Breakdown & Module Breakdown */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Developer Wise Open Defects */}
        <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
          <div className="flex items-center justify-between border-b border-[#263247] pb-3">
            <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
              Developer Active Bug Distribution
            </h2>
          </div>

          <div className="space-y-3">
            {stats.developer_wise_bugs && stats.developer_wise_bugs.length > 0 ? (
              stats.developer_wise_bugs.map((d) => (
                <div
                  key={d.developer_id}
                  className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] flex items-center justify-between"
                >
                  <span className="text-xs font-medium text-[#F1F5F9]">{d.developer_name}</span>
                  <span
                    className={`text-xs font-mono font-bold px-2 py-0.5 rounded ${
                      d.open_bugs > 3
                        ? 'bg-[#FB4B5F]/20 text-[#FB4B5F] border border-[#FB4B5F]/30'
                        : 'bg-[#22D3EE]/20 text-[#22D3EE] border border-[#22D3EE]/30'
                    }`}
                  >
                    {d.open_bugs} Open Defects
                  </span>
                </div>
              ))
            ) : (
              <div className="text-center py-6 text-xs text-[#94A3B8]">
                No developer bug metrics available.
              </div>
            )}
          </div>
        </div>

        {/* Module Wise Open Defects */}
        <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
          <div className="flex items-center justify-between border-b border-[#263247] pb-3">
            <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
              Module Defect Concentration
            </h2>
          </div>

          <div className="space-y-3">
            {stats.module_wise_bugs && stats.module_wise_bugs.length > 0 ? (
              stats.module_wise_bugs.map((m) => (
                <div
                  key={m.module_id}
                  className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] flex items-center justify-between"
                >
                  <span className="text-xs font-medium text-[#F1F5F9]">{m.module_name}</span>
                  <span className="text-xs font-mono font-bold text-[#F1F5F9]">
                    {m.open_bugs} Bugs
                  </span>
                </div>
              ))
            ) : (
              <div className="text-center py-6 text-xs text-[#94A3B8]">
                No module defect metrics available.
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Create Bug Modal */}
      <CreateBugModal
        isOpen={isCreateBugOpen}
        onClose={() => setIsCreateBugOpen(false)}
        onBugCreated={() => {
          setIsCreateBugOpen(false);
          fetchStats();
        }}
      />
    </div>
  );
};
