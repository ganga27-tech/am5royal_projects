import React, { useState, useEffect } from 'react';
import { marketingApi } from '../api/marketingApi';
import { GoogleAdsReportItem } from '../types/marketing';
import { Modal } from '../components/common/Modal';
import { StatsCard } from '../components/common/StatsCard';
import {
  BadgePercent,
  Plus,
  Trash2,
  Edit3,
  TrendingUp,
  DollarSign,
  MousePointerClick,
  Eye,
  Target,
  Download,
  Search,
  Filter,
} from 'lucide-react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
} from 'recharts';

export const GoogleAdsPage: React.FC = () => {
  const [reports, setReports] = useState<GoogleAdsReportItem[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [typeFilter, setTypeFilter] = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<GoogleAdsReportItem | null>(null);

  // Form states
  const [formName, setFormName] = useState('');
  const [formType, setFormType] = useState<any>('Search');
  const [formSuperCategory, setFormSuperCategory] = useState('Home Deep Cleaning');
  const [formKeywords, setFormKeywords] = useState('');
  const [formNegativeKeys, setFormNegativeKeys] = useState('');
  const [formDailyBudget, setFormDailyBudget] = useState(3500);
  const [formTotalSpend, setFormTotalSpend] = useState(65000);
  const [formImpressions, setFormImpressions] = useState(48000);
  const [formClicks, setFormClicks] = useState(3200);
  const [formConversions, setFormConversions] = useState(340);
  const [formRoas, setFormRoas] = useState(4.8);
  const [formStatus, setFormStatus] = useState<any>('Active');

  const loadData = async () => {
    const list = await marketingApi.getGoogleAdsReports();
    setReports(list);
  };

  useEffect(() => {
    loadData();
  }, []);

  const openCreateModal = () => {
    setEditingItem(null);
    setFormName('Search_DelhiNCR_EmergencyApplianceRepair');
    setFormType('Search');
    setFormSuperCategory('Appliance Repair');
    setFormKeywords('ac gas refill delhi, split ac technician noida, washing machine repair gurgaon');
    setFormNegativeKeys('free repair, iti syllabus, ac spare parts wholesale');
    setFormDailyBudget(4000);
    setFormTotalSpend(72000);
    setFormImpressions(58000);
    setFormClicks(3900);
    setFormConversions(410);
    setFormRoas(5.4);
    setFormStatus('Active');
    setIsModalOpen(true);
  };

  const handleEdit = (item: GoogleAdsReportItem) => {
    setEditingItem(item);
    setFormName(item.campaignName);
    setFormType(item.campaignType);
    setFormSuperCategory(item.targetSuperCategory);
    setFormKeywords(item.targetKeywords.join(', '));
    setFormNegativeKeys(item.negativeKeywords.join(', '));
    setFormDailyBudget(item.dailyBudgetInr);
    setFormTotalSpend(item.totalSpendInr);
    setFormImpressions(item.impressions);
    setFormClicks(item.clicks);
    setFormConversions(item.conversions);
    setFormRoas(item.roasRatio);
    setFormStatus(item.status);
    setIsModalOpen(true);
  };

  const handleFormSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await marketingApi.saveGoogleAdsReport({
      id: editingItem?.id,
      campaignName: formName,
      campaignType: formType,
      targetSuperCategory: formSuperCategory,
      targetKeywords: formKeywords.split(',').map((k) => k.trim()).filter(Boolean),
      negativeKeywords: formNegativeKeys.split(',').map((k) => k.trim()).filter(Boolean),
      dailyBudgetInr: Number(formDailyBudget),
      totalSpendInr: Number(formTotalSpend),
      impressions: Number(formImpressions),
      clicks: Number(formClicks),
      conversions: Number(formConversions),
      roasRatio: Number(formRoas),
      status: formStatus,
      startDate: editingItem?.startDate || new Date().toISOString().split('T')[0],
      ctrPercent: formImpressions > 0 ? Number(((formClicks / formImpressions) * 100).toFixed(2)) : 0,
      avgCpcInr: formClicks > 0 ? Number((formTotalSpend / formClicks).toFixed(2)) : 0,
      cpaInr: formConversions > 0 ? Number((formTotalSpend / formConversions).toFixed(2)) : 0,
    });
    setIsModalOpen(false);
    loadData();
  };

  const handleDelete = async (id: string) => {
    if (confirm('Delete this Google Ad campaign record?')) {
      await marketingApi.deleteGoogleAdsReport(id);
      loadData();
    }
  };

  // Filtered reports
  const filteredReports = reports.filter((item) => {
    const matchesSearch =
      item.campaignName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.targetSuperCategory.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesType = typeFilter === 'all' || item.campaignType === typeFilter;
    const matchesStatus = statusFilter === 'all' || item.status === statusFilter;
    return matchesSearch && matchesType && matchesStatus;
  });

  const totalSpend = reports.reduce((acc, curr) => acc + curr.totalSpendInr, 0);
  const totalConversions = reports.reduce((acc, curr) => acc + curr.conversions, 0);
  const totalClicks = reports.reduce((acc, curr) => acc + curr.clicks, 0);
  const avgRoas = reports.length > 0 ? (reports.reduce((acc, curr) => acc + curr.roasRatio, 0) / reports.length).toFixed(1) : '0';

  return (
    <div className="space-y-8 text-left">
      {/* Top Banner Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-[#EAE2D2] pb-6">
        <div>
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-2xl bg-[#FAF6EF] border border-[#E5D8C1] text-[#9B7314] shadow-cream-sm">
              <BadgePercent className="h-6 w-6" />
            </div>
            <div>
              <h1 className="font-serif text-2xl font-bold text-[#1E1B18] tracking-tight">
                Google Ads Performance Command
              </h1>
              <p className="text-xs sm:text-sm text-[#685D51] mt-0.5">
                Search, Performance Max, Display campaign metrics, keyword negative bidding & ROAS analytics.
              </p>
            </div>
          </div>
        </div>

        {/* Action Controls */}
        <div className="flex flex-wrap items-center gap-3">
          <button
            onClick={() => marketingApi.exportToCsv(filteredReports, 'google_ads_reports')}
            className="flex items-center gap-2 px-4 py-2 bg-[#FFFFFF] hover:bg-[#FAF7F2] border border-[#EAE2D2] text-[#4D443B] text-xs sm:text-sm font-bold rounded-xl transition-all shadow-cream-sm"
          >
            <Download className="h-4 w-4 text-[#8E8276]" />
            <span>Export CSV</span>
          </button>
          <button
            onClick={openCreateModal}
            className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] px-4 py-2 text-xs sm:text-sm font-bold text-[#1E1B18] shadow-cream-md hover:scale-[1.02] transition-all"
          >
            <Plus className="h-4 w-4" />
            <span>New Ad Campaign</span>
          </button>
        </div>
      </div>

      {/* KPI Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <StatsCard
          title="Total Google Ads Spend"
          value={`₹${(totalSpend / 100000).toFixed(1)} Lakh`}
          subtitle="All active ad sets"
          icon={DollarSign}
          change="+14.5%"
          isPositive={true}
          colorClass="from-[#FAF6EF] to-[#F5EFEB] text-[#8A6412] border-[#E5D8C1]"
        />
        <StatsCard
          title="Google Conversions"
          value={totalConversions.toLocaleString()}
          subtitle="Direct verified bookings"
          icon={Target}
          change="+28.2%"
          isPositive={true}
          colorClass="from-emerald-50 to-teal-50 text-emerald-800 border-emerald-200"
        />
        <StatsCard
          title="Total Paid Clicks"
          value={totalClicks.toLocaleString()}
          subtitle="High intent landing visits"
          icon={MousePointerClick}
          change="+19.4%"
          isPositive={true}
          colorClass="from-blue-50 to-indigo-50 text-blue-800 border-blue-200"
        />
        <StatsCard
          title="Average Campaign ROAS"
          value={`${avgRoas}x`}
          subtitle="Return on Ad Spend"
          icon={TrendingUp}
          change="+0.8x"
          isPositive={true}
          colorClass="from-purple-50 to-pink-50 text-purple-800 border-purple-200"
        />
      </div>

      {/* Search & Filter Toolbar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-4 p-4 rounded-3xl bg-[#FFFFFF] border border-[#EAE2D2] shadow-cream-sm">
        <div className="relative w-full sm:w-80">
          <Search className="w-4 h-4 text-[#8E8276] absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search campaigns, categories..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl text-xs sm:text-sm text-[#1E1B18] placeholder-[#8E8276] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none transition-all shadow-inner"
          />
        </div>

        <div className="flex flex-wrap items-center gap-3 w-full sm:w-auto">
          <Filter className="w-4 h-4 text-[#8E8276]" />
          <select
            value={typeFilter}
            onChange={(e) => setTypeFilter(e.target.value)}
            className="bg-[#FAF7F2] border border-[#EAE2D2] text-[#4D443B] text-xs sm:text-sm font-semibold rounded-xl px-3 py-2 focus:border-[#C59A27] focus:outline-none"
          >
            <option value="all">All Campaign Types</option>
            <option value="Search">Search</option>
            <option value="Performance Max">Performance Max</option>
            <option value="Display">Display</option>
            <option value="YouTube Video">YouTube Video</option>
          </select>

          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="bg-[#FAF7F2] border border-[#EAE2D2] text-[#4D443B] text-xs sm:text-sm font-semibold rounded-xl px-3 py-2 focus:border-[#C59A27] focus:outline-none"
          >
            <option value="all">All Statuses ({reports.length})</option>
            <option value="Active">Active</option>
            <option value="Learning">Learning</option>
            <option value="Paused">Paused</option>
            <option value="Completed">Completed</option>
          </select>
        </div>
      </div>

      {/* Campaigns List */}
      <div className="grid grid-cols-1 gap-6">
        {filteredReports.map((item) => (
          <div
            key={item.id}
            className="glass-card rounded-3xl p-6 sm:p-8 bg-[#FFFFFF] shadow-cream-md hover:border-[#C59A27] transition-all space-y-6"
          >
            {/* Header Details */}
            <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4 border-b border-[#EAE2D2] pb-4">
              <div>
                <div className="flex flex-wrap items-center gap-2">
                  <span className="rounded-lg bg-[#FAF6EF] border border-[#E5D8C1] px-2.5 py-0.5 text-xs font-bold text-[#8A6412]">
                    {item.campaignType}
                  </span>
                  <span
                    className={`rounded-lg px-2.5 py-0.5 text-xs font-bold ${
                      item.status === 'Active'
                        ? 'bg-emerald-50 text-emerald-800 border border-emerald-200'
                        : item.status === 'Learning'
                        ? 'bg-amber-50 text-amber-800 border border-amber-200'
                        : 'bg-rose-50 text-rose-800 border border-rose-200'
                    }`}
                  >
                    {item.status}
                  </span>
                  <span className="text-xs text-[#8E8276]">Category: {item.targetSuperCategory}</span>
                </div>

                <h3 className="font-outfit text-base sm:text-lg font-bold text-[#1E1B18] mt-1.5">
                  {item.campaignName}
                </h3>
              </div>

              {/* ROAS & Actions */}
              <div className="flex items-center gap-4">
                <div className="text-right">
                  <div className="flex items-center gap-1.5 justify-end">
                    <span className="font-outfit text-2xl font-black text-[#8A6412]">
                      {item.roasRatio}x
                    </span>
                  </div>
                  <p className="text-[10px] text-[#8E8276] font-semibold uppercase">Campaign ROAS</p>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    onClick={() => handleEdit(item)}
                    className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] hover:bg-[#FFFFFF] p-2 text-[#4D443B] transition-colors"
                    title="Edit Campaign"
                  >
                    <Edit3 className="h-4 w-4" />
                  </button>
                  <button
                    onClick={() => handleDelete(item.id)}
                    className="rounded-xl border border-rose-200 bg-rose-50 hover:bg-rose-100 p-2 text-rose-700 transition-colors"
                    title="Delete Campaign"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </div>
            </div>

            {/* Metrics Breakdown Grid */}
            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
              <div className="rounded-2xl border border-[#EAE2D2] bg-[#FAF7F2] p-3 text-left">
                <p className="text-[10px] uppercase font-extrabold text-[#8E8276]">Total Spend</p>
                <p className="text-sm font-bold text-[#1E1B18] mt-0.5">₹{item.totalSpendInr.toLocaleString()}</p>
                <p className="text-[10px] text-[#8E8276]">₹{item.dailyBudgetInr}/day</p>
              </div>
              <div className="rounded-2xl border border-[#EAE2D2] bg-[#FAF7F2] p-3 text-left">
                <p className="text-[10px] uppercase font-extrabold text-[#8E8276]">Conversions</p>
                <p className="text-sm font-bold text-emerald-700 mt-0.5">{item.conversions} orders</p>
                <p className="text-[10px] text-emerald-800 font-semibold">CPA: ₹{item.cpaInr}</p>
              </div>
              <div className="rounded-2xl border border-[#EAE2D2] bg-[#FAF7F2] p-3 text-left">
                <p className="text-[10px] uppercase font-extrabold text-[#8E8276]">Clicks / CTR</p>
                <p className="text-sm font-bold text-[#1E1B18] mt-0.5">{item.clicks.toLocaleString()}</p>
                <p className="text-[10px] text-[#8A6412] font-semibold">{item.ctrPercent}% CTR</p>
              </div>
              <div className="rounded-2xl border border-[#EAE2D2] bg-[#FAF7F2] p-3 text-left">
                <p className="text-[10px] uppercase font-extrabold text-[#8E8276]">Impressions</p>
                <p className="text-sm font-bold text-[#1E1B18] mt-0.5">{item.impressions.toLocaleString()}</p>
                <p className="text-[10px] text-[#8E8276]">Screen reach</p>
              </div>
              <div className="rounded-2xl border border-[#EAE2D2] bg-[#FAF7F2] p-3 text-left">
                <p className="text-[10px] uppercase font-extrabold text-[#8E8276]">Average CPC</p>
                <p className="text-sm font-bold text-[#1E1B18] mt-0.5">₹{item.avgCpcInr}</p>
                <p className="text-[10px] text-emerald-700 font-semibold">Cost per click</p>
              </div>
              <div className="rounded-2xl border border-[#EAE2D2] bg-[#FAF7F2] p-3 text-left">
                <p className="text-[10px] uppercase font-extrabold text-[#8E8276]">Start Date</p>
                <p className="text-sm font-bold text-[#685D51] mt-0.5">{item.startDate}</p>
                <p className="text-[10px] text-[#8E8276]">Tracking active</p>
              </div>
            </div>

            {/* Keyword Targeting & Negatives */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 pt-2">
              <div className="rounded-2xl border border-[#EAE2D2] bg-[#FAF7F2] p-4 text-left">
                <p className="text-xs font-bold text-[#1E1B18] mb-2">🎯 Target High-Intent Keywords:</p>
                <div className="flex flex-wrap gap-1.5">
                  {item.targetKeywords.map((kw, i) => (
                    <span key={i} className="rounded-lg bg-[#FAF6EF] border border-[#E5D8C1] px-2 py-0.5 text-xs text-[#8A6412] font-semibold">
                      {kw}
                    </span>
                  ))}
                </div>
              </div>

              <div className="rounded-2xl border border-[#EAE2D2] bg-[#FAF7F2] p-4 text-left">
                <p className="text-xs font-bold text-rose-800 mb-2">🚫 Negative Keywords Excluded:</p>
                <div className="flex flex-wrap gap-1.5">
                  {item.negativeKeywords.map((nkw, i) => (
                    <span key={i} className="rounded-lg bg-rose-50 border border-rose-200 px-2 py-0.5 text-xs text-rose-700 font-semibold">
                      -{nkw}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Campaign Form Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingItem ? 'Edit Google Ad Campaign' : 'Create New Google Ad Campaign'}
        subtitle="Configure target categories, keywords, budgets and conversion metrics"
        maxWidth="max-w-2xl"
      >
        <form onSubmit={handleFormSubmit} className="space-y-4 text-left">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Campaign Name *
              </label>
              <input
                type="text"
                required
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs font-mono text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Target Category *
              </label>
              <input
                type="text"
                required
                value={formSuperCategory}
                onChange={(e) => setFormSuperCategory(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Campaign Type
              </label>
              <select
                value={formType}
                onChange={(e) => setFormType(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              >
                <option value="Search">Search</option>
                <option value="Performance Max">Performance Max</option>
                <option value="Display">Display</option>
                <option value="YouTube Video">YouTube Video</option>
              </select>
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Daily Budget (₹) *
              </label>
              <input
                type="number"
                required
                value={formDailyBudget}
                onChange={(e) => setFormDailyBudget(Number(e.target.value))}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Status
              </label>
              <select
                value={formStatus}
                onChange={(e) => setFormStatus(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              >
                <option value="Active">Active</option>
                <option value="Learning">Learning</option>
                <option value="Paused">Paused</option>
                <option value="Completed">Completed</option>
              </select>
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Target Keywords (Comma Separated) *
            </label>
            <textarea
              rows={2}
              required
              value={formKeywords}
              onChange={(e) => setFormKeywords(e.target.value)}
              className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none leading-relaxed"
            />
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Negative Keywords Excluded (Comma Separated)
            </label>
            <input
              type="text"
              value={formNegativeKeys}
              onChange={(e) => setFormNegativeKeys(e.target.value)}
              className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
            />
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Total Spend (₹)
              </label>
              <input
                type="number"
                value={formTotalSpend}
                onChange={(e) => setFormTotalSpend(Number(e.target.value))}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Clicks
              </label>
              <input
                type="number"
                value={formClicks}
                onChange={(e) => setFormClicks(Number(e.target.value))}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Conversions
              </label>
              <input
                type="number"
                value={formConversions}
                onChange={(e) => setFormConversions(Number(e.target.value))}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                ROAS Multiplier
              </label>
              <input
                type="number"
                step="0.1"
                value={formRoas}
                onChange={(e) => setFormRoas(Number(e.target.value))}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none font-bold text-[#8A6412]"
              />
            </div>
          </div>

          <div className="flex items-center justify-end gap-3 pt-4 border-t border-[#EAE2D2]">
            <button
              type="button"
              onClick={() => setIsModalOpen(false)}
              className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-4 py-2 text-xs font-bold text-[#685D51] hover:bg-[#FFFFFF] transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="rounded-xl bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] px-5 py-2 text-xs sm:text-sm font-bold text-[#1E1B18] shadow-cream-md hover:scale-[1.02] transition-all"
            >
              Save Campaign
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
};
