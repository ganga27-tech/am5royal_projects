import asyncio
from app.db.session import AsyncSessionLocal, engine
from app.db.base_class import Base
# Import all models to ensure they are registered with Base metadata
import app.models
from app.models.user_location import City
from app.models.catalog import (
    ServiceCategory, ServiceSubcategory, Package,
    PackageBenefit, PackageInclusionStep, PackageInclusionBullet,
    PackageExclusionStep, PackageExclusionBullet, PackagePrecaution,
    PackageBrand, PackageSafety, PackageSection
)
from app.models.engagement import FAQ

async def seed_data():
    # Automatically create tables in the database if they don't exist
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    async with AsyncSessionLocal() as db:
        # Add Cities
        dubai = City(name="Dubai", state="Dubai", code="DXB")
        db.add(dubai)
        await db.flush()

        # Add Category
        beauty_spa = ServiceCategory(name="Beauty & Spa", sort_order=1, lead_category_code="B")
        db.add(beauty_spa)
        await db.flush()

        # Add Subcategory
        facials = ServiceSubcategory(category_id=beauty_spa.id, name="Facials", lead_category_code="F")
        db.add(facials)
        await db.flush()

        # Add Package
        facial_pkg = Package(
            subcategory_id=facials.id,
            name="Skin Lightening Facial",
            description="Deep cleanse, hydrate, and restore skin's natural glow.",
            price=699.0,
            mrp=999.0,
            rating=4.6,
            reviews_count=415,
            duration_minutes=60,
            currency="₹",
            hero_image="https://images.unsplash.com/photo-1600423115367-84a1a9d5d1a9?w=1600&q=80&fm=webp",
            detail_info="Pamper your skin with our rejuvenating beauty facial service, designed to deeply cleanse, hydrate, and restore your skin’s natural glow. This refreshing facial treatment is tailored to suit all skin types and provides a refreshing break from daily stress and pollution.",
            is_active=True
        )
        db.add(facial_pkg)
        await db.flush()

        # Add Benefits
        benefits_data = [
            {"label": "Radiant glow", "emoji": "✨"},
            {"label": "Hydrated Skin", "emoji": "💧"},
            {"label": "Firmness", "emoji": "🧖"},
            {"label": "Clear Pores", "emoji": "🫧"}
        ]
        for b in benefits_data:
            db.add(PackageBenefit(package_id=facial_pkg.id, label=b["label"], emoji=b["emoji"]))

        # Add Included Steps
        inc_steps = [
            {"title": "Apply on damp face and neck", "image_url": "https://picsum.photos/seed/inc1/640/480.webp"},
            {"title": "Apply 4 to 5 drops evenly", "image_url": "https://picsum.photos/seed/inc2/640/480.webp"},
            {"title": "Massage face and neck", "image_url": "https://picsum.photos/seed/inc3/640/480.webp"},
            {"title": "Apply a thin even layer", "image_url": "https://picsum.photos/seed/inc4/640/480.webp"},
            {"title": "Apply evenly to hydrate", "image_url": "https://picsum.photos/seed/inc5/640/480.webp"},
            {"title": "Apply evenly as the final step", "image_url": "https://picsum.photos/seed/inc6/640/480.webp"}
        ]
        for step in inc_steps:
            db.add(PackageInclusionStep(package_id=facial_pkg.id, title=step["title"], image_url=step["image_url"]))

        # Add Included Bullets
        inc_bullets = [
            "Deep cleansing of face and neck",
            "Exfoliation to remove dead skin cells",
            "Steam treatment to open up pores",
            "Blackhead and whitehead removal",
            "Application of face pack or mask (based on skin type)"
        ]
        for bullet in inc_bullets:
            db.add(PackageInclusionBullet(package_id=facial_pkg.id, text=bullet))

        # Add Excluded Steps
        ex_steps = [
            {"title": "Bleach application", "image_url": "https://picsum.photos/seed/ex1/640/480.webp"},
            {"title": "Derma/chemical peels", "image_url": "https://picsum.photos/seed/ex2/640/480.webp"},
            {"title": "Bridal/advanced therapies", "image_url": "https://picsum.photos/seed/ex3/640/480.webp"},
            {"title": "Any add-ons not listed", "image_url": "https://picsum.photos/seed/ex4/640/480.webp"}
        ]
        for step in ex_steps:
            db.add(PackageExclusionStep(package_id=facial_pkg.id, title=step["title"], image_url=step["image_url"]))

        # Add Excluded Bullets
        ex_bullets = [
            "Bleach, detan, or skin lightening treatments",
            "Bridal or advanced skin therapies",
            "Derma or chemical-based facial treatments",
            "Any add-on treatments not mentioned in inclusions"
        ]
        for bullet in ex_bullets:
            db.add(PackageExclusionBullet(package_id=facial_pkg.id, text=bullet))

        # Add Precautions
        precautions_data = [
            {"product": "Sunscreen", "status": "recommended"},
            {"product": "No makeup", "status": "avoid"},
            {"product": "Hydration", "status": "recommended"}
        ]
        for p in precautions_data:
            db.add(PackagePrecaution(package_id=facial_pkg.id, product=p["product"], status=p["status"]))

        # Add Brands
        brands_data = [
            {"name": "V L C C", "image_url": "https://picsum.photos/seed/brand1/1200/700.webp"},
            {"name": "S A R A", "image_url": "https://picsum.photos/seed/brand2/1200/700.webp"},
            {"name": "R A A G A", "image_url": "https://picsum.photos/seed/brand3/1200/700.webp"},
            {"name": "A R O M A  M A G I C", "image_url": "https://picsum.photos/seed/brand4/1200/700.webp"}
        ]
        for b in brands_data:
            db.add(PackageBrand(package_id=facial_pkg.id, name=b["name"], image_url=b["image_url"]))

        # Add Safety
        safety_data = [
            {
                "title": "Safety Kit",
                "description": "Our trained pros prioritize safety, maintain sterile service, working carefully with a comprehensive kit.",
                "image_url": "https://picsum.photos/seed/safety1/800/500.webp"
            },
            {
                "title": "Facial Kit",
                "description": "Our make-up/skin pros ensure hygiene, use sealed products, and leave no complex residue.",
                "image_url": "https://picsum.photos/seed/safety2/800/500.webp"
            }
        ]
        for s in safety_data:
            db.add(PackageSafety(package_id=facial_pkg.id, title=s["title"], description=s["description"], image_url=s["image_url"]))

        # Add Sections
        sections_data = [
            "hero", "pricing", "detail", "assurance", "note", "benefits",
            "included", "excluded", "precautions", "brands", "safety", "faqs"
        ]
        for idx, sec in enumerate(sections_data):
            db.add(PackageSection(package_id=facial_pkg.id, section_name=sec, sort_order=idx))

        # Add FAQs
        faqs_data = [
            {
                "q": "Is this facial suitable for all skin types?",
                "a": "Yes. The therapist tailors products for your skin type. Sensitive skin options are available."
            },
            {
                "q": "How long does the facial session take?",
                "a": "Approximately 60 minutes including consultation and post-care guidance."
            }
        ]
        for faq in faqs_data:
            db.add(FAQ(package_id=facial_pkg.id, question=faq["q"], answer=faq["a"], category="Facial", active=True))

        await db.commit()
        print("Database seeded successfully with rich facial package data!")

if __name__ == "__main__":
    asyncio.run(seed_data())
