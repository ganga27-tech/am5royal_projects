// ============================================================================
// AM5 ROYAL • Telecaller Vendor Onboarding Multi-Step API Layer
// Mirrors Flutter: telecallerSaveProfile, telecallerSaveCategoryServices, telecallerCompleteOnboarding
// ============================================================================

import { apiClient } from './client';

export interface VendorProfilePayload {
  first_name: string;
  last_name: string;
  father_name?: string;
  email?: string;
  alternative_number?: string;
  business_name: string;
  aadhaar_number?: string;
  address: string;
  street?: string;
  city: string;
  district?: string;
  state: string;
  pincode: string;
  latitude?: number;
  longitude?: number;
  service_radius_km?: number;
  profile_image?: string;
}

export interface CategorySelectionPayload {
  main_category_id: number;
  sub_category_ids: number[];
}

export interface ServiceSelectionPayload {
  service_id: number;
  amount: number;
  discounted_amount?: number;
  is_negotiable?: boolean;
}

export const onboardingApi = {
  // Step 1: POST /employees/vendors/telecaller-onboard/profile?mobile={mobile}
  async saveProfile(mobile: string, profile: VendorProfilePayload): Promise<any> {
    const response = await apiClient.post('/employees/vendors/telecaller-onboard/profile', profile, {
      params: { mobile: mobile.trim() },
    });
    return response.data;
  },

  // Step 2: POST /employees/vendors/telecaller-onboard/category-services?mobile={mobile}
  async saveCategoryServices(
    mobile: string,
    categories: CategorySelectionPayload[],
    services: ServiceSelectionPayload[]
  ): Promise<any> {
    const response = await apiClient.post(
      '/employees/vendors/telecaller-onboard/category-services',
      {
        categories,
        services,
      },
      {
        params: { mobile: mobile.trim() },
      }
    );
    return response.data;
  },

  // Step 3: POST /employees/vendors/telecaller-onboard/complete?mobile={mobile}
  async completeOnboarding(mobile: string): Promise<any> {
    const response = await apiClient.post(
      '/employees/vendors/telecaller-onboard/complete',
      {},
      {
        params: { mobile: mobile.trim() },
      }
    );
    return response.data;
  },
};
