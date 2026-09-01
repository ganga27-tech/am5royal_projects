import React, { useEffect, useState } from 'react';
import { developerApi } from '../api/developerApi';
import { DevTask, Project, TeamMember, TaskStatus } from '../types/developer';
import { StatusBadge } from '../components/StatusBadge';
import { Modal } from '../components/Modal';
import { CheckSquare, Plus, Clock, User, CheckCircle2, ArrowRight } from 'lucide-react';

export const TasksPage: React.FC = () => {
  const [tasks, setTasks] = useState<DevTask[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const [team, setTeam] = useState<TeamMember[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);

  // New Task Modal
  const [isModalOpen, setIsModalOpen] = useState<boolean>(false);
  const [projectId, setProjectId] = useState<number | ''>('');
  const [title, setTitle] = useState<string>('');
  const [description, setDescription] = useState<string>('');
  const [priority, setPriority] = useState<string>('high');
  const [assignedDevId, setAssignedDevId] = useState<number | ''>('');
  const [dueDate, setDueDate] = useState<string>('');
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);

  const fetchTasks = async () => {
    setIsLoading(true);
    try {
      const data = await developerApi.listTasks();
      setTasks(data);
    } catch {
      // ignore
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchTasks();
    developerApi.listProjects().then(setProjects);
    developerApi.listTeamMembers().then(setTeam);
  }, []);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!projectId || !title.trim()) return;
    setIsSubmitting(true);
    try {
      await developerApi.createTask({
        project_id: Number(projectId),
        title: title.trim(),
        description: description.trim() || undefined,
        priority,
        assigned_developer_id: assignedDevId ? Number(assignedDevId) : undefined,
        due_date: dueDate || undefined,
      });
      setTitle('');
      setDescription('');
      setIsModalOpen(false);
      fetchTasks();
    } catch (err: any) {
      alert(err?.response?.data?.detail || 'Failed to create task.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleUpdateStatus = async (taskId: number, newStatus: TaskStatus) => {
    try {
      await developerApi.updateTask(taskId, { status: newStatus });
      fetchTasks();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="text-lg font-bold text-[#F1F5F9] uppercase tracking-wide flex items-center gap-2">
            <CheckSquare className="w-5 h-5 text-[#FBBF24]" /> Sprint Tasks & Engineering Backlog
          </h1>
          <p className="text-xs text-[#94A3B8] font-mono mt-0.5">
            FEATURE DELIVERABLES, INFRASTRUCTURE REFACTORING & BACKLOG
          </p>
        </div>
        <button
          onClick={() => {
            if (projects.length > 0 && !projectId) setProjectId(projects[0].id);
            setIsModalOpen(true);
          }}
          className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-md text-xs font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] transition shadow"
        >
          <Plus className="w-4 h-4" /> Create Sprint Task
        </button>
      </div>

      {/* Tasks Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {isLoading ? (
          <div className="col-span-full text-center py-20 text-xs font-mono text-[#FBBF24] animate-pulse">
            LOADING SPRINT TASKS...
          </div>
        ) : tasks && tasks.length > 0 ? (
          tasks.map((task) => (
            <div
              key={task.id}
              className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-3 flex flex-col justify-between hover:border-[#FBBF24]/40 transition"
            >
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-[10px] font-mono uppercase px-1.5 py-0.2 rounded bg-[#151E2E] text-[#94A3B8] border border-[#263247]">
                    {task.project_name || 'AM5 Platform'}
                  </span>
                  <StatusBadge status={task.status} size="sm" />
                </div>

                <h3 className="text-sm font-bold text-[#F1F5F9] leading-snug">{task.title}</h3>

                {task.description && (
                  <p className="text-xs text-[#94A3B8] line-clamp-3 leading-relaxed">
                    {task.description}
                  </p>
                )}
              </div>

              <div className="space-y-3 pt-3 border-t border-[#263247]/60">
                <div className="flex items-center justify-between text-[11px] font-mono text-[#94A3B8]">
                  <span className="flex items-center gap-1">
                    <User className="w-3 h-3 text-[#475569]" />
                    {task.developer_name || 'Unassigned'}
                  </span>
                  <span className="text-[#FBBF24] uppercase">{task.priority}</span>
                </div>

                {/* Quick Status transition */}
                <div className="flex items-center gap-1.5">
                  {task.status === 'todo' && (
                    <button
                      onClick={() => handleUpdateStatus(task.id, 'in_progress')}
                      className="w-full py-1 text-[11px] font-semibold font-mono rounded bg-[#151E2E] hover:bg-[#22D3EE] text-[#94A3B8] hover:text-[#080B12] border border-[#263247] transition text-center"
                    >
                      Start Task
                    </button>
                  )}
                  {task.status === 'in_progress' && (
                    <button
                      onClick={() => handleUpdateStatus(task.id, 'completed')}
                      className="w-full py-1 text-[11px] font-semibold font-mono rounded bg-[#0E241B] hover:bg-[#34D399] text-[#34D399] hover:text-[#080B12] border border-[#34D399]/30 transition text-center"
                    >
                      Mark Complete
                    </button>
                  )}
                  {task.status === 'completed' && (
                    <div className="w-full py-1 text-[10px] font-mono text-[#34D399] text-center flex items-center justify-center gap-1">
                      <CheckCircle2 className="w-3.5 h-3.5" /> Completed
                    </div>
                  )}
                </div>
              </div>
            </div>
          ))
        ) : (
          <div className="col-span-full text-center py-12 text-xs text-[#94A3B8]">
            No sprint tasks found.
          </div>
        )}
      </div>

      {/* Create Task Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title="Create Sprint Task"
        subtitle="Schedules deliverables for developers with priority & due dates."
      >
        <form onSubmit={handleCreate} className="space-y-4">
          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">PROJECT *</label>
            <select
              required
              value={projectId}
              onChange={(e) => setProjectId(Number(e.target.value))}
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
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">TASK TITLE *</label>
            <input
              type="text"
              required
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="e.g. Implement refresh token rotation in Auth middleware"
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            />
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">DESCRIPTION</label>
            <textarea
              rows={3}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Technical scope and acceptance criteria..."
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-mono text-[#94A3B8] mb-1">PRIORITY</label>
              <select
                value={priority}
                onChange={(e) => setPriority(e.target.value)}
                className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
              >
                <option value="low">Low</option>
                <option value="medium">Medium</option>
                <option value="high">High</option>
                <option value="critical">Critical</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-mono text-[#94A3B8] mb-1">ASSIGN DEVELOPER</label>
              <select
                value={assignedDevId}
                onChange={(e) => setAssignedDevId(e.target.value ? Number(e.target.value) : '')}
                className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
              >
                <option value="">(Unassigned)</option>
                {team
                  .filter((m) => m.role === 'developer' || m.role === 'admin')
                  .map((m) => (
                    <option key={m.id} value={m.id}>
                      {m.full_name}
                    </option>
                  ))}
              </select>
            </div>
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
              {isSubmitting ? 'Creating...' : 'Create Task'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
};
