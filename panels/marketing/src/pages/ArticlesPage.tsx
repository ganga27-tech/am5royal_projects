import React, { useState, useEffect } from 'react';
import { marketingApi } from '../api/marketingApi';
import { ArticleItem } from '../types/marketing';
import { Modal } from '../components/common/Modal';
import { StatsCard } from '../components/common/StatsCard';
import {
  Newspaper,
  Plus,
  Trash2,
  Edit3,
  ExternalLink,
  Users,
  Search,
  CheckCircle2,
  Download,
  Share2,
} from 'lucide-react';

export const ArticlesPage: React.FC = () => {
  const [articles, setArticles] = useState<ArticleItem[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState('All');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<ArticleItem | null>(null);

  // Form states
  const [formTitle, setFormTitle] = useState('');
  const [formPublication, setFormPublication] = useState('');
  const [formType, setFormType] = useState<any>('Press Release');
  const [formAuthor, setFormAuthor] = useState('Editorial Tech Desk');
  const [formAudience, setFormAudience] = useState('Urban Consumers & Industry Leaders');
  const [formLiveUrl, setFormLiveUrl] = useState('');
  const [formKeywords, setFormKeywords] = useState('');
  const [formBacklink, setFormBacklink] = useState(true);
  const [formSnippet, setFormSnippet] = useState('');
  const [formStatus, setFormStatus] = useState<any>('Published');
  const [formTraffic, setFormTraffic] = useState(1200);

  const loadData = async () => {
    const list = await marketingApi.getArticles();
    setArticles(list);
  };

  useEffect(() => {
    loadData();
  }, []);

  const openCreateModal = () => {
    setEditingItem(null);
    setFormTitle('AM5 ROYAL Announces Landmark 50,000 Verified Vendor Onboarding Milestone');
    setFormPublication('Business Standard / PR Newswire');
    setFormType('Press Release');
    setFormAuthor('Corporate Communications');
    setFormAudience('Business Leaders, Service Contractors & Metro Consumers');
    setFormLiveUrl('https://business-standard.com/companies/news/am5-royal-gig-empowerment-50k-partners');
    setFormKeywords('AM5 ROYAL MSKGRC, gig economy, on-demand home services');
    setFormBacklink(true);
    setFormSnippet('How MSKGRC enabled instant daily UPI payouts to create India\'s most trusted on-demand home maintenance marketplace.');
    setFormStatus('Published');
    setFormTraffic(2450);
    setIsModalOpen(true);
  };

  const handleEdit = (item: ArticleItem) => {
    setEditingItem(item);
    setFormTitle(item.title);
    setFormPublication(item.publicationName);
    setFormType(item.publicationType);
    setFormAuthor(item.authorByline);
    setFormAudience(item.targetAudience);
    setFormLiveUrl(item.liveArticleUrl);
    setFormKeywords(item.targetedKeywords.join(', '));
    setFormBacklink(item.backlinkIncluded);
    setFormSnippet(item.contentSnippet);
    setFormStatus(item.status);
    setFormTraffic(item.referralTraffic);
    setIsModalOpen(true);
  };

  const handleFormSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await marketingApi.saveArticle({
      id: editingItem?.id,
      title: formTitle,
      publicationName: formPublication,
      publicationType: formType,
      authorByline: formAuthor,
      targetAudience: formAudience,
      canonicalUrl: formLiveUrl,
      liveArticleUrl: formLiveUrl,
      targetedKeywords: formKeywords.split(',').map((s) => s.trim()).filter(Boolean),
      backlinkIncluded: formBacklink,
      contentSnippet: formSnippet,
      status: formStatus,
      referralTraffic: Number(formTraffic),
      publicationDate: editingItem?.publicationDate || new Date().toISOString().split('T')[0],
    });
    setIsModalOpen(false);
    loadData();
  };

  const handleDelete = async (id: string) => {
    if (confirm('Delete this article record?')) {
      await marketingApi.deleteArticle(id);
      loadData();
    }
  };

  const filtered = articles.filter((a) => {
    const matchesSearch =
      a.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      a.publicationName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      a.targetAudience.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus = statusFilter === 'All' || a.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const totalArticles = filtered.length;
  const totalTraffic = filtered.reduce((sum, a) => sum + a.referralTraffic, 0);

  return (
    <div className="space-y-8 text-left">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-[#EAE2D2] pb-6">
        <div>
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-2xl bg-[#FAF6EF] border border-[#E5D8C1] text-[#9B7314] shadow-cream-sm">
              <Newspaper className="h-6 w-6" />
            </div>
            <div>
              <h1 className="font-serif text-2xl font-bold text-[#1E1B18] tracking-tight">
                Articles & PR Media Tracker
              </h1>
              <p className="text-xs sm:text-sm text-[#685D51] mt-0.5">
                Track external press releases, guest contributions, Medium features, and referral visitor acquisition.
              </p>
            </div>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          <button
            onClick={() => marketingApi.exportToCsv(filtered, 'am5_pr_articles')}
            className="flex items-center gap-2 px-4 py-2 bg-[#FFFFFF] hover:bg-[#FAF7F2] border border-[#EAE2D2] text-[#4D443B] text-xs sm:text-sm font-bold rounded-xl transition-all shadow-cream-sm"
          >
            <Download className="w-4 h-4 text-[#8E8276]" />
            <span>Export CSV</span>
          </button>
          <button
            onClick={openCreateModal}
            className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] px-4 py-2.5 text-xs sm:text-sm font-bold text-[#1E1B18] shadow-cream-md hover:scale-[1.02] transition-all"
          >
            <Plus className="w-4 h-4" />
            <span>Log PR Article</span>
          </button>
        </div>
      </div>

      {/* Metrics Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <StatsCard
          title="Total Published PR & Articles"
          value={totalArticles}
          icon={Newspaper}
          subtitle="Media features directory"
          change="+14.2%"
          isPositive={true}
          colorClass="from-[#FAF6EF] to-[#F5EFEB] text-[#8A6412] border-[#E5D8C1]"
        />
        <StatsCard
          title="Referral Visitors"
          value={`${totalTraffic.toLocaleString()}`}
          icon={Users}
          subtitle="Direct high-intent clicks"
          change="+22.8%"
          isPositive={true}
          colorClass="from-emerald-50 to-teal-50 text-emerald-800 border-emerald-200"
        />
        <StatsCard
          title="Active Backlinks"
          value={`${filtered.filter((a) => a.backlinkIncluded).length}`}
          icon={CheckCircle2}
          subtitle="High authority anchor links"
          change="+6.5%"
          isPositive={true}
          colorClass="from-blue-50 to-indigo-50 text-blue-800 border-blue-200"
        />
        <StatsCard
          title="Press Reach Index"
          value="48.5k"
          icon={Share2}
          subtitle="Estimated media views"
          change="+19.0%"
          isPositive={true}
          colorClass="from-purple-50 to-pink-50 text-purple-800 border-purple-200"
        />
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-4 p-4 rounded-3xl bg-[#FFFFFF] border border-[#EAE2D2] shadow-cream-sm">
        <div className="relative w-full sm:w-80">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-[#8E8276] w-4 h-4" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search article title, publication, audience..."
            className="w-full pl-10 pr-4 py-2 bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl text-xs sm:text-sm text-[#1E1B18] placeholder-[#8E8276] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none transition-all shadow-inner"
          />
        </div>

        <div className="flex items-center gap-2 overflow-x-auto w-full sm:w-auto">
          {['All', 'Published', 'Approved', 'Pitching'].map((st) => (
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

      {/* Article List Cards */}
      <div className="grid grid-cols-1 gap-5">
        {filtered.map((item) => (
          <div
            key={item.id}
            className="glass-card rounded-3xl p-6 sm:p-7 bg-[#FFFFFF] border border-[#EAE2D2] shadow-cream-md flex flex-col md:flex-row items-start justify-between gap-6 hover:border-[#C59A27] transition-all"
          >
            <div className="flex-1 space-y-2.5">
              <div className="flex items-center gap-2">
                <span className="rounded-lg bg-[#FAF6EF] px-2.5 py-1 text-xs font-bold text-[#8A6412] border border-[#E5D8C1]">
                  {item.publicationType}
                </span>
                <span className="text-xs font-bold text-[#1E1B18]">• {item.publicationName}</span>
                <span className="text-xs text-[#8E8276]">| {item.publicationDate}</span>
              </div>

              <a
                href={item.liveArticleUrl}
                target="_blank"
                rel="noreferrer"
                className="font-serif text-base sm:text-lg font-bold text-[#1E1B18] hover:text-[#9B7314] transition-colors flex items-center gap-2"
              >
                <span>{item.title}</span>
                <ExternalLink className="w-4 h-4 text-[#8E8276] flex-shrink-0" />
              </a>

              <p className="text-xs text-[#685D51] line-clamp-2 leading-relaxed bg-[#FAF7F2] p-3.5 rounded-2xl border border-[#EAE2D2] shadow-inner">
                "{item.contentSnippet}"
              </p>

              <div className="flex flex-wrap items-center gap-2 pt-1 text-xs text-[#8E8276]">
                <span>Byline: <strong className="text-[#1E1B18]">{item.authorByline}</strong></span>
                <span>•</span>
                <span>Audience: <strong className="text-[#1E1B18]">{item.targetAudience}</strong></span>
                {item.backlinkIncluded && (
                  <span className="rounded-lg bg-emerald-50 px-2.5 py-0.5 text-xs font-bold text-emerald-800 border border-emerald-200">
                    Backlink Included
                  </span>
                )}
              </div>
            </div>

            {/* Metrics & Actions */}
            <div className="flex flex-row md:flex-col items-center md:items-end justify-between w-full md:w-auto gap-4 border-t md:border-t-0 md:border-l border-[#EAE2D2] pt-3 md:pt-0 md:pl-6">
              <div className="text-left md:text-right">
                <p className="text-[10px] font-extrabold uppercase tracking-wider text-[#8E8276]">
                  Referral Traffic
                </p>
                <p className="font-outfit text-xl font-black text-[#0F4C81] mt-0.5">
                  {item.referralTraffic.toLocaleString()} <span className="text-xs text-[#8E8276] font-normal">clicks</span>
                </p>
              </div>

              <div className="flex items-center gap-1.5">
                <button
                  onClick={() => handleEdit(item)}
                  className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] hover:bg-[#FFFFFF] p-2 text-[#4D443B] transition-colors"
                  title="Edit Article"
                >
                  <Edit3 className="w-4 h-4" />
                </button>
                <button
                  onClick={() => handleDelete(item.id)}
                  className="rounded-xl border border-rose-200 bg-rose-50 hover:bg-rose-100 p-2 text-rose-700 transition-colors"
                  title="Delete Article"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingItem ? 'Edit Media Publication' : 'Log New PR / Article Publication'}
        subtitle="Fill publication name, media type, live canonical link, and traffic generated"
      >
        <form onSubmit={handleFormSubmit} className="space-y-4 text-left">
          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Article / Headline Title
            </label>
            <input
              type="text"
              required
              value={formTitle}
              onChange={(e) => setFormTitle(e.target.value)}
              className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Publication Portal Name
              </label>
              <input
                type="text"
                required
                value={formPublication}
                onChange={(e) => setFormPublication(e.target.value)}
                placeholder="e.g. Economic Times, Medium, Forbes"
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Publication Type
              </label>
              <select
                value={formType}
                onChange={(e) => setFormType(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              >
                <option value="Press Release">Press Release</option>
                <option value="Guest Post">Guest Post</option>
                <option value="Medium">Medium</option>
                <option value="News Portal">News Portal</option>
                <option value="Industry Journal">Industry Journal</option>
              </select>
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Live Article Link URL
            </label>
            <input
              type="url"
              required
              value={formLiveUrl}
              onChange={(e) => setFormLiveUrl(e.target.value)}
              className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Author / Byline
              </label>
              <input
                type="text"
                value={formAuthor}
                onChange={(e) => setFormAuthor(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Target Audience
              </label>
              <input
                type="text"
                value={formAudience}
                onChange={(e) => setFormAudience(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Key Excerpt / Story Snippet
            </label>
            <textarea
              rows={3}
              value={formSnippet}
              onChange={(e) => setFormSnippet(e.target.value)}
              className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none leading-relaxed"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Referral Clicks Generated
              </label>
              <input
                type="number"
                value={formTraffic}
                onChange={(e) => setFormTraffic(Number(e.target.value))}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Status
              </label>
              <select
                value={formStatus}
                onChange={(e) => setFormStatus(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              >
                <option value="Published">Published</option>
                <option value="Approved">Approved</option>
                <option value="Drafting">Drafting</option>
                <option value="Pitching">Pitching</option>
              </select>
            </div>
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
              {editingItem ? 'Save Article Changes' : 'Log Article'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
};

