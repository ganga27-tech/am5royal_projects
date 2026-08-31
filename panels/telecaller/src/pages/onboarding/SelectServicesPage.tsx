// ============================================================================
// AM5 ROYAL • Onboarding Step 3: Service Selection & Price Configuration
// Mirrors Flutter: TelecallerSelectServicePage & Complete Onboarding
// ============================================================================

import React, { useEffect, useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { catalogApi } from '../../api/catalogApi';
import { onboardingApi, ServiceSelectionPayload } from '../../api/onboardingApi';
import { ServiceItem } from '../../types';
import { Validation } from '../../utils/validation';
import { extractErrorMessage } from '../../api/client';
import {
  Layers,
  CheckCircle2,
  AlertCircle,
  Loader2,
  ArrowLeft,
  Sparkles,
  Check,
  Tag,
  DollarSign,
} from 'lucide-react';

interface ServiceFormState {
  selected: boolean;
  amount: string;
  discounted_amount: string;
  is_negotiable: boolean;
}

export const SelectServicesPage: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();

  const mobile = (location.state as any)?.mobile || '';
  const businessName = (location.state as any)?.businessName || 'Partner';
  const categoriesPayload = (location.state as any)?.categoriesPayload || [];
  const allSubCategoryIds: number[] = (location.state as any)?.allSubCategoryIds || [];

  const [services, setServices] = useState<ServiceItem[]>([]);
  const [serviceForms, setServiceForms] = useState<Record<number, ServiceFormState>>({});
  const [isLoadingServices, setIsLoadingServices] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isCompleteSuccess, setIsCompleteSuccess] = useState(false);

  useEffect(() => {
    if (!mobile || allSubCategoryIds.length === 0) {
      navigate('/onboard');
      return;
    }
    fetchServices();
  }, [allSubCategoryIds]);

  const fetchServices = async () => {
    setIsLoadingServices(true);
    setError(null);
    try {
      const data = await catalogApi.getServicesBatch(allSubCategoryIds);
      setServices(data);

      // Initialize form states
      const initial: Record<number, ServiceFormState> = {};
      data.forEach((svc) => {
        initial[svc.id] = {
          selected: true, // Default checked
          amount: svc.base_price ? String(svc.base_price) : '500',
          discounted_amount: '',
          is_negotiable: false,
        };
      });
      setServiceForms(initial);
    } catch (err) {
      setError(extractErrorMessage(err));
    } finally {
      setIsLoadingServices(false);
    }
  };

  const handleToggleService = (id: number) => {
    setServiceForms((prev) => ({
      ...prev,
      [id]: { ...prev[id], selected: !prev[id]?.selected },
    }));
  };

  const handleFieldChange = (id: number, field: keyof ServiceFormState, value: any) => {
    setServiceForms((prev) => ({
      ...prev,
      [id]: { ...prev[id], [field]: value },
    }));
  };

  const handleFinalize = async () => {
    setError(null);

    // Filter selected services
    const selectedEntries = Object.entries(serviceForms).filter(
      ([_, form]) => form.selected
    );

    if (selectedEntries.length === 0) {
      setError('Please select and price at least one service to activate this partner.');
      return;
    }

    // Validate prices
    for (const [idStr, form] of selectedEntries) {
      const priceNum = parseFloat(form.amount);
      if (isNaN(priceNum) || priceNum <= 0) {
        setError(`Please enter a valid price for all selected services.`);
        return;
      }
      if (form.discounted_amount) {
        const discNum = parseFloat(form.discounted_amount);
        if (isNaN(discNum) || discNum > priceNum) {
          setError(`Discounted price cannot exceed the original service price.`);
          return;
        }
      }
    }

    const servicesPayload: ServiceSelectionPayload[] = selectedEntries.map(
      ([idStr, form]) => ({
        service_id: parseInt(idStr, 10),
        amount: parseFloat(form.amount),
        discounted_amount: form.discounted_amount
          ? parseFloat(form.discounted_amount)
          : undefined,
        is_negotiable: form.is_negotiable,
      })
    );

    setIsSubmitting(true);
    try {
      // Step A: Save Category Services
      await onboardingApi.saveCategoryServices(mobile, categoriesPayload, servicesPayload);

      // Step B: Finalize Complete Onboarding
      await onboardingApi.completeOnboarding(mobile);

      setIsCompleteSuccess(true);
    } catch (err) {
      setError(extractErrorMessage(err));
    } finally {
      setIsSubmitting(false);
    }
  };

  // Celebration / Success Screen
  if (isCompleteSuccess) {
    return (
      <div style={{ maxWidth: '640px', margin: '3rem auto', textAlign: 'center' }}>
        <div className="card" style={{ padding: '3.5rem 2.5rem' }}>
          <div
            style={{
              width: '72px',
              height: '72px',
              borderRadius: '50%',
              background: 'var(--success-light)',
              color: 'var(--success)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              margin: '0 auto 1.5rem auto',
              boxShadow: '0 8px 24px rgba(16, 185, 129, 0.3)',
            }}
          >
            <CheckCircle2 size={42} />
          </div>

          <h2 style={{ fontSize: '1.85rem', color: 'var(--text-main)', marginBottom: '0.75rem' }}>
            Partner Onboarding Complete!
          </h2>

          <p style={{ color: 'var(--text-muted)', fontSize: '0.95rem', lineHeight: 1.6, marginBottom: '2rem' }}>
            <strong>{businessName}</strong> ({mobile}) has been registered and initialized in the AM5 Royal Verification network.
            Attribution points have been assigned to your telecaller account.
          </p>

          <button
            className="btn btn-primary"
            onClick={() => navigate('/')}
            style={{ padding: '0.85rem 2.5rem' }}
          >
            <span>Return to Dashboard</span>
          </button>
        </div>
      </div>
    );
  }

  const selectedCount = Object.values(serviceForms).filter((f) => f.selected).length;

  return (
    <div style={{ maxWidth: '960px', margin: '0 auto', paddingBottom: '3rem' }}>
      {/* Header Tracker */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
        <button
          className="btn btn-sm btn-outline"
          onClick={() => navigate('/onboard/categories', { state: location.state })}
          style={{ gap: '0.4rem' }}
        >
          <ArrowLeft size={16} />
          <span>Back to Categories</span>
        </button>

        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <span style={{ fontSize: '0.85rem', color: '#059669', fontWeight: 600 }}>✓ Step 1: Profile</span>
          <span style={{ color: 'var(--text-subtle)' }}>→</span>
          <span style={{ fontSize: '0.85rem', color: '#059669', fontWeight: 600 }}>✓ Step 2: Categories</span>
          <span style={{ color: 'var(--text-subtle)' }}>→</span>
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
            3
          </span>
          <span style={{ fontSize: '0.85rem', fontWeight: 700, color: 'var(--primary)' }}>
            Step 3: Services & Pricing
          </span>
        </div>
      </div>

      <div className="card" style={{ padding: '2.5rem' }}>
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            marginBottom: '1.75rem',
            borderBottom: '1px solid var(--border-subtle)',
            paddingBottom: '1rem',
          }}
        >
          <div>
            <h2 style={{ fontSize: '1.5rem', color: 'var(--text-main)' }}>Set Service Pricing</h2>
            <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem', marginTop: '0.25rem' }}>
              Configure base pricing and discounts for <strong>{businessName}</strong> ({mobile})
            </p>
          </div>

          <div
            style={{
              background: 'var(--success-light)',
              color: '#065f46',
              padding: '0.4rem 0.85rem',
              borderRadius: 'var(--radius-md)',
              fontWeight: 700,
              fontSize: '0.85rem',
            }}
          >
            {selectedCount} of {services.length} Services Selected
          </div>
        </div>

        {error && (
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
            <span>{error}</span>
          </div>
        )}

        {isLoadingServices ? (
          <div style={{ textAlign: 'center', padding: '4rem 0' }}>
            <Loader2 size={36} className="spinner" color="var(--primary)" />
            <p style={{ marginTop: '0.85rem', color: 'var(--text-muted)' }}>
              Loading services for selected subcategories...
            </p>
          </div>
        ) : services.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '3rem 1rem' }}>
            <Layers size={36} color="var(--text-subtle)" style={{ margin: '0 auto 0.5rem auto' }} />
            <p style={{ fontWeight: 600, color: 'var(--text-muted)' }}>
              No services found for selected subcategories.
            </p>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            {services.map((svc) => {
              const form = serviceForms[svc.id] || {
                selected: false,
                amount: '500',
                discounted_amount: '',
                is_negotiable: false,
              };

              return (
                <div
                  key={svc.id}
                  style={{
                    padding: '1.25rem',
                    borderRadius: 'var(--radius-md)',
                    border: `1.5px solid ${form.selected ? 'var(--primary)' : 'var(--border-subtle)'}`,
                    background: form.selected ? '#ffffff' : 'var(--bg-subtle)',
                    display: 'flex',
                    flexDirection: 'column',
                    gap: '1rem',
                    transition: 'all 0.15s ease',
                  }}
                >
                  {/* Service Checkbox & Title */}
                  <div
                    style={{
                      display: 'flex',
                      alignItems: 'flex-start',
                      gap: '0.85rem',
                      cursor: 'pointer',
                    }}
                    onClick={() => handleToggleService(svc.id)}
                  >
                    <div
                      style={{
                        width: '22px',
                        height: '22px',
                        borderRadius: '6px',
                        border: `2px solid ${form.selected ? 'var(--primary)' : 'var(--border-strong)'}`,
                        background: form.selected ? 'var(--primary)' : 'white',
                        color: 'white',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        flexShrink: 0,
                        marginTop: '2px',
                      }}
                    >
                      {form.selected && <Check size={15} />}
                    </div>

                    <div style={{ flex: 1 }}>
                      <div style={{ fontWeight: 700, fontSize: '0.975rem', color: 'var(--text-main)' }}>
                        {svc.title}
                      </div>
                      {svc.description && (
                        <div style={{ fontSize: '0.775rem', color: 'var(--text-muted)', marginTop: '0.15rem' }}>
                          {svc.description}
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Pricing Inputs (Only if selected) */}
                  {form.selected && (
                    <div
                      style={{
                        display: 'grid',
                        gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))',
                        gap: '1rem',
                        paddingTop: '0.85rem',
                        borderTop: '1px solid var(--border-subtle)',
                        alignItems: 'center',
                      }}
                    >
                      <div className="form-group" style={{ marginBottom: 0 }}>
                        <label className="form-label" style={{ fontSize: '0.775rem' }}>
                          Standard Price (₹) <span className="required-star">*</span>
                        </label>
                        <input
                          type="number"
                          className="form-input"
                          placeholder="e.g. 499"
                          value={form.amount}
                          onChange={(e) => handleFieldChange(svc.id, 'amount', e.target.value)}
                          min="1"
                        />
                      </div>

                      <div className="form-group" style={{ marginBottom: 0 }}>
                        <label className="form-label" style={{ fontSize: '0.775rem' }}>
                          Discounted Price (₹) (Optional)
                        </label>
                        <input
                          type="number"
                          className="form-input"
                          placeholder="e.g. 399"
                          value={form.discounted_amount}
                          onChange={(e) =>
                            handleFieldChange(svc.id, 'discounted_amount', e.target.value)
                          }
                          min="0"
                        />
                      </div>

                      <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginTop: '1.25rem' }}>
                        <input
                          type="checkbox"
                          id={`neg-${svc.id}`}
                          checked={form.is_negotiable}
                          onChange={(e) =>
                            handleFieldChange(svc.id, 'is_negotiable', e.target.checked)
                          }
                          style={{ width: '16px', height: '16px', accentColor: 'var(--primary)' }}
                        />
                        <label
                          htmlFor={`neg-${svc.id}`}
                          style={{ fontSize: '0.825rem', fontWeight: 600, color: 'var(--text-muted)', cursor: 'pointer' }}
                        >
                          Price is Negotiable
                        </label>
                      </div>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}

        {/* Submit Action */}
        <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '2.5rem', paddingTop: '1.5rem', borderTop: '1px solid var(--border-subtle)' }}>
          <button
            className="btn btn-primary"
            onClick={handleFinalize}
            disabled={isSubmitting || selectedCount === 0}
            style={{ padding: '0.85rem 2.5rem' }}
          >
            {isSubmitting ? (
              <>
                <Loader2 size={18} className="spinner" />
                <span>Completing Partner Onboarding...</span>
              </>
            ) : (
              <>
                <Sparkles size={18} />
                <span>Finalize & Activate Partner</span>
              </>
            )}
          </button>
        </div>
      </div>
    </div>
  );
};
