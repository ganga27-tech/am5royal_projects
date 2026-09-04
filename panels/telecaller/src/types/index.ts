// ============================================================================
// AM5 ROYAL • Telecaller Operations Type Definitions
// ============================================================================

export interface EmployeeProfile {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber: string;
  role: string;
  status: string;
  referralPoints: number;
  bankName?: string | null;
  bankAccountNumber?: string | null;
  bankAccountName?: string | null;
  bankIfscCode?: string | null;
}

export interface EmployeeUpdateRequest {
  first_name?: string;
  last_name?: string;
  email?: string;
  phone_number?: string;
  bank_name?: string;
  bank_account_number?: string;
  bank_account_name?: string;
  bank_ifsc_code?: string;
}

export interface AuthSession {
  token: string;
  role: string;
  tokenType: string;
  user: EmployeeProfile | null;
}

export interface PointDetail {
  name: string;
  points: number;
}

export interface TelecallerDashboardStats {
  weeklyOnboardings: number;
  monthlyConversions: number;
  referralPoints: number;
  estimatedReferralPayout: number;
  monthlyPayoutBonus: number;
  withdrawableBalance: number;
  totalWithdrawn: number;
  telecallerPoints?: PointDetail | null;
  companyPoints?: PointDetail | null;
  freelancerPoints?: PointDetail[] | null;
}

export interface TelecallerOnboardedVendor {
  id: number;
  businessName: string;
  firstName: string;
  lastName: string;
  city: string;
  status: string;
  createdAt: string;
  mobileNumber: string;
  leadSource?: string | null;
  email?: string;
  username?: string;
  serviceName?: string;
  assignedTeamMember?: string;
  leadStatus?: string;
  hasServices?: boolean;
  hasRegistration?: boolean;
  hasSlots?: boolean;
  hasBusinessReg?: boolean;
  hasPayment?: boolean;
  isTempActive?: boolean;
  isActivated?: boolean;
}

export interface PaginatedOnboardedVendorsResponse {
  total: number;
  skip: number;
  limit: number;
  vendors: TelecallerOnboardedVendor[];
}

export interface VendorDetailsUpdateRequest {
  business_name?: string;
  first_name?: string;
  last_name?: string;
  email?: string;
  alternative_number?: string;
  city?: string;
  state?: string;
  pincode?: string;
  address?: string;
  aadhaar_number?: string;
  pan_number?: string;
  gst_number?: string;
  service_radius_km?: number;
}

export interface LeadPerformanceMetrics {
  total_leads: number;
  website_leads: number;
  application_leads: number;
  freelancer_leads: number;
  assigned_leads: number;
  contacted_leads: number;
  in_progress_leads: number;
  converted_leads: number;
  activated_vendors: number;
  pending_leads: number;
  closed_leads: number;
  conversion_rate: number;
}

export interface TeamNotification {
  id: string;
  type: 'new_lead' | 'lead_assigned' | 'reminder' | 'kyc_pending' | 'payment_pending' | 'admin';
  title: string;
  message: string;
  lead_id?: number | null;
  created_at: string;
  is_read: boolean;
}

export interface AdminContactMessageRequest {
  subject: string;
  message: string;
  category?: string;
}

export interface LeadActivityHistoryItem {
  stage: string;
  status: 'completed' | 'current' | 'pending';
  timestamp?: string;
  description?: string;
}

export interface WithdrawalRequest {
  id: number;
  employee_id: number;
  amount: number;
  status: 'pending' | 'approved' | 'rejected' | 'completed';
  created_at: string;
  updated_at?: string | null;
  admin_notes?: string | null;
}

export interface VerificationIncentive {
  id: number;
  vendorId: number;
  vendorName: string;
  subscriptionAmount: number;
  incentivePercent: number;
  incentiveAmount: number;
  paymentDate: string;
  planId?: number | null;
  planName?: string | null;
  employeeId?: number | null;
}

export interface TelecallerLeaderboardEntry {
  name: string;
  points: number;
}

// 7-step details modal structures
export interface VendorStepDetails {
  registration: {
    first_name: string;
    last_name: string;
    father_name: string;
    mobile_number: string;
    alternative_contact_number: string;
    email: string;
    city: string;
    state: string;
    pincode: string;
    address: string;
    created_at: string;
  };
  business_reg: {
    business_name: string;
    aadhaar_number: string;
    pan_number?: string | null;
    gst_number?: string | null;
    service_radius_km: number;
    documents: Array<{
      document_type: string;
      verification_status: string;
      document_url: string;
    }>;
  };
  services: Array<{
    title: string;
    description: string;
    price: number | null;
    discounted_price: number | null;
    main_category_name: string;
    sub_category_name?: string | null;
  }>;
  slots: Array<{
    day_name: string;
    start_time: string;
    end_time: string;
    is_available: boolean;
  }>;
  payment: {
    payment_info?: any;
    subscriptions: Array<{
      plan_name: string;
      payment_id: string;
      amount: number;
      status: string;
      start_date: string;
      end_date: string;
    }>;
  };
}

// Catalog types
export interface MainCategory {
  id: number;
  name: string;
  icon_url?: string;
  has_subcategories?: boolean;
}

export interface SubCategory {
  id: number;
  name: string;
  main_category_id: number;
  icon_url?: string;
}

export interface ServiceItem {
  id: number;
  title: string;
  description?: string;
  main_category_id: number;
  sub_category_id: number;
  base_price?: number;
}

// Lead Pipeline
export interface PipelineLead {
  id: string;
  name: string;
  phone: string;
  category: string;
  status: 'New' | 'Follow-up' | 'Not Interested';
  note: string;
  lastCalled: string;
}

export interface StuckVendor {
  id: string;
  businessName: string;
  ownerName: string;
  phone: string;
  stuckStage: string;
  lastActive: string;
  helperNote: string;
}
