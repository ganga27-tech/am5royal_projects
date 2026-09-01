import React, { useEffect, useState } from 'react';
import { developerApi } from '../api/developerApi';
import { Module, Project } from '../types/developer';
import { Modal } from '../components/Modal';
import { Boxes, Plus, Network, Bug, CheckSquare, FolderGit2 } from 'lucide-react';

export const ModulesPage: React.FC = () => {
  const [modules, setModules] = useState<Module[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const [selectedProjectId, setSelectedProjectId] = useState<number | ''>('');
  const [isLoading, setIsLoading] = useState<boolean>(true);

  // New Module Form
  const [isModalOpen, setIsModalOpen] = useState<boolean>(false);
  const [modProjectId, setModProjectId] = useState<number | ''>('');
  const [name, setName] = useState<string>('');
  const [description, setDescription] = useState<string>('');
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const fetchModules = async () => {
    setIsLoading(true);
    try {
      const data = await developerApi.listModules(
        selectedProjectId ? Number(selectedProjectId) : undefined
      );
      setModules(data);
    } catch {
      // ignore
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    developerApi.listProjects().then(setProjects);
  }, []);

  useEffect(() => {
    fetchModules();
  }, [selectedProjectId]);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!modProjectId || !name.trim()) return;
    setIsSubmitting(true);
    setError(null);
    try {
      await developerApi.createModule({
        project_id: Number(modProjectId),
        name: name.trim(),
        description: description.trim() || undefined,
      });
      setName('');
      setDescription('');
      setIsModalOpen(false);
      fetchModules();
    } catch (err: any) {
      setError(err?.response?.data?.detail || 'Failed to create module.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="text-lg font-bold text-[#F1F5F9] uppercase tracking-wide flex items-center gap-2">
            <Boxes className="w-5 h-5 text-[#8B5CF6]" /> System Modules Architecture
          </h1>
          <p className="text-xs text-[#94A3B8] font-mono mt-0.5">
            LOGICAL DOMAIN BOUNDARIES, ENDPOINTS & ASSOCIATED DEFECTS
          </p>
        </div>
        <div className="flex items-center gap-3">
          <select
            value={selectedProjectId}
            onChange={(e) => setSelectedProjectId(e.target.value ? Number(e.target.value) : '')}
            className="rounded bg-[#151E2E] border border-[#263247] px-3 py-1.5 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
          >
            <option value="">All Projects</option>
            {projects.map((p) => (
              <option key={p.id} value={p.id}>
                {p.name}
              </option>
            ))}
          </select>
          <button
            onClick={() => {
              if (projects.length > 0 && !modProjectId) setModProjectId(projects[0].id);
              setIsModalOpen(true);
            }}
            className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-md text-xs font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] transition shadow"
          >
            <Plus className="w-4 h-4" /> Add Module
          </button>
        </div>
      </div>

      {/* Modules Grid */}
      {isLoading ? (
        <div className="text-center py-20 text-xs font-mono text-[#8B5CF6] animate-pulse">
          FETCHING DOMAIN MODULES...
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {modules.map((m) => (
            <div
              key={m.id}
              className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-3 hover:border-[#8B5CF6]/40 transition"
            >
              <div className="flex items-start justify-between">
                <div>
                  <h2 className="text-sm font-bold text-[#F1F5F9]">{m.name}</h2>
                  <span className="text-[10px] font-mono uppercase px-1.5 py-0.2 rounded bg-[#151E2E] text-[#A78BFA] border border-[#8B5CF6]/30">
                    {m.status}
                  </span>
                </div>
              </div>

              {m.description && (
                <p className="text-xs text-[#94A3B8] line-clamp-2 leading-relaxed">{m.description}</p>
              )}

              {/* Progress */}
              <div className="space-y-1">
                <div className="flex justify-between text-[10px] font-mono">
                  <span className="text-[#94A3B8]">Maturity</span>
                  <span className="text-[#8B5CF6] font-bold">{m.progress}%</span>
                </div>
                <div className="w-full h-1 rounded-full bg-[#151E2E] overflow-hidden">
                  <div
                    className="h-full bg-[#8B5CF6] rounded-full transition-all"
                    style={{ width: `${m.progress}%` }}
                  />
                </div>
              </div>

              {/* Stats */}
              <div className="grid grid-cols-3 gap-2 pt-2 border-t border-[#263247]/60 text-center font-mono text-[11px]">
                <div className="p-1.5 rounded bg-[#151E2E]">
                  <div className="text-[9px] text-[#94A3B8]">APIS</div>
                  <div className="font-bold text-[#34D399]">{m.apis_count}</div>
                </div>
                <div className="p-1.5 rounded bg-[#151E2E]">
                  <div className="text-[9px] text-[#94A3B8]">BUGS</div>
                  <div className="font-bold text-[#FB4B5F]">{m.bugs_count}</div>
                </div>
                <div className="p-1.5 rounded bg-[#151E2E]">
                  <div className="text-[9px] text-[#94A3B8]">TASKS</div>
                  <div className="font-bold text-[#FBBF24]">{m.tasks_count}</div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Create Module Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title="Add System Module"
        subtitle="Deconstructs projects into testable domain boundaries."
      >
        <form onSubmit={handleCreate} className="space-y-4">
          {error && <div className="text-xs text-[#FB4B5F]">{error}</div>}

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">PARENT PROJECT *</label>
            <select
              required
              value={modProjectId}
              onChange={(e) => setModProjectId(Number(e.target.value))}
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
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">MODULE NAME *</label>
            <input
              type="text"
              required
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="e.g. Authentication & Authorization"
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            />
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">DESCRIPTION</label>
            <textarea
              rows={3}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Responsibilities, schemas, business logic..."
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
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
              {isSubmitting ? 'Adding...' : 'Add Module'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
};
