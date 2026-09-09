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
  ArrowUpRight,
  Sparkles,
  Zap,
  Activity,
  Layers,
  Award,
  Crown,
  ChevronRight,
  Clock,
  CheckCircle2,
  BarChart3,
  Target,
} from 'lucide-react';
import {
  AreaChart,
  Area,
  BarChart,
  Bar,
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

  const monthlyGrowthData = [
    { month: 'Apr', spend: 65000, revenue: 290000, leads: 180 },
    { month: 'May', spend: 85000, revenue: 380000, leads: 240 },
    { month: 'Jun', spend: 110000, revenue: 540000, leads: 340 },
    { month: 'Jul', spend: 140000, revenue: 720000, leads: 460 },
    { month: 'Aug', spend: 195000, revenue: 980000, leads: 620 },
    { month: 'Sep', spend: 235000, revenue: 1220000, leads: 780 },
  ];

  const channelAttributionData = [
    { name: 'Google Ads', leads: 420, color: '#C59A27' },
    { name: 'SEO Organic', leads: 310, color: '#059669' },
    { name: 'Instagram Ads', leads: 240, color: '#E11D48' },
    { name: 'Facebook Ads', leads: 180, color: '#0F4C81' },
    { name: 'Blogs & PR', leads: 120, color: '#7C3AED' },
  ];

  const recentGrowthActivities = [
    { title: 'New High-Intent Google Ad campaign launched in Mumbai', time: '20 mins ago', type: 'ads', badge: 'Active' },
    { title: 'DoFollow backlink acquired from Architectural Digest India (DR 78)', time: '2 hours ago', type: 'backlink', badge: 'Verified' },
    { title: '4K Satisfying Sofa Deep Clean reel crossed 148,000 views on Instagram', time: '4 hours ago', type: 'smm', badge: 'Viral' },
    { title: 'New Vendor Onboarding lead converted: Shree Ganesh Clean Care (₹14,999)', time: 'Yesterday', type: 'lead', badge: 'Closed Won' },
    { title: 'On-Page SEO Audit completed for Home Cleaning category (Score: 94/100)', time: 'Yesterday', type: 'seo', badge: 'Optimized' },
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
          value={stats?.totalLeads || '1,842'}
          subtitle="Qualified conversion inquiries"
          icon={UsersRound}
          change="+24.8%"
          isPositive={true}
          colorClass="from-[#FAF6EF] to-[#F5EFEB] text-[#8A6412] border-[#E5D8C1]"
        />
        <StatsCard
          title="Total Ad Spend"
          value={`₹${((stats?.totalAdSpendInr || 235000) / 100000).toFixed(1)} Lakh`}
          subtitle="Google & Meta Ad Budgets"
          icon={DollarSign}
          change="+18.2%"
          isPositive={true}
          colorClass="from-blue-50 to-indigo-50 text-blue-800 border-blue-200"
        />
        <StatsCard
          title="Blended ROAS"
          value={`${stats?.blendedRoas || 4.85}x`}
          subtitle="Return on Marketing Spend"
          icon={TrendingUp}
          change="+0.65x"
          isPositive={true}
          colorClass="from-emerald-50 to-teal-50 text-emerald-800 border-emerald-200"
        />
        <StatsCard
          title="Avg Customer CAC"
          value={`₹${stats?.blendedCpaInr || 214}`}
          subtitle="Per verified vendor lead"
          icon={BadgePercent}
          change="-12.4%"
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
                <span className="rounded-full bg-emerald-50 px-2 py-0.5 text-[10px] font-bold text-emerald-700 border border-emerald-200">
                  +32% MoM
                </span>
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
              Channel volume distribution for September 2026
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
                <span className="font-outfit text-2xl font-black text-[#1E1B18]">1,270</span>
                <span className="text-[10px] text-[#8E8276] uppercase font-bold">Total Inbound</span>
              </div>
            </div>

            {/* Legends */}
            <div className="space-y-2 mt-4">
              {channelAttributionData.map((item, idx) => (
                <div key={idx} className="flex items-center justify-between text-xs">
                  <div className="flex items-center gap-2">
                    <span className="h-2.5 w-2.5 rounded-full" style={{ backgroundColor: item.color }}></span>
                    <span className="text-[#4D443B] font-medium">{item.name}</span>
                  </div>
                  <span className="font-bold text-[#1E1B18]">{item.leads} leads</span>
                </div>
              ))}
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
            { name: 'SEO Suite', path: '/seo', icon: SearchCode, count: 'Score 96', color: 'text-amber-700 bg-amber-50' },
            { name: 'Backlinks', path: '/backlinks', icon: Link2, count: '34 DR 70+', color: 'text-blue-700 bg-blue-50' },
            { name: 'Blogs Studio', path: '/blogs', icon: BookOpenText, count: '18 Published', color: 'text-emerald-700 bg-emerald-50' },
            { name: 'PR Articles', path: '/articles', icon: Layers, count: 'Vogue & Forbes', color: 'text-purple-700 bg-purple-50' },
            { name: 'SMM Hub', path: '/smm', icon: Share2, count: '1.4M Reach', color: 'text-pink-700 bg-pink-50' },
            { name: 'Google Ads', path: '/google-ads', icon: BarChart3, count: '4.85x ROAS', color: 'text-indigo-700 bg-indigo-50' },
            { name: 'GA4 Telemetry', path: '/analytics', icon: Activity, count: '24k Sessions', color: 'text-teal-700 bg-teal-50' },
            { name: 'Leads Pipeline', path: '/leads', icon: UsersRound, count: '₹42.8L Value', color: 'text-amber-800 bg-amber-50' },
            { name: 'Strategies', path: '/strategies', icon: Target, count: 'Q3 Blueprint', color: 'text-gold-800 bg-gold-50' },
            { name: 'Content Studio', path: '/content-creations', icon: Sparkles, count: 'Copy Repository', color: 'text-rose-700 bg-rose-50' },
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
