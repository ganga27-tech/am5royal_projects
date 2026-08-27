from sqlalchemy import Column, String, Integer, Boolean, ForeignKey, Text, JSON, Numeric, DateTime, BigInteger
from sqlalchemy.orm import relationship
from app.db.base_class import Base
import datetime

class ServiceCategory(Base):
    __tablename__ = "main_categories"
    __mapper_args__ = {"exclude_properties": ["updated_at"]}

    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String, nullable=False)
    category_type = Column(String)
    icon = Column(String)
    is_active = Column(Boolean, default=True)
    super_category_id = Column(BigInteger)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    subcategories = relationship("ServiceSubcategory", back_populates="category")

    @property
    def icon_url(self):
        return self.icon

class ServiceSubcategory(Base):
    __tablename__ = "sub_categories"
    __mapper_args__ = {"exclude_properties": ["updated_at"]}

    id = Column(BigInteger, primary_key=True, index=True)
    main_category_id = Column(BigInteger, ForeignKey("main_categories.id"))
    name = Column(String, nullable=False)
    category_type = Column(String, nullable=True) # E.g., 'A' or 'B'
    description = Column(Text)
    icon_url = Column(String)
    ai_keywords = Column(Text)
    is_active = Column(Boolean, default=True)
    sort_order = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    category = relationship("ServiceCategory", back_populates="subcategories", foreign_keys=[main_category_id])
    packages = relationship("Package", back_populates="subcategory")

    @property
    def category_id(self):
        return self.main_category_id

class Package(Base):
    __tablename__ = "packages"

    id = Column(BigInteger, primary_key=True, index=True)
    subcategory_id = Column(BigInteger, ForeignKey("sub_categories.id"))
    name = Column(String, nullable=False)
    description = Column(Text)
    price = Column(Numeric(10, 2))
    is_active = Column(Boolean, default=True)
    
    # Extra fields for rich service view
    rating = Column(Numeric(2, 1), default=0.0)
    reviews_count = Column(Integer, default=0)
    duration_minutes = Column(Integer, default=0)
    mrp = Column(Numeric(10, 2))
    currency = Column(String, default="₹")
    hero_image = Column(String)
    detail_info = Column(Text)
    
    # Metadata for dynamic inclusions/exclusions (fallback)
    meta_data = Column(JSON) # {includes: [], excludes: [], precautions: []}
    
    subcategory = relationship("ServiceSubcategory", back_populates="packages")
    sub_packages = relationship("SubPackage", back_populates="package", cascade="all, delete-orphan")
    
    # New relationships
    benefits = relationship("PackageBenefit", back_populates="package", cascade="all, delete-orphan")
    inclusion_steps = relationship("PackageInclusionStep", back_populates="package", cascade="all, delete-orphan")
    inclusion_bullets = relationship("PackageInclusionBullet", back_populates="package", cascade="all, delete-orphan")
    exclusion_steps = relationship("PackageExclusionStep", back_populates="package", cascade="all, delete-orphan")
    exclusion_bullets = relationship("PackageExclusionBullet", back_populates="package", cascade="all, delete-orphan")
    precautions = relationship("PackagePrecaution", back_populates="package", cascade="all, delete-orphan")
    brands = relationship("PackageBrand", back_populates="package", cascade="all, delete-orphan")
    safety = relationship("PackageSafety", back_populates="package", cascade="all, delete-orphan")
    sections = relationship("PackageSection", back_populates="package", cascade="all, delete-orphan")
    faqs = relationship("FAQ", primaryjoin="Package.id == FAQ.package_id", foreign_keys="[FAQ.package_id]")

class SubPackage(Base):
    __tablename__ = "sub_packages"

    id = Column(BigInteger, primary_key=True, index=True)
    package_id = Column(BigInteger, ForeignKey("packages.id"))
    name = Column(String, nullable=False)
    price = Column(Numeric(10, 2))
    is_active = Column(Boolean, default=True)
    
    package = relationship("Package", back_populates="sub_packages")

