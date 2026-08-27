import asyncio
import os
from datetime import datetime
from sqlalchemy import text
from app.db.session import engine

# Import ReportLab elements
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, KeepTogether
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
            self.draw_page_elements(page_count)
            super().showPage()
        super().save()

    def draw_page_elements(self, page_count):
        self.saveState()
        self.setFont("Helvetica", 8)
        self.setFillColor(colors.HexColor("#4A5568"))
        
        # Header (on all pages)
        self.drawString(54, 750, "AM5Royal - Vendor Registration Steps Report")
        self.setStrokeColor(colors.HexColor("#CBD5E1"))
        self.setLineWidth(0.5)
        self.line(54, 742, letter[0] - 54, 742)
        
        # Footer (on all pages)
        page_text = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(letter[0] - 54, 36, page_text)
        self.drawString(54, 36, f"Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        self.line(54, 48, letter[0] - 54, 48)
        self.restoreState()

async def main():
    query = text("""
        WITH vendor_steps AS (
            SELECT 
                u.id as user_id,
                COALESCE(u.mobile, 'N/A') as user_mobile,
                COALESCE(u.email, 'N/A') as user_email,
                v.id as vendor_id,
                COALESCE(v.first_name, '') as first_name,
                COALESCE(v.last_name, '') as last_name,
                COALESCE(v.business_name, 'N/A') as business_name,
                (
                    CASE
                        WHEN EXISTS (SELECT 1 FROM vendor_subscriptions vs WHERE vs.vendor_id = v.id AND vs.status = 'active') THEN 'Payment'
                        WHEN EXISTS (SELECT 1 FROM vendor_availability va WHERE va.vendor_id = v.id) THEN 'Slot Booking'
                        WHEN EXISTS (SELECT 1 FROM vendor_sub_categories vsc WHERE vsc.vendor_id = v.id) OR EXISTS (SELECT 1 FROM vendor_services vsr WHERE vsr.vendor_id = v.id) THEN 'Subcategory'
                        WHEN v.id IS NOT NULL AND (v.first_name IS NOT NULL AND v.first_name != '' OR v.business_name IS NOT NULL AND v.business_name != '') THEN 'Registration'
                        ELSE 'Only OTP Verified'
                    END
                ) as step
            FROM users u
            LEFT JOIN vendors v ON v.user_id = u.id
            WHERE u.role LIKE '%VENDOR%'
        )
        SELECT * FROM vendor_steps
        ORDER BY 
            CASE 
                WHEN step = 'Payment' THEN 1
                WHEN step = 'Slot Booking' THEN 2
                WHEN step = 'Subcategory' THEN 3
                WHEN step = 'Registration' THEN 4
                ELSE 5
            END ASC,
            user_id DESC
    """)

    results_list = []
    counts = {
        "Payment": 0,
        "Slot Booking": 0,
        "Subcategory": 0,
        "Registration": 0,
        "Only OTP Verified": 0
    }

    async with engine.connect() as conn:
        result = await conn.execute(query)
        rows = result.fetchall()
        for idx, row in enumerate(rows, start=1):
            step = row.step
            counts[step] = counts.get(step, 0) + 1
            
            name = f"{row.first_name} {row.last_name}".strip()
            if not name:
                name = "N/A"
                
            mobile = row.user_mobile
            if mobile == 'N/A' and row.first_name:
                # Fallback to vendor mobile if user mobile is empty
                mobile = "N/A" # Defaulting to N/A if not found

            results_list.append({
                "s_no": idx,
                "user_id": row.user_id,
                "vendor_id": row.vendor_id or "N/A",
                "name": name,
                "business_name": row.business_name,
                "mobile": mobile,
                "step": step
            })

    total_vendors = len(results_list)
    print(f"Fetched {total_vendors} vendors from DB.")

    # Generate PDF
    pdf_filename = "vendors_step_report.pdf"
    doc = SimpleDocTemplate(
        pdf_filename, 
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=72,
        bottomMargin=72
    )
    
    elements = []
    styles = getSampleStyleSheet()
    
    # Custom styles
    title_style = ParagraphStyle(
        'ReportTitle',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=20,
        leading=24,
        textColor=colors.HexColor("#1A365D"),
        spaceAfter=15
    )
    
    subtitle_style = ParagraphStyle(
        'ReportSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=10,
        leading=14,
        textColor=colors.HexColor("#4A5568"),
        spaceAfter=20
    )

    section_header_style = ParagraphStyle(
        'SectionHeader',
        parent=styles['Heading2'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=16,
        textColor=colors.HexColor("#2C5282"),
        spaceBefore=10,
        spaceAfter=10
    )

    cell_style = ParagraphStyle(
        'TableCell',
        fontName='Helvetica',
        fontSize=8,
        leading=10,
        textColor=colors.HexColor("#2D3748")
    )

    cell_header_style = ParagraphStyle(
        'TableHeader',
        fontName='Helvetica-Bold',
        fontSize=9,
        leading=11,
        textColor=colors.whitesmoke
    )

    step_badge_styles = {
        "Payment": ParagraphStyle('BadgeP', fontName='Helvetica-Bold', fontSize=8, leading=10, textColor=colors.HexColor("#22543D")),
        "Slot Booking": ParagraphStyle('BadgeSB', fontName='Helvetica-Bold', fontSize=8, leading=10, textColor=colors.HexColor("#744210")),
        "Subcategory": ParagraphStyle('BadgeSC', fontName='Helvetica-Bold', fontSize=8, leading=10, textColor=colors.HexColor("#2A4365")),
        "Registration": ParagraphStyle('BadgeR', fontName='Helvetica-Bold', fontSize=8, leading=10, textColor=colors.HexColor("#2B6CB0")),
        "Only OTP Verified": ParagraphStyle('BadgeOTP', fontName='Helvetica-Bold', fontSize=8, leading=10, textColor=colors.HexColor("#742A2A"))
    }

    elements.append(Paragraph("Vendor Registration Status Report", title_style))
    elements.append(Paragraph("Comprehensive list of all registered users with the VENDOR role and their current progress in the onboarding/registration funnel.", subtitle_style))

    # Summary Dashboard Table
    summary_data = [
        [
            Paragraph("<b>Status Step</b>", cell_header_style), 
            Paragraph("<b>Description</b>", cell_header_style), 
            Paragraph("<b>Count</b>", cell_header_style),
            Paragraph("<b>Percentage</b>", cell_header_style)
        ],
        [
            Paragraph("<b>Payment</b>", step_badge_styles["Payment"]),
            Paragraph("Active subscription / Paid vendors", cell_style),
            Paragraph(str(counts["Payment"]), cell_style),
            Paragraph(f"{counts['Payment']/total_vendors*100:.1f}%", cell_style)
        ],
        [
            Paragraph("<b>Slot Booking</b>", step_badge_styles["Slot Booking"]),
            Paragraph("Slots / availability configured, payment pending", cell_style),
            Paragraph(str(counts["Slot Booking"]), cell_style),
            Paragraph(f"{counts['Slot Booking']/total_vendors*100:.1f}%", cell_style)
        ],
        [
            Paragraph("<b>Subcategory</b>", step_badge_styles["Subcategory"]),
            Paragraph("Selected subcategories/services, slots pending", cell_style),
            Paragraph(str(counts["Subcategory"]), cell_style),
            Paragraph(f"{counts['Subcategory']/total_vendors*100:.1f}%", cell_style)
        ],
        [
            Paragraph("<b>Registration</b>", step_badge_styles["Registration"]),
            Paragraph("Basic details entered, subcategory selection pending", cell_style),
            Paragraph(str(counts["Registration"]), cell_style),
            Paragraph(f"{counts['Registration']/total_vendors*100:.1f}%", cell_style)
        ],
        [
            Paragraph("<b>Only OTP Verified</b>", step_badge_styles["Only OTP Verified"]),
            Paragraph("Verified OTP but profile details not started/submitted", cell_style),
            Paragraph(str(counts["Only OTP Verified"]), cell_style),
            Paragraph(f"{counts['Only OTP Verified']/total_vendors*100:.1f}%", cell_style)
        ],
        [
            Paragraph("<b>Total</b>", cell_style),
            Paragraph("<b>All registered vendors</b>", cell_style),
            Paragraph(f"<b>{total_vendors}</b>", cell_style),
            Paragraph("<b>100%</b>", cell_style)
        ]
    ]

    summary_table = Table(summary_data, colWidths=[110, 240, 70, 84])
    summary_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#1A365D")),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ('BACKGROUND', (0, -1), (-1, -1), colors.HexColor("#EDF2F7")),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
    ]))
    
    elements.append(Paragraph("Funnel Summary Statistics", section_header_style))
    elements.append(summary_table)
    elements.append(Spacer(1, 20))

    # Vendors List Table
    elements.append(Paragraph("Complete Vendors List by Step", section_header_style))

    # Widths: S.No (30), User ID (45), Name (110), Business Name (120), Mobile (85), Step (114)
    # Total = 504
    col_widths = [30, 45, 110, 120, 85, 114]
    
    table_data = [[
        Paragraph("S.No", cell_header_style),
        Paragraph("User ID", cell_header_style),
        Paragraph("Name", cell_header_style),
        Paragraph("Business Name", cell_header_style),
        Paragraph("Mobile", cell_header_style),
        Paragraph("Current Step", cell_header_style)
    ]]

    for idx, item in enumerate(results_list, start=1):
        step_str = item["step"]
        badge_style = step_badge_styles[step_str]
        
        # Color backgrounds for steps
        step_bg = "#FFFFFF"
        if step_str == "Payment":
            step_bg = "<b><font color='#22543D'>Payment</font></b>"
        elif step_str == "Slot Booking":
            step_bg = "<b><font color='#744210'>Slot Booking</font></b>"
        elif step_str == "Subcategory":
            step_bg = "<b><font color='#2A4365'>Subcategory</font></b>"
        elif step_str == "Registration":
            step_bg = "<b><font color='#2B6CB0'>Registration</font></b>"
        else:
            step_bg = "<b><font color='#742A2A'>OTP Verified Only</font></b>"

        table_data.append([
            Paragraph(str(idx), cell_style),
            Paragraph(str(item["user_id"]), cell_style),
            Paragraph(item["name"], cell_style),
            Paragraph(item["business_name"], cell_style),
            Paragraph(item["mobile"], cell_style),
            Paragraph(step_bg, cell_style)
        ])

    vendors_table = Table(table_data, colWidths=col_widths, repeatRows=1)
    
    v_table_style = TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#2B6CB0")),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 6),
        ('TOPPADDING', (0, 0), (-1, 0), 6),
        ('BOTTOMPADDING', (0, 1), (-1, -1), 4),
        ('TOPPADDING', (0, 1), (-1, -1), 4),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
    ])
    
    # Alternating row colors
    for i in range(1, len(table_data)):
        if i % 2 == 0:
            v_table_style.add('BACKGROUND', (0, i), (-1, i), colors.HexColor("#F7FAFC"))
            
    vendors_table.setStyle(v_table_style)
    elements.append(vendors_table)
    
    doc.build(elements, canvasmaker=NumberedCanvas)
    print(f"Successfully generated PDF report: {pdf_filename}")

if __name__ == "__main__":
    asyncio.run(main())
