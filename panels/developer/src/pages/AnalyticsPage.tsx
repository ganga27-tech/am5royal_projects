import React, { useEffect, useState } from 'react';
import { developerApi } from '../api/developerApi';
import { AnalyticsData } from '../types/developer';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  AreaChart,
  Area,
} from 'recharts';
import { BarChart3, TrendingUp, ShieldAlert, CheckCircle2, Activity } from 'lucide-react';

export const AnalyticsPage: React.FC = () => {
  const [timeframe, setTimeframe] = useState<string>('7d');
  const [data, setData] = useState<AnalyticsData | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);

  useEffect(() => {
    setIsLoading(true);
    developerApi
      .getAnalytics(timeframe)
      .then(setData)
      .finally(() => setIsLoading(false));
  }, [timeframe]);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="text-lg font-bold text-[#F1F5F9] uppercase tracking-wide flex items-center gap-2">
            <BarChart3 className="w-5 h-5 text-[#22D3EE]" /> Engineering Telemetry & Analytics
          </h1>
          <p className="text-xs text-[#94A3B8] font-mono mt-0.5">
            DEFECT DISCOVERY TRENDS, SPRINT VELOCITY & MODULE STABILITY
          </p>
        </div>

        {/* Timeframe selector */}
        <div className="flex items-center gap-1.5 p-1 rounded-lg bg-[#0E1420] border border-[#263247]">
          {['today', '7d', '30d'].map((tf) => (
            <button
              key={tf}
              onClick={() => setTimeframe(tf)}
              className={`px-3 py-1 text-xs font-mono rounded transition ${
                timeframe === tf
                  ? 'bg-[#151E2E] text-[#22D3EE] font-bold border border-[#22D3EE]/40'
                  : 'text-[#94A3B8] hover:text-[#F1F5F9]'
              }`}
            >
              {tf.toUpperCase()}
            </button>
          ))}
        </div>
      </div>

      {isLoading || !data ? (
        <div className="text-center py-20 text-xs font-mono text-[#22D3EE] animate-pulse">
          AGGREGATING HISTORICAL METRICS...
        </div>
      ) : (
        <div className="space-y-6">
          {/* Defect Discovery vs Resolution Trend */}
          <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
            <div className="flex items-center justify-between border-b border-[#263247] pb-3">
              <div>
                <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
                  Defect Discovery vs Fix Resolution Velocity
                </h2>
                <p className="text-[11px] text-[#94A3B8] mt-0.5">
                  Daily comparison of reported bugs vs QA verified fixes
                </p>
              </div>
              <div className="flex items-center gap-4 text-xs font-mono">
                <span className="flex items-center gap-1.5 text-[#FB4B5F]">
                  <span className="w-2.5 h-2.5 rounded-full bg-[#FB4B5F]" /> Reported
                </span>
                <span className="flex items-center gap-1.5 text-[#34D399]">
                  <span className="w-2.5 h-2.5 rounded-full bg-[#34D399]" /> Verified Fixed
                </span>
              </div>
            </div>

            <div className="h-64 w-full">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={data.bug_trend}>
                  <defs>
                    <linearGradient id="colorCreated" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#FB4B5F" stopOpacity={0.4} />
                      <stop offset="95%" stopColor="#FB4B5F" stopOpacity={0} />
                    </linearGradient>
                    <linearGradient id="colorVerified" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#34D399" stopOpacity={0.4} />
                      <stop offset="95%" stopColor="#34D399" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="#263247" />
                  <XAxis dataKey="date" stroke="#94A3B8" fontSize={11} />
                  <YAxis stroke="#94A3B8" fontSize={11} />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: '#0E1420',
                      borderColor: '#263247',
                      fontSize: '12px',
                    }}
                  />
                  <Area
                    type="monotone"
                    dataKey="created"
                    stroke="#FB4B5F"
                    fillOpacity={1}
                    fill="url(#colorCreated)"
                    name="Defects Reported"
                  />
                  <Area
                    type="monotone"
                    dataKey="verified"
                    stroke="#34D399"
                    fillOpacity={1}
                    fill="url(#colorVerified)"
                    name="Defects Verified"
                  />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Module Health Matrix & QA Velocity */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Module Health */}
            <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
              <div className="border-b border-[#263247] pb-3">
                <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
                  Module Stability & Health Index
                </h2>
              </div>

              <div className="space-y-3">
                {data.module_health.map((m) => (
                  <div
                    key={m.module}
                    className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] flex items-center justify-between"
                  >
                    <div>
                      <div className="text-xs font-bold text-[#F1F5F9]">{m.module}</div>
                      <div className="text-[10px] font-mono text-[#94A3B8]">
                        {m.open_bugs} Open Defects
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-xs font-mono font-bold text-[#22D3EE]">
                        {m.health_score}%
                      </div>
                      <div className="text-[10px] font-mono text-[#34D399]">Optimal</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* QA Test Execution Efficiency */}
            <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
              <div className="border-b border-[#263247] pb-3">
                <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
                  QA Auditor Test Execution Ratio
                </h2>
              </div>

              <div className="space-y-3">
                {data.qa_workload.map((q) => (
                  <div
                    key={q.qa}
                    className="p-3 rounded-lg bg-[#151E2E] border border-[#263247] space-y-2"
                  >
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-bold text-[#F1F5F9]">{q.qa}</span>
                      <span className="text-[10px] font-mono text-[#FBBF24]">
                        {q.pending_review} In Verification
                      </span>
                    </div>
                    <div className="grid grid-cols-2 gap-2 text-center text-xs font-mono pt-1">
                      <div className="p-1.5 rounded bg-[#0E1420] text-[#34D399]">
                        {q.verified} Passes
                      </div>
                      <div className="p-1.5 rounded bg-[#0E1420] text-[#FB4B5F]">
                        {q.rejected} Rejects
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
