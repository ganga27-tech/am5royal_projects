// ============================================================================
// AM5 ROYAL • Vendor Actions & Payouts API Layer
// Mirrors Flutter: employee_api_service.dart / employees.py
// ============================================================================

import { apiClient } from './client';
import { WithdrawalRequest } from '../types';

export const vendorActionsApi = {
  // PUT /employees/vendors/{vendor_id}/approve
  async approveVendor(vendorId: number): Promise<{ success: boolean; message: string }> {
    const response = await apiClient.put(`/employees/vendors/${vendorId}/approve`);
    return response.data;
  },

  // PUT /employees/vendors/{vendor_id}/reject
  async rejectVendor(vendorId: number): Promise<{ success: boolean; message: string }> {
    const response = await apiClient.put(`/employees/vendors/${vendorId}/reject`);
    return response.data;
  },

  // POST /employees/vendors/send-whatsapp-invite
  async sendWhatsAppInvite(phone: string, vendorName: string): Promise<{ success: boolean; message?: string }> {
    const response = await apiClient.post('/employees/vendors/send-whatsapp-invite', {
      phone_number: phone.trim(),
      vendor_name: vendorName.trim(),
    });
    return response.data;
  },

  // POST /employees/withdraw
  async requestWithdrawal(amount: number): Promise<WithdrawalRequest> {
    const response = await apiClient.post<WithdrawalRequest>('/employees/withdraw', {
      amount,
    });
    return response.data;
  },

  // GET /employees/withdrawals
  async getWithdrawals(): Promise<WithdrawalRequest[]> {
    const response = await apiClient.get<WithdrawalRequest[]>('/employees/withdrawals');
    return response.data;
  },
};
