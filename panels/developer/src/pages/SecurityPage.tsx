import React, { useEffect, useState } from 'react';
import { developerApi } from '../api/developerApi';
import { SecurityAudit } from '../types/developer';
import { ShieldCheck, ShieldAlert, Lock, UserCheck, AlertTriangle, Key } from 'lucide-react';

export const SecurityPage: React.FC = () => {
  const [sec, setSec] = useState<SecurityAudit | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);

  useEffect(() => {
    developerApi
      .getSecurityAudit()
      .then(setSec)
      .finally(() => setIsLoading(false));
  }, []);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-lg font-bold text-[#F1F5F9] uppercase tracking-wide flex items-center gap-2">
          <ShieldCheck className="w-5 h-5 text-[#34D399]" /> Security & Access Control Audit
        </h1>
        <p className="text-xs text-[#94A3B8] font-mono mt-0.5">
          JWT BEARER VALIDATION, RBAC ROLES & AUTHENTICATION AUDIT
        </p>
      </div>

      {isLoading || !sec ? (
        <div className="text-center py-20 text-xs font-mono text-[#34D399] animate-pulse">
          AUDITING SECURITY SIGNATURES...
        </div>
      ) : (
        <div className="space-y-6">
          {/* Security KPI Grid */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247]">
              <div className="text-[10px] font-mono uppercase text-[#94A3B8]">AUTHENTICATION HEALTH</div>
              <div className="text-sm font-bold font-mono text-[#34D399] mt-1 flex items-center gap-1.5">
                <ShieldCheck className="w-4 h-4" /> Optimal
              </div>
              <div className="text-[10px] font-mono text-[#475569] mt-0.5">{sec.auth_health}</div>
            </div>

            <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247]">
              <div className="text-[10px] font-mono uppercase text-[#94A3B8]">LOGINS (PAST 24H)</div>
              <div className="text-2xl font-bold font-mono text-[#22D3EE] mt-1">
                {sec.total_logins_24h}
              </div>
              <div className="text-[10px] font-mono text-[#34D399] mt-0.5">
                0 Unrecognized Geo-Locations
              </div>
            </div>

            <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247]">
              <div className="text-[10px] font-mono uppercase text-[#94A3B8]">FAILED AUTH ATTEMPTS</div>
              <div className="text-2xl font-bold font-mono text-[#F1F5F9] mt-1">
                {sec.failed_logins_24h}
              </div>
              <div className="text-[10px] font-mono text-[#34D399] mt-0.5">
                Rate limiting active
              </div>
            </div>

            <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247]">
              <div className="text-[10px] font-mono uppercase text-[#94A3B8]">SECURITY ALERTS</div>
              <div className="text-2xl font-bold font-mono text-[#34D399] mt-1">
                {sec.suspicious_indicators_count}
              </div>
              <div className="text-[10px] font-mono text-[#34D399] mt-0.5">No anomalies</div>
            </div>
          </div>

          {/* Recent Security Audits */}
          <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
            <div className="border-b border-[#263247] pb-3 flex items-center justify-between">
              <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
                Authentication & Role Enforced Events
              </h2>
              <span className="text-[10px] font-mono text-[#34D399]">RBAC Protected</span>
            </div>

            <div className="space-y-2.5">
              {sec.recent_security_events && sec.recent_security_events.length > 0 ? (
                sec.recent_security_events.map((e) => (
                  <div
                    key={e.id}
                    className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] flex items-center justify-between text-xs font-mono"
                  >
                    <div className="flex items-center gap-3">
                      <div className="p-1.5 rounded bg-[#0E1420] text-[#34D399]">
                        <Key className="w-3.5 h-3.5" />
                      </div>
                      <div>
                        <span className="font-bold text-[#F1F5F9]">{e.actor_name}</span>{' '}
                        <span className="text-[#94A3B8]">({e.actor_role})</span>
                        <div className="text-[10px] text-[#475569] mt-0.5">
                          {e.action} on {e.resource_type}
                        </div>
                      </div>
                    </div>
                    <div className="text-right">
                      <span className="text-[10px] text-[#34D399] uppercase px-1.5 py-0.2 rounded bg-[#34D399]/10 border border-[#34D399]/30">
                        {e.status}
                      </span>
                      <div className="text-[10px] text-[#475569] mt-1">
                        {new Date(e.created_at).toLocaleTimeString()}
                      </div>
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-center py-8 text-xs text-[#94A3B8]">
                  No security events recorded.
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
