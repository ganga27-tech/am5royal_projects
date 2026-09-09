from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional, Any, Dict
from pydantic import BaseModel, Field
from datetime import datetime
from decimal import Decimal

from app.db.session import get_db
from app.models.marketing import MarketingLead, MarketingCollateral
from app.dependencies.auth import get_current_employee

router = APIRouter()

# -----------------------------------------------------------------------------
# 1. Marketing Leads & Conversions
# -----------------------------------------------------------------------------
class LeadCreate(BaseModel):
    shop_name: str
    contact_person: str
    phone_number: str
    address: str
    latitude: Optional[Decimal] = None
    longitude: Optional[Decimal] = None
    shop_image_url: Optional[str] = None
    notes: Optional[str] = None
    deal_value: Optional[float] = 50000.0
    source: Optional[str] = "Google Ad"
    target_category: Optional[str] = "Luxury Retail"

class LeadResponse(BaseModel):
    id: int
    shop_name: str
    contact_person: str
    phone_number: str
    address: str
    latitude: Optional[Decimal] = None
    longitude: Optional[Decimal] = None
    shop_image_url: Optional[str] = None
    notes: Optional[str] = None
    status: str
    created_by_employee_id: Optional[int] = None
    assigned_to_employee_id: Optional[int] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True

class LeadStatusUpdate(BaseModel):
    status: str

class LeadAssign(BaseModel):
    employee_id: int

@router.post("/leads", response_model=LeadResponse)
async def create_lead(
    lead_in: LeadCreate,
    db: AsyncSession = Depends(get_db)
):
    new_lead = MarketingLead(
        shop_name=lead_in.shop_name,
        contact_person=lead_in.contact_person,
        phone_number=lead_in.phone_number,
        address=lead_in.address,
        latitude=lead_in.latitude,
        longitude=lead_in.longitude,
        shop_image_url=lead_in.shop_image_url,
        notes=lead_in.notes,
        status="NEW"
    )
    db.add(new_lead)
    await db.commit()
    await db.refresh(new_lead)
    return new_lead

@router.get("/leads", response_model=List[LeadResponse])
async def list_leads(
    db: AsyncSession = Depends(get_db),
    status: Optional[str] = None
):
    query = select(MarketingLead).order_by(MarketingLead.id.desc())
    if status:
        query = query.where(MarketingLead.status == status)
    result = await db.execute(query)
    leads = result.scalars().all()
    return leads

@router.put("/leads/{lead_id}/status", response_model=LeadResponse)
async def update_lead_status(
    lead_id: int,
    status_update: LeadStatusUpdate,
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(MarketingLead).where(MarketingLead.id == lead_id))
    lead = result.scalar_one_or_none()
    if not lead:
        raise HTTPException(status_code=404, detail="Lead not found")
    
    lead.status = status_update.status
    await db.commit()
    await db.refresh(lead)
    return lead

@router.delete("/leads/{lead_id}")
async def delete_lead(
    lead_id: int,
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(MarketingLead).where(MarketingLead.id == lead_id))
    lead = result.scalar_one_or_none()
    if not lead:
        raise HTTPException(status_code=404, detail="Lead not found")
    await db.delete(lead)
    await db.commit()
    return {"message": "Lead deleted successfully", "id": lead_id}

# -----------------------------------------------------------------------------
# 2. SEO (On-Page & Off-Page)
# -----------------------------------------------------------------------------
class SeoOnPageModel(BaseModel):
    id: Optional[str] = None
    pageUrl: str
    pageTitle: str
    metaTitle: str
    metaDescription: str
    primaryKeyword: str
    secondaryKeywords: List[str] = []
    canonicalUrl: str
    h1Tag: str
    h2Tags: List[str] = []
    imageAltCount: int = 0
    missingAltCount: int = 0
    wordCount: int = 0
    keywordDensity: float = 1.5
    schemaType: str = "LocalBusiness"
    robotsDirective: str = "index, follow"
    coreWebVitalsScore: int = 92
    lastAuditDate: Optional[str] = None
    status: str = "Optimized"

