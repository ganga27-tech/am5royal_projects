import re

# 1. Update orders.py
with open("app/api/v1/endpoints/orders.py", "r", encoding="utf-8") as f:
    orders_content = f.read()

# We want to comment out:
# - get_my_orders
# - create_order
# - cancel_order
# - reschedule_order
# - calculate_order_amount
# - get_available_service_provider_slots
# - generate_otps

# Find the start of get_my_orders and the start of start_service
pos_start_customer = orders_content.find('@router.get("/", response_model=List[dict])')
pos_start_vendor = orders_content.find('class StartServiceRequest(BaseModel):')
if pos_start_vendor == -1:
    pos_start_vendor = orders_content.find('@router.post("/start")')

if pos_start_customer != -1 and pos_start_vendor != -1:
    customer_part = orders_content[pos_start_customer:pos_start_vendor]
    commented_customer = "\n".join(f"# {line}" if line.strip() else "#" for line in customer_part.splitlines())
    new_orders_content = (
        orders_content[:pos_start_customer]
        + "# ==========================================\n"
        + "# CUSTOMER ORDERS ENDPOINTS (COMMENTED OUT)\n"
        + "# ==========================================\n"
        + commented_customer
        + "\n\n"
        + orders_content[pos_start_vendor:]
    )
    with open("app/api/v1/endpoints/orders.py", "w", encoding="utf-8") as f:
        f.write(new_orders_content)
    print("orders.py updated successfully")

# 2. Update catalog.py
with open("app/api/v1/endpoints/catalog.py", "r", encoding="utf-8") as f:
    catalog_content = f.read()

# In catalog.py, customer endpoints:
# - get_categories_by_pincode
# - get_category_children
# - get_vendors
# - get_packages
# - get_vendor_categories
# - get_vendor_category_services
# - get_category_vendors
# - get_vendor_profile_id
# - get_vendor_services

# We can comment out the specific customer endpoints:
def comment_endpoint(code, start_marker, end_marker):
    start_pos = code.find(start_marker)
    if start_pos == -1:
        print(f"Could not find start marker: {start_marker}")
        return code
    if end_marker:
        end_pos = code.find(end_marker, start_pos)
        if end_pos == -1:
            print(f"Could not find end marker: {end_marker}")
            return code
    else:
        end_pos = len(code)
    
    target = code[start_pos:end_pos]
    commented = "\n".join(f"# {line}" if line.strip() else "#" for line in target.splitlines())
    header = "\n# ------------------------------------------\n# CUSTOMER CATALOG ENDPOINT (COMMENTED OUT)\n# ------------------------------------------\n"
    return code[:start_pos] + header + commented + ("\n\n" if end_marker else "\n") + code[end_pos:]

# 2a. get_categories_by_pincode and get_category_children and get_vendors
catalog_content = comment_endpoint(
    catalog_content,
    '@router.get("/categories/by-pincode"',
    '@router.get("/subcategories"'
)

# 2b. get_packages
catalog_content = comment_endpoint(
    catalog_content,
    '@router.get("/packages"',
    '@router.get("/services"'
)

# 2c. get_vendor_categories, get_vendor_category_services, get_category_vendors, get_vendor_profile_id, get_vendor_services
catalog_content = comment_endpoint(
    catalog_content,
    '@router.get("/vendors/{vendor_id}/categories"',
    None
)

with open("app/api/v1/endpoints/catalog.py", "w", encoding="utf-8") as f:
    f.write(catalog_content)
print("catalog.py updated successfully")
