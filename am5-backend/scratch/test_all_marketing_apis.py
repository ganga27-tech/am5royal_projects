import requests
import json
import sys

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

BASE_URL = "http://76.13.245.174:8000/api/v1/marketing"

def test_endpoint(method, path, data=None, expected_status=200):
    url = f"{BASE_URL}{path}"
    try:
        if method == "GET":
            res = requests.get(url, timeout=10)
        elif method == "POST":
            res = requests.post(url, json=data, timeout=10)
        elif method == "PUT":
            res = requests.put(url, json=data, timeout=10)
        elif method == "DELETE":
            res = requests.delete(url, timeout=10)
        else:
            raise ValueError(f"Unknown method {method}")
        
        status_ok = (res.status_code == expected_status)
        symbol = "✅" if status_ok else "❌"
        print(f"{symbol} [{method}] {path} -> HTTP {res.status_code}")
        if not status_ok:
            print(f"   Error: {res.text[:200]}")
        return status_ok, res.json() if res.headers.get("content-type", "").startswith("application/json") else res.text
    except Exception as e:
        print(f"❌ [{method}] {path} -> Exception: {e}")
        return False, None

def run_all_tests():
    print("=================================================================")
    print("AM5 ROYAL • Testing All Marketing & Delete API Endpoints")
    print("=================================================================")
    results = []

    # 1. Health & Overview
    print("\n--- 1. Marketing Overview & Stats ---")
    ok, data = test_endpoint("GET", "/overview")
    results.append(("GET /overview", ok))

    # 2. Leads CRUD
    print("\n--- 2. Marketing Leads CRUD ---")
    lead_payload = {
        "shop_name": "Royal Gems Diamond Studio",
        "contact_person": "Kavita Rao",
        "phone_number": "+91 98200 11223",
        "address": "Bandra West, Mumbai",
        "notes": "Interested in Premium Tier listing on AM5",
        "deal_value": 75000,
        "source": "Instagram Ad",
        "target_category": "Jewelry"
    }
    ok_create, created_lead = test_endpoint("POST", "/leads", data=lead_payload)
    results.append(("POST /leads (Create)", ok_create))

    lead_id = None
    if ok_create and isinstance(created_lead, dict):
        lead_id = created_lead.get("id")
        print(f"   Created Lead ID: {lead_id}")

    ok_list, leads_list = test_endpoint("GET", "/leads")
    results.append(("GET /leads (List)", ok_list))

    if lead_id:
        ok_put, updated_lead = test_endpoint("PUT", f"/leads/{lead_id}/status", data={"status": "QUALIFIED"})
        results.append(("PUT /leads/{id}/status (Update)", ok_put))

        ok_del, del_res = test_endpoint("DELETE", f"/leads/{lead_id}")
        results.append(("DELETE /leads/{id} (Delete)", ok_del))

    # 3. SEO (On-Page)
    print("\n--- 3. SEO On-Page CRUD ---")
    ok_seo_get, _ = test_endpoint("GET", "/seo/on-page")
    results.append(("GET /seo/on-page", ok_seo_get))

    seo_payload = {
        "id": "seo-test-99",
        "pageUrl": "https://am5royal.com/services/test",
        "pageTitle": "Test SEO Page",
        "metaTitle": "Test Meta Title",
        "metaDescription": "Test Meta Description for AM5",
        "primaryKeyword": "luxury home care",
        "secondaryKeywords": ["villa care"],
        "canonicalUrl": "https://am5royal.com/services/test",
        "h1Tag": "Elite Luxury Services",
        "h2Tags": ["Why Choose Us"],
        "imageAltCount": 5,
        "missingAltCount": 0,
        "wordCount": 1200,
        "keywordDensity": 1.5,
        "schemaType": "LocalBusiness",
        "robotsDirective": "index, follow",
        "coreWebVitalsScore": 95,
        "status": "Optimized"
    }
    ok_seo_post, _ = test_endpoint("POST", "/seo/on-page", data=seo_payload)
    results.append(("POST /seo/on-page", ok_seo_post))

    ok_seo_del, _ = test_endpoint("DELETE", "/seo/on-page/seo-test-99")
    results.append(("DELETE /seo/on-page/{id}", ok_seo_del))

    # 4. Backlinks
    print("\n--- 4. Backlinks CRUD ---")
    ok_bl_get, _ = test_endpoint("GET", "/backlinks")
    results.append(("GET /backlinks", ok_bl_get))

    bl_payload = {
        "id": "bl-test-99",
        "targetUrl": "https://am5royal.com",
        "referringDomain": "elle.in",
        "anchorText": "AM5 Royal Wedding Concierge",
        "linkType": "DoFollow",
        "domainRating": 80,
        "spamScore": 1,
        "liveVerifiedUrl": "https://elle.in/bridal-couture",
        "acquisitionDate": "2026-09-08",
        "costInr": 25000,
        "outreachContact": "pr@elle.in",
        "status": "Live"
    }
    ok_bl_post, _ = test_endpoint("POST", "/backlinks", data=bl_payload)
    results.append(("POST /backlinks", ok_bl_post))

    ok_bl_del, _ = test_endpoint("DELETE", "/backlinks/bl-test-99")
    results.append(("DELETE /backlinks/{id}", ok_bl_del))

    # 5. Blogs
    print("\n--- 5. Blogs CRUD ---")
    ok_blog_get, _ = test_endpoint("GET", "/blogs")
    results.append(("GET /blogs", ok_blog_get))

    blog_payload = {
        "id": "blog-test-99",
        "title": "5 Signs Your Velvet Upholstery Needs Professional Sanitization",
        "slug": "velvet-upholstery-sanitization-guide",
        "category": "Home Decor Care",
        "targetSuperCategory": "Home Services",
        "authorName": "Aanya Sharma",
        "readTimeMinutes": 4,
        "wordCount": 950,
        "featuredImageUrl": "https://images.unsplash.com/photo-1581578731548-c64695cc6952",
        "metaTitle": "Velvet Upholstery Care | AM5 ROYAL",
        "metaDescription": "Discover how our hot-water extraction preserves delicate upholstery fabrics.",
        "focusKeywords": ["velvet sofa cleaning", "upholstery care"],
        "tags": ["Cleaning", "Velvet", "Luxury Care"],
        "content": "Velvet is among the most luxurious yet delicate fabrics...",
        "publishDate": "2026-09-08",
        "status": "Published",
        "viewsCount": 120,
        "sharesCount": 15
    }
    ok_blog_post, _ = test_endpoint("POST", "/blogs", data=blog_payload)
    results.append(("POST /blogs", ok_blog_post))

    ok_blog_del, _ = test_endpoint("DELETE", "/blogs/blog-test-99")
    results.append(("DELETE /blogs/{id}", ok_blog_del))

    # 6. Articles & PR
    print("\n--- 6. PR Articles CRUD ---")
    ok_art_get, _ = test_endpoint("GET", "/articles")
    results.append(("GET /articles", ok_art_get))

    art_payload = {
        "id": "art-test-99",
        "title": "How AM5 ROYAL is Setting Benchmark in Ultra-Luxury Home Care",
        "publicationName": "Mint Lounge",
        "publicationType": "Guest Post",
        "authorByline": "Vikram Sethi",
        "targetAudience": "HNW Families",
        "publicationDate": "2026-09-08",
        "canonicalUrl": "https://am5royal.com/press/mint",
        "liveArticleUrl": "https://livemint.com/am5",
        "targetedKeywords": ["luxury home care"],
        "backlinkIncluded": True,
        "contentSnippet": "India's burgeoning luxury home services segment...",
        "status": "Published",
        "referralTraffic": 450
    }
    ok_art_post, _ = test_endpoint("POST", "/articles", data=art_payload)
    results.append(("POST /articles", ok_art_post))

    ok_art_del, _ = test_endpoint("DELETE", "/articles/art-test-99")
    results.append(("DELETE /articles/{id}", ok_art_del))

    # 7. SMM
    print("\n--- 7. SMM (Social Media) CRUD ---")
    ok_smm_get, _ = test_endpoint("GET", "/smm")
    results.append(("GET /smm", ok_smm_get))

    smm_payload = {
        "id": "smm-test-99",
        "platform": "Instagram",
        "postType": "Carousel",
        "title": "3 Steps to Preserve Heritage Gold",
        "caption": "Your heirloom jewelry deserves royal preservation ✨",
        "hashtags": ["#AM5Royal", "#HeritageGold"],
        "mediaAssetUrl": "https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f",
        "scheduledTime": "2026-09-09T18:00:00",
        "targetAudience": "Luxury Shoppers",
        "isPaidAd": False,
        "status": "Scheduled"
    }
    ok_smm_post, _ = test_endpoint("POST", "/smm", data=smm_payload)
    results.append(("POST /smm", ok_smm_post))

    ok_smm_del, _ = test_endpoint("DELETE", "/smm/smm-test-99")
    results.append(("DELETE /smm/{id}", ok_smm_del))

    # 8. Google Ads
    print("\n--- 8. Google Ads Reports CRUD ---")
    ok_gads_get, _ = test_endpoint("GET", "/google-ads")
    results.append(("GET /google-ads", ok_gads_get))

    gads_payload = {
        "id": "gads-test-99",
        "campaignName": "Search_Bridal_Jewelry_Bangalore",
        "campaignType": "Search",
        "targetSuperCategory": "Luxury Jewelry",
        "targetKeywords": ["bridal gold necklace", "polki choker bangalore"],
        "negativeKeywords": ["cheap", "fake"],
        "dailyBudgetInr": 8000,
        "totalSpendInr": 24000,
        "impressions": 48000,
        "clicks": 3200,
        "ctrPercent": 6.67,
        "avgCpcInr": 7.5,
        "conversions": 160,
        "cpaInr": 150,
        "roasRatio": 6.2,
        "status": "Active",
        "startDate": "2026-09-01"
    }
    ok_gads_post, _ = test_endpoint("POST", "/google-ads", data=gads_payload)
    results.append(("POST /google-ads", ok_gads_post))

    ok_gads_del, _ = test_endpoint("DELETE", "/google-ads/gads-test-99")
    results.append(("DELETE /google-ads/{id}", ok_gads_del))

    # 9. Strategies
    print("\n--- 9. Marketing Strategies CRUD ---")
    ok_strat_get, _ = test_endpoint("GET", "/strategies")
    results.append(("GET /strategies", ok_strat_get))

    strat_payload = {
        "id": "strat-test-99",
        "title": "Q4 High-Ticket Vendor Expansion",
        "horizonQuarter": "Q4 2026",
        "objective": "Onboard 100 luxury vendors in Delhi & Hyderabad",
        "targetSuperCategories": ["Jewelry", "Home Services"],
        "targetRegions": ["Delhi NCR", "Hyderabad"],
        "coreChannels": ["LinkedIn", "Google Ads", "Direct PR"],
        "allocatedBudgetInr": 500000,
        "spentBudgetInr": 50000,
        "projectedLeads": 800,
        "actualLeads": 120,
        "kpis": ["ROAS > 4.5x"],
        "milestones": [{"id": "m-1", "title": "Landing Page", "completed": True}],
        "ownerName": "Vikram Sethi",
        "status": "Active"
    }
    ok_strat_post, _ = test_endpoint("POST", "/strategies", data=strat_payload)
    results.append(("POST /strategies", ok_strat_post))

    ok_strat_del, _ = test_endpoint("DELETE", "/strategies/strat-test-99")
    results.append(("DELETE /strategies/{id}", ok_strat_del))

    # 10. Content Creations
    print("\n--- 10. Content Creations CRUD ---")
    ok_cc_get, _ = test_endpoint("GET", "/content")
    results.append(("GET /content", ok_cc_get))

    cc_payload = {
        "id": "cc-test-99",
        "title": "Festive Diamond Earring Ad Copy",
        "contentType": "Ad Banner Copy",
        "platform": "Facebook",
        "targetPersona": "Luxury Buyers",
        "copyText": "Adorn yourself in certified brilliance this Diwali.",
        "visualAssetUrl": "https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f",
        "assignedCreator": "Aanya Sharma",
        "deadlineDate": "2026-09-15",
        "approvalStatus": "Draft",
        "performanceTags": ["Festive", "Diamond"]
    }
    ok_cc_post, _ = test_endpoint("POST", "/content", data=cc_payload)
    results.append(("POST /content", ok_cc_post))

    ok_cc_del, _ = test_endpoint("DELETE", "/content/cc-test-99")
    results.append(("DELETE /content/{id}", ok_cc_del))

    # Summary
    print("\n=================================================================")
    print("TEST SUMMARY")
    print("=================================================================")
    total = len(results)
    passed = sum(1 for _, ok in results if ok)
    print(f"Total Tests Executed: {total}")
    print(f"Passed: {passed} / {total} ({(passed/total)*100:.1f}%)")
    for name, ok in results:
        print(f"  {'✅' if ok else '❌'} {name}")

if __name__ == "__main__":
    run_all_tests()
