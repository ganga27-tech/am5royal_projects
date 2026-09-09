// ============================================================================
// AM5 ROYAL • Marketing Panel Types Definition
// Production-grade types covering all 10 marketing domains
// ============================================================================

export type UserRole = 'marketing_head' | 'seo_lead' | 'growth_hacker' | 'content_strategist' | 'smm_specialist';

export interface MarketingUser {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  roleTitle: string;
  avatarUrl?: string;
  token?: string;
}

// 1. SEO Types (On-Page & Off-Page)
export interface SeoOnPageItem {
  id: string;
  pageUrl: string;
  pageTitle: string;
  metaTitle: string;
  metaDescription: string;
  primaryKeyword: string;
  secondaryKeywords: string[];
  canonicalUrl: string;
  h1Tag: string;
  h2Tags: string[];
  imageAltCount: number;
  missingAltCount: number;
  wordCount: number;
  keywordDensity: number; // e.g. 1.8%
  ogTitle?: string;
  ogDescription?: string;
  ogImageUrl?: string;
  schemaType: 'LocalBusiness' | 'Service' | 'Article' | 'Organization' | 'WebPage';
  robotsDirective: 'index, follow' | 'noindex, follow' | 'index, nofollow';
  coreWebVitalsScore: number; // 0-100
  lastAuditDate: string;
  status: 'Optimized' | 'Needs Attention' | 'Critical Issues';
}

export interface SeoOffPageItem {
  id: string;
  targetCategory: string;
  targetRegion: string;
  domainAuthority: number; // 0-100
  targetDa: number;
  totalBacklinks: number;
  referringDomainsCount: number;
  brandMentionsCount: number;
  localCitationsCount: number;
  competitorGapNotes: string;
  lastUpdated: string;
}

// 2. Backlinks Types
export interface BacklinkItem {
  id: string;
  targetUrl: string;
  referringDomain: string;
  anchorText: string;
  linkType: 'DoFollow' | 'NoFollow' | 'UGC' | 'Sponsored';
  domainRating: number;
  spamScore: number; // 0-100%
  liveVerifiedUrl: string;
  acquisitionDate: string;
  costInr: number;
  outreachContact: string;
  status: 'Live' | 'In Outreach' | 'Lost' | 'Pending Verification';
  notes?: string;
}

// 3. Blogs Types
export interface BlogItem {
  id: string;
  title: string;
  slug: string;
  category: string;
  targetSuperCategory: string;
  authorName: string;
  authorAvatar?: string;
  readTimeMinutes: number;
  wordCount: number;
  featuredImageUrl: string;
  metaTitle: string;
  metaDescription: string;
  focusKeywords: string[];
  tags: string[];
  content: string;
  publishDate: string;
  status: 'Draft' | 'In Review' | 'Scheduled' | 'Published';
  viewsCount: number;
  sharesCount: number;
}

// 4. Articles Types (PR, Media & External Publications)
export interface ArticleItem {
  id: string;
  title: string;
  publicationName: string;
  publicationType: 'Press Release' | 'Guest Post' | 'Medium' | 'News Portal' | 'Industry Journal';
  authorByline: string;
  targetAudience: string;
  publicationDate: string;
  canonicalUrl: string;
  liveArticleUrl: string;
  targetedKeywords: string[];
  backlinkIncluded: boolean;
  contentSnippet: string;
  status: 'Pitching' | 'Drafting' | 'Approved' | 'Published' | 'Archived';
  referralTraffic: number;
}

// 5. SMM (Social Media Marketing) Types
export type SmmPlatform = 'Instagram' | 'Facebook' | 'LinkedIn' | 'Twitter';

export interface SmmPostItem {
  id: string;
  platform: SmmPlatform;
  postType: 'Reel' | 'Carousel' | 'Story' | 'Static Post' | 'Video' | 'Tweet Thread';
  title: string;
  caption: string;
  hashtags: string[];
  mediaAssetUrl: string;
  scheduledTime: string;
  targetAudience: string;
  isPaidAd: boolean;
  adBudgetInt: number;
  // Metrics
  impressions: number;
  reach: number;
  likes: number;
  comments: number;
  saves: number;
  shares: number;
  linkClicks: number;
  spendInr: number;
  conversions: number;
  status: 'Draft' | 'Scheduled' | 'Active Live' | 'Completed';
}

