import asyncio
import asyncpg

leads_data = [
    # Page 1
    {"business_name": "Rajesh's Business", "mobile": "8790977324", "active": False, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Salahuddin 's Business", "mobile": "9766442764", "active": False, "payment": "No", "feedback": "He need 2-3months of time as he dont have money he said"},
    {"business_name": "vedhanayagam's Business", "mobile": "9710072772", "active": False, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Pankaj's Business", "mobile": "6900748226", "active": False, "payment": "No", "feedback": "He will reach his home today and will start the process"},
    {"business_name": "HINDUSTAN PEST CONTROL COMPANY", "mobile": "7303116045", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Anand 's Business", "mobile": "8512848207", "active": True, "payment": "No", "feedback": "He Asked to share details / not respondibg"},
    {"business_name": "Gangi's Business", "mobile": "9000550957", "active": True, "payment": "1899", "feedback": ""},
    {"business_name": "Pest Control Service", "mobile": "9854225222", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "suman 's Business", "mobile": "8788742081", "active": True, "payment": "No", "feedback": "Switch Off"},
    {"business_name": "Raju's Business", "mobile": "9989956152", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "INSTANT CAR CARE", "mobile": "9346011444", "active": True, "payment": "No", "feedback": "Not Connecting The Call"},
    {"business_name": "Aniket's Business", "mobile": "8882868841", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Puran Arun's Business", "mobile": "9281227427", "active": True, "payment": "No", "feedback": "He Told He Will Do"},
    {"business_name": "Buroju 's Business", "mobile": "7095900621", "active": True, "payment": "No", "feedback": "He Will Do DayAfter Tommorow"},
    {"business_name": "Spoorti cleaning and painting services", "mobile": "9959130620", "active": True, "payment": "2399", "feedback": ""},
    {"business_name": "Amreen's Business", "mobile": "8688875072", "active": True, "payment": "No", "feedback": "As she is not feeling well and dont have money, She will do on Monday she said"},
    {"business_name": "Sandeep's Business", "mobile": "8630645532", "active": True, "payment": "No", "feedback": "Asked to call later / not responding"},
    {"business_name": "Nure Irran's Business", "mobile": "9989032473", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Shisir Kanth's Business", "mobile": "9938768239", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Mukesh's Business", "mobile": "9289363589", "active": True, "payment": "No", "feedback": "He kept yahoo mail id will change to Gmail."},
    {"business_name": "Dattatray Vilas's Business", "mobile": "9699174461", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Mohammed Ziya 's Business", "mobile": "9390157107", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Shahid 's Business", "mobile": "9875456583", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Isaq's Business", "mobile": "7483862517", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Appaintingworks 's Business", "mobile": "6309621899", "active": True, "payment": "No", "feedback": "Not connecting the call"},
    {"business_name": "Nityananda's Business", "mobile": "6291362606", "active": True, "payment": "No", "feedback": "Ask to call back"},
    {"business_name": "Sunny's Business", "mobile": "8070919191", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Daksh electrical services", "mobile": "7678209655", "active": True, "payment": "299", "feedback": "Payment Done"},
    {"business_name": "Ravi's Business", "mobile": "7398195196", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Vivek 's Business", "mobile": "7995345100", "active": True, "payment": "1000", "feedback": "Payment Done"},
    {"business_name": "Gaurav 's Business", "mobile": "9582836874", "active": True, "payment": "No", "feedback": "Switch Off"},
    {"business_name": "Mantri's Business", "mobile": "9490536460", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Rahul's Business", "mobile": "9764429388", "active": True, "payment": "No", "feedback": "Call Back"},

    # Page 2
    {"business_name": "Janavikapestcontrol", "mobile": "9502688955", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Sharvan's Business", "mobile": "7850858478", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Dhasoju Chandra's Business", "mobile": "9030715568", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Rohit's Business", "mobile": "7278787275", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Mubarak Ansar's Business", "mobile": "7304692154", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Mohammed's Business", "mobile": "7981894940", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Ankit Rajesh's Business", "mobile": "8208028350", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Arjun's Business", "mobile": "9866592716", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Nishant 's Business", "mobile": "8851366496", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Md house cleaning services", "mobile": "9608020889", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Abhijit cleaning service", "mobile": "9002495054", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Aadharshini pest control", "mobile": "9705657924", "active": True, "payment": "299", "feedback": ""},
    {"business_name": "Rahul 's Business", "mobile": "8051532049", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Urban Pain Relief Therapy and Wellness", "mobile": "9075915336", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Rafa ac repair service", "mobile": "8639511553", "active": True, "payment": "No", "feedback": "Call Back / uploaded yahoo mail"},
    {"business_name": "5star Deep cleaning services", "mobile": "7569985449", "active": True, "payment": "1499", "feedback": ""},
    {"business_name": "Hemant 's Business", "mobile": "9942889933", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Gopal 's Business", "mobile": "8920179011", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Govind's Business", "mobile": "8619903809", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "LAXMAN's Business", "mobile": "7680947699", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Santoshkumar 's Business", "mobile": "8690111693", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Hydrokil Pest Control Private Limited", "mobile": "9045615857", "active": True, "payment": "1000", "feedback": "payment Done"},
    {"business_name": "Mohammed's Business", "mobile": "9154030972", "active": True, "payment": "No", "feedback": "He told he will do"},
    {"business_name": "Himagiri's Business", "mobile": "9704335630", "active": True, "payment": "No", "feedback": "Ask To share Details"},
    {"business_name": "ishine services", "mobile": "8374107519", "active": True, "payment": "No", "feedback": "He told he will do"},
    {"business_name": "saurabh's Business", "mobile": "6305143317", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Driver", "mobile": "8584877425", "active": True, "payment": "299", "feedback": "Done Wallet Recharge"},
    {"business_name": "Venkatesh 's Business", "mobile": "8099190992", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Vivansh Home Solutions", "mobile": "7304971787", "active": True, "payment": "299", "feedback": "payment Done"},
    {"business_name": "Shaikh 's Business", "mobile": "9666146512", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Veerender's Business", "mobile": "9063635964", "active": True, "payment": "No", "feedback": "He told he will do"},
    {"business_name": "Manish's Business", "mobile": "9737879926", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Satish 's Business", "mobile": "7322002531", "active": True, "payment": "No", "feedback": "He told he will do"},

    # Page 3
    {"business_name": "Home solution", "mobile": "9558473889", "active": True, "payment": "299", "feedback": "payment Done"},
    {"business_name": "Vadla shiva 's Business", "mobile": "7893685004", "active": True, "payment": "No", "feedback": "Ask To share Details"},
    {"business_name": "Bhujang 's Business", "mobile": "9930611142", "active": True, "payment": "No", "feedback": "He told he will do"},
    {"business_name": "ANJANEYULU's Business", "mobile": "7287000500", "active": True, "payment": "299", "feedback": "payment Done"},
    {"business_name": "CLEAN PEST CONTROL INDIA", "mobile": "8817018849", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Md's Business", "mobile": "9700950390", "active": True, "payment": "No", "feedback": "He told he will do"},
    {"business_name": "AQUA SHEER RO ALKALINE WATER PURIFIERS", "mobile": "9491177069", "active": True, "payment": "299", "feedback": "payment Done"},
    {"business_name": "RONIT ELETRICIAN", "mobile": "8768606148", "active": True, "payment": "299", "feedback": "payment Done"},
    {"business_name": "Khaja 's Business", "mobile": "9701072257", "active": True, "payment": "299", "feedback": "payment Done"},
    {"business_name": "Kareem's Business", "mobile": "7842587370", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Septic tank clener", "mobile": "9618467142", "active": True, "payment": "500", "feedback": "payment Done"},
    {"business_name": "Manohar pest solutions", "mobile": "9701192539", "active": True, "payment": "299", "feedback": "payment Done"},
    {"business_name": "Mp.kiran's Business", "mobile": "8309637606", "active": True, "payment": "299", "feedback": "payment Done"},
    {"business_name": "Mohammad's Business", "mobile": "9381227996", "active": True, "payment": "299", "feedback": "payment Done"},
    {"business_name": "Lalit's Business", "mobile": "8319128452", "active": True, "payment": "No", "feedback": "Ask To share Details"},
    {"business_name": "Baljeet's Business", "mobile": "8950301232", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "PCS Pest control services", "mobile": "9182909056", "active": True, "payment": "No", "feedback": "He told he will do"},
    {"business_name": "K 's Business", "mobile": "8885514883", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Ramesh pest Control services", "mobile": "8142375725", "active": True, "payment": "No", "feedback": "payment Done"},
    {"business_name": "Pest control service", "mobile": "9794713193", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "SS PEST SERVICES", "mobile": "8897735667", "active": True, "payment": "No", "feedback": "Call back"},
    {"business_name": "Vision pest control", "mobile": "9100494814", "active": True, "payment": "200", "feedback": "payment Done"},
    {"business_name": "VIKAS's Business", "mobile": "8088487246", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Sri Laxmi Narasimha Facility Services", "mobile": "9381521634", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Pest 's Business", "mobile": "7506830111", "active": True, "payment": "No", "feedback": "Call Back"},
    {"business_name": "Nitish 's Business", "mobile": "9631731620", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Korra 's Business", "mobile": "8919604614", "active": True, "payment": "No", "feedback": "Not Answering"},
    {"business_name": "Hanvika electrical works", "mobile": "9603275698", "active": True, "payment": "200", "feedback": "Payment Done"},
    {"business_name": "Rapid Plumbing Services", "mobile": "9346855759", "active": True, "payment": "No", "feedback": "Not Connecting the call"},
    {"business_name": "Apcs pest Experts", "mobile": "7989991901", "active": True, "payment": "420", "feedback": "Payment Done"},
    {"business_name": "Ayan 's plumbing solutions", "mobile": "8247581149", "active": True, "payment": "200", "feedback": "Payment Done"},
    {"business_name": "N/A Servicesd", "mobile": "9105164732", "active": True, "payment": "500", "feedback": "Payment Done"},
    {"business_name": "coomar and coomar services", "mobile": "9666884352", "active": True, "payment": "500", "feedback": "Payment Done"},

    # Page 4
    {"business_name": "SpinNWash Laundry", "mobile": "9930091400", "active": True, "payment": "325", "feedback": "Payment Done"},
    {"business_name": "Sabavat 's Business", "mobile": "7981716760", "active": True, "payment": "No", "feedback": "Not Answering"}
]

async def main():
    conn = await asyncpg.connect("postgresql://am5royal_user:am5royal%4012345@76.13.245.174:5433/am5royal")
    print(f"Connected to DB. Starting import of {len(leads_data)} leads...")
    
    inserted_count = 0
    for lead in leads_data:
        mobile = lead["mobile"]
        bname = lead["business_name"]
        feedback = lead["feedback"]
        payment_info = lead["payment"]
        
        # Deduce names
        first_name = bname.split("'")[0].strip()
        last_name = "Business"
        if "Business" not in bname and "services" not in bname.lower() and "control" not in bname.lower() and len(bname.split()) > 1:
            parts = bname.split()
            first_name = parts[0]
            last_name = " ".join(parts[1:])
            
        status = "active" if lead["active"] else "onboarding"
        
        # 1. Get or create user
        user = await conn.fetchrow("SELECT id, role FROM users WHERE mobile = $1", mobile)
        if not user:
            user_id = await conn.fetchval("""
                INSERT INTO users (mobile, email, role, is_active, otp_verified, created_at, updated_at)
                VALUES ($1, $2, 'VENDOR', true, true, NOW(), NOW())
                RETURNING id
            """, mobile, f"vendor_{mobile}@am5royal.com")
        else:
            user_id = user["id"]
            role = user["role"] or ""
            if "VENDOR" not in role:
                new_role = f"{role},VENDOR".strip(",")
                await conn.execute("UPDATE users SET role = $1 WHERE id = $2", new_role, user_id)
                
        # 2. Get or create vendor
        vendor = await conn.fetchrow("SELECT id FROM vendors WHERE user_id = $1", user_id)
        if not vendor:
            await conn.execute("""
                INSERT INTO vendors (
                    user_id, business_name, first_name, last_name, lead_source, 
                    status, feedback, payment_info, created_at, updated_at
                )
                VALUES ($1, $2, $3, $4, 'company', $5, $6, $7, NOW(), NOW())
            """, user_id, bname, first_name, last_name, status, feedback, payment_info)
            inserted_count += 1
        else:
            # Update existing vendor's feedback and payment_info
            await conn.execute("""
                UPDATE vendors 
                SET feedback = $1, payment_info = $2, lead_source = 'company'
                WHERE id = $3
            """, feedback, payment_info, vendor["id"])
            
    print(f"Import complete! Inserted {inserted_count} new vendor records, updated remaining.")
    await conn.close()

asyncio.run(main())
