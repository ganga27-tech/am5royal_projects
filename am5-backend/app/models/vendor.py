from sqlalchemy import Column, String, Integer, Boolean, ForeignKey, Text, Numeric, DateTime, BigInteger, Time, JSON
from sqlalchemy.orm import relationship
from app.db.base_class import Base

class Vendor(Base):
    __tablename__ = "vendors"
    __mapper_args__ = {"exclude_properties": ["updated_at"]}

    id = Column(BigInteger, primary_key=True, index=True)
    user_id = Column(BigInteger, index=True)
    onboarded_by_employee_id = Column(BigInteger, ForeignKey("employees.id"), nullable=True)
    lead_source = Column(String(50), default="company")  # 'direct_telecaller', 'company', 'company_website', 'company_mobile', 'freelancer'
    freelancer_id = Column(BigInteger, ForeignKey("freelancers.id"), nullable=True)
    assigned_telecaller_id = Column(BigInteger, ForeignKey("employees.id"), nullable=True)
    first_name = Column(String)
    last_name = Column(String)
    father_name = Column(String)
    email = Column(String, nullable=True)
    mobile = Column(String, nullable=True)
    alternative_number = Column(String, nullable=True)
    business_name = Column(String)
    aadhaar_number = Column(String)
    aadhaar_verified = Column(Boolean, default=False)
    address = Column(Text)
    street = Column(String, nullable=True)
    city = Column(String)
    district = Column(String, nullable=True)
    state = Column(String)
    pincode = Column(String)
    gst_number = Column(String, nullable=True)
    pan_number = Column(String, nullable=True)
    usc_number = Column(String, nullable=True)
    msme_number = Column(String, nullable=True)
    govt_auth_doc_number = Column(String, nullable=True)
    current_bill_number = Column(String, nullable=True)
    latitude = Column(Numeric(9, 6))
    longitude = Column(Numeric(9, 6))
    is_premium = Column(Boolean, default=False)
    avg_rating = Column(Numeric(3, 2), default=0.0)
    total_reviews = Column(Integer, default=0)
    service_radius_km = Column(Integer, default=10)
    profile_image = Column(Text)
    status = Column(String, default="active")
    telecaller_services_updated = Column(Boolean, default=False)

    background_banner = Column(Text, nullable=True)
    business_description = Column(Text, nullable=True)
    business_highlights = Column(JSON, nullable=True)
    about_business = Column(Text, nullable=True)
    alternative_contact_number = Column(String, nullable=True)
    feedback = Column(Text, nullable=True)
    payment_info = Column(String(100), nullable=True)

    # vendor_categories = relationship("VendorSubCategory", back_populates="vendor")

    @property
    def photo_url(self):
        return self.profile_image

    @property
    def operating_city(self):
        return self.city
class VendorSubCategory(Base):
    __tablename__ = "vendor_sub_categories"
    __mapper_args__ = {"exclude_properties": ["updated_at"]}

    id = Column(BigInteger, primary_key=True, index=True)
    vendor_id = Column(BigInteger, ForeignKey("vendors.id"), index=True)
    main_category_id = Column(BigInteger, ForeignKey("main_categories.id"))
    sub_category_id = Column(BigInteger, ForeignKey("sub_categories.id"))

    # vendor = relationship("Vendor", back_populates="vendor_categories")
    # main_category = relationship("ServiceCategory")
    # sub_category = relationship("ServiceSubcategory")

class VendorDocument(Base):
    __tablename__ = "vendor_documents"
    __mapper_args__ = {"exclude_properties": ["updated_at"]}

    id = Column(BigInteger, primary_key=True, index=True)
    vendor_id = Column(BigInteger, ForeignKey("vendors.id"), index=True)
    document_type = Column(String(100))
    document_url = Column(Text)
    verification_status = Column(String(50), default="pending")

class VendorAvailability(Base):
    __tablename__ = "vendor_availability"
    __mapper_args__ = {"exclude_properties": ["created_at", "updated_at"]}

    id = Column(BigInteger, primary_key=True, index=True)
    vendor_id = Column(BigInteger, ForeignKey("vendors.id"), index=True)
    day_of_week = Column(Integer)
    start_time = Column(Time)
    end_time = Column(Time)
    is_available = Column(Boolean, default=True)

class VendorService(Base):
    __tablename__ = "vendor_services"
    
    id = Column(BigInteger, primary_key=True, index=True)
    vendor_id = Column(BigInteger, ForeignKey("vendors.id"), index=True)
    main_category_id = Column(BigInteger, ForeignKey("main_categories.id"))
    sub_category_id = Column(BigInteger, ForeignKey("sub_categories.id"))
    service_id = Column(BigInteger, ForeignKey("services.id"), nullable=True)
    title = Column(String(255))
    description = Column(Text)
    price = Column(Numeric(10, 2))
    discounted_price = Column(Numeric(10, 2))
    negotiable = Column(Boolean, default=False)
    booking_type = Column(String(50))
    is_active = Column(Boolean, default=True)

class VendorServiceMedia(Base):
    __tablename__ = "vendor_service_media"
    __mapper_args__ = {"exclude_properties": ["updated_at"]}

    id = Column(BigInteger, primary_key=True, index=True)
    vendor_service_id = Column(BigInteger, ForeignKey("vendor_services.id"), index=True)
    media_type = Column(String(50))
    media_url = Column(Text)