@router.get("/seo/on-page")
async def get_seo_on_page():
    return [
        {
            "id": "seo-001",
            "pageUrl": "https://am5royal.com/services/home-deep-cleaning-mumbai",
            "pageTitle": "Luxury Home Deep Cleaning Services in Mumbai | AM5 ROYAL",
            "metaTitle": "Professional Villa & Home Deep Cleaning Mumbai | 100% Verified Partners",
            "metaDescription": "Book premium, certified 5-star home sanitization, kitchen degreasing, and sofa upholstery cleaning in Mumbai.",
            "primaryKeyword": "home deep cleaning mumbai",
            "secondaryKeywords": ["villa sanitization", "sofa dry cleaning mumbai", "luxury housekeeping"],
            "canonicalUrl": "https://am5royal.com/services/home-deep-cleaning-mumbai",
            "h1Tag": "Elite Residential & Villa Deep Cleaning in Mumbai",
            "h2Tags": ["Why Choose AM5 ROYAL Certified Pros", "Our 6-Stage Deep Cleansing Protocol"],
            "imageAltCount": 18,
            "missingAltCount": 0,
            "wordCount": 1840,
            "keywordDensity": 1.8,
            "schemaType": "LocalBusiness",
            "robotsDirective": "index, follow",
            "coreWebVitalsScore": 96,
            "lastAuditDate": "2026-09-07",
            "status": "Optimized"
        }
    ]

@router.post("/seo/on-page")
async def save_seo_on_page(item: SeoOnPageModel):
    return {"message": "On-Page SEO Configuration Saved", "data": item}

@router.delete("/seo/on-page/{seo_id}")
async def delete_seo_on_page(seo_id: str):
    return {"message": f"SEO On-Page Audit item {seo_id} deleted successfully", "id": seo_id}

# -----------------------------------------------------------------------------
# 3. Backlinks & Outreach
# -----------------------------------------------------------------------------
class BacklinkModel(BaseModel):
    id: Optional[str] = None
    targetUrl: str
    referringDomain: str
    anchorText: str
    linkType: str = "DoFollow"
    domainRating: int = 70
    spamScore: int = 1
    liveVerifiedUrl: str
    acquisitionDate: str
    costInr: float = 15000
    outreachContact: str
    status: str = "Live"
    notes: Optional[str] = None

@router.get("/backlinks")
async def get_backlinks():
    return [
        {
            "id": "bl-001",
            "targetUrl": "https://am5royal.com/services/bridal-makeup",
            "referringDomain": "vogue.in",
            "anchorText": "top luxury bridal artists by AM5 ROYAL",
            "linkType": "DoFollow",
            "domainRating": 84,
            "spamScore": 1,
            "liveVerifiedUrl": "https://www.vogue.in/wedding-trends-2026-curated-guide",
            "acquisitionDate": "2026-08-15",
            "costInr": 45000,
            "outreachContact": "editor.editorial@vogue.in",
            "status": "Live",
            "notes": "Premium editorial placement in Annual Indian Wedding Issue"
        }
    ]

@router.post("/backlinks")
async def save_backlink(item: BacklinkModel):
    return {"message": "Backlink Record Saved", "data": item}

@router.delete("/backlinks/{backlink_id}")
async def delete_backlink(backlink_id: str):
    return {"message": f"Backlink {backlink_id} removed successfully", "id": backlink_id}

# -----------------------------------------------------------------------------
# 4. Blogs & PR Articles
# -----------------------------------------------------------------------------
class BlogModel(BaseModel):
    id: Optional[str] = None
    title: str
    slug: str
    category: str
    targetSuperCategory: str
    authorName: str
    readTimeMinutes: int = 5
    wordCount: int = 1200
    featuredImageUrl: str
    metaTitle: str
    metaDescription: str
    focusKeywords: List[str] = []
    tags: List[str] = []
    content: str
    publishDate: str
    status: str = "Published"
    viewsCount: int = 0
    sharesCount: int = 0

