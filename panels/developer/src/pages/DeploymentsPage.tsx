import React, { useEffect, useState } from 'react';
import { developerApi } from '../api/developerApi';
import { Deployment, Project } from '../types/developer';
import { Modal } from '../components/Modal';
import { ConfirmDialog } from '../components/ConfirmDialog';
import { Rocket, Plus, GitCommit, CheckCircle, Clock, Server, RotateCcw, Play, CheckCircle2, ShieldAlert } from 'lucide-react';

export const DeploymentsPage: React.FC = () => {
  const [deployments, setDeployments] = useState<Deployment[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);

  // New Deployment Modal
  const [isModalOpen, setIsModalOpen] = useState<boolean>(false);
  const [projectId, setProjectId] = useState<number | ''>('');
  const [environment, setEnvironment] = useState<string>('DEVELOPMENT');
  const [version, setVersion] = useState<string>('v1.0.4');
  const [commitHash, setCommitHash] = useState<string>('');
  const [changelog, setChangelog] = useState<string>('');
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);

  // Rollback / Deploy Confirmation Dialog
  const [confirmAction, setConfirmAction] = useState<{
    type: 'deploy' | 'rollback';
    env: string;
    version: string;
  } | null>(null);
  const [isConfirming, setIsConfirming] = useState<boolean>(false);

  const fetchDeployments = async () => {
    setIsLoading(true);
    try {
      const data = await developerApi.listDeployments();
      setDeployments(data);
    } catch {
      // ignore
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchDeployments();
    developerApi.listProjects().then(setProjects);
  }, []);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!projectId || !version.trim()) return;
    setIsSubmitting(true);
    try {
      await developerApi.createDeployment({
        project_id: Number(projectId),
        environment,
        version: version.trim(),
        commit_hash: commitHash.trim() || undefined,
        changelog: changelog.trim() || undefined,
      });
      setIsModalOpen(false);
      fetchDeployments();
    } catch (err: any) {
      alert(err?.response?.data?.detail || 'Failed to record deployment.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleExecuteConfirmedAction = async () => {
    if (!confirmAction) return;
    setIsConfirming(true);
    try {
      const targetProjId = projects.length > 0 ? projects[0].id : 1;
      const isRollback = confirmAction.type === 'rollback';
      await developerApi.createDeployment({
        project_id: targetProjId,
        environment: confirmAction.env,
        version: isRollback ? `${confirmAction.version}-rollback` : confirmAction.version,
        changelog: isRollback
          ? `Emergency rollback executed on ${confirmAction.env} by engineer.`
          : `Release deployment executed to ${confirmAction.env}.`,
      });
      setConfirmAction(null);
      fetchDeployments();
    } catch (err: any) {
      alert(err?.response?.data?.detail || 'Action failed.');
    } finally {
      setIsConfirming(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-lg font-bold text-[#F1F5F9] uppercase tracking-wide flex items-center gap-2">
            <Rocket className="w-5 h-5 text-[#22D3EE]" /> Release Deployments & CI/CD Trail
          </h1>
          <p className="text-xs text-[#94A3B8] font-mono mt-0.5">
            HOSTINGER VPS AUTOMATED CONTAINERS & PRODUCTION RELEASES
          </p>
        </div>
        <button
          onClick={() => {
            if (projects.length > 0 && !projectId) setProjectId(projects[0].id);
            setIsModalOpen(true);
          }}
          className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-md text-xs font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] transition shadow"
        >
          <Plus className="w-4 h-4" /> Record Deployment
        </button>
      </div>

      {/* 3 Main Environment Status Cards (Section 11) */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {/* Development */}
        <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-4 space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-mono uppercase px-2 py-0.5 rounded bg-[#151E2E] text-[#38BDF8] border border-[#38BDF8]/30">
              DEVELOPMENT
            </span>
            <span className="text-xs font-mono text-[#34D399] flex items-center gap-1">
              <CheckCircle2 className="w-3.5 h-3.5" /> ACTIVE
            </span>
          </div>
          <div>
            <div className="text-sm font-bold font-mono text-[#F1F5F9]">v1.2.4-dev</div>
            <div className="text-[11px] text-[#94A3B8] font-mono mt-0.5">Hostinger Dev Sandbox • Node/Python</div>
          </div>
          <button
            onClick={() => {
              setEnvironment('DEVELOPMENT');
              setVersion('v1.2.5-dev');
              if (projects.length > 0) setProjectId(projects[0].id);
              setIsModalOpen(true);
            }}
            className="w-full py-1.5 px-3 rounded bg-[#151E2E] hover:bg-[#1B2638] text-xs font-mono text-[#38BDF8] border border-[#38BDF8]/30 transition flex items-center justify-center gap-1.5"
          >
            <Play className="w-3 h-3" /> Deploy Dev Build
          </button>
        </div>

        {/* Staging */}
        <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-4 space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-mono uppercase px-2 py-0.5 rounded bg-[#1C1635] text-[#A78BFA] border border-[#8B5CF6]/30">
              STAGING
            </span>
            <span className="text-xs font-mono text-[#FBBF24] flex items-center gap-1">
              <Clock className="w-3.5 h-3.5" /> PRE-PROD STABLE
            </span>
          </div>
          <div>
            <div className="text-sm font-bold font-mono text-[#F1F5F9]">v1.2.3-rc</div>
            <div className="text-[11px] text-[#94A3B8] font-mono mt-0.5">QA Verification Pipeline • Staging VPC</div>
          </div>
          <button
            onClick={() => {
              setEnvironment('STAGING');
              setVersion('v1.2.3-rc2');
              if (projects.length > 0) setProjectId(projects[0].id);
              setIsModalOpen(true);
            }}
            className="w-full py-1.5 px-3 rounded bg-[#151E2E] hover:bg-[#1B2638] text-xs font-mono text-[#A78BFA] border border-[#8B5CF6]/30 transition flex items-center justify-center gap-1.5"
          >
            <Play className="w-3 h-3" /> Deploy to Staging
          </button>
        </div>

        {/* Production */}
        <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-4 space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-mono uppercase px-2 py-0.5 rounded bg-[#2A1015] text-[#FB4B5F] border border-[#FB4B5F]/30 font-semibold">
              PRODUCTION
            </span>
            <span className="text-xs font-mono text-[#34D399] flex items-center gap-1">
              <CheckCircle2 className="w-3.5 h-3.5" /> LIVE • 99.8%
            </span>
          </div>
          <div>
            <div className="text-sm font-bold font-mono text-[#F1F5F9]">v1.2.0-prod</div>
            <div className="text-[11px] text-[#94A3B8] font-mono mt-0.5">Hostinger Primary VPS Cluster • Port 8000</div>
          </div>
          <div className="grid grid-cols-2 gap-2">
            <button
              onClick={() => {
                setConfirmAction({
                  type: 'deploy',
                  env: 'PRODUCTION',
                  version: 'v1.2.1-prod',
                });
              }}
              className="py-1.5 px-2 rounded bg-[#22D3EE] hover:bg-[#06B6D4] text-[#080B12] text-xs font-semibold font-mono transition flex items-center justify-center gap-1 shadow"
            >
              <Rocket className="w-3 h-3" /> Deploy
            </button>
            <button
              onClick={() => {
                setConfirmAction({
                  type: 'rollback',
                  env: 'PRODUCTION',
                  version: 'v1.1.9',
                });
              }}
              className="py-1.5 px-2 rounded bg-[#151E2E] hover:bg-[#FB4B5F]/20 text-[#FB4B5F] text-xs font-mono border border-[#FB4B5F]/40 transition flex items-center justify-center gap-1"
            >
              <RotateCcw className="w-3 h-3" /> Rollback
            </button>
          </div>
        </div>
      </div>

      {/* Deployments Table */}
      <div className="rounded-lg bg-[#0E1420] border border-[#263247] overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="border-b border-[#263247] bg-[#151E2E]/60 text-[#94A3B8] font-mono uppercase text-[11px]">
                <th className="px-4 py-3">Version</th>
                <th className="px-4 py-3">Environment</th>
                <th className="px-4 py-3">Project</th>
                <th className="px-4 py-3">Commit Reference</th>
                <th className="px-4 py-3">Changelog Summary</th>
                <th className="px-4 py-3">Deployer</th>
                <th className="px-4 py-3">Timestamp</th>
                <th className="px-4 py-3 text-right">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#263247]/60">
              {isLoading ? (
                <tr>
                  <td colSpan={8} className="py-12 text-center text-[#22D3EE] font-mono animate-pulse">
                    QUERYING DEPLOYMENT REGISTRY...
                  </td>
                </tr>
              ) : deployments && deployments.length > 0 ? (
                deployments.map((d) => (
                  <tr key={d.id} className="hover:bg-[#151E2E]/60 transition">
                    <td className="px-4 py-3 font-mono font-bold text-[#F1F5F9]">{d.version}</td>
                    <td className="px-4 py-3 whitespace-nowrap">
                      <span
                        className={`text-[10px] font-mono uppercase px-2 py-0.5 rounded border ${
                          d.environment === 'PRODUCTION'
                            ? 'bg-[#2A1015] text-[#FB4B5F] border-[#FB4B5F]/30 font-semibold'
                            : 'bg-[#1C1635] text-[#A78BFA] border-[#8B5CF6]/30'
                        }`}
                      >
                        {d.environment}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-[#F1F5F9]">{d.project_name}</td>
                    <td className="px-4 py-3 font-mono text-[#22D3EE]">
                      {d.commit_hash ? `#${d.commit_hash}` : 'HEAD'}
                    </td>
                    <td className="px-4 py-3 text-[#94A3B8] max-w-xs truncate">
                      {d.changelog || 'Automated deployment sync'}
                    </td>
                    <td className="px-4 py-3 font-mono text-[#94A3B8]">
                      {d.deployer_name || 'System CI/CD'}
                    </td>
                    <td className="px-4 py-3 font-mono text-[11px] text-[#475569] whitespace-nowrap">
                      {new Date(d.deployed_at).toLocaleString()}
                    </td>
                    <td className="px-4 py-3 text-right whitespace-nowrap">
                      <span className="inline-flex items-center gap-1 font-mono text-xs text-[#34D399]">
                        <CheckCircle className="w-3.5 h-3.5" />
                        {d.status.toUpperCase()}
                      </span>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={8} className="py-8 text-center text-[#94A3B8] font-mono">
                    No deployment records found.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Record Deployment Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title="Record Production Deployment"
        subtitle="Appends an immutable deployment record into the engineering audit trail."
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

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-mono text-[#94A3B8] mb-1">ENVIRONMENT *</label>
              <select
                value={environment}
                onChange={(e) => setEnvironment(e.target.value)}
                className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
              >
                <option value="DEVELOPMENT">DEVELOPMENT</option>
                <option value="STAGING">STAGING</option>
                <option value="PRODUCTION">PRODUCTION</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-mono text-[#94A3B8] mb-1">VERSION TAG *</label>
              <input
                type="text"
                required
                value={version}
                onChange={(e) => setVersion(e.target.value)}
                placeholder="e.g. v1.2.0"
                className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] font-mono focus:outline-none focus:border-[#22D3EE]"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">GIT COMMIT HASH</label>
            <input
              type="text"
              value={commitHash}
              onChange={(e) => setCommitHash(e.target.value)}
              placeholder="e.g. 7c8f2a1"
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] font-mono focus:outline-none focus:border-[#22D3EE]"
            />
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">CHANGELOG NOTES</label>
            <textarea
              rows={3}
              value={changelog}
              onChange={(e) => setChangelog(e.target.value)}
              placeholder="Summary of bug fixes, patches, schema migrations..."
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
              {isSubmitting ? 'Recording...' : 'Record Deployment'}
            </button>
          </div>
        </form>
      </Modal>

      {/* Deploy / Rollback Confirmation Dialog */}
      <ConfirmDialog
        isOpen={!!confirmAction}
        onClose={() => setConfirmAction(null)}
        onConfirm={handleExecuteConfirmedAction}
        title={
          confirmAction?.type === 'rollback'
            ? `Emergency Rollback: ${confirmAction?.env}`
            : `Production Deployment: ${confirmAction?.env}`
        }
        message={
          confirmAction?.type === 'rollback'
            ? `Are you sure you want to trigger an emergency rollback on ${confirmAction?.env}? This will restore version ${confirmAction?.version} and log an immutable incident audit.`
            : `Are you sure you want to execute release ${confirmAction?.version} to ${confirmAction?.env}? Container clusters will reload.`
        }
        confirmText={confirmAction?.type === 'rollback' ? 'Execute Rollback' : 'Deploy Release'}
        isDestructive={confirmAction?.type === 'rollback'}
        isLoading={isConfirming}
      />
    </div>
  );
};
