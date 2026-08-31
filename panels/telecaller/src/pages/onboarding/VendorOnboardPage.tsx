// ============================================================================
// AM5 ROYAL • Onboarding Step 1: Partner Profile & Business Address
// Strict Production-Grade Validation for All Required & Formatted Inputs
// Mirrors Flutter: TelecallerVendorOnboardPage
// ============================================================================

import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { onboardingApi } from '../../api/onboardingApi';
import { Validation } from '../../utils/validation';
import { extractErrorMessage } from '../../api/client';
import {
  Store,
  User,
  Phone,
  Mail,
  MapPin,
  Compass,
  ArrowRight,
  ArrowLeft,
  AlertCircle,
  Loader2,
  FileText,
} from 'lucide-react';

export const VendorOnboardPage: React.FC = () => {
  const navigate = useNavigate();

  const [formData, setFormData] = useState({
    mobile: '',
    first_name: '',
    last_name: '',
    father_name: '',
    business_name: '',
    email: '',
    alternative_number: '',
    aadhaar_number: '',
    address: '',
    street: '',
    city: '',
    district: '',
    state: '',
    pincode: '',
    service_radius_km: '10',
  });

  const [touched, setTouched] = useState<Record<string, boolean>>({});
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [serverError, setServerError] = useState<string | null>(null);

  // Field validator
  const validateField = (name: string, value: string): string | undefined => {
    switch (name) {
      case 'mobile':
        return Validation.mobile(value).error;
      case 'first_name':
        return Validation.required(value, 'First Name').error;
      case 'last_name':
        return Validation.required(value, 'Last Name').error;
      case 'business_name':
        return Validation.required(value, 'Business Name').error;
      case 'email':
        return Validation.email(value, true).error;
      case 'alternative_number':
        if (value.trim()) return Validation.mobile(value).error;
        return undefined;
      case 'aadhaar_number':
        if (value.trim()) return Validation.aadhaar(value, false).error;
        return undefined;
      case 'address':
        return Validation.required(value, 'Address').error;
      case 'city':
        return Validation.required(value, 'City').error;
      case 'state':
        return Validation.required(value, 'State').error;
      case 'pincode':
        return Validation.pincode(value).error;
      case 'service_radius_km':
        return Validation.radius(value).error;
      default:
        return undefined;
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));

    if (touched[name]) {
      const err = validateField(name, value);
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

    // Validate all fields
    const newErrors: Record<string, string> = {};
    Object.keys(formData).forEach((k) => {
      const err = validateField(k, (formData as any)[k]);
      if (err) newErrors[k] = err;
    });

    setErrors(newErrors);
    setTouched(
      Object.keys(formData).reduce((acc, k) => ({ ...acc, [k]: true }), {})
    );

    if (Object.values(newErrors).some((v) => Boolean(v))) {
      const firstKey = Object.keys(newErrors)[0];
      const el = document.getElementsByName(firstKey)[0];
      if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' });
      return;
    }

    setIsSubmitting(true);
    try {
      await onboardingApi.saveProfile(formData.mobile.trim(), {
        first_name: formData.first_name.trim(),
        last_name: formData.last_name.trim(),
        father_name: formData.father_name.trim() || undefined,
        business_name: formData.business_name.trim(),
        email: formData.email.trim(),
        alternative_number: formData.alternative_number.trim() || undefined,
        aadhaar_number: formData.aadhaar_number.trim() || undefined,
        address: formData.address.trim(),
        street: formData.street.trim() || undefined,
        city: formData.city.trim(),
        district: formData.district.trim() || undefined,
        state: formData.state.trim(),
        pincode: formData.pincode.trim(),
        service_radius_km: parseInt(formData.service_radius_km, 10) || 10,
      });

      // Pass along mobile to step 2
      navigate('/onboard/categories', {
        state: {
          mobile: formData.mobile.trim(),
          businessName: formData.business_name.trim(),
        },
      });
    } catch (err) {
      setServerError(extractErrorMessage(err));
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div style={{ maxWidth: '840px', margin: '0 auto', paddingBottom: '3rem' }}>
      {/* Back button + Stepper Tracker Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
        <button
          className="btn btn-sm btn-outline"
          onClick={() => navigate('/')}
          style={{ gap: '0.4rem' }}
        >
          <ArrowLeft size={16} />
          <span>Exit to Dashboard</span>
        </button>

        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <span
            style={{
              width: '28px',
              height: '28px',
              borderRadius: '50%',
              background: 'var(--primary)',
              color: 'white',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '0.8rem',
              fontWeight: 700,
            }}
          >
            1
          </span>
          <span style={{ fontSize: '0.85rem', fontWeight: 700, color: 'var(--primary)' }}>
            Step 1: Profile & Business
          </span>
          <span style={{ color: 'var(--text-subtle)' }}>→</span>
          <span style={{ fontSize: '0.85rem', color: 'var(--text-subtle)' }}>Step 2: Categories</span>
          <span style={{ color: 'var(--text-subtle)' }}>→</span>
          <span style={{ fontSize: '0.85rem', color: 'var(--text-subtle)' }}>Step 3: Services & Pricing</span>
        </div>
      </div>

      <div className="card" style={{ padding: '2.5rem' }}>
        <div style={{ marginBottom: '1.75rem', borderBottom: '1px solid var(--border-subtle)', paddingBottom: '1rem' }}>
          <h2 style={{ fontSize: '1.5rem', color: 'var(--text-main)' }}>Register New Partner</h2>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem', marginTop: '0.25rem' }}>
            Complete initial profile creation to begin category and catalog assignment
          </p>
        </div>

        {serverError && (
          <div
            style={{
              padding: '0.85rem 1rem',
              background: 'var(--danger-light)',
              border: '1px solid var(--danger-border)',
              borderRadius: 'var(--radius-md)',
              color: 'var(--danger)',
              fontSize: '0.85rem',
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem',
              marginBottom: '1.5rem',
            }}
          >
            <AlertCircle size={18} flex-shrink={0} />
            <span>{serverError}</span>
          </div>
        )}

        <form onSubmit={handleSubmit}>
          {/* Section A: Contact Credentials */}
          <div style={{ marginBottom: '2rem' }}>
            <h4
              style={{
                fontSize: '1rem',
                color: 'var(--primary)',
                marginBottom: '1rem',
                display: 'flex',
                alignItems: 'center',
                gap: '0.4rem',
              }}
            >
              <Phone size={16} />
              <span>Contact & Identity Credentials</span>
            </h4>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
              <div className="form-group">
                <label className="form-label">
                  Primary Mobile Number <span className="required-star">*</span>
                </label>
                <input
                  type="tel"
                  name="mobile"
                  className={`form-input ${touched.mobile && errors.mobile ? 'is-invalid' : ''}`}
                  placeholder="10-digit mobile number"
                  value={formData.mobile}
                  onChange={handleChange}
                  onBlur={() => handleBlur('mobile')}
                  maxLength={10}
                />
                {touched.mobile && errors.mobile && (
                  <div className="form-error-msg">{errors.mobile}</div>
                )}
              </div>

              <div className="form-group">
                <label className="form-label">Alternative Phone (Optional)</label>
                <input
                  type="tel"
                  name="alternative_number"
                  className={`form-input ${
                    touched.alternative_number && errors.alternative_number ? 'is-invalid' : ''
                  }`}
                  placeholder="Optional secondary phone"
                  value={formData.alternative_number}
                  onChange={handleChange}
                  onBlur={() => handleBlur('alternative_number')}
                  maxLength={10}
                />
                {touched.alternative_number && errors.alternative_number && (
                  <div className="form-error-msg">{errors.alternative_number}</div>
                )}
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '1rem' }}>
              <div className="form-group">
                <label className="form-label">
                  First Name <span className="required-star">*</span>
                </label>
                <input
                  type="text"
                  name="first_name"
                  className={`form-input ${touched.first_name && errors.first_name ? 'is-invalid' : ''}`}
                  placeholder="First name"
                  value={formData.first_name}
                  onChange={handleChange}
                  onBlur={() => handleBlur('first_name')}
                />
                {touched.first_name && errors.first_name && (
                  <div className="form-error-msg">{errors.first_name}</div>
                )}
              </div>

              <div className="form-group">
                <label className="form-label">
                  Last Name <span className="required-star">*</span>
                </label>
                <input
                  type="text"
                  name="last_name"
                  className={`form-input ${touched.last_name && errors.last_name ? 'is-invalid' : ''}`}
                  placeholder="Last name"
                  value={formData.last_name}
                  onChange={handleChange}
                  onBlur={() => handleBlur('last_name')}
                />
                {touched.last_name && errors.last_name && (
                  <div className="form-error-msg">{errors.last_name}</div>
                )}
              </div>

              <div className="form-group">
                <label className="form-label">Father's Name</label>
                <input
                  type="text"
                  name="father_name"
                  className="form-input"
                  placeholder="Father's name"
                  value={formData.father_name}
                  onChange={handleChange}
                />
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
              <div className="form-group">
                <label className="form-label">
                  Email Address <span className="required-star">*</span>
                </label>
                <input
                  type="email"
                  name="email"
                  className={`form-input ${touched.email && errors.email ? 'is-invalid' : ''}`}
                  placeholder="partner@example.com"
                  value={formData.email}
                  onChange={handleChange}
                  onBlur={() => handleBlur('email')}
                />
                {touched.email && errors.email && (
                  <div className="form-error-msg">{errors.email}</div>
                )}
              </div>

              <div className="form-group">
                <label className="form-label">Aadhaar Card (12 Digits)</label>
                <input
                  type="text"
                  name="aadhaar_number"
                  className={`form-input ${
                    touched.aadhaar_number && errors.aadhaar_number ? 'is-invalid' : ''
                  }`}
                  placeholder="12-digit Aadhaar number"
                  value={formData.aadhaar_number}
                  onChange={handleChange}
                  onBlur={() => handleBlur('aadhaar_number')}
                  maxLength={12}
                />
                {touched.aadhaar_number && errors.aadhaar_number && (
                  <div className="form-error-msg">{errors.aadhaar_number}</div>
                )}
              </div>
            </div>
          </div>

          {/* Section B: Business & Location */}
          <div style={{ marginBottom: '2rem' }}>
            <h4
              style={{
                fontSize: '1rem',
                color: 'var(--primary)',
                marginBottom: '1rem',
                display: 'flex',
                alignItems: 'center',
                gap: '0.4rem',
              }}
            >
              <Store size={16} />
              <span>Business Profile & Operational Radius</span>
            </h4>

            <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '1rem' }}>
              <div className="form-group">
                <label className="form-label">
                  Business Name <span className="required-star">*</span>
                </label>
                <input
                  type="text"
                  name="business_name"
                  className={`form-input ${
                    touched.business_name && errors.business_name ? 'is-invalid' : ''
                  }`}
                  placeholder="e.g. Royal Auto Care & Services"
                  value={formData.business_name}
                  onChange={handleChange}
                  onBlur={() => handleBlur('business_name')}
                />
                {touched.business_name && errors.business_name && (
                  <div className="form-error-msg">{errors.business_name}</div>
                )}
              </div>

              <div className="form-group">
                <label className="form-label">
                  Service Radius (KM) <span className="required-star">*</span>
                </label>
                <input
                  type="number"
                  name="service_radius_km"
                  className={`form-input ${
                    touched.service_radius_km && errors.service_radius_km ? 'is-invalid' : ''
                  }`}
                  value={formData.service_radius_km}
                  onChange={handleChange}
                  onBlur={() => handleBlur('service_radius_km')}
                  min="1"
                  max="100"
                />
                {touched.service_radius_km && errors.service_radius_km && (
                  <div className="form-error-msg">{errors.service_radius_km}</div>
                )}
              </div>
            </div>

            <div className="form-group">
              <label className="form-label">
                Full Street Address <span className="required-star">*</span>
              </label>
              <input
                type="text"
                name="address"
                className={`form-input ${touched.address && errors.address ? 'is-invalid' : ''}`}
                placeholder="Shop No., Complex, Landmark, Main Road"
                value={formData.address}
                onChange={handleChange}
                onBlur={() => handleBlur('address')}
              />
              {touched.address && errors.address && (
                <div className="form-error-msg">{errors.address}</div>
              )}
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '0.85rem' }}>
              <div className="form-group">
                <label className="form-label">Street / Area</label>
                <input
                  type="text"
                  name="street"
                  className="form-input"
                  placeholder="e.g. MG Road"
                  value={formData.street}
                  onChange={handleChange}
                />
              </div>

              <div className="form-group">
                <label className="form-label">
                  City <span className="required-star">*</span>
                </label>
                <input
                  type="text"
                  name="city"
                  className={`form-input ${touched.city && errors.city ? 'is-invalid' : ''}`}
                  placeholder="City"
                  value={formData.city}
                  onChange={handleChange}
                  onBlur={() => handleBlur('city')}
                />
                {touched.city && errors.city && <div className="form-error-msg">{errors.city}</div>}
              </div>

              <div className="form-group">
                <label className="form-label">
                  State <span className="required-star">*</span>
                </label>
                <input
                  type="text"
                  name="state"
                  className={`form-input ${touched.state && errors.state ? 'is-invalid' : ''}`}
                  placeholder="State"
                  value={formData.state}
                  onChange={handleChange}
                  onBlur={() => handleBlur('state')}
                />
                {touched.state && errors.state && (
                  <div className="form-error-msg">{errors.state}</div>
                )}
              </div>

              <div className="form-group">
                <label className="form-label">
                  Pincode <span className="required-star">*</span>
                </label>
                <input
                  type="text"
                  name="pincode"
                  className={`form-input ${touched.pincode && errors.pincode ? 'is-invalid' : ''}`}
                  placeholder="6 digits"
                  value={formData.pincode}
                  onChange={handleChange}
                  onBlur={() => handleBlur('pincode')}
                  maxLength={6}
                />
                {touched.pincode && errors.pincode && (
                  <div className="form-error-msg">{errors.pincode}</div>
                )}
              </div>
            </div>
          </div>

          {/* Action Button */}
          <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '1rem' }}>
            <button
              type="submit"
              className="btn btn-primary"
              disabled={isSubmitting}
              style={{ padding: '0.85rem 2rem' }}
            >
              {isSubmitting ? (
                <>
                  <Loader2 size={18} className="spinner" />
                  <span>Saving Profile...</span>
                </>
              ) : (
                <>
                  <span>Save & Proceed to Categories</span>
                  <ArrowRight size={18} />
                </>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
