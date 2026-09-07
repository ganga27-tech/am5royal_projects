from pydantic import BaseModel, ConfigDict
from typing import List, Optional

class VendorMainCategoryResponse(BaseModel):
    id: int
    name: str
    icon_url: Optional[str] = None
    has_subcategories: bool
    
    model_config = ConfigDict(from_attributes=True)

class VendorSubCategoryResponse(BaseModel):
    id: int
    name: str
    icon_url: Optional[str] = None
    is_selected: bool = False
    
    model_config = ConfigDict(from_attributes=True)

class VendorServiceResponse(BaseModel):
    id: int
    name: str
    price: Optional[float] = None
    main_category_id: Optional[int] = None
    sub_category_id: Optional[int] = None
    image_url: Optional[str] = None
    
    model_config = ConfigDict(from_attributes=True)

class BatchServicesRequest(BaseModel):
    sub_category_ids: List[int]

class MediaItem(BaseModel):
    media_url: str
    media_type: str  # 'image' or 'video'

class VendorServiceAddRequest(BaseModel):
    service_id: int
    amount: float
    discounted_amount: Optional[float] = None
    is_negotiable: bool = False
    media: Optional[List[MediaItem]] = []


class VendorCategoryAddRequest(BaseModel):
    main_category_id: int
    sub_category_ids: List[int]


class VendorCatalogServiceItem(BaseModel):
    id: int
    service_id: Optional[int] = None
    title: str
    description: Optional[str] = None
    price: float
    discounted_price: Optional[float] = None
    negotiable: bool = False
    main_category_id: int
    sub_category_id: int
    sub_category_name: str
    is_active: bool = True
    image_url: Optional[str] = None
    media: List[MediaItem] = []


class VendorCatalogSubCategoryGroup(BaseModel):
    sub_category_id: int
    sub_category_name: str
    main_category_id: int
    services: List[VendorCatalogServiceItem] = []


class VendorCatalogMainCategoryGroup(BaseModel):
    main_category_id: int
    main_category_name: str
    icon_url: Optional[str] = None
    sub_categories: List[VendorCatalogSubCategoryGroup] = []


class VendorCatalogResponse(BaseModel):
    categories: List[VendorCatalogMainCategoryGroup] = []
    total_services: int = 0
    total_active_services: int = 0
