// ============================================================================
// AM5 ROYAL • Onboarding Step 2: Select Categories & Subcategories
// Mirrors Flutter: TelecallerMapScreen / DynamicSubCategoryBox
// ============================================================================

import React, { useEffect, useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { catalogApi } from '../../api/catalogApi';
import { MainCategory, SubCategory } from '../../types';
import { extractErrorMessage } from '../../api/client';
import {
  Layers,
  ArrowRight,
  ArrowLeft,
  CheckCircle2,
  AlertCircle,
  Loader2,
  Tag,
  Check,
  Store,
} from 'lucide-react';

export const SelectCategoryPage: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();

  const mobile = (location.state as any)?.mobile || '';
  const businessName = (location.state as any)?.businessName || 'Partner';

  const [categories, setCategories] = useState<MainCategory[]>([]);
  const [subCategoriesMap, setSubCategoriesMap] = useState<Record<number, SubCategory[]>>({});
  const [selectedCategory, setSelectedCategory] = useState<MainCategory | null>(null);

  // Mapping of categoryId -> array of selected subcategory IDs
  const [selectedSubCats, setSelectedSubCats] = useState<Record<number, number[]>>({});

  const [isLoadingCats, setIsLoadingCats] = useState(true);
  const [isLoadingSubs, setIsLoadingSubs] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [validationMsg, setValidationMsg] = useState<string | null>(null);

  useEffect(() => {
    if (!mobile) {
      navigate('/onboard');
      return;
    }
    fetchMainCategories();
  }, [mobile]);

  const fetchMainCategories = async () => {
    setIsLoadingCats(true);
    setError(null);
    try {
      const data = await catalogApi.getMainCategories();
      setCategories(data);
      if (data.length > 0) {
        handleCategoryClick(data[0]);
      }
    } catch (err) {
      setError(extractErrorMessage(err));
    } finally {
      setIsLoadingCats(false);
    }
  };

  const handleCategoryClick = async (cat: MainCategory) => {
    setSelectedCategory(cat);
    setValidationMsg(null);

    // If subcategories already cached, do not re-fetch
    if (subCategoriesMap[cat.id]) return;

    setIsLoadingSubs(true);
    try {
      const subs = await catalogApi.getSubCategories(cat.id);
      setSubCategoriesMap((prev) => ({ ...prev, [cat.id]: subs }));
    } catch (err) {
      console.error('Failed to load subcategories:', err);
    } finally {
      setIsLoadingSubs(false);
    }
  };

  const toggleSubCategory = (catId: number, subId: number) => {
    setValidationMsg(null);
    setSelectedSubCats((prev) => {
      const currentList = prev[catId] || [];
      if (currentList.includes(subId)) {
        const nextList = currentList.filter((id) => id !== subId);
        return { ...prev, [catId]: nextList };
      } else {
        return { ...prev, [catId]: [...currentList, subId] };
      }
    });
  };

  const totalSelectedSubCats = Object.values(selectedSubCats).reduce(
    (sum, list) => sum + list.length,
    0
  );

  const handleProceed = () => {
    if (totalSelectedSubCats === 0) {
      setValidationMsg('Please select at least one subcategory to assign services to this partner.');
      return;
    }

    // Collect list of selected category structures
    const categoriesPayload = Object.entries(selectedSubCats)
      .filter(([_, subs]) => subs.length > 0)
      .map(([catIdStr, subs]) => ({
        main_category_id: parseInt(catIdStr, 10),
        sub_category_ids: subs,
      }));

    const allSubCategoryIds = Object.values(selectedSubCats).flat();

    navigate('/onboard/services', {
      state: {
        mobile,
        businessName,
        categoriesPayload,
        allSubCategoryIds,
      },
    });
  };

  return (
    <div style={{ maxWidth: '960px', margin: '0 auto', padding: '0 0.5rem 4rem 0.5rem' }}>
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
          onClick={() => navigate('/onboard')}
          style={{
            gap: '0.45rem',
            background: 'white',
            fontWeight: 600,
            fontSize: '0.825rem',
            padding: '0.45rem 0.95rem',
          }}
        >
          <ArrowLeft size={16} />
          <span>Back to Profile</span>
        </button>

        {/* Enhanced 3-Step Interactive Breadcrumb */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          {/* Step 1 */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.45rem' }}>
            <div
              style={{
                width: '26px',
                height: '26px',
                borderRadius: '50%',
                background: '#10b981',
                color: 'white',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '0.75rem',
                fontWeight: 700,
              }}
            >
              ✓
            </div>
            <span style={{ fontSize: '0.8rem', fontWeight: 600, color: '#059669' }}>
              Profile & Identity
            </span>
          </div>

          <span style={{ color: 'var(--border-strong)', fontSize: '0.85rem' }}>—</span>

          {/* Step 2 (Active) */}
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
              2
            </div>
            <span style={{ fontSize: '0.825rem', fontWeight: 700, color: 'var(--primary)' }}>
              Categories & Subcategories
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
          padding: '2rem 2.5rem',
          color: 'white',
          marginBottom: '1.75rem',
          position: 'relative',
          overflow: 'hidden',
          boxShadow: 'var(--shadow-lg)',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '1rem' }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.4rem' }}>
              <span
                style={{
                  padding: '0.2rem 0.65rem',
                  borderRadius: '9999px',
                  background: 'rgba(255, 255, 255, 0.15)',
                  fontSize: '0.725rem',
                  fontWeight: 700,
                  textTransform: 'uppercase',
                }}
              >
                Step 2 of 3
              </span>
              <span style={{ fontSize: '0.8rem', color: 'rgba(255, 255, 255, 0.8)' }}>
                Partner: <strong>{businessName}</strong> ({mobile})
              </span>
            </div>
            <h1 style={{ fontSize: '1.75rem', fontWeight: 800, color: 'white' }}>
              Select Partner Categories
            </h1>
            <p style={{ color: 'rgba(255, 255, 255, 0.85)', fontSize: '0.875rem', marginTop: '0.25rem' }}>
              Assign main industries and specific subcategories this vendor provides.
            </p>
          </div>

          <div
            style={{
              background: 'rgba(255, 255, 255, 0.12)',
              backdropFilter: 'blur(8px)',
              border: '1px solid rgba(255, 255, 255, 0.2)',
              borderRadius: 'var(--radius-md)',
              padding: '0.75rem 1.25rem',
              textAlign: 'center',
            }}
          >
            <div style={{ fontSize: '1.5rem', fontWeight: 800, color: '#fcd34d' }}>
              {totalSelectedSubCats}
            </div>
            <div style={{ fontSize: '0.75rem', color: 'white', textTransform: 'uppercase', letterSpacing: '0.04em' }}>
              Subcategories Selected
            </div>
          </div>
        </div>
      </div>

      <div className="card" style={{ padding: '2rem' }}>

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
            <AlertCircle size={18} />
            <span>{error}</span>
          </div>
        )}

        {validationMsg && (
          <div
            style={{
              padding: '0.85rem 1rem',
              background: 'var(--warning-light)',
              border: '1px solid #fde68a',
              borderRadius: 'var(--radius-md)',
              color: '#92400e',
              fontSize: '0.85rem',
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem',
              marginBottom: '1.5rem',
            }}
          >
            <AlertCircle size={18} />
            <span>{validationMsg}</span>
          </div>
        )}

        {isLoadingCats ? (
          <div style={{ textAlign: 'center', padding: '4rem 0' }}>
            <Loader2 size={36} className="spinner" color="var(--primary)" />
            <p style={{ marginTop: '0.85rem', color: 'var(--text-muted)' }}>
              Loading catalog categories...
            </p>
          </div>
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: '260px 1fr', gap: '2rem' }}>
            {/* Left: Main Categories List */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
              <span style={{ fontSize: '0.75rem', fontWeight: 700, color: 'var(--text-subtle)', textTransform: 'uppercase' }}>
                Main Categories
              </span>

              {categories.map((cat) => {
                const isSelected = selectedCategory?.id === cat.id;
                const count = (selectedSubCats[cat.id] || []).length;

                return (
                  <button
                    key={cat.id}
                    onClick={() => handleCategoryClick(cat)}
                    style={{
                      padding: '0.85rem 1rem',
                      borderRadius: 'var(--radius-md)',
                      border: `1.5px solid ${isSelected ? 'var(--primary)' : 'var(--border-subtle)'}`,
                      background: isSelected ? 'var(--primary-light)' : 'white',
                      color: isSelected ? 'var(--primary-dark)' : 'var(--text-main)',
                      fontFamily: 'var(--font-heading)',
                      fontWeight: isSelected ? 700 : 600,
                      fontSize: '0.875rem',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      cursor: 'pointer',
                      textAlign: 'left',
                      transition: 'all 0.15s',
                    }}
                  >
                    <span>{cat.name}</span>
                    {count > 0 && (
                      <span
                        style={{
                          fontSize: '0.7rem',
                          background: 'var(--primary)',
                          color: 'white',
                          padding: '0.15rem 0.5rem',
                          borderRadius: '9999px',
                        }}
                      >
                        {count}
                      </span>
                    )}
                  </button>
                );
              })}
            </div>

            {/* Right: Subcategories Selector */}
            <div
              style={{
                border: '1px solid var(--border-subtle)',
                borderRadius: 'var(--radius-md)',
                padding: '1.5rem',
                background: 'var(--bg-subtle)',
              }}
            >
              <div style={{ marginBottom: '1rem' }}>
                <h4 style={{ fontSize: '1.05rem', color: 'var(--primary-dark)' }}>
                  {selectedCategory?.name} Subcategories
                </h4>
                <p style={{ fontSize: '0.775rem', color: 'var(--text-muted)' }}>
                  Tick all subcategories this partner provides:
                </p>
              </div>

              {isLoadingSubs ? (
                <div style={{ textAlign: 'center', padding: '3rem 0' }}>
                  <Loader2 size={28} className="spinner" color="var(--primary)" />
                  <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: '0.5rem' }}>
                    Loading subcategories...
                  </p>
                </div>
              ) : !selectedCategory || (subCategoriesMap[selectedCategory.id] || []).length === 0 ? (
                <div style={{ textAlign: 'center', padding: '3rem 0', color: 'var(--text-muted)' }}>
                  No subcategories found for this category.
                </div>
              ) : (
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: '0.75rem' }}>
                  {(subCategoriesMap[selectedCategory.id] || []).map((sub) => {
                    const isChecked = (selectedSubCats[selectedCategory.id] || []).includes(sub.id);

                    return (
                      <div
                        key={sub.id}
                        onClick={() => toggleSubCategory(selectedCategory.id, sub.id)}
                        style={{
                          padding: '0.85rem 1rem',
                          borderRadius: 'var(--radius-md)',
                          border: `1.5px solid ${isChecked ? 'var(--primary)' : 'var(--border-subtle)'}`,
                          background: isChecked ? 'white' : '#ffffff',
                          display: 'flex',
                          alignItems: 'center',
                          gap: '0.65rem',
                          cursor: 'pointer',
                          boxShadow: isChecked ? '0 4px 12px var(--primary-glow)' : 'none',
                          transition: 'all 0.15s ease',
                        }}
                      >
                        <div
                          style={{
                            width: '20px',
                            height: '20px',
                            borderRadius: '6px',
                            border: `1.5px solid ${isChecked ? 'var(--primary)' : 'var(--border-strong)'}`,
                            background: isChecked ? 'var(--primary)' : 'transparent',
                            color: 'white',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            flexShrink: 0,
                          }}
                        >
                          {isChecked && <Check size={14} />}
                        </div>

                        <span style={{ fontSize: '0.85rem', fontWeight: isChecked ? 700 : 500 }}>
                          {sub.name}
                        </span>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        )}

        {/* Footer Actions */}
        <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '2.5rem', paddingTop: '1.5rem', borderTop: '1px solid var(--border-subtle)' }}>
          <button
            className="btn btn-primary"
            onClick={handleProceed}
            disabled={totalSelectedSubCats === 0}
            style={{ padding: '0.85rem 2rem' }}
          >
            <span>Proceed to Services & Pricing</span>
            <ArrowRight size={18} />
          </button>
        </div>
      </div>
    </div>
  );
};
