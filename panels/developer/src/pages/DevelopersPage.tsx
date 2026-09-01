import React, { useEffect, useState } from 'react';
import { developerApi } from '../api/developerApi';
import { TeamMember } from '../types/developer';
import { Users, Bug, CheckSquare, ShieldCheck, Mail, Phone } from 'lucide-react';

export const DevelopersPage: React.FC = () => {
  const [team, setTeam] = useState<TeamMember[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);

  useEffect(() => {
    developerApi
      .listTeamMembers()
      .then(setTeam)
      .finally(() => setIsLoading(false));
  }, []);

  const getRoleBadge = (role: string) => {
    if (role === 'qa') {
      return (
        <span className="text-[10px] font-mono uppercase px-2 py-0.5 rounded bg-[#1C1635] text-[#A78BFA] border border-[#8B5CF6]/30 font-semibold">
          QA ENGINEER
        </span>
      );
    }
    if (role === 'admin' || role === 'super_admin') {
      return (
        <span className="text-[10px] font-mono uppercase px-2 py-0.5 rounded bg-[#2A1015] text-[#FB4B5F] border border-[#FB4B5F]/30 font-semibold">
          ADMIN
        </span>
      );
    }
    return (
      <span className="text-[10px] font-mono uppercase px-2 py-0.5 rounded bg-[#0E1E2E] text-[#22D3EE] border border-[#22D3EE]/30 font-semibold">
        DEVELOPER
      </span>
    );
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-lg font-bold text-[#F1F5F9] uppercase tracking-wide flex items-center gap-2">
          <Users className="w-5 h-5 text-[#22D3EE]" /> Engineering & QA Roster
        </h1>
        <p className="text-xs text-[#94A3B8] font-mono mt-0.5">
          STAFF ALLOCATION, ACTIVE DEFECT LOAD & SPRINT PERFORMANCE
        </p>
      </div>

      {/* Team Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {isLoading ? (
          <div className="col-span-full text-center py-20 text-xs font-mono text-[#22D3EE] animate-pulse">
            AUDITING ENGINEERING ROSTER...
          </div>
        ) : team && team.length > 0 ? (
          team.map((member) => (
            <div
              key={member.id}
              className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4 hover:border-[#22D3EE]/40 transition"
            >
              <div className="flex items-start justify-between">
                <div>
                  <h3 className="text-sm font-bold text-[#F1F5F9]">{member.full_name}</h3>
                  <div className="flex items-center gap-1 text-xs text-[#94A3B8] mt-1 font-mono">
                    <Mail className="w-3 h-3 text-[#475569]" />
                    {member.email}
                  </div>
                </div>
                {getRoleBadge(member.role)}
              </div>

              {/* Workload meter */}
              <div className="space-y-1.5">
                <div className="flex justify-between text-xs font-mono">
                  <span className="text-[#94A3B8]">Workload Score</span>
                  <span
                    className={`font-bold ${
                      member.workload_score > 75 ? 'text-[#FB4B5F]' : 'text-[#34D399]'
                    }`}
                  >
                    {member.workload_score}%
                  </span>
                </div>
                <div className="w-full h-1.5 rounded-full bg-[#151E2E] overflow-hidden">
                  <div
                    className={`h-full rounded-full transition-all ${
                      member.workload_score > 75 ? 'bg-[#FB4B5F]' : 'bg-[#22D3EE]'
                    }`}
                    style={{ width: `${member.workload_score}%` }}
                  />
                </div>
              </div>

              {/* Counters */}
              <div className="grid grid-cols-2 gap-2 pt-3 border-t border-[#263247]/60 text-center font-mono text-xs">
                <div className="p-2 rounded bg-[#151E2E]">
                  <div className="text-[10px] text-[#94A3B8]">ACTIVE DEFECTS</div>
                  <div className="font-bold text-[#FB4B5F] mt-0.5">{member.active_bugs_count}</div>
                </div>
                <div className="p-2 rounded bg-[#151E2E]">
                  <div className="text-[10px] text-[#94A3B8]">TASKS DELIVERED</div>
                  <div className="font-bold text-[#34D399] mt-0.5">
                    {member.completed_tasks_count}
                  </div>
                </div>
              </div>
            </div>
          ))
        ) : (
          <div className="col-span-full text-center py-12 text-xs text-[#94A3B8]">
            No engineers registered.
          </div>
        )}
      </div>
    </div>
  );
};
