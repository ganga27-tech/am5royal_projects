// ============================================================================
// AM5 ROYAL • Unified Marketing API & Persistent Data Store
// Connects with Backend API and provides resilient local caching + state management
// ============================================================================

import { apiClient } from './client';
import { storage } from '../utils/storage';
import {
  SeoOnPageItem,
  SeoOffPageItem,
  BacklinkItem,
  BlogItem,
  ArticleItem,
  SmmPostItem,
  GoogleAdsReportItem,
  GoogleAnalyticsOverview,
  MarketingLeadItem,
  MarketingStrategyItem,
  ContentCreationItem,
  MarketingOverviewStats,
} from '../types/marketing';
import {
  initialSeoOnPageList,
  initialSeoOffPageList,
  initialBacklinksList,
  initialBlogsList,
  initialArticlesList,
  initialSmmPostsList,
  initialGoogleAdsList,
  initialGoogleAnalyticsOverview,
  initialMarketingLeadsList,
  initialStrategiesList,
  initialContentCreationsList,
} from '../mock/initialData';

export const marketingApi = {
  // --------------------------------------------------------------------------
  // 1. SEO (On-Page & Off-Page)
  // --------------------------------------------------------------------------
  getSeoOnPageList: async (): Promise<SeoOnPageItem[]> => {
    try {
      const res = await apiClient.get('/marketing/seo/on-page');
      if (res.data && Array.isArray(res.data)) return res.data;
    } catch {}
    return storage.getData<SeoOnPageItem[]>('seo_onpage', initialSeoOnPageList);
  },

  saveSeoOnPageItem: async (item: Omit<SeoOnPageItem, 'id'> & { id?: string }): Promise<SeoOnPageItem> => {
    const list = await marketingApi.getSeoOnPageList();
    const finalItem: SeoOnPageItem = {
      ...item,
      id: item.id || `seo-${Date.now()}`,
      lastAuditDate: item.lastAuditDate || new Date().toISOString().split('T')[0],
    };

    const existingIndex = list.findIndex((i) => i.id === finalItem.id);
    let updatedList: SeoOnPageItem[];
    if (existingIndex >= 0) {
      updatedList = [...list];
      updatedList[existingIndex] = finalItem;
    } else {
      updatedList = [finalItem, ...list];
    }

    storage.setData('seo_onpage', updatedList);
    try {
      await apiClient.post('/marketing/seo/on-page', finalItem);
    } catch {}
    return finalItem;
  },

  deleteSeoOnPageItem: async (id: string): Promise<void> => {
    const list = await marketingApi.getSeoOnPageList();
    const updated = list.filter((i) => i.id !== id);
    storage.setData('seo_onpage', updated);
    try {
      await apiClient.delete(`/marketing/seo/on-page/${id}`);
    } catch {}
  },

  getSeoOffPageList: async (): Promise<SeoOffPageItem[]> => {
    return storage.getData<SeoOffPageItem[]>('seo_offpage', initialSeoOffPageList);
  },

  saveSeoOffPageItem: async (item: Omit<SeoOffPageItem, 'id'> & { id?: string }): Promise<SeoOffPageItem> => {
    const list = await marketingApi.getSeoOffPageList();
    const finalItem: SeoOffPageItem = {
      ...item,
      id: item.id || `offpage-${Date.now()}`,
      lastUpdated: new Date().toISOString().split('T')[0],
    };
    const idx = list.findIndex((i) => i.id === finalItem.id);
    const updatedList = idx >= 0 ? list.map((i) => (i.id === finalItem.id ? finalItem : i)) : [finalItem, ...list];
    storage.setData('seo_offpage', updatedList);
    return finalItem;
  },

  // --------------------------------------------------------------------------
  // 2. Backlinks
  // --------------------------------------------------------------------------
  getBacklinks: async (): Promise<BacklinkItem[]> => {
    try {
      const res = await apiClient.get('/marketing/backlinks');
      if (res.data && Array.isArray(res.data)) return res.data;
    } catch {}
    return storage.getData<BacklinkItem[]>('backlinks', initialBacklinksList);
  },

  saveBacklink: async (item: Omit<BacklinkItem, 'id'> & { id?: string }): Promise<BacklinkItem> => {
    const list = await marketingApi.getBacklinks();
    const finalItem: BacklinkItem = {
      ...item,
      id: item.id || `bl-${Date.now()}`,
    };
    const idx = list.findIndex((i) => i.id === finalItem.id);
    const updatedList = idx >= 0 ? list.map((i) => (i.id === finalItem.id ? finalItem : i)) : [finalItem, ...list];
    storage.setData('backlinks', updatedList);
    try {
      await apiClient.post('/marketing/backlinks', finalItem);
    } catch {}
    return finalItem;
  },

  deleteBacklink: async (id: string): Promise<void> => {
    const list = await marketingApi.getBacklinks();
    storage.setData('backlinks', list.filter((i) => i.id !== id));
    try {
      await apiClient.delete(`/marketing/backlinks/${id}`);
    } catch {}
  },

  // --------------------------------------------------------------------------
  // 3. Blogs
  // --------------------------------------------------------------------------
  getBlogs: async (): Promise<BlogItem[]> => {
    try {
      const res = await apiClient.get('/marketing/blogs');
      if (res.data && Array.isArray(res.data)) return res.data;
    } catch {}
    return storage.getData<BlogItem[]>('blogs', initialBlogsList);
  },

  saveBlog: async (item: Omit<BlogItem, 'id'> & { id?: string }): Promise<BlogItem> => {
    const list = await marketingApi.getBlogs();
    const finalItem: BlogItem = {
      ...item,
      id: item.id || `blog-${Date.now()}`,
      publishDate: item.publishDate || new Date().toISOString().split('T')[0],
      viewsCount: item.viewsCount ?? 0,
      sharesCount: item.sharesCount ?? 0,
    };
    const idx = list.findIndex((i) => i.id === finalItem.id);
    const updatedList = idx >= 0 ? list.map((i) => (i.id === finalItem.id ? finalItem : i)) : [finalItem, ...list];
    storage.setData('blogs', updatedList);
    try {
      await apiClient.post('/marketing/blogs', finalItem);
    } catch {}
    return finalItem;
  },

  deleteBlog: async (id: string): Promise<void> => {
    const list = await marketingApi.getBlogs();
    storage.setData('blogs', list.filter((i) => i.id !== id));
    try {
      await apiClient.delete(`/marketing/blogs/${id}`);
    } catch {}
  },

  // --------------------------------------------------------------------------
  // 4. Articles (PR & External Publications)
  // --------------------------------------------------------------------------
  getArticles: async (): Promise<ArticleItem[]> => {
    try {
      const res = await apiClient.get('/marketing/articles');
      if (res.data && Array.isArray(res.data)) return res.data;
    } catch {}
    return storage.getData<ArticleItem[]>('articles', initialArticlesList);
  },

  saveArticle: async (item: Omit<ArticleItem, 'id'> & { id?: string }): Promise<ArticleItem> => {
    const list = await marketingApi.getArticles();
    const finalItem: ArticleItem = {
      ...item,
      id: item.id || `art-${Date.now()}`,
      publicationDate: item.publicationDate || new Date().toISOString().split('T')[0],
      referralTraffic: item.referralTraffic ?? 0,
    };
    const idx = list.findIndex((i) => i.id === finalItem.id);
    const updatedList = idx >= 0 ? list.map((i) => (i.id === finalItem.id ? finalItem : i)) : [finalItem, ...list];
    storage.setData('articles', updatedList);
    try {
      await apiClient.post('/marketing/articles', finalItem);
    } catch {}
    return finalItem;
  },

  deleteArticle: async (id: string): Promise<void> => {
    const list = await marketingApi.getArticles();
    storage.setData('articles', list.filter((i) => i.id !== id));
    try {
      await apiClient.delete(`/marketing/articles/${id}`);
    } catch {}
  },

  // --------------------------------------------------------------------------
  // 5. SMM (Social Media Marketing - Ads and Reports)
  // --------------------------------------------------------------------------
  getSmmPosts: async (platform?: string): Promise<SmmPostItem[]> => {
    const list = storage.getData<SmmPostItem[]>('smm_posts', initialSmmPostsList);
    if (platform && platform !== 'All') {
      return list.filter((p) => p.platform.toLowerCase() === platform.toLowerCase());
    }
    return list;
  },

  saveSmmPost: async (item: Omit<SmmPostItem, 'id'> & { id?: string }): Promise<SmmPostItem> => {
    const list = storage.getData<SmmPostItem[]>('smm_posts', initialSmmPostsList);
    const finalItem: SmmPostItem = {
      ...item,
      id: item.id || `smm-${Date.now()}`,
      impressions: item.impressions ?? 0,
      reach: item.reach ?? 0,
      likes: item.likes ?? 0,
      comments: item.comments ?? 0,
      saves: item.saves ?? 0,
      shares: item.shares ?? 0,
      linkClicks: item.linkClicks ?? 0,
      conversions: item.conversions ?? 0,
      spendInr: item.spendInr ?? 0,
    };
    const idx = list.findIndex((i) => i.id === finalItem.id);
    const updatedList = idx >= 0 ? list.map((i) => (i.id === finalItem.id ? finalItem : i)) : [finalItem, ...list];
    storage.setData('smm_posts', updatedList);
    return finalItem;
  },

  deleteSmmPost: async (id: string): Promise<void> => {
    const list = storage.getData<SmmPostItem[]>('smm_posts', initialSmmPostsList);
    storage.setData('smm_posts', list.filter((i) => i.id !== id));
  },

  // --------------------------------------------------------------------------
  // 6. Google Ads Reports
  // --------------------------------------------------------------------------
  getGoogleAdsReports: async (): Promise<GoogleAdsReportItem[]> => {
    return storage.getData<GoogleAdsReportItem[]>('google_ads', initialGoogleAdsList);
  },

  saveGoogleAdsReport: async (item: Omit<GoogleAdsReportItem, 'id'> & { id?: string }): Promise<GoogleAdsReportItem> => {
    const list = await marketingApi.getGoogleAdsReports();
    const finalItem: GoogleAdsReportItem = {
      ...item,
      id: item.id || `gads-${Date.now()}`,
      impressions: item.impressions ?? 0,
      clicks: item.clicks ?? 0,
      totalSpendInr: item.totalSpendInr ?? 0,
      conversions: item.conversions ?? 0,
      ctrPercent: item.impressions ? Number(((item.clicks / item.impressions) * 100).toFixed(2)) : item.ctrPercent,
      avgCpcInr: item.clicks ? Number((item.totalSpendInr / item.clicks).toFixed(2)) : item.avgCpcInr,
      cpaInr: item.conversions ? Number((item.totalSpendInr / item.conversions).toFixed(2)) : item.cpaInr,
      roasRatio: item.roasRatio || 4.5,
    };
    const idx = list.findIndex((i) => i.id === finalItem.id);
    const updatedList = idx >= 0 ? list.map((i) => (i.id === finalItem.id ? finalItem : i)) : [finalItem, ...list];
    storage.setData('google_ads', updatedList);
    return finalItem;
  },

  deleteGoogleAdsReport: async (id: string): Promise<void> => {
    const list = await marketingApi.getGoogleAdsReports();
    storage.setData('google_ads', list.filter((i) => i.id !== id));
  },

  // --------------------------------------------------------------------------
  // 7. Google Analytics GA4
  // --------------------------------------------------------------------------
  getGoogleAnalyticsOverview: async (): Promise<GoogleAnalyticsOverview> => {
    return storage.getData<GoogleAnalyticsOverview>('ga4_overview', initialGoogleAnalyticsOverview);
  },

  updateGoogleAnalyticsOverview: async (overview: GoogleAnalyticsOverview): Promise<GoogleAnalyticsOverview> => {
    storage.setData('ga4_overview', overview);
    return overview;
  },

  // --------------------------------------------------------------------------
  // 8. Leads & Conversions Hub
  // --------------------------------------------------------------------------
  getMarketingLeads: async (): Promise<MarketingLeadItem[]> => {
    try {
      const res = await apiClient.get('/marketing/leads');
      if (res.data && Array.isArray(res.data)) {
        // Map backend model to frontend structure
        return res.data.map((lead: any) => ({
          id: String(lead.id),
          leadName: lead.contact_person || lead.shop_name || 'Partner',
          contactNumber: lead.phone_number || '',
          email: lead.email || '',
          businessName: lead.shop_name || 'Service Business',
          source: lead.source || 'SEO Organic',
          targetCategory: lead.target_category || 'Home Services',
          city: lead.address ? lead.address.split(',')[0] : 'Mumbai',
          state: 'Maharashtra',
          status: lead.status === 'ONBOARDED' ? 'Converted' : (lead.status === 'CONTACTED' ? 'Contacted' : 'New'),
          dealValueInr: lead.deal_value || 9999,
          customerAcquisitionCostInr: lead.cac || 190,
          assignedRep: 'Marketing Team',
          followUpDate: new Date().toISOString().split('T')[0],
          createdAt: lead.created_at ? lead.created_at.split('T')[0] : new Date().toISOString().split('T')[0],
          notes: lead.notes || '',
        }));
      }
    } catch {}
    return storage.getData<MarketingLeadItem[]>('marketing_leads', initialMarketingLeadsList);
  },

  saveMarketingLead: async (item: Omit<MarketingLeadItem, 'id'> & { id?: string }): Promise<MarketingLeadItem> => {
    const list = storage.getData<MarketingLeadItem[]>('marketing_leads', initialMarketingLeadsList);
    const finalItem: MarketingLeadItem = {
      ...item,
      id: item.id || `lead-${Date.now()}`,
      createdAt: item.createdAt || new Date().toISOString().split('T')[0],
    };
    const idx = list.findIndex((i) => i.id === finalItem.id);
    const updatedList = idx >= 0 ? list.map((i) => (i.id === finalItem.id ? finalItem : i)) : [finalItem, ...list];
    storage.setData('marketing_leads', updatedList);

    try {
      // Attempt backend post
      await apiClient.post('/marketing/leads', {
        shop_name: finalItem.businessName,
        contact_person: finalItem.leadName,
        phone_number: finalItem.contactNumber,
        address: `${finalItem.city}, ${finalItem.state}`,
        notes: finalItem.notes,
        status: finalItem.status === 'Converted' ? 'ONBOARDED' : (finalItem.status === 'Contacted' ? 'CONTACTED' : 'NEW'),
      });
    } catch {}

    return finalItem;
  },

  deleteMarketingLead: async (id: string): Promise<void> => {
    const list = storage.getData<MarketingLeadItem[]>('marketing_leads', initialMarketingLeadsList);
    storage.setData('marketing_leads', list.filter((i) => i.id !== id));
  },

  // --------------------------------------------------------------------------
  // 9. Marketing Strategies
  // --------------------------------------------------------------------------
  getStrategies: async (): Promise<MarketingStrategyItem[]> => {
    return storage.getData<MarketingStrategyItem[]>('strategies', initialStrategiesList);
  },

  saveStrategy: async (item: Omit<MarketingStrategyItem, 'id'> & { id?: string }): Promise<MarketingStrategyItem> => {
    const list = await marketingApi.getStrategies();
    const finalItem: MarketingStrategyItem = {
      ...item,
      id: item.id || `strat-${Date.now()}`,
      spentBudgetInr: item.spentBudgetInr ?? 0,
      actualLeads: item.actualLeads ?? 0,
      milestones: item.milestones ?? [],
    };
    const idx = list.findIndex((i) => i.id === finalItem.id);
    const updatedList = idx >= 0 ? list.map((i) => (i.id === finalItem.id ? finalItem : i)) : [finalItem, ...list];
    storage.setData('strategies', updatedList);
    return finalItem;
  },

  deleteStrategy: async (id: string): Promise<void> => {
    const list = await marketingApi.getStrategies();
    storage.setData('strategies', list.filter((i) => i.id !== id));
  },

  // --------------------------------------------------------------------------
  // 10. Content Creations
  // --------------------------------------------------------------------------
  getContentCreations: async (): Promise<ContentCreationItem[]> => {
    return storage.getData<ContentCreationItem[]>('content_creations', initialContentCreationsList);
  },

  saveContentCreation: async (item: Omit<ContentCreationItem, 'id'> & { id?: string }): Promise<ContentCreationItem> => {
    const list = await marketingApi.getContentCreations();
    const finalItem: ContentCreationItem = {
      ...item,
      id: item.id || `content-${Date.now()}`,
      createdAt: item.createdAt || new Date().toISOString().split('T')[0],
      performanceTags: item.performanceTags ?? [],
    };
    const idx = list.findIndex((i) => i.id === finalItem.id);
    const updatedList = idx >= 0 ? list.map((i) => (i.id === finalItem.id ? finalItem : i)) : [finalItem, ...list];
    storage.setData('content_creations', updatedList);
    return finalItem;
  },

  deleteContentCreation: async (id: string): Promise<void> => {
    const list = await marketingApi.getContentCreations();
    storage.setData('content_creations', list.filter((i) => i.id !== id));
  },

  // --------------------------------------------------------------------------
  // Overview & Analytics Aggregator
  // --------------------------------------------------------------------------
  getOverviewStats: async (): Promise<MarketingOverviewStats> => {
    const leads = await marketingApi.getMarketingLeads();
    const googleAds = await marketingApi.getGoogleAdsReports();
    const smmPosts = await marketingApi.getSmmPosts();
    const backlinks = await marketingApi.getBacklinks();
    const blogs = await marketingApi.getBlogs();

    const totalLeads = leads.length;
    const totalConversions = leads.filter((l) => l.status === 'Converted').length;
    const conversionRatePercent = totalLeads > 0 ? Number(((totalConversions / totalLeads) * 100).toFixed(1)) : 0;

    const gadsSpend = googleAds.reduce((sum, g) => sum + g.totalSpendInr, 0);
    const smmSpend = smmPosts.reduce((sum, s) => sum + s.spendInr, 0);
    const totalAdSpendInr = gadsSpend + smmSpend;

    const totalSocialReach = smmPosts.reduce((sum, s) => sum + s.reach, 0);
    const activeCampaigns = googleAds.filter((g) => g.status === 'Active').length + smmPosts.filter((s) => s.status === 'Active Live').length;

    const blendedRoas = totalAdSpendInr > 0 ? Number(((totalConversions * 50000) / totalAdSpendInr).toFixed(2)) : 0;
    const blendedCpaInr = totalConversions > 0 ? Math.round(totalAdSpendInr / totalConversions) : 0;

    return {
      totalLeads,
      totalConversions,
      conversionRatePercent,
      totalAdSpendInr,
      blendedRoas,
      blendedCpaInr,
      totalBacklinks: backlinks.length,
      publishedBlogs: blogs.filter((b) => b.status === 'Published').length,
      totalSocialReach,
      activeCampaigns,
    };
  },

  // Helper export function
  exportToCsv: (data: Record<string, any>[], filename: string) => {
    if (!data.length) return;
    const headers = Object.keys(data[0]);
    const csvRows = [
      headers.join(','),
      ...data.map((row) =>
        headers
          .map((fieldName) => {
            const val = row[fieldName];
            if (val === null || val === undefined) return '""';
            const escaped = String(val).replace(/"/g, '""');
            return `"${escaped}"`;
          })
          .join(',')
      ),
    ];

    const blob = new Blob([csvRows.join('\n')], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.setAttribute('download', `${filename}_${new Date().toISOString().split('T')[0]}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  },
};
