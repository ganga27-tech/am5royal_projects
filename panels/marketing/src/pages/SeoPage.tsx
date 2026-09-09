import React, { useState, useEffect } from 'react';
import { marketingApi } from '../api/marketingApi';
import { SeoOnPageItem, SeoOffPageItem } from '../types/marketing';
import { Modal } from '../components/common/Modal';
import {
  SearchCode,
  Globe,
  Plus,
  Trash2,
  Edit3,
  CheckCircle2,
  AlertTriangle,
  FileCode,
  Gauge,
  Sparkles,
  Layers,
  ArrowUpRight,
  Download,
} from 'lucide-react';

export const SeoPage: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'onpage' | 'offpage'>('onpage');
  const [onPageList, setOnPageList] = useState<SeoOnPageItem[]>([]);
  const [offPageList, setOffPageList] = useState<SeoOffPageItem[]>([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<SeoOnPageItem | null>(null);

  // Form State for On-Page SEO
  const [formPageUrl, setFormPageUrl] = useState('');
  const [formPageTitle, setFormPageTitle] = useState('');
  const [formMetaTitle, setFormMetaTitle] = useState('');
  const [formMetaDesc, setFormMetaDesc] = useState('');
  const [formPrimaryKey, setFormPrimaryKey] = useState('');
  const [formSecondaryKeys, setFormSecondaryKeys] = useState('');
  const [formCanonical, setFormCanonical] = useState('');
  const [formH1Tag, setFormH1Tag] = useState('');
  const [formH2Tags, setFormH2Tags] = useState('');
  const [formImageAltCount, setFormImageAltCount] = useState(10);
  const [formMissingAltCount, setFormMissingAltCount] = useState(0);
  const [formWordCount, setFormWordCount] = useState(1200);
  const [formKeywordDensity, setFormKeywordDensity] = useState(1.5);
  const [formSchemaType, setFormSchemaType] = useState<any>('LocalBusiness');
  const [formRobots, setFormRobots] = useState<any>('index, follow');
  const [formCoreWebVitals, setFormCoreWebVitals] = useState(90);
  const [formStatus, setFormStatus] = useState<any>('Optimized');

  // Load Data
  const loadData = async () => {
    const onpage = await marketingApi.getSeoOnPageList();
    const offpage = await marketingApi.getSeoOffPageList();
    setOnPageList(onpage);
    setOffPageList(offpage);
  };

  useEffect(() => {
    loadData();
  }, []);

  const openCreateModal = () => {
    setEditingItem(null);
    setFormPageUrl('https://am5royal.com/services/new-service');
    setFormPageTitle('Luxury Service in Mumbai | AM5 ROYAL');
    setFormMetaTitle('Top Rated Service in Mumbai - Certified Partners | AM5 ROYAL');
    setFormMetaDesc('Book certified royal service partners in Mumbai. Transparent fixed pricing, 100% verified specialists.');
    setFormPrimaryKey('luxury service mumbai');
    setFormSecondaryKeys('verified partners, best service near me');
    setFormCanonical('https://am5royal.com/services/new-service');
    setFormH1Tag('Elite Certified Services in Mumbai');
    setFormH2Tags('Why AM5 ROYAL, 6-Stage Sanitization Protocol, Client Testimonials');
    setFormImageAltCount(12);
    setFormMissingAltCount(0);
    setFormWordCount(1450);
    setFormKeywordDensity(1.6);
    setFormSchemaType('LocalBusiness');
    setFormRobots('index, follow');
    setFormCoreWebVitals(95);
    setFormStatus('Optimized');
    setIsModalOpen(true);
  };

  const openEditModal = (item: SeoOnPageItem) => {
    setEditingItem(item);
    setFormPageUrl(item.pageUrl);
    setFormPageTitle(item.pageTitle);
    setFormMetaTitle(item.metaTitle);
    setFormMetaDesc(item.metaDescription);
    setFormPrimaryKey(item.primaryKeyword);
    setFormSecondaryKeys(item.secondaryKeywords.join(', '));
    setFormCanonical(item.canonicalUrl);
    setFormH1Tag(item.h1Tag);
    setFormH2Tags(item.h2Tags.join(', '));
    setFormImageAltCount(item.imageAltCount);
    setFormMissingAltCount(item.missingAltCount);
    setFormWordCount(item.wordCount);
    setFormKeywordDensity(item.keywordDensity);
    setFormSchemaType(item.schemaType);
    setFormRobots(item.robotsDirective);
    setFormCoreWebVitals(item.coreWebVitalsScore);
    setFormStatus(item.status);
    setIsModalOpen(true);
  };

  const handleSaveOnPage = async (e: React.FormEvent) => {
    e.preventDefault();
    const payload = {
      id: editingItem?.id,
      pageUrl: formPageUrl,
      pageTitle: formPageTitle,
      metaTitle: formMetaTitle,
      metaDescription: formMetaDesc,
      primaryKeyword: formPrimaryKey,
      secondaryKeywords: formSecondaryKeys.split(',').map((k) => k.trim()).filter(Boolean),
      canonicalUrl: formCanonical,
      h1Tag: formH1Tag,
      h2Tags: formH2Tags.split(',').map((h) => h.trim()).filter(Boolean),
      imageAltCount: Number(formImageAltCount),
      missingAltCount: Number(formMissingAltCount),
      wordCount: Number(formWordCount),
      keywordDensity: Number(formKeywordDensity),
      schemaType: formSchemaType,
      robotsDirective: formRobots,
      coreWebVitalsScore: Number(formCoreWebVitals),
      lastAuditDate: editingItem?.lastAuditDate || new Date().toISOString().split('T')[0],
      status: formStatus,
    };

    await marketingApi.saveSeoOnPageItem(payload);
    setIsModalOpen(false);
    loadData();
  };

  const handleDeleteOnPage = async (id: string) => {
    if (confirm('Are you sure you want to delete this SEO audit record?')) {
      await marketingApi.deleteSeoOnPageItem(id);
      loadData();
    }
  };

  return (
    <div className="space-y-8 text-left">
      {/* Top Banner Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-[#EAE2D2] pb-6">
        <div>
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-2xl bg-[#FAF6EF] border border-[#E5D8C1] text-[#9B7314] shadow-cream-sm">
              <SearchCode className="h-6 w-6" />
            </div>
            <div>
              <h1 className="font-serif text-2xl font-bold text-[#1E1B18] tracking-tight">
                SEO Command Suite
              </h1>
              <p className="text-xs sm:text-sm text-[#685D51] mt-0.5">
                On-page technical audits, live SERP snippets, meta tag optimizations & off-page authority tracking.
              </p>
            </div>
          </div>
        </div>

        {/* Action Controls */}
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex items-center p-1 bg-[#FAF7F2] border border-[#EAE2D2] rounded-2xl shadow-inner">
            <button
              onClick={() => setActiveTab('onpage')}
              className={`flex items-center gap-2 rounded-xl px-4 py-2 text-xs font-bold transition-all ${
                activeTab === 'onpage'
                  ? 'bg-[#FFFFFF] text-[#1E1B18] shadow-cream-sm border border-[#EAE2D2]'
                  : 'text-[#8E8276] hover:text-[#1E1B18]'
              }`}
            >
              <FileCode className="h-3.5 w-3.5 text-[#9B7314]" />
              <span>On-Page SEO ({onPageList.length})</span>
            </button>
            <button
              onClick={() => setActiveTab('offpage')}
              className={`flex items-center gap-2 rounded-xl px-4 py-2 text-xs font-bold transition-all ${
                activeTab === 'offpage'
                  ? 'bg-[#FFFFFF] text-[#1E1B18] shadow-cream-sm border border-[#EAE2D2]'
                  : 'text-[#8E8276] hover:text-[#1E1B18]'
              }`}
            >
              <Globe className="h-3.5 w-3.5 text-[#9B7314]" />
              <span>Off-Page Authority</span>
            </button>
          </div>

          <button
            onClick={openCreateModal}
            className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] px-4 py-2 text-xs sm:text-sm font-bold text-[#1E1B18] shadow-cream-md hover:scale-[1.02] transition-all"
          >
            <Plus className="h-4 w-4" />
            <span>New SEO Audit</span>
          </button>
        </div>
      </div>

      {/* Content Tab: On-Page SEO */}
      {activeTab === 'onpage' && (
        <div className="space-y-6">
          {/* Live Cards List */}
          <div className="grid grid-cols-1 gap-6">
            {onPageList.map((item) => (
              <div
                key={item.id}
                className="glass-card rounded-3xl p-6 sm:p-8 bg-[#FFFFFF] shadow-cream-md hover:border-[#C59A27] transition-all space-y-6"
              >
                {/* Card Top Details */}
                <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4 border-b border-[#EAE2D2] pb-4">
                  <div className="space-y-1">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="rounded-lg bg-[#FAF6EF] border border-[#E5D8C1] px-2.5 py-0.5 text-xs font-bold text-[#8A6412]">
                        {item.schemaType}
                      </span>
                      <span
                        className={`rounded-lg px-2.5 py-0.5 text-xs font-bold ${
                          item.status === 'Optimized'
                            ? 'bg-emerald-50 text-emerald-800 border border-emerald-200'
                            : 'bg-amber-50 text-amber-800 border border-amber-200'
                        }`}
                      >
                        {item.status}
                      </span>
                      <span className="text-xs text-[#8E8276]">Audit: {item.lastAuditDate}</span>
                    </div>
                    <h3 className="font-outfit text-base sm:text-lg font-bold text-[#1E1B18] mt-1">
                      {item.pageTitle}
                    </h3>
                    <p className="text-xs font-mono text-[#8A6412] truncate max-w-2xl">
                      {item.pageUrl}
                    </p>
                  </div>

                  {/* Actions & Score */}
                  <div className="flex items-center gap-4">
                    <div className="text-right">
                      <div className="flex items-center gap-1.5 justify-end">
                        <Gauge className="h-4 w-4 text-emerald-600" />
                        <span className="font-outfit text-xl font-black text-emerald-700">
                          {item.coreWebVitalsScore}
                        </span>
                        <span className="text-[10px] text-[#8E8276]">/100</span>
                      </div>
                      <p className="text-[10px] text-[#8E8276] font-semibold">Core Web Vitals</p>
                    </div>

                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => openEditModal(item)}
                        className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] hover:bg-[#FFFFFF] p-2 text-[#4D443B] transition-colors"
                        title="Edit SEO Form Fields"
                      >
                        <Edit3 className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => handleDeleteOnPage(item.id)}
                        className="rounded-xl border border-rose-200 bg-rose-50 hover:bg-rose-100 p-2 text-rose-700 transition-colors"
                        title="Delete SEO Audit"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </div>
                </div>

                {/* Google SERP Live Snippet Preview */}
                <div className="rounded-2xl border border-[#EAE2D2] bg-[#FAF7F2] p-4 sm:p-5 text-left space-y-1.5 shadow-inner">
                  <div className="flex items-center gap-2 text-xs text-[#8E8276]">
                    <Globe className="h-3.5 w-3.5 text-[#9B7314]" />
                    <span className="font-mono text-[11px] truncate text-[#4D443B]">
                      {item.canonicalUrl}
                    </span>
                  </div>
                  <h4 className="text-base sm:text-lg font-semibold text-[#1A0DAB] hover:underline cursor-pointer leading-tight">
                    {item.metaTitle}
                  </h4>
                  <p className="text-xs text-[#4D5156] line-clamp-2 leading-relaxed">
                    {item.metaDescription}
                  </p>
                </div>

                {/* Live Form Fields Breakdown in UI */}
                <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
                  <div className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] p-3 text-left">
                    <p className="text-[10px] uppercase font-extrabold text-[#8E8276]">Primary Keyword</p>
                    <p className="text-xs font-bold text-[#9B7314] mt-0.5 truncate">
                      {item.primaryKeyword}
                    </p>
                  </div>
                  <div className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] p-3 text-left">
                    <p className="text-[10px] uppercase font-extrabold text-[#8E8276]">Keyword Density</p>
                    <p className="text-xs font-bold text-[#1E1B18] mt-0.5">{item.keywordDensity}%</p>
                  </div>
                  <div className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] p-3 text-left">
                    <p className="text-[10px] uppercase font-extrabold text-[#8E8276]">Word Count</p>
                    <p className="text-xs font-bold text-[#1E1B18] mt-0.5">{item.wordCount} words</p>
                  </div>
                  <div className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] p-3 text-left">
                    <p className="text-[10px] uppercase font-extrabold text-[#8E8276]">Image Alt Tags</p>
                    <p className="text-xs font-bold text-emerald-700 mt-0.5">
                      {item.imageAltCount} Valid / {item.missingAltCount} Missing
                    </p>
                  </div>
                  <div className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] p-3 text-left">
                    <p className="text-[10px] uppercase font-extrabold text-[#8E8276]">Robots Directive</p>
                    <p className="text-xs font-mono font-semibold text-[#685D51] mt-0.5 truncate">
                      {item.robotsDirective}
                    </p>
                  </div>
                  <div className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] p-3 text-left">
                    <p className="text-[10px] uppercase font-extrabold text-[#8E8276]">H1 Header</p>
                    <p className="text-xs font-semibold text-[#1E1B18] mt-0.5 truncate">{item.h1Tag}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Content Tab: Off-Page Authority */}
      {activeTab === 'offpage' && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {offPageList.map((item) => (
            <div
              key={item.id}
              className="glass-card rounded-3xl p-6 sm:p-8 bg-[#FFFFFF] shadow-cream-md space-y-6"
            >
              <div className="flex items-center justify-between border-b border-[#EAE2D2] pb-4">
                <div>
                  <h3 className="font-outfit text-lg font-bold text-[#1E1B18]">
                    {item.targetCategory}
                  </h3>
                  <p className="text-xs text-[#8E8276]">{item.targetRegion}</p>
                </div>
                <div className="text-right">
                  <span className="font-outfit text-2xl font-black text-[#8A6412]">
                    DA {item.domainAuthority}
                  </span>
                  <span className="text-xs text-[#8E8276]"> / Goal {item.targetDa}</span>
                </div>
              </div>

              {/* Authority Progress Bar */}
              <div className="space-y-2">
                <div className="flex items-center justify-between text-xs font-semibold text-[#685D51]">
                  <span>Domain Authority Progress</span>
                  <span className="text-[#8A6412] font-bold">
                    {Math.round((item.domainAuthority / item.targetDa) * 100)}% of Target
                  </span>
                </div>
                <div className="h-2.5 w-full rounded-full bg-[#FAF7F2] border border-[#EAE2D2] overflow-hidden">
                  <div
                    className="h-full bg-gradient-to-r from-[#C59A27] to-[#DAB84E] rounded-full transition-all"
                    style={{ width: `${(item.domainAuthority / item.targetDa) * 100}%` }}
                  />
                </div>
              </div>

              {/* Metrics Grid */}
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                <div className="rounded-2xl border border-[#EAE2D2] bg-[#FAF7F2] p-3 text-center">
                  <p className="text-[10px] uppercase font-extrabold text-[#8E8276]">Total Backlinks</p>
                  <p className="text-sm font-bold text-[#1E1B18] mt-1">{item.totalBacklinks.toLocaleString()}</p>
                </div>
                <div className="rounded-2xl border border-[#EAE2D2] bg-[#FAF7F2] p-3 text-center">
                  <p className="text-[10px] uppercase font-extrabold text-[#8E8276]">Referring Domains</p>
                  <p className="text-sm font-bold text-[#1E1B18] mt-1">{item.referringDomainsCount}</p>
                </div>
                <div className="rounded-2xl border border-[#EAE2D2] bg-[#FAF7F2] p-3 text-center">
                  <p className="text-[10px] uppercase font-extrabold text-[#8E8276]">Brand Mentions</p>
                  <p className="text-sm font-bold text-[#1E1B18] mt-1">{item.brandMentionsCount}</p>
                </div>
                <div className="rounded-2xl border border-[#EAE2D2] bg-[#FAF7F2] p-3 text-center">
                  <p className="text-[10px] uppercase font-extrabold text-[#8E8276]">Local Citations</p>
                  <p className="text-sm font-bold text-[#1E1B18] mt-1">{item.localCitationsCount}</p>
                </div>
              </div>

              {/* Competitor Gap Notes */}
              <div className="rounded-2xl border border-[#EAE2D2] bg-[#FAF7F2] p-4 text-xs text-[#685D51] space-y-1">
                <span className="font-bold text-[#1E1B18] block">Competitive Gap Strategy:</span>
                <p className="leading-relaxed">{item.competitorGapNotes}</p>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* SEO Form Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingItem ? 'Edit SEO Form Fields' : 'New On-Page SEO Audit'}
        subtitle="Manage complete meta information, canonical tags, schema and robots directives"
        maxWidth="max-w-3xl"
      >
        <form onSubmit={handleSaveOnPage} className="space-y-4 text-left">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Target Page URL *
              </label>
              <input
                type="url"
                required
                value={formPageUrl}
                onChange={(e) => setFormPageUrl(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs font-mono text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Page Title Tag *
              </label>
              <input
                type="text"
                required
                value={formPageTitle}
                onChange={(e) => setFormPageTitle(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Google Meta Title (SERP) *
              </label>
              <input
                type="text"
                required
                value={formMetaTitle}
                onChange={(e) => setFormMetaTitle(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Canonical URL
              </label>
              <input
                type="url"
                value={formCanonical}
                onChange={(e) => setFormCanonical(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs font-mono text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Google Meta Description *
            </label>
            <textarea
              rows={2}
              required
              value={formMetaDesc}
              onChange={(e) => setFormMetaDesc(e.target.value)}
              className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none leading-relaxed"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Primary Keyword *
              </label>
              <input
                type="text"
                required
                value={formPrimaryKey}
                onChange={(e) => setFormPrimaryKey(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Secondary Keywords (Comma Separated)
              </label>
              <input
                type="text"
                value={formSecondaryKeys}
                onChange={(e) => setFormSecondaryKeys(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Schema JSON-LD Type
              </label>
              <select
                value={formSchemaType}
                onChange={(e) => setFormSchemaType(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              >
                <option value="LocalBusiness">LocalBusiness</option>
                <option value="Service">Service</option>
                <option value="Article">Article</option>
                <option value="Organization">Organization</option>
                <option value="WebPage">WebPage</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Robots Directive
              </label>
              <select
                value={formRobots}
                onChange={(e) => setFormRobots(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              >
                <option value="index, follow">index, follow</option>
                <option value="noindex, follow">noindex, follow</option>
                <option value="index, nofollow">index, nofollow</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Audit Status
              </label>
              <select
                value={formStatus}
                onChange={(e) => setFormStatus(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              >
                <option value="Optimized">Optimized</option>
                <option value="Needs Attention">Needs Attention</option>
                <option value="Critical Issues">Critical Issues</option>
              </select>
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
              Save SEO Configuration
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
};
