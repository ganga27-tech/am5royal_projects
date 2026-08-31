// ============================================================================
// AM5 ROYAL • Production-Grade Validation Utilities
// Crisp, Clear, Real-time Validation for Telecaller Operations
// ============================================================================

export interface ValidationResult {
  isValid: boolean;
  error?: string;
}

export const Validation = {
  // Required Text
  required(value: string | number | null | undefined, fieldName = 'Field'): ValidationResult {
    if (value === null || value === undefined) {
      return { isValid: false, error: `${fieldName} is required` };
    }
    const str = String(value).trim();
    if (str.length === 0) {
      return { isValid: false, error: `${fieldName} is required` };
    }
    return { isValid: true };
  },

  // Indian Mobile Phone Number (10 digits starting with 6,7,8,9; handles +91 or 0 prefix)
  mobile(phone: string): ValidationResult {
    if (!phone || !phone.trim()) {
      return { isValid: false, error: 'Mobile number is required' };
    }
    const cleaned = phone.replace(/[\s\-()]/g, '');
    const standardFormat = cleaned.startsWith('+91')
      ? cleaned.slice(3)
      : cleaned.startsWith('0')
      ? cleaned.slice(1)
      : cleaned;

    if (!/^\d+$/.test(standardFormat)) {
      return { isValid: false, error: 'Mobile number must contain digits only' };
    }

    if (standardFormat.length !== 10) {
      return { isValid: false, error: `Must be exactly 10 digits (currently ${standardFormat.length})` };
    }

    if (!/^[6-9]/.test(standardFormat)) {
      return { isValid: false, error: 'Must start with 6, 7, 8, or 9' };
    }

    return { isValid: true };
  },

  // Clean formatted mobile to 10 digits
  cleanMobile(phone: string): string {
    const cleaned = phone.replace(/[\s\-()]/g, '');
    if (cleaned.startsWith('+91')) return cleaned.slice(3);
    if (cleaned.startsWith('0')) return cleaned.slice(1);
    return cleaned;
  },

  // Email Validation (RFC 5322 standard check)
  email(email: string, required = true): ValidationResult {
    if (!email || !email.trim()) {
      if (!required) return { isValid: true };
      return { isValid: false, error: 'Email address is required' };
    }
    const emailRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$/;
    if (!emailRegex.test(email.trim())) {
      return { isValid: false, error: 'Please enter a valid email address (e.g. name@example.com)' };
    }
    return { isValid: true };
  },

  // Password Validation
  password(password: string): ValidationResult {
    if (!password) {
      return { isValid: false, error: 'Password is required' };
    }
    if (password.length < 6) {
      return { isValid: false, error: 'Password must be at least 6 characters' };
    }
    return { isValid: true };
  },

  // Aadhaar Number (Exact 12 digits, cannot start with 0 or 1 per UIDAI)
  aadhaar(aadhaar: string, required = true): ValidationResult {
    if (!aadhaar || !aadhaar.trim()) {
      if (!required) return { isValid: true };
      return { isValid: false, error: 'Aadhaar number is required' };
    }
    const clean = aadhaar.replace(/[\s\-]/g, '');
    if (!/^\d+$/.test(clean)) {
      return { isValid: false, error: 'Aadhaar must contain numeric digits only' };
    }
    if (clean.length !== 12) {
      return { isValid: false, error: `Aadhaar must be exactly 12 digits (entered ${clean.length})` };
    }
    if (clean.startsWith('0') || clean.startsWith('1')) {
      return { isValid: false, error: 'Invalid Aadhaar: cannot start with 0 or 1' };
    }
    return { isValid: true };
  },

  // PAN Card (5 letters, 4 digits, 1 letter: e.g. ABCDE1234F)
  pan(pan: string, required = false): ValidationResult {
    if (!pan || !pan.trim()) {
      if (!required) return { isValid: true };
      return { isValid: false, error: 'PAN card number is required' };
    }
    const clean = pan.trim().toUpperCase();
    const panRegex = /^[A-Z]{5}[0-9]{4}[A-Z]{1}$/;
    if (!panRegex.test(clean)) {
      return { isValid: false, error: 'Invalid PAN format (expected e.g. ABCDE1234F)' };
    }
    return { isValid: true };
  },

  // GST Number (15 alphanumeric characters standard GSTIN format)
  gst(gst: string, required = false): ValidationResult {
    if (!gst || !gst.trim()) {
      if (!required) return { isValid: true };
      return { isValid: false, error: 'GST number is required' };
    }
    const clean = gst.trim().toUpperCase();
    const gstRegex = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/;
    if (!gstRegex.test(clean)) {
      return { isValid: false, error: 'Invalid GSTIN format (expected 15 characters, e.g. 29ABCDE1234F1Z5)' };
    }
    return { isValid: true };
  },

  // Bank IFSC Code (4 letters, 0, 6 alphanumeric: e.g. SBIN0001234)
  ifsc(ifsc: string): ValidationResult {
    if (!ifsc || !ifsc.trim()) {
      return { isValid: false, error: 'IFSC code is required' };
    }
    const clean = ifsc.trim().toUpperCase();
    const ifscRegex = /^[A-Z]{4}0[A-Z0-9]{6}$/;
    if (!ifscRegex.test(clean)) {
      return { isValid: false, error: 'Invalid IFSC code (e.g. SBIN0001234, 5th char must be 0)' };
    }
    return { isValid: true };
  },

  // Bank Account Number (9 to 18 digits)
  bankAccount(account: string): ValidationResult {
    if (!account || !account.trim()) {
      return { isValid: false, error: 'Account number is required' };
    }
    const clean = account.replace(/[\s\-]/g, '');
    if (!/^\d+$/.test(clean)) {
      return { isValid: false, error: 'Account number must contain digits only' };
    }
    if (clean.length < 9 || clean.length > 18) {
      return { isValid: false, error: 'Account number must be between 9 and 18 digits' };
    }
    return { isValid: true };
  },

  // Indian Pincode (6 digits, non-zero first digit)
  pincode(pin: string): ValidationResult {
    if (!pin || !pin.trim()) {
      return { isValid: false, error: 'Pincode is required' };
    }
    const clean = pin.trim();
    if (!/^[1-9][0-9]{5}$/.test(clean)) {
      return { isValid: false, error: 'Invalid pincode (must be a valid 6-digit postal code)' };
    }
    return { isValid: true };
  },

  // Service Radius (KM)
  radius(radius: string | number): ValidationResult {
    const num = typeof radius === 'number' ? radius : Number(radius);
    if (isNaN(num) || num <= 0) {
      return { isValid: false, error: 'Radius must be a positive number' };
    }
    if (num > 100) {
      return { isValid: false, error: 'Radius cannot exceed 100 km' };
    }
    return { isValid: true };
  },

  // Positive Currency Amount
  amount(amount: string | number, maxAvailable?: number): ValidationResult {
    if (amount === '' || amount === null || amount === undefined) {
      return { isValid: false, error: 'Amount is required' };
    }
    const num = typeof amount === 'number' ? amount : parseFloat(amount);
    if (isNaN(num) || num <= 0) {
      return { isValid: false, error: 'Amount must be greater than ₹0' };
    }
    if (maxAvailable !== undefined && num > maxAvailable) {
      return { isValid: false, error: `Amount cannot exceed available balance of ₹${maxAvailable.toLocaleString('en-IN')}` };
    }
    return { isValid: true };
  },
};
