// ============================================================================
// AM5 ROYAL • Onboarding Step 1: Partner Profile & Business Address
// Luxurious, Hardware-Accelerated Design with Multi-Step Visual Progression
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
  PhoneCall,
  Mail,
  MapPin,
  Compass,
  ArrowRight,
  ArrowLeft,
  AlertCircle,
  Loader2,
  ShieldCheck,
  Building2,
  Sparkles,
  CheckCircle2,
  Layers,
  Lock,
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

      // Pass along to step 2
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

  const radiusPresets = ['5', '10', '15', '25', '50'];

  return (
    <div style={{ maxWidth: '920px', margin: '0 auto', padding: '0 0.5rem 4rem 0.5rem' }}>
      {/* Top Header Bar: Exit Button & Visual Multi-Step Tracker */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          flexWrap: 'wrap',
          gap: '1rem',
          marginBottom: '2rem',
          padding: '0.75rem 1.25rem',
          background: 'rgba(255, 255, 255, 0.85)',
          backdropFilter: 'blur(12px)',
          borderRadius: 'var(--radius-lg)',
          border: '1px solid var(--border-subtle)',
          boxShadow: 'var(--shadow-sm)',
        }}
      >
        <button
          className="btn btn-sm btn-outline"
          onClick={() => navigate('/')}
          style={{
            gap: '0.45rem',
            background: 'white',
            fontWeight: 600,
            fontSize: '0.825rem',
            padding: '0.45rem 0.95rem',
          }}
        >
          <ArrowLeft size={16} />
          <span>Exit to Dashboard</span>
        </button>

        {/* Enhanced 3-Step Interactive Breadcrumb */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          {/* Step 1 */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <div
              style={{
                width: '28px',
                height: '28px',
                borderRadius: '50%',
                background: 'linear-gradient(135deg, var(--primary) 0%, #312e81 100%)',
                color: 'white',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '0.75rem',
                fontWeight: 700,
                boxShadow: '0 2px 8px var(--primary-glow)',
              }}
            >
              1
            </div>
            <span style={{ fontSize: '0.825rem', fontWeight: 700, color: 'var(--primary)' }}>
              Profile & Identity
            </span>
          </div>

          <span style={{ color: 'var(--border-strong)', fontSize: '0.85rem' }}>—</span>

          {/* Step 2 */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.45rem', opacity: 0.65 }}>
            <div
              style={{
                width: '26px',
                height: '26px',
                borderRadius: '50%',
                background: '#e2e8f0',
                color: 'var(--text-muted)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '0.75rem',
                fontWeight: 700,
              }}
            >
              2
            </div>
            <span style={{ fontSize: '0.8rem', fontWeight: 600, color: 'var(--text-muted)' }}>
              Categories
            </span>
          </div>

          <span style={{ color: 'var(--border-strong)', fontSize: '0.85rem' }}>—</span>

          {/* Step 3 */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.45rem', opacity: 0.65 }}>
            <div
              style={{
                width: '26px',
                height: '26px',
                borderRadius: '50%',
                background: '#e2e8f0',
                color: 'var(--text-muted)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '0.75rem',
                fontWeight: 700,
              }}
            >
              3
            </div>
            <span style={{ fontSize: '0.8rem', fontWeight: 600, color: 'var(--text-muted)' }}>
              Services & Pricing
            </span>
          </div>
        </div>
      </div>

      {/* Hero Welcome Banner */}
      <div
        style={{
          background: 'linear-gradient(135deg, #1e1b4b 0%, #312e81 60%, #4338ca 100%)',
          borderRadius: 'var(--radius-xl)',
          padding: '2.25rem 2.5rem',
          color: 'white',
          marginBottom: '1.75rem',
          position: 'relative',
          overflow: 'hidden',
          boxShadow: 'var(--shadow-lg)',
        }}
      >
        {/* Subtle decorative glow circles */}
        <div
          style={{
            position: 'absolute',
            top: '-40px',
            right: '-40px',
            width: '180px',
            height: '180px',
            borderRadius: '50%',
            background: 'radial-gradient(circle, rgba(252, 211, 77, 0.25) 0%, transparent 70%)',
            pointerEvents: 'none',
          }}
        />

        <div style={{ position: 'relative', zIndex: 2 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem', marginBottom: '0.5rem' }}>
            <span
              style={{
                padding: '0.2rem 0.65rem',
                borderRadius: '9999px',
                background: 'rgba(255, 255, 255, 0.15)',
                backdropFilter: 'blur(8px)',
                fontSize: '0.725rem',
                fontWeight: 700,
                letterSpacing: '0.06em',
                textTransform: 'uppercase',
                display: 'flex',
                alignItems: 'center',
                gap: '0.35rem',
              }}
            >
              <Sparkles size={12} color="#fcd34d" />
              Onboarding Pipeline • Step 1 of 3
            </span>
            <span
              style={{
                fontSize: '0.725rem',
                color: 'rgba(255, 255, 255, 0.7)',
                fontWeight: 500,
              }}
            >
              Est. time: ~2 mins
            </span>
          </div>

          <h1 style={{ fontSize: '1.85rem', fontWeight: 800, color: 'white', letterSpacing: '-0.02em' }}>
            Register New Partner
          </h1>
          <p
            style={{
              color: 'rgba(255, 255, 255, 0.85)',
              fontSize: '0.925rem',
              marginTop: '0.35rem',
              maxWidth: '650px',
              lineHeight: 1.5,
            }}
          >
            Create the primary partner record, identity credentials, and operational radius to
            authorize catalog assignment and background verification.
          </p>
        </div>
      </div>

      {serverError && (
        <div
          style={{
            padding: '1rem 1.25rem',
            background: 'var(--danger-light)',
            border: '1.5px solid var(--danger-border)',
            borderRadius: 'var(--radius-md)',
            color: 'var(--danger)',
            fontSize: '0.875rem',
            display: 'flex',
            alignItems: 'center',
            gap: '0.65rem',
            marginBottom: '1.5rem',
          }}
        >
          <AlertCircle size={20} style={{ flexShrink: 0 }} />
          <div>
            <strong>Validation Notice:</strong> {serverError}
          </div>
        </div>
      )}

      <form onSubmit={handleSubmit}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
          {/* Card 1: Contact & Identity Credentials */}
          <div
            className="card"
            style={{
              padding: '1.75rem',
              background: 'white',
              borderRadius: 'var(--radius-lg)',
              border: '1px solid var(--border-subtle)',
              boxShadow: 'var(--shadow-sm)',
            }}
          >
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '0.65rem',
                marginBottom: '1.5rem',
                borderBottom: '1px solid var(--border-subtle)',
                paddingBottom: '1rem',
              }}
            >
              <div
                style={{
                  width: '36px',
                  height: '36px',
                  borderRadius: '10px',
                  background: 'var(--primary-light)',
                  color: 'var(--primary)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <Phone size={18} />
              </div>
              <div>
                <h3 style={{ fontSize: '1.05rem', color: 'var(--text-main)' }}>
                  Contact & Identity Credentials
                </h3>
                <p style={{ fontSize: '0.775rem', color: 'var(--text-muted)' }}>
                  Essential phone numbers and legal identity information
                </p>
              </div>
            </div>

            {/* Row 1: Mobile Numbers */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '1.25rem' }}>
              <div className="form-group">
                <label className="form-label">
                  Primary Mobile Number <span className="required-star">*</span>
                </label>
                <div className="form-control-wrapper">
                  <Phone size={17} className="input-icon-left" />
                  <input
                    type="tel"
                    name="mobile"
                    className={`form-input has-left-icon ${
                      touched.mobile && errors.mobile ? 'is-invalid' : ''
                    }`}
                    placeholder="10-digit mobile number"
                    value={formData.mobile}
                    onChange={handleChange}
                    onBlur={() => handleBlur('mobile')}
                    maxLength={10}
                  />
                </div>
                {touched.mobile && errors.mobile && (
                  <div className="form-error-msg">{errors.mobile}</div>
                )}
              </div>

              <div className="form-group">
                <label className="form-label">Alternative Phone (Optional)</label>
                <div className="form-control-wrapper">
                  <PhoneCall size={17} className="input-icon-left" />
                  <input
                    type="tel"
                    name="alternative_number"
                    className={`form-input has-left-icon ${
                      touched.alternative_number && errors.alternative_number ? 'is-invalid' : ''
                    }`}
                    placeholder="Secondary contact number"
                    value={formData.alternative_number}
                    onChange={handleChange}
                    onBlur={() => handleBlur('alternative_number')}
                    maxLength={10}
                  />
                </div>
                {touched.alternative_number && errors.alternative_number && (
                  <div className="form-error-msg">{errors.alternative_number}</div>
                )}
              </div>
            </div>

            {/* Row 2: Names */}
            <div
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
                gap: '1.25rem',
                marginTop: '1rem',
              }}
            >
              <div className="form-group">
                <label className="form-label">
                  First Name <span className="required-star">*</span>
                </label>
                <div className="form-control-wrapper">
                  <User size={17} className="input-icon-left" />
                  <input
                    type="text"
                    name="first_name"
                    className={`form-input has-left-icon ${
                      touched.first_name && errors.first_name ? 'is-invalid' : ''
                    }`}
                    placeholder="Partner first name"
                    value={formData.first_name}
                    onChange={handleChange}
                    onBlur={() => handleBlur('first_name')}
                  />
                </div>
                {touched.first_name && errors.first_name && (
                  <div className="form-error-msg">{errors.first_name}</div>
                )}
              </div>

              <div className="form-group">
                <label className="form-label">
                  Last Name <span className="required-star">*</span>
                </label>
                <div className="form-control-wrapper">
                  <User size={17} className="input-icon-left" />
                  <input
                    type="text"
                    name="last_name"
                    className={`form-input has-left-icon ${
                      touched.last_name && errors.last_name ? 'is-invalid' : ''
                    }`}
                    placeholder="Surname / Family name"
                    value={formData.last_name}
                    onChange={handleChange}
                    onBlur={() => handleBlur('last_name')}
                  />
                </div>
                {touched.last_name && errors.last_name && (
                  <div className="form-error-msg">{errors.last_name}</div>
                )}
              </div>

              <div className="form-group">
                <label className="form-label">Father's Name (Optional)</label>
                <div className="form-control-wrapper">
                  <User size={17} className="input-icon-left" />
                  <input
                    type="text"
                    name="father_name"
                    className="form-input has-left-icon"
                    placeholder="Father's full name"
                    value={formData.father_name}
                    onChange={handleChange}
                  />
                </div>
              </div>
            </div>

            {/* Row 3: Email & Aadhaar */}
            <div
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
                gap: '1.25rem',
                marginTop: '1rem',
              }}
            >
              <div className="form-group">
                <label className="form-label">
                  Email Address <span className="required-star">*</span>
                </label>
                <div className="form-control-wrapper">
                  <Mail size={17} className="input-icon-left" />
                  <input
                    type="email"
                    name="email"
                    className={`form-input has-left-icon ${
                      touched.email && errors.email ? 'is-invalid' : ''
                    }`}
                    placeholder="partner@example.com"
                    value={formData.email}
                    onChange={handleChange}
                    onBlur={() => handleBlur('email')}
                  />
                </div>
                {touched.email && errors.email && (
                  <div className="form-error-msg">{errors.email}</div>
                )}
              </div>

              <div className="form-group">
                <label className="form-label">
                  Aadhaar Card (12 Digits)
                  <span style={{ fontSize: '0.725rem', color: 'var(--text-subtle)', fontWeight: 400 }}>
                    (Optional for draft)
                  </span>
                </label>
                <div className="form-control-wrapper">
                  <ShieldCheck size={17} className="input-icon-left" />
                  <input
                    type="text"
                    name="aadhaar_number"
                    className={`form-input has-left-icon ${
                      touched.aadhaar_number && errors.aadhaar_number ? 'is-invalid' : ''
                    }`}
                    placeholder="12-digit Aadhaar number"
                    value={formData.aadhaar_number}
                    onChange={handleChange}
                    onBlur={() => handleBlur('aadhaar_number')}
                    maxLength={12}
                  />
                </div>
                {touched.aadhaar_number && errors.aadhaar_number && (
                  <div className="form-error-msg">{errors.aadhaar_number}</div>
                )}
              </div>
            </div>
          </div>

          {/* Card 2: Business Profile & Operational Radius */}
          <div
            className="card"
            style={{
              padding: '1.75rem',
              background: 'white',
              borderRadius: 'var(--radius-lg)',
              border: '1px solid var(--border-subtle)',
              boxShadow: 'var(--shadow-sm)',
            }}
          >
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '0.65rem',
                marginBottom: '1.5rem',
                borderBottom: '1px solid var(--border-subtle)',
                paddingBottom: '1rem',
              }}
            >
              <div
                style={{
                  width: '36px',
                  height: '36px',
                  borderRadius: '10px',
                  background: 'rgba(13, 148, 136, 0.12)',
                  color: 'var(--secondary)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <Store size={18} />
              </div>
              <div>
                <h3 style={{ fontSize: '1.05rem', color: 'var(--text-main)' }}>
                  Business Profile & Operational Radius
                </h3>
                <p style={{ fontSize: '0.775rem', color: 'var(--text-muted)' }}>
                  Brand name and customer servicing distance
                </p>
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '1.25rem' }}>
              <div className="form-group">
                <label className="form-label">
                  Business Name <span className="required-star">*</span>
                </label>
                <div className="form-control-wrapper">
                  <Building2 size={17} className="input-icon-left" />
                  <input
                    type="text"
                    name="business_name"
                    className={`form-input has-left-icon ${
                      touched.business_name && errors.business_name ? 'is-invalid' : ''
                    }`}
                    placeholder="e.g. Royal Auto Care & Services"
                    value={formData.business_name}
                    onChange={handleChange}
                    onBlur={() => handleBlur('business_name')}
                  />
                </div>
                {touched.business_name && errors.business_name && (
                  <div className="form-error-msg">{errors.business_name}</div>
                )}
              </div>

              {/* Service Radius with Quick Preset Buttons */}
              <div className="form-group">
                <label className="form-label">
                  Service Radius (KM) <span className="required-star">*</span>
                </label>
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.45rem' }}>
                  {radiusPresets.map((r) => {
                    const isSelected = formData.service_radius_km === r;
                    return (
                      <button
                        key={r}
                        type="button"
                        onClick={() => setFormData((prev) => ({ ...prev, service_radius_km: r }))}
                        style={{
                          flex: 1,
                          padding: '0.65rem 0.25rem',
                          borderRadius: '8px',
                          border: '1.5px solid',
                          borderColor: isSelected ? 'var(--secondary)' : 'var(--border-subtle)',
                          background: isSelected ? 'var(--secondary-light)' : 'white',
                          color: isSelected ? 'var(--secondary)' : 'var(--text-main)',
                          fontFamily: 'var(--font-heading)',
                          fontSize: '0.8rem',
                          fontWeight: isSelected ? 700 : 500,
                          cursor: 'pointer',
                          transition: 'all 0.15s ease',
                        }}
                      >
                        {r} km
                      </button>
                    );
                  })}
                  <div style={{ width: '80px' }}>
                    <input
                      type="number"
                      name="service_radius_km"
                      className="form-input"
                      style={{ padding: '0.65rem 0.5rem', textAlign: 'center', fontSize: '0.85rem' }}
                      value={formData.service_radius_km}
                      onChange={handleChange}
                      min="1"
                      max="100"
                    />
                  </div>
                </div>
                {touched.service_radius_km && errors.service_radius_km && (
                  <div className="form-error-msg">{errors.service_radius_km}</div>
                )}
              </div>
            </div>
          </div>

          {/* Card 3: Location & Operating Address */}
          <div
            className="card"
            style={{
              padding: '1.75rem',
              background: 'white',
              borderRadius: 'var(--radius-lg)',
              border: '1px solid var(--border-subtle)',
              boxShadow: 'var(--shadow-sm)',
            }}
          >
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '0.65rem',
                marginBottom: '1.5rem',
                borderBottom: '1px solid var(--border-subtle)',
                paddingBottom: '1rem',
              }}
            >
              <div
                style={{
                  width: '36px',
                  height: '36px',
                  borderRadius: '10px',
                  background: 'rgba(217, 119, 6, 0.12)',
                  color: 'var(--gold)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <MapPin size={18} />
              </div>
              <div>
                <h3 style={{ fontSize: '1.05rem', color: 'var(--text-main)' }}>
                  Location & Operating Address
                </h3>
                <p style={{ fontSize: '0.775rem', color: 'var(--text-muted)' }}>
                  Physical office, workshop, or base location
                </p>
              </div>
            </div>

            <div className="form-group">
              <label className="form-label">
                Full Street Address <span className="required-star">*</span>
              </label>
              <div className="form-control-wrapper">
                <MapPin size={17} className="input-icon-left" />
                <input
                  type="text"
                  name="address"
                  className={`form-input has-left-icon ${
                    touched.address && errors.address ? 'is-invalid' : ''
                  }`}
                  placeholder="Shop / House No., Complex, Landmark, Main Road"
                  value={formData.address}
                  onChange={handleChange}
                  onBlur={() => handleBlur('address')}
                />
              </div>
              {touched.address && errors.address && (
                <div className="form-error-msg">{errors.address}</div>
              )}
            </div>

            <div
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))',
                gap: '1.15rem',
                marginTop: '1rem',
              }}
            >
              <div className="form-group">
                <label className="form-label">Street / Area</label>
                <input
                  type="text"
                  name="street"
                  className="form-input"
                  placeholder="e.g. Banjara Hills"
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
                  placeholder="e.g. Hyderabad"
                  value={formData.city}
                  onChange={handleChange}
                  onBlur={() => handleBlur('city')}
                />
                {touched.city && errors.city && (
                  <div className="form-error-msg">{errors.city}</div>
                )}
              </div>

              <div className="form-group">
                <label className="form-label">
                  State <span className="required-star">*</span>
                </label>
                <input
                  type="text"
                  name="state"
                  className={`form-input ${touched.state && errors.state ? 'is-invalid' : ''}`}
                  placeholder="e.g. Telangana"
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

          {/* Sticky / Floating Action Bar at Bottom */}
          <div
            style={{
              padding: '1.25rem 1.5rem',
              background: 'white',
              borderRadius: 'var(--radius-lg)',
              border: '1px solid var(--border-subtle)',
              boxShadow: 'var(--shadow-md)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              flexWrap: 'wrap',
              gap: '1rem',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--text-muted)', fontSize: '0.8rem' }}>
              <Lock size={15} color="var(--primary)" />
              <span>Partner record protected by AM5 Operations Security</span>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
              <button
                type="button"
                className="btn btn-outline"
                onClick={() => navigate('/')}
                disabled={isSubmitting}
              >
                Cancel
              </button>

              <button
                type="submit"
                className="btn btn-primary"
                disabled={isSubmitting}
                style={{
                  padding: '0.75rem 2rem',
                  fontSize: '0.925rem',
                  fontWeight: 700,
                  boxShadow: '0 4px 14px var(--primary-glow)',
                }}
              >
                {isSubmitting ? (
                  <>
                    <Loader2 size={18} className="spinner" />
                    <span>Saving Profile...</span>
                  </>
                ) : (
                  <>
                    <span>Proceed to Categories</span>
                    <ArrowRight size={18} />
                  </>
                )}
              </button>
            </div>
          </div>
        </div>
      </form>
    </div>
  );
};
