import React, { useEffect, useState } from 'react';
import { developerApi } from '../api/developerApi';
import { Project, TeamMember } from '../types/developer';
import { Modal } from '../components/Modal';
import {
  FolderGit2,
  Boxes,
  Network,
  Bug,
  CheckSquare,
  Plus,
  ExternalLink,
  GitBranch,
  ArrowRight,
} from 'lucide-react';
import { Link } from 'react-router-dom';

export const ProjectsPage: React.FC = () => {
  const [projects, setProjects] = useState<Project[]>([]);
  const [team, setTeam] = useState<TeamMember[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [isModalOpen, setIsModalOpen] = useState<boolean>(false);

  // New Project Form
  const [name, setName] = useState<string>('');
  const [slug, setSlug] = useState<string>('');
  const [description, setDescription] = useState<string>('');
  const [repoUrl, setRepoUrl] = useState<string>('');
  const [projectHeadId, setProjectHeadId] = useState<number | ''>('');
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const fetchProjects = async () => {
    setIsLoading(true);
    try {
      const data = await developerApi.listProjects();
      setProjects(data);
    } catch {
      // ignore
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchProjects();
    developerApi.listTeamMembers().then(setTeam);
  }, []);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !slug.trim()) return;
    setIsSubmitting(true);
    setError(null);
    try {
      await developerApi.createProject({
        name: name.trim(),
        slug: slug.trim(),
        description: description.trim() || undefined,
        repository_url: repoUrl.trim() || undefined,
        project_head_id: projectHeadId ? Number(projectHeadId) : undefined,
      });
      setName('');
      setSlug('');
      setDescription('');
      setRepoUrl('');
      setProjectHeadId('');
      setIsModalOpen(false);
      fetchProjects();
    } catch (err: any) {
      setError(err?.response?.data?.detail || 'Failed to create project.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-lg font-bold text-[#F1F5F9] uppercase tracking-wide flex items-center gap-2">
            <FolderGit2 className="w-5 h-5 text-[#38BDF8]" /> Engineering Projects Directory
          </h1>
          <p className="text-xs text-[#94A3B8] font-mono mt-0.5">
            MICROSERVICES, CLIENT APPLICATIONS & INFRASTRUCTURE REPOSITORIES
          </p>
        </div>
        <button
          onClick={() => setIsModalOpen(true)}
          className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-md text-xs font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] transition shadow"
        >
          <Plus className="w-4 h-4" /> Add Project
        </button>
      </div>

      {/* Projects Grid */}
      {isLoading ? (
        <div className="text-center py-20 text-xs font-mono text-[#22D3EE] animate-pulse">
          QUERYING PLATFORM REPOSITORIES...
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {projects.map((p) => (
            <div
              key={p.id}
              className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4 hover:border-[#22D3EE]/40 transition flex flex-col justify-between"
            >
              <div className="space-y-3">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <div className="flex items-center gap-2">
                      <Link
                        to={`/projects/${p.id}`}
                        className="text-sm font-bold text-[#F1F5F9] hover:text-[#22D3EE] transition"
                      >
                        {p.name}
                      </Link>
                      <span className="text-[10px] font-mono uppercase px-1.5 py-0.2 rounded bg-[#151E2E] text-[#34D399] border border-[#34D399]/30">
                        {p.status}
                      </span>
                    </div>
                    <div className="text-[11px] font-mono text-[#475569] mt-0.5">{p.slug}</div>
                  </div>
                  {p.repository_url && (
                    <a
                      href={p.repository_url}
                      target="_blank"
                      rel="noreferrer"
                      className="p-1.5 rounded bg-[#151E2E] hover:bg-[#1B2638] text-[#94A3B8] hover:text-[#F1F5F9] border border-[#263247] transition"
                      title="Open Repository"
                    >
                      <ExternalLink className="w-3.5 h-3.5" />
                    </a>
                  )}
                </div>

                {/* Project Head Tag */}
                <div className="flex items-center gap-1.5 text-xs font-mono text-[#94A3B8] bg-[#151E2E] px-2.5 py-1 rounded border border-[#263247]">
                  <span className="text-[10px] text-[#FDE047] uppercase font-bold">PROJECT HEAD:</span>
                  <span className="text-[#F1F5F9] font-medium truncate">
                    {p.project_head_name || 'Unassigned'}
                  </span>
                </div>

                {p.description && (
                  <p className="text-xs text-[#94A3B8] line-clamp-2 leading-relaxed">{p.description}</p>
                )}

                {/* Progress */}
                <div className="space-y-1.5">
                  <div className="flex justify-between text-[11px] font-mono">
                    <span className="text-[#94A3B8]">Maturity</span>
                    <span className="text-[#22D3EE] font-bold">{p.progress}%</span>
                  </div>
                  <div className="w-full h-1.5 rounded-full bg-[#151E2E] overflow-hidden">
                    <div
                      className="h-full bg-[#22D3EE] rounded-full transition-all"
                      style={{ width: `${p.progress}%` }}
                    />
                  </div>
                </div>

                {/* Metrics row */}
                <div className="grid grid-cols-4 gap-2 pt-3 border-t border-[#263247]/60 text-center font-mono text-xs">
                  <div className="p-2 rounded bg-[#151E2E]">
                    <div className="text-[10px] text-[#94A3B8]">MODULES</div>
                    <div className="font-bold text-[#F1F5F9]">{p.modules_count}</div>
                  </div>
                  <div className="p-2 rounded bg-[#151E2E]">
                    <div className="text-[10px] text-[#94A3B8]">APIS</div>
                    <div className="font-bold text-[#34D399]">{p.apis_count}</div>
                  </div>
                  <div className="p-2 rounded bg-[#151E2E]">
                    <div className="text-[10px] text-[#94A3B8]">OPEN BUGS</div>
                    <div className="font-bold text-[#FB4B5F]">{p.open_bugs_count}</div>
                  </div>
                  <div className="p-2 rounded bg-[#151E2E]">
                    <div className="text-[10px] text-[#94A3B8]">TASKS</div>
                    <div className="font-bold text-[#FBBF24]">{p.active_tasks_count}</div>
                  </div>
                </div>
              </div>

              {/* Enter Workspace Button */}
              <div className="pt-2">
                <Link
                  to={`/projects/${p.id}`}
                  className="w-full py-1.5 px-3 rounded bg-[#151E2E] hover:bg-[#22D3EE] text-[#22D3EE] hover:text-[#080B12] text-xs font-mono font-semibold transition flex items-center justify-center gap-1.5 border border-[#22D3EE]/30"
                >
                  Enter Project Workspace & Team <ArrowRight className="w-3.5 h-3.5" />
                </Link>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Create Project Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title="Register New Engineering Project"
        subtitle="Adds an architectural project container to track modules, APIs & defects."
      >
        <form onSubmit={handleCreate} className="space-y-4">
          {error && <div className="text-xs text-[#FB4B5F]">{error}</div>}

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">PROJECT NAME *</label>
            <input
              type="text"
              required
              value={name}
              onChange={(e) => {
                setName(e.target.value);
                if (!slug) setSlug(e.target.value.toLowerCase().replace(/\s+/g, '-'));
              }}
              placeholder="e.g. AM5 Payments Gateway"
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            />
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">PROJECT SLUG *</label>
            <input
              type="text"
              required
              value={slug}
              onChange={(e) => setSlug(e.target.value)}
              placeholder="e.g. am5-payments-gateway"
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] font-mono focus:outline-none focus:border-[#22D3EE]"
            />
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">DESIGNATE PROJECT HEAD</label>
            <select
              value={projectHeadId}
              onChange={(e) => setProjectHeadId(e.target.value ? Number(e.target.value) : '')}
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            >
              <option value="">(Auto-assign to creator)</option>
              {team.map((t) => (
                <option key={t.id} value={t.id}>
                  {t.full_name} ({t.role}) • {t.email}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">DESCRIPTION</label>
            <textarea
              rows={3}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Primary scope, tech stack, and service boundaries..."
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            />
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">
              REPOSITORY URL (GIT)
            </label>
            <input
              type="text"
              value={repoUrl}
              onChange={(e) => setRepoUrl(e.target.value)}
              placeholder="https://github.com/am5royal/payments-service"
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] font-mono focus:outline-none focus:border-[#22D3EE]"
            />
          </div>

          <div className="flex items-center justify-end gap-3 pt-3 border-t border-[#263247]">
            <button
              type="button"
              onClick={() => setIsModalOpen(false)}
              className="px-4 py-2 text-xs text-[#94A3B8] hover:text-[#F1F5F9] transition"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="px-4 py-2 text-xs font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] rounded transition shadow"
            >
              {isSubmitting ? 'Registering...' : 'Register Project'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
};
