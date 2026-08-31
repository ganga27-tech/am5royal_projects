// ============================================================================
// AM5 ROYAL • Edit Vendor Details Modal (Temporary Active Stage)
// Allows Team Members to update personal, contact, and business details before final activation
// ============================================================================

import React, { useState } from 'react';
import { TelecallerOnboardedVendor, VendorDetailsUpdateRequest } from '../../types';
import { vendorActionsApi } from '../../api/vendorActionsApi';
import { extractErrorMessage } from '../../api/client';
import {
  X,
  Edit3,
  Building,
  User,
  MapPin,
  FileText,
  Loader2,
  CheckCircle2,
  AlertCircle,
} from 'lucide-react';

interface EditVendorDetailsModalProps {
  isOpen: boolean;
  vendor: TelecallerOnboardedVendor;
  onClose: () => void;
  onSuccess: () => void;
}

export const EditVendorDetailsModal: React.FC<EditVendorDetailsModalProps> = ({
  isOpen,
  vendor,
  onClose,
  onSuccess,
}) => {
  const [formData, setFormData] = useState<VendorDetailsUpdateRequest>({
    business_name: vendor.businessName || '',
    first_name: vendor.firstName || '',
    last_name: vendor.lastName || '',
    email: vendor.email || '',
    city: vendor.city || '',
    state: '',
    pincode: '',
    address: '',
    aadhaar_number: '',
    pan_number: '',
    gst_number: '',
    service_radius_km: 10,
  });

  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [savedSuccess, setSavedSuccess] = useState(false);

  if (!isOpen) return null;

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);
    setError(null);
    try {
      await vendorActionsApi.updateVendorDetails(vendor.id, formData);
      setSavedSuccess(true);
      setTimeout(() => {
        onSuccess();
        onClose();
      }, 750);
    } catch (err) {
      setError(extractErrorMessage(err));
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 160,
        background: 'rgba(15, 23, 42, 0.65)',
        backdropFilter: 'blur(6px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '1.5rem',
      }}
      onClick={onClose}
    >
      <div
        className="card"
        style={{
          width: '100%',
          maxWidth: '680px',
          maxHeight: '90vh',
          display: 'flex',
          flexDirection: 'column',
          padding: 0,
          overflow: 'hidden',
          animation: 'fadeIn 0.2s ease-out',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Modal Header */}
        <div
          style={{
            padding: '1.25rem 1.5rem',
            borderBottom: '1px solid var(--border-subtle)',
            background: 'var(--bg-surface)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
            <div
              style={{
                width: '38px',
                height: '38px',
                borderRadius: '10px',
                background: 'rgba(245, 158, 11, 0.12)',
                color: '#d97706',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Edit3 size={18} />
            </div>
            <div>
              <h3 style={{ fontSize: '1.1rem', color: 'var(--text-main)' }}>
                Edit Partner Details
              </h3>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                Temporary Active Stage • Modify details before final activation
              </p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="btn btn-sm btn-outline"
            style={{ borderRadius: '50%', width: '32px', height: '32px', padding: 0 }}
          >
            <X size={16} />
          </button>
        </div>

        {/* Scrollable Form Body */}
        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', flex: 1, overflow: 'hidden' }}>
          <div
            style={{
              padding: '1.5rem',
              overflowY: 'auto',
              display: 'flex',
              flexDirection: 'column',
              gap: '1.25rem',
            }}
          >
            {error && (
              <div
                style={{
                  padding: '0.75rem 1rem',
                  background: 'var(--danger-light)',
                  borderRadius: 'var(--radius-sm)',
                  color: 'var(--danger)',
                  fontSize: '0.825rem',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.5rem',
                }}
              >
                <AlertCircle size={16} />
                <span>{error}</span>
              </div>
            )}

            {savedSuccess && (
              <div
                style={{
                  padding: '0.75rem 1rem',
                  background: 'var(--success-light)',
                  borderRadius: 'var(--radius-sm)',
                  color: 'var(--success)',
                  fontSize: '0.825rem',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.5rem',
                }}
              >
                <CheckCircle2 size={16} />
                <span>Details updated successfully!</span>
              </div>
            )}

            {/* Business Information Section */}
            <div>
              <h4
                style={{
                  fontSize: '0.8rem',
                  fontFamily: 'var(--font-heading)',
                  color: 'var(--text-subtle)',
                  textTransform: 'uppercase',
                  letterSpacing: '0.05em',
                  marginBottom: '0.75rem',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.4rem',
                }}
              >
                <Building size={14} color="var(--primary)" />
                <span>Business Information</span>
              </h4>

              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '0.85rem' }}>
                <div className="form-group">
                  <label className="form-label">Business Name *</label>
                  <input
                    type="text"
                    name="business_name"
                    className="form-input"
                    value={formData.business_name || ''}
                    onChange={handleChange}
                    required
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">GST Number (Optional)</label>
                  <input
                    type="text"
                    name="gst_number"
                    className="form-input"
                    value={formData.gst_number || ''}
                    onChange={handleChange}
                    placeholder="22AAAAA0000A1Z5"
                  />
                </div>
              </div>
            </div>

            {/* Partner / Contact Person */}
            <div>
              <h4
                style={{
                  fontSize: '0.8rem',
                  fontFamily: 'var(--font-heading)',
                  color: 'var(--text-subtle)',
                  textTransform: 'uppercase',
                  letterSpacing: '0.05em',
                  marginBottom: '0.75rem',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.4rem',
                }}
              >
                <User size={14} color="var(--primary)" />
                <span>Partner Contact Details</span>
              </h4>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.85rem' }}>
                <div className="form-group">
                  <label className="form-label">First Name *</label>
                  <input
                    type="text"
                    name="first_name"
                    className="form-input"
                    value={formData.first_name || ''}
                    onChange={handleChange}
                    required
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Last Name</label>
                  <input
                    type="text"
                    name="last_name"
                    className="form-input"
                    value={formData.last_name || ''}
                    onChange={handleChange}
                  />
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.85rem', marginTop: '0.85rem' }}>
                <div className="form-group">
                  <label className="form-label">Email Address</label>
                  <input
                    type="email"
                    name="email"
                    className="form-input"
                    value={formData.email || ''}
                    onChange={handleChange}
                    placeholder="partner@example.com"
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Alternative Phone</label>
                  <input
                    type="tel"
                    name="alternative_number"
                    className="form-input"
                    value={formData.alternative_number || ''}
                    onChange={handleChange}
                    placeholder="9876543210"
                  />
                </div>
              </div>
            </div>

            {/* Address & City */}
            <div>
              <h4
                style={{
                  fontSize: '0.8rem',
                  fontFamily: 'var(--font-heading)',
                  color: 'var(--text-subtle)',
                  textTransform: 'uppercase',
                  letterSpacing: '0.05em',
                  marginBottom: '0.75rem',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.4rem',
                }}
              >
                <MapPin size={14} color="var(--primary)" />
                <span>Location & Operational Coverage</span>
              </h4>

              <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '0.85rem' }}>
                <div className="form-group">
                  <label className="form-label">Operating City *</label>
                  <input
                    type="text"
                    name="city"
                    className="form-input"
                    value={formData.city || ''}
                    onChange={handleChange}
                    required
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Coverage Radius (km)</label>
                  <input
                    type="number"
                    name="service_radius_km"
                    className="form-input"
                    value={formData.service_radius_km || 10}
                    onChange={handleChange}
                    min={1}
                    max={100}
                  />
                </div>
              </div>
            </div>
          </div>

          {/* Modal Footer */}
          <div
            style={{
              padding: '1rem 1.5rem',
              borderTop: '1px solid var(--border-subtle)',
              background: 'var(--bg-subtle)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'flex-end',
              gap: '0.75rem',
            }}
          >
            <button
              type="button"
              className="btn btn-outline"
              onClick={onClose}
              disabled={isSaving}
            >
              Cancel
            </button>
            <button
              type="submit"
              className="btn btn-primary"
              disabled={isSaving}
              style={{ minWidth: '130px' }}
            >
              {isSaving ? (
                <>
                  <Loader2 size={16} className="spinner" />
                  <span>Saving...</span>
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