// 6. Google Ads Types
export interface GoogleAdsReportItem {
  id: string;
  campaignName: string;
  campaignType: 'Search' | 'Performance Max' | 'Display' | 'YouTube Video' | 'Local Store';
  targetSuperCategory: string;
  targetKeywords: string[];
  negativeKeywords: string[];
  dailyBudgetInr: number;
  totalSpendInr: number;
  impressions: number;
  clicks: number;
  ctrPercent: number;
  avgCpcInr: number;
  conversions: number;
  cpaInr: number;
  roasRatio: number; // e.g. 4.2x
  status: 'Active' | 'Paused' | 'Learning' | 'Completed';
  startDate: string;
  endDate?: string;
}

// 7. Google Analytics GA4 Types
export interface GaTrafficSource {
  channel: string;
  users: number;
  sessions: number;
  engagementRatePercent: number;
  conversions: number;
  revenueInr: number;
}

export interface GaLandingPage {
  path: string;
  pageviews: number;
  avgTimeSeconds: number;
  bounceRatePercent: number;
  conversions: number;
}

export interface GoogleAnalyticsOverview {
  propertyId: string;
  dateRange: string;
  activeUsers: number;
  newUsers: number;
  sessions: number;
  avgSessionDurationSec: number;
  engagementRate: number;
  bounceRate: number;
  topSources: GaTrafficSource[];
  topPages: GaLandingPage[];
  deviceBreakdown: { mobile: number; desktop: number; tablet: number };
  topCities: { city: string; users: number; share: number }[];
}

// 8. Leads & Conversions Hub Types
export type LeadSource = 'SEO Organic' | 'Instagram Ad' | 'Facebook Ad' | 'Google Ad' | 'Blog' | 'LinkedIn' | 'Referral' | 'Telecaller';
export type LeadStatus = 'New' | 'Contacted' | 'Qualified' | 'Demo Scheduled' | 'Converted' | 'Lost';

export interface MarketingLeadItem {
  id: string;
  leadName: string;
  contactNumber: string;
  email: string;
  businessName: string;
  source: LeadSource;
  targetCategory: string;
  city: string;
  state: string;
  status: LeadStatus;
  dealValueInr: number;
  customerAcquisitionCostInr: number;
  assignedRep: string;
  followUpDate: string;
  createdAt: string;
  conversionDate?: string;
  notes?: string;
}

// 9. Marketing Strategy Types
export interface StrategyMilestone {
  id: string;
  title: string;
  dueDate: string;
  completed: boolean;
}

export interface MarketingStrategyItem {
  id: string;
  title: string;
  horizonQuarter: string; // e.g. "Q3 2026", "Festive Blitz 2026"
  objective: string;
  targetSuperCategories: string[];
  targetRegions: string[];
  coreChannels: string[];
  allocatedBudgetInr: number;
  spentBudgetInr: number;
  projectedLeads: number;
  actualLeads: number;
  kpis: string[];
  milestones: StrategyMilestone[];
  ownerName: string;
  status: 'Planning' | 'Active' | 'Under Review' | 'Completed' | 'Paused';
  learningsNotes?: string;
}

// 10. Content Creations Types
export type ContentType = 
  | 'Short Video Script (Reel/Short)' 
  | 'Ad Banner Copy' 
  | 'Email Newsletter' 
  | 'Push Notification' 
  | 'Brochure / Flyer' 
  | 'Case Study' 
  | 'Infographic Brief';

export interface ContentCreationItem {
  id: string;
  title: string;
  contentType: ContentType;
  platform: string;
  targetPersona: string;
  copyText: string;
  visualAssetUrl: string; // drive/cloud link
  assignedCreator: string;
  deadlineDate: string;
  approvalStatus: 'Draft' | 'Under Review' | 'Revision Requested' | 'Approved' | 'Published';
  performanceTags: string[];
  createdAt: string;
}

// Overall Dashboard KPI Aggregation
export interface MarketingOverviewStats {
  totalLeads: number;
  totalConversions: number;
  conversionRatePercent: number;
  totalAdSpendInr: number;
  blendedRoas: number;
  blendedCpaInr: number;
  totalBacklinks: number;
  publishedBlogs: number;
  totalSocialReach: number;
  activeCampaigns: number;
}
