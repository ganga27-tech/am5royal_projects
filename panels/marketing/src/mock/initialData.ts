// ============================================================================
// AM5 ROYAL • Clean Marketing Initial Dataset
// Reset to 0 / empty initial state
// ============================================================================

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
} from '../types/marketing';

export const initialSeoOnPageList: SeoOnPageItem[] = [];

export const initialSeoOffPageList: SeoOffPageItem[] = [];

export const initialBacklinksList: BacklinkItem[] = [];

export const initialBlogsList: BlogItem[] = [];

export const initialArticlesList: ArticleItem[] = [];

export const initialSmmPostsList: SmmPostItem[] = [];

export const initialGoogleAdsList: GoogleAdsReportItem[] = [];

export const initialGoogleAnalyticsOverview: GoogleAnalyticsOverview = {
  propertyId: 'GA4-AM5ROYAL (am5royal.com)',
  dateRange: 'Current Period',
  activeUsers: 0,
  newUsers: 0,
  sessions: 0,
  avgSessionDurationSec: 0,
  engagementRate: 0,
  bounceRate: 0,
  topSources: [],
  topPages: [],
  deviceBreakdown: { mobile: 0, desktop: 0, tablet: 0 },
  topCities: [],
};

export const initialMarketingLeadsList: MarketingLeadItem[] = [];

export const initialStrategiesList: MarketingStrategyItem[] = [];

export const initialContentCreationsList: ContentCreationItem[] = [];