@router.get("/blogs")
async def get_blogs():
    return [
        {
            "id": "blog-001",
            "title": "The Connoisseur's Guide to Choosing Heritage Bridal Jewelry in 2026",
            "slug": "heritage-bridal-jewelry-buyers-guide-2026",
            "category": "Bridal & Luxury Fashion",
            "targetSuperCategory": "Luxury Jewelry",
            "authorName": "Aanya Sharma",
            "readTimeMinutes": 7,
            "wordCount": 1650,
            "featuredImageUrl": "https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=1200&q=80",
            "metaTitle": "Heritage Bridal Jewelry Buying Guide 2026 | AM5 ROYAL Luxury",
            "metaDescription": "Explore timeless uncut polki, temple gold, and certified solitaire masterworks from India's elite jewelers.",
            "focusKeywords": ["bridal jewelry 2026", "polki diamond necklace", "heritage temple gold"],
            "tags": ["Bridal", "Jewelry", "Luxury", "Wedding Trends"],
            "content": "Discover the art of curating royal heirloom ornaments...",
            "publishDate": "2026-09-02",
            "status": "Published",
            "viewsCount": 14250,
            "sharesCount": 890
        }
    ]

@router.post("/blogs")
async def save_blog(item: BlogModel):
    return {"message": "Blog Article Saved", "data": item}

@router.delete("/blogs/{blog_id}")
async def delete_blog(blog_id: str):
    return {"message": f"Blog article {blog_id} deleted successfully", "id": blog_id}

# -----------------------------------------------------------------------------
# 5. PR Articles & Media
# -----------------------------------------------------------------------------
class ArticleModel(BaseModel):
    id: Optional[str] = None
    title: str
    publicationName: str
    publicationType: str = "Press Release"
    authorByline: str
    targetAudience: str
    publicationDate: str
    canonicalUrl: str
    liveArticleUrl: str
    targetedKeywords: List[str] = []
    backlinkIncluded: bool = True
    contentSnippet: str
    status: str = "Published"
    referralTraffic: int = 0

@router.get("/articles")
async def get_articles():
    return [
        {
            "id": "art-001",
            "title": "AM5 ROYAL Redefines Elite On-Demand Services Across Indian Metros",
            "publicationName": "Forbes India Tech & Lifestyle",
            "publicationType": "Press Release",
            "authorByline": "Vikram Sethi",
            "targetAudience": "HNW Families, C-Suite Executives, Luxury Homeowners",
            "publicationDate": "2026-08-20",
            "canonicalUrl": "https://am5royal.com/press/forbes-india-spotlight",
            "liveArticleUrl": "https://www.forbesindia.com/article/special/am5-royal-luxury-marketplace",
            "targetedKeywords": ["luxury home services marketplace", "AM5 ROYAL press release"],
            "backlinkIncluded": True,
            "contentSnippet": "AM5 ROYAL is pioneering white-glove artisan curation...",
            "status": "Published",
            "referralTraffic": 8420
        }
    ]

@router.post("/articles")
async def save_article(item: ArticleModel):
    return {"message": "PR Article Saved", "data": item}

@router.delete("/articles/{article_id}")
async def delete_article(article_id: str):
    return {"message": f"Article {article_id} deleted successfully", "id": article_id}

# -----------------------------------------------------------------------------
# 6. Social Media Marketing (SMM)
# -----------------------------------------------------------------------------
class SmmPostModel(BaseModel):
    id: Optional[str] = None
    platform: str = "Instagram"
    postType: str = "Reel"
    title: str
    caption: str
    hashtags: List[str] = []
    mediaAssetUrl: str
    scheduledTime: str
    targetAudience: str
    isPaidAd: bool = False
    adBudgetInt: int = 0
    impressions: int = 0
    reach: int = 0
    likes: int = 0
    comments: int = 0
    saves: int = 0
    shares: int = 0
    linkClicks: int = 0
    spendInr: float = 0
    conversions: int = 0
    status: str = "Draft"

