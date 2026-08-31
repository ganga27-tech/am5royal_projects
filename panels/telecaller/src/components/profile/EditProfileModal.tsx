// ============================================================================
// AM5 ROYAL • Edit Profile & Bank Details Modal
// Strict, Crisp Production-Grade Validation for Profile & Banking Fields
// ============================================================================

import React, { useState } from 'react';
import { useAuth } from '../../auth/AuthContext';
import { authApi } from '../../api/authApi';
import { Validation } from '../../utils/validation';
import { extractErrorMessage } from '../../api/client';
import { X, CheckCircle2, AlertCircle, Building2, UserCheck, Loader2 } from 'lucide-react';

interface EditProfileModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSaved?: () => void;
}

export const EditProfileModal: React.FC<EditProfileModalProps> = ({
  isOpen,
  onClose,
  onSaved,
}) => {
  const { user, refreshProfile } = useAuth();

  const [formData, setFormData] = useState({
    firstName: user?.firstName || '',
    lastName: user?.lastName || '',
    email: user?.email || '',
    phoneNumber: user?.phoneNumber || '',
    bankName: user?.bankName || '',
    bankAccountNumber: user?.bankAccountNumber || '',
    bankAccountName: user?.bankAccountName || '',
    bankIfscCode: user?.bankIfscCode || '',
  });

  const [touched, setTouched] = useState<Record<string, boolean>>({});
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [serverError, setServerError] = useState<string | null>(null);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);

  if (!isOpen) return null;

  // Validate specific field
  const validateField = (name: string, value: string): string | undefined => {
    switch (name) {
      case 'firstName':
        return Validation.required(value, 'First Name').error;
      case 'email':
        return Validation.email(value, true).error;
      case 'phoneNumber':
        return Validation.mobile(value).error;
      case 'bankAccountName':
        if (value.trim() || formData.bankAccountNumber.trim()) {
          return Validation.required(value, 'Account Holder Name').error;
        }
        return undefined;
      case 'bankName':
        if (value.trim() || formData.bankAccountNumber.trim()) {
          return Validation.required(value, 'Bank Name').error;
        }
        return undefined;
      case 'bankAccountNumber':
        if (value.trim() || formData.bankName.trim()) {
          return Validation.bankAccount(value).error;
        }
        return undefined;
      case 'bankIfscCode':
        if (value.trim() || formData.bankAccountNumber.trim()) {
          return Validation.ifsc(value).error;
        }
        return undefined;
      default:
        return undefined;
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    let formattedValue = value;
    if (name === 'bankIfscCode') {
      formattedValue = value.toUpperCase();
    }

    setFormData((prev) => ({ ...prev, [name]: formattedValue }));

    if (touched[name]) {
      const err = validateField(name, formattedValue);
      setErrors((prev) => ({ ...prev, [name]: err || '' }));
    }
  };

  const handleBlur = (name: string) => {
    setTouched((prev) => ({ ...prev, [name]: true }));
    const err = validateField(name, (formData as any)[name]);
    setErrors((prev) => ({ ...prev, [name]: err || '' }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setServerError(null);
    setSuccessMsg(null);

    // Validate all fields
    const newErrors: Record<string, string> = {};
    Object.keys(formData).forEach((key) => {
      const err = validateField(key, (formData as any)[key]);
      if (err) newErrors[key] = err;
    });

    setErrors(newErrors);
    setTouched(
      Object.keys(formData).reduce((acc, k) => ({ ...acc, [k]: true }), {})
    );

    if (Object.values(newErrors).some((v) => Boolean(v))) {
      return;
    }

    setIsSubmitting(true);
    try {
      await authApi.updateEmployeeProfile({
        first_name: formData.firstName.trim(),
        last_name: formData.lastName.trim(),
        email: formData.email.trim(),
        phone_number: formData.phoneNumber.trim(),
        bank_name: formData.bankName.trim() || undefined,
        bank_account_number: formData.bankAccountNumber.trim() || undefined,
        bank_account_name: formData.bankAccountName.trim() || undefined,
        bank_ifsc_code: formData.bankIfscCode.trim() || undefined,
      });

      await refreshProfile();
      setSuccessMsg('Profile and banking credentials updated successfully!');
      setTimeout(() => {
        if (onSaved) onSaved();
        onClose();
      }, 1200);
    } catch (err) {
      setServerError(extractErrorMessage(err));
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 110,
        background: 'rgba(15, 23, 42, 0.5)',
        backdropFilter: 'blur(6px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '1.5rem',
      }}
    >
      <div
        className="card"
        style={{
          width: '100%',
          maxWidth: '560px',
          maxHeight: '90vh',
          display: 'flex',
          flexDirection: 'column',
          padding: 0,
          overflow: 'hidden',
          animation: 'fadeInDown 0.25s ease-out',
        }}
      >
        {/* Header */}
        <div
          style={{
            padding: '1.25rem 1.5rem',
            borderBottom: '1px solid var(--border-subtle)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            background: 'var(--bg-subtle)',
          }}
        >
          <div>
            <h3 style={{ fontSize: '1.15rem', color: 'var(--primary-dark)' }}>
              Telecaller Profile & Banking Settings
            </h3>
            <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
              Update your contact info and commission payout bank account
            </p>
          </div>
          <button
            onClick={onClose}
            style={{
              background: 'transparent',
              border: 'none',
              cursor: 'pointer',
              color: 'var(--text-muted)',
              padding: '0.25rem',
              borderRadius: '6px',
            }}
          >
            <X size={20} />
          </button>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSubmit} style={{ overflowY: 'auto', padding: '1.5rem' }}>
          {serverError && (
            <div
              style={{
                padding: '0.75rem 1rem',
                background: 'var(--danger-light)',
                border: '1px solid var(--danger-border)',
                borderRadius: 'var(--radius-md)',
                color: 'var(--danger)',
                fontSize: '0.85rem',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
                marginBottom: '1.25rem',
              }}
            >
              <AlertCircle size={18} flex-shrink={0} />
              <span>{serverError}</span>
            </div>
          )}

          {successMsg && (
            <div
              style={{
                padding: '0.75rem 1rem',
                background: 'var(--success-light)',
                border: '1px solid var(--success)',
                borderRadius: 'var(--radius-md)',
                color: 'var(--success)',
                fontSize: '0.85rem',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
                marginBottom: '1.25rem',
              }}
            >
              <CheckCircle2 size={18} flex-shrink={0} />
              <span>{successMsg}</span>
            </div>
          )}

          {/* Section 1: Personal Contact */}
          <div style={{ marginBottom: '1.5rem' }}>
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
                marginBottom: '0.85rem',
                color: 'var(--primary)',
                fontFamily: 'var(--font-heading)',
                fontWeight: 700,
                fontSize: '0.875rem',
                borderBottom: '1px solid var(--border-subtle)',
                paddingBottom: '0.4rem',
              }}
            >
              <UserCheck size={16} />
              <span>Personal Information</span>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.85rem' }}>
              <div className="form-group">
                <label className="form-label">
                  First Name <span className="required-star">*</span>
                </label>
                <input
                  type="text"
                  name="firstName"
                  className={`form-input ${touched.firstName && errors.firstName ? 'is-invalid' : ''}`}
                  value={formData.firstName}
                  onChange={handleChange}
                  onBlur={() => handleBlur('firstName')}
                  placeholder="e.g. Rahul"
                />
                {touched.firstName && errors.firstName && (
                  <div className="form-error-msg">{errors.firstName}</div>
                )}
              </div>

              <div className="form-group">
                <label className="form-label">Last Name</label>
                <input
                  type="text"
                  name="lastName"
                  className="form-input"
                  value={formData.lastName}
                  onChange={handleChange}
                  placeholder="e.g. Sharma"
                />
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.85rem' }}>
              <div className="form-group">
                <label className="form-label">
                  Email Address <span className="required-star">*</span>
                </label>
                <input
                  type="email"
                  name="email"
                  className={`form-input ${touched.email && errors.email ? 'is-invalid' : ''}`}
                  value={formData.email}
                  onChange={handleChange}
                  onBlur={() => handleBlur('email')}
                  placeholder="telecaller@am5royal.com"
                />
                {touched.email && errors.email && (
                  <div className="form-error-msg">{errors.email}</div>
                )}
              </div>

              <div className="form-group">
                <label className="form-label">
                  Phone Number <span className="required-star">*</span>
                </label>
                <input
                  type="tel"
                  name="phoneNumber"
                  className={`form-input ${touched.phoneNumber && errors.phoneNumber ? 'is-invalid' : ''}`}
                  value={formData.phoneNumber}
                  onChange={handleChange}
                  onBlur={() => handleBlur('phoneNumber')}
                  placeholder="10-digit mobile"
                  maxLength={10}
                />
                {touched.phoneNumber && errors.phoneNumber && (
                  <div className="form-error-msg">{errors.phoneNumber}</div>
                )}
              </div>
            </div>
          </div>

          {/* Section 2: Bank Details */}
          <div>
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
                marginBottom: '0.85rem',
                color: 'var(--gold)',
                fontFamily: 'var(--font-heading)',
                fontWeight: 700,
                fontSize: '0.875rem',
                borderBottom: '1px solid var(--border-subtle)',
                paddingBottom: '0.4rem',
              }}
            >
              <Building2 size={16} />
              <span>Payout Bank Account Details</span>
            </div>

            <div className="form-group">
              <label className="form-label">Account Holder Name</label>
              <input
                type="text"
                name="bankAccountName"
                className={`form-input ${touched.bankAccountName && errors.bankAccountName ? 'is-invalid' : ''}`}
                value={formData.bankAccountName}
                onChange={handleChange}
                onBlur={() => handleBlur('bankAccountName')}
                placeholder="Name as registered in Bank Passbook"
              />
              {touched.bankAccountName && errors.bankAccountName && (
                <div className="form-error-msg">{errors.bankAccountName}</div>
              )}
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.85rem' }}>
              <div className="form-group">
                <label className="form-label">Bank Name</label>
                <input
                  type="text"
                  name="bankName"
                  className={`form-input ${touched.bankName && errors.bankName ? 'is-invalid' : ''}`}
                  value={formData.bankName}
                  onChange={handleChange}
                  onBlur={() => handleBlur('bankName')}
                  placeholder="e.g. HDFC Bank, SBI"
                />
                {touched.bankName && errors.bankName && (
                  <div className="form-error-msg">{errors.bankName}</div>
                )}
              </div>

              <div className="form-group">
                <label className="form-label">IFSC Code</label>
                <input
                  type="text"
                  name="bankIfscCode"
                  className={`form-input ${touched.bankIfscCode && errors.bankIfscCode ? 'is-invalid' : ''}`}
                  value={formData.bankIfscCode}
                  onChange={handleChange}
                  onBlur={() => handleBlur('bankIfscCode')}
                  placeholder="e.g. HDFC0001234"
                  maxLength={11}
                />
                {touched.bankIfscCode && errors.bankIfscCode && (
                  <div className="form-error-msg">{errors.bankIfscCode}</div>
                )}
              </div>
            </div>

            <div className="form-group">
              <label className="form-label">Bank Account Number</label>
              <input
                type="password"
                name="bankAccountNumber"
                className={`form-input ${touched.bankAccountNumber && errors.bankAccountNumber ? 'is-invalid' : ''}`}
                value={formData.bankAccountNumber}
                onChange={handleChange}
                onBlur={() => handleBlur('bankAccountNumber')}
                placeholder="9 to 18 digit account number"
                maxLength={18}
              />
              {touched.bankAccountNumber && errors.bankAccountNumber && (
                <div className="form-error-msg">{errors.bankAccountNumber}</div>
              )}
            </div>
          </div>

          {/* Footer Actions */}
          <div
            style={{
              display: 'flex',
              justifyContent: 'flex-end',
              gap: '0.75rem',
              marginTop: '1.5rem',
              paddingTop: '1rem',
              borderTop: '1px solid var(--border-subtle)',
            }}
          >
            <button type="button" className="btn btn-outline" onClick={onClose} disabled={isSubmitting}>
              Cancel
            </button>
            <button type="submit" className="btn btn-primary" disabled={isSubmitting}>
              {isSubmitting ? (
                <>
                  <Loader2 size={16} className="spinner" />
                  <span>Saving Profile...</span>
                </>
              ) : (
                'Save Changes'
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
