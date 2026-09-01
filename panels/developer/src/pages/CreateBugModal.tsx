import React, { useState, useEffect } from 'react';
import { Modal } from '../components/Modal';
import { developerApi } from '../api/developerApi';
import { Project, Module, TeamMember } from '../types/developer';
import { Bug, Plus, AlertCircle } from 'lucide-react';

interface CreateBugModalProps {
  isOpen: boolean;
  onClose: () => void;
  onBugCreated: () => void;
}

export const CreateBugModal: React.FC<CreateBugModalProps> = ({
  isOpen,
  onClose,
  onBugCreated,
}) => {
  const [projects, setProjects] = useState<Project[]>([]);
  const [modules, setModules] = useState<Module[]>([]);
  const [team, setTeam] = useState<TeamMember[]>([]);

  const [projectId, setProjectId] = useState<number | ''>('');
  const [moduleId, setModuleId] = useState<number | ''>('');
  const [title, setTitle] = useState<string>('');
  const [description, setDescription] = useState<string>('');
  const [severity, setSeverity] = useState<string>('high');
  const [priority, setPriority] = useState<string>('high');
  const [environment, setEnvironment] = useState<string>('development');
  const [assignedDevId, setAssignedDevId] = useState<number | ''>('');
  const [stepsToReproduce, setStepsToReproduce] = useState<string>('');
  const [expectedResult, setExpectedResult] = useState<string>('');
  const [actualResult, setActualResult] = useState<string>('');
  const [apiEndpoint, setApiEndpoint] = useState<string>('');

  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (isOpen) {
      developerApi.listProjects().then((projs) => {
        setProjects(projs);
        if (projs.length > 0 && !projectId) {
          setProjectId(projs[0].id);
        }
      });
      developerApi.listTeamMembers().then(setTeam);
    }
  }, [isOpen]);

  useEffect(() => {
    if (projectId) {
      developerApi.listModules(Number(projectId)).then(setModules);
    } else {
      setModules([]);
    }
  }, [projectId]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!projectId || !title.trim()) {
      setError('Please select a project and enter a defect title.');
      return;
    }

    setIsSubmitting(true);
    setError(null);
    try {
      await developerApi.createBug({
        project_id: Number(projectId),
        module_id: moduleId ? Number(moduleId) : undefined,
        title: title.trim(),
        description: description.trim() || undefined,
        severity,
        priority,
        environment,
        assigned_developer_id: assignedDevId ? Number(assignedDevId) : undefined,
        steps_to_reproduce: stepsToReproduce.trim() || undefined,
        expected_result: expectedResult.trim() || undefined,
        actual_result: actualResult.trim() || undefined,
        api_endpoint: apiEndpoint.trim() || undefined,
      });

      // Reset form
      setTitle('');
      setDescription('');
      setStepsToReproduce('');
      setExpectedResult('');
      setActualResult('');
      setApiEndpoint('');
      onBugCreated();
    } catch (err: any) {
      setError(err?.response?.data?.detail || 'Failed to file defect.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const developers = team.filter((m) => m.role === 'developer' || m.role === 'admin');

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title="File New Engineering Defect"
      subtitle="Creates a defect ticket with state machine tracking & notifications."
      maxWidth="2xl"
    >
      <form onSubmit={handleSubmit} className="space-y-4">
        {error && (
          <div className="p-3 rounded bg-[#FB4B5F]/10 border border-[#FB4B5F]/30 text-xs text-[#FB4B5F] flex items-center gap-2">
            <AlertCircle className="w-4 h-4 shrink-0" />
            <span>{error}</span>
          </div>
        )}

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          {/* Project */}
          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">PROJECT *</label>
            <select
              required
              value={projectId}
              onChange={(e) => setProjectId(Number(e.target.value))}
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            >
              <option value="">Select Project</option>
              {projects.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name}
                </option>
              ))}
            </select>
          </div>

          {/* Module */}
          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">MODULE</label>
            <select
              value={moduleId}
              onChange={(e) => setModuleId(e.target.value ? Number(e.target.value) : '')}
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            >
              <option value="">(Optional) General / Platform</option>
              {modules.map((m) => (
                <option key={m.id} value={m.id}>
                  {m.name}
                </option>
              ))}
            </select>
          </div>
        </div>

        {/* Title */}
        <div>
          <label className="block text-xs font-mono text-[#94A3B8] mb-1">DEFECT TITLE *</label>
          <input
            type="text"
            required
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="e.g. 500 error on checkout when applying promotional coupon"
            className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
          />
        </div>

        {/* Severity, Priority, Environment, Assignee */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">SEVERITY</label>
            <select
              value={severity}
              onChange={(e) => setSeverity(e.target.value)}
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-2.5 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            >
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
              <option value="critical">Critical</option>
            </select>
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">PRIORITY</label>
            <select
              value={priority}
              onChange={(e) => setPriority(e.target.value)}
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-2.5 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            >
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
              <option value="critical">Critical</option>
            </select>
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">ENVIRONMENT</label>
            <select
              value={environment}
              onChange={(e) => setEnvironment(e.target.value)}
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-2.5 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            >
              <option value="development">Development</option>
              <option value="staging">Staging</option>
              <option value="production">Production</option>
            </select>
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">ASSIGN DEVELOPER</label>
            <select
              value={assignedDevId}
              onChange={(e) => setAssignedDevId(e.target.value ? Number(e.target.value) : '')}
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-2.5 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            >
              <option value="">(Unassigned)</option>
              {developers.map((d) => (
                <option key={d.id} value={d.id}>
                  {d.full_name}
                </option>
              ))}
            </select>
          </div>
        </div>

        {/* Steps to Reproduce */}
        <div>
          <label className="block text-xs font-mono text-[#94A3B8] mb-1">
            STEPS TO REPRODUCE
          </label>
          <textarea
            rows={3}
            value={stepsToReproduce}
            onChange={(e) => setStepsToReproduce(e.target.value)}
            placeholder="1. Navigate to /checkout&#10;2. Apply coupon SAVE50&#10;3. Click Proceed to Payment"
            className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
          />
        </div>

        {/* Expected & Actual Result */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">EXPECTED RESULT</label>
            <textarea
              rows={2}
              value={expectedResult}
              onChange={(e) => setExpectedResult(e.target.value)}
              placeholder="Coupon discount should apply to cart total."
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            />
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">ACTUAL RESULT</label>
            <textarea
              rows={2}
              value={actualResult}
              onChange={(e) => setActualResult(e.target.value)}
              placeholder="500 Internal Server Error returned with error message."
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            />
          </div>
        </div>

        {/* API Endpoint reference */}
        <div>
          <label className="block text-xs font-mono text-[#94A3B8] mb-1">
            ASSOCIATED API ENDPOINT (IF APPLICABLE)
          </label>
          <input
            type="text"
            value={apiEndpoint}
            onChange={(e) => setApiEndpoint(e.target.value)}
            placeholder="e.g. POST /api/v1/orders/create"
            className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] font-mono focus:outline-none focus:border-[#22D3EE]"
          />
        </div>

        {/* Submit */}
        <div className="flex items-center justify-end gap-3 pt-3 border-t border-[#263247]">
          <button
            type="button"
            onClick={onClose}
            disabled={isSubmitting}
            className="px-4 py-2 text-xs font-medium text-[#94A3B8] hover:text-[#F1F5F9] transition"
          >
            Cancel
          </button>
          <button
            type="submit"
            disabled={isSubmitting}
            className="px-5 py-2 text-xs font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] rounded-md transition shadow-md flex items-center gap-1.5"
          >
            {isSubmitting ? 'Registering Defect...' : 'Register Defect'}
          </button>
        </div>
      </form>
    </Modal>
  );
};
