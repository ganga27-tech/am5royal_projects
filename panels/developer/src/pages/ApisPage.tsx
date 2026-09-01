import React, { useEffect, useState } from 'react';
import { developerApi } from '../api/developerApi';
import { ApiEndpoint, Project, Module } from '../types/developer';
import { Modal } from '../components/Modal';
import { Network, Plus, Play, CheckCircle, AlertTriangle, XCircle, Search } from 'lucide-react';

export const ApisPage: React.FC = () => {
  const [apis, setApis] = useState<ApiEndpoint[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const [modules, setModules] = useState<Module[]>([]);
  const [search, setSearch] = useState<string>('');
  const [selectedProjectId, setSelectedProjectId] = useState<number | ''>('');
  const [isLoading, setIsLoading] = useState<boolean>(true);

  // Testing status state
  const [testingApiId, setTestingApiId] = useState<number | null>(null);
  const [testResults, setTestResults] = useState<Record<number, { latency: number; status: string }>>({});

  // New API Modal
  const [isModalOpen, setIsModalOpen] = useState<boolean>(false);
  const [newProjectId, setNewProjectId] = useState<number | ''>('');
  const [newModuleId, setNewModuleId] = useState<number | ''>('');
  const [name, setName] = useState<string>('');
  const [endpoint, setEndpoint] = useState<string>('');
  const [method, setMethod] = useState<string>('GET');
  const [version, setVersion] = useState<string>('v1');
  const [description, setDescription] = useState<string>('');
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const fetchApis = async () => {
    setIsLoading(true);
    try {
      const data = await developerApi.listApis(
        selectedProjectId ? Number(selectedProjectId) : undefined
      );
      setApis(data);
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
    fetchApis();
  }, [selectedProjectId]);

  useEffect(() => {
    if (newProjectId) {
      developerApi.listModules(Number(newProjectId)).then(setModules);
    } else {
      setModules([]);
    }
  }, [newProjectId]);

  const handleTestApi = async (apiId: number) => {
    setTestingApiId(apiId);
    try {
      const res: any = await developerApi.testApi(apiId);
      setTestResults((prev) => ({
        ...prev,
        [apiId]: { latency: res.latency_ms, status: res.status },
      }));
    } catch {
      setTestResults((prev) => ({
        ...prev,
        [apiId]: { latency: 999, status: 'error' },
      }));
    } finally {
      setTestingApiId(null);
    }
  };

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newProjectId || !name.trim() || !endpoint.trim()) return;
    setIsSubmitting(true);
    setError(null);
    try {
      await developerApi.createApi({
        project_id: Number(newProjectId),
        module_id: newModuleId ? Number(newModuleId) : undefined,
        name: name.trim(),
        endpoint: endpoint.trim(),
        method,
        version,
        description: description.trim() || undefined,
      });
      setName('');
      setEndpoint('');
      setDescription('');
      setIsModalOpen(false);
      fetchApis();
    } catch (err: any) {
      setError(err?.response?.data?.detail || 'Failed to catalog API endpoint.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const getMethodBadge = (m: string) => {
    switch (m.toUpperCase()) {
      case 'GET':
        return 'text-[#38BDF8] bg-[#38BDF8]/10 border-[#38BDF8]/30';
      case 'POST':
        return 'text-[#34D399] bg-[#34D399]/10 border-[#34D399]/30';
      case 'PUT':
      case 'PATCH':
        return 'text-[#FBBF24] bg-[#FBBF24]/10 border-[#FBBF24]/30';
      case 'DELETE':
        return 'text-[#FB4B5F] bg-[#FB4B5F]/10 border-[#FB4B5F]/30';
      default:
        return 'text-[#94A3B8] bg-[#94A3B8]/10 border-[#94A3B8]/30';
    }
  };

  const filteredApis = apis.filter(
    (a) =>
      a.name.toLowerCase().includes(search.toLowerCase()) ||
      a.endpoint.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="text-lg font-bold text-[#F1F5F9] uppercase tracking-wide flex items-center gap-2">
            <Network className="w-5 h-5 text-[#34D399]" /> API Service Registry & Diagnostics
          </h1>
          <p className="text-xs text-[#94A3B8] font-mono mt-0.5">
            MICROSERVICE REST INTERFACES, LATENCY TESTING & HEALTH STATUS
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
              if (projects.length > 0 && !newProjectId) setNewProjectId(projects[0].id);
              setIsModalOpen(true);
            }}
            className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-md text-xs font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] transition shadow"
          >
            <Plus className="w-4 h-4" /> Catalog Endpoint
          </button>
        </div>
      </div>

      {/* Search Filter */}
      <div className="p-3 rounded-lg bg-[#0E1420] border border-[#263247]">
        <div className="relative">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-[#475569]">
            <Search className="w-4 h-4" />
          </div>
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Filter by endpoint path (e.g. /api/v1/orders) or service name..."
            className="w-full pl-9 pr-3 py-1.5 bg-[#151E2E] border border-[#263247] rounded-md text-xs text-[#F1F5F9] placeholder-[#475569] focus:outline-none focus:border-[#22D3EE] font-mono"
          />
        </div>
      </div>

      {/* APIs Table */}
      <div className="rounded-lg bg-[#0E1420] border border-[#263247] overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="border-b border-[#263247] bg-[#151E2E]/60 text-[#94A3B8] font-mono uppercase text-[11px]">
                <th className="px-4 py-3">Method</th>
                <th className="px-4 py-3">Endpoint Path</th>
                <th className="px-4 py-3">Name / Capability</th>
                <th className="px-4 py-3">Health Status</th>
                <th className="px-4 py-3">Latency Result</th>
                <th className="px-4 py-3 text-right">Ping Test</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#263247]/60">
              {isLoading ? (
                <tr>
                  <td colSpan={6} className="py-12 text-center text-[#34D399] font-mono animate-pulse">
                    FETCHING REST ENDPOINT METRICS...
                  </td>
                </tr>
              ) : filteredApis && filteredApis.length > 0 ? (
                filteredApis.map((api) => {
                  const testRes = testResults[api.id];
                  return (
                    <tr key={api.id} className="hover:bg-[#151E2E]/60 transition">
                      <td className="px-4 py-3 whitespace-nowrap">
                        <span
                          className={`font-mono font-bold text-[10px] px-2 py-0.5 rounded border uppercase ${getMethodBadge(
                            api.method
                          )}`}
                        >
                          {api.method}
                        </span>
                      </td>
                      <td className="px-4 py-3 font-mono font-semibold text-[#F1F5F9]">
                        {api.endpoint}
                      </td>
                      <td className="px-4 py-3 text-[#94A3B8]">{api.name}</td>
                      <td className="px-4 py-3 whitespace-nowrap">
                        <span className="inline-flex items-center gap-1.5 text-[11px] font-mono text-[#34D399]">
                          <span className="w-1.5 h-1.5 rounded-full bg-[#34D399]" />
                          {api.health_status.toUpperCase()}
                        </span>
                      </td>
                      <td className="px-4 py-3 font-mono text-[11px] whitespace-nowrap">
                        {testRes ? (
                          <span
                            className={
                              testRes.status === 'healthy' ? 'text-[#34D399]' : 'text-[#FB4B5F]'
                            }
                          >
                            {testRes.latency}ms • {testRes.status.toUpperCase()}
                          </span>
                        ) : (
                          <span className="text-[#475569]">Not tested</span>
                        )}
                      </td>
                      <td className="px-4 py-3 text-right whitespace-nowrap">
                        <button
                          onClick={() => handleTestApi(api.id)}
                          disabled={testingApiId === api.id}
                          className="inline-flex items-center gap-1 px-2.5 py-1 rounded bg-[#151E2E] hover:bg-[#1B2638] text-[#22D3EE] border border-[#22D3EE]/30 text-[11px] font-mono transition"
                        >
                          <Play className="w-3 h-3 fill-current" />
                          {testingApiId === api.id ? 'Pinging...' : 'Test Run'}
                        </button>
                      </td>
                    </tr>
                  );
                })
              ) : (
                <tr>
                  <td colSpan={6} className="py-8 text-center text-[#94A3B8] font-mono">
                    No API endpoints cataloged yet.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Create API Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title="Catalog API Endpoint"
        subtitle="Registers endpoint signature for automated health checks & defect correlation."
      >
        <form onSubmit={handleCreate} className="space-y-4">
          {error && <div className="text-xs text-[#FB4B5F]">{error}</div>}

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-mono text-[#94A3B8] mb-1">PROJECT *</label>
              <select
                required
                value={newProjectId}
                onChange={(e) => setNewProjectId(Number(e.target.value))}
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
              <label className="block text-xs font-mono text-[#94A3B8] mb-1">MODULE</label>
              <select
                value={newModuleId}
                onChange={(e) => setNewModuleId(e.target.value ? Number(e.target.value) : '')}
                className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
              >
                <option value="">(None)</option>
                {modules.map((m) => (
                  <option key={m.id} value={m.id}>
                    {m.name}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div className="grid grid-cols-3 gap-3">
            <div>
              <label className="block text-xs font-mono text-[#94A3B8] mb-1">METHOD *</label>
              <select
                value={method}
                onChange={(e) => setMethod(e.target.value)}
                className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] font-mono focus:outline-none focus:border-[#22D3EE]"
              >
                <option value="GET">GET</option>
                <option value="POST">POST</option>
                <option value="PUT">PUT</option>
                <option value="DELETE">DELETE</option>
                <option value="PATCH">PATCH</option>
              </select>
            </div>

            <div className="col-span-2">
              <label className="block text-xs font-mono text-[#94A3B8] mb-1">
                ENDPOINT PATH *
              </label>
              <input
                type="text"
                required
                value={endpoint}
                onChange={(e) => setEndpoint(e.target.value)}
                placeholder="/api/v1/auth/login"
                className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] font-mono focus:outline-none focus:border-[#22D3EE]"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">ENDPOINT TITLE *</label>
            <input
              type="text"
              required
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="e.g. Employee Login & Session Token Exchange"
              className="w-full rounded bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] focus:outline-none focus:border-[#22D3EE]"
            />
          </div>

          <div>
            <label className="block text-xs font-mono text-[#94A3B8] mb-1">DESCRIPTION</label>
            <textarea
              rows={2}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Query parameters, headers, response format..."
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
              {isSubmitting ? 'Registering...' : 'Register Endpoint'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
};
