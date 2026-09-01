import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { developerApi } from '../api/developerApi';
import { ProjectWorkspace, TeamMember } from '../types/developer';
import { StatusBadge } from '../components/StatusBadge';
import { SeverityBadge } from '../components/SeverityBadge';
import { Modal } from '../components/Modal';
import { useAuth } from '../auth/AuthContext';
import {
  FolderGit2,
  Crown,
  Users,
  UserPlus,
  Trash2,
  Bug,
  CheckSquare,
  Boxes,
  Network,
  ArrowLeft,
  ExternalLink,
  ShieldCheck,
  Play,
  CheckCircle,
  Clock,
  ArrowRight,
  AlertCircle,
  Kanban,
} from 'lucide-react';

export const ProjectDetailPage: React.FC = () => {
  const { projectId } = useParams<{ projectId: string }>();
  const { user } = useAuth();

  const [workspace, setWorkspace] = useState<ProjectWorkspace | null>(null);
  const [team, setTeam] = useState<TeamMember[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Active tab
  const [activeTab, setActiveTab] = useState<'bugs' | 'tasks' | 'modules' | 'apis'>('bugs');

  // Add Member Modal
  const [isAddMemberOpen, setIsAddMemberOpen] = useState<boolean>(false);
  const [selectedEmpId, setSelectedEmpId] = useState<number | ''>('');
  const [projectRole, setProjectRole] = useState<string>('developer');
  const [isSubmittingMember, setIsSubmittingMember] = useState<boolean>(false);
  const [memberError, setMemberError] = useState<string | null>(null);

  // Reassign Head Modal
  const [isHeadModalOpen, setIsHeadModalOpen] = useState<boolean>(false);
  const [newHeadId, setNewHeadId] = useState<number | ''>('');
  const [isSubmittingHead, setIsSubmittingHead] = useState<boolean>(false);

  const fetchWorkspace = async () => {
    if (!projectId) return;
    setIsLoading(true);
    setError(null);
    try {
      const data = await developerApi.getProjectWorkspace(Number(projectId));
      setWorkspace(data);
    } catch {
      setError('Failed to load project workspace.');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchWorkspace();
    developerApi.listTeamMembers().then(setTeam);
  }, [projectId]);

  const p = workspace?.project;
  const isProjectHead = user?.id === p?.project_head_id;
  const isAdmin = user?.role === 'admin' || user?.role === 'super_admin';
  const canManageTeam = isProjectHead || isAdmin;

  const handleAddMember = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!p || !selectedEmpId) return;

    setIsSubmittingMember(true);
    setMemberError(null);
    try {
      await developerApi.addProjectMember(p.id, {
        employee_id: Number(selectedEmpId),
        project_role: projectRole,
      });
      setIsAddMemberOpen(false);
      setSelectedEmpId('');
      fetchWorkspace();
    } catch (err: any) {
      setMemberError(err?.response?.data?.detail || 'Failed to add team member.');
    } finally {
      setIsSubmittingMember(false);
    }
  };

  const handleRemoveMember = async (employeeId: number, memberName: string) => {
    if (!p) return;
    if (!confirm(`Are you sure you want to remove ${memberName} from this project?`)) return;

    try {
      await developerApi.removeProjectMember(p.id, employeeId);
      fetchWorkspace();
    } catch (err: any) {
      alert(err?.response?.data?.detail || 'Failed to remove member.');
    }
  };

  const handleUpdateHead = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!p || !newHeadId) return;

    setIsSubmittingHead(true);
    try {
      await developerApi.updateProjectHead(p.id, Number(newHeadId));
      setIsHeadModalOpen(false);
      fetchWorkspace();
    } catch (err: any) {
      alert(err?.response?.data?.detail || 'Failed to update Project Head.');
    } finally {
      setIsSubmittingHead(false);
    }
  };

  if (isLoading) {
    return (
      <div className="text-center py-20 text-xs font-mono text-[#22D3EE] animate-pulse">
        INITIALIZING PROJECT WORKSPACE & TEAM ALLOCATION...
      </div>
    );
  }

  if (error || !workspace || !p) {
    return (
      <div className="p-6 rounded-lg bg-[#0E1420] border border-[#FB4B5F]/30 space-y-3">
        <div className="text-sm font-semibold text-[#FB4B5F]">Project Not Found</div>
        <p className="text-xs text-[#94A3B8]">{error || 'Unable to locate the specified project workspace.'}</p>
        <Link to="/projects" className="inline-flex items-center gap-1 text-xs text-[#22D3EE] hover:underline font-mono">
          <ArrowLeft className="w-3.5 h-3.5" /> Return to Projects Directory
        </Link>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Top Breadcrumb */}
      <div className="flex items-center justify-between">
        <Link
          to="/projects"
          className="inline-flex items-center gap-1.5 text-xs text-[#94A3B8] hover:text-[#F1F5F9] transition font-mono"
        >
          <ArrowLeft className="w-4 h-4" /> Back to Projects Directory
        </Link>

        <div className="flex items-center gap-2">
          <Link
            to={`/board?project=${p.id}`}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-mono font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] transition shadow"
          >
            <Kanban className="w-3.5 h-3.5" /> Sprint Board
          </Link>
          {p.repository_url && (
            <a
              href={p.repository_url}
              target="_blank"
              rel="noreferrer"
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-mono bg-[#151E2E] hover:bg-[#1B2638] text-[#94A3B8] hover:text-[#F1F5F9] border border-[#263247] transition"
            >
              <ExternalLink className="w-3.5 h-3.5" /> Git Repository
            </a>
          )}
        </div>
      </div>

      {/* Project Banner & Metadata */}
      <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-6 space-y-4">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 border-b border-[#263247] pb-4">
          <div>
            <div className="flex items-center gap-2 flex-wrap">
              <h1 className="text-xl font-bold text-[#F1F5F9]">{p.name}</h1>
              <span className="text-[10px] font-mono uppercase px-2 py-0.5 rounded bg-[#151E2E] text-[#34D399] border border-[#34D399]/30">
                {p.status}
              </span>
            </div>
            <div className="text-xs font-mono text-[#475569] mt-0.5">{p.slug}</div>
          </div>

          {/* Maturity Meter */}
          <div className="w-48 space-y-1.5">
            <div className="flex justify-between text-xs font-mono">
              <span className="text-[#94A3B8]">Maturity</span>
              <span className="text-[#22D3EE] font-bold">{p.progress}%</span>
            </div>
            <div className="w-full h-2 rounded-full bg-[#151E2E] overflow-hidden border border-[#263247]">
              <div
                className="h-full bg-gradient-to-r from-[#22D3EE] to-[#8B5CF6] rounded-full"
                style={{ width: `${p.progress}%` }}
              />
            </div>
          </div>
        </div>

        {p.description && (
          <p className="text-xs text-[#94A3B8] leading-relaxed">{p.description}</p>
        )}

        {/* Counters summary */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 pt-3 border-t border-[#263247]/60 text-xs font-mono">
          <div className="p-2.5 rounded bg-[#151E2E] border border-[#263247]">
            <span className="text-[#475569] block text-[10px]">TEAM MEMBERS</span>
            <span className="text-[#F1F5F9] font-bold text-sm">{workspace.members.length}</span>
          </div>
          <div className="p-2.5 rounded bg-[#151E2E] border border-[#263247]">
            <span className="text-[#475569] block text-[10px]">OPEN DEFECTS</span>
            <span className="text-[#FB4B5F] font-bold text-sm">{p.open_bugs_count}</span>
          </div>
          <div className="p-2.5 rounded bg-[#151E2E] border border-[#263247]">
            <span className="text-[#475569] block text-[10px]">ACTIVE TASKS</span>
            <span className="text-[#FBBF24] font-bold text-sm">{p.active_tasks_count}</span>
          </div>
          <div className="p-2.5 rounded bg-[#151E2E] border border-[#263247]">
            <span className="text-[#475569] block text-[10px]">CATALOGED APIS</span>
            <span className="text-[#34D399] font-bold text-sm">{p.apis_count}</span>
          </div>
        </div>
      </div>

      {/* Project Head & Team Management Row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Project Head Card */}
        <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
          <div className="flex items-center justify-between border-b border-[#263247] pb-3">
            <div className="flex items-center gap-2">
              <Crown className="w-4 h-4 text-[#FBBF24]" />
              <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
                Project Leadership
              </h2>
            </div>
            {isAdmin && (
              <button
                onClick={() => {
                  setNewHeadId(p.project_head_id || '');
                  setIsHeadModalOpen(true);
                }}
                className="text-[10px] font-mono text-[#22D3EE] hover:underline"
              >
                Reassign Head
              </button>
            )}
          </div>

          <div className="p-3.5 rounded-lg bg-[#151E2E] border border-[#263247] space-y-2">
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold text-[#F1F5F9]">
                {p.project_head_name || 'Unassigned Project Head'}
              </span>
              <span className="text-[10px] font-mono uppercase px-2 py-0.5 rounded bg-[#2A210D] text-[#FDE047] border border-[#EAB308]/30 font-semibold">
                PROJECT HEAD
              </span>
            </div>

            {p.project_head_email && (
              <div className="text-[11px] font-mono text-[#94A3B8]">{p.project_head_email}</div>
            )}

            {isProjectHead ? (
              <div className="mt-2 p-2 rounded bg-[#22D3EE]/10 border border-[#22D3EE]/30 text-[10px] font-mono text-[#22D3EE] flex items-center gap-1.5">
                <ShieldCheck className="w-3.5 h-3.5 shrink-0" />
                <span>You are the Project Head. Team access control enabled.</span>
              </div>
            ) : (
              <div className="text-[10px] font-mono text-[#475569] mt-1">
                Project Head has primary authorization to assign staff.
              </div>
            )}
          </div>
        </div>

        {/* Assigned Team Roster Card */}
        <div className="lg:col-span-2 rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
          <div className="flex items-center justify-between border-b border-[#263247] pb-3">
            <div className="flex items-center gap-2">
              <Users className="w-4 h-4 text-[#22D3EE]" />
              <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
                Assigned Team Roster ({workspace.members.length})
              </h2>
            </div>

            {canManageTeam ? (
              <button
                onClick={() => {
                  setMemberError(null);
                  setSelectedEmpId('');
                  setIsAddMemberOpen(true);
                }}
                className="flex items-center gap-1.5 px-3 py-1 rounded-md text-xs font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] transition"
              >
                <UserPlus className="w-3.5 h-3.5" /> Add Team Member
              </button>
            ) : (
              <span className="text-[10px] font-mono text-[#475569]">
                Team management restricted to Project Head
              </span>
            )}
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 max-h-48 overflow-y-auto pr-1">
            {workspace.members && workspace.members.length > 0 ? (
              workspace.members.map((m) => {
                const isLead = m.project_role === 'lead';
                return (
                  <div
                    key={m.id}
                    className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] flex items-center justify-between"
                  >
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="text-xs font-bold text-[#F1F5F9]">{m.full_name}</span>
                        <span
                          className={`text-[9px] font-mono uppercase px-1.5 py-0.2 rounded border ${
                            isLead
                              ? 'bg-[#2A210D] text-[#FDE047] border-[#EAB308]/30'
                              : m.project_role === 'qa'
                              ? 'bg-[#1C1635] text-[#A78BFA] border-[#8B5CF6]/30'
                              : 'bg-[#0E1E2E] text-[#22D3EE] border-[#22D3EE]/30'
                          }`}
                        >
                          {m.project_role}
                        </span>
                      </div>
                      <div className="text-[10px] font-mono text-[#94A3B8] truncate mt-0.5">
                        {m.email}
                      </div>
                    </div>

                    {canManageTeam && !isLead && (
                      <button
                        onClick={() => handleRemoveMember(m.employee_id, m.full_name)}
                        className="p-1.5 rounded text-[#475569] hover:text-[#FB4B5F] hover:bg-[#1B2638] transition"
                        title="Remove Member"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    )}
                  </div>
                );
              })
            ) : (
              <div className="col-span-full text-center py-6 text-xs text-[#94A3B8]">
                No members assigned to this project yet.
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Unified Implementation Matrix Tabs */}
      <div className="rounded-lg bg-[#0E1420] border border-[#263247] overflow-hidden">
        {/* Navigation Tabs */}
        <div className="flex items-center border-b border-[#263247] bg-[#151E2E]/60 px-4">
          <button
            onClick={() => setActiveTab('bugs')}
            className={`flex items-center gap-2 px-4 py-3 text-xs font-mono font-semibold transition border-b-2 ${
              activeTab === 'bugs'
                ? 'border-[#22D3EE] text-[#22D3EE] bg-[#0E1420]'
                : 'border-transparent text-[#94A3B8] hover:text-[#F1F5F9]'
            }`}
          >
            <Bug className="w-3.5 h-3.5 text-[#FB4B5F]" />
            Defects & Bugs ({workspace.bugs.length})
          </button>

          <button
            onClick={() => setActiveTab('tasks')}
            className={`flex items-center gap-2 px-4 py-3 text-xs font-mono font-semibold transition border-b-2 ${
              activeTab === 'tasks'
                ? 'border-[#22D3EE] text-[#22D3EE] bg-[#0E1420]'
                : 'border-transparent text-[#94A3B8] hover:text-[#F1F5F9]'
            }`}
          >
            <CheckSquare className="w-3.5 h-3.5 text-[#FBBF24]" />
            Sprint Features & Tasks ({workspace.tasks.length})
          </button>

          <button
            onClick={() => setActiveTab('modules')}
            className={`flex items-center gap-2 px-4 py-3 text-xs font-mono font-semibold transition border-b-2 ${
              activeTab === 'modules'
                ? 'border-[#22D3EE] text-[#22D3EE] bg-[#0E1420]'
                : 'border-transparent text-[#94A3B8] hover:text-[#F1F5F9]'
            }`}
          >
            <Boxes className="w-3.5 h-3.5 text-[#8B5CF6]" />
            Architecture Modules ({workspace.modules.length})
          </button>

          <button
            onClick={() => setActiveTab('apis')}
            className={`flex items-center gap-2 px-4 py-3 text-xs font-mono font-semibold transition border-b-2 ${
              activeTab === 'apis'
                ? 'border-[#22D3EE] text-[#22D3EE] bg-[#0E1420]'
                : 'border-transparent text-[#94A3B8] hover:text-[#F1F5F9]'
            }`}
          >
            <Network className="w-3.5 h-3.5 text-[#34D399]" />
            APIs & Endpoints ({workspace.apis.length})
          </button>
        </div>

        {/* Tab 1: Defects & Bugs */}
        {activeTab === 'bugs' && (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead>
                <tr className="border-b border-[#263247] bg-[#151E2E]/40 text-[#94A3B8] font-mono uppercase text-[11px]">
                  <th className="px-4 py-3">Code</th>
                  <th className="px-4 py-3">Title</th>
                  <th className="px-4 py-3">Module</th>
                  <th className="px-4 py-3">Severity</th>
                  <th className="px-4 py-3">Status</th>
                  <th className="px-4 py-3">Assigned Developer</th>
                  <th className="px-4 py-3 text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#263247]/60">
                {workspace.bugs && workspace.bugs.length > 0 ? (
                  workspace.bugs.map((b) => (
                    <tr key={b.id} className="hover:bg-[#151E2E]/60 transition">
                      <td className="px-4 py-3 font-mono font-bold text-[#22D3EE]">{b.bug_code}</td>
                      <td className="px-4 py-3 font-medium text-[#F1F5F9] max-w-sm truncate">
                        {b.title}
                      </td>
                      <td className="px-4 py-3 font-mono text-[#94A3B8]">
                        {b.module_name || 'Platform'}
                      </td>
                      <td className="px-4 py-3">
                        <SeverityBadge severity={b.severity} />
                      </td>
                      <td className="px-4 py-3">
                        <StatusBadge status={b.status} size="sm" />
                      </td>
                      <td className="px-4 py-3 font-mono text-[#94A3B8]">
                        {b.developer_name || 'Unassigned'}
                      </td>
                      <td className="px-4 py-3 text-right">
                        <Link
                          to={`/bugs/${b.id}`}
                          className="inline-flex items-center gap-1 px-2.5 py-1 rounded bg-[#151E2E] hover:bg-[#22D3EE] text-[#94A3B8] hover:text-[#080B12] text-[11px] font-mono font-semibold transition"
                        >
                          Inspect <ArrowRight className="w-3 h-3" />
                        </Link>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan={7} className="py-10 text-center text-[#94A3B8] font-mono">
                      No bugs filed against this project. Clean pipeline!
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        )}

        {/* Tab 2: Features & Tasks */}
        {activeTab === 'tasks' && (
          <div className="p-4 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
            {workspace.tasks && workspace.tasks.length > 0 ? (
              workspace.tasks.map((t) => (
                <div
                  key={t.id}
                  className="p-4 rounded-lg bg-[#151E2E] border border-[#263247] space-y-2 flex flex-col justify-between"
                >
                  <div>
                    <div className="flex items-center justify-between">
                      <span className="text-[10px] font-mono uppercase text-[#FBBF24]">
                        {t.priority} Priority
                      </span>
                      <StatusBadge status={t.status} size="sm" />
                    </div>
                    <h3 className="text-xs font-bold text-[#F1F5F9] mt-1 line-clamp-2">{t.title}</h3>
                    {t.description && (
                      <p className="text-[11px] text-[#94A3B8] line-clamp-2 mt-1">{t.description}</p>
                    )}
                  </div>

                  <div className="pt-2 border-t border-[#263247]/60 text-[10px] font-mono text-[#94A3B8]">
                    Developer: {t.developer_name || 'Unassigned'}
                  </div>
                </div>
              ))
            ) : (
              <div className="col-span-full text-center py-10 text-xs text-[#94A3B8]">
                No sprint implementation tasks logged for this project.
              </div>
            )}
          </div>
        )}

        {/* Tab 3: Modules */}
        {activeTab === 'modules' && (
          <div className="p-4 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
            {workspace.modules && workspace.modules.length > 0 ? (
              workspace.modules.map((m) => (
                <div key={m.id} className="p-4 rounded-lg bg-[#151E2E] border border-[#263247] space-y-2">
                  <div className="flex items-center justify-between">
                    <h3 className="text-xs font-bold text-[#F1F5F9]">{m.name}</h3>
                    <span className="text-[10px] font-mono text-[#22D3EE]">{m.progress}%</span>
                  </div>
                  <div className="w-full h-1 rounded-full bg-[#0E1420] overflow-hidden">
                    <div className="h-full bg-[#22D3EE] rounded-full" style={{ width: `${m.progress}%` }} />
                  </div>
                  <div className="grid grid-cols-3 gap-1 text-[10px] font-mono text-center pt-2 border-t border-[#263247]/60">
                    <div>{m.apis_count} APIs</div>
                    <div className="text-[#FB4B5F]">{m.bugs_count} Bugs</div>
                    <div className="text-[#FBBF24]">{m.tasks_count} Tasks</div>
                  </div>
                </div>
              ))
            ) : (
              <div className="col-span-full text-center py-10 text-xs text-[#94A3B8]">
                No modules created under this project.
              </div>
            )}
          </div>
        )}

        {/* Tab 4: APIs */}
        {activeTab === 'apis' && (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead>
                <tr className="border-b border-[#263247] bg-[#151E2E]/40 text-[#94A3B8] font-mono uppercase text-[11px]">
                  <th className="px-4 py-3">Method</th>
                  <th className="px-4 py-3">Endpoint Path</th>
                  <th className="px-4 py-3">Description</th>
                  <th className="px-4 py-3 text-right">Health</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#263247]/60 font-mono">
                {workspace.apis && workspace.apis.length > 0 ? (
                  workspace.apis.map((a) => (
                    <tr key={a.id} className="hover:bg-[#151E2E]/60 transition">
                      <td className="px-4 py-2.5 font-bold text-[#22D3EE]">{a.method}</td>
                      <td className="px-4 py-2.5 text-[#F1F5F9]">{a.endpoint}</td>
                      <td className="px-4 py-2.5 text-[#94A3B8] font-sans text-[11px]">{a.name}</td>
                      <td className="px-4 py-2.5 text-right text-[#34D399] uppercase">{a.health_status}</td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan={4} className="py-10 text-center text-[#94A3B8] font-mono">
                      No APIs cataloged for this project.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Add Team Member Modal */}
      <Modal
        isOpen={isAddMemberOpen}
        onClose={() => setIsAddMemberOpen(false)}
        title="Add Engineer to Project Team"
        subtitle={`Grant access to defects, sprint tasks and modules in ${p.name}`}
      >
        <form onSubmit={handleAddMember} className="space-y-4">
          {memberError && (
            <div className="p-2.5 rounded bg-[#FB4B5F]/10 border border-[#FB4B5F]/30 text-xs text-[#FB4B5F]">
              {memberError}
            </div>
          )}

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">SELECT ENGINEER *</label>
            <select
              required
              value={selectedEmpId}
              onChange={(e) => setSelectedEmpId(Number(e.target.value))}
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            >
              <option value="">Select Team Member</option>
              {team.map((emp) => (
                <option key={emp.id} value={emp.id}>
                  {emp.full_name} ({emp.role}) • {emp.email}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">PROJECT ROLE</label>
            <select
              value={projectRole}
              onChange={(e) => setProjectRole(e.target.value)}
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] font-mono focus:outline-none focus:border-[#22D3EE]"
            >
              <option value="developer">Developer</option>
              <option value="qa">QA Specialist</option>
              <option value="lead">Technical Sub-Lead</option>
              <option value="viewer">Viewer / Reviewer</option>
            </select>
          </div>

          <div className="flex items-center justify-end gap-3 pt-3 border-t border-[#263247]">
            <button
              type="button"
              onClick={() => setIsAddMemberOpen(false)}
              className="px-4 py-2 text-xs text-[#94A3B8] hover:text-[#F1F5F9] transition"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmittingMember || !selectedEmpId}
              className="px-4 py-2 text-xs font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] rounded transition shadow disabled:opacity-50"
            >
              {isSubmittingMember ? 'Adding...' : 'Add to Team'}
            </button>
          </div>
        </form>
      </Modal>

      {/* Reassign Project Head Modal */}
      <Modal
        isOpen={isHeadModalOpen}
        onClose={() => setIsHeadModalOpen(false)}
        title="Reassign Project Head"
        subtitle="Only Admins can appoint a new Project Head"
      >
        <form onSubmit={handleUpdateHead} className="space-y-4">
          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">NEW PROJECT HEAD *</label>
            <select
              required
              value={newHeadId}
              onChange={(e) => setNewHeadId(Number(e.target.value))}
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            >
              <option value="">Select Engineer</option>
              {team.map((emp) => (
                <option key={emp.id} value={emp.id}>
                  {emp.full_name} ({emp.role}) • {emp.email}
                </option>
              ))}
            </select>
          </div>

          <div className="flex items-center justify-end gap-3 pt-3 border-t border-[#263247]">
            <button
              type="button"
              onClick={() => setIsHeadModalOpen(false)}
              className="px-4 py-2 text-xs text-[#94A3B8] hover:text-[#F1F5F9] transition"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmittingHead || !newHeadId}
              className="px-4 py-2 text-xs font-semibold bg-[#FBBF24] text-[#080B12] hover:bg-[#F59E0B] rounded transition shadow disabled:opacity-50"
            >
              {isSubmittingHead ? 'Reassigning...' : 'Appoint Project Head'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
};