class PackageBenefit(Base):
    __tablename__ = "package_benefits"

    id = Column(BigInteger, primary_key=True, index=True)
    package_id = Column(BigInteger, ForeignKey("packages.id", ondelete="CASCADE"), nullable=False)
    label = Column(String, nullable=False)
    emoji = Column(String)

    package = relationship("Package", back_populates="benefits")

class PackageInclusionStep(Base):
    __tablename__ = "package_inclusion_steps"

    id = Column(BigInteger, primary_key=True, index=True)
    package_id = Column(BigInteger, ForeignKey("packages.id", ondelete="CASCADE"), nullable=False)
    title = Column(String, nullable=False)
    image_url = Column(String)

    package = relationship("Package", back_populates="inclusion_steps")

class PackageInclusionBullet(Base):
    __tablename__ = "package_inclusion_bullets"

    id = Column(BigInteger, primary_key=True, index=True)
    package_id = Column(BigInteger, ForeignKey("packages.id", ondelete="CASCADE"), nullable=False)
    text = Column(Text, nullable=False)

    package = relationship("Package", back_populates="inclusion_bullets")

class PackageExclusionStep(Base):
    __tablename__ = "package_exclusion_steps"

    id = Column(BigInteger, primary_key=True, index=True)
    package_id = Column(BigInteger, ForeignKey("packages.id", ondelete="CASCADE"), nullable=False)
    title = Column(String, nullable=False)
    image_url = Column(String)

    package = relationship("Package", back_populates="exclusion_steps")

class PackageExclusionBullet(Base):
    __tablename__ = "package_exclusion_bullets"

    id = Column(BigInteger, primary_key=True, index=True)
    package_id = Column(BigInteger, ForeignKey("packages.id", ondelete="CASCADE"), nullable=False)
    text = Column(Text, nullable=False)

    package = relationship("Package", back_populates="exclusion_bullets")

class PackagePrecaution(Base):
    __tablename__ = "package_precautions"

    id = Column(BigInteger, primary_key=True, index=True)
    package_id = Column(BigInteger, ForeignKey("packages.id", ondelete="CASCADE"), nullable=False)
    product = Column(String, nullable=False)
    status = Column(String, nullable=False) # e.g. recommended / avoid

    package = relationship("Package", back_populates="precautions")

class PackageBrand(Base):
    __tablename__ = "package_brands"

    id = Column(BigInteger, primary_key=True, index=True)
    package_id = Column(BigInteger, ForeignKey("packages.id", ondelete="CASCADE"), nullable=False)
    name = Column(String, nullable=False)
    image_url = Column(String)

    package = relationship("Package", back_populates="brands")

class PackageSafety(Base):
    __tablename__ = "package_safety"

    id = Column(BigInteger, primary_key=True, index=True)
    package_id = Column(BigInteger, ForeignKey("packages.id", ondelete="CASCADE"), nullable=False)
    title = Column(String, nullable=False)
    description = Column(Text)
    image_url = Column(String)

    package = relationship("Package", back_populates="safety")

class PackageSection(Base):
    __tablename__ = "package_sections"

    id = Column(BigInteger, primary_key=True, index=True)
    package_id = Column(BigInteger, ForeignKey("packages.id", ondelete="CASCADE"), nullable=False)
    section_name = Column(String, nullable=False)
    sort_order = Column(Integer, default=0)

    package = relationship("Package", back_populates="sections")

class Service(Base):
    __tablename__ = "services"

    id = Column(BigInteger, primary_key=True, index=True)
    main_category_id = Column(BigInteger, ForeignKey("main_categories.id"), nullable=True)
    sub_category_id = Column(BigInteger, ForeignKey("sub_categories.id"), nullable=True)
    name = Column(String, nullable=False)
    image_url = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    main_category = relationship("ServiceCategory")
    sub_category = relationship("ServiceSubcategory")
