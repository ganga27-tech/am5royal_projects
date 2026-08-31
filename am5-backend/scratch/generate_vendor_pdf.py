import os
import json
from datetime import datetime
from reportlab.lib.pagesizes import letter, landscape
from reportlab.lib import colors
from reportlab.platypus import (
    SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, PageBreak
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.pages = []

    def showPage(self):
        self.pages.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        page_count = len(self.pages)
        for page in self.pages:
            self.__dict__.update(page)
            self.draw_page_decorations(page_count)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        self.saveState()
        self.setFont("Helvetica-Bold", 8)
        self.setFillColor(colors.HexColor("#4A5568"))
        
        # Header (pages 2+)
        if self._pageNumber > 1:
            self.drawString(36, 582, "AM5ROYAL  |  VENDOR ONBOARDING & REGISTRATION STATUS REPORT")
            self.setFont("Helvetica", 8)
            self.drawRightString(792 - 36, 582, "CONFIDENTIAL & PROPRIETARY")
            self.setStrokeColor(colors.HexColor("#CBD5E1"))
            self.setLineWidth(0.75)
            self.line(36, 576, 792 - 36, 576)
            
        # Footer (all pages)
        self.setFont("Helvetica", 8)
        self.setFillColor(colors.HexColor("#718096"))
        self.drawString(36, 22, f"Generated: {datetime.now().strftime('%B %d, %Y at %I:%M %p')}  •  AM5Royal Services Marketplace")
        page_str = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(792 - 36, 22, page_str)
        self.setStrokeColor(colors.HexColor("#CBD5E1"))
        self.setLineWidth(0.75)
        self.line(36, 32, 792 - 36, 32)
        
        self.restoreState()

def clean_text(text):
    if text is None:
        return ""
    text = str(text).strip()
    text = text.replace("₹", "Rs. ")
    text = text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    return text

def build_pdf(json_file_path, output_pdf_paths):
    with open(json_file_path, "r", encoding="utf-8") as f:
        vendors = json.load(f)

    processed_vendors = []
    counts = {
        "Subscribed (Paid)": 0,
        "Slots Done": 0,
        "Category Added": 0,
        "Registration Done": 0,
        "OTP Verified Only": 0
    }
    
    total_otp_verified = 0
    total_registration_done = 0
    total_categories_added = 0
    total_docs_uploaded = 0
    total_slots_configured = 0
    total_paid_active = 0
    
    category_counts = {}

    for v in vendors:
        is_otp = bool(v.get("otp_verified"))
        has_sub = v.get("subscription_status") == "active"
        has_slots = (v.get("slots_count") or 0) > 0
        has_cats = bool(v.get("sub_categories")) or (v.get("services_count") or 0) > 0
        has_docs = (v.get("documents_count") or 0) > 0 or bool(v.get("aadhaar_number")) or bool(v.get("pan_number"))
        has_profile = bool(v.get("first_name") and v.get("first_name").strip()) or bool(v.get("business_name") and v.get("business_name").strip())
        
        if is_otp:
            total_otp_verified += 1
        if has_profile:
            total_registration_done += 1
        if has_cats:
            total_categories_added += 1
        if has_docs:
            total_docs_uploaded += 1
        if has_slots:
            total_slots_configured += 1
        if has_sub:
            total_paid_active += 1

        if has_sub:
            stage = "Subscribed (Paid)"
            stage_order = 1
        elif has_slots:
            stage = "Slots Done"
            stage_order = 2
        elif has_cats:
            stage = "Category Added"
            stage_order = 3
        elif has_profile:
            stage = "Registration Done"
            stage_order = 4
        else:
            stage = "OTP Verified Only"
            stage_order = 5
            
        counts[stage] = counts.get(stage, 0) + 1
        
        sub_cats_str = v.get("sub_categories") or ""
        if sub_cats_str:
            for c in sub_cats_str.split(", "):
                c_clean = c.strip()
                if c_clean:
                    category_counts[c_clean] = category_counts.get(c_clean, 0) + 1

        name_parts = [clean_text(v.get("first_name")), clean_text(v.get("last_name"))]
        full_name = " ".join([p for p in name_parts if p]).strip() or "Not Provided"
        business = clean_text(v.get("business_name")) or "-"
        mobile = clean_text(v.get("user_mobile") or v.get("vendor_mobile")) or "-"
        city = clean_text(v.get("city")) or clean_text(v.get("district")) or "-"
        
        created_str = "-"
        if v.get("user_created_at"):
            try:
                dt = datetime.fromisoformat(v["user_created_at"].split(".")[0])
                created_str = dt.strftime("%d/%m/%Y")
            except:
                created_str = v["user_created_at"][:10]
                
        processed_vendors.append({
            "raw": v,
            "user_id": v.get("user_id"),
            "vendor_id": v.get("vendor_id") or "-",
            "name": full_name,
            "business": business,
            "mobile": mobile,
            "city": city,
            "created": created_str,
            "stage": stage,
            "stage_order": stage_order,
            "is_otp": is_otp,
            "has_profile": has_profile,
            "has_cats": has_cats,
            "sub_categories": v.get("sub_categories") or "",
            "services_count": v.get("services_count") or 0,
            "has_slots": has_slots,
            "slots_count": v.get("slots_count") or 0,
            "has_docs": has_docs,
            "documents_uploaded": v.get("documents_uploaded") or "",
            "has_sub": has_sub,
            "plan_name": clean_text(v.get("subscription_plan_name")) or "-",
            "plan_price": clean_text(v.get("subscription_price")) or "-"
        })

    # Sort vendors: Paid first -> Slots -> Category -> Profile -> OTP Only, then newest first
    processed_vendors.sort(key=lambda x: (x["stage_order"], -x["user_id"]))
    total_vendors = len(processed_vendors)

    styles = getSampleStyleSheet()
    
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=colors.HexColor("#0F172A"),
        spaceAfter=2
    )
    
    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8.5,
        leading=12,
        textColor=colors.HexColor("#475569"),
        spaceAfter=10
    )

    section_header_style = ParagraphStyle(
        'SectionHeader',
        parent=styles['Heading2'],
        fontName='Helvetica-Bold',
        fontSize=10.5,
        leading=14,
        textColor=colors.HexColor("#1E293B"),
        spaceBefore=6,
        spaceAfter=6
    )

    th_style = ParagraphStyle(
        'TableHead',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=8,
        leading=10,
        textColor=colors.whitesmoke
    )

    td_style = ParagraphStyle(
        'TableBody',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=7.5,
        leading=9.5,
        textColor=colors.HexColor("#1E293B")
    )

    td_bold_style = ParagraphStyle(
        'TableBodyBold',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=7.5,
        leading=9.5,
        textColor=colors.HexColor("#0F172A")
    )

    td_muted_style = ParagraphStyle(
        'TableBodyMuted',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=7,
        leading=8.5,
        textColor=colors.HexColor("#64748B")
    )

    elements = []

    # ================= PAGE 1: EXECUTIVE KPI DASHBOARD =================
    elements.append(Paragraph("AM5ROYAL SERVICES MARKETPLACE", ParagraphStyle('PreTitle', fontName='Helvetica-Bold', fontSize=8.5, textColor=colors.HexColor("#2563EB"), spaceAfter=2)))
    elements.append(Paragraph("Vendor Onboarding & Registration Status Report", title_style))
    elements.append(Paragraph(f"Comprehensive live audit of all <b>{total_vendors} registered vendors</b>, tracking onboarding milestones: OTP Verification, Profile Registration, Category/Services Setup, Slot Timings, and Subscription Payment.", subtitle_style))
    
    # 5 KPI Metric Cards
    kpi_card_data = [
        [
            Paragraph("<b>1. OTP VERIFIED</b>", ParagraphStyle('kpi_h1', fontName='Helvetica-Bold', fontSize=8, textColor=colors.HexColor("#1E3A8A"))),
            Paragraph("<b>2. PROFILE COMPLETED</b>", ParagraphStyle('kpi_h2', fontName='Helvetica-Bold', fontSize=8, textColor=colors.HexColor("#4338CA"))),
            Paragraph("<b>3. CATEGORY / SERVICES</b>", ParagraphStyle('kpi_h3', fontName='Helvetica-Bold', fontSize=8, textColor=colors.HexColor("#0369A1"))),
            Paragraph("<b>4. SLOTS CONFIGURED</b>", ParagraphStyle('kpi_h4', fontName='Helvetica-Bold', fontSize=8, textColor=colors.HexColor("#B45309"))),
            Paragraph("<b>5. ACTIVE SUBSCRIBED</b>", ParagraphStyle('kpi_h5', fontName='Helvetica-Bold', fontSize=8, textColor=colors.HexColor("#15803D")))
        ],
        [
            Paragraph(f"<font size=15><b>{total_otp_verified}</b></font><br/><font size=7.5 color='#4B5563'>100% of Total</font>", ParagraphStyle('kpi_v1', fontName='Helvetica-Bold', leading=15)),
            Paragraph(f"<font size=15><b>{total_registration_done}</b></font><br/><font size=7.5 color='#4B5563'>{total_registration_done/total_vendors*100:.1f}% Conversion</font>", ParagraphStyle('kpi_v2', fontName='Helvetica-Bold', leading=15)),
            Paragraph(f"<font size=15><b>{total_categories_added}</b></font><br/><font size=7.5 color='#4B5563'>{total_categories_added/total_vendors*100:.1f}% Conversion</font>", ParagraphStyle('kpi_v3', fontName='Helvetica-Bold', leading=15)),
            Paragraph(f"<font size=15><b>{total_slots_configured}</b></font><br/><font size=7.5 color='#4B5563'>{total_slots_configured/total_vendors*100:.1f}% Conversion</font>", ParagraphStyle('kpi_v4', fontName='Helvetica-Bold', leading=15)),
            Paragraph(f"<font size=15><b>{total_paid_active}</b></font><br/><font size=7.5 color='#15803D'>{total_paid_active/total_vendors*100:.1f}% Paid Conversion</font>", ParagraphStyle('kpi_v5', fontName='Helvetica-Bold', leading=15))
        ]
    ]
    kpi_table = Table(kpi_card_data, colWidths=[144, 144, 144, 144, 144])
    kpi_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (0, 1), colors.HexColor("#EFF6FF")),
        ('BACKGROUND', (1, 0), (1, 1), colors.HexColor("#EEF2FF")),
        ('BACKGROUND', (2, 0), (2, 1), colors.HexColor("#F0F9FF")),
        ('BACKGROUND', (3, 0), (3, 1), colors.HexColor("#FEF3C7")),
        ('BACKGROUND', (4, 0), (4, 1), colors.HexColor("#DCFCE7")),
        ('BOX', (0, 0), (0, 1), 1, colors.HexColor("#BFDBFE")),
        ('BOX', (1, 0), (1, 1), 1, colors.HexColor("#C7D2FE")),
        ('BOX', (2, 0), (2, 1), 1, colors.HexColor("#BAE6FD")),
        ('BOX', (3, 0), (3, 1), 1, colors.HexColor("#FDE68A")),
        ('BOX', (4, 0), (4, 1), 1, colors.HexColor("#BBF7D0")),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    elements.append(kpi_table)
    elements.append(Spacer(1, 8))

    # Funnel Milestone Table
    elements.append(Paragraph("Funnel Breakdown by Milestone Stage", section_header_style))
    
    funnel_data = [
        [
            Paragraph("Milestone Stage", th_style),
            Paragraph("Status Description & Stage Criteria", th_style),
            Paragraph("Vendor Count", th_style),
            Paragraph("% of Total", th_style),
            Paragraph("Current Status Badge", th_style),
            Paragraph("Recommended Follow-up Action", th_style)
        ],
        [
            Paragraph("<b>1. Subscribed (Paid)</b>", td_bold_style),
            Paragraph("Active subscription plan (Gold / Platinum / Rs. 999 / Rs. 1499). Fully onboarded.", td_style),
            Paragraph(f"<b>{counts['Subscribed (Paid)']}</b>", td_bold_style),
            Paragraph(f"<b>{counts['Subscribed (Paid)']/total_vendors*100:.1f}%</b>", td_style),
            Paragraph("<font color='#166534'><b>[ ACTIVE / PAID ]</b></font>", td_style),
            Paragraph("Lead allocation, monitor customer booking completion.", td_muted_style)
        ],
        [
            Paragraph("<b>2. Slots Done</b>", td_bold_style),
            Paragraph("Weekly operating slots configured in app. Subscription purchase pending.", td_style),
            Paragraph(f"<b>{counts['Slots Done']}</b>", td_bold_style),
            Paragraph(f"<b>{counts['Slots Done']/total_vendors*100:.1f}%</b>", td_style),
            Paragraph("<font color='#92400E'><b>[ SLOTS CONFIGURED ]</b></font>", td_style),
            Paragraph("High intent! Telecaller follow-up to close plan subscription.", td_muted_style)
        ],
        [
            Paragraph("<b>3. Category Added</b>", td_bold_style),
            Paragraph("Services/trade categories selected. Operating slot timings pending.", td_style),
            Paragraph(f"<b>{counts['Category Added']}</b>", td_bold_style),
            Paragraph(f"<b>{counts['Category Added']/total_vendors*100:.1f}%</b>", td_style),
            Paragraph("<font color='#0369A1'><b>[ CATEGORY ADDED ]</b></font>", td_style),
            Paragraph("Prompt vendor to configure weekly availability calendar.", td_muted_style)
        ],
        [
            Paragraph("<b>4. Registration Done</b>", td_bold_style),
            Paragraph("Vendor profile details & address entered. Category selection pending.", td_style),
            Paragraph(f"<b>{counts['Registration Done']}</b>", td_bold_style),
            Paragraph(f"<b>{counts['Registration Done']/total_vendors*100:.1f}%</b>", td_style),
            Paragraph("<font color='#4F46E5'><b>[ REGISTRATION DONE ]</b></font>", td_style),
            Paragraph("Call/guide vendor to select their specialized service categories.", td_muted_style)
        ],
        [
            Paragraph("<b>5. OTP Verified Only</b>", td_bold_style),
            Paragraph("OTP verified upon mobile login, but profile details not yet submitted.", td_style),
            Paragraph(f"<b>{counts['OTP Verified Only']}</b>", td_bold_style),
            Paragraph(f"<b>{counts['OTP Verified Only']/total_vendors*100:.1f}%</b>", td_style),
            Paragraph("<font color='#991B1B'><b>[ OTP VERIFIED ONLY ]</b></font>", td_style),
            Paragraph("Trigger automated WhatsApp/SMS reminder to complete registration.", td_muted_style)
        ],
        [
            Paragraph("<b>TOTAL VENDORS</b>", td_bold_style),
            Paragraph("<b>All registered vendors in AM5Royal Database</b>", td_bold_style),
            Paragraph(f"<b>{total_vendors}</b>", td_bold_style),
            Paragraph("<b>100.0%</b>", td_bold_style),
            Paragraph("<b>-</b>", td_bold_style),
            Paragraph("<b>-</b>", td_bold_style)
        ]
    ]

    funnel_table = Table(funnel_data, colWidths=[110, 215, 65, 55, 120, 155])
    funnel_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#1E293B")),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('TOPPADDING', (0, 0), (-1, -1), 3.5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3.5),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 5),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ('BACKGROUND', (0, 1), (-1, 1), colors.HexColor("#F0FDF4")),
        ('BACKGROUND', (0, 2), (-1, 2), colors.HexColor("#FFFBEB")),
        ('BACKGROUND', (0, 3), (-1, 3), colors.HexColor("#F0F9FF")),
        ('BACKGROUND', (0, 4), (-1, 4), colors.HexColor("#F5F3FF")),
        ('BACKGROUND', (0, 5), (-1, 5), colors.HexColor("#FEF2F2")),
        ('BACKGROUND', (0, -1), (-1, -1), colors.HexColor("#E2E8F0")),
    ]))
    elements.append(funnel_table)
    elements.append(Spacer(1, 8))

    # Top Categories Table (Top 8 categories)
    elements.append(Paragraph("Top Vendor Trade Categories Configured", section_header_style))
    top_cats = sorted(category_counts.items(), key=lambda x: x[1], reverse=True)[:8]
    cat_summary_rows = [
        [
            Paragraph("Trade Category Name", th_style),
            Paragraph("Vendor Count", th_style),
            Paragraph("Trade Category Name", th_style),
            Paragraph("Vendor Count", th_style)
        ]
    ]
    half = 4
    for i in range(half):
        c1, cnt1 = top_cats[i] if i < len(top_cats) else ("-", 0)
        c2, cnt2 = top_cats[i + half] if (i + half) < len(top_cats) else ("-", 0)
        cat_summary_rows.append([
            Paragraph(f"• <b>{c1}</b>", td_style),
            Paragraph(f"<b>{cnt1}</b> vendors", td_style),
            Paragraph(f"• <b>{c2}</b>", td_style),
            Paragraph(f"<b>{cnt2}</b> vendors", td_style)
        ])
    cat_summary_table = Table(cat_summary_rows, colWidths=[240, 120, 240, 120])
    cat_summary_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#334155")),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0, 0), (-1, -1), 3),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    elements.append(cat_summary_table)

    # Page break to start the detailed directory on Page 2
    elements.append(PageBreak())

    # ================= PAGES 2+: COMPREHENSIVE VENDOR DIRECTORY =================
    elements.append(Paragraph("Complete Vendor Directory & Status Audit Roster", section_header_style))
    elements.append(Paragraph("All vendors sorted by milestone hierarchy (Active Paid Vendors first, followed by Slots Done, Categories Added, Registration Done, and OTP Only).", subtitle_style))

    # Col Widths: 28 + 52 + 125 + 115 + 145 + 85 + 80 + 90 = 720 pt
    col_widths = [28, 52, 125, 115, 145, 85, 80, 90]
    
    directory_table_data = [[
        Paragraph("<b>S.No</b>", th_style),
        Paragraph("<b>User/Ven ID</b>", th_style),
        Paragraph("<b>Vendor & Mobile</b>", th_style),
        Paragraph("<b>Business & City</b>", th_style),
        Paragraph("<b>Category / Services Added</b>", th_style),
        Paragraph("<b>KYC & Slots</b>", th_style),
        Paragraph("<b>Subscription</b>", th_style),
        Paragraph("<b>Current Status</b>", th_style)
    ]]

    badge_html = {
        "Subscribed (Paid)": "<font color='#166534'><b>[ ACTIVE / PAID ]</b></font>",
        "Slots Done": "<font color='#92400E'><b>[ SLOTS DONE ]</b></font>",
        "Category Added": "<font color='#0284C7'><b>[ CATEGORY DONE ]</b></font>",
        "Registration Done": "<font color='#4F46E5'><b>[ PROFILE DONE ]</b></font>",
        "OTP Verified Only": "<font color='#DC2626'><b>[ OTP ONLY ]</b></font>"
    }

    for idx, v in enumerate(processed_vendors, start=1):
        id_str = f"U: {v['user_id']}<br/><font color='#64748B'>V: {v['vendor_id']}</font>"
        vendor_str = f"<b>{v['name']}</b><br/><font color='#2563EB'>{v['mobile']}</font>"
        loc_str = f"<b>{v['business']}</b><br/><font color='#64748B'>{v['city']}</font>"
        
        if v['sub_categories']:
            cat_display = v['sub_categories']
            if len(cat_display) > 60:
                cat_display = cat_display[:57] + "..."
            svc_info = f"<br/><font color='#475569'>Services: {v['services_count']}</font>" if v['services_count'] else ""
            cat_str = f"<b>{clean_text(cat_display)}</b>{svc_info}"
        else:
            cat_str = "<font color='#94A3B8'>None Selected</font>"

        docs_display = f"Docs: {clean_text(v['documents_uploaded']) or 'None'}"
        if len(docs_display) > 28:
            docs_display = docs_display[:25] + "..."
        slots_display = f"Slots: {v['slots_count']} active" if v['has_slots'] else "Slots: None"
        kyc_slots_str = f"{slots_display}<br/><font color='#64748B'>{docs_display}</font>"
        
        if v['has_sub']:
            sub_str = f"<b><font color='#166534'>{v['plan_name']}</font></b><br/><font color='#475569'>Rs. {v['plan_price']}</font>"
        else:
            sub_str = "<font color='#94A3B8'>Not Subscribed</font>"

        status_badge = badge_html[v['stage']]

        directory_table_data.append([
            Paragraph(str(idx), td_style),
            Paragraph(id_str, td_style),
            Paragraph(vendor_str, td_style),
            Paragraph(loc_str, td_style),
            Paragraph(cat_str, td_style),
            Paragraph(kyc_slots_str, td_style),
            Paragraph(sub_str, td_style),
            Paragraph(status_badge, td_style)
        ])

    dir_table = Table(directory_table_data, colWidths=col_widths, repeatRows=1)
    
    table_style = TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#0F172A")),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('TOPPADDING', (0, 0), (-1, 0), 5),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 5),
        ('TOPPADDING', (0, 1), (-1, -1), 3),
        ('BOTTOMPADDING', (0, 1), (-1, -1), 3),
        ('LEFTPADDING', (0, 0), (-1, -1), 4),
        ('RIGHTPADDING', (0, 0), (-1, -1), 4),
        ('GRID', (0, 0), (-1, -1), 0.4, colors.HexColor("#E2E8F0")),
    ])
    
    for i in range(1, len(directory_table_data)):
        if i % 2 == 0:
            table_style.add('BACKGROUND', (0, i), (-1, i), colors.HexColor("#F8FAFC"))
            
    dir_table.setStyle(table_style)
    elements.append(dir_table)

    # Build primary PDF
    first_path = output_pdf_paths[0]
    doc = SimpleDocTemplate(
        first_path,
        pagesize=landscape(letter),
        leftMargin=36,
        rightMargin=36,
        topMargin=40,
        bottomMargin=40
    )
    doc.build(elements, canvasmaker=NumberedCanvas)
    print(f"Generated: {first_path}")

    # Copy to any other requested paths
    import shutil
    for extra_path in output_pdf_paths[1:]:
        shutil.copy2(first_path, extra_path)
        print(f"Copied to: {extra_path}")

if __name__ == '__main__':
    json_path = 'd:/fb/am5-backend/scratch/vendors_dump.json'
    destinations = [
        'd:/fb/vendor_onboarding_status_report.pdf',
        'd:/fb/am5-backend/vendor_onboarding_status_report.pdf',
        'd:/fb/am5-backend/vendor_report.pdf'
    ]
    build_pdf(json_path, destinations)
