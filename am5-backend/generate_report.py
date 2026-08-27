import asyncio
import json
from sqlalchemy import text
from app.db.session import engine

async def main():
    query = text("""
        SELECT 
            v.id, 
            v.first_name, 
            v.last_name, 
            u.mobile as mobile_number,
            (
                CASE
                    WHEN EXISTS (SELECT 1 FROM vendor_subscriptions vs WHERE vs.vendor_id = v.id AND vs.status = 'active') THEN 'active'
                    WHEN EXISTS (SELECT 1 FROM vendor_availability va WHERE va.vendor_id = v.id) THEN 'slots done'
                    WHEN EXISTS (SELECT 1 FROM vendor_services v_s WHERE v_s.vendor_id = v.id) THEN 'services added'
                    WHEN v.business_name IS NOT NULL AND v.business_name != '' THEN 'business registration'
                    ELSE 'registration'
                END
            ) as status
        FROM vendors v
        JOIN users u ON v.user_id = u.id
    """)

    results_list = []
    
    async with engine.connect() as conn:
        result = await conn.execute(query)
        rows = result.fetchall()
        for row in rows:
            results_list.append({
                "vendor_id": row.id,
                "first_name": row.first_name,
                "last_name": row.last_name,
                "mobile_number": row.mobile_number,
                "status": row.status
            })

    with open("vendor_report.json", "w") as f:
        json.dump(results_list, f, indent=4)
        
    print(f"Successfully generated JSON with {len(results_list)} records.")

    # Generate PDF
    from reportlab.lib.pagesizes import letter
    from reportlab.platypus import SimpleDocTemplate, Table, TableStyle
    from reportlab.lib import colors

    pdf_filename = "vendor_report.pdf"
    doc = SimpleDocTemplate(pdf_filename, pagesize=letter)
    elements = []

    # Table header
    data = [["ID", "Name", "Mobile", "Status"]]
    for item in results_list:
        name = f"{item['first_name'] or ''} {item['last_name'] or ''}".strip()
        data.append([
            str(item["vendor_id"]),
            name,
            str(item["mobile_number"]),
            item["status"]
        ])

    table = Table(data, colWidths=[40, 200, 100, 150])
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 12),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('TEXTCOLOR', (0, 1), (-1, -1), colors.black),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 1), (-1, -1), 10),
        ('GRID', (0, 0), (-1, -1), 1, colors.black)
    ]))

    elements.append(table)
    doc.build(elements)
    print(f"Successfully generated PDF: {pdf_filename}")

if __name__ == "__main__":
    asyncio.run(main())
