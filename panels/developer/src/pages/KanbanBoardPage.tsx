import React, { useEffect, useState, useMemo } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import { developerApi } from '../api/developerApi';
import { Bug, DevTask, Project, BugStatus, TaskStatus } from '../types/developer';
import { StatusBadge } from '../components/StatusBadge';
import { SeverityBadge } from '../components/SeverityBadge';
import { Modal } from '../components/Modal';
import { CreateBugModal } from './CreateBugModal';
import { useAuth } from '../auth/AuthContext';
import {
  Kanban,
  Bug as BugIcon,
  CheckSquare,
  Search,
  Filter,
  Plus,
  ArrowRight,
  User,
  AlertCircle,
  Clock,
  Layers,
  Sparkles,
  CheckCircle2,
  ChevronDown,
} from 'lucide-react';

interface UnifiedTicket {
  id: number;
  key: string;
  type: 'bug' | 'task';
  title: string;
  status: string;
  priority: string;
  severity?: string;
  project_id?: number;
  project_name?: string;
  module_name?: string;
  assigned_to_id?: number;
  assigned_name?: string;
  updated_at?: string;
  rawBug?: Bug;
  rawTask?: DevTask;
}

export const KanbanBoardPage: React.FC = () => {
  const { user } = useAuth();
  const [searchParams] = useSearchParams();
  const initialProj = searchParams.get('project');

  const [bugs, setBugs] = useState<Bug[]>([]);
  const [tasks, setTasks] = useState<DevTask[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);

  // Quick Filters
  const [search, setSearch] = useState<string>('');
  const [onlyMyIssues, setOnlyMyIssues] = useState<boolean>(false);
  const [typeFilter, setTypeFilter] = useState<'all' | 'bug' | 'task'>('all');
  const [criticalOnly, setCriticalOnly] = useState<boolean>(false);
  const [selectedProjectId, setSelectedProjectId] = useState<number | 'all'>(
    initialProj ? Number(initialProj) : 'all'
  );

  // Create Issue Modal
  const [isCreateBugOpen, setIsCreateBugOpen] = useState<boolean>(false);
  const [isCreateTaskOpen, setIsCreateTaskOpen] = useState<boolean>(false);

  // New Task Form State
  const [taskTitle, setTaskTitle] = useState<string>('');
  const [taskDesc, setTaskDesc] = useState<string>('');
  const [taskPriority, setTaskPriority] = useState<string>('medium');
  const [taskProjectId, setTaskProjectId] = useState<number | ''>('');
  const [isSubmittingTask, setIsSubmittingTask] = useState<boolean>(false);

  const fetchBoardData = async () => {
    setIsLoading(true);
    try {
      const [bugRes, taskList, projList] = await Promise.all([
        developerApi.listBugs({ page_size: 100 }),
        developerApi.listTasks(),
        developerApi.listProjects(),
      ]);
      setBugs(bugRes.items);
      setTasks(taskList);
      setProjects(projList);
      if (projList.length > 0 && !taskProjectId) {
        setTaskProjectId(projList[0].id);
      }
    } catch {
      // ignore
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchBoardData();
  }, []);

  // Normalize bugs and tasks into unified Jira ticket cards
  const unifiedTickets: UnifiedTicket[] = useMemo(() => {
    const ticketList: UnifiedTicket[] = [];

    bugs.forEach((b) => {
      ticketList.push({
        id: b.id,
        key: b.bug_code,
        type: 'bug',
        title: b.title,
        status: b.status,
        priority: b.priority,
        severity: b.severity,
        project_id: b.project_id,
        project_name: b.project_name,
        module_name: b.module_name,
        assigned_to_id: b.assigned_developer_id || b.assigned_qa_id,
        assigned_name: b.developer_name || b.qa_name,
        updated_at: b.updated_at,
        rawBug: b,
      });
    });

    tasks.forEach((t) => {
      ticketList.push({
        id: t.id,
        key: `TSK-${t.id}`,
        type: 'task',
        title: t.title,
        status: t.status,
        priority: t.priority,
        project_id: t.project_id,
        project_name: t.project_name,
        module_name: t.module_name,
        assigned_to_id: t.assigned_developer_id || t.assigned_qa_id,
        assigned_name: t.developer_name || t.qa_name,
        updated_at: t.updated_at,
        rawTask: t,
      });
    });

    return ticketList;
  }, [bugs, tasks]);

  // Apply Jira Quick Filters
  const filteredTickets = useMemo(() => {
    return unifiedTickets.filter((item) => {
      // Search
      if (search.trim()) {
        const q = search.toLowerCase();
        const matches =
          item.key.toLowerCase().includes(q) ||
          item.title.toLowerCase().includes(q) ||
          (item.module_name && item.module_name.toLowerCase().includes(q));
        if (!matches) return false;
      }

      // My Issues
      if (onlyMyIssues && user) {
        if (item.assigned_to_id !== user.id) return false;
      }

      // Type Filter
      if (typeFilter !== 'all' && item.type !== typeFilter) return false;

      // Critical Only
      if (criticalOnly) {
        const isCrit = item.priority === 'critical' || item.severity === 'critical';
        if (!isCrit) return false;
      }

      // Project filter
      if (selectedProjectId !== 'all' && item.project_id !== selectedProjectId) {
        return false;
      }

      return true;
    });
  }, [unifiedTickets, search, onlyMyIssues, typeFilter, criticalOnly, selectedProjectId, user]);

  // Jira Kanban Columns Definition
  const columns = [
    {
      id: 'TODO',
      title: 'To Do / Backlog',
      color: '#38BDF8',
      matchStatus: ['NEW', 'ASSIGNED_TO_DEVELOPER', 'todo'],
      targetBugStatus: 'ASSIGNED_TO_DEVELOPER',
      targetTaskStatus: 'todo',
    },
    {
      id: 'IN_PROGRESS',
      title: 'In Progress',
      color: '#FBBF24',
      matchStatus: ['IN_PROGRESS', 'in_progress'],
      targetBugStatus: 'IN_PROGRESS',
      targetTaskStatus: 'in_progress',
    },
    {
      id: 'READY_FOR_QA',
      title: 'Ready for QA / Review',
      color: '#8B5CF6',
      matchStatus: ['READY_FOR_QA', 'FIXED', 'under_review', 'QA_REJECTED', 'REOPENED'],
      targetBugStatus: 'READY_FOR_QA',
      targetTaskStatus: 'under_review',
    },
    {
      id: 'QA_TESTING',
      title: 'QA Testing',
      color: '#22D3EE',
      matchStatus: ['QA_TESTING'],
      targetBugStatus: 'QA_TESTING',
      targetTaskStatus: 'in_progress',
    },
    {
      id: 'DONE',
      title: 'Done / Verified',
      color: '#34D399',
      matchStatus: ['VERIFIED', 'CLOSED', 'completed'],
      targetBugStatus: 'VERIFIED',
      targetTaskStatus: 'completed',
    },
  ];

  // Quick move ticket status
  const handleQuickMove = async (ticket: UnifiedTicket, targetStatus: string) => {
    try {
      if (ticket.type === 'bug') {
        await developerApi.transitionBug(ticket.id, {
          new_status: targetStatus as BugStatus,
          notes: `Moved to ${targetStatus} via Jira Kanban Board`,
        });
      } else {
        await developerApi.updateTask(ticket.id, { status: targetStatus as TaskStatus });
      }
      fetchBoardData();
    } catch (err: any) {
      alert(err?.response?.data?.detail || 'Failed to move ticket');
    }
  };

  const handleCreateTask = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!taskTitle.trim() || !taskProjectId) return;
    setIsSubmittingTask(true);
    try {
      await developerApi.createTask({
        project_id: Number(taskProjectId),
        title: taskTitle.trim(),
        description: taskDesc.trim() || undefined,
        priority: taskPriority,
      });
      setTaskTitle('');
      setTaskDesc('');
      setIsCreateTaskOpen(false);
      fetchBoardData();
    } catch (err: any) {
      alert(err?.response?.data?.detail || 'Failed to create task');
    } finally {
      setIsSubmittingTask(false);
    }
  };

  return (
    <div className="space-y-5">
      {/* Top Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 border-b border-[#263247] pb-4">
        <div>
          <div className="flex items-center gap-2">
            <Kanban className="w-5 h-5 text-[#22D3EE]" />
            <h1 className="text-lg font-bold text-[#F1F5F9] uppercase tracking-wide">
              Engineering Sprint & Kanban Board
            </h1>
          </div>
          <p className="text-xs text-[#94A3B8] font-mono mt-0.5">
            ENGINEERING WORKSPACE • ACTIVE DEFECTS & SPRINT IMPLEMENTATION
          </p>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => setIsCreateBugOpen(true)}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-semibold bg-[#FB4B5F] text-white hover:bg-[#E11D48] transition shadow"
          >
            <BugIcon className="w-3.5 h-3.5" /> File Defect
          </button>
          <button
            onClick={() => setIsCreateTaskOpen(true)}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] transition shadow"
          >
            <Plus className="w-3.5 h-3.5" /> Create Task
          </button>
        </div>
      </div>

      {/* Jira Quick Filters Toolbar */}
      <div className="p-3 rounded-lg bg-[#0E1420] border border-[#263247] flex flex-wrap items-center justify-between gap-3">
        {/* Search & Project Selector */}
        <div className="flex items-center gap-2 flex-1 min-w-[280px]">
          <div className="relative flex-1">
            <Search className="w-3.5 h-3.5 text-[#94A3B8] absolute left-3 top-2.5" />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Filter by ticket key, summary, or module..."
              className="w-full pl-9 pr-3 py-1.5 rounded bg-[#151E2E] border border-[#263247] text-xs text-[#F1F5F9] placeholder-[#475569] focus:outline-none focus:border-[#22D3EE]"
            />
          </div>

          <select
            value={selectedProjectId}
            onChange={(e) =>
              setSelectedProjectId(e.target.value === 'all' ? 'all' : Number(e.target.value))
            }
            className="px-2.5 py-1.5 rounded bg-[#151E2E] border border-[#263247] text-xs text-[#F1F5F9] font-mono focus:outline-none focus:border-[#22D3EE]"
          >
            <option value="all">All Projects</option>
            {projects.map((p) => (
              <option key={p.id} value={p.id}>
                {p.name}
              </option>
            ))}
          </select>
        </div>

        {/* Quick Filter Buttons */}
        <div className="flex items-center gap-1.5 flex-wrap">
          <button
            onClick={() => setOnlyMyIssues(!onlyMyIssues)}
            className={`px-3 py-1 text-xs font-mono rounded transition border ${onlyMyIssues
              ? 'bg-[#22D3EE] text-[#080B12] font-bold border-[#22D3EE]'
              : 'bg-[#151E2E] text-[#94A3B8] border-[#263247] hover:text-[#F1F5F9]'
              }`}
          >
            Only My Issues
          </button>

          <button
            onClick={() => setTypeFilter(typeFilter === 'bug' ? 'all' : 'bug')}
            className={`px-3 py-1 text-xs font-mono rounded transition border ${typeFilter === 'bug'
              ? 'bg-[#FB4B5F] text-white font-bold border-[#FB4B5F]'
              : 'bg-[#151E2E] text-[#94A3B8] border-[#263247] hover:text-[#F1F5F9]'
              }`}
          >
            Bugs ({bugs.length})
          </button>

          <button
            onClick={() => setTypeFilter(typeFilter === 'task' ? 'all' : 'task')}
            className={`px-3 py-1 text-xs font-mono rounded transition border ${typeFilter === 'task'
              ? 'bg-[#FBBF24] text-[#080B12] font-bold border-[#FBBF24]'
              : 'bg-[#151E2E] text-[#94A3B8] border-[#263247] hover:text-[#F1F5F9]'
              }`}
          >
            Tasks ({tasks.length})
          </button>

          <button
            onClick={() => setCriticalOnly(!criticalOnly)}
            className={`px-3 py-1 text-xs font-mono rounded transition border ${criticalOnly
              ? 'bg-[#FB4B5F]/20 text-[#FB4B5F] font-bold border-[#FB4B5F]'
              : 'bg-[#151E2E] text-[#94A3B8] border-[#263247] hover:text-[#F1F5F9]'
              }`}
          >
            Critical Only
          </button>

          {(search || onlyMyIssues || typeFilter !== 'all' || criticalOnly || selectedProjectId !== 'all') && (
            <button
              onClick={() => {
                setSearch('');
                setOnlyMyIssues(false);
                setTypeFilter('all');
                setCriticalOnly(false);
                setSelectedProjectId('all');
              }}
              className="text-[11px] text-[#22D3EE] hover:underline font-mono ml-1"
            >
              Reset
            </button>
          )}
        </div>
      </div>

      {/* Kanban Columns Horizontal Scroll View */}
      {isLoading ? (
        <div className="text-center py-20 text-xs font-mono text-[#22D3EE] animate-pulse">
          RENDERING JIRA SPRINT BOARD & AGGREGATING TICKETS...
        </div>
      ) : (
        <div className="flex gap-4 overflow-x-auto pb-6 items-start">
          {columns.map((col) => {
            const colTickets = filteredTickets.filter((t) => col.matchStatus.includes(t.status));
            return (
              <div
                key={col.id}
                className="w-[310px] min-w-[310px] max-w-[310px] shrink-0 rounded-lg bg-[#0E1420] border border-[#263247] flex flex-col max-h-[calc(100vh-230px)] shadow-md"
              >
                {/* Column Header */}
                <div className="p-3 border-b border-[#263247] flex items-center justify-between shrink-0 bg-[#151E2E]/50">
                  <div className="flex items-center gap-2 min-w-0 pr-2">
                    <span
                      className="w-2.5 h-2.5 rounded-full shrink-0"
                      style={{ backgroundColor: col.color }}
                    />
                    <h2 className="text-xs font-bold text-[#F1F5F9] font-mono truncate" title={col.title}>
                      {col.title}
                    </h2>
                  </div>
                  <span className="text-[11px] font-mono font-bold text-[#94A3B8] bg-[#0E1420] px-2 py-0.5 rounded border border-[#263247] shrink-0">
                    {colTickets.length}
                  </span>
                </div>

                {/* Column Ticket Stream */}
                <div className="p-3 space-y-3 overflow-y-auto flex-1 min-h-[160px]">
                  {colTickets.length > 0 ? (
                    colTickets.map((ticket) => {
                      const isBug = ticket.type === 'bug';
                      return (
                        <div
                          key={`${ticket.type}-${ticket.id}`}
                          className="rounded-lg bg-[#151E2E] border border-[#263247] p-3.5 space-y-2.5 hover:border-[#22D3EE]/60 transition shadow-sm group"
                        >
                          {/* Card Top: Key & Type & Priority (No wrapping) */}
                          <div className="flex items-center justify-between gap-2">
                            <div className="flex items-center gap-1.5 shrink-0">
                              {isBug ? (
                                <span className="p-1 rounded bg-[#FB4B5F]/15 text-[#FB4B5F]">
                                  <BugIcon className="w-3.5 h-3.5" />
                                </span>
                              ) : (
                                <span className="p-1 rounded bg-[#FBBF24]/15 text-[#FBBF24]">
                                  <CheckSquare className="w-3.5 h-3.5" />
                                </span>
                              )}
                              <Link
                                to={isBug ? `/bugs/${ticket.id}` : `/tasks`}
                                className="text-xs font-mono font-bold text-[#22D3EE] hover:underline whitespace-nowrap"
                              >
                                {ticket.key}
                              </Link>
                            </div>

                            <div className="shrink-0">
                              {ticket.severity ? (
                                <SeverityBadge severity={ticket.severity} />
                              ) : (
                                <span className="text-[10px] font-mono uppercase text-[#94A3B8] px-1.5 py-0.5 rounded bg-[#0E1420] border border-[#263247]">
                                  {ticket.priority}
                                </span>
                              )}
                            </div>
                          </div>

                          {/* Card Title */}
                          <Link
                            to={isBug ? `/bugs/${ticket.id}` : `/tasks`}
                            className="text-xs font-medium text-[#F1F5F9] line-clamp-2 block hover:text-[#22D3EE] transition leading-snug"
                          >
                            {ticket.title}
                          </Link>

                          {/* Module / Project Tag */}
                          <div className="flex items-center gap-1.5 text-[10px] font-mono text-[#94A3B8]">
                            <span className="px-2 py-0.5 rounded bg-[#0E1420] border border-[#263247] truncate max-w-[240px]">
                              {ticket.module_name || ticket.project_name || 'General Platform'}
                            </span>
                          </div>

                          {/* Card Bottom: Assignee Initial & Quick Move Menu */}
                          <div className="flex items-center justify-between pt-2.5 border-t border-[#263247]/60 text-xs">
                            <div
                              className="w-6 h-6 rounded-full bg-[#0E1420] border border-[#263247] flex items-center justify-center text-[11px] text-[#22D3EE] shrink-0 font-bold font-mono shadow-inner cursor-default hover:border-[#22D3EE]/50 transition"
                              title={`Assigned: ${ticket.assigned_name || 'Unassigned'}`}
                            >
                              {ticket.assigned_name ? ticket.assigned_name.charAt(0).toUpperCase() : '?'}
                            </div>

                            {/* Quick Move Dropdown */}
                            <select
                              onChange={(e) => {
                                if (e.target.value) {
                                  handleQuickMove(ticket, e.target.value);
                                }
                              }}
                              defaultValue=""
                              className="text-[10px] font-mono bg-[#0E1420] text-[#22D3EE] border border-[#263247] rounded px-2 py-1 focus:outline-none hover:border-[#22D3EE]/50 shrink-0 cursor-pointer"
                              title="Move ticket"
                            >
                              <option value="" disabled>
                                Move...
                              </option>
                              {columns.map((c) => {
                                const targetSt = isBug ? c.targetBugStatus : c.targetTaskStatus;
                                return (
                                  <option key={c.id} value={targetSt} className="bg-[#0E1420] text-[#F1F5F9]">
                                    → {c.title}
                                  </option>
                                );
                              })}
                            </select>
                          </div>
                        </div>
                      );
                    })
                  ) : (
                    <div className="h-28 flex items-center justify-center text-[11px] font-mono text-[#475569] border border-dashed border-[#263247] rounded-lg">
                      No issues
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Create Bug Modal */}
      <CreateBugModal
        isOpen={isCreateBugOpen}
        onClose={() => setIsCreateBugOpen(false)}
        onBugCreated={fetchBoardData}
      />

      {/* Create Task Modal */}
      <Modal
        isOpen={isCreateTaskOpen}
        onClose={() => setIsCreateTaskOpen(false)}
        title="Create Sprint Implementation Task"
        subtitle="Add a feature task or engineering chore to the sprint board."
      >
        <form onSubmit={handleCreateTask} className="space-y-4">
          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">PROJECT *</label>
            <select
              required
              value={taskProjectId}
              onChange={(e) => setTaskProjectId(Number(e.target.value))}
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            >
              {projects.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">TASK SUMMARY *</label>
            <input
              type="text"
              required
              value={taskTitle}
              onChange={(e) => setTaskTitle(e.target.value)}
              placeholder="e.g. Implement OTP rate limiting middleware"
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            />
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">DESCRIPTION</label>
            <textarea
              rows={3}
              value={taskDesc}
              onChange={(e) => setTaskDesc(e.target.value)}
              placeholder="Acceptance criteria and technical details..."
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            />
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">PRIORITY</label>
            <select
              value={taskPriority}
              onChange={(e) => setTaskPriority(e.target.value)}
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] font-mono focus:outline-none focus:border-[#22D3EE]"
            >
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
              <option value="critical">Critical</option>
            </select>
          </div>

          <div className="flex items-center justify-end gap-3 pt-3 border-t border-[#263247]">
            <button
              type="button"
              onClick={() => setIsCreateTaskOpen(false)}
              className="px-4 py-2 text-xs text-[#94A3B8] hover:text-[#F1F5F9] transition"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmittingTask}
              className="px-4 py-2 text-xs font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] rounded transition shadow"
            >
              {isSubmittingTask ? 'Creating...' : 'Create Sprint Task'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
};
