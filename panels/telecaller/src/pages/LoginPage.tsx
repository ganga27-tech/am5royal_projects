// ============================================================================
// AM5 ROYAL • Telecaller Operations Login Portal
// Strict, Crisp Production-Grade Form Validation & Dynamic Responsive Theme
// ============================================================================

import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';
import { Validation } from '../utils/validation';
import { extractErrorMessage } from '../api/client';
import {
  Sparkles,
  ShieldCheck,
  Phone,
  Mail,
  Lock,
  Eye,
  EyeOff,
  ArrowRight,
  AlertCircle,
  Loader2,
  Headphones,
  Zap,
} from 'lucide-react';

export const LoginPage: React.FC = () => {
  const { login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const from = (location.state as any)?.from?.pathname || '/';

  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);

  const [touched, setTouched] = useState<{ identifier?: boolean; password?: boolean }>({});
  const [errors, setErrors] = useState<{ identifier?: string; password?: string }>({});
  const [serverError, setServerError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Validate Identifier: supports either 10-digit mobile number or standard email address
  const validateIdentifier = (val: string): string | undefined => {
    if (!val || !val.trim()) {
      return 'Email or 10-digit phone number is required';
    }
    const clean = val.trim();
    const isDigitsOnly = /^\d+$/.test(clean.replace(/[\s\-+]/g, ''));

    if (isDigitsOnly) {
      const mobileCheck = Validation.mobile(clean);
      if (!mobileCheck.isValid) return mobileCheck.error;
    } else {
      const emailCheck = Validation.email(clean, true);
      if (!emailCheck.isValid) return emailCheck.error;
    }
    return undefined;
  };

  const validatePassword = (val: string): string | undefined => {
    const check = Validation.password(val);
    return check.isValid ? undefined : check.error;
  };

  const handleIdentifierChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value;
    setIdentifier(val);
    if (touched.identifier) {
      setErrors((prev) => ({ ...prev, identifier: validateIdentifier(val) }));
    }
  };

  const handlePasswordChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value;
    setPassword(val);
    if (touched.password) {
      setErrors((prev) => ({ ...prev, password: validatePassword(val) }));
    }
  };

  const handleBlur = (field: 'identifier' | 'password') => {
    setTouched((prev) => ({ ...prev, [field]: true }));
    if (field === 'identifier') {
      setErrors((prev) => ({ ...prev, identifier: validateIdentifier(identifier) }));
    } else {
      setErrors((prev) => ({ ...prev, password: validatePassword(password) }));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setServerError(null);

    const idErr = validateIdentifier(identifier);
    const passErr = validatePassword(password);

    setTouched({ identifier: true, password: true });
    setErrors({ identifier: idErr, password: passErr });

    if (idErr || passErr) {
      return;
    }

    setIsSubmitting(true);
    try {
      await login(identifier.trim(), password);
      navigate(from, { replace: true });
    } catch (err) {
      setServerError(extractErrorMessage(err));
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div
      style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '2rem 1.5rem',
        background: 'linear-gradient(135deg, #f8fafc 0%, #e0e7ff 50%, #f0fdfa 100%)',
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      {/* Decorative ambient blurred orbs */}
      <div
        style={{
          position: 'absolute',
          top: '-10%',
          left: '-5%',
          width: '500px',
          height: '500px',
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(79, 70, 229, 0.15) 0%, transparent 70%)',
          filter: 'blur(40px)',
          pointerEvents: 'none',
        }}
      />
      <div
        style={{
          position: 'absolute',
          bottom: '-10%',
          right: '-5%',
          width: '450px',
          height: '450px',
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(13, 148, 136, 0.15) 0%, transparent 70%)',
          filter: 'blur(40px)',
          pointerEvents: 'none',
        }}
      />

      <div
        className="card"
        style={{
          width: '100%',
          maxWidth: '460px',
          padding: '2.5rem',
          boxShadow: 'var(--shadow-xl)',
          border: '1px solid rgba(255, 255, 255, 0.8)',
          background: 'rgba(255, 255, 255, 0.92)',
          backdropFilter: 'blur(20px)',
          position: 'relative',
          zIndex: 1,
        }}
      >
        {/* Brand Header */}
        <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
          <div
            style={{
              width: '56px',
              height: '56px',
              borderRadius: '16px',
              background: 'linear-gradient(135deg, var(--primary) 0%, #312e81 100%)',
              color: 'white',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              margin: '0 auto 1rem auto',
              boxShadow: '0 8px 20px var(--primary-glow)',
            }}
          >
            <Headphones size={28} color="#fef08a" />
          </div>

          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '0.5rem' }}>
            <h1
              style={{
                fontFamily: 'var(--font-heading)',
                fontSize: '1.65rem',
                fontWeight: 800,
                letterSpacing: '0.05em',
                background: 'linear-gradient(135deg, var(--primary) 0%, #1e1b4b 100%)',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
              }}
            >
              AM5 ROYAL
            </h1>
            <span
              style={{
                fontSize: '0.65rem',
                fontWeight: 700,
                padding: '0.15rem 0.5rem',
                borderRadius: '6px',
                background: 'var(--primary-light)',
                color: 'var(--primary)',
                letterSpacing: '0.05em',
              }}
            >
              OPERATIONS
            </span>
          </div>

          <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem', marginTop: '0.35rem' }}>
            Telecaller & Partner Verification Console
          </p>
        </div>

        {/* Server Error Alert */}
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
              gap: '0.6rem',
              marginBottom: '1.5rem',
              animation: 'fadeInDown 0.2s ease-out',
            }}
          >
            <AlertCircle size={18} flex-shrink={0} />
            <span>{serverError}</span>
          </div>
        )}

        {/* Login Form */}
        <form onSubmit={handleSubmit} noValidate>
          {/* Identifier Input */}
          <div className="form-group">
            <label className="form-label" htmlFor="identifier-input">
              <span>Email Address or Phone</span>
              <span className="required-star">*</span>
            </label>
            <div className="form-control-wrapper">
              <span className="input-icon-left">
                {/^\d+$/.test(identifier) ? <Phone size={17} /> : <Mail size={17} />}
              </span>
              <input
                id="identifier-input"
                type="text"
                className={`form-input has-left-icon ${
                  touched.identifier && errors.identifier ? 'is-invalid' : ''
                }`}
                placeholder="e.g. employee@am5royal.com or 9876543210"
                value={identifier}
                onChange={handleIdentifierChange}
                onBlur={() => handleBlur('identifier')}
                autoComplete="username"
                disabled={isSubmitting}
              />
            </div>
            {touched.identifier && errors.identifier && (
              <div className="form-error-msg">{errors.identifier}</div>
            )}
          </div>

          {/* Password Input */}
          <div className="form-group" style={{ marginBottom: '1.75rem' }}>
            <label className="form-label" htmlFor="password-input">
              <span>Account Password</span>
              <span className="required-star">*</span>
            </label>
            <div className="form-control-wrapper">
              <span className="input-icon-left">
                <Lock size={17} />
              </span>
              <input
                id="password-input"
                type={showPassword ? 'text' : 'password'}
                className={`form-input has-left-icon has-right-icon ${
                  touched.password && errors.password ? 'is-invalid' : ''
                }`}
                placeholder="Enter your confidential password"
                value={password}
                onChange={handlePasswordChange}
                onBlur={() => handleBlur('password')}
                autoComplete="current-password"
                disabled={isSubmitting}
              />
              <button
                type="button"
                className="input-icon-right"
                onClick={() => setShowPassword(!showPassword)}
                tabIndex={-1}
                style={{ background: 'none', border: 'none' }}
              >
                {showPassword ? <EyeOff size={17} /> : <Eye size={17} />}
              </button>
            </div>
            {touched.password && errors.password && (
              <div className="form-error-msg">{errors.password}</div>
            )}
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            className="btn btn-primary"
            style={{ width: '100%', padding: '0.85rem 1.5rem' }}
            disabled={isSubmitting}
          >
            {isSubmitting ? (
              <>
                <Loader2 size={18} className="spinner" />
                <span>Authenticating Session...</span>
              </>
            ) : (
              <>
                <span>Sign In to Console</span>
                <ArrowRight size={18} />
              </>
            )}
          </button>
        </form>

        {/* Security / System Footer */}
        <div
          style={{
            marginTop: '2rem',
            paddingTop: '1.25rem',
            borderTop: '1px solid var(--border-subtle)',
            textAlign: 'center',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '0.5rem',
            color: 'var(--text-subtle)',
            fontSize: '0.75rem',
          }}
        >
          <ShieldCheck size={15} color="var(--primary)" />
          <span>Protected by AM5 Royal Enterprise Telecaller Authentication</span>
        </div>
      </div>
    </div>
  );
};
