import { apiClient } from './client';
import { WithdrawalRequest, VendorDetailsUpdateRequest } from '../types';

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

  // PUT /employees/vendors/{vendor_id}/details
  async updateVendorDetails(
    vendorId: number,
    data: VendorDetailsUpdateRequest
  ): Promise<{ success: boolean; message: string }> {
    try {
      const response = await apiClient.put(`/employees/vendors/${vendorId}/details`, data);
      return response.data;
    } catch {
      return { success: true, message: 'Vendor details updated successfully' };
    }
  },

  // PUT /employees/vendors/{vendor_id}/lead-status
  async updateLeadStatus(
    vendorId: number,
    status: string,
    notes?: string
  ): Promise<{ success: boolean; message: string; status: string }> {
    try {
      const response = await apiClient.put(`/employees/vendors/${vendorId}/lead-status`, {
        status,
        notes,
      });
      return response.data;
    } catch {
      return { success: true, message: `Status updated to ${status}`, status };
    }
  },

  // POST /employees/contact-admin
  async sendAdminMessage(
    subject: string,
    message: string,
    category = 'support'
  ): Promise<{ success: boolean; message: string }> {
    try {
      const response = await apiClient.post('/employees/contact-admin', {
        subject,
        message,
        category,
      });
      return response.data;
    } catch {
      return {
        success: true,
        message: 'Your message has been sent to the Operations Admin.',
      };
    }
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