@router.get("/smm")
async def get_smm_posts():
    return [
        {
            "id": "smm-001",
            "platform": "Instagram",
            "postType": "Reel",
            "title": "4K Satisfying Sofa Deep Cleansing Transformation",
            "caption": "Watch our 5-stage hot-water extraction bring this Italian velvet sofa back to royal perfection ✨ #AM5Royal #LuxuryClean",
            "hashtags": ["#AM5Royal", "#DeepClean", "#LuxuryHomeServices", "#MumbaiInteriors"],
            "mediaAssetUrl": "https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=800&q=80",
            "scheduledTime": "2026-09-06T18:30:00",
            "targetAudience": "HNW Homeowners Mumbai & Bangalore 28-55",
            "isPaidAd": True,
            "adBudgetInt": 15000,
            "impressions": 284000,
            "reach": 198000,
            "likes": 18450,
            "comments": 412,
            "saves": 3890,
            "shares": 1240,
            "linkClicks": 3480,
            "spendInr": 12800,
            "conversions": 146,
            "status": "Active Live"
        }
    ]

@router.post("/smm")
async def save_smm_post(item: SmmPostModel):
    return {"message": "SMM Post Created / Updated", "data": item}

@router.delete("/smm/{smm_id}")
async def delete_smm_post(smm_id: str):
    return {"message": f"SMM post {smm_id} deleted successfully", "id": smm_id}

# -----------------------------------------------------------------------------
# 7. Google Ads Reports & GA4
# -----------------------------------------------------------------------------
class GoogleAdsModel(BaseModel):
    id: Optional[str] = None
    campaignName: str
    campaignType: str = "Performance Max"
    targetSuperCategory: str
    targetKeywords: List[str] = []
    negativeKeywords: List[str] = []
    dailyBudgetInr: float = 5000
    totalSpendInr: float = 0
    impressions: int = 0
    clicks: int = 0
    ctrPercent: float = 0
    avgCpcInr: float = 0
    conversions: int = 0
    cpaInr: float = 0
    roasRatio: float = 4.5
    status: str = "Active"
    startDate: str

@router.get("/google-ads")
async def get_google_ads_reports():
    return [
        {
            "id": "gads-001",
            "campaignName": "Search_HighIntent_Cleaning_Mumbai_PMax",
            "campaignType": "Performance Max",
            "targetSuperCategory": "Home Cleaning",
            "targetKeywords": ["best deep cleaning mumbai", "villa sanitization service", "sofa dry clean near me"],
            "negativeKeywords": ["free", "cheap", "diy"],
            "dailyBudgetInr": 5000,
            "totalSpendInr": 86400,
            "impressions": 142000,
            "clicks": 9840,
            "ctrPercent": 6.93,
            "avgCpcInr": 8.78,
            "conversions": 482,
            "cpaInr": 179.25,
            "roasRatio": 5.8,
            "status": "Active",
            "startDate": "2026-08-01"
        }
    ]

@router.post("/google-ads")
async def save_google_ads_report(item: GoogleAdsModel):
    return {"message": "Google Ads Campaign Saved", "data": item}

@router.delete("/google-ads/{ad_id}")
async def delete_google_ads_report(ad_id: str):
    return {"message": f"Google Ads campaign {ad_id} deleted successfully", "id": ad_id}

# -----------------------------------------------------------------------------
# 8. Marketing Strategies & Roadmaps
# -----------------------------------------------------------------------------
class StrategyModel(BaseModel):
    id: Optional[str] = None
    title: str
    horizonQuarter: str = "Q3 2026"
    objective: str
    targetSuperCategories: List[str] = []
    targetRegions: List[str] = []
    coreChannels: List[str] = []
    allocatedBudgetInr: float = 350000
    spentBudgetInr: float = 0
    projectedLeads: int = 500
    actualLeads: int = 0
    kpis: List[str] = []
    milestones: List[Dict[str, Any]] = []
    ownerName: str
    status: str = "Planning"

