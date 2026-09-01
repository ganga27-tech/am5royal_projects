import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { developerApi } from '../api/developerApi';
import { Bug, TeamMember, BugStatus } from '../types/developer';
import { StatusBadge } from '../components/StatusBadge';
import { SeverityBadge } from '../components/SeverityBadge';
import { ActivityTimeline } from '../components/ActivityTimeline';
import { CommentsList } from '../components/CommentsList';
import { useAuth } from '../auth/AuthContext';
import {
  Bug as BugIcon,
  ArrowLeft,
  Calendar,
  User,
  Server,
  Terminal,
  FolderGit2,
  Boxes,
  CheckCircle,
  FileText,
  GitCommit,
  Tag,
  Share2,
  ChevronDown,
  Sparkles,
  Clock,
  AlertCircle,
  MessageSquare,
  History,
} from 'lucide-react';

export const BugDetailPage: React.FC = () => {
  const { bugId } = useParams<{ bugId: string }>();
  const { user } = useAuth();

  const [bug, setBug] = useState<Bug | null>(null);
  const [team, setTeam] = useState<TeamMember[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Active activity tab: comments vs history
  const [activityTab, setActivityTab] = useState<'comments' | 'history'>('comments');

  // Status transition loading state
  const [isUpdatingStatus, setIsUpdatingStatus] = useState<boolean>(false);
  const [isAssigning, setIsAssigning] = useState<boolean>(false);

  const fetchBug = async () => {
    if (!bugId) return;
    setIsLoading(true);
    setError(null);
    try {
      const data = await developerApi.getBug(Number(bugId));
      setBug(data);
    } catch {
      setError('Failed to fetch defect details.');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchBug();
    developerApi.listTeamMembers().then(setTeam);
  }, [bugId]);

  // Jira-style direct status change
  const handleStatusChange = async (newStatus: string) => {
    if (!bug || isUpdatingStatus) return;
    setIsUpdatingStatus(true);
    try {
      const updated = await developerApi.transitionBug(bug.id, {
        new_status: newStatus as BugStatus,
        notes: `Status changed to ${newStatus}`,
      });
      setBug(updated);
    } catch (err: any) {
      alert(err?.response?.data?.detail || 'Failed to update status.');
    } finally {
      setIsUpdatingStatus(false);
    }
  };

  // Quick "Assign to me" shortcut
  const handleAssignToMe = async () => {
    if (!bug || !user || isAssigning) return;
    setIsAssigning(true);
    try {
      const updated = await developerApi.assignBug(bug.id, {
        developer_id: user.id,
        notes: `Assigned to ${user.full_name || user.email} via Quick-Assign`,
      });
      setBug(updated);
    } catch (err: any) {
      alert(err?.response?.data?.detail || 'Failed to assign issue.');
    } finally {
      setIsAssigning(false);
    }
  };

  // Reassign to specific team member
  const handleReassign = async (empId: number) => {
    if (!bug || isAssigning) return;
    setIsAssigning(true);
    try {
      const updated = await developerApi.assignBug(bug.id, {
        developer_id: empId,
        notes: `Reassigned issue via Member Selector`,
      });
      setBug(updated);
    } catch (err: any) {
      alert(err?.response?.data?.detail || 'Failed to reassign issue.');
    } finally {
      setIsAssigning(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-20">
        <div className="text-xs font-mono text-[#22D3EE] animate-pulse">
          FETCHING DEFECT METRICS & AUDIT LOGS...
        </div>
      </div>
    );
  }

  if (error || !bug) {
    return (
      <div className="p-6 rounded-lg bg-[#0E1420] border border-[#FB4B5F]/30 space-y-3">
        <div className="text-sm font-semibold text-[#FB4B5F]">Issue Not Found</div>
        <p className="text-xs text-[#94A3B8]">{error || 'The requested issue could not be loaded.'}</p>
        <Link to="/bugs" className="inline-flex items-center gap-1 text-xs text-[#22D3EE] hover:underline font-mono">
          <ArrowLeft className="w-3.5 h-3.5" /> Return to Defect Register
        </Link>
      </div>
    );
  }

  // All standard Jira workflow statuses
  const allStatuses: { value: BugStatus; label: string; color: string }[] = [
    { value: 'NEW', label: 'To Do (New)', color: '#38BDF8' },
    { value: 'ASSIGNED_TO_DEVELOPER', label: 'Assigned', color: '#8B5CF6' },
    { value: 'IN_PROGRESS', label: 'In Progress', color: '#FBBF24' },
    { value: 'READY_FOR_QA', label: 'Ready for QA', color: '#22D3EE' },
    { value: 'QA_TESTING', label: 'QA Testing', color: '#A78BFA' },
    { value: 'VERIFIED', label: 'Verified', color: '#34D399' },
    { value: 'QA_REJECTED', label: 'QA Rejected', color: '#FB4B5F' },
    { value: 'REOPENED', label: 'Reopened', color: '#FB4B5F' },
    { value: 'CLOSED', label: 'Done / Closed', color: '#475569' },
  ];

  return (
    <div className="space-y-4">
      {/* Jira Top Header Bar */}
      <div className="flex items-center justify-between border-b border-[#263247] pb-3">
        <div className="flex items-center gap-2 text-xs font-mono">
          <Link
            to="/board"
            className="text-[#94A3B8] hover:text-[#F1F5F9] transition flex items-center gap-1"
          >
            <ArrowLeft className="w-3.5 h-3.5" /> Sprint Board
          </Link>
          <span className="text-[#475569]">/</span>
          <span className="text-[#94A3B8]">{bug.project_name || 'AM5 Platform'}</span>
          <span className="text-[#475569]">/</span>
          <span className="text-[#22D3EE] font-bold">{bug.bug_code}</span>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => {
              navigator.clipboard.writeText(window.location.href);
              alert('Issue link copied to clipboard!');
            }}
            className="flex items-center gap-1 px-2.5 py-1 rounded bg-[#151E2E] hover:bg-[#1B2638] text-[11px] font-mono text-[#94A3B8] hover:text-[#F1F5F9] border border-[#263247] transition"
          >
            <Share2 className="w-3 h-3" /> Share
          </button>
        </div>
      </div>

      {/* Main Jira 2-Column Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        {/* ==================================================================== */}
        {/* LEFT COLUMN (68% width): Summary, Details, Activity                  */}
        {/* ==================================================================== */}
        <div className="lg:col-span-8 space-y-6">
          {/* Issue Title & Summary Header */}
          <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-3">
            <div className="flex items-center gap-2">
              <span className="p-1 rounded bg-[#FB4B5F]/15 text-[#FB4B5F]">
                <BugIcon className="w-4 h-4" />
              </span>
              <span className="text-xs font-mono font-bold text-[#FB4B5F] uppercase">
                DEFECT • {bug.bug_code}
              </span>
            </div>
            <h1 className="text-xl font-bold text-[#F1F5F9] leading-snug">{bug.title}</h1>

            {bug.description && (
              <div className="pt-2 text-xs text-[#94A3B8] leading-relaxed whitespace-pre-wrap">
                {bug.description}
              </div>
            )}
          </div>

          {/* Reproduction Steps & Discrepancy (Jira Issue Content) */}
          <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
            <div className="flex items-center gap-2 border-b border-[#263247] pb-2.5">
              <Terminal className="w-4 h-4 text-[#22D3EE]" />
              <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
                Steps to Reproduce
              </h2>
            </div>
            <div className="text-xs font-mono text-[#F1F5F9] bg-[#151E2E] p-3.5 rounded border border-[#263247] whitespace-pre-wrap leading-relaxed">
              {bug.steps_to_reproduce || 'No reproduction steps provided.'}
            </div>

            {/* Expected vs Actual */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2">
              <div className="space-y-1">
                <span className="text-[10px] font-mono uppercase text-[#34D399] block font-semibold">
                  EXPECTED BEHAVIOR
                </span>
                <div className="bg-[#151E2E] p-2.5 rounded border border-[#263247] text-xs text-[#F1F5F9] min-h-[60px]">
                  {bug.expected_result || 'Normal operational response.'}
                </div>
              </div>

              <div className="space-y-1">
                <span className="text-[10px] font-mono uppercase text-[#FB4B5F] block font-semibold">
                  ACTUAL OBSERVED DEFECT
                </span>
                <div className="bg-[#151E2E] p-2.5 rounded border border-[#263247] text-xs text-[#F1F5F9] min-h-[60px]">
                  {bug.actual_result || 'Error, crash, or unexpected behavior.'}
                </div>
              </div>
            </div>
          </div>

          {/* Technical Diagnostics */}
          <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-3">
            <div className="flex items-center gap-2 border-b border-[#263247] pb-2.5">
              <Server className="w-4 h-4 text-[#38BDF8]" />
              <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
                Technical Context
              </h2>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 text-xs font-mono">
              <div className="p-2.5 rounded bg-[#151E2E] border border-[#263247]">
                <div className="text-[10px] text-[#475569] mb-0.5">ENDPOINT</div>
                <div className="text-[#22D3EE] font-semibold truncate">
                  {bug.api_endpoint || 'N/A (UI / Client Defect)'}
                </div>
              </div>

              <div className="p-2.5 rounded bg-[#151E2E] border border-[#263247]">
                <div className="text-[10px] text-[#475569] mb-0.5">FIX COMMIT HASH</div>
                <div className="text-[#F1F5F9] font-semibold">
                  {bug.commit_reference ? `#${bug.commit_reference}` : 'Pending Fix'}
                </div>
              </div>

              <div className="p-2.5 rounded bg-[#151E2E] border border-[#263247]">
                <div className="text-[10px] text-[#475569] mb-0.5">RELEASE VERSION</div>
                <div className="text-[#F1F5F9] font-semibold">
                  {bug.release_version || 'Pending Release'}
                </div>
              </div>
            </div>
          </div>

          {/* Jira Activity Section: Comments vs History Stream */}
          <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
            <div className="flex items-center justify-between border-b border-[#263247] pb-3">
              <div className="flex items-center gap-4">
                <button
                  onClick={() => setActivityTab('comments')}
                  className={`flex items-center gap-1.5 text-xs font-mono font-bold pb-1 border-b-2 transition ${
                    activityTab === 'comments'
                      ? 'text-[#22D3EE] border-[#22D3EE]'
                      : 'text-[#94A3B8] border-transparent hover:text-[#F1F5F9]'
                  }`}
                >
                  <MessageSquare className="w-3.5 h-3.5" /> Comments ({bug.comments?.length || 0})
                </button>

                <button
                  onClick={() => setActivityTab('history')}
                  className={`flex items-center gap-1.5 text-xs font-mono font-bold pb-1 border-b-2 transition ${
                    activityTab === 'history'
                      ? 'text-[#22D3EE] border-[#22D3EE]'
                      : 'text-[#94A3B8] border-transparent hover:text-[#F1F5F9]'
                  }`}
                >
                  <History className="w-3.5 h-3.5" /> History Trail ({bug.activity_history?.length || 0})
                </button>
              </div>
            </div>

            {activityTab === 'comments' ? (
              <CommentsList
                bugId={bug.id}
                comments={bug.comments || []}
                onCommentAdded={fetchBug}
              />
            ) : (
              <ActivityTimeline history={bug.activity_history || []} />
            )}
          </div>
        </div>

        {/* ==================================================================== */}
        {/* RIGHT SIDEBAR (32% width): Jira Issue Fields & Instant Controls      */}
        {/* ==================================================================== */}
        <div className="lg:col-span-4 space-y-4 sticky top-4">
          {/* Status Panel (Jira Status Pill) */}
          <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-4 space-y-3">
            <label className="text-[10px] font-mono uppercase text-[#475569] font-bold block">
              STATUS
            </label>

            <div className="relative">
              <select
                value={bug.status}
                disabled={isUpdatingStatus}
                onChange={(e) => handleStatusChange(e.target.value)}
                className="w-full appearance-none px-3.5 py-2 rounded-lg bg-[#151E2E] border border-[#22D3EE]/40 text-xs font-mono font-bold text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE] transition cursor-pointer"
              >
                {allStatuses.map((st) => (
                  <option key={st.value} value={st.value} className="bg-[#0E1420] text-[#F1F5F9]">
                    ● {st.label}
                  </option>
                ))}
              </select>
              <ChevronDown className="w-4 h-4 text-[#22D3EE] absolute right-3 top-2.5 pointer-events-none" />
            </div>

            <div className="text-[10px] font-mono text-[#94A3B8]">
              Click to instantly advance or transition status.
            </div>
          </div>

          {/* People & Assignment Panel */}
          <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-4 space-y-3">
            <h3 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider border-b border-[#263247] pb-2">
              People
            </h3>

            {/* Assignee */}
            <div className="space-y-1.5">
              <div className="flex items-center justify-between text-[11px] font-mono">
                <span className="text-[#475569]">Assignee</span>
                <button
                  onClick={handleAssignToMe}
                  disabled={isAssigning}
                  className="text-[10px] text-[#22D3EE] hover:underline flex items-center gap-1 font-semibold"
                >
                  Assign to me
                </button>
              </div>

              <select
                value={bug.assigned_developer_id || ''}
                onChange={(e) => {
                  if (e.target.value) handleReassign(Number(e.target.value));
                }}
                disabled={isAssigning}
                className="w-full px-2.5 py-1.5 rounded bg-[#151E2E] border border-[#263247] text-xs text-[#F1F5F9] font-mono focus:outline-none focus:border-[#22D3EE]"
              >
                <option value="">Unassigned</option>
                {team.map((m) => (
                  <option key={m.id} value={m.id}>
                    {m.full_name} ({m.role})
                  </option>
                ))}
              </select>
            </div>

            {/* QA Tester */}
            <div className="space-y-1 pt-2 border-t border-[#263247]/60 text-xs font-mono">
              <span className="text-[#475569] text-[10px] block">QA AUDITOR</span>
              <div className="text-[#F1F5F9] font-medium">{bug.qa_name || 'Sarah QA Lead'}</div>
            </div>

            {/* Reporter */}
            <div className="space-y-1 pt-2 border-t border-[#263247]/60 text-xs font-mono">
              <span className="text-[#475569] text-[10px] block">REPORTER</span>
              <div className="text-[#94A3B8]">{bug.reporter_name || 'QA Platform Auditor'}</div>
            </div>
          </div>

          {/* Details & Attributes Panel */}
          <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-4 space-y-3">
            <h3 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider border-b border-[#263247] pb-2">
              Details
            </h3>

            {/* Severity */}
            <div className="flex items-center justify-between text-xs font-mono">
              <span className="text-[#475569]">Severity</span>
              <SeverityBadge severity={bug.severity} />
            </div>

            {/* Priority */}
            <div className="flex items-center justify-between text-xs font-mono pt-1.5 border-t border-[#263247]/40">
              <span className="text-[#475569]">Priority</span>
              <span className="uppercase text-[#FBBF24] font-bold text-[11px]">{bug.priority}</span>
            </div>

            {/* Project */}
            <div className="flex items-center justify-between text-xs font-mono pt-1.5 border-t border-[#263247]/40">
              <span className="text-[#475569]">Project</span>
              <Link
                to={bug.project_id ? `/projects/${bug.project_id}` : '/projects'}
                className="text-[#22D3EE] hover:underline truncate max-w-[140px]"
              >
                {bug.project_name || 'AM5 Platform'}
              </Link>
            </div>

            {/* Module */}
            <div className="flex items-center justify-between text-xs font-mono pt-1.5 border-t border-[#263247]/40">
              <span className="text-[#475569]">Component</span>
              <span className="text-[#F1F5F9] truncate max-w-[140px]">
                {bug.module_name || 'Core Services'}
              </span>
            </div>

            {/* Environment */}
            <div className="flex items-center justify-between text-xs font-mono pt-1.5 border-t border-[#263247]/40">
              <span className="text-[#475569]">Environment</span>
              <span className="uppercase text-[#94A3B8]">{bug.environment}</span>
            </div>
          </div>

          {/* Dates & Activity Log */}
          <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-4 space-y-2 text-[11px] font-mono text-[#94A3B8]">
            <div className="flex justify-between">
              <span className="text-[#475569]">Created</span>
              <span>{bug.created_at ? new Date(bug.created_at).toLocaleDateString() : 'Recent'}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-[#475569]">Updated</span>
              <span>{bug.updated_at ? new Date(bug.updated_at).toLocaleDateString() : 'Just now'}</span>
            </div>
            {bug.reopened_count > 0 && (
              <div className="flex justify-between text-[#FB4B5F] font-bold">
                <span>Reopen Count</span>
                <span>{bug.reopened_count}x</span>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
