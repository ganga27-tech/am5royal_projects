import React, { useEffect, useState } from 'react';
import { developerApi } from '../api/developerApi';
import { AuditLog } from '../types/developer';
import { ScrollText, Search, Filter, ShieldCheck, CheckCircle } from 'lucide-react';

export const AuditLogsPage: React.FC = () => {
  const [logs, setLogs] = useState<AuditLog[]>([]);
  const [actionFilter, setActionFilter] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(true);

  const fetchLogs = async () => {
    setIsLoading(true);
    try {
      const data = await developerApi.listAuditLogs(actionFilter || undefined, 50);
      setLogs(data);
    } catch {
      // ignore
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchLogs();
  }, [actionFilter]);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="text-lg font-bold text-[#F1F5F9] uppercase tracking-wide flex items-center gap-2">
            <ScrollText className="w-5 h-5 text-[#22D3EE]" /> Operational Audit Trail
          </h1>
          <p className="text-xs text-[#94A3B8] font-mono mt-0.5">
            COMPREHENSIVE IMMUTABLE LOG OF STATE TRANSITIONS, DEPLOYMENTS & MUTATIONS
          </p>
        </div>

        <div className="flex items-center gap-2">
          <select
            value={actionFilter}
            onChange={(e) => setActionFilter(e.target.value)}
            className="rounded bg-[#151E2E] border border-[#263247] px-3 py-1.5 text-xs text-[#F1F5F9] font-mono focus:outline-none focus:border-[#22D3EE]"
          >
            <option value="">All Audit Actions</option>
            <option value="BUG_CREATED">BUG CREATED</option>
            <option value="BUG_TRANSITION">BUG TRANSITION</option>
            <option value="BUG_ASSIGNED">BUG ASSIGNED</option>
            <option value="COMMENT_ADDED">COMMENT ADDED</option>
            <option value="DEPLOYMENT_RECORDED">DEPLOYMENT RECORDED</option>
          </select>
        </div>
      </div>

      {/* Logs Table */}
      <div className="rounded-lg bg-[#0E1420] border border-[#263247] overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs font-mono">
            <thead>
              <tr className="border-b border-[#263247] bg-[#151E2E]/60 text-[#94A3B8] uppercase text-[11px]">
                <th className="px-4 py-3">Timestamp</th>
                <th className="px-4 py-3">Actor / Principal</th>
                <th className="px-4 py-3">Role</th>
                <th className="px-4 py-3">Action Type</th>
                <th className="px-4 py-3">Resource</th>
                <th className="px-4 py-3">Event Detail</th>
                <th className="px-4 py-3 text-right">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#263247]/60 text-[11px]">
              {isLoading ? (
                <tr>
                  <td colSpan={7} className="py-12 text-center text-[#22D3EE] animate-pulse">
                    QUERYING AUDIT STORAGE...
                  </td>
                </tr>
              ) : logs && logs.length > 0 ? (
                logs.map((log) => (
                  <tr key={log.id} className="hover:bg-[#151E2E]/60 transition">
                    <td className="px-4 py-2.5 text-[#475569] whitespace-nowrap">
                      {new Date(log.created_at).toLocaleString()}
                    </td>
                    <td className="px-4 py-2.5 font-bold text-[#F1F5F9] whitespace-nowrap">
                      {log.actor_name || 'System Operator'}
                    </td>
                    <td className="px-4 py-2.5 whitespace-nowrap">
                      <span className="text-[10px] uppercase text-[#A78BFA] bg-[#1C1635] px-1.5 py-0.2 rounded border border-[#8B5CF6]/30">
                        {log.actor_role || 'SYSTEM'}
                      </span>
                    </td>
                    <td className="px-4 py-2.5 text-[#22D3EE] font-semibold whitespace-nowrap">
                      {log.action}
                    </td>
                    <td className="px-4 py-2.5 text-[#94A3B8] whitespace-nowrap">
                      {log.resource_type} {log.resource_id ? `#${log.resource_id}` : ''}
                    </td>
                    <td className="px-4 py-2.5 text-[#F1F5F9] max-w-sm truncate">
                      {log.details || '-'}
                    </td>
                    <td className="px-4 py-2.5 text-right whitespace-nowrap">
                      <span className="text-[10px] uppercase text-[#34D399] font-bold">
                        {log.status.toUpperCase()}
                      </span>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={7} className="py-8 text-center text-[#94A3B8]">
                    No audit records located.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
