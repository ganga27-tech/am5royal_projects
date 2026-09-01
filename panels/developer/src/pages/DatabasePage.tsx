import React, { useEffect, useState } from 'react';
import { developerApi } from '../api/developerApi';
import { DatabaseDiagnostics } from '../types/developer';
import { Database, CheckCircle, Server, RefreshCw, Key } from 'lucide-react';

export const DatabasePage: React.FC = () => {
  const [diag, setDiag] = useState<DatabaseDiagnostics | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);

  const fetchDiag = async () => {
    setIsLoading(true);
    try {
      const data = await developerApi.getDatabaseDiagnostics();
      setDiag(data);
    } catch {
      // ignore
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchDiag();
  }, []);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-lg font-bold text-[#F1F5F9] uppercase tracking-wide flex items-center gap-2">
            <Database className="w-5 h-5 text-[#22D3EE]" /> PostgreSQL Database Diagnostics
          </h1>
          <p className="text-xs text-[#94A3B8] font-mono mt-0.5">
            ASYNC ENGINE POOL STATUS, ORM ENTITIES & TABLE ROW COUNTS
          </p>
        </div>
        <button
          onClick={fetchDiag}
          className="flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-mono bg-[#151E2E] hover:bg-[#1B2638] text-[#22D3EE] border border-[#263247] transition"
        >
          <RefreshCw className="w-3.5 h-3.5" /> Refresh Telemetry
        </button>
      </div>

      {isLoading || !diag ? (
        <div className="text-center py-20 text-xs font-mono text-[#22D3EE] animate-pulse">
          READING POSTGRES ENGINE CATALOG...
        </div>
      ) : (
        <div className="space-y-6">
          {/* Status Matrix */}
          <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
            <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247]">
              <div className="text-[10px] font-mono uppercase text-[#94A3B8]">ENGINE STATUS</div>
              <div className="text-base font-bold font-mono text-[#34D399] mt-1 flex items-center gap-1.5">
                <CheckCircle className="w-4 h-4" /> {diag.status.toUpperCase()}
              </div>
            </div>

            <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247]">
              <div className="text-[10px] font-mono uppercase text-[#94A3B8]">SQL DIALECT</div>
              <div className="text-base font-bold font-mono text-[#22D3EE] mt-1">
                {diag.dialect.toUpperCase()}
              </div>
            </div>

            <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247]">
              <div className="text-[10px] font-mono uppercase text-[#94A3B8]">CONNECTION POOL</div>
              <div className="text-base font-bold font-mono text-[#F1F5F9] mt-1">
                {diag.pool_status} (Size: {diag.pool_size})
              </div>
            </div>

            <div className="p-4 rounded-lg bg-[#0E1420] border border-[#263247]">
              <div className="text-[10px] font-mono uppercase text-[#94A3B8]">ALEMBIC SCHEMA</div>
              <div className="text-base font-bold font-mono text-[#34D399] mt-1">
                {diag.migrations_status}
              </div>
            </div>
          </div>

          {/* Tables Overview */}
          <div className="rounded-lg bg-[#0E1420] border border-[#263247] overflow-hidden">
            <div className="p-4 border-b border-[#263247] flex items-center justify-between">
              <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
                Managed Entity Tables ({diag.tables_overview.length})
              </h2>
              <span className="text-[10px] font-mono text-[#475569]">
                Safe Read-Only Diagnostic Inspector
              </span>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead>
                  <tr className="border-b border-[#263247] bg-[#151E2E]/60 text-[#94A3B8] font-mono uppercase text-[11px]">
                    <th className="px-4 py-3">Physical Table Name</th>
                    <th className="px-4 py-3">Logical Entity Domain</th>
                    <th className="px-4 py-3">Primary Key</th>
                    <th className="px-4 py-3 text-right">Persisted Records</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#263247]/60 font-mono">
                  {diag.tables_overview.map((t) => (
                    <tr key={t.table_name} className="hover:bg-[#151E2E]/60 transition">
                      <td className="px-4 py-3 font-semibold text-[#22D3EE]">{t.table_name}</td>
                      <td className="px-4 py-3 text-[#F1F5F9]">{t.label}</td>
                      <td className="px-4 py-3 text-[#94A3B8] flex items-center gap-1">
                        <Key className="w-3 h-3 text-[#475569]" /> {t.primary_key}
                      </td>
                      <td className="px-4 py-3 text-right font-bold text-[#F1F5F9]">
                        {t.row_count.toLocaleString()}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
