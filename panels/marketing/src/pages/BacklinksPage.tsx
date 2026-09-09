import React, { useState, useEffect } from 'react';
import { marketingApi } from '../api/marketingApi';
import { BacklinkItem } from '../types/marketing';
import { Modal } from '../components/common/Modal';
import { StatsCard } from '../components/common/StatsCard';
import {
  Link2,
  Plus,
  Trash2,
  Edit3,
  ExternalLink,
  ShieldAlert,
  CheckCircle2,
  Clock,
  Download,
  Search,
  Filter,
} from 'lucide-react';

export const BacklinksPage: React.FC = () => {
  const [backlinks, setBacklinks] = useState<BacklinkItem[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState('All');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<BacklinkItem | null>(null);

  // Form states
  const [formTargetUrl, setFormTargetUrl] = useState('');
  const [formReferringDomain, setFormReferringDomain] = useState('');
  const [formAnchorText, setFormAnchorText] = useState('');
  const [formLinkType, setFormLinkType] = useState<any>('DoFollow');
  const [formDr, setFormDr] = useState(70);
  const [formSpamScore, setFormSpamScore] = useState(1);
  const [formLiveUrl, setFormLiveUrl] = useState('');
  const [formCost, setFormCost] = useState(0);
  const [formContact, setFormContact] = useState('');
  const [formStatus, setFormStatus] = useState<any>('Live');
  const [formNotes, setFormNotes] = useState('');

  const loadData = async () => {
    const list = await marketingApi.getBacklinks();
    setBacklinks(list);
  };

  useEffect(() => {
    loadData();
  }, []);

  const openCreateModal = () => {
    setEditingItem(null);
    setFormTargetUrl('https://am5royal.com/services/home-cleaning');
    setFormReferringDomain('timesofindia.indiatimes.com');
    setFormAnchorText('certified home cleaning partners');
    setFormLinkType('DoFollow');
    setFormDr(86);
    setFormSpamScore(1);
    setFormLiveUrl('https://timesofindia.indiatimes.com/lifestyle/home-decor/urban-services-guide-2026');
    setFormCost(15000);
    setFormContact('editorial.partners@timesgroup.com');
    setFormStatus('Live');
    setFormNotes('Featured in Tier 1 Metro Lifestyle feature.');
    setIsModalOpen(true);
  };

  const handleEdit = (item: BacklinkItem) => {
    setEditingItem(item);
    setFormTargetUrl(item.targetUrl);
    setFormReferringDomain(item.referringDomain);
    setFormAnchorText(item.anchorText);
    setFormLinkType(item.linkType);
    setFormDr(item.domainRating);
    setFormSpamScore(item.spamScore);
    setFormLiveUrl(item.liveVerifiedUrl);
    setFormCost(item.costInr);
    setFormContact(item.outreachContact);
    setFormStatus(item.status);
    setFormNotes(item.notes || '');
    setIsModalOpen(true);
  };

  const handleFormSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await marketingApi.saveBacklink({
      id: editingItem?.id,
      targetUrl: formTargetUrl,
      referringDomain: formReferringDomain,
      anchorText: formAnchorText,
      linkType: formLinkType,
      domainRating: Number(formDr),
      spamScore: Number(formSpamScore),
      liveVerifiedUrl: formLiveUrl,
      costInr: Number(formCost),
      outreachContact: formContact,
      status: formStatus,
      notes: formNotes,
      acquisitionDate: editingItem?.acquisitionDate || new Date().toISOString().split('T')[0],
    });
    setIsModalOpen(false);
    loadData();
  };

  const handleDelete = async (id: string) => {
    if (confirm('Are you sure you want to remove this backlink record?')) {
      await marketingApi.deleteBacklink(id);
      loadData();
    }
  };

  const filtered = backlinks.filter((item) => {
    const matchesSearch =
      item.referringDomain.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.anchorText.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.targetUrl.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesStatus = statusFilter === 'All' || item.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const totalLinks = filtered.length;
  const doFollowCount = filtered.filter((b) => b.linkType === 'DoFollow').length;
  const avgDr = totalLinks > 0 ? Math.round(filtered.reduce((s, b) => s + b.domainRating, 0) / totalLinks) : 0;
  const totalSpend = filtered.reduce((s, b) => s + b.costInr, 0);

  return (
    <div className="space-y-8 text-left">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-[#EAE2D2] pb-6">
        <div>
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-2xl bg-[#FAF6EF] border border-[#E5D8C1] text-[#9B7314] shadow-cream-sm">
              <Link2 className="h-6 w-6" />
            </div>
            <div>
              <h1 className="font-serif text-2xl font-bold text-[#1E1B18] tracking-tight">
                Backlinks & Outreach CRM
              </h1>
              <p className="text-xs sm:text-sm text-[#685D51] mt-0.5">
                Track referring domain rating, anchor texts, spam score, live verified URLs, and outreach acquisitions.
              </p>
            </div>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          <button
            onClick={() => marketingApi.exportToCsv(filtered, 'am5_backlinks')}
            className="flex items-center gap-2 px-4 py-2 bg-[#FFFFFF] hover:bg-[#FAF7F2] border border-[#EAE2D2] text-[#4D443B] text-xs sm:text-sm font-bold rounded-xl transition-all shadow-cream-sm"
          >
            <Download className="w-4 h-4 text-[#8E8276]" />
            <span>Export CSV</span>
          </button>
          <button
            onClick={openCreateModal}
            className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] px-4 py-2 text-xs sm:text-sm font-bold text-[#1E1B18] shadow-cream-md hover:scale-[1.02] transition-all"
          >
            <Plus className="w-4 h-4" />
            <span>Add Backlink</span>
          </button>
        </div>
      </div>

      {/* Metrics Row */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <StatsCard
          title="Total Backlinks"
          value={totalLinks}
          icon={Link2}
          subtitle="Filtered directory count"
          change="+12.4%"
          isPositive={true}
          colorClass="from-[#FAF6EF] to-[#F5EFEB] text-[#8A6412] border-[#E5D8C1]"
        />
        <StatsCard
          title="DoFollow Quality Ratio"
          value={`${totalLinks > 0 ? Math.round((doFollowCount / totalLinks) * 100) : 0}%`}
          icon={CheckCircle2}
          subtitle={`${doFollowCount} high-authority links`}
          change="+8.2%"
          isPositive={true}
          colorClass="from-emerald-50 to-teal-50 text-emerald-800 border-emerald-200"
        />
        <StatsCard
          title="Average Domain Rating"
          value={`DR ${avgDr}`}
          icon={ShieldAlert}
          subtitle="Tier 1 authority profile"
          change="+4 pts"
          isPositive={true}
          colorClass="from-blue-50 to-indigo-50 text-blue-800 border-blue-200"
        />
        <StatsCard
          title="Link Acquisition Spend"
          value={`₹${(totalSpend / 1000).toFixed(0)}k`}
          icon={Clock}
          subtitle="PR & sponsored outreach"
          change="+10.5%"
          isPositive={true}
          colorClass="from-purple-50 to-pink-50 text-purple-800 border-purple-200"
        />
      </div>

      {/* Filters & Search */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-4 p-4 rounded-3xl bg-[#FFFFFF] border border-[#EAE2D2] shadow-cream-sm">
        <div className="relative w-full sm:w-80">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-[#8E8276] w-4 h-4" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search domain, anchor text, URL..."
            className="w-full pl-10 pr-4 py-2 bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl text-xs sm:text-sm text-[#1E1B18] placeholder-[#8E8276] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none transition-all shadow-inner"
          />
        </div>

        <div className="flex items-center gap-2 overflow-x-auto w-full sm:w-auto">
          {['All', 'Live', 'In Outreach', 'Lost'].map((st) => (
            <button
              key={st}
              onClick={() => setStatusFilter(st)}
              className={`rounded-xl px-3.5 py-2 text-xs font-bold transition-all ${
                statusFilter === st
                  ? 'bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] text-[#1E1B18] shadow-cream-sm'
                  : 'bg-[#FAF7F2] border border-[#EAE2D2] text-[#685D51] hover:text-[#1E1B18] hover:bg-[#FFFFFF]'
              }`}
            >
              {st}
            </button>
          ))}
        </div>
      </div>

      {/* Data Table */}
      <div className="rounded-3xl border border-[#EAE2D2] bg-[#FFFFFF] shadow-cream-md overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-[#4D443B]">
            <thead className="border-b border-[#EAE2D2] bg-[#FAF6EF] font-bold uppercase tracking-wider text-[#685D51]">
              <tr>
                <th className="px-6 py-4">Referring Domain</th>
                <th className="px-6 py-4">Anchor Text</th>
                <th className="px-6 py-4">Target Destination</th>
                <th className="px-6 py-4">DR / Spam</th>
                <th className="px-6 py-4">Type</th>
                <th className="px-6 py-4">Cost</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#EAE2D2]/80">
              {filtered.map((item) => (
                <tr key={item.id} className="hover:bg-[#FAF7F2] transition-colors">
                  <td className="px-6 py-4 font-bold text-[#1E1B18]">
                    <div className="flex items-center gap-2">
                      <span>{item.referringDomain}</span>
                      {item.liveVerifiedUrl && (
                        <a
                          href={item.liveVerifiedUrl}
                          target="_blank"
                          rel="noreferrer"
                          className="text-[#9B7314] hover:text-[#C59A27]"
                        >
                          <ExternalLink className="w-3.5 h-3.5" />
                        </a>
                      )}
                    </div>
                    <span className="text-[10px] text-[#8E8276] font-normal">{item.acquisitionDate}</span>
                  </td>

                  <td className="px-6 py-4 font-medium text-[#1E1B18]">
                    <span className="rounded-lg bg-[#FAF6EF] px-2.5 py-1 text-xs text-[#8A6412] border border-[#E5D8C1] font-semibold">
                      "{item.anchorText}"
                    </span>
                  </td>

                  <td className="px-6 py-4 truncate max-w-[200px] text-[#8E8276] font-mono text-[11px]">
                    {item.targetUrl}
                  </td>

                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2 font-bold">
                      <span className="text-emerald-700">DR {item.domainRating}</span>
                      <span className="text-[10px] text-[#8E8276]">| Spam {item.spamScore}%</span>
                    </div>
                  </td>

                  <td className="px-6 py-4">
                    <span
                      className={`rounded-lg px-2.5 py-1 text-[11px] font-bold border ${
                        item.linkType === 'DoFollow'
                          ? 'bg-emerald-50 text-emerald-800 border-emerald-200'
                          : 'bg-[#FAF7F2] text-[#685D51] border-[#EAE2D2]'
                      }`}
                    >
                      {item.linkType}
                    </span>
                  </td>

                  <td className="px-6 py-4 font-bold text-[#1E1B18]">
                    {item.costInr > 0 ? `₹${item.costInr.toLocaleString()}` : 'Free Earned'}
                  </td>

                  <td className="px-6 py-4">
                    <span
                      className={`rounded-full px-3 py-1 text-[11px] font-bold border ${
                        item.status === 'Live'
                          ? 'bg-emerald-50 text-emerald-800 border-emerald-200'
                          : item.status === 'In Outreach'
                          ? 'bg-blue-50 text-blue-800 border-blue-200'
                          : 'bg-rose-50 text-rose-800 border-rose-200'
                      }`}
                    >
                      {item.status}
                    </span>
                  </td>

                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-1.5">
                      <button
                        onClick={() => handleEdit(item)}
                        className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] hover:bg-[#FFFFFF] p-2 text-[#4D443B] transition-colors"
                        title="Edit Backlink"
                      >
                        <Edit3 className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => handleDelete(item.id)}
                        className="rounded-xl border border-rose-200 bg-rose-50 hover:bg-rose-100 p-2 text-rose-700 transition-colors"
                        title="Delete Backlink"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Create / Edit Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingItem ? 'Edit Backlink Record' : 'Record New Acquired Backlink'}
        subtitle="Fill all required domain metrics, target anchors, and live verification URL"
      >
        <form onSubmit={handleFormSubmit} className="space-y-4 text-left">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Referring Domain
              </label>
              <input
                type="text"
                required
                value={formReferringDomain}
                onChange={(e) => setFormReferringDomain(e.target.value)}
                placeholder="e.g. yourstory.com"
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Anchor Text
              </label>
              <input
                type="text"
                required
                value={formAnchorText}
                onChange={(e) => setFormAnchorText(e.target.value)}
                placeholder="e.g. luxury home cleaning"
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Target AM5 ROYAL Landing URL
            </label>
            <input
              type="url"
              required
              value={formTargetUrl}
              onChange={(e) => setFormTargetUrl(e.target.value)}
              className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
            />
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Live Verified Article URL
            </label>
            <input
              type="url"
              value={formLiveUrl}
              onChange={(e) => setFormLiveUrl(e.target.value)}
              className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
            />
          </div>

          <div className="grid grid-cols-3 gap-3">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Link Type
              </label>
              <select
                value={formLinkType}
                onChange={(e) => setFormLinkType(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              >
                <option value="DoFollow">DoFollow</option>
                <option value="NoFollow">NoFollow</option>
                <option value="UGC">UGC</option>
                <option value="Sponsored">Sponsored</option>
              </select>
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Domain Rating (0-100)
              </label>
              <input
                type="number"
                value={formDr}
                onChange={(e) => setFormDr(Number(e.target.value))}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Spam Score %
              </label>
              <input
                type="number"
                value={formSpamScore}
                onChange={(e) => setFormSpamScore(Number(e.target.value))}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Cost (INR)
              </label>
              <input
                type="number"
                value={formCost}
                onChange={(e) => setFormCost(Number(e.target.value))}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Outreach Status
              </label>
              <select
                value={formStatus}
                onChange={(e) => setFormStatus(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              >
                <option value="Live">Live</option>
                <option value="In Outreach">In Outreach</option>
                <option value="Lost">Lost</option>
                <option value="Pending Verification">Pending Verification</option>
              </select>
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Outreach Contact & Notes
            </label>
            <input
              type="text"
              value={formNotes}
              onChange={(e) => setFormNotes(e.target.value)}
              placeholder="e.g. Editorial partner contact details or article topic"
              className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
            />
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-[#EAE2D2]">
            <button
              type="button"
              onClick={() => setIsModalOpen(false)}
              className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-4 py-2 text-xs font-bold text-[#685D51] hover:bg-[#FFFFFF] transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="rounded-xl bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] px-5 py-2 text-xs font-bold text-[#1E1B18] shadow-cream-md hover:scale-[1.02]"
            >
              {editingItem ? 'Save Changes' : 'Record Backlink'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
};

