// ============================================================================
// AM5 ROYAL • Vendor Step Details Modal (5-Step Detailed Inspection)
// Mirrors Flutter: _showStepDetailsModal() / _buildModalStepContent()
// ============================================================================

import React, { useEffect, useState } from 'react';
import { telecallerApi } from '../../api/telecallerApi';
import { VendorStepDetails } from '../../types';
import { formatCurrency, formatDate, formatTime } from '../../utils/formatters';
import { extractErrorMessage } from '../../api/client';
import {
  X,
  Layers,
  Clock,
  User,
  Building,
  CreditCard,
  CheckCircle,
  AlertCircle,
  Eye,
  Loader2,
  Calendar,
  Phone,
  Mail,
  MapPin,
  ShieldAlert,
} from 'lucide-react';

interface StepDetailsModalProps {
  isOpen: boolean;
  vendorId: number;
  vendorName: string;
  initialStep?: string; // 'Services' | 'Slots' | 'Registration' | 'Business Reg' | 'Payment'
  onClose: () => void;
}

export const StepDetailsModal: React.FC<StepDetailsModalProps> = ({
  isOpen,
  vendorId,
  vendorName,
  initialStep = 'Services',
  onClose,
}) => {
  const [details, setDetails] = useState<VendorStepDetails | null>(null);
  const [activeStep, setActiveStep] = useState<string>(initialStep);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Document preview enlarged image
  const [previewImage, setPreviewImage] = useState<{ url: string; title: string } | null>(null);

  useEffect(() => {
    if (isOpen && vendorId) {
      loadStepDetails();
    }
  }, [isOpen, vendorId]);

  useEffect(() => {
    if (initialStep) {
      // Normalize step name to match our tabs
      const lower = initialStep.toLowerCase();
      if (lower.includes('service')) setActiveStep('Services');
      else if (lower.includes('slot')) setActiveStep('Slots');
      else if (lower.includes('business')) setActiveStep('Business Reg');
      else if (lower.includes('reg')) setActiveStep('Registration');
      else if (lower.includes('pay')) setActiveStep('Payment');
    }
  }, [initialStep]);

  const loadStepDetails = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const data = await telecallerApi.getVendorStepDetails(vendorId);
      setDetails(data);
    } catch (err) {
      setError(extractErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  if (!isOpen) return null;

  const tabs = [
    { id: 'Services', label: 'Services', icon: Layers },
    { id: 'Slots', label: 'Availability / Slots', icon: Clock },
    { id: 'Registration', label: 'Personal & Contact', icon: User },
    { id: 'Business Reg', label: 'Business & KYC Docs', icon: Building },
    { id: 'Payment', label: 'Subscriptions', icon: CreditCard },
  ];

  return (
    <>
      <div
        style={{
          position: 'fixed',
          inset: 0,
          zIndex: 100,
          background: 'rgba(15, 23, 42, 0.55)',
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
            maxWidth: '780px',
            maxHeight: '90vh',
            display: 'flex',
            flexDirection: 'column',
            padding: 0,
            overflow: 'hidden',
            animation: 'fadeInDown 0.2s ease-out',
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
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <h3 style={{ fontSize: '1.15rem', color: 'var(--primary-dark)' }}>
                  {vendorName || 'Partner'} Verification Breakdown
                </h3>
                <span
                  style={{
                    fontSize: '0.7rem',
                    fontWeight: 700,
                    padding: '0.15rem 0.5rem',
                    borderRadius: '9999px',
                    background: 'var(--primary-light)',
                    color: 'var(--primary)',
                  }}
                >
                  ID: #{vendorId}
                </span>
              </div>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                Inspect 5 core onboarding steps, registered KYC documents, and catalog services
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
              }}
            >
              <X size={20} />
            </button>
          </div>

          {/* Navigation Step Tabs */}
          <div
            style={{
              display: 'flex',
              borderBottom: '1px solid var(--border-subtle)',
              background: 'white',
              overflowX: 'auto',
            }}
          >
            {tabs.map((tab) => {
              const Icon = tab.icon;
              const isSelected = activeStep === tab.id;
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveStep(tab.id)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.5rem',
                    padding: '0.85rem 1.25rem',
                    border: 'none',
                    borderBottom: `2.5px solid ${isSelected ? 'var(--primary)' : 'transparent'}`,
                    background: isSelected ? 'var(--primary-light)' : 'transparent',
                    color: isSelected ? 'var(--primary)' : 'var(--text-muted)',
                    fontFamily: 'var(--font-heading)',
                    fontSize: '0.825rem',
                    fontWeight: isSelected ? 700 : 600,
                    cursor: 'pointer',
                    whiteSpace: 'nowrap',
                    transition: 'all 0.2s',
                  }}
                >
                  <Icon size={16} />
                  <span>{tab.label}</span>
                </button>
              );
            })}
          </div>

          {/* Modal Content */}
          <div style={{ padding: '1.5rem', overflowY: 'auto', flex: 1 }}>
            {isLoading ? (
              <div style={{ textAlign: 'center', padding: '4rem 0' }}>
                <Loader2 size={36} className="spinner" color="var(--primary)" />
                <p style={{ marginTop: '0.85rem', color: 'var(--text-muted)', fontSize: '0.875rem' }}>
                  Loading {activeStep} details from server...
                </p>
              </div>
            ) : error ? (
              <div
                style={{
                  padding: '1.5rem',
                  background: 'var(--danger-light)',
                  borderRadius: 'var(--radius-md)',
                  color: 'var(--danger)',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.75rem',
                }}
              >
                <AlertCircle size={22} />
                <div>
                  <div style={{ fontWeight: 700 }}>Unable to Load Step Details</div>
                  <div style={{ fontSize: '0.825rem', marginTop: '0.2rem' }}>{error}</div>
                </div>
              </div>
            ) : !details ? (
              <div style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>
                No details available.
              </div>
            ) : (
              <div>
                {/* 1. SERVICES TAB */}
                {activeStep === 'Services' && (
                  <div>
                    {details.services.length === 0 ? (
                      <div style={{ textAlign: 'center', padding: '3rem 1rem', color: 'var(--text-muted)' }}>
                        <Layers size={36} color="var(--text-subtle)" style={{ margin: '0 auto 0.5rem auto' }} />
                        <p style={{ fontWeight: 600 }}>No services registered yet.</p>
                      </div>
                    ) : (
                      <div style={{ display: 'flex', flexDirection: 'column', gap: '0.85rem' }}>
                        {details.services.map((svc, idx) => (
                          <div
                            key={idx}
                            style={{
                              padding: '1rem 1.25rem',
                              borderRadius: 'var(--radius-md)',
                              border: '1px solid var(--border-subtle)',
                              background: 'var(--bg-subtle)',
                              display: 'flex',
                              alignItems: 'center',
                              justifyContent: 'space-between',
                            }}
                          >
                            <div>
                              <div style={{ fontWeight: 700, fontSize: '0.95rem', color: 'var(--text-main)' }}>
                                {svc.title}
                              </div>
                              <div style={{ fontSize: '0.775rem', color: 'var(--text-muted)', marginTop: '0.2rem' }}>
                                Category: {svc.main_category_name} {svc.sub_category_name ? `→ ${svc.sub_category_name}` : ''}
                              </div>
                              {svc.description && (
                                <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)', fontStyle: 'italic', marginTop: '0.35rem' }}>
                                  "{svc.description}"
                                </div>
                              )}
                            </div>

                            <div style={{ textAlign: 'right' }}>
                              <div
                                style={{
                                  fontFamily: 'var(--font-heading)',
                                  fontSize: '1.15rem',
                                  fontWeight: 800,
                                  color: 'var(--success)',
                                }}
                              >
                                {formatCurrency(svc.discounted_price || svc.price)}
                              </div>
                              {svc.price && svc.discounted_price && svc.price !== svc.discounted_price && (
                                <div
                                  style={{
                                    fontSize: '0.75rem',
                                    color: 'var(--text-subtle)',
                                    textDecoration: 'line-through',
                                  }}
                                >
                                  {formatCurrency(svc.price)}
                                </div>
                              )}
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                )}

                {/* 2. SLOTS TAB */}
                {activeStep === 'Slots' && (
                  <div>
                    {details.slots.length === 0 ? (
                      <div style={{ textAlign: 'center', padding: '3rem 1rem', color: 'var(--text-muted)' }}>
                        <Clock size={36} color="var(--text-subtle)" style={{ margin: '0 auto 0.5rem auto' }} />
                        <p style={{ fontWeight: 600 }}>No working availability configured yet.</p>
                      </div>
                    ) : (
                      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.75rem' }}>
                        {details.slots.map((slot, idx) => (
                          <div
                            key={idx}
                            style={{
                              padding: '0.85rem 1rem',
                              borderRadius: 'var(--radius-md)',
                              border: '1px solid var(--border-subtle)',
                              background: 'var(--bg-subtle)',
                              display: 'flex',
                              alignItems: 'center',
                              justifyContent: 'space-between',
                            }}
                          >
                            <span style={{ fontWeight: 700, fontSize: '0.85rem' }}>{slot.day_name}</span>
                            <span
                              style={{
                                fontSize: '0.8rem',
                                color: 'var(--primary)',
                                fontWeight: 600,
                                display: 'flex',
                                alignItems: 'center',
                                gap: '0.35rem',
                              }}
                            >
                              <Clock size={13} />
                              <span>
                                {formatTime(slot.start_time)} – {formatTime(slot.end_time)}
                              </span>
                            </span>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                )}

                {/* 3. REGISTRATION TAB */}
                {activeStep === 'Registration' && (
                  <div
                    style={{
                      display: 'grid',
                      gridTemplateColumns: '1fr 1fr',
                      gap: '1rem',
                      background: 'var(--bg-subtle)',
                      padding: '1.25rem',
                      borderRadius: 'var(--radius-md)',
                    }}
                  >
                    <div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Partner Name</div>
                      <div style={{ fontWeight: 600, fontSize: '0.9rem', color: 'var(--text-main)' }}>
                        {details.registration.first_name} {details.registration.last_name}
                      </div>
                    </div>

                    <div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Father's Name</div>
                      <div style={{ fontWeight: 600, fontSize: '0.9rem' }}>
                        {details.registration.father_name || '—'}
                      </div>
                    </div>

                    <div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Primary Mobile</div>
                      <div style={{ fontWeight: 600, fontSize: '0.9rem', color: 'var(--primary)' }}>
                        {details.registration.mobile_number || '—'}
                      </div>
                    </div>

                    <div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Alternative Contact</div>
                      <div style={{ fontWeight: 600, fontSize: '0.9rem' }}>
                        {details.registration.alternative_contact_number || '—'}
                      </div>
                    </div>

                    <div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Email Address</div>
                      <div style={{ fontWeight: 600, fontSize: '0.9rem' }}>
                        {details.registration.email || '—'}
                      </div>
                    </div>

                    <div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>City & State</div>
                      <div style={{ fontWeight: 600, fontSize: '0.9rem' }}>
                        {details.registration.city}, {details.registration.state} ({details.registration.pincode})
                      </div>
                    </div>

                    <div style={{ gridColumn: 'span 2' }}>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Registered Address</div>
                      <div style={{ fontWeight: 500, fontSize: '0.85rem' }}>
                        {details.registration.address || '—'}
                      </div>
                    </div>

                    <div style={{ gridColumn: 'span 2', paddingTop: '0.5rem', borderTop: '1px solid var(--border-subtle)' }}>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Registered On</div>
                      <div style={{ fontWeight: 600, fontSize: '0.825rem' }}>
                        {formatDate(details.registration.created_at)}
                      </div>
                    </div>
                  </div>
                )}

                {/* 4. BUSINESS REG & KYC DOCS TAB */}
                {activeStep === 'Business Reg' && (
                  <div>
                    {/* Business Info Grid */}
                    <div
                      style={{
                        display: 'grid',
                        gridTemplateColumns: 'repeat(3, 1fr)',
                        gap: '1rem',
                        background: 'var(--bg-subtle)',
                        padding: '1.25rem',
                        borderRadius: 'var(--radius-md)',
                        marginBottom: '1.5rem',
                      }}
                    >
                      <div>
                        <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Business Name</div>
                        <div style={{ fontWeight: 700, fontSize: '0.95rem' }}>
                          {details.business_reg.business_name || '—'}
                        </div>
                      </div>

                      <div>
                        <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Aadhaar Number</div>
                        <div style={{ fontWeight: 600, fontSize: '0.9rem' }}>
                          {details.business_reg.aadhaar_number || '—'}
                        </div>
                      </div>

                      <div>
                        <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>PAN Card</div>
                        <div style={{ fontWeight: 600, fontSize: '0.9rem' }}>
                          {details.business_reg.pan_number || '—'}
                        </div>
                      </div>

                      <div>
                        <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>GST Number</div>
                        <div style={{ fontWeight: 600, fontSize: '0.9rem' }}>
                          {details.business_reg.gst_number || '—'}
                        </div>
                      </div>

                      <div>
                        <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Service Radius</div>
                        <div style={{ fontWeight: 600, fontSize: '0.9rem' }}>
                          {details.business_reg.service_radius_km} km
                        </div>
                      </div>
                    </div>

                    {/* Uploaded Documents */}
                    <h4 style={{ fontSize: '0.95rem', marginBottom: '0.85rem' }}>
                      Uploaded KYC Verification Documents
                    </h4>

                    {details.business_reg.documents.length === 0 ? (
                      <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', fontStyle: 'italic' }}>
                        No KYC documents uploaded yet.
                      </p>
                    ) : (
                      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                        {details.business_reg.documents.map((doc, idx) => (
                          <div
                            key={idx}
                            style={{
                              border: '1px solid var(--border-subtle)',
                              borderRadius: 'var(--radius-md)',
                              padding: '1rem',
                              background: 'white',
                            }}
                          >
                            <div
                              style={{
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'space-between',
                                marginBottom: '0.75rem',
                              }}
                            >
                              <span style={{ fontWeight: 700, fontSize: '0.85rem' }}>
                                {doc.document_type}
                              </span>
                              <span
                                className={`badge ${
                                  doc.verification_status === 'verified' ? 'badge-active' : 'badge-temporary-active'
                                }`}
                              >
                                {doc.verification_status}
                              </span>
                            </div>

                            {doc.document_url && (
                              <div
                                style={{
                                  position: 'relative',
                                  height: '140px',
                                  borderRadius: 'var(--radius-sm)',
                                  overflow: 'hidden',
                                  background: '#f1f5f9',
                                  cursor: 'pointer',
                                }}
                                onClick={() =>
                                  setPreviewImage({
                                    url: doc.document_url,
                                    title: doc.document_type,
                                  })
                                }
                              >
                                <img
                                  src={doc.document_url}
                                  alt={doc.document_type}
                                  style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                                  onError={(e) => {
                                    (e.currentTarget as any).src = 'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100"><text x="10" y="50">No preview</text></svg>';
                                  }}
                                />
                                <div
                                  style={{
                                    position: 'absolute',
                                    bottom: '6px',
                                    right: '6px',
                                    background: 'rgba(0,0,0,0.6)',
                                    color: 'white',
                                    padding: '0.2rem 0.5rem',
                                    borderRadius: '6px',
                                    fontSize: '0.7rem',
                                    display: 'flex',
                                    alignItems: 'center',
                                    gap: '0.25rem',
                                  }}
                                >
                                  <Eye size={12} />
                                  <span>Enlarge</span>
                                </div>
                              </div>
                            )}
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                )}

                {/* 5. PAYMENT & SUBSCRIPTIONS TAB */}
                {activeStep === 'Payment' && (
                  <div>
                    {details.payment.subscriptions.length === 0 ? (
                      <div style={{ textAlign: 'center', padding: '3rem 1rem', color: 'var(--text-muted)' }}>
                        <CreditCard size={36} color="var(--text-subtle)" style={{ margin: '0 auto 0.5rem auto' }} />
                        <p style={{ fontWeight: 600 }}>No subscription records found.</p>
                      </div>
                    ) : (
                      <div style={{ display: 'flex', flexDirection: 'column', gap: '0.85rem' }}>
                        {details.payment.subscriptions.map((sub, idx) => (
                          <div
                            key={idx}
                            style={{
                              padding: '1rem 1.25rem',
                              borderRadius: 'var(--radius-md)',
                              border: '1px solid var(--border-subtle)',
                              background: 'var(--bg-subtle)',
                              display: 'flex',
                              alignItems: 'center',
                              justifyContent: 'space-between',
                            }}
                          >
                            <div>
                              <div style={{ fontWeight: 700, fontSize: '0.95rem' }}>{sub.plan_name}</div>
                              <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '0.2rem' }}>
                                Payment ID: #{sub.payment_id}
                              </div>
                              <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)', marginTop: '0.2rem' }}>
                                Valid: {formatDate(sub.start_date)} – {formatDate(sub.end_date)}
                              </div>
                            </div>

                            <div style={{ textAlign: 'right' }}>
                              <div
                                style={{
                                  fontFamily: 'var(--font-heading)',
                                  fontSize: '1.2rem',
                                  fontWeight: 800,
                                  color: 'var(--text-main)',
                                }}
                              >
                                {formatCurrency(sub.amount)}
                              </div>
                              <span
                                className={`badge ${
                                  sub.status === 'active' ? 'badge-active' : 'badge-temporary-active'
                                }`}
                                style={{ marginTop: '0.35rem' }}
                              >
                                {sub.status}
                              </span>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                )}
              </div>
            )}
          </div>

          {/* Modal Footer */}
          <div
            style={{
              padding: '1rem 1.5rem',
              borderTop: '1px solid var(--border-subtle)',
              display: 'flex',
              justifyContent: 'flex-end',
              background: 'var(--bg-subtle)',
            }}
          >
            <button className="btn btn-primary btn-sm" onClick={onClose}>
              Close Inspector
            </button>
          </div>
        </div>
      </div>

      {/* Enlarged Image Preview Dialog */}
      {previewImage && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 150,
            background: 'rgba(0, 0, 0, 0.85)',
            backdropFilter: 'blur(8px)',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '2rem',
          }}
          onClick={() => setPreviewImage(null)}
        >
          <div
            style={{
              maxWidth: '85vw',
              maxHeight: '85vh',
              position: 'relative',
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <button
              onClick={() => setPreviewImage(null)}
              style={{
                position: 'absolute',
                top: '-2.5rem',
                right: '0',
                background: 'rgba(255, 255, 255, 0.2)',
                border: 'none',
                color: 'white',
                borderRadius: '50%',
                width: '36px',
                height: '36px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
              }}
            >
              <X size={20} />
            </button>
            <img
              src={previewImage.url}
              alt={previewImage.title}
              style={{
                maxWidth: '80vw',
                maxHeight: '80vh',
                borderRadius: '12px',
                boxShadow: '0 20px 50px rgba(0,0,0,0.5)',
              }}
            />
            <div style={{ color: 'white', marginTop: '0.75rem', textAlign: 'center', fontWeight: 600 }}>
              {previewImage.title}
            </div>
          </div>
        </div>
      )}
    </>
  );
};
