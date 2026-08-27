from typing import Any
from app.repositories.base import BaseRepository
from app.models.catalog import Package, ServiceCategory, ServiceSubcategory

class PackageRepository(BaseRepository[Package, Any, Any]):
    pass

class ServiceCategoryRepository(BaseRepository[ServiceCategory, Any, Any]):
    pass

class ServiceSubcategoryRepository(BaseRepository[ServiceSubcategory, Any, Any]):
    pass

package_repo = PackageRepository(Package)
category_repo = ServiceCategoryRepository(ServiceCategory)
subcategory_repo = ServiceSubcategoryRepository(ServiceSubcategory)
