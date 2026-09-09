import React, { useState, useEffect } from 'react';
import { 
  Sparkles, 
  Plus, 
  Search, 
  Filter, 
  Copy, 
  Check, 
  ExternalLink, 
  Trash2, 
  Layers, 
  FileText, 
  Video, 
  Mail, 
  Bell, 
  ThumbsUp, 
  Clock, 
  CheckCircle2, 
  Tag
} from 'lucide-react';
import { marketingApi } from '../api/marketingApi';
import { ContentCreationItem, ContentType } from '../types/marketing';
import { StatsCard } from '../components/common/StatsCard';
import { Modal } from '../components/common/Modal';

export const ContentCreationsPage: React.FC = () => {
  const [items, setItems] = useState<ContentCreationItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [typeFilter, setTypeFilter] = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [copiedId, setCopiedId] = useState<string | null>(null);
  const [selectedItem, setSelectedItem] = useState<ContentCreationItem | null>(null);

  // Form State
  const [formData, setFormData] = useState({
    title: '',
    contentType: 'Ad Banner Copy' as ContentType,
    platform: 'Instagram',
    approvalStatus: 'Draft' as ContentCreationItem['approvalStatus'],
    targetPersona: 'Bridal Couples & Luxury Shoppers',
    copyText: '',
    visualAssetUrl: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=800&q=80',
    assignedCreator: 'Aanya Sharma',
    performanceTags: 'Luxury, Bridal, Festive, Royal'
  });

  useEffect(() => {
    loadContent();
  }, []);

  const loadContent = async () => {
    try {
      setLoading(true);
      const res = await marketingApi.getContentCreations();
      setItems(res);
    } catch (err) {
      console.error('Failed to load content creations', err);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateContent = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const newPayload = {
        title: formData.title,
        contentType: formData.contentType,
        platform: formData.platform,
        approvalStatus: formData.approvalStatus,
        targetPersona: formData.targetPersona,
        copyText: formData.copyText,
        visualAssetUrl: formData.visualAssetUrl,
        assignedCreator: formData.assignedCreator,
        deadlineDate: new Date(Date.now() + 7 * 86400000).toISOString().split('T')[0],
        performanceTags: formData.performanceTags.split(',').map(t => t.trim()).filter(Boolean),
        createdAt: new Date().toISOString().split('T')[0]
      };

      const saved = await marketingApi.saveContentCreation(newPayload);
      setItems(prev => [saved, ...prev]);
      setIsAddModalOpen(false);
      setFormData({
        title: '',
        contentType: 'Ad Banner Copy',
        platform: 'Instagram',
        approvalStatus: 'Draft',
        targetPersona: 'Bridal Couples & Luxury Shoppers',
        copyText: '',
        visualAssetUrl: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=800&q=80',
        assignedCreator: 'Aanya Sharma',
        performanceTags: 'Luxury, Bridal, Festive, Royal'
      });
    } catch (err) {
      console.error('Failed to create content', err);
    }
  };

  const handleCopy = (id: string, text: string) => {
    navigator.clipboard.writeText(text);
    setCopiedId(id);
    setTimeout(() => setCopiedId(null), 2000);
  };

  const handleUpdateStatus = async (id: string, newStatus: ContentCreationItem['approvalStatus']) => {
    const target = items.find(c => c.id === id);
    if (!target) return;
    try {
      const updated = await marketingApi.saveContentCreation({
        ...target,
        approvalStatus: newStatus
      });
      setItems(prev => prev.map(c => c.id === id ? updated : c));
      if (selectedItem?.id === id) {
        setSelectedItem(updated);
      }
    } catch (err) {
      console.error('Failed to update status', err);
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Delete this creative copy?')) return;
    try {
      await marketingApi.deleteContentCreation(id);
      setItems(prev => prev.filter(c => c.id !== id));
      if (selectedItem?.id === id) {
        setSelectedItem(null);
      }
    } catch (err) {
      console.error('Failed to delete content', err);
    }
  };

  const filteredItems = items.filter(item => {
    const matchesSearch = item.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.copyText.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.assignedCreator.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesType = typeFilter === 'all' || item.contentType === typeFilter;
    const matchesStatus = statusFilter === 'all' || item.approvalStatus === statusFilter;
    return matchesSearch && matchesType && matchesStatus;
  });

  const typeIcons: Record<string, React.ReactNode> = {
    'Short Video Script (Reel/Short)': <Video className="w-4 h-4 text-purple-600" />,
    'Ad Banner Copy': <Sparkles className="w-4 h-4 text-[#8A6412]" />,
    'Email Newsletter': <Mail className="w-4 h-4 text-emerald-600" />,
    'Push Notification': <Bell className="w-4 h-4 text-rose-600" />,
    'Brochure / Flyer': <Layers className="w-4 h-4 text-blue-600" />,
    'Case Study': <FileText className="w-4 h-4 text-indigo-600" />
  };

  const statusBadges: Record<ContentCreationItem['approvalStatus'], { bg: string; text: string; border: string }> = {
    Draft: { bg: 'bg-[#FAF7F2]', text: 'text-[#685D51]', border: 'border-[#EAE2D2]' },
    'Under Review': { bg: 'bg-amber-50', text: 'text-amber-800', border: 'border-amber-200' },
    'Revision Requested': { bg: 'bg-rose-50', text: 'text-rose-800', border: 'border-rose-200' },
    Approved: { bg: 'bg-emerald-50', text: 'text-emerald-800', border: 'border-emerald-200' },
    Published: { bg: 'bg-blue-50', text: 'text-blue-800', border: 'border-blue-200' }
  };

  return (
    <div className="space-y-8 animate-fadeIn text-left">
      {/* Top Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-[#EAE2D2] pb-6">
        <div>
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-2xl bg-[#FAF6EF] border border-[#E5D8C1] text-[#9B7314] shadow-cream-sm">
              <Sparkles className="w-6 h-6" />
            </div>
            <div>
              <h1 className="font-serif text-2xl font-bold text-[#1E1B18] tracking-tight">Content Creations & Copy Studio</h1>
              <p className="text-[#685D51] text-xs sm:text-sm mt-0.5">
                Centralized copywriting repository, multi-platform scripts, and editorial approval workflow.
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
            <span>Create New Copy / Script</span>
          </button>
        </div>
      </div>

      {/* KPI Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <StatsCard
          title="Total Creatives"
          value={filteredItems.length}
          subtitle="Copy & script assets"
          change="+16.2%"
          isPositive={true}
          icon={Sparkles}
          colorClass="from-[#FAF6EF] to-[#F5EFEB] text-[#8A6412] border-[#E5D8C1]"
        />
        <StatsCard
          title="Published & Live"
          value={filteredItems.filter(i => i.approvalStatus === 'Published').length}
          subtitle="Distributed across channels"
          change="+20.0%"
          isPositive={true}
          icon={CheckCircle2}
          colorClass="from-blue-50 to-indigo-50 text-blue-800 border-blue-200"
        />
        <StatsCard
          title="In Review Queue"
          value={filteredItems.filter(i => i.approvalStatus === 'Under Review').length}
          subtitle="Awaiting editorial sign-off"
          change="+5.4%"
          isPositive={true}
          icon={Clock}
          colorClass="from-purple-50 to-pink-50 text-purple-800 border-purple-200"
        />
        <StatsCard
          title="Approved Assets"
          value={filteredItems.filter(i => i.approvalStatus === 'Approved').length}
          subtitle="Ready for media broadcast"
          change="+12.5%"
          isPositive={true}
          icon={ThumbsUp}
          colorClass="from-emerald-50 to-teal-50 text-emerald-800 border-emerald-200"
        />
      </div>

      {/* Search & Filter Toolbar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-4 p-4 rounded-3xl bg-[#FFFFFF] border border-[#EAE2D2] shadow-cream-sm">
        <div className="relative w-full sm:w-80">
          <Search className="w-4 h-4 text-[#8E8276] absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search title, copy, creators..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl text-xs sm:text-sm text-[#1E1B18] placeholder-[#8E8276] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none transition-all shadow-inner"
          />
        </div>

        <div className="flex flex-wrap items-center gap-3 w-full sm:w-auto">
          <select
            value={typeFilter}
            onChange={(e) => setTypeFilter(e.target.value)}
            className="bg-[#FAF7F2] border border-[#EAE2D2] text-[#4D443B] text-xs sm:text-sm font-semibold rounded-xl px-3 py-2 focus:border-[#C59A27] focus:outline-none"
          >
            <option value="all">All Formats</option>
            <option value="Ad Banner Copy">Ad Banner Copy</option>
            <option value="Short Video Script (Reel/Short)">Video / Reel Script</option>
            <option value="Email Newsletter">Email Newsletter</option>
            <option value="Push Notification">Push Notification</option>
            <option value="Brochure / Flyer">Brochure / Flyer</option>
            <option value="Case Study">Case Study</option>
          </select>

          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="bg-[#FAF7F2] border border-[#EAE2D2] text-[#4D443B] text-xs sm:text-sm font-semibold rounded-xl px-3 py-2 focus:border-[#C59A27] focus:outline-none"
          >
            <option value="all">All Statuses ({items.length})</option>
            <option value="Draft">Draft</option>
            <option value="Under Review">Under Review</option>
            <option value="Revision Requested">Revision Requested</option>
            <option value="Approved">Approved</option>
            <option value="Published">Published</option>
          </select>
        </div>
      </div>

      {/* Creatives Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredItems.map((item) => {
          const sb = statusBadges[item.approvalStatus] || statusBadges.Draft;

          return (
            <div
              key={item.id}
              className="p-6 rounded-3xl bg-[#FFFFFF] border border-[#EAE2D2] hover:border-[#C59A27] transition-all flex flex-col justify-between space-y-4 shadow-cream-md group"
            >
              <div>
                {/* Header: Platform & Format */}
                <div className="flex items-center justify-between gap-2 mb-3">
                  <div className="flex items-center gap-2">
                    <span className="p-1.5 rounded-xl bg-[#FAF6EF] border border-[#E5D8C1]">
                      {typeIcons[item.contentType] || <Sparkles className="w-4 h-4 text-[#8A6412]" />}
                    </span>
                    <span className="text-xs font-bold text-[#1E1B18]">{item.platform}</span>
                  </div>
                  <span className={`text-[11px] font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-lg border ${sb.bg} ${sb.text} ${sb.border}`}>
                    {item.approvalStatus}
                  </span>
                </div>

                {/* Title */}
                <h3 className="font-serif text-base font-bold text-[#1E1B18] group-hover:text-[#9B7314] transition-colors leading-snug">
                  {item.title}
                </h3>
                
                {/* Target Persona */}
                <div className="p-2.5 rounded-xl bg-[#FAF6EF] border border-[#E5D8C1] mt-2 text-xs font-semibold text-[#8A6412]">
                  Target: {item.targetPersona}
                </div>

                {/* Copy Text Preview */}
                <p className="text-xs text-[#4D443B] mt-3 font-mono line-clamp-4 leading-relaxed bg-[#FAF7F2] p-3.5 rounded-2xl border border-[#EAE2D2] shadow-inner">
                  {item.copyText}
                </p>

                {/* Tags */}
                <div className="flex flex-wrap gap-1 mt-3">
                  {item.performanceTags.map((t, idx) => (
                    <span key={idx} className="text-[10px] px-2 py-0.5 rounded-lg bg-[#FAF7F2] text-[#8E8276] border border-[#EAE2D2] font-semibold">
                      #{t}
                    </span>
                  ))}
                </div>
              </div>

              {/* Footer Controls */}
              <div className="pt-3 border-t border-[#EAE2D2] flex items-center justify-between text-xs">
                <span className="text-[#8E8276] text-xs font-semibold">By {item.assignedCreator}</span>

                <div className="flex items-center gap-2">
                  <button
                    onClick={() => handleCopy(item.id, item.copyText)}
                    className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-[#FAF7F2] hover:bg-[#FFFFFF] border border-[#EAE2D2] text-[#4D443B] font-bold transition-all shadow-cream-sm"
                    title="Copy full text to clipboard"
                  >
                    {copiedId === item.id ? (
                      <>
                        <Check className="w-3.5 h-3.5 text-emerald-600" />
                        <span className="text-xs text-emerald-700">Copied</span>
                      </>
                    ) : (
                      <>
                        <Copy className="w-3.5 h-3.5 text-[#8E8276]" />
                        <span className="text-xs">Copy</span>
                      </>
                    )}
                  </button>

                  <button
                    onClick={() => setSelectedItem(item)}
                    className="p-2 rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] hover:bg-[#FFFFFF] text-[#4D443B] transition-colors"
                    title="View & Edit Details"
                  >
                    <ExternalLink className="w-3.5 h-3.5" />
                  </button>

                  <button
                    onClick={() => handleDelete(item.id)}
                    className="p-2 rounded-xl border border-rose-200 bg-rose-50 hover:bg-rose-100 text-rose-700 transition-colors"
                    title="Delete Creative"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Add Content Modal */}
      <Modal
        isOpen={isAddModalOpen}
        onClose={() => setIsAddModalOpen(false)}
        title="Create Copywriting / Script Asset"
        maxWidth="max-w-2xl"
      >
        <form onSubmit={handleCreateContent} className="space-y-4 text-left">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Creative Asset Title *
              </label>
              <input
                type="text"
                required
                value={formData.title}
                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                placeholder="e.g., Royal Wedding Heritage Ring Ad"
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>

            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Target Platform
              </label>
              <select
                value={formData.platform}
                onChange={(e) => setFormData({ ...formData, platform: e.target.value })}
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:outline-none"
              >
                <option value="Instagram">Instagram</option>
                <option value="Facebook">Facebook</option>
                <option value="LinkedIn">LinkedIn</option>
                <option value="Twitter">Twitter / X</option>
                <option value="YouTube">YouTube</option>
                <option value="Email">Email Newsletter</option>
                <option value="App Push">Mobile App Push</option>
              </select>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Format Type
              </label>
              <select
                value={formData.contentType}
                onChange={(e) => setFormData({ ...formData, contentType: e.target.value as ContentType })}
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:outline-none"
              >
                <option value="Ad Banner Copy">Ad Banner Copy</option>
                <option value="Short Video Script (Reel/Short)">Short Video Script (Reel/Short)</option>
                <option value="Email Newsletter">Email Newsletter</option>
                <option value="Push Notification">Push Notification</option>
                <option value="Brochure / Flyer">Brochure / Flyer</option>
                <option value="Case Study">Case Study</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Approval Status
              </label>
              <select
                value={formData.approvalStatus}
                onChange={(e) => setFormData({ ...formData, approvalStatus: e.target.value as ContentCreationItem['approvalStatus'] })}
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:outline-none"
              >
                <option value="Draft">Draft</option>
                <option value="Under Review">Under Review</option>
                <option value="Revision Requested">Revision Requested</option>
                <option value="Approved">Approved</option>
                <option value="Published">Published</option>
              </select>
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Target Persona
            </label>
            <input
              type="text"
              value={formData.targetPersona}
              onChange={(e) => setFormData({ ...formData, targetPersona: e.target.value })}
              placeholder="HNW Couples & Luxury Connoisseurs"
              className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
            />
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Full Copy Body / Script Lines *
            </label>
            <textarea
              rows={5}
              required
              value={formData.copyText}
              onChange={(e) => setFormData({ ...formData, copyText: e.target.value })}
              placeholder="Write the full persuasive copy, scene instructions, or email paragraphs..."
              className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none font-mono"
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Assigned Creator
              </label>
              <input
                type="text"
                value={formData.assignedCreator}
                onChange={(e) => setFormData({ ...formData, assignedCreator: e.target.value })}
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>

            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Performance Tags (comma separated)
              </label>
              <input
                type="text"
                value={formData.performanceTags}
                onChange={(e) => setFormData({ ...formData, performanceTags: e.target.value })}
                placeholder="Luxury, Diamond, Wedding"
                className="w-full bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl px-4 py-2.5 text-[#1E1B18] text-sm focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
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
              Save Creative Asset
            </button>
          </div>
        </form>
      </Modal>

      {/* Selected Item Detail / Status Changer Modal */}
      {selectedItem && (
        <Modal
          isOpen={true}
          onClose={() => setSelectedItem(null)}
          title={`Creative Asset: ${selectedItem.title}`}
          maxWidth="max-w-xl"
        >
          <div className="space-y-5 text-left">
            <div className="p-4 rounded-2xl bg-[#FAF7F2] border border-[#EAE2D2] space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold text-[#8A6412]">{selectedItem.platform} • {selectedItem.contentType}</span>
                <select
                  value={selectedItem.approvalStatus}
                  onChange={(e) => handleUpdateStatus(selectedItem.id, e.target.value as ContentCreationItem['approvalStatus'])}
                  className="bg-[#FFFFFF] border border-[#EAE2D2] rounded-xl px-3 py-1 text-xs font-bold text-[#1E1B18] focus:border-[#C59A27] focus:outline-none shadow-cream-sm"
                >
                  <option value="Draft">Draft</option>
                  <option value="Under Review">Under Review</option>
                  <option value="Revision Requested">Revision Requested</option>
                  <option value="Approved">Approved</option>
                  <option value="Published">Published</option>
                </select>
              </div>

              <div className="text-xs text-[#8E8276]">Target Persona: <span className="text-[#1E1B18] font-bold">{selectedItem.targetPersona}</span></div>
            </div>

            <div className="p-4 rounded-2xl bg-[#FFFFFF] border border-[#EAE2D2] space-y-2 shadow-cream-sm">
              <div className="text-xs font-extrabold text-[#8E8276] uppercase tracking-wider">Full Copy Text</div>
              <div className="text-[#1E1B18] text-xs sm:text-sm font-mono whitespace-pre-wrap leading-relaxed bg-[#FAF7F2] p-3.5 rounded-xl border border-[#EAE2D2]">
                {selectedItem.copyText}
              </div>
            </div>

            <div className="flex items-center justify-between text-xs text-[#8E8276] pt-3 border-t border-[#EAE2D2]">
              <div>Author: <span className="text-[#1E1B18] font-bold">{selectedItem.assignedCreator}</span></div>
              <button
                onClick={() => {
                  navigator.clipboard.writeText(selectedItem.copyText);
                  alert('Full copy text copied to clipboard!');
                }}
                className="px-4 py-2 rounded-xl bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] text-[#1E1B18] font-bold text-xs shadow-cream-md hover:scale-[1.02] transition-all"
              >
                Copy to Clipboard
              </button>
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
};

