# Revised Vendor Flow APIs

Based on your explanation and the specific condition for Home Services, here is the exact API flow for the Vendor Application's first few screens.

---

### Step 1: Authentication
1. **`POST /api/v1/vendor/auth/send-otp`**
   - **Input:** Mobile Number or Email.
   - **Action:** Generates and sends a 5-digit OTP.

2. **`POST /api/v1/vendor/auth/verify-otp`**
   - **Input:** Mobile/Email + 5-digit OTP.
   - **Action:** Verifies the OTP and returns login tokens.

3. **`POST /api/v1/vendor/auth/social-login`**
   - **Input:** Google/Social Media Auth Token.
   - **Action:** Verifies the token and logs the vendor in.

---

### Step 2: Map View (Vendor Locations)
4. **`GET /api/v1/vendors/locations`**
   - **Action:** Fetches the list of all active vendors across India.
   - **Returns:** Latitude, Longitude, and their corresponding Main Category Icon/Image so that they can be displayed on the map as bit markers.

---

### Step 3: Categories Selection Flow (Multi-Select Logic)
*Note: As per your condition, ONLY "Home Services" has sub-categories. Other main categories have direct services.*

5. **`GET /api/v1/categories/main`**
   - **Action:** Fetches all Main Categories (`id`, `name`, `image`, `has_subcategories: boolean`).
   - **Usage:** Vendor will see all main categories and pick one.

6. **`GET /api/v1/categories/main/{main_category_id}/sub-categories`**
   - **Action:** Called ONLY if the selected main category has sub-categories (i.e., Home Services).
   - **Returns:** List of sub-categories (e.g., AC Repair, Pest Control).
   - **Logic:** Vendor can select **MULTIPLE** sub-categories from here (e.g., both AC Repair and Pest Control).

7. **`GET /api/v1/categories/main/{main_category_id}/services`**
   - **Action:** Called ONLY if the selected main category does **not** have sub-categories (e.g., Real Estate).
   - **Returns:** Direct list of services under that main category. (Vendor can select multiple).

8. **`POST /api/v1/categories/sub/services-batch` (or multiple GETs)**
   - **Input:** Array of selected `sub_category_ids` (e.g., IDs for AC Repair & Pest Control).
   - **Returns:** All services under the selected sub-categories.
   - **Logic:** Vendor can select **MULTIPLE** services across their multiple selected sub-categories.

---
