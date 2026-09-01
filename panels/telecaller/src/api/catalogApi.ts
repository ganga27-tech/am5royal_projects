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
    const response = await apiClient.post<any[]>('/vendor/catalog/sub-categories/services-batch', {
      sub_category_ids: subCategoryIds,
    });
    return (response.data || []).map((s) => ({
      id: s.id,
      title: s.title || s.name || '',
      description: s.description || '',
      main_category_id: s.main_category_id,
      sub_category_id: s.sub_category_id,
      base_price: s.base_price || s.price || 0,
    }));
  },
};
