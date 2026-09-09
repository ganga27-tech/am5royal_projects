import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { marketingApi } from '../api/marketingApi';
import { MarketingOverviewStats } from '../types/marketing';
import { StatsCard } from '../components/common/StatsCard';
import {
  UsersRound,
  BadgePercent,
  TrendingUp,
  Link2,
  BookOpenText,
  Share2,
  SearchCode,
  DollarSign,
  Crown,
  BarChart3,
  Target,
  Sparkles,
  Activity,
  Layers,
  Inbox,
} from 'lucide-react';
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  CartesianGrid,
} from 'recharts';

export const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<MarketingOverviewStats | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const loadOverview = async () => {
      const data = await marketingApi.getOverviewStats();
      setStats(data);
      setIsLoading(false);
    };
    loadOverview();
  }, []);

  const totalLeadsCount = stats?.totalLeads ?? 0;
  const totalSpendAmount = stats?.totalAdSpendInr ?? 0;

  const monthlyGrowthData = totalSpendAmount > 0 ? [
    { month: 'Apr', spend: 0, revenue: 0, leads: 0 },
    { month: 'May', spend: 0, revenue: 0, leads: 0 },
    { month: 'Jun', spend: 0, revenue: 0, leads: 0 },
    { month: 'Jul', spend: 0, revenue: 0, leads: 0 },
    { month: 'Aug', spend: 0, revenue: 0, leads: 0 },
    { month: 'Sep', spend: totalSpendAmount, revenue: totalLeadsCount * 50000, leads: totalLeadsCount },
  ] : [
    { month: 'Apr', spend: 0, revenue: 0, leads: 0 },
    { month: 'May', spend: 0, revenue: 0, leads: 0 },
    { month: 'Jun', spend: 0, revenue: 0, leads: 0 },
    { month: 'Jul', spend: 0, revenue: 0, leads: 0 },
    { month: 'Aug', spend: 0, revenue: 0, leads: 0 },
    { month: 'Sep', spend: 0, revenue: 0, leads: 0 },
  ];

  const channelAttributionData = totalLeadsCount > 0 ? [
    { name: 'Google Ads', leads: 0, color: '#C59A27' },
    { name: 'SEO Organic', leads: 0, color: '#059669' },
    { name: 'Instagram Ads', leads: 0, color: '#E11D48' },
    { name: 'Facebook Ads', leads: 0, color: '#0F4C81' },
    { name: 'Blogs & PR', leads: 0, color: '#7C3AED' },
  ] : [
    { name: 'No Active Leads', leads: 1, color: '#EAE2D2' },
  ];

  return (
    <div className="space-y-8 text-left">
      {/* Top Banner Header */}
      <div className="relative rounded-3xl border border-[#E5D8C1] bg-gradient-to-r from-[#FAF6EF] via-[#FFFFFF] to-[#FAF6EF] p-6 sm:p-8 shadow-cream-lg overflow-hidden">
        <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6 relative z-10">
          <div>
            <div className="inline-flex items-center gap-2 rounded-full border border-[#C59A27]/30 bg-[#C59A27]/10 px-3 py-1 text-xs font-bold text-[#8A6412] mb-3">
              <Crown className="w-3.5 h-3.5 text-[#C59A27]" />
              <span>MSKGRC AM5 ROYAL Growth Hub</span>
            </div>
            <h1 className="font-serif text-2xl sm:text-3xl lg:text-4xl font-black text-[#1E1B18] tracking-tight">
              Omnichannel <span className="gold-gradient-text">Marketing Engine</span>
            </h1>
            <p className="text-xs sm:text-sm text-[#685D51] mt-1 max-w-2xl">
              Real-time executive tracking across SEO, Backlinks, Blogs, PR Media, Social Reach, Google Ads, GA4, Inbound Funnel, and Strategic Roadmaps.
            </p>
          </div>

          {/* Action Hub Buttons */}
          <div className="flex flex-wrap items-center gap-3">
            <button
              onClick={() => navigate('/leads')}
              className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-[#C59A27] to-[#DAB84E] px-4 py-2.5 text-xs sm:text-sm font-bold text-[#1E1B18] shadow-cream-md hover:scale-[1.02] transition-all"
            >
              <UsersRound className="h-4 w-4" />
              <span>Open Leads Funnel</span>
            </button>
            <button
              onClick={() => navigate('/seo')}
              className="flex items-center gap-2 rounded-xl border border-[#EAE2D2] bg-[#FFFFFF] hover:bg-[#FAF7F2] px-4 py-2.5 text-xs sm:text-sm font-bold text-[#4D443B] transition-colors shadow-sm"
            >
              <SearchCode className="h-4 w-4 text-[#C59A27]" />
              <span>SEO Suite</span>
            </button>
          </div>
        </div>
      </div>

      {/* Top 4 KPI High-Impact Metric Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <StatsCard
          title="Total Inbound Leads"
          value={totalLeadsCount.toString()}
          subtitle="Qualified conversion inquiries"
          icon={UsersRound}
          change="0%"
          isPositive={true}
          colorClass="from-[#FAF6EF] to-[#F5EFEB] text-[#8A6412] border-[#E5D8C1]"
        />
        <StatsCard
          title="Total Ad Spend"
          value={totalSpendAmount > 0 ? `₹${(totalSpendAmount / 100000).toFixed(1)} Lakh` : '₹0'}
          subtitle="Google & Meta Ad Budgets"
          icon={DollarSign}
          change="0%"
          isPositive={true}
          colorClass="from-blue-50 to-indigo-50 text-blue-800 border-blue-200"
        />
        <StatsCard
          title="Blended ROAS"
          value={`${stats?.blendedRoas ?? 0}x`}
          subtitle="Return on Marketing Spend"
          icon={TrendingUp}
          change="0x"
          isPositive={true}
          colorClass="from-emerald-50 to-teal-50 text-emerald-800 border-emerald-200"
        />
        <StatsCard
          title="Avg Customer CAC"
          value={`₹${stats?.blendedCpaInr ?? 0}`}
          subtitle="Per verified vendor lead"
          icon={BadgePercent}
          change="0%"
          isPositive={true}
          colorClass="from-purple-50 to-pink-50 text-purple-800 border-purple-200"
        />
      </div>

      {/* Charts Section: Monthly Spend vs Revenue & Channel Share */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left: Spend vs Generated Revenue (Area Chart) */}
        <div className="lg:col-span-2 glass-card rounded-3xl p-6 sm:p-8 bg-[#FFFFFF] shadow-cream-md">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 mb-6">
            <div>
              <h3 className="font-outfit text-lg font-bold text-[#1E1B18] flex items-center gap-2">
                <span>Marketing Spend vs Generated Revenue</span>
              </h3>
              <p className="text-xs text-[#8E8276] mt-0.5">
                Monthly revenue generated through organic and paid marketing channels
              </p>
            </div>
            <div className="flex items-center gap-4 text-xs font-semibold">
              <div className="flex items-center gap-1.5">
                <span className="h-3 w-3 rounded-full bg-[#C59A27]"></span>
                <span className="text-[#685D51]">Revenue (₹)</span>
              </div>
              <div className="flex items-center gap-1.5">
                <span className="h-3 w-3 rounded-full bg-[#0F4C81]"></span>
                <span className="text-[#685D51]">Ad Spend (₹)</span>
              </div>
            </div>
          </div>

          <div className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={monthlyGrowthData} margin={{ top: 10, right: 10, left: -15, bottom: 0 }}>
                <defs>
                  <linearGradient id="colorRev" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#C59A27" stopOpacity={0.4} />
                    <stop offset="95%" stopColor="#C59A27" stopOpacity={0.0} />
                  </linearGradient>
                  <linearGradient id="colorSpend" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#0F4C81" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#0F4C81" stopOpacity={0.0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#EAE2D2" vertical={false} />
                <XAxis dataKey="month" stroke="#8E8276" tick={{ fontSize: 12 }} tickLine={false} />
                <YAxis stroke="#8E8276" tick={{ fontSize: 12 }} tickLine={false} tickFormatter={(v) => `₹${v/1000}k`} />
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#FFFFFF',
                    borderColor: '#E5D8C1',
                    borderRadius: '1rem',
                    boxShadow: '0 10px 25px -5px rgba(0, 0, 0, 0.1)',
                    color: '#1E1B18',
                  }}
                  formatter={(value: any) => [`₹${Number(value).toLocaleString()}`, '']}
                />
                <Area type="monotone" dataKey="revenue" stroke="#C59A27" strokeWidth={2.5} fillOpacity={1} fill="url(#colorRev)" />
                <Area type="monotone" dataKey="spend" stroke="#0F4C81" strokeWidth={2} fillOpacity={1} fill="url(#colorSpend)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Right: Channel Attribution Lead Share */}
        <div className="glass-card rounded-3xl p-6 sm:p-8 bg-[#FFFFFF] shadow-cream-md flex flex-col justify-between">
          <div>
            <h3 className="font-outfit text-lg font-bold text-[#1E1B18] mb-1">
              Lead Attribution Share
            </h3>
            <p className="text-xs text-[#8E8276] mb-4">
              Channel volume distribution
            </p>

            <div className="h-48 w-full relative flex items-center justify-center">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={channelAttributionData}
                    cx="50%"
                    cy="50%"
                    innerRadius={55}
                    outerRadius={75}
                    paddingAngle={4}
                    dataKey="leads"
                  >
                    {channelAttributionData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip
                    contentStyle={{
                      backgroundColor: '#FFFFFF',
                      borderColor: '#E5D8C1',
                      borderRadius: '0.75rem',
                      color: '#1E1B18'
                    }}
                  />
                </PieChart>
              </ResponsiveContainer>
              <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
                <span className="font-outfit text-2xl font-black text-[#1E1B18]">{totalLeadsCount}</span>
                <span className="text-[10px] text-[#8E8276] uppercase font-bold">Total Inbound</span>
              </div>
            </div>

            {/* Legends */}
            <div className="space-y-2 mt-4">
              {totalLeadsCount > 0 ? (
                channelAttributionData.map((item, idx) => (
                  <div key={idx} className="flex items-center justify-between text-xs">
                    <div className="flex items-center gap-2">
                      <span className="h-2.5 w-2.5 rounded-full" style={{ backgroundColor: item.color }}></span>
                      <span className="text-[#4D443B] font-medium">{item.name}</span>
                    </div>
                    <span className="font-bold text-[#1E1B18]">{item.leads} leads</span>
                  </div>
                ))
              ) : (
                <p className="text-xs text-center text-[#8E8276] italic py-2">
                  No active channel leads recorded yet.
                </p>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Fast Jump Matrix Across All 10 Domains */}
      <div className="glass-card rounded-3xl p-6 sm:p-8 bg-[#FFFFFF] shadow-cream-md space-y-4">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="font-outfit text-lg font-bold text-[#1E1B18]">
              Marketing Command Fast-Jump Matrix
            </h3>
            <p className="text-xs text-[#8E8276]">
              Direct access into all 10 active marketing modules
            </p>
          </div>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3.5 pt-2">
          {[
            { name: 'SEO Suite', path: '/seo', icon: SearchCode, count: 'Audit & SERP', color: 'text-amber-700 bg-amber-50' },
            { name: 'Backlinks', path: '/backlinks', icon: Link2, count: 'Outreach CRM', color: 'text-blue-700 bg-blue-50' },
            { name: 'Blogs Studio', path: '/blogs', icon: BookOpenText, count: 'Publishing Hub', color: 'text-emerald-700 bg-emerald-50' },
            { name: 'PR Articles', path: '/articles', icon: Layers, count: 'Media PR Studio', color: 'text-purple-700 bg-purple-50' },
            { name: 'SMM Hub', path: '/smm', icon: Share2, count: 'Social Reach', color: 'text-pink-700 bg-pink-50' },
            { name: 'Google Ads', path: '/google-ads', icon: BarChart3, count: 'Ads Command', color: 'text-indigo-700 bg-indigo-50' },
            { name: 'GA4 Telemetry', path: '/analytics', icon: Activity, count: 'Web Analytics', color: 'text-teal-700 bg-teal-50' },
            { name: 'Leads Pipeline', path: '/leads', icon: UsersRound, count: 'Inbound CRM', color: 'text-amber-800 bg-amber-50' },
            { name: 'Strategies', path: '/strategies', icon: Target, count: 'Growth Roadmaps', color: 'text-gold-800 bg-gold-50' },
            { name: 'Content Studio', path: '/content-creations', icon: Sparkles, count: 'Creative Copy', color: 'text-rose-700 bg-rose-50' },
          ].map((item, idx) => {
            const Icon = item.icon;
            return (
              <button
                key={idx}
                onClick={() => navigate(item.path)}
                className="group flex flex-col justify-between p-4 rounded-2xl border border-[#EAE2D2] bg-[#FAF7F2] hover:bg-[#FFFFFF] hover:border-[#C59A27] hover:shadow-cream-md transition-all text-left"
              >
                <div className={`p-2.5 rounded-xl ${item.color} w-fit border border-[#EAE2D2] mb-3 group-hover:scale-110 transition-transform`}>
                  <Icon className="h-4 w-4" />
                </div>
                <div>
                  <p className="text-xs font-bold text-[#1E1B18] group-hover:text-[#8A6412] transition-colors">
                    {item.name}
                  </p>
                  <p className="text-[10px] text-[#8E8276] mt-0.5">{item.count}</p>
                </div>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
};
