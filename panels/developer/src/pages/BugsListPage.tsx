import React, { useEffect, useState } from 'react';
import { developerApi } from '../api/developerApi';
import { Bug, Project, TeamMember, BugStatus } from '../types/developer';
import { StatusBadge } from '../components/StatusBadge';
import { SeverityBadge } from '../components/SeverityBadge';
import { CreateBugModal } from './CreateBugModal';
import {
  Bug as BugIcon,
  Search,
  Filter,
  Plus,
  ArrowRight,
  ChevronLeft,
  ChevronRight,
  RotateCcw,
} from 'lucide-react';
import { Link } from 'react-router-dom';

export const BugsListPage: React.FC = () => {
  const [bugs, setBugs] = useState<Bug[]>([]);
  const [total, setTotal] = useState<number>(0);
  const [page, setPage] = useState<number>(1);
  const [totalPages, setTotalPages] = useState<number>(1);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Filters
  const [search, setSearch] = useState<string>('');
  const [selectedProject, setSelectedProject] = useState<number | ''>('');
  const [selectedSeverity, setSelectedSeverity] = useState<string>('');
  const [selectedStatus, setSelectedStatus] = useState<string>('');
  const [selectedDeveloper, setSelectedDeveloper] = useState<number | ''>('');

  const [projects, setProjects] = useState<Project[]>([]);
  const [team, setTeam] = useState<TeamMember[]>([]);
  const [isCreateModalOpen, setIsCreateModalOpen] = useState<boolean>(false);

  const fetchBugs = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const data = await developerApi.listBugs({
        project_id: selectedProject ? Number(selectedProject) : undefined,
        severity: selectedSeverity || undefined,
        status: selectedStatus || undefined,
        assigned_developer_id: selectedDeveloper ? Number(selectedDeveloper) : undefined,
        search: search.trim() || undefined,
        page,
        page_size: 15,
      });
      setBugs(data.items);
      setTotal(data.total);
      setTotalPages(data.total_pages);
    } catch {
      setError('Failed to fetch defect records.');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    developerApi.listProjects().then(setProjects);
    developerApi.listTeamMembers().then(setTeam);
  }, []);

  useEffect(() => {
    fetchBugs();
  }, [page, selectedProject, selectedSeverity, selectedStatus, selectedDeveloper]);

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setPage(1);
    fetchBugs();
  };

  const handleResetFilters = () => {
    setSearch('');
    setSelectedProject('');
    setSelectedSeverity('');
    setSelectedStatus('');
    setSelectedDeveloper('');
    setPage(1);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="text-lg font-bold text-[#F1F5F9] uppercase tracking-wide flex items-center gap-2">
            <BugIcon className="w-5 h-5 text-[#FB4B5F]" /> Platform Defect Lifecycle Register
          </h1>
          <p className="text-xs text-[#94A3B8] font-mono mt-0.5">
            REAL-TIME REPOSITORY OF AUDITED BUGS, ASSIGNMENTS & STATUS
          </p>
        </div>
        <button
          onClick={() => setIsCreateModalOpen(true)}
          className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-md text-xs font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] transition"
        >
          <Plus className="w-4 h-4" />
          Log New Defect
        </button>
      </div>

      {/* Filter Bar */}
      <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247] space-y-3">
        <form onSubmit={handleSearchSubmit} className="flex gap-2">
          <div className="relative flex-1">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-[#475569]">
              <Search className="w-4 h-4" />
            </div>
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search by bug code (BUG-1001), title, endpoint, or description..."
              className="w-full pl-9 pr-3 py-2 bg-[#151E2E] border border-[#263247] rounded-md text-xs text-[#F1F5F9] placeholder-[#475569] focus:outline-none focus:border-[#22D3EE] font-mono"
            />
          </div>
          <button
            type="submit"
            className="px-4 py-2 bg-[#151E2E] hover:bg-[#1B2638] text-[#22D3EE] border border-[#263247] rounded-md text-xs font-semibold font-mono transition"
          >
            SEARCH
          </button>
        </form>

        <div className="grid grid-cols-2 sm:grid-cols-5 gap-2.5 pt-2 border-t border-[#263247]/60">
          {/* Project Filter */}
          <select
            value={selectedProject}
            onChange={(e) => {
              setSelectedProject(e.target.value ? Number(e.target.value) : '');
              setPage(1);
            }}
            className="rounded bg-[#151E2E] border border-[#263247] px-2.5 py-1.5 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
          >
            <option value="">All Projects</option>
            {projects.map((p) => (
              <option key={p.id} value={p.id}>
                {p.name}
              </option>
            ))}
          </select>

          {/* Severity Filter */}
          <select
            value={selectedSeverity}
            onChange={(e) => {
              setSelectedSeverity(e.target.value);
              setPage(1);
            }}
            className="rounded bg-[#151E2E] border border-[#263247] px-2.5 py-1.5 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
          >
            <option value="">All Severities</option>
            <option value="critical">Critical</option>
            <option value="high">High</option>
            <option value="medium">Medium</option>
            <option value="low">Low</option>
          </select>

          {/* Status Filter */}
          <select
            value={selectedStatus}
            onChange={(e) => {
              setSelectedStatus(e.target.value);
              setPage(1);
            }}
            className="rounded bg-[#151E2E] border border-[#263247] px-2.5 py-1.5 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
          >
            <option value="">All Statuses</option>
            <option value="NEW">NEW</option>
            <option value="ASSIGNED_TO_DEVELOPER">ASSIGNED TO DEV</option>
            <option value="IN_PROGRESS">IN PROGRESS</option>
            <option value="READY_FOR_QA">READY FOR QA</option>
            <option value="QA_TESTING">QA TESTING</option>
            <option value="VERIFIED">VERIFIED</option>
            <option value="QA_REJECTED">QA REJECTED</option>
            <option value="REOPENED">REOPENED</option>
            <option value="CLOSED">CLOSED</option>
          </select>

          {/* Developer Filter */}
          <select
            value={selectedDeveloper}
            onChange={(e) => {
              setSelectedDeveloper(e.target.value ? Number(e.target.value) : '');
              setPage(1);
            }}
            className="rounded bg-[#151E2E] border border-[#263247] px-2.5 py-1.5 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
          >
            <option value="">All Assignees</option>
            {team.map((m) => (
              <option key={m.id} value={m.id}>
                {m.full_name} ({m.role})
              </option>
            ))}
          </select>

          {/* Reset button */}
          <button
            type="button"
            onClick={handleResetFilters}
            className="flex items-center justify-center gap-1.5 px-3 py-1.5 rounded bg-[#151E2E] hover:bg-[#1B2638] text-[#94A3B8] border border-[#263247] text-xs font-mono transition"
          >
            <RotateCcw className="w-3.5 h-3.5" />
            Reset
          </button>
        </div>
      </div>

      {/* Bugs Table */}
      <div className="rounded-lg bg-[#0E1420] border border-[#263247] overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="border-b border-[#263247] bg-[#151E2E]/60 text-[#94A3B8] font-mono uppercase text-[11px]">
                <th className="px-4 py-3">Code</th>
                <th className="px-4 py-3">Defect Summary</th>
                <th className="px-4 py-3">Project / Module</th>
                <th className="px-4 py-3">Severity</th>
                <th className="px-4 py-3">Status</th>
                <th className="px-4 py-3">Developer</th>
                <th className="px-4 py-3">QA Lead</th>
                <th className="px-4 py-3 text-right">Details</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#263247]/60">
              {isLoading ? (
                <tr>
                  <td colSpan={8} className="py-12 text-center text-[#22D3EE] font-mono animate-pulse">
                    QUERYING POSTGRES DEFECT DATABASE...
                  </td>
                </tr>
              ) : bugs && bugs.length > 0 ? (
                bugs.map((bug) => (
                  <tr key={bug.id} className="hover:bg-[#151E2E]/70 transition group">
                    <td className="px-4 py-3 font-mono font-bold text-[#22D3EE] whitespace-nowrap">
                      {bug.bug_code}
                    </td>
                    <td className="px-4 py-3 font-medium text-[#F1F5F9] max-w-sm">
                      <Link
                        to={`/bugs/${bug.id}`}
                        className="hover:text-[#22D3EE] transition line-clamp-1"
                      >
                        {bug.title}
                      </Link>
                      {bug.api_endpoint && (
                        <div className="text-[10px] font-mono text-[#475569] truncate mt-0.5">
                          {bug.api_endpoint}
                        </div>
                      )}
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap font-mono text-[#94A3B8]">
                      <div>{bug.project_name || 'AM5 Core'}</div>
                      {bug.module_name && (
                        <div className="text-[10px] text-[#475569]">{bug.module_name}</div>
                      )}
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap">
                      <SeverityBadge severity={bug.severity} />
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap">
                      <StatusBadge status={bug.status} size="sm" />
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap font-mono text-[#94A3B8]">
                      {bug.developer_name ? (
                        <span className="text-[#F1F5F9]">{bug.developer_name}</span>
                      ) : (
                        <span className="text-[#475569] italic">Unassigned</span>
                      )}
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap font-mono text-[#94A3B8]">
                      {bug.qa_name || 'QA Team'}
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap text-right">
                      <Link
                        to={`/bugs/${bug.id}`}
                        className="inline-flex items-center gap-1 px-2.5 py-1 rounded bg-[#151E2E] group-hover:bg-[#22D3EE] text-[#94A3B8] group-hover:text-[#080B12] font-semibold text-[11px] transition font-mono"
                      >
                        Inspect <ArrowRight className="w-3 h-3" />
                      </Link>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={8} className="py-12 text-center text-[#94A3B8] font-mono">
                    No defect tickets found matching your query filters.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination Footer */}
        <div className="px-4 py-3 border-t border-[#263247] flex items-center justify-between text-xs font-mono text-[#94A3B8]">
          <div>
            Showing {bugs.length} of {total} defects (Page {page} of {totalPages})
          </div>
          <div className="flex items-center gap-2">
            <button
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={page <= 1}
              className="p-1.5 rounded bg-[#151E2E] hover:bg-[#1B2638] text-[#F1F5F9] disabled:opacity-30 disabled:cursor-not-allowed border border-[#263247] transition"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <button
              onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
              disabled={page >= totalPages}
              className="p-1.5 rounded bg-[#151E2E] hover:bg-[#1B2638] text-[#F1F5F9] disabled:opacity-30 disabled:cursor-not-allowed border border-[#263247] transition"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Create Bug Modal */}
      <CreateBugModal
        isOpen={isCreateModalOpen}
        onClose={() => setIsCreateModalOpen(false)}
        onBugCreated={() => {
          setIsCreateModalOpen(false);
          fetchBugs();
        }}
      />
    </div>
  );
};
