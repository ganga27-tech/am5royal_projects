import React, { useEffect, useState } from 'react';
import { developerApi } from '../api/developerApi';
import { DeveloperDashboardStats } from '../types/developer';
import { StatusBadge } from '../components/StatusBadge';
import { SeverityBadge } from '../components/SeverityBadge';
import { ActivityTimeline } from '../components/ActivityTimeline';
import {
  Code2,
  Bug,
  CheckSquare,
  AlertTriangle,
  RotateCcw,
  Clock,
  ArrowRight,
  Flame,
} from 'lucide-react';
import { Link } from 'react-router-dom';

export const DeveloperDashboardPage: React.FC = () => {
  const [stats, setStats] = useState<DeveloperDashboardStats | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const data = await developerApi.getDeveloperDashboard();
        setStats(data);
      } catch {
        setError('Failed to fetch developer workspace.');
      } finally {
        setIsLoading(false);
      }
    };
    fetchStats();
  }, []);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-20">
        <div className="text-xs font-mono text-[#22D3EE] animate-pulse">
          FETCHING ASSIGNED DEFECTS & WORKLOAD...
        </div>
      </div>
    );
  }

  if (error || !stats) {
    return (
      <div className="p-4 rounded-lg bg-[#FB4B5F]/10 border border-[#FB4B5F]/30 text-xs text-[#FB4B5F]">
        {error || 'Error loading developer workspace.'}
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="text-lg font-bold text-[#F1F5F9] uppercase tracking-wide flex items-center gap-2">
            <Code2 className="w-5 h-5 text-[#22D3EE]" /> Developer Command Center
          </h1>
          <p className="text-xs text-[#94A3B8] font-mono mt-0.5">
            PERSONAL SPRINT QUEUE, ACTIVE DEFECTS & QA REJECTIONS
          </p>
        </div>
      </div>

      {/* KPI Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Open Bugs */}
        <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247] flex items-center justify-between">
          <div>
            <div className="text-[11px] font-mono uppercase text-[#94A3B8]">My Assigned Bugs</div>
            <div className="text-2xl font-bold font-mono text-[#22D3EE] mt-1">
              {stats.my_open_bugs_count}
            </div>
            <div className="text-[10px] text-[#94A3B8] font-mono mt-0.5">
              {stats.critical_bugs_count} Critical Priority
            </div>
          </div>
          <div className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] text-[#22D3EE]">
            <Bug className="w-5 h-5" />
          </div>
        </div>

        {/* Returned by QA */}
        <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247] flex items-center justify-between">
          <div>
            <div className="text-[11px] font-mono uppercase text-[#94A3B8]">Returned by QA</div>
            <div className="text-2xl font-bold font-mono text-[#FB4B5F] mt-1">
              {stats.bugs_returned_by_qa_count}
            </div>
            <div className="text-[10px] text-[#FB4B5F] font-mono mt-0.5">Action Required</div>
          </div>
          <div className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] text-[#FB4B5F]">
            <RotateCcw className="w-5 h-5" />
          </div>
        </div>

        {/* Sprint Tasks */}
        <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247] flex items-center justify-between">
          <div>
            <div className="text-[11px] font-mono uppercase text-[#94A3B8]">My Sprint Tasks</div>
            <div className="text-2xl font-bold font-mono text-[#FBBF24] mt-1">
              {stats.my_tasks_count}
            </div>
            <div className="text-[10px] text-[#34D399] font-mono mt-0.5">
              {stats.completed_tasks_count} Completed
            </div>
          </div>
          <div className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] text-[#FBBF24]">
            <CheckSquare className="w-5 h-5" />
          </div>
        </div>

        {/* Workload */}
        <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247] flex items-center justify-between">
          <div>
            <div className="text-[11px] font-mono uppercase text-[#94A3B8]">Workload Capacity</div>
            <div className="text-2xl font-bold font-mono text-[#F1F5F9] mt-1">
              {stats.workload_percent}%
            </div>
            <div className="text-[10px] text-[#38BDF8] font-mono mt-0.5">
              {stats.workload_percent > 80 ? 'Heavy Sprint' : 'Optimal Capacity'}
            </div>
          </div>
          <div className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] text-[#8B5CF6]">
            <Flame className="w-5 h-5" />
          </div>
        </div>
      </div>

      {/* Main Grid: My Bugs & My Tasks */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* My Open Bugs List */}
        <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
          <div className="flex items-center justify-between border-b border-[#263247] pb-3">
            <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider flex items-center gap-2">
              <Bug className="w-4 h-4 text-[#22D3EE]" /> My Active Bug Queue
            </h2>
            <Link to="/bugs" className="text-[11px] text-[#22D3EE] font-mono hover:underline">
              All Bugs ({stats.my_open_bugs_count})
            </Link>
          </div>

          <div className="space-y-2.5">
            {stats.my_bugs && stats.my_bugs.length > 0 ? (
              stats.my_bugs.map((bug) => (
                <Link
                  key={bug.id}
                  to={`/bugs/${bug.id}`}
                  className="block p-3 rounded-lg bg-[#151E2E] hover:bg-[#1B2638] border border-[#263247] transition group"
                >
                  <div className="flex items-center justify-between gap-2">
                    <div className="flex items-center gap-2">
                      <span className="text-xs font-mono font-bold text-[#22D3EE]">
                        {bug.bug_code}
                      </span>
                      <SeverityBadge severity={bug.severity} />
                    </div>
                    <StatusBadge status={bug.status} size="sm" />
                  </div>

                  <div className="text-xs font-medium text-[#F1F5F9] mt-2 line-clamp-1 group-hover:text-[#22D3EE] transition">
                    {bug.title}
                  </div>

                  <div className="flex items-center justify-between text-[10px] font-mono text-[#94A3B8] mt-2 pt-2 border-t border-[#263247]/60">
                    <span>{bug.project_name || 'Marketplace'}</span>
                    <span className="text-[#475569]">Repro on: {bug.environment}</span>
                  </div>
                </Link>
              ))
            ) : (
              <div className="text-center py-10 text-xs text-[#94A3B8]">
                No bugs assigned to you. Queue clear!
              </div>
            )}
          </div>
        </div>

        {/* My Tasks Queue */}
        <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
          <div className="flex items-center justify-between border-b border-[#263247] pb-3">
            <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider flex items-center gap-2">
              <CheckSquare className="w-4 h-4 text-[#FBBF24]" /> My Assigned Tasks
            </h2>
            <Link to="/tasks" className="text-[11px] text-[#22D3EE] font-mono hover:underline">
              Sprint Board
            </Link>
          </div>

          <div className="space-y-2.5">
            {stats.my_tasks && stats.my_tasks.length > 0 ? (
              stats.my_tasks.map((task) => (
                <div
                  key={task.id}
                  className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] space-y-2"
                >
                  <div className="flex items-center justify-between gap-2">
                    <span className="text-xs font-medium text-[#F1F5F9] line-clamp-1">
                      {task.title}
                    </span>
                    <StatusBadge status={task.status} size="sm" />
                  </div>

                  <div className="flex items-center justify-between text-[10px] font-mono text-[#94A3B8]">
                    <span>{task.project_name || 'General'}</span>
                    <span className="text-[#FBBF24] uppercase">{task.priority} Priority</span>
                  </div>
                </div>
              ))
            ) : (
              <div className="text-center py-10 text-xs text-[#94A3B8]">No active tasks.</div>
            )}
          </div>
        </div>
      </div>

      {/* Activity Timeline */}
      <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
        <div className="flex items-center justify-between border-b border-[#263247] pb-3">
          <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
            Defect Events Related to My Work
          </h2>
        </div>
        <ActivityTimeline history={stats.recent_activity} />
      </div>
    </div>
  );
};
