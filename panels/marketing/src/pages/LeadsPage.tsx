import React, { useState, useEffect } from 'react';
import { 
  Users, 
  Plus, 
  Search, 
  Filter, 
  Download, 
  DollarSign, 
  TrendingUp, 
  CheckCircle2, 
  Clock, 
  Phone, 
  Mail, 
  Building2, 
  ExternalLink, 
  Trash2, 
  Table as TableIcon,
  Kanban,
  MapPin,
  Calendar
} from 'lucide-react';
import { marketingApi } from '../api/marketingApi';
import { MarketingLeadItem, LeadSource, LeadStatus } from '../types/marketing';
import { StatsCard } from '../components/common/StatsCard';
import { Modal } from '../components/common/Modal';

export const LeadsPage: React.FC = () => {
  const [leads, setLeads] = useState<MarketingLeadItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [viewMode, setViewMode] = useState<'table' | 'kanban'>('table');
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [selectedLead, setSelectedLead] = useState<MarketingLeadItem | null>(null);

  // Form State for creating a lead
  const [formData, setFormData] = useState({
    leadName: '',
    email: '',
    contactNumber: '',
    businessName: '',
    source: 'Google Ad' as LeadSource,
    targetCategory: 'Luxury Jewelry & Gems',
    city: 'Mumbai',
    state: 'Maharashtra',
    status: 'New' as LeadStatus,
    dealValueInr: 50000,
    customerAcquisitionCostInr: 450,
    assignedRep: 'Vikram Sethi',
    notes: ''
  });

  useEffect(() => {
    loadLeads();
  }, []);

  const loadLeads = async () => {
    try {
      setLoading(true);
      const res = await marketingApi.getMarketingLeads();
      setLeads(res);
    } catch (err) {
      console.error('Failed to load leads', err);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateLead = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const newLeadPayload = {
        leadName: formData.leadName,
        email: formData.email,
        contactNumber: formData.contactNumber,
        businessName: formData.businessName,
        source: formData.source,
        targetCategory: formData.targetCategory,
        city: formData.city,
        state: formData.state,
        status: formData.status,
        dealValueInr: Number(formData.dealValueInr),
        customerAcquisitionCostInr: Number(formData.customerAcquisitionCostInr),
        assignedRep: formData.assignedRep,
        followUpDate: new Date().toISOString().split('T')[0],
        createdAt: new Date().toISOString().split('T')[0],
        notes: formData.notes
      };

      const saved = await marketingApi.saveMarketingLead(newLeadPayload);
      setLeads(prev => [saved, ...prev]);
      setIsAddModalOpen(false);
      setFormData({
        leadName: '',
        email: '',
        contactNumber: '',
        businessName: '',
        source: 'Google Ad',
        targetCategory: 'Luxury Jewelry & Gems',
        city: 'Mumbai',
        state: 'Maharashtra',
        status: 'New',
        dealValueInr: 50000,
        customerAcquisitionCostInr: 450,
        assignedRep: 'Vikram Sethi',
        notes: ''
      });
    } catch (err) {
      console.error('Failed to add lead', err);
    }
  };

  const handleUpdateStatus = async (id: string, newStatus: LeadStatus) => {
    const target = leads.find(l => l.id === id);
    if (!target) return;
    try {
      const updated = await marketingApi.saveMarketingLead({
        ...target,
        status: newStatus
      });
      setLeads(prev => prev.map(l => l.id === id ? updated : l));
      if (selectedLead && selectedLead.id === id) {
        setSelectedLead(updated);
      }
    } catch (err) {
      console.error('Failed to update lead status', err);
    }
  };

  const handleDeleteLead = async (id: string) => {
    if (!window.confirm('Are you sure you want to remove this lead record?')) return;
    try {
      await marketingApi.deleteMarketingLead(id);
      setLeads(prev => prev.filter(l => l.id !== id));
      if (selectedLead?.id === id) {
        setSelectedLead(null);
      }
    } catch (err) {
      console.error('Failed to delete lead', err);
    }
  };

  const filteredLeads = leads.filter(item => {
    const matchesSearch = item.leadName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.businessName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.source.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus = statusFilter === 'all' || item.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const totalPipelineValue = leads.reduce((sum, l) => sum + (l.dealValueInr || 0), 0);
  const wonLeads = leads.filter(l => l.status === 'Converted');
  const wonValue = wonLeads.reduce((sum, l) => sum + (l.dealValueInr || 0), 0);
  const conversionRate = leads.length > 0 ? ((wonLeads.length / leads.length) * 100).toFixed(1) : '0';

  const statusColors: Record<LeadStatus, { bg: string; text: string; border: string }> = {
    'New': { bg: 'bg-blue-50', text: 'text-blue-800', border: 'border-blue-200' },
    'Contacted': { bg: 'bg-amber-50', text: 'text-amber-800', border: 'border-amber-200' },
    'Qualified': { bg: 'bg-purple-50', text: 'text-purple-800', border: 'border-purple-200' },
    'Demo Scheduled': { bg: 'bg-indigo-50', text: 'text-indigo-800', border: 'border-indigo-200' },
    'Converted': { bg: 'bg-emerald-50', text: 'text-emerald-800', border: 'border-emerald-200' },
    'Lost': { bg: 'bg-rose-50', text: 'text-rose-800', border: 'border-rose-200' }
  };

  return (
    <div className="space-y-8 animate-fadeIn text-left">
      {/* Top Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-[#EAE2D2] pb-6">
        <div>
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-2xl bg-[#FAF6EF] border border-[#E5D8C1] text-[#9B7314] shadow-cream-sm">
              <Users className="w-6 h-6" />
            </div>
            <div>
              <h1 className="font-serif text-2xl font-bold text-[#1E1B18] tracking-tight">Leads & Conversions Hub</h1>
              <p className="text-[#685D51] text-xs sm:text-sm mt-0.5">
                Full-funnel inbound marketing attribution, pipeline velocity, and conversion tracking.
              </p>
            </div>
          </div>
        </div>

        {/* Action Controls */}
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex items-center p-1 bg-[#FAF7F2] border border-[#EAE2D2] rounded-2xl shadow-inner">
            <button
              onClick={() => setViewMode('table')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-bold transition-all ${
                viewMode === 'table'
                  ? 'bg-[#FFFFFF] text-[#1E1B18] shadow-cream-sm border border-[#EAE2D2]'
                  : 'text-[#8E8276] hover:text-[#1E1B18]'
              }`}
            >
              <TableIcon className="w-3.5 h-3.5" />
              <span>Table</span>
            </button>
            <button
              onClick={() => setViewMode('kanban')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-bold transition-all ${
                viewMode === 'kanban'
                  ? 'bg-[#FFFFFF] text-[#1E1B18] shadow-cream-sm border border-[#EAE2D2]'
                  : 'text-[#8E8276] hover:text-[#1E1B18]'
              }`}
            >
              <Kanban className="w-3.5 h-3.5" />
              <span>Kanban</span>
            </button>
          </div>

          <button
            onClick={() => marketingApi.exportToCsv(filteredLeads, 'am5_marketing_leads')}
            className="flex items-center gap-2 px-4 py-2 bg-[#FFFFFF] hover:bg-[#FAF6EF] border border-[#EAE2D2] text-[#4D443B] text-xs sm:text-sm font-bold rounded-xl transition-all shadow-cream-sm"
          >
            <Download className="w-4 h-4 text-[#8E8276]" />
            <span>Export CSV</span>
          </button>

          <button
            onClick={() => setIsAddModalOpen(true)}
            className="flex items-center gap-2 px-4 py-2 bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] hover:from-[#BA9427] hover:to-[#BA9427] text-[#1E1B18] text-xs sm:text-sm font-bold rounded-xl shadow-cream-md transition-all hover:scale-[1.02]"
          >
            <Plus className="w-4 h-4" />
            <span>Add Inbound Lead</span>
          </button>
        </div>
      </div>

      {/* KPI Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <StatsCard
          title="Total Leads"
          value={leads.length}
          subtitle="All campaign touchpoints"
          change="+24.5%"
          isPositive={true}
          icon={Users}
          colorClass="from-[#FAF6EF] to-[#F5EFEB] text-[#8A6412] border-[#E5D8C1]"
        />
        <StatsCard
          title="Pipeline Value"
          value={`₹${(totalPipelineValue / 100000).toFixed(1)} Lakh`}
          subtitle="Open high-ticket opportunities"
          change="+31.2%"
          isPositive={true}
          icon={DollarSign}
          colorClass="from-emerald-50 to-teal-50 text-emerald-800 border-emerald-200"
        />
        <StatsCard
          title="Converted Value"
          value={`₹${(wonValue / 100000).toFixed(1)} Lakh`}
          subtitle="Closed Won partnerships"
          change="+18.9%"
          isPositive={true}
          icon={CheckCircle2}
          colorClass="from-blue-50 to-indigo-50 text-blue-800 border-blue-200"
        />
        <StatsCard
          title="Conversion Rate"
          value={`${conversionRate}%`}
          subtitle="Lead to Customer ratio"
          change="+3.4%"
          isPositive={true}
          icon={TrendingUp}
          colorClass="from-purple-50 to-pink-50 text-purple-800 border-purple-200"
        />
      </div>

      {/* Search & Filter Toolbar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-4 p-4 rounded-3xl bg-[#FFFFFF] border border-[#EAE2D2] shadow-cream-sm">
        <div className="relative w-full sm:w-80">
          <Search className="w-4 h-4 text-[#8E8276] absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search leads, brands, emails..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl text-sm text-[#1E1B18] placeholder-[#8E8276] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none transition-all shadow-inner"
          />
        </div>

        <div className="flex items-center gap-3 w-full sm:w-auto">
          <Filter className="w-4 h-4 text-[#8E8276]" />
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="bg-[#FAF7F2] border border-[#EAE2D2] text-[#4D443B] text-xs sm:text-sm font-semibold rounded-xl px-3.5 py-2 focus:border-[#C59A27] focus:outline-none"
          >
            <option value="all">All Stages ({leads.length})</option>
            <option value="New">New</option>
            <option value="Contacted">Contacted</option>
            <option value="Qualified">Qualified</option>
            <option value="Demo Scheduled">Demo Scheduled</option>
            <option value="Converted">Converted</option>
            <option value="Lost">Lost</option>
          </select>
        </div>
      </div>

      {/* View: Table View */}
      {viewMode === 'table' ? (
        <div className="rounded-3xl bg-[#FFFFFF] border border-[#EAE2D2] shadow-cream-md overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-[#FAF6EF] border-b border-[#EAE2D2] text-[#685D51] text-[11px] uppercase tracking-wider font-extrabold">
                  <th className="py-4 px-6">Lead & Business</th>
                  <th className="py-4 px-4">Contact Info</th>
                  <th className="py-4 px-4">Attribution Source</th>
                  <th className="py-4 px-4">Stage</th>
                  <th className="py-4 px-4 text-right">Deal Value</th>
                  <th className="py-4 px-6 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#EAE2D2]/80 text-sm">
                {filteredLeads.map((item) => {
                  const sc = statusColors[item.status] || statusColors.New;
                  return (
                    <tr 
                      key={item.id} 
                      className="hover:bg-[#FAF7F2] transition-colors group cursor-pointer"
                      onClick={() => setSelectedLead(item)}
                    >
                      <td className="py-4 px-6">
                        <div className="font-bold text-[#1E1B18] group-hover:text-[#9B7314] transition-colors">
                          {item.leadName}
                        </div>
                        <div className="flex items-center gap-1.5 text-xs text-[#685D51] mt-0.5">
                          <Building2 className="w-3.5 h-3.5 text-[#8E8276]" />
                          <span>{item.businessName}</span>
                        </div>
                        <div className="flex items-center gap-1 text-[11px] text-[#8E8276] mt-1">
                          <MapPin className="w-3 h-3" />
                          <span>{item.city}, {item.state}</span>
                        </div>
                      </td>

                      <td className="py-4 px-4">
                        <div className="flex items-center gap-1.5 text-xs text-[#4D443B]">
                          <Mail className="w-3.5 h-3.5 text-[#8E8276]" />
                          <span>{item.email}</span>
                        </div>
                        <div className="flex items-center gap-1.5 text-xs text-[#685D51] mt-1">
                          <Phone className="w-3.5 h-3.5 text-[#8E8276]" />
                          <span>{item.contactNumber}</span>
                        </div>
                      </td>

                      <td className="py-4 px-4">
                        <span className="inline-block px-2.5 py-1 rounded-lg text-xs font-bold bg-[#FAF6EF] text-[#8A6412] border border-[#E5D8C1]">
                          {item.source}
                        </span>
                        <div className="text-[11px] text-[#8E8276] mt-1 truncate max-w-[150px]">
                          {item.targetCategory}
                        </div>
                      </td>

                      <td className="py-4 px-4">
                        <select
                          value={item.status}
                          onClick={(e) => e.stopPropagation()}
                          onChange={(e) => handleUpdateStatus(item.id, e.target.value as LeadStatus)}
                          className={`text-xs font-bold uppercase tracking-wider rounded-lg px-2.5 py-1 border ${sc.bg} ${sc.text} ${sc.border} focus:outline-none`}
                        >
                          <option value="New">NEW</option>
                          <option value="Contacted">CONTACTED</option>
                          <option value="Qualified">QUALIFIED</option>
                          <option value="Demo Scheduled">DEMO SCHEDULED</option>
                          <option value="Converted">CONVERTED</option>
                          <option value="Lost">LOST</option>
                        </select>
                      </td>

                      <td className="py-4 px-4 text-right">
                        <div className="font-bold text-[#9B7314]">
                          ₹{item.dealValueInr.toLocaleString()}
                        </div>
                        <div className="text-[11px] text-[#8E8276]">
                          CAC: ₹{item.customerAcquisitionCostInr}
                        </div>
                      </td>

                      <td className="py-4 px-6 text-right" onClick={(e) => e.stopPropagation()}>
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => setSelectedLead(item)}
                            className="p-1.5 rounded-lg bg-[#FAF7F2] hover:bg-[#FFFFFF] border border-[#EAE2D2] text-[#4D443B] transition-colors"
                            title="View Details"
                          >
                            <ExternalLink className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => handleDeleteLead(item.id)}
                            className="p-1.5 rounded-lg bg-rose-50 hover:bg-rose-100 border border-rose-200 text-rose-700 transition-colors"
                            title="Delete Lead"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      ) : (
        /* View: Kanban Pipeline View */
        <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-6 gap-4 overflow-x-auto pb-4">
          {(['New', 'Contacted', 'Qualified', 'Demo Scheduled', 'Converted', 'Lost'] as const).map((stage) => {
            const stageLeads = filteredLeads.filter(l => l.status === stage);
            const stageValue = stageLeads.reduce((sum, l) => sum + l.dealValueInr, 0);
            const sc = statusColors[stage];

            return (
              <div key={stage} className="p-4 rounded-3xl bg-[#FFFFFF] border border-[#EAE2D2] shadow-cream-sm flex flex-col min-w-[240px]">
                <div className="flex items-center justify-between mb-3 border-b border-[#EAE2D2] pb-3">
                  <div className="flex items-center gap-2">
                    <span className={`w-2.5 h-2.5 rounded-full ${sc.bg} border ${sc.border}`}></span>
                    <span className="text-xs font-bold uppercase tracking-wider text-[#1E1B18]">{stage}</span>
                  </div>
                  <span className="text-xs font-bold px-2 py-0.5 rounded-full bg-[#FAF6EF] text-[#8A6412] border border-[#E5D8C1]">
                    {stageLeads.length}
                  </span>
                </div>

                <div className="text-[11px] font-bold text-[#8E8276] mb-3">
                  ₹{(stageValue / 1000).toFixed(0)}k Value
                </div>

                <div className="space-y-3 flex-1 overflow-y-auto max-h-[500px] pr-1">
                  {stageLeads.map((item) => (
                    <div
                      key={item.id}
                      onClick={() => setSelectedLead(item)}
                      className="p-3.5 rounded-2xl bg-[#FAF7F2] hover:bg-[#FFFFFF] border border-[#EAE2D2] hover:border-[#C59A27] hover:shadow-cream-sm cursor-pointer transition-all space-y-2 group"
                    >
                      <div className="font-bold text-[#1E1B18] text-xs group-hover:text-[#9B7314] transition-colors">
                        {item.leadName}
                      </div>
                      <div className="text-[11px] text-[#685D51] truncate">
                        {item.businessName}
                      </div>
                      <div className="flex items-center justify-between pt-2 border-t border-[#EAE2D2]">
                        <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-[#FAF6EF] text-[#8A6412] border border-[#E5D8C1]">
                          ₹{(item.dealValueInr / 1000).toFixed(0)}k
                        </span>
                        <span className="text-[10px] text-[#8E8276]">
                          {item.source}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Add Inbound Lead Modal */}
      <Modal
        isOpen={isAddModalOpen}
        onClose={() => setIsAddModalOpen(false)}
        title="Add Inbound Marketing Lead"
        maxWidth="max-w-2xl"
      >
        <form onSubmit={handleCreateLead} className="space-y-4 text-left">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-[#4D443B] uppercase tracking-wider mb-2">
                Lead Full Name *
              </label>
              <input
                type="text"
                required
                value={formData.leadName}
                onChange={(e) => setFormData({ ...formData, leadName: e.target.value })}
                placeholder="e.g., Rajesh Malhotra"
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none transition-all"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-[#4D443B] uppercase tracking-wider mb-2">
                Business / Brand Name *
              </label>
              <input
                type="text"
                required
                value={formData.businessName}
                onChange={(e) => setFormData({ ...formData, businessName: e.target.value })}
                placeholder="e.g., Malhotra Jewels & Gems"
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none transition-all"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-[#4D443B] uppercase tracking-wider mb-2">
                Email Address *
              </label>
              <input
                type="email"
                required
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                placeholder="rajesh@malhotrajewels.in"
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none transition-all"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-[#4D443B] uppercase tracking-wider mb-2">
                Phone Number *
              </label>
              <input
                type="text"
                required
                value={formData.contactNumber}
                onChange={(e) => setFormData({ ...formData, contactNumber: e.target.value })}
                placeholder="+91 98201 55432"
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none transition-all"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="block text-xs font-bold text-[#4D443B] uppercase tracking-wider mb-2">
                Attribution Source
              </label>
              <select
                value={formData.source}
                onChange={(e) => setFormData({ ...formData, source: e.target.value as LeadSource })}
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:outline-none"
              >
                <option value="Google Ad">Google Ad</option>
                <option value="Instagram Ad">Instagram Ad</option>
                <option value="LinkedIn">LinkedIn</option>
                <option value="Facebook Ad">Facebook Ad</option>
                <option value="SEO Organic">SEO Organic</option>
                <option value="Blog">Blog & Articles</option>
                <option value="Referral">Direct Referral</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-bold text-[#4D443B] uppercase tracking-wider mb-2">
                Initial Stage
              </label>
              <select
                value={formData.status}
                onChange={(e) => setFormData({ ...formData, status: e.target.value as LeadStatus })}
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:outline-none"
              >
                <option value="New">New</option>
                <option value="Contacted">Contacted</option>
                <option value="Qualified">Qualified</option>
                <option value="Demo Scheduled">Demo Scheduled</option>
                <option value="Converted">Converted</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-bold text-[#4D443B] uppercase tracking-wider mb-2">
                Deal Value (₹)
              </label>
              <input
                type="number"
                value={formData.dealValueInr}
                onChange={(e) => setFormData({ ...formData, dealValueInr: Number(e.target.value) })}
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:outline-none font-mono"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-[#4D443B] uppercase tracking-wider mb-2">
                Target Category
              </label>
              <input
                type="text"
                value={formData.targetCategory}
                onChange={(e) => setFormData({ ...formData, targetCategory: e.target.value })}
                placeholder="e.g., Luxury Diamond Tier"
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:outline-none"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-[#4D443B] uppercase tracking-wider mb-2">
                City / Region
              </label>
              <input
                type="text"
                value={formData.city}
                onChange={(e) => setFormData({ ...formData, city: e.target.value })}
                placeholder="Mumbai"
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:outline-none"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-[#4D443B] uppercase tracking-wider mb-2">
              Inquiry / Qualification Notes
            </label>
            <textarea
              rows={3}
              value={formData.notes}
              onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
              placeholder="Inquired about AM5 luxury vendor portal onboarding..."
              className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:outline-none"
            />
          </div>

          <div className="flex items-center justify-end gap-3 pt-4 border-t border-[#EAE2D2]">
            <button
              type="button"
              onClick={() => setIsAddModalOpen(false)}
              className="px-4 py-2 rounded-xl border border-[#EAE2D2] text-[#685D51] hover:bg-[#FAF7F2] text-sm font-semibold transition-all"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-5 py-2 rounded-xl bg-gradient-to-r from-[#C59A27] to-[#DAB84E] text-[#1E1B18] font-bold text-sm shadow-cream-md hover:scale-[1.02] transition-all"
            >
              Save Inbound Lead
            </button>
          </div>
        </form>
      </Modal>

      {/* View Lead Detail Modal */}
      {selectedLead && (
        <Modal
          isOpen={true}
          onClose={() => setSelectedLead(null)}
          title={`Lead Dossier: ${selectedLead.leadName}`}
          maxWidth="max-w-xl"
        >
          <div className="space-y-6 text-left">
            <div className="flex items-center justify-between p-4 rounded-2xl bg-[#FAF6EF] border border-[#E5D8C1]">
              <div>
                <h3 className="text-lg font-bold text-[#1E1B18]">{selectedLead.leadName}</h3>
                <p className="text-xs text-[#8A6412] font-semibold">{selectedLead.businessName}</p>
              </div>
              <div className="text-right">
                <div className="text-xl font-bold text-emerald-700">₹{selectedLead.dealValueInr.toLocaleString()}</div>
                <div className="text-[11px] text-[#8E8276]">Expected Deal Value</div>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
              <div className="p-4 rounded-2xl bg-[#FFFFFF] border border-[#EAE2D2] space-y-2">
                <div className="text-xs font-bold text-[#8E8276] uppercase tracking-wider">Contact Coordinates</div>
                <div className="flex items-center gap-2 text-[#4D443B]">
                  <Mail className="w-4 h-4 text-[#C59A27]" />
                  <span>{selectedLead.email}</span>
                </div>
                <div className="flex items-center gap-2 text-[#4D443B]">
                  <Phone className="w-4 h-4 text-[#C59A27]" />
                  <span>{selectedLead.contactNumber}</span>
                </div>
              </div>

              <div className="p-4 rounded-2xl bg-[#FFFFFF] border border-[#EAE2D2] space-y-2">
                <div className="text-xs font-bold text-[#8E8276] uppercase tracking-wider">Marketing Attribution</div>
                <div className="text-[#4D443B]">
                  Source: <span className="text-[#8A6412] font-bold">{selectedLead.source}</span>
                </div>
                <div className="text-[#4D443B]">
                  Location: <span className="text-[#1E1B18]">{selectedLead.city}, {selectedLead.state}</span>
                </div>
              </div>
            </div>

            <div className="p-4 rounded-2xl bg-[#FFFFFF] border border-[#EAE2D2] space-y-2">
              <div className="text-xs font-bold text-[#8E8276] uppercase tracking-wider">Client Inquiry Notes</div>
              <p className="text-[#685D51] text-sm leading-relaxed">{selectedLead.notes || 'No specific notes recorded.'}</p>
            </div>

            <div className="flex items-center justify-between pt-4 border-t border-[#EAE2D2]">
              <div className="flex items-center gap-2">
                <span className="text-xs text-[#8E8276]">Change Status:</span>
                <select
                  value={selectedLead.status}
                  onChange={(e) => handleUpdateStatus(selectedLead.id, e.target.value as LeadStatus)}
                  className="bg-[#FAF7F2] border border-[#EAE2D2] rounded-lg px-3 py-1.5 text-xs font-bold text-[#8A6412] focus:outline-none"
                >
                  <option value="New">New</option>
                  <option value="Contacted">Contacted</option>
                  <option value="Qualified">Qualified</option>
                  <option value="Demo Scheduled">Demo Scheduled</option>
                  <option value="Converted">Converted</option>
                  <option value="Lost">Lost</option>
                </select>
              </div>

              <div className="flex items-center gap-3">
                <button
                  onClick={() => handleDeleteLead(selectedLead.id)}
                  className="px-4 py-2 rounded-xl bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 text-xs font-bold transition-all"
                >
                  Delete Lead
                </button>
                <button
                  onClick={() => setSelectedLead(null)}
                  className="px-5 py-2 rounded-xl bg-[#FAF7F2] hover:bg-[#FAF6EF] text-[#1E1B18] border border-[#EAE2D2] text-xs font-bold transition-all"
                >
                  Done
                </button>
              </div>
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
};
