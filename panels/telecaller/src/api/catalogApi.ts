// ============================================================================
// AM5 ROYAL • Catalog API Layer
// Mirrors Flutter: vendor_catalog.py
// ============================================================================

import { apiClient } from './client';
import { MainCategory, SubCategory, ServiceItem } from '../types';

export const catalogApi = {
  // GET /vendor/catalog/main-categories
  async getMainCategories(): Promise<MainCategory[]> {
    const response = await apiClient.get<any[]>('/vendor/catalog/main-categories');
    return (response.data || []).map((c) => ({
      id: c.id,
      name: c.name || c.title || '',
      icon_url: c.icon_url || c.image_url,
      has_subcategories: c.has_subcategories ?? true,
    }));
  },

  // GET /vendor/catalog/main-categories/{category_id}/sub-categories
  async getSubCategories(categoryId: number): Promise<SubCategory[]> {
    const response = await apiClient.get<any[]>(
      `/vendor/catalog/main-categories/${categoryId}/sub-categories`
    );
    return (response.data || []).map((s) => ({
      id: s.id,
      name: s.name || s.title || '',
      main_category_id: s.main_category_id || categoryId,
      icon_url: s.icon_url || s.image_url,
    }));
  },

  // POST /vendor/catalog/sub-categories/services-batch
  async getServicesBatch(subCategoryIds: number[]): Promise<ServiceItem[]> {
    if (!subCategoryIds || subCategoryIds.length === 0) return [];

    try {
      const response = await apiClient.post<any[]>('/vendor/catalog/sub-categories/services-batch', {
        sub_category_ids: subCategoryIds,
      });
      if (Array.isArray(response.data) && response.data.length > 0) {
        return response.data.map((s) => ({
          id: s.id,
          title: s.title || s.name || '',
          description: s.description || '',
          main_category_id: s.main_category_id,
          sub_category_id: s.sub_category_id,
          base_price: s.base_price || s.price || 500,
        }));
      }
    } catch (e) {
      console.warn('services-batch endpoint failed, attempting fallback to /catalog/services:', e);
    }

    // Fallback: fetch directly from /catalog/services for each subcategory
    try {
      const fallbackPromises = subCategoryIds.map((subId) =>
        apiClient.get<any[]>('/catalog/services', {
          params: { subcategory_id: subId, limit: 100 },
        })
      );
      const results = await Promise.all(fallbackPromises);
      const all: ServiceItem[] = [];
      const seen = new Set<number>();

      results.forEach((res) => {
        (res.data || []).forEach((s: any) => {
          if (!seen.has(s.id)) {
            seen.add(s.id);
            all.push({
              id: s.id,
              title: s.name || s.title || '',
              description: s.description || '',
              main_category_id: s.main_category_id || s.category_id,
              sub_category_id: s.sub_category_id || s.subcategory_id,
              base_price: s.base_price || s.price || 500,
            });
          }
        });
      });
      return all;
    } catch (fallbackErr) {
      console.error('Fallback /catalog/services error:', fallbackErr);
      return [];
    }
  },
};
