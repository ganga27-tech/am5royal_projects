// ============================================================================
// AM5 ROYAL • Telecaller IVR Call API Service
// Connects React Telecaller actions to Secure Backend -> Airtel IQ Gateway
// ============================================================================

import { apiClient, extractErrorMessage } from './client';

export interface InitiateCallParams {
  vendorId?: number;
  phoneNumber: string;
}

export interface CallResponse {
  success: boolean;
  message: string;
  call_session_id?: string;
  target_phone?: string;
  agent_phone?: string;
}

export const callApi = {
  /**
   * Initiates an Airtel IQ Click-to-Call via our backend.
   * Authentication is handled automatically by attaching the Telecaller's JWT token.
   */
  async initiateCall(params: InitiateCallParams): Promise<CallResponse> {
    try {
      const response = await apiClient.post<CallResponse>(
        '/employees/telecaller-dashboard/call',
        {
          vendor_id: params.vendorId ?? null,
          phone_number: params.phoneNumber,
        }
      );
      return response.data;
    } catch (error) {
      const errorMsg = extractErrorMessage(error);
      return {
        success: false,
        message: errorMsg,
      };
    }
  },
};
