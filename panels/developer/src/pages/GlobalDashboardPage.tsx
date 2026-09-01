import React, { useEffect, useState } from 'react';
import { developerApi } from '../api/developerApi';
import { GlobalDashboardStats } from '../types/developer';
import { StatusBadge } from '../components/StatusBadge';
import { SeverityBadge } from '../components/SeverityBadge';
import { ActivityTimeline } from '../components/ActivityTimeline';
import {
  FolderGit2,
  Network,
  Bug,
  Users,
  Activity,
  Server,
  Database,
  ShieldCheck,
  CreditCard,
  BellRing,
  Rocket,
  ArrowUpRight,
  TrendingUp,
  Layers,
  Boxes,
} from 'lucide-react';
import { Link } from 'react-router-dom';

export const GlobalDashboardPage: React.FC = () => {
  const [stats, setStats] = useState<GlobalDashboardStats | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const data = await developerApi.getGlobalDashboard();
        setStats(data);
      } catch (err: any) {
        setError('Failed to fetch dashboard metrics.');
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
          LOADING GLOBAL ENGINEERING TELEMETRY...
        </div>
      </div>
    );
  }

  if (error || !stats) {
    return (
      <div className="p-4 rounded-lg bg-[#FB4B5F]/10 border border-[#FB4B5F]/30 text-xs text-[#FB4B5F]">
        {error || 'Error loading dashboard.'}
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Top Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="text-lg font-bold text-[#F1F5F9] uppercase tracking-wide">
            Global Engineering Control Center
          </h1>
          <p className="text-xs text-[#94A3B8] font-mono mt-0.5">
            PLATFORM HEALTH, DEFECT TRACKING & SERVICE TELEMETRY
          </p>
        </div>
        <div className="flex items-center gap-2">
          <Link
            to="/bugs"
            className="px-3 py-1.5 rounded-md text-xs font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] transition"
          >
            View All Defects
          </Link>
        </div>
      </div>

      {/* KPI Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Projects */}
        <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247] flex items-center justify-between">
          <div>
            <div className="text-[11px] font-mono uppercase text-[#94A3B8]">Active Projects</div>
            <div className="text-2xl font-bold font-mono text-[#F1F5F9] mt-1">{stats.projects_count}</div>
            <div className="text-[10px] text-[#34D399] font-mono mt-0.5">All monitored</div>
          </div>
          <div className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] text-[#38BDF8]">
            <FolderGit2 className="w-5 h-5" />
          </div>
        </div>

        {/* APIs */}
        <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247] flex items-center justify-between">
          <div>
            <div className="text-[11px] font-mono uppercase text-[#94A3B8]">Cataloged APIs</div>
            <div className="text-2xl font-bold font-mono text-[#F1F5F9] mt-1">{stats.apis_count}</div>
            <div className="text-[10px] text-[#34D399] font-mono mt-0.5">100% healthy</div>
          </div>
          <div className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] text-[#34D399]">
            <Network className="w-5 h-5" />
          </div>
        </div>

        {/* Open Bugs */}
        <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247] flex items-center justify-between">
          <div>
            <div className="text-[11px] font-mono uppercase text-[#94A3B8]">Open Defects</div>
            <div className="text-2xl font-bold font-mono text-[#FB4B5F] mt-1">{stats.open_bugs_count}</div>
            <div className="text-[10px] text-[#FB4B5F] font-mono mt-0.5">
              {stats.bug_summary.critical} Critical • {stats.bug_summary.high} High
            </div>
          </div>
          <div className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] text-[#FB4B5F]">
            <Bug className="w-5 h-5" />
          </div>
        </div>

        {/* Team Members */}
        <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247] flex items-center justify-between">
          <div>
            <div className="text-[11px] font-mono uppercase text-[#94A3B8]">Engineering Staff</div>
            <div className="text-2xl font-bold font-mono text-[#F1F5F9] mt-1">
              {stats.developers_count + stats.qa_count}
            </div>
            <div className="text-[10px] text-[#22D3EE] font-mono mt-0.5">
              {stats.developers_count} Devs • {stats.qa_count} QA
            </div>
          </div>
          <div className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] text-[#22D3EE]">
            <Users className="w-5 h-5" />
          </div>
        </div>
      </div>

      {/* Development Progress & Bug Breakdown */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Development Progress */}
        <div className="lg:col-span-2 rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
          <div className="flex items-center justify-between border-b border-[#263247] pb-3">
            <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
              Subsystem Development Maturity
            </h2>
            <span className="text-[10px] font-mono text-[#34D399] bg-[#34D399]/10 px-2 py-0.5 rounded border border-[#34D399]/30">
              Live Sprints
            </span>
          </div>

          <div className="space-y-4">
            {Object.entries(stats.development_progress).map(([subsystem, progress]) => (
              <div key={subsystem} className="space-y-1.5">
                <div className="flex justify-between text-xs font-mono">
                  <span className="text-[#F1F5F9]">{subsystem}</span>
                  <span className="text-[#22D3EE] font-bold">{progress}%</span>
                </div>
                <div className="w-full h-2 rounded-full bg-[#151E2E] overflow-hidden border border-[#263247]">
                  <div
                    className="h-full bg-gradient-to-r from-[#22D3EE] to-[#8B5CF6] rounded-full transition-all duration-500"
                    style={{ width: `${progress}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Bug Breakdown by Severity */}
        <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
          <div className="flex items-center justify-between border-b border-[#263247] pb-3">
            <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
              Defect Severity Spectrum
            </h2>
            <Bug className="w-4 h-4 text-[#FB4B5F]" />
          </div>

          <div className="space-y-3">
            <div className="p-3 rounded-lg bg-[#151E2E] border border-[#FB4B5F]/30 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="w-2.5 h-2.5 rounded-full bg-[#FB4B5F]" />
                <span className="text-xs font-mono text-[#F1F5F9]">CRITICAL</span>
              </div>
              <span className="text-base font-mono font-bold text-[#FB4B5F]">
                {stats.bug_summary.critical}
              </span>
            </div>

            <div className="p-3 rounded-lg bg-[#151E2E] border border-[#FBBF24]/30 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="w-2.5 h-2.5 rounded-full bg-[#FBBF24]" />
                <span className="text-xs font-mono text-[#F1F5F9]">HIGH</span>
              </div>
              <span className="text-base font-mono font-bold text-[#FBBF24]">
                {stats.bug_summary.high}
              </span>
            </div>

            <div className="p-3 rounded-lg bg-[#151E2E] border border-[#38BDF8]/30 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="w-2.5 h-2.5 rounded-full bg-[#38BDF8]" />
                <span className="text-xs font-mono text-[#F1F5F9]">MEDIUM</span>
              </div>
              <span className="text-base font-mono font-bold text-[#38BDF8]">
                {stats.bug_summary.medium}
              </span>
            </div>

            <div className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="w-2.5 h-2.5 rounded-full bg-[#94A3B8]" />
                <span className="text-xs font-mono text-[#F1F5F9]">LOW</span>
              </div>
              <span className="text-base font-mono font-bold text-[#94A3B8]">
                {stats.bug_summary.low}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Projects Overview & Distribution (Section 10) */}
      <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
        <div className="flex items-center justify-between border-b border-[#263247] pb-3">
          <div className="flex items-center gap-2">
            <Layers className="w-4 h-4 text-[#38BDF8]" />
            <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
              Project Architecture & Domain Distribution
            </h2>
          </div>
          <Link to="/projects" className="text-[11px] text-[#22D3EE] font-mono hover:underline flex items-center gap-1">
            Explore All Projects <ArrowUpRight className="w-3 h-3" />
          </Link>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3 font-mono">
          {[
            { name: 'Core Backend', tag: 'Microservice', count: '4 Modules', health: '98%', color: '#22D3EE' },
            { name: 'Customer App', tag: 'Mobile Flutter', count: 'v2.1.0', health: 'Healthy', color: '#8B5CF6' },
            { name: 'Vendor App', tag: 'Mobile & Web', count: 'v1.8.4', health: 'Active', color: '#38BDF8' },
            { name: 'Admin Portal', tag: 'React Panel', count: 'v3.0.1', health: 'Synced', color: '#34D399' },
            { name: 'Lead & Telecaller', tag: 'Internal CRM', count: 'v2.0.0', health: 'Stable', color: '#FBBF24' },
            { name: 'QA Automation', tag: 'Test Suites', count: '4 Suites', health: 'Passing', color: '#FB4B5F' },
          ].map((cat) => (
            <div
              key={cat.name}
              className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] space-y-1 hover:border-[#22D3EE]/40 transition"
            >
              <div className="text-[10px] text-[#94A3B8] uppercase">{cat.tag}</div>
              <div className="text-xs font-bold text-[#F1F5F9] truncate">{cat.name}</div>
              <div className="flex items-center justify-between text-[10px] pt-1 border-t border-[#263247]/60">
                <span className="text-[#94A3B8]">{cat.count}</span>
                <span style={{ color: cat.color }} className="font-semibold">{cat.health}</span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* System Infrastructure Status */}
      <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
        <div className="flex items-center justify-between border-b border-[#263247] pb-3">
          <div className="flex items-center gap-2">
            <Server className="w-4 h-4 text-[#22D3EE]" />
            <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
              Core Subsystem Operational Matrix
            </h2>
          </div>
          <span className="text-[10px] font-mono text-[#34D399] bg-[#34D399]/10 px-2 py-0.5 rounded border border-[#34D399]/30">
            ALL SYSTEMS OPERATIONAL
          </span>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-3">
          {Object.entries(stats.system_status).map(([service, info]) => (
            <div
              key={service}
              className="p-3.5 rounded-lg bg-[#151E2E] border border-[#263247] space-y-1.5"
            >
              <div className="text-[10px] font-mono text-[#94A3B8] uppercase">
                {service.replace(/_/g, ' ')}
              </div>
              <div className="flex items-center gap-1.5 text-xs font-bold text-[#34D399]">
                <span className="w-2 h-2 rounded-full bg-[#34D399] animate-pulse" />
                {info.status.toUpperCase()}
              </div>
              <div className="text-[10px] font-mono text-[#475569]">
                Latency: {info.latency_ms || 4}ms • Uptime: {info.uptime || '99.9%'}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Recent Activity & Recent Deployments */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Timeline */}
        <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
          <div className="flex items-center justify-between border-b border-[#263247] pb-3">
            <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
              Recent Engineering Defect Activity
            </h2>
            <Link to="/bugs" className="text-[11px] text-[#22D3EE] font-mono hover:underline">
              View All
            </Link>
          </div>
          <ActivityTimeline history={stats.recent_activities} />
        </div>

        {/* Deployments */}
        <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
          <div className="flex items-center justify-between border-b border-[#263247] pb-3">
            <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
              Deployment Registry
            </h2>
            <Link to="/deployments" className="text-[11px] text-[#22D3EE] font-mono hover:underline">
              Deploy Logs
            </Link>
          </div>

          <div className="space-y-3">
            {stats.deployment_summary && stats.deployment_summary.length > 0 ? (
              stats.deployment_summary.map((d) => (
                <div
                  key={d.id}
                  className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] flex items-center justify-between"
                >
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="text-xs font-bold font-mono text-[#F1F5F9]">{d.version}</span>
                      <span
                        className={`text-[10px] font-mono uppercase px-1.5 py-0.2 rounded border ${
                          d.environment === 'PRODUCTION'
                            ? 'bg-[#2A1015] text-[#FB4B5F] border-[#FB4B5F]/30'
                            : 'bg-[#1C1635] text-[#A78BFA] border-[#8B5CF6]/30'
                        }`}
                      >
                        {d.environment}
                      </span>
                    </div>
                    <div className="text-[11px] text-[#94A3B8] mt-0.5">{d.project_name}</div>
                  </div>
                  <div className="text-right text-[11px] font-mono text-[#475569]">
                    <div>{d.commit_hash ? `#${d.commit_hash}` : 'HEAD'}</div>
                    <div>{d.status.toUpperCase()}</div>
                  </div>
                </div>
              ))
            ) : (
              <div className="text-center py-6 text-xs text-[#94A3B8]">No deployments recorded.</div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
