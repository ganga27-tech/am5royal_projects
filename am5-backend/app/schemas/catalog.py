from typing import List, Optional, Union
from pydantic import BaseModel, ConfigDict
from datetime import datetime
from decimal import Decimal

class ServiceSubcategoryBase(BaseModel):
    name: str
    description: Optional[str] = None
    icon_url: Optional[str] = None
    is_active: bool = True
    sort_order: int = 0

class ServiceSubcategory(ServiceSubcategoryBase):
    id: int
    category_id: int
    
    model_config = ConfigDict(from_attributes=True)

class ServiceCategoryBase(BaseModel):
    name: str
    description: Optional[str] = None
    icon_url: Optional[str] = None
    is_active: bool = True
    sort_order: int = 0
    is_pest_control: bool = False

class ServiceCategory(ServiceCategoryBase):
    id: int
    subcategories: List[ServiceSubcategory] = []
    
    model_config = ConfigDict(from_attributes=True)

class SubPackageBase(BaseModel):
    name: str
    price: Decimal
    is_active: bool = True

class SubPackage(SubPackageBase):
    id: int
    package_id: int
    
    model_config = ConfigDict(from_attributes=True)

from pydantic import BaseModel, ConfigDict, model_validator

class PackageBenefitSchema(BaseModel):
    label: str
    emoji: Optional[str] = None
    model_config = ConfigDict(from_attributes=True)

class StepSchema(BaseModel):
    title: str
    image: Optional[str] = None
    model_config = ConfigDict(from_attributes=True)

class PrecautionSchema(BaseModel):
    product: str
    status: str
    model_config = ConfigDict(from_attributes=True)

class BrandSchema(BaseModel):
    name: str
    image: Optional[str] = None
    model_config = ConfigDict(from_attributes=True)

class SafetySchema(BaseModel):
    title: str
    description: Optional[str] = None
    image: Optional[str] = None
    model_config = ConfigDict(from_attributes=True)

class IncludedSchema(BaseModel):
    steps: List[StepSchema] = []
    bullets: List[str] = []

class ExcludedSchema(BaseModel):
    steps: List[StepSchema] = []
    bullets: List[str] = []

class PackageBase(BaseModel):
    name: str
    description: Optional[str] = None
    price: Decimal
    is_active: bool = True
    meta_data: Optional[dict] = None

class FAQSchema(BaseModel):
    q: str
    a: str
    model_config = ConfigDict(from_attributes=True)

class Package(BaseModel):
    id: str
    subcategory_id: int
    title: str
    rating: float
    reviewsCount: int
    durationMinutes: int
    mrp: Decimal
    price: Decimal
    currency: str
    heroImage: Optional[str] = None
    detailInfo: Optional[str] = None
    benefits: List[PackageBenefitSchema] = []
    included: IncludedSchema
    excluded: ExcludedSchema
    afterPrecautions: List[PrecautionSchema] = []
    brands: List[BrandSchema] = []
    safety: List[SafetySchema] = []
    sections: List[str] = []
    faqs: List[FAQSchema] = []
    sub_packages: List[SubPackage] = []
    is_active: bool = True
    
    model_config = ConfigDict(from_attributes=True)

    @model_validator(mode='before')
    @classmethod
    def format_package(cls, data):
        if isinstance(data, dict):
            return data
        
        # Format the relational tables into nested structure
        included_steps = [
            {"title": step.title, "image": step.image_url}
            for step in getattr(data, "inclusion_steps", [])
        ]
        included_bullets = [
            bullet.text for bullet in getattr(data, "inclusion_bullets", [])
        ]
        
        excluded_steps = [
            {"title": step.title, "image": step.image_url}
            for step in getattr(data, "exclusion_steps", [])
        ]
        excluded_bullets = [
            bullet.text for bullet in getattr(data, "exclusion_bullets", [])
        ]
        
        after_precautions = [
            {"product": prec.product, "status": prec.status}
            for prec in getattr(data, "precautions", [])
        ]
        
        brands = [
            {"name": brand.name, "image": brand.image_url}
            for brand in getattr(data, "brands", [])
        ]
        
        safety = [
            {"title": s.title, "description": s.description, "image": s.image_url}
            for s in getattr(data, "safety", [])
        ]
        
        sections = [
            sec.section_name for sec in sorted(getattr(data, "sections", []), key=lambda x: x.sort_order)
        ]
        if not sections and getattr(data, "sections", []):
            sections = [sec.section_name for sec in getattr(data, "sections", [])]
            
        benefits = [
            {"label": b.label, "emoji": b.emoji}
            for b in getattr(data, "benefits", [])
        ]

        faqs = [
            {"q": faq.question, "a": faq.answer}
            for faq in getattr(data, "faqs", []) if faq.active
        ]
        
        id_str = f"svc_{data.name.lower().strip().replace(' ', '_').replace('&', 'and')}" if data.name else str(data.id)
        
        return {
            "id": id_str,
            "subcategory_id": data.subcategory_id,
            "title": data.name,
            "rating": float(data.rating) if data.rating else 0.0,
            "reviewsCount": data.reviews_count or 0,
            "durationMinutes": data.duration_minutes or 0,
            "mrp": data.mrp or data.price,
            "price": data.price,
            "currency": data.currency or "₹",
            "heroImage": data.hero_image,
            "detailInfo": data.detail_info or data.description,
            "benefits": benefits,
            "included": {"steps": included_steps, "bullets": included_bullets},
            "excluded": {"steps": excluded_steps, "bullets": excluded_bullets},
            "afterPrecautions": after_precautions,
            "brands": brands,
            "safety": safety,
            "sections": sections,
            "faqs": faqs,
            "sub_packages": getattr(data, "sub_packages", []),
            "is_active": data.is_active
        }

class VendorCategory(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    icon_url: Optional[str] = None
    is_active: bool = True
    sort_order: int = 0
    is_pest_control: bool = False
    
    model_config = ConfigDict(from_attributes=True)

class VendorServiceDetail(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    icon_url: Optional[str] = None
    category_id: int
    price_range_min: Optional[Decimal] = None
    price_range_max: Optional[Decimal] = None
    pricing_type: Optional[str] = None
    packages: List[Package] = []
    
    model_config = ConfigDict(from_attributes=True)

class VendorBasicInfo(BaseModel):
    id: int
    business_name: str
    business_description: Optional[str] = None
    years_of_experience: Optional[int] = 0
    avg_rating: Optional[float] = 0.0
    total_reviews: Optional[int] = 0
    is_verified: bool = False
    photo_url: Optional[str] = None
    banner_url: Optional[str] = None
    approx_visit_charge: Optional[Decimal] = None
    discount: Optional[int] = 0
    operating_city: Optional[str] = None
    distance_km: Optional[float] = None
    leads_consumed: Optional[int] = None
    service_price: Optional[float] = None
    service_negotiable: Optional[bool] = False
    
    model_config = ConfigDict(from_attributes=True)

class VendorServiceOffering(BaseModel):
    id: int
    service_id: Optional[int] = None
    title: str
    description: Optional[str] = None
    price: float
    discounted_price: Optional[float] = None
    negotiable: bool = False
    main_category_id: int
    sub_category_id: int
    sub_category_name: Optional[str] = None
    image_url: Optional[str] = None

class ServiceResponse(BaseModel):
    id: int
    main_category_id: Optional[int] = None
    sub_category_id: Optional[int] = None
    name: str
    image_url: Optional[str] = None
    is_active: bool
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)

class CategoryChildrenResponse(BaseModel):
    is_subcategory: bool
    data: List[Union[ServiceSubcategory, ServiceResponse]]