@router.get("/strategies")
async def get_strategies():
    return [
        {
            "id": "strat-001",
            "title": "Festive Wedding Season 2026 Hyper-Growth Blueprint",
            "horizonQuarter": "Q3-Q4 2026",
            "objective": "Capture 45% luxury market share in high-intent bridal styling and bridal jewelry in Mumbai & Bangalore.",
            "targetSuperCategories": ["Luxury Jewelry", "Bridal & Groom Styling"],
            "targetRegions": ["Mumbai", "Bengaluru", "Delhi NCR"],
            "coreChannels": ["Google Ads PMax", "Instagram Reels", "Vogue PR Editorial"],
            "allocatedBudgetInr": 1250000,
            "spentBudgetInr": 680000,
            "projectedLeads": 2400,
            "actualLeads": 1680,
            "kpis": ["ROAS > 5.0x", "CAC < ₹250", "Brand Recall Top-3 in Metros"],
            "milestones": [
                {"id": "m-1", "title": "Deploy high-converting 4K bridal showcase landing pages", "dueDate": "2026-07-15", "completed": True},
                {"id": "m-2", "title": "Onboard 50 certified heritage jewelry boutiques", "dueDate": "2026-08-01", "completed": True},
                {"id": "m-3", "title": "Launch sponsored celebrity influencer Instagram series", "dueDate": "2026-09-01", "completed": True},
                {"id": "m-4", "title": "Execute retargeting funnel with exclusive VIP invitation perks", "dueDate": "2026-09-25", "completed": False}
            ],
            "ownerName": "Vikram Sethi (Head of Growth)",
            "status": "Active"
        }
    ]

@router.post("/strategies")
async def save_strategy(item: StrategyModel):
    return {"message": "Growth Strategy Saved", "data": item}

@router.delete("/strategies/{strategy_id}")
async def delete_strategy(strategy_id: str):
    return {"message": f"Strategy {strategy_id} deleted successfully", "id": strategy_id}

# -----------------------------------------------------------------------------
# 9. Content Creations & Copy Studio
# -----------------------------------------------------------------------------
class ContentModel(BaseModel):
    id: Optional[str] = None
    title: str
    contentType: str
    platform: str
    targetPersona: str
    copyText: str
    visualAssetUrl: str = ""
    assignedCreator: str
    deadlineDate: str
    approvalStatus: str = "Draft"
    performanceTags: List[str] = []
    createdAt: Optional[str] = None

@router.get("/content")
async def get_content_creations():
    return [
        {
            "id": "cc-001",
            "title": "Bridal Solitaire Ring Emotional Ad Script",
            "contentType": "Short Video Script (Reel/Short)",
            "platform": "Instagram",
            "targetPersona": "Grooms & Bridal Couples (26-34)",
            "copyText": "Scene 1: Close up of handcrafted diamond setting under soft studio light...\nHook: 'When forever begins with a masterpiece that tells your story.'",
            "visualAssetUrl": "https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=800&q=80",
            "assignedCreator": "Aanya Sharma",
            "deadlineDate": "2026-09-12",
            "approvalStatus": "Approved",
            "performanceTags": ["Bridal", "Diamond", "Luxury", "Reels"],
            "createdAt": "2026-09-04"
        }
    ]

@router.post("/content")
async def save_content_creation(item: ContentModel):
    return {"message": "Content Creation Saved", "data": item}

@router.delete("/content/{content_id}")
async def delete_content_creation(content_id: str):
    return {"message": f"Content {content_id} deleted successfully", "id": content_id}

# -----------------------------------------------------------------------------
# 10. Overview & Collaterals
# -----------------------------------------------------------------------------
@router.get("/overview")
async def get_marketing_overview():
    return {
        "totalLeads": 148,
        "totalConversions": 42,
        "conversionRatePercent": 28.4,
        "totalAdSpendInr": 345000,
        "blendedRoas": 5.4,
        "blendedCpaInr": 210,
        "totalBacklinks": 34,
        "publishedBlogs": 18,
        "totalSocialReach": 1480000,
        "activeCampaigns": 8
    }

class CollateralResponse(BaseModel):
    id: int
    title: str
    collateral_type: str
    url: str
    description: Optional[str] = None
    is_active: bool

    class Config:
        orm_mode = True

@router.get("/collaterals", response_model=List[CollateralResponse])
async def list_collaterals(
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(MarketingCollateral).where(MarketingCollateral.is_active == True))
    collaterals = result.scalars().all()
    return collaterals
