import paramiko
import json

def fetch_all_vendor_data():
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect('76.13.245.174', username='root', password='Am5royal@2026')
    
    script = """import asyncio, json
from sqlalchemy import text
from app.db.session import engine

async def run():
    async with engine.connect() as conn:
        query = text('''
            SELECT 
                u.id as user_id,
                u.mobile as user_mobile,
                u.email as user_email,
                u.otp_verified,
                u.is_active as user_is_active,
                u.created_at as user_created_at,
                u.updated_at as user_updated_at,
                v.id as vendor_id,
                v.first_name,
                v.last_name,
                v.business_name,
                v.mobile as vendor_mobile,
                v.alternative_number,
                v.city,
                v.district,
                v.state,
                v.pincode,
                v.address,
                v.status as vendor_status,
                v.is_premium,
                v.aadhaar_number,
                v.aadhaar_verified,
                v.pan_number,
                v.gst_number,
                v.lead_source,
                v.onboarded_by_employee_id,
                (
                    SELECT string_agg(DISTINCT mc.name, ', ')
                    FROM vendor_sub_categories vsc
                    JOIN main_categories mc ON vsc.main_category_id = mc.id
                    WHERE vsc.vendor_id = v.id
                ) as main_categories,
                (
                    SELECT string_agg(DISTINCT sc.name, ', ')
                    FROM vendor_sub_categories vsc
                    JOIN sub_categories sc ON vsc.sub_category_id = sc.id
                    WHERE vsc.vendor_id = v.id
                ) as sub_categories,
                (
                    SELECT COUNT(*)
                    FROM vendor_services vs
                    WHERE vs.vendor_id = v.id
                ) as services_count,
                (
                    SELECT string_agg(DISTINCT vs.title, ', ')
                    FROM vendor_services vs
                    WHERE vs.vendor_id = v.id
                ) as custom_services,
                (
                    SELECT COUNT(*)
                    FROM vendor_availability va
                    WHERE va.vendor_id = v.id AND va.is_available = true
                ) as slots_count,
                (
                    SELECT string_agg(DISTINCT vd.document_type, ', ')
                    FROM vendor_documents vd
                    WHERE vd.vendor_id = v.id
                ) as documents_uploaded,
                (
                    SELECT COUNT(*)
                    FROM vendor_documents vd
                    WHERE vd.vendor_id = v.id
                ) as documents_count,
                (
                    SELECT vs.status
                    FROM vendor_subscriptions vs
                    WHERE vs.vendor_id = v.id
                    ORDER BY vs.id DESC LIMIT 1
                ) as subscription_status,
                (
                    SELECT sp.name
                    FROM vendor_subscriptions vs
                    JOIN subscription_plans sp ON vs.subscription_plan_id = sp.id
                    WHERE vs.vendor_id = v.id
                    ORDER BY vs.id DESC LIMIT 1
                ) as subscription_plan_name,
                (
                    SELECT sp.price::text
                    FROM vendor_subscriptions vs
                    JOIN subscription_plans sp ON vs.subscription_plan_id = sp.id
                    WHERE vs.vendor_id = v.id
                    ORDER BY vs.id DESC LIMIT 1
                ) as subscription_price,
                (
                    SELECT vs.end_date::text
                    FROM vendor_subscriptions vs
                    WHERE vs.vendor_id = v.id
                    ORDER BY vs.id DESC LIMIT 1
                ) as subscription_end_date
            FROM users u
            LEFT JOIN vendors v ON v.user_id = u.id
            WHERE u.role LIKE '%VENDOR%'
            ORDER BY u.id DESC
        ''')
        
        res = await conn.execute(query)
        rows = [dict(r) for r in res.mappings().fetchall()]
        
        # Convert datetimes to strings
        for r in rows:
            for k, val in r.items():
                if hasattr(val, 'isoformat'):
                    r[k] = val.isoformat()
                    
        with open('/app/scratch/vendors_dump.json', 'w') as f:
            json.dump(rows, f, indent=2)
            
        print(f"Dumped {len(rows)} vendor records to /app/scratch/vendors_dump.json")

asyncio.run(run())
"""
    sftp = client.open_sftp()
    with sftp.open('/root/am5-backend/scratch/dump_script.py', 'w') as f:
        f.write(script)
    sftp.close()
    
    stdin, stdout, stderr = client.exec_command('docker exec -i -w /app -e PYTHONPATH=/app am5_backend python /app/scratch/dump_script.py')
    print(stdout.read().decode())
    err = stderr.read().decode()
    if err:
        print("Error:", err)
        
    # Download JSON to local
    sftp = client.open_sftp()
    sftp.get('/root/am5-backend/scratch/vendors_dump.json', 'd:/fb/am5-backend/scratch/vendors_dump.json')
    sftp.close()
    client.close()
    print("Successfully downloaded vendors_dump.json to local machine.")

if __name__ == '__main__':
    fetch_all_vendor_data()
