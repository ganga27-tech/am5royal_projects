import React, { useState, useEffect } from 'react';
import { 
  Target, 
  Plus, 
  Search, 
  Filter, 
  DollarSign, 
  Clock, 
  Award, 
  Trash2, 
  CheckSquare, 
  Square,
  Sparkles,
  CheckCircle2
} from 'lucide-react';
import { marketingApi } from '../api/marketingApi';
import { MarketingStrategyItem, StrategyMilestone } from '../types/marketing';
import { StatsCard } from '../components/common/StatsCard';
import { Modal } from '../components/common/Modal';

export const StrategiesPage: React.FC = () => {
  const [strategies, setStrategies] = useState<MarketingStrategyItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [selectedStrategy, setSelectedStrategy] = useState<MarketingStrategyItem | null>(null);

  // Form State for creating a strategy
  const [formData, setFormData] = useState({
    title: '',
    objective: '',
    horizonQuarter: 'Q3 2026',
    status: 'Planning' as MarketingStrategyItem['status'],
    allocatedBudgetInr: 350000,
    targetSuperCategories: 'Home Cleaning, Bridal Jewelry',
    coreChannels: 'Google Ads, Instagram, Luxury PR',
    kpis: '1,000 Luxury Leads, 4.5x ROAS',
    ownerName: 'Vikram Sethi',
    milestonesText: 'Vendor Discovery Pipeline\nInfluencer Gifting Activation\nConversion Rate Optimization'
  });

  useEffect(() => {
    loadStrategies();
  }, []);

  const loadStrategies = async () => {
    try {
      setLoading(true);
      const res = await marketingApi.getStrategies();
      setStrategies(res);
    } catch (err) {
      console.error('Failed to load strategies', err);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateStrategy = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const parsedMilestones: StrategyMilestone[] = formData.milestonesText
        .split('\n')
        .map(t => t.trim())
        .filter(Boolean)
        .map((title, idx) => ({
          id: `m_${Date.now()}_${idx}`,
          title,
          completed: false,
          dueDate: '2026-09-30'
        }));

      const newPayload = {
        title: formData.title,
        objective: formData.objective,
        horizonQuarter: formData.horizonQuarter,
        status: formData.status,
        allocatedBudgetInr: Number(formData.allocatedBudgetInr),
        spentBudgetInr: 0,
        projectedLeads: 500,
        actualLeads: 0,
        targetSuperCategories: formData.targetSuperCategories.split(',').map(c => c.trim()).filter(Boolean),
        targetRegions: ['Mumbai', 'Bengaluru', 'Delhi NCR'],
        coreChannels: formData.coreChannels.split(',').map(c => c.trim()).filter(Boolean),
        kpis: formData.kpis.split(',').map(k => k.trim()).filter(Boolean),
        milestones: parsedMilestones,
        ownerName: formData.ownerName
      };

      const saved = await marketingApi.saveStrategy(newPayload);
      setStrategies(prev => [saved, ...prev]);
      setIsAddModalOpen(false);
      setFormData({
        title: '',
        objective: '',
        horizonQuarter: 'Q3 2026',
        status: 'Planning',
        allocatedBudgetInr: 350000,
        targetSuperCategories: 'Home Cleaning, Bridal Jewelry',
        coreChannels: 'Google Ads, Instagram, Luxury PR',
        kpis: '1,000 Luxury Leads, 4.5x ROAS',
        ownerName: 'Vikram Sethi',
        milestonesText: 'Vendor Discovery Pipeline\nInfluencer Gifting Activation\nConversion Rate Optimization'
      });
    } catch (err) {
      console.error('Failed to create strategy', err);
    }
  };

  const handleToggleMilestone = async (strategyId: string, milestoneId: string) => {
    const target = strategies.find(s => s.id === strategyId);
    if (!target) return;

    const updatedMilestones = target.milestones.map(m => 
      m.id === milestoneId ? { ...m, completed: !m.completed } : m
    );

    try {
      const updated = await marketingApi.saveStrategy({
        ...target,
        milestones: updatedMilestones
      });

      setStrategies(prev => prev.map(s => s.id === strategyId ? updated : s));
      if (selectedStrategy?.id === strategyId) {
        setSelectedStrategy(updated);
      }
    } catch (err) {
      console.error('Failed to toggle milestone', err);
    }
  };

  const handleDeleteStrategy = async (id: string) => {
    if (!window.confirm('Delete this marketing strategy?')) return;
    try {
      await marketingApi.deleteStrategy(id);
      setStrategies(prev => prev.filter(s => s.id !== id));
      if (selectedStrategy?.id === id) {
        setSelectedStrategy(null);
      }
    } catch (err) {
      console.error('Failed to delete strategy', err);
    }
  };

  const filteredStrategies = strategies.filter(item => {
    const matchesSearch = item.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.objective.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.ownerName.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus = statusFilter === 'all' || item.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const totalBudget = filteredStrategies.reduce((sum, s) => sum + s.allocatedBudgetInr, 0);
  const activeCount = filteredStrategies.filter(s => s.status === 'Active').length;

  const statusBadges: Record<MarketingStrategyItem['status'], { bg: string; text: string; border: string }> = {
    Planning: { bg: 'bg-blue-50', text: 'text-blue-800', border: 'border-blue-200' },
    Active: { bg: 'bg-emerald-50', text: 'text-emerald-800', border: 'border-emerald-200' },
    Completed: { bg: 'bg-[#FAF6EF]', text: 'text-[#8A6412]', border: 'border-[#E5D8C1]' },
    'Under Review': { bg: 'bg-purple-50', text: 'text-purple-800', border: 'border-purple-200' },
    Paused: { bg: 'bg-rose-50', text: 'text-rose-800', border: 'border-rose-200' }
  };

  return (
    <div className="space-y-8 animate-fadeIn text-left">
      {/* Top Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-[#EAE2D2] pb-6">
        <div>
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-2xl bg-[#FAF6EF] border border-[#E5D8C1] text-[#9B7314] shadow-cream-sm">
              <Target className="w-6 h-6" />
            </div>
            <div>
              <h1 className="font-serif text-2xl font-bold text-[#1E1B18] tracking-tight">Marketing Growth Strategies</h1>
              <p className="text-[#685D51] text-xs sm:text-sm mt-0.5">
                Strategic quarterly roadmaps, budget execution, and KPI milestone achievements.
              </p>
            </div>
          </div>
        </div>

        {/* Action Controls */}
        <div className="flex items-center gap-3">
          <button
            onClick={() => setIsAddModalOpen(true)}
            className="flex items-center gap-2 px-4 py-2.5 bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] text-[#1E1B18] text-xs sm:text-sm font-bold rounded-xl shadow-cream-md transition-all hover:scale-[1.02]"
          >
            <Plus className="w-4 h-4" />
            <span>Create Growth Strategy</span>
          </button>
        </div>
      </div>

      {/* KPI Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <StatsCard
          title="Total Roadmaps"
          value={filteredStrategies.length}
          subtitle="Active & planned strategic tracks"
          change="+20%"
          isPositive={true}
          icon={Target}
          colorClass="from-[#FAF6EF] to-[#F5EFEB] text-[#8A6412] border-[#E5D8C1]"
        />
        <StatsCard
          title="Active Execution"
          value={activeCount}
          subtitle="Currently running initiatives"
          change="+14.3%"
          isPositive={true}
          icon={Clock}
          colorClass="from-blue-50 to-indigo-50 text-blue-800 border-blue-200"
        />
        <StatsCard
          title="Allocated Budget"
          value={`₹${(totalBudget / 100000).toFixed(1)} Lakh`}
          subtitle="Strategy war-chest investment"
          change="+25.0%"
          isPositive={true}
          icon={DollarSign}
          colorClass="from-emerald-50 to-teal-50 text-emerald-800 border-emerald-200"
        />
        <StatsCard
          title="Avg Milestone Velocity"
          value="74%"
          subtitle="Across all strategic roadmaps"
          change="+8.5%"
          isPositive={true}
          icon={Award}
          colorClass="from-purple-50 to-pink-50 text-purple-800 border-purple-200"
        />
      </div>

      {/* Search & Filter Toolbar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-4 p-4 rounded-3xl bg-[#FFFFFF] border border-[#EAE2D2] shadow-cream-sm">
        <div className="relative w-full sm:w-80">
          <Search className="w-4 h-4 text-[#8E8276] absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search strategy title, owner, objective..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl text-xs sm:text-sm text-[#1E1B18] placeholder-[#8E8276] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none transition-all shadow-inner"
          />
        </div>

        <div className="flex items-center gap-3 w-full sm:w-auto">
          <Filter className="w-4 h-4 text-[#8E8276]" />
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="bg-[#FAF7F2] border border-[#EAE2D2] text-[#4D443B] text-xs sm:text-sm font-semibold rounded-xl px-3 py-2 focus:border-[#C59A27] focus:outline-none"
          >
            <option value="all">All Statuses ({strategies.length})</option>
            <option value="Planning">Planning</option>
            <option value="Active">Active</option>
            <option value="Under Review">Under Review</option>
            <option value="Completed">Completed</option>
            <option value="Paused">Paused</option>
          </select>
        </div>
      </div>

      {/* Strategies Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {filteredStrategies.map((strategy) => {
          const sb = statusBadges[strategy.status] || statusBadges.Planning;
          const completedMilestones = strategy.milestones.filter(m => m.completed).length;
          const progressPercent = strategy.milestones.length > 0 
            ? Math.round((completedMilestones / strategy.milestones.length) * 100) 
            : 0;

          return (
            <div
              key={strategy.id}
              className="p-6 rounded-3xl bg-[#FFFFFF] border border-[#EAE2D2] hover:border-[#C59A27] transition-all flex flex-col justify-between space-y-5 shadow-cream-md group"
            >
              <div>
                {/* Header Badge */}
                <div className="flex items-center justify-between gap-2 mb-3">
                  <span className="text-xs font-mono font-bold px-2.5 py-1 rounded-lg bg-[#FAF6EF] text-[#8A6412] border border-[#E5D8C1]">
                    {strategy.horizonQuarter}
                  </span>
                  <span className={`text-xs font-bold uppercase tracking-wider px-2.5 py-1 rounded-lg border ${sb.bg} ${sb.text} ${sb.border}`}>
                    {strategy.status}
                  </span>
                </div>

                {/* Title & Objective */}
                <h3 className="font-serif text-lg font-bold text-[#1E1B18] group-hover:text-[#9B7314] transition-colors">
                  {strategy.title}
                </h3>
                <p className="text-xs sm:text-sm text-[#685D51] mt-1.5 leading-relaxed">
                  {strategy.objective}
                </p>

                {/* Channels & Target Audience */}
                <div className="mt-4 p-3.5 rounded-2xl bg-[#FAF7F2] border border-[#EAE2D2] space-y-2 text-xs">
                  <div className="flex items-center justify-between">
                    <span className="text-[#8E8276] font-semibold">Categories:</span>
                    <span className="font-bold text-[#1E1B18]">{strategy.targetSuperCategories.join(', ')}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-[#8E8276] font-semibold">Budget Allocated:</span>
                    <span className="font-bold text-[#9B7314]">₹{strategy.allocatedBudgetInr.toLocaleString()}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-[#8E8276] font-semibold">Lead Strategist:</span>
                    <span className="font-bold text-[#1E1B18]">{strategy.ownerName}</span>
                  </div>
                </div>

                {/* Progress Bar */}
                <div className="mt-4 space-y-1.5">
                  <div className="flex items-center justify-between text-xs font-semibold">
                    <span className="text-[#685D51]">Execution Velocity</span>
                    <span className="font-bold text-[#8A6412]">{progressPercent}%</span>
                  </div>
                  <div className="w-full h-2.5 bg-[#FAF7F2] border border-[#EAE2D2] rounded-full overflow-hidden">
                    <div
                      style={{ width: `${progressPercent}%` }}
                      className="h-full bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] rounded-full transition-all duration-500"
                    ></div>
                  </div>
                </div>

                {/* Milestone Checklist Preview */}
                <div className="mt-5 space-y-2">
                  <div className="text-xs font-extrabold text-[#8E8276] uppercase tracking-wider">
                    Milestones ({completedMilestones}/{strategy.milestones.length})
                  </div>
                  <div className="space-y-1.5">
                    {strategy.milestones.map((m) => (
                      <div
                        key={m.id}
                        onClick={() => handleToggleMilestone(strategy.id, m.id)}
                        className={`flex items-center gap-2.5 p-2 rounded-xl text-xs cursor-pointer transition-colors border ${
                          m.completed 
                            ? 'bg-emerald-50 text-emerald-800 border-emerald-200 font-semibold' 
                            : 'bg-[#FAF7F2] text-[#4D443B] border-[#EAE2D2] hover:bg-[#FFFFFF]'
                        }`}
                      >
                        {m.completed ? (
                          <CheckSquare className="w-4 h-4 text-emerald-600 shrink-0" />
                        ) : (
                          <Square className="w-4 h-4 text-[#8E8276] shrink-0" />
                        )}
                        <span className={m.completed ? 'line-through text-[#8E8276]' : 'font-medium'}>
                          {m.title}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              {/* Bottom Footer Actions */}
              <div className="pt-4 border-t border-[#EAE2D2] flex items-center justify-between">
                <div className="flex flex-wrap gap-1">
                  {strategy.kpis.map((k, i) => (
                    <span key={i} className="text-[10px] font-bold px-2 py-0.5 rounded-lg bg-[#FAF6EF] text-[#8A6412] border border-[#E5D8C1]">
                      🎯 {k}
                    </span>
                  ))}
                </div>

                <div className="flex items-center gap-2">
                  <button
                    onClick={() => handleDeleteStrategy(strategy.id)}
                    className="p-2 rounded-xl border border-rose-200 bg-rose-50 hover:bg-rose-100 text-rose-700 transition-colors"
                    title="Delete Strategy"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Create Strategy Modal */}
      <Modal
        isOpen={isAddModalOpen}
        onClose={() => setIsAddModalOpen(false)}
        title="Create Strategic Growth Initiative"
        maxWidth="max-w-2xl"
      >
        <form onSubmit={handleCreateStrategy} className="space-y-4 text-left">
          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Strategy Title *
            </label>
            <input
              type="text"
              required
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              placeholder="e.g., Luxury Diamond Tier Vendor Onboarding Campaign"
              className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
            />
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Primary Objective *
            </label>
            <textarea
              rows={2}
              required
              value={formData.objective}
              onChange={(e) => setFormData({ ...formData, objective: e.target.value })}
              placeholder="Target 250+ top-tier certified vendors across Mumbai & Bangalore..."
              className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none leading-relaxed"
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Horizon / Cycle
              </label>
              <input
                type="text"
                value={formData.horizonQuarter}
                onChange={(e) => setFormData({ ...formData, horizonQuarter: e.target.value })}
                placeholder="Q3 2026"
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:outline-none"
              />
            </div>

            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Budget (₹)
              </label>
              <input
                type="number"
                value={formData.allocatedBudgetInr}
                onChange={(e) => setFormData({ ...formData, allocatedBudgetInr: Number(e.target.value) })}
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:outline-none font-mono"
              />
            </div>

            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Lead Owner
              </label>
              <input
                type="text"
                value={formData.ownerName}
                onChange={(e) => setFormData({ ...formData, ownerName: e.target.value })}
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:outline-none"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Target Categories (comma separated)
              </label>
              <input
                type="text"
                value={formData.targetSuperCategories}
                onChange={(e) => setFormData({ ...formData, targetSuperCategories: e.target.value })}
                placeholder="Home Cleaning, Diamond Jewelry"
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:outline-none"
              />
            </div>

            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Core Marketing Channels
              </label>
              <input
                type="text"
                value={formData.coreChannels}
                onChange={(e) => setFormData({ ...formData, coreChannels: e.target.value })}
                placeholder="Google Ads, Instagram, PR Media"
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:outline-none"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Key Performance Indicators (KPIs)
            </label>
            <input
              type="text"
              value={formData.kpis}
              onChange={(e) => setFormData({ ...formData, kpis: e.target.value })}
              placeholder="e.g., 250 Verified Vendors, ₹1.5 Cr GMV, 4.5x ROAS"
              className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:outline-none"
            />
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Milestone Checklist (one per line)
            </label>
            <textarea
              rows={3}
              value={formData.milestonesText}
              onChange={(e) => setFormData({ ...formData, milestonesText: e.target.value })}
              placeholder="Build High-Converting Landing Page&#10;Deploy Google Performance Max Ad Sets&#10;Onboard 50 Diamond Partners"
              className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-xs focus:border-[#C59A27] focus:outline-none font-mono"
            />
          </div>

          <div className="flex items-center justify-end gap-3 pt-4 border-t border-[#EAE2D2]">
            <button
              type="button"
              onClick={() => setIsAddModalOpen(false)}
              className="px-4 py-2 rounded-xl border border-[#EAE2D2] text-[#685D51] hover:bg-[#FAF7F2] text-xs font-bold transition-all"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-5 py-2 rounded-xl bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] text-[#1E1B18] font-bold text-xs sm:text-sm shadow-cream-md hover:scale-[1.02] transition-all"
            >
              Launch Strategy
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
};

