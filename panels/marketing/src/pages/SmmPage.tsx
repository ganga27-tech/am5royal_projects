import React, { useState, useEffect } from 'react';
import { marketingApi } from '../api/marketingApi';
import { SmmPostItem, SmmPlatform } from '../types/marketing';
import { Modal } from '../components/common/Modal';
import { StatsCard } from '../components/common/StatsCard';
import {
  Share2,
  Plus,
  Trash2,
  Edit3,
  Instagram,
  Facebook,
  Linkedin,
  Twitter,
  Heart,
  MessageCircle,
  Bookmark,
  Send,
  Eye,
  TrendingUp,
  DollarSign,
  Download,
  Search,
  Filter,
} from 'lucide-react';

export const SmmPage: React.FC = () => {
  const [posts, setPosts] = useState<SmmPostItem[]>([]);
  const [selectedPlatform, setSelectedPlatform] = useState<string>('All');
  const [selectedPostType, setSelectedPostType] = useState<string>('All');
  const [searchQuery, setSearchQuery] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<SmmPostItem | null>(null);

  // Form states
  const [formPlatform, setFormPlatform] = useState<SmmPlatform>('Instagram');
  const [formPostType, setFormPostType] = useState<any>('Reel');
  const [formTitle, setFormTitle] = useState('');
  const [formCaption, setFormCaption] = useState('');
  const [formHashtags, setFormHashtags] = useState('');
  const [formMediaUrl, setFormMediaUrl] = useState('');
  const [formAudience, setFormAudience] = useState('');
  const [formIsPaid, setFormIsPaid] = useState(true);
  const [formBudget, setFormBudget] = useState(10000);
  const [formImpressions, setFormImpressions] = useState(50000);
  const [formReach, setFormReach] = useState(38000);
  const [formLikes, setFormLikes] = useState(2400);
  const [formComments, setFormComments] = useState(180);
  const [formSaves, setFormSaves] = useState(450);
  const [formShares, setFormShares] = useState(620);
  const [formClicks, setFormClicks] = useState(1200);
  const [formConversions, setFormConversions] = useState(85);
  const [formStatus, setFormStatus] = useState<any>('Active Live');

  const loadData = async () => {
    const list = await marketingApi.getSmmPosts();
    setPosts(list);
  };

  useEffect(() => {
    loadData();
  }, []);

  const openCreateModal = () => {
    setEditingItem(null);
    setFormPlatform('Instagram');
    setFormPostType('Reel');
    setFormTitle('Satisfying Kitchen Deep Clean Transformation');
    setFormCaption('Watch our certified partner turn a grease-stained kitchen into a pristine 5-star space in under 1 hour! ✨👑 Book your festive deep clean today with code ROYAL100.');
    setFormHashtags('#AM5Royal, #HomeCleaning, #SatisfyingReels, #MumbaiLiving, #CleanTok');
    setFormMediaUrl('https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800');
    setFormAudience('Metro Homeowners, Families aged 25-50 (Mumbai, Bengaluru)');
    setFormIsPaid(true);
    setFormBudget(15000);
    setFormImpressions(85000);
    setFormReach(64000);
    setFormLikes(4800);
    setFormComments(320);
    setFormSaves(950);
    setFormShares(1420);
    setFormClicks(2100);
    setFormConversions(124);
    setFormStatus('Active Live');
    setIsModalOpen(true);
  };

  const handleEdit = (item: SmmPostItem) => {
    setEditingItem(item);
    setFormPlatform(item.platform);
    setFormPostType(item.postType);
    setFormTitle(item.title);
    setFormCaption(item.caption);
    setFormHashtags(item.hashtags.join(', '));
    setFormMediaUrl(item.mediaAssetUrl);
    setFormAudience(item.targetAudience);
    setFormIsPaid(item.isPaidAd);
    setFormBudget(item.adBudgetInt);
    setFormImpressions(item.impressions);
    setFormReach(item.reach);
    setFormLikes(item.likes);
    setFormComments(item.comments);
    setFormSaves(item.saves);
    setFormShares(item.shares);
    setFormClicks(item.linkClicks);
    setFormConversions(item.conversions);
    setFormStatus(item.status);
    setIsModalOpen(true);
  };

  const handleFormSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await marketingApi.saveSmmPost({
      id: editingItem?.id,
      platform: formPlatform,
      postType: formPostType,
      title: formTitle,
      caption: formCaption,
      hashtags: formHashtags.split(',').map((h) => (h.trim().startsWith('#') ? h.trim() : `#${h.trim()}`)).filter(Boolean),
      mediaAssetUrl: formMediaUrl,
      targetAudience: formAudience,
      isPaidAd: formIsPaid,
      adBudgetInt: Number(formBudget),
      spendInr: formIsPaid ? Number(formBudget) : 0,
      impressions: Number(formImpressions),
      reach: Number(formReach),
      likes: Number(formLikes),
      comments: Number(formComments),
      saves: Number(formSaves),
      shares: Number(formShares),
      linkClicks: Number(formClicks),
      conversions: Number(formConversions),
      status: formStatus,
      scheduledTime: editingItem?.scheduledTime || new Date().toISOString(),
    });
    setIsModalOpen(false);
    loadData();
  };

  const handleDelete = async (id: string) => {
    if (confirm('Delete this SMM campaign record?')) {
      await marketingApi.deleteSmmPost(id);
      loadData();
    }
  };

  const filtered = posts.filter((p) => {
    const matchesPlatform = selectedPlatform === 'All' || p.platform.toLowerCase() === selectedPlatform.toLowerCase();
    const matchesPostType = selectedPostType === 'All' || p.postType.toLowerCase() === selectedPostType.toLowerCase();
    const matchesSearch =
      p.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.caption.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.targetAudience.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesPlatform && matchesPostType && matchesSearch;
  });

  const totalReach = filtered.reduce((sum, p) => sum + p.reach, 0);
  const totalEngagements = filtered.reduce((sum, p) => sum + p.likes + p.comments + p.shares + p.saves, 0);
  const totalSpend = filtered.reduce((sum, p) => sum + p.spendInr, 0);
  const totalConversions = filtered.reduce((sum, p) => sum + p.conversions, 0);

  const getPlatformIcon = (platform: SmmPlatform) => {
    switch (platform) {
      case 'Instagram':
        return <Instagram className="w-5 h-5 text-pink-600" />;
      case 'Facebook':
        return <Facebook className="w-5 h-5 text-blue-600" />;
      case 'LinkedIn':
        return <Linkedin className="w-5 h-5 text-sky-700" />;
      case 'Twitter':
        return <Twitter className="w-5 h-5 text-sky-500" />;
    }
  };

  return (
    <div className="space-y-8 text-left">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-[#EAE2D2] pb-6">
        <div>
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-2xl bg-[#FAF6EF] border border-[#E5D8C1] text-[#9B7314] shadow-cream-sm">
              <Share2 className="h-6 w-6" />
            </div>
            <div>
              <h1 className="font-serif text-2xl font-bold text-[#1E1B18] tracking-tight">
                Social Media Marketing (SMM) Suite
              </h1>
              <p className="text-xs sm:text-sm text-[#685D51] mt-0.5">
                Omnichannel ad campaigns across Instagram, Facebook, LinkedIn & Twitter with engagement and conversion tracking.
              </p>
            </div>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          <button
            onClick={() => marketingApi.exportToCsv(filtered, 'am5_smm_campaigns')}
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
            <span>Create SMM Campaign</span>
          </button>
        </div>
      </div>

      {/* Metrics Row */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <StatsCard
          title="Total Social Reach"
          value={`${(totalReach / 1000).toFixed(1)}k`}
          icon={Eye}
          subtitle="Screen views & impressions"
          change="+18.2%"
          isPositive={true}
          colorClass="from-[#FAF6EF] to-[#F5EFEB] text-[#8A6412] border-[#E5D8C1]"
        />
        <StatsCard
          title="Total Engagements"
          value={totalEngagements.toLocaleString()}
          icon={Heart}
          subtitle="Likes, shares, saves"
          change="+24.5%"
          isPositive={true}
          colorClass="from-pink-50 to-rose-50 text-pink-800 border-pink-200"
        />
        <StatsCard
          title="Direct Ad Spend"
          value={`₹${(totalSpend / 1000).toFixed(0)}k`}
          icon={DollarSign}
          subtitle="Paid boost budget"
          change="+15.0%"
          isPositive={true}
          colorClass="from-blue-50 to-indigo-50 text-blue-800 border-blue-200"
        />
        <StatsCard
          title="Attributed Conversions"
          value={`${totalConversions} Leads`}
          icon={TrendingUp}
          subtitle="Direct SMM bookings"
          change="+31.0%"
          isPositive={true}
          colorClass="from-emerald-50 to-teal-50 text-emerald-800 border-emerald-200"
        />
      </div>

      {/* Platform Selector Tabs & Filter Bar */}
      <div className="flex flex-col md:flex-row items-center justify-between gap-4 p-4 rounded-3xl bg-[#FFFFFF] border border-[#EAE2D2] shadow-cream-sm">
        {/* Platform Buttons */}
        <div className="flex items-center gap-2 overflow-x-auto w-full md:w-auto pb-1 md:pb-0">
          {[
            { key: 'All', label: 'All Channels' },
            { key: 'Instagram', label: 'Instagram', icon: Instagram },
            { key: 'Facebook', label: 'Facebook', icon: Facebook },
            { key: 'LinkedIn', label: 'LinkedIn', icon: Linkedin },
            { key: 'Twitter', label: 'Twitter (X)', icon: Twitter },
          ].map((item) => (
            <button
              key={item.key}
              onClick={() => setSelectedPlatform(item.key)}
              className={`flex items-center gap-2 rounded-xl px-3.5 py-2 text-xs font-bold transition-all whitespace-nowrap ${
                selectedPlatform.toLowerCase() === item.key.toLowerCase()
                  ? 'bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] text-[#1E1B18] shadow-cream-sm'
                  : 'bg-[#FAF7F2] border border-[#EAE2D2] text-[#685D51] hover:text-[#1E1B18] hover:bg-[#FFFFFF]'
              }`}
            >
              {item.icon && <item.icon className="w-3.5 h-3.5" />}
              <span>{item.label}</span>
            </button>
          ))}
        </div>

        {/* Search and Format Dropdown */}
        <div className="flex flex-wrap items-center gap-3 w-full md:w-auto">
          <div className="relative flex-1 md:w-64">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-[#8E8276] w-3.5 h-3.5" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search posts, captions..."
              className="w-full pl-9 pr-3 py-1.5 bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl text-xs text-[#1E1B18] placeholder-[#8E8276] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
            />
          </div>

          <select
            value={selectedPostType}
            onChange={(e) => setSelectedPostType(e.target.value)}
            className="bg-[#FAF7F2] border border-[#EAE2D2] text-[#4D443B] text-xs font-semibold rounded-xl px-3 py-1.5 focus:border-[#C59A27] focus:outline-none"
          >
            <option value="All">All Formats</option>
            <option value="Reel">Reel / Video</option>
            <option value="Carousel">Carousel</option>
            <option value="Story">Story</option>
            <option value="Static Post">Static Post</option>
          </select>
        </div>
      </div>

      {/* SMM Posts Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {filtered.map((post) => (
          <div
            key={post.id}
            className="glass-card rounded-3xl p-6 sm:p-7 bg-[#FFFFFF] shadow-cream-md hover:border-[#C59A27] transition-all space-y-5 relative"
          >
            {/* Header */}
            <div className="flex items-start justify-between border-b border-[#EAE2D2] pb-4">
              <div className="flex items-center gap-3">
                <div className="rounded-2xl bg-[#FAF6EF] p-2.5 border border-[#E5D8C1] shadow-cream-sm">
                  {getPlatformIcon(post.platform)}
                </div>
                <div>
                  <h3 className="font-outfit text-base font-bold text-[#1E1B18] line-clamp-1">{post.title}</h3>
                  <div className="flex items-center gap-2 text-xs text-[#8E8276] mt-0.5">
                    <span className="text-[#8A6412] font-bold">{post.platform} • {post.postType}</span>
                    <span>•</span>
                    <span>{post.scheduledTime.split('T')[0]}</span>
                  </div>
                </div>
              </div>

              <div className="flex items-center gap-2">
                {post.isPaidAd && (
                  <span className="rounded-lg bg-emerald-50 px-2.5 py-1 text-xs font-bold text-emerald-800 border border-emerald-200">
                    Paid Ad (₹{post.adBudgetInt.toLocaleString()})
                  </span>
                )}
                <div className="flex items-center gap-1">
                  <button
                    onClick={() => handleEdit(post)}
                    className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] hover:bg-[#FFFFFF] p-2 text-[#4D443B] transition-colors"
                    title="Edit Campaign"
                  >
                    <Edit3 className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDelete(post.id)}
                    className="rounded-xl border border-rose-200 bg-rose-50 hover:bg-rose-100 p-2 text-rose-700 transition-colors"
                    title="Delete Campaign"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>

            {/* Post Caption Preview */}
            <div className="rounded-2xl border border-[#EAE2D2] bg-[#FAF7F2] p-4 text-xs text-[#4D443B] leading-relaxed shadow-inner">
              <p className="line-clamp-3">{post.caption}</p>
              <div className="flex flex-wrap gap-1.5 mt-2">
                {post.hashtags.map((ht, i) => (
                  <span key={i} className="text-[#0F4C81] font-semibold">
                    {ht}
                  </span>
                ))}
              </div>
            </div>

            {/* Performance Grid */}
            <div className="grid grid-cols-3 sm:grid-cols-6 gap-2 text-center text-xs">
              <div className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] p-2.5">
                <p className="text-[10px] text-[#8E8276] font-extrabold uppercase">Reach</p>
                <p className="font-bold text-[#1E1B18] mt-0.5">{post.reach.toLocaleString()}</p>
              </div>
              <div className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] p-2.5">
                <p className="text-[10px] text-[#8E8276] font-extrabold uppercase">Likes</p>
                <p className="font-bold text-pink-700 mt-0.5">{post.likes.toLocaleString()}</p>
              </div>
              <div className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] p-2.5">
                <p className="text-[10px] text-[#8E8276] font-extrabold uppercase">Comments</p>
                <p className="font-bold text-[#0F4C81] mt-0.5">{post.comments}</p>
              </div>
              <div className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] p-2.5">
                <p className="text-[10px] text-[#8E8276] font-extrabold uppercase">Saves</p>
                <p className="font-bold text-purple-800 mt-0.5">{post.saves}</p>
              </div>
              <div className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] p-2.5">
                <p className="text-[10px] text-[#8E8276] font-extrabold uppercase">Shares</p>
                <p className="font-bold text-[#8A6412] mt-0.5">{post.shares}</p>
              </div>
              <div className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] p-2.5">
                <p className="text-[10px] text-[#8E8276] font-extrabold uppercase">Leads</p>
                <p className="font-bold text-emerald-800 mt-0.5">{post.conversions}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Create / Edit Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingItem ? 'Edit SMM Campaign' : 'Create New SMM Post / Ad'}
        subtitle="Configure platform, creative caption, media assets, budget, and performance metrics"
        maxWidth="max-w-3xl"
      >
        <form onSubmit={handleFormSubmit} className="space-y-4 text-left">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Target Platform
              </label>
              <select
                value={formPlatform}
                onChange={(e) => setFormPlatform(e.target.value as SmmPlatform)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              >
                <option value="Instagram">Instagram</option>
                <option value="Facebook">Facebook</option>
                <option value="LinkedIn">LinkedIn</option>
                <option value="Twitter">Twitter (X)</option>
              </select>
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Post / Ad Format
              </label>
              <select
                value={formPostType}
                onChange={(e) => setFormPostType(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              >
                <option value="Reel">Reel / Short Video</option>
                <option value="Carousel">Multi-Slide Carousel</option>
                <option value="Story">Story Campaign</option>
                <option value="Static Post">Static Single Image</option>
                <option value="Tweet Thread">Tweet Thread / Poll</option>
              </select>
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Campaign / Creative Title
            </label>
            <input
              type="text"
              required
              value={formTitle}
              onChange={(e) => setFormTitle(e.target.value)}
              className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
            />
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Primary Post Caption
            </label>
            <textarea
              rows={3}
              required
              value={formCaption}
              onChange={(e) => setFormCaption(e.target.value)}
              className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none leading-relaxed"
            />
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Hashtags (comma-separated)
            </label>
            <input
              type="text"
              value={formHashtags}
              onChange={(e) => setFormHashtags(e.target.value)}
              placeholder="#AM5Royal, #HomeCare, #MumbaiServices"
              className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Media Asset Link (Google Drive / Cloud)
              </label>
              <input
                type="url"
                value={formMediaUrl}
                onChange={(e) => setFormMediaUrl(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Target Audience Demographics
              </label>
              <input
                type="text"
                value={formAudience}
                onChange={(e) => setFormAudience(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
          </div>

          <div className="grid grid-cols-3 gap-3">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Paid Boost Budget (INR)
              </label>
              <input
                type="number"
                value={formBudget}
                onChange={(e) => setFormBudget(Number(e.target.value))}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Total Reach
              </label>
              <input
                type="number"
                value={formReach}
                onChange={(e) => setFormReach(Number(e.target.value))}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Leads / Conversions
              </label>
              <input
                type="number"
                value={formConversions}
                onChange={(e) => setFormConversions(Number(e.target.value))}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              />
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
              className="rounded-xl bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] px-5 py-2 text-xs font-bold text-[#1E1B18] shadow-cream-md hover:scale-[1.02] transition-all"
            >
              {editingItem ? 'Save Campaign Changes' : 'Launch SMM Post'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
};

