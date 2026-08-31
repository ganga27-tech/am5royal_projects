// ============================================================================
// AM5 ROYAL • Authentication API Layer
// Mirrors Flutter: auth_remote_data_source.dart / employees.py
// ============================================================================

import { apiClient } from './client';
import { EmployeeProfile, EmployeeUpdateRequest } from '../types';

export interface LoginResponse {
  access_token: string;
  token_type: string;
  role: string;
}

export const authApi = {
  // POST /employees/login
  async login(identifier: string, password: string): Promise<LoginResponse> {
    const response = await apiClient.post<LoginResponse>('/employees/login', {
      identifier: identifier.trim(),
      password,
    });
    return response.data;
  },

  // GET /employees/me
  async getCurrentEmployee(): Promise<EmployeeProfile> {
    const response = await apiClient.get<any>('/employees/me');
    const d = response.data;
    return {
      id: d.id,
      firstName: d.first_name || '',
      lastName: d.last_name || '',
      email: d.email || '',
      phoneNumber: d.phone_number || '',
      role: d.role || '',
      status: d.status || 'active',
      referralPoints: d.referral_points || 0,
      bankName: d.bank_name,
      bankAccountNumber: d.bank_account_number,
      bankAccountName: d.bank_account_name,
      bankIfscCode: d.bank_ifsc_code,
    };
  },

  // PUT /employees/me
  async updateEmployeeProfile(data: EmployeeUpdateRequest): Promise<EmployeeProfile> {
    const response = await apiClient.put<any>('/employees/me', data);
    const d = response.data;
    return {
      id: d.id,
      firstName: d.first_name || '',
      lastName: d.last_name || '',
      email: d.email || '',
      phoneNumber: d.phone_number || '',
      role: d.role || '',
      status: d.status || 'active',
      referralPoints: d.referral_points || 0,
      bankName: d.bank_name,
      bankAccountNumber: d.bank_account_number,
      bankAccountName: d.bank_account_name,
      bankIfscCode: d.bank_ifsc_code,
    };
  },
};
