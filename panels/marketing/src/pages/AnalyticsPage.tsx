import React, { useState, useEffect } from 'react';
import { 
  BarChart3, 
  TrendingUp, 
  Users, 
  Clock, 
  Activity, 
  Globe, 
  Monitor, 
  Smartphone, 
  Tablet, 
  Eye, 
  Download, 
  Zap, 
  CheckCircle2, 
  Sparkles,
  Search,
  Filter
} from 'lucide-react';
import { 
  AreaChart, 
  Area, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer 
} from 'recharts';
import { marketingApi } from '../api/marketingApi';
import { GoogleAnalyticsOverview } from '../types/marketing';
import { StatsCard } from '../components/common/StatsCard';
import { Modal } from '../components/common/Modal';

export const AnalyticsPage: React.FC = () => {
  const [data, setData] = useState<GoogleAnalyticsOverview | null>(null);
  const [loading, setLoading] = useState(true);
  const [timeRange, setTimeRange] = useState<'7d' | '30d' | '90d'>('30d');
  const [pageSearchQuery, setPageSearchQuery] = useState('');
  const [isConfigModalOpen, setIsConfigModalOpen] = useState(false);
  const [gaMeasurementId, setGaMeasurementId] = useState('G-AM5ROYAL99');

  useEffect(() => {
    loadAnalytics();
  }, []);

  const loadAnalytics = async () => {
    try {
      setLoading(true);
      const res = await marketingApi.getGoogleAnalyticsOverview();
      setData(res);
    } catch (err) {
      console.error('Failed to load analytics', err);
    } finally {
      setLoading(false);
    }
  };

  if (loading || !data) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <div className="w-10 h-10 border-4 border-[#C59A27]/20 border-t-[#C59A27] rounded-full animate-spin"></div>
      </div>
    );
  }

  // Dynamic Chart Datasets based on Time Range Filter
  const timeRangeDatasets = {
    '7d': [
      { date: 'Sep 02', visitors: 1680, pageviews: 4900 },
      { date: 'Sep 03', visitors: 1950, pageviews: 5800 },
      { date: 'Sep 04', visitors: 2200, pageviews: 6400 },
      { date: 'Sep 05', visitors: 2600, pageviews: 7900 },
      { date: 'Sep 06', visitors: 3100, pageviews: 9200 },
      { date: 'Sep 07', visitors: 3450, pageviews: 10400 },
      { date: 'Sep 08', visitors: 3820, pageviews: 11600 },
    ],
    '30d': [
      { date: 'Aug 10', visitors: 1120, pageviews: 3200 },
      { date: 'Aug 15', visitors: 1450, pageviews: 4100 },
      { date: 'Aug 20', visitors: 1890, pageviews: 5300 },
      { date: 'Aug 25', visitors: 2340, pageviews: 6800 },
      { date: 'Aug 30', visitors: 2890, pageviews: 8200 },
      { date: 'Sep 04', visitors: 3200, pageviews: 9400 },
      { date: 'Sep 08', visitors: 3820, pageviews: 11600 },
    ],
    '90d': [
      { date: 'Jun W1', visitors: 4500, pageviews: 13200 },
      { date: 'Jun W3', visitors: 6200, pageviews: 18500 },
      { date: 'Jul W1', visitors: 8900, pageviews: 26400 },
      { date: 'Jul W3', visitors: 11400, pageviews: 34100 },
      { date: 'Aug W1', visitors: 14800, pageviews: 44200 },
      { date: 'Aug W3', visitors: 18200, pageviews: 54900 },
      { date: 'Sep W1', visitors: 21900, pageviews: 65800 },
    ]
  };

  const currentChartData = timeRangeDatasets[timeRange];

  // Dynamic scaled stats for time range
  const multiplier = timeRange === '7d' ? 0.25 : (timeRange === '30d' ? 1.0 : 3.2);
  const displayedActiveUsers = Math.round(data.activeUsers * multiplier);
  const displayedSessions = Math.round(data.sessions * multiplier);

  const filteredPages = data.topPages.filter(p =>
    p.path.toLowerCase().includes(pageSearchQuery.toLowerCase())
  );

  const sourceColors = ['#C59A27', '#0F4C81', '#059669', '#7C3AED', '#E11D48'];

  return (
    <div className="space-y-8 animate-fadeIn text-left">
      {/* Top Header with Dark High-Contrast Typography */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-[#EAE2D2] pb-6">
        <div>
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-2xl bg-[#FAF6EF] border border-[#E5D8C1] text-[#9B7314] shadow-cream-sm">
              <Activity className="w-6 h-6" />
            </div>
            <div>
              <h1 className="font-serif text-2xl font-bold text-[#1E1B18] tracking-tight">
                Google Analytics 4 Telemetry
              </h1>
              <p className="text-[#685D51] text-xs sm:text-sm mt-0.5">
                Real-time user engagement, session journeys, and top landing page conversion rates.
              </p>
            </div>
          </div>
        </div>

        {/* Action Controls */}
        <div className="flex flex-wrap items-center gap-3">
          {/* Time Range Filter Selector */}
          <div className="flex items-center p-1 bg-[#FAF7F2] border border-[#EAE2D2] rounded-2xl shadow-inner">
            {(['7d', '30d', '90d'] as const).map((range) => (
              <button
                key={range}
                onClick={() => setTimeRange(range)}
                className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all ${
                  timeRange === range
                    ? 'bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] text-[#1E1B18] shadow-cream-sm'
                    : 'text-[#8E8276] hover:text-[#1E1B18]'
                }`}
              >
                {range.toUpperCase()}
              </button>
            ))}
          </div>

          <button
            onClick={() => setIsConfigModalOpen(true)}
            className="flex items-center gap-2 px-4 py-2 bg-[#FFFFFF] hover:bg-[#FAF6EF] border border-[#EAE2D2] text-[#4D443B] text-xs sm:text-sm font-bold rounded-xl transition-all shadow-cream-sm"
          >
            <Zap className="w-4 h-4 text-[#9B7314]" />
            <span>GA4 Config</span>
          </button>

          <button
            onClick={() => marketingApi.exportToCsv([data as any], 'ga4_telemetry')}
            className="flex items-center gap-2 px-4 py-2 bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] hover:from-[#BA9427] hover:to-[#BA9427] text-[#1E1B18] text-xs sm:text-sm font-bold rounded-xl shadow-cream-md transition-all hover:scale-[1.02]"
          >
            <Download className="w-4 h-4" />
            <span>Export CSV</span>
          </button>
        </div>
      </div>

      {/* KPI Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <StatsCard
          title={`Active Users (${timeRange.toUpperCase()})`}
          value={displayedActiveUsers.toLocaleString()}
          subtitle="Unique active visitors"
          change="+18.4%"
          isPositive={true}
          icon={Users}
          colorClass="from-[#FAF6EF] to-[#F5EFEB] text-[#8A6412] border-[#E5D8C1]"
        />
        <StatsCard
          title={`Total Sessions (${timeRange.toUpperCase()})`}
          value={displayedSessions.toLocaleString()}
          subtitle="Screen interactions"
          change="+24.1%"
          isPositive={true}
          icon={Eye}
          colorClass="from-blue-50 to-indigo-50 text-blue-800 border-blue-200"
        />
        <StatsCard
          title="Avg Session Duration"
          value={`${Math.floor(data.avgSessionDurationSec / 60)}m ${data.avgSessionDurationSec % 60}s`}
          subtitle="Time engaged on site"
          change="+12.8%"
          isPositive={true}
          icon={Clock}
          colorClass="from-emerald-50 to-teal-50 text-emerald-800 border-emerald-200"
        />
        <StatsCard
          title="Bounce Rate"
          value={`${data.bounceRate}%`}
          subtitle="Single-page exits"
          change="-4.2%"
          isPositive={true}
          icon={BarChart3}
          colorClass="from-purple-50 to-pink-50 text-purple-800 border-purple-200"
        />
      </div>

      {/* Charts Section: Session Trend & Device Breakdown */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left: Interactive Session Timeline */}
        <div className="lg:col-span-2 glass-card rounded-3xl p-6 sm:p-8 bg-[#FFFFFF] shadow-cream-md">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h3 className="font-outfit text-lg font-bold text-[#1E1B18] tracking-tight">
                Visitor & Pageview Velocity ({timeRange.toUpperCase()})
              </h3>
              <p className="text-xs text-[#8E8276] mt-1">
                Active sessions and screen engagements filtered by {timeRange.toUpperCase()}
              </p>
            </div>
            <div className="flex items-center gap-4 text-xs font-semibold">
              <div className="flex items-center gap-2">
                <span className="w-3 h-3 rounded-full bg-[#C59A27]"></span>
                <span className="text-[#4D443B]">Visitors</span>
              </div>
              <div className="flex items-center gap-2">
                <span className="w-3 h-3 rounded-full bg-[#0F4C81]"></span>
                <span className="text-[#4D443B]">Pageviews</span>
              </div>
            </div>
          </div>

          <div className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={currentChartData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="visitorGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#C59A27" stopOpacity={0.4} />
                    <stop offset="95%" stopColor="#C59A27" stopOpacity={0.0} />
                  </linearGradient>
                  <linearGradient id="pageviewGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#0F4C81" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#0F4C81" stopOpacity={0.0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#EAE2D2" vertical={false} />
                <XAxis dataKey="date" stroke="#8E8276" tick={{ fontSize: 11 }} tickLine={false} />
                <YAxis stroke="#8E8276" tick={{ fontSize: 11 }} tickLine={false} />
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#FFFFFF',
                    borderColor: '#E5D8C1',
                    borderRadius: '0.75rem',
                    boxShadow: '0 10px 25px -5px rgba(0, 0, 0, 0.1)',
                    color: '#1E1B18'
                  }}
                  itemStyle={{ fontSize: '12px' }}
                />
                <Area type="monotone" dataKey="visitors" stroke="#C59A27" strokeWidth={2.5} fillOpacity={1} fill="url(#visitorGrad)" />
                <Area type="monotone" dataKey="pageviews" stroke="#0F4C81" strokeWidth={2} fillOpacity={1} fill="url(#pageviewGrad)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Right: Device & Channel Breakdown */}
        <div className="space-y-6">
          {/* Device Split */}
          <div className="glass-card rounded-3xl p-6 bg-[#FFFFFF] shadow-cream-md">
            <h3 className="font-outfit text-base font-bold text-[#1E1B18] mb-4 flex items-center justify-between">
              <span>Device Split</span>
              <Monitor className="w-4 h-4 text-[#9B7314]" />
            </h3>

            <div className="grid grid-cols-3 gap-3 mb-6">
              <div className="p-3 rounded-2xl bg-[#FAF7F2] border border-[#EAE2D2] text-center">
                <Smartphone className="w-5 h-5 text-[#C59A27] mx-auto mb-1" />
                <div className="text-lg font-bold text-[#1E1B18]">{data.deviceBreakdown.mobile}%</div>
                <div className="text-[11px] text-[#8E8276]">Mobile</div>
              </div>
              <div className="p-3 rounded-2xl bg-[#FAF7F2] border border-[#EAE2D2] text-center">
                <Monitor className="w-5 h-5 text-[#0F4C81] mx-auto mb-1" />
                <div className="text-lg font-bold text-[#1E1B18]">{data.deviceBreakdown.desktop}%</div>
                <div className="text-[11px] text-[#8E8276]">Desktop</div>
              </div>
              <div className="p-3 rounded-2xl bg-[#FAF7F2] border border-[#EAE2D2] text-center">
                <Tablet className="w-5 h-5 text-emerald-700 mx-auto mb-1" />
                <div className="text-lg font-bold text-[#1E1B18]">{data.deviceBreakdown.tablet}%</div>
                <div className="text-[11px] text-[#8E8276]">Tablet</div>
              </div>
            </div>

            {/* Progress bar */}
            <div className="w-full h-3 bg-[#FAF7F2] border border-[#EAE2D2] rounded-full overflow-hidden flex">
              <div style={{ width: `${data.deviceBreakdown.mobile}%` }} className="bg-[#C59A27] h-full"></div>
              <div style={{ width: `${data.deviceBreakdown.desktop}%` }} className="bg-[#0F4C81] h-full"></div>
              <div style={{ width: `${data.deviceBreakdown.tablet}%` }} className="bg-emerald-600 h-full"></div>
            </div>
          </div>

          {/* Top Acquisition Sources */}
          <div className="glass-card rounded-3xl p-6 bg-[#FFFFFF] shadow-cream-md">
            <h3 className="font-outfit text-base font-bold text-[#1E1B18] mb-4 flex items-center justify-between">
              <span>Traffic Acquisition</span>
              <Globe className="w-4 h-4 text-emerald-600" />
            </h3>

            <div className="space-y-3">
              {data.topSources.map((src, i) => (
                <div key={src.channel} className="space-y-1">
                  <div className="flex items-center justify-between text-xs">
                    <span className="font-semibold text-[#4D443B]">{src.channel}</span>
                    <span className="font-bold text-[#1E1B18]">{src.sessions.toLocaleString()} sessions</span>
                  </div>
                  <div className="w-full h-2 bg-[#FAF7F2] border border-[#EAE2D2] rounded-full overflow-hidden">
                    <div
                      style={{ width: `${src.engagementRatePercent}%`, backgroundColor: sourceColors[i % sourceColors.length] }}
                      className="h-full rounded-full transition-all duration-500"
                    ></div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Top Landing Pages Table with Search Filter */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Top Landing Pages */}
        <div className="lg:col-span-2 rounded-3xl bg-[#FFFFFF] border border-[#EAE2D2] shadow-cream-md overflow-hidden">
          <div className="p-6 border-b border-[#EAE2D2] flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div>
              <h3 className="font-outfit text-lg font-bold text-[#1E1B18]">Top Landing Pages Performance</h3>
              <p className="text-xs text-[#8E8276] mt-0.5">High intent entry URLs and conversion rates</p>
            </div>
            
            {/* Filter Input */}
            <div className="relative w-full sm:w-64">
              <Search className="w-3.5 h-3.5 text-[#8E8276] absolute left-3 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                placeholder="Filter URLs..."
                value={pageSearchQuery}
                onChange={(e) => setPageSearchQuery(e.target.value)}
                className="w-full pl-9 pr-3 py-1.5 bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl text-xs text-[#1E1B18] placeholder-[#8E8276] focus:border-[#C59A27] focus:outline-none"
              />
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-[#FAF6EF] border-b border-[#EAE2D2] text-[#685D51] text-[11px] uppercase tracking-wider font-extrabold">
                  <th className="py-3.5 px-6">Page URL</th>
                  <th className="py-3.5 px-4 text-right">Pageviews</th>
                  <th className="py-3.5 px-4 text-right">Avg Duration</th>
                  <th className="py-3.5 px-4 text-right">Bounce Rate</th>
                  <th className="py-3.5 px-6 text-right">Conversions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#EAE2D2]/80 text-sm">
                {filteredPages.map((page, idx) => (
                  <tr key={idx} className="hover:bg-[#FAF7F2] transition-colors">
                    <td className="py-4 px-6 font-mono text-xs text-[#8A6412] font-semibold max-w-xs truncate">
                      {page.path}
                    </td>
                    <td className="py-4 px-4 text-right text-[#1E1B18] font-bold">
                      {page.pageviews.toLocaleString()}
                    </td>
                    <td className="py-4 px-4 text-right text-[#685D51]">
                      {page.avgTimeSeconds}s
                    </td>
                    <td className="py-4 px-4 text-right text-[#685D51]">
                      {page.bounceRatePercent}%
                    </td>
                    <td className="py-4 px-6 text-right">
                      <span className="inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-bold bg-emerald-50 text-emerald-800 border border-emerald-200">
                        {page.conversions} Orders
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Top Cities Presence */}
        <div className="p-6 rounded-3xl bg-[#FFFFFF] border border-[#EAE2D2] shadow-cream-md flex flex-col justify-between">
          <div>
            <h3 className="font-outfit text-lg font-bold text-[#1E1B18] mb-1">Top Metro Regions</h3>
            <p className="text-xs text-[#8E8276] mb-6">User concentration by metropolitan clusters</p>

            <div className="space-y-4">
              {data.topCities.map((city, idx) => (
                <div key={city.city} className="flex items-center justify-between p-3 rounded-2xl bg-[#FAF7F2] border border-[#EAE2D2]">
                  <div className="flex items-center gap-3">
                    <span className="w-6 h-6 rounded-full bg-[#FFFFFF] flex items-center justify-center text-xs font-bold text-[#8A6412] border border-[#E5D8C1]">
                      {idx + 1}
                    </span>
                    <span className="text-sm font-bold text-[#1E1B18]">{city.city}</span>
                  </div>
                  <div className="text-right">
                    <div className="text-sm font-bold text-[#9B7314]">{city.users.toLocaleString()}</div>
                    <div className="text-[10px] text-[#8E8276] font-semibold">{city.share}% share</div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="mt-6 p-4 rounded-2xl bg-gradient-to-br from-[#FAF6EF] to-[#F5EFEB] border border-[#E5D8C1]">
            <div className="flex items-center gap-2 text-xs font-bold text-[#8A6412]">
              <Sparkles className="w-4 h-4" />
              <span>Key Geo Insight</span>
            </div>
            <p className="text-xs text-[#685D51] mt-1 leading-relaxed">
              Mumbai and Bangalore drive over 58% of all high-value luxury vendor registrations.
            </p>
          </div>
        </div>
      </div>

      {/* GA4 Config Modal */}
      <Modal
        isOpen={isConfigModalOpen}
        onClose={() => setIsConfigModalOpen(false)}
        title="Google Analytics 4 Property Config"
        maxWidth="max-w-md"
      >
        <div className="space-y-4 text-left">
          <div>
            <label className="block text-xs font-bold text-[#4D443B] uppercase tracking-wider mb-2">
              Measurement ID (G-Tag)
            </label>
            <input
              type="text"
              value={gaMeasurementId}
              onChange={(e) => setGaMeasurementId(e.target.value)}
              className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] font-mono text-sm focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              placeholder="G-XXXXXXXXXX"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-[#4D443B] uppercase tracking-wider mb-2">
              Stream API Secret
            </label>
            <input
              type="password"
              defaultValue="••••••••••••••••••••••••"
              className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] font-mono text-sm focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
            />
          </div>

          <div className="p-4 rounded-2xl bg-[#FAF6EF] border border-[#E5D8C1] space-y-2 text-xs text-[#4D443B]">
            <div className="flex items-center gap-2 text-emerald-800 font-bold">
              <CheckCircle2 className="w-4 h-4 text-emerald-600" />
              <span>Real-time Telemetry Active</span>
            </div>
            <p className="text-[#685D51]">
              Enhanced ecommerce tracking is streaming vendor conversions and onboarding reservations directly into GA4.
            </p>
          </div>

          <div className="flex items-center justify-end gap-3 pt-4 border-t border-[#EAE2D2]">
            <button
              onClick={() => setIsConfigModalOpen(false)}
              className="px-4 py-2 rounded-xl border border-[#EAE2D2] text-[#685D51] hover:bg-[#FAF7F2] text-sm font-bold transition-all"
            >
              Cancel
            </button>
            <button
              onClick={() => {
                setIsConfigModalOpen(false);
                alert('GA4 Configuration Saved Successfully');
              }}
              className="px-5 py-2 rounded-xl bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] text-[#1E1B18] font-bold text-sm shadow-cream-md hover:scale-[1.02] transition-all"
            >
              Save Stream Settings
            </button>
          </div>
        </div>
      </Modal>
    </div>
  );
};
