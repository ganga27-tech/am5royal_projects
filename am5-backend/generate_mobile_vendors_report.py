import asyncio
import json
from datetime import datetime
from sqlalchemy import text
from app.db.session import engine

# Import ReportLab elements
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
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
            self.draw_page_number(page_count)
            super().showPage()
        super().save()

    def draw_page_number(self, page_count):
        self.saveState()
        self.setFont("Helvetica", 9)
        self.setFillColor(colors.HexColor("#555555"))
        
        # Header (on every page except first maybe, or all)
        self.drawString(54, 750, "AM5Royal - Mobile Application Logged-In Vendors Report")
        self.setStrokeColor(colors.HexColor("#cccccc"))
        self.setLineWidth(0.5)
        self.line(54, 742, letter[0] - 54, 742)
        
        # Footer
        page_text = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(letter[0] - 54, 36, page_text)
        self.drawString(54, 36, f"Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        self.line(54, 48, letter[0] - 54, 48)
        self.restoreState()

async def main():
    query = text("""
        SELECT 
            v.id as vendor_id,
            COALESCE(v.first_name, '') as first_name,
            COALESCE(v.last_name, '') as last_name,
            COALESCE(v.business_name, 'N/A') as business_name,
            COALESCE(u.mobile, 'N/A') as mobile_number,
            COALESCE(u.email, 'N/A') as email,
            u.updated_at as last_active_at
        FROM vendors v
        JOIN users u ON v.user_id = u.id
        WHERE u.fcm_token IS NOT NULL OR u.id IN (SELECT DISTINCT user_id FROM device_installations WHERE user_id IS NOT NULL)
        ORDER BY u.updated_at DESC
    """)

    results_list = []
    async with engine.connect() as conn:
        result = await conn.execute(query)
        rows = result.fetchall()
        for idx, row in enumerate(rows, start=1):
            results_list.append({
                "s_no": idx,
                "vendor_id": row.vendor_id,
                "name": f"{row.first_name} {row.last_name}".strip() or "N/A",
                "business_name": row.business_name,
                "mobile_number": row.mobile_number,
                "email": row.email,
                "last_active": row.last_active_at.strftime('%Y-%m-%d %H:%M:%S') if row.last_active_at else "N/A"
            })

    print(f"Fetched {len(results_list)} records from DB.")

    # Generate PDF
    pdf_filename = "mobile_logged_in_vendors.pdf"
    # Margins: 0.75 inch top, 0.75 inch bottom (54 pt) to leave room for header and footer
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
    title_style = ParagraphStyle(
        'ReportTitle',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=colors.HexColor("#1A365D"),
        spaceAfter=15
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

    elements.append(Paragraph("Mobile Application Logged-In Vendors", title_style))
    elements.append(Spacer(1, 10))

    # Table columns: S.No (30), ID (40), Name (120), Business Name (120), Mobile (80), Last Active (114)
    # Total width = 504 (letter width is 612 - 108 margins = 504)
    col_widths = [30, 40, 110, 140, 80, 104]
    
    table_data = [[
        Paragraph("S.No", cell_header_style),
        Paragraph("ID", cell_header_style),
        Paragraph("Name", cell_header_style),
        Paragraph("Business Name", cell_header_style),
        Paragraph("Mobile", cell_header_style),
        Paragraph("Last Active", cell_header_style)
    ]]

    for item in results_list:
        table_data.append([
            Paragraph(str(item["s_no"]), cell_style),
            Paragraph(str(item["vendor_id"]), cell_style),
            Paragraph(item["name"], cell_style),
            Paragraph(item["business_name"], cell_style),
            Paragraph(item["mobile_number"], cell_style),
            Paragraph(item["last_active"], cell_style)
        ])

    table = Table(table_data, colWidths=col_widths, repeatRows=1)
    
    t_style = TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#1A365D")),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 8),
        ('TOPPADDING', (0, 0), (-1, 0), 8),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
    ])
    
    # Alternating row colors
    for i in range(1, len(table_data)):
        if i % 2 == 0:
            t_style.add('BACKGROUND', (0, i), (-1, i), colors.HexColor("#F7FAFC"))
            
    table.setStyle(t_style)
    elements.append(table)
    
    doc.build(elements, canvasmaker=NumberedCanvas)
    print(f"Successfully generated PDF: {pdf_filename}")

if __name__ == "__main__":
    asyncio.run(main())
