// ============================================================================
// AM5 ROYAL • Leads Management Tab Component (Sections 5, 6 & 7 Specifications)
// Powers Company Website Leads, Company Application Leads & Freelancer Leads
// ============================================================================

import React, { useEffect, useState } from 'react';
import { telecallerApi } from '../api/telecallerApi';
import { TelecallerOnboardedVendor } from '../types';
import { VendorStepperCard } from '../components/vendors/VendorStepperCard';
import { extractErrorMessage } from '../api/client';
import {
  Search,
  Filter,
  Calendar,
  RefreshCw,
  AlertCircle,
  Loader2,
  X,
  Globe,
  Smartphone,
  Briefcase,
} from 'lucide-react';

export type LeadSourceType = 'website' | 'application' | 'freelancer';

interface CompanyLeadsTabProps {
  isWebsite?: boolean;
  sourceType?: LeadSourceType;
  onCountUpdate?: (count: number) => void;
}

export const CompanyLeadsTab: React.FC<CompanyLeadsTabProps> = ({
  isWebsite,
  sourceType,
  onCountUpdate,
}) => {
  // Resolve effective source type
  const effectiveSource: LeadSourceType =
    sourceType || (isWebsite === false ? 'application' : 'website');

  const [vendors, setVendors] = useState<TelecallerOnboardedVendor[]>([]);
  const [total, setTotal] = useState(0);
  const [skip, setSkip] = useState(0);
  const limit = 50;

  const [isLoading, setIsLoading] = useState(true);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Filters
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState('All');
  const [datePreset, setDatePreset] = useState<'all' | 'today' | 'week' | 'month' | 'custom'>('all');
  const [startDate, setStartDate] = useState<string>('');
  const [endDate, setEndDate] = useState<string>('');

  // Map source to API leadSource parameter
  const getApiLeadSource = () => {
    switch (effectiveSource) {
      case 'website':
        return 'company_website';
      case 'application':
        return 'company_mobile';
      case 'freelancer':
        return 'freelancer';
    }
  };

  const leadSource = getApiLeadSource();

  // Page Header Details per Specification
  const getHeaderInfo = () => {
    switch (effectiveSource) {
      case 'website':
        return {
          title: 'Company Website Leads',
          description: 'This section displays all leads generated through the AM5 ROYAL Company Website.',
          icon: Globe,
        };
      case 'application':
        return {
          title: 'Company Application Leads',
          description: 'This section displays all leads generated from the AM5 ROYAL Company Application.',
          icon: Smartphone,
        };
      case 'freelancer':
        return {
          title: 'Freelancer Leads',
          description: 'This section displays all leads generated through the AM5 ROYAL Freelancer partners.',
          icon: Briefcase,
        };
    }
  };

  const headerInfo = getHeaderInfo();
  const HeaderIcon = headerInfo.icon;

  useEffect(() => {
    fetchLeads(true);
  }, [effectiveSource]);

  const fetchLeads = async (reset = false, customStart?: string, customEnd?: string) => {
    if (reset) {
      setIsLoading(true);
      setSkip(0);
    } else {
      setIsLoadingMore(true);
    }
    setError(null);

    const currentSkip = reset ? 0 : skip;
    const effStart = customStart !== undefined ? customStart : startDate;
    const effEnd = customEnd !== undefined ? customEnd : endDate;

    try {
      const resp = await telecallerApi.getOnboardedVendors({
        leadSource,
        skip: currentSkip,
        limit,
        startDate: effStart || undefined,
        endDate: effEnd || undefined,
      });

      if (reset) {
        setVendors(resp.vendors);
      } else {
        setVendors((prev) => [...prev, ...resp.vendors]);
      }
      setTotal(resp.total);
      if (onCountUpdate) onCountUpdate(resp.total);

      if (!reset) {
        setSkip(currentSkip + limit);
      } else {
        setSkip(limit);
      }
    } catch (err) {
      setError(extractErrorMessage(err));
    } finally {
      setIsLoading(false);
      setIsLoadingMore(false);
    }
  };

  // Quick Date Preset Handler
  const handleDatePreset = (preset: 'all' | 'today' | 'week' | 'month' | 'custom') => {
    setDatePreset(preset);
    const today = new Date();
    const formatDateStr = (d: Date) => d.toISOString().split('T')[0];

    if (preset === 'all') {
      setStartDate('');
      setEndDate('');
      fetchLeads(true, '', '');
    } else if (preset === 'today') {
      const todayStr = formatDateStr(today);
      setStartDate(todayStr);
      setEndDate(todayStr);
      fetchLeads(true, todayStr, todayStr);
    } else if (preset === 'week') {
      const day = today.getDay();
      const diff = today.getDate() - day + (day === 0 ? -6 : 1);
      const monday = new Date(today.setDate(diff));
      const monStr = formatDateStr(monday);
      const nowStr = formatDateStr(new Date());
      setStartDate(monStr);
      setEndDate(nowStr);
      fetchLeads(true, monStr, nowStr);
    } else if (preset === 'month') {
      const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
      const firstStr = formatDateStr(firstDay);
      const nowStr = formatDateStr(new Date());
      setStartDate(firstStr);
      setEndDate(nowStr);
      fetchLeads(true, firstStr, nowStr);
    }
  };

  // Filtering & Sorting
  const filteredVendors = vendors
    .filter((v) => {
      // Exclude rejected
      if (v.status.toLowerCase() === 'rejected') return false;

      // Search Query filter: Vendor Name, Business Name, Phone Number, Email
      if (searchQuery.trim()) {
        const q = searchQuery.toLowerCase();
        const haystack = `${v.businessName} ${v.firstName} ${v.lastName} ${v.mobileNumber} ${v.email || ''} ${v.city}`.toLowerCase();
        if (!haystack.includes(q)) return false;
      }

      // Status Filter
      if (statusFilter !== 'All') {
        const target = statusFilter.toLowerCase();
        const cardStatus = v.status.toLowerCase();
        const crmStatus = (v.leadStatus || '').toLowerCase();

        const matchesStatus =
          cardStatus === target ||
          cardStatus.includes(target) ||
          crmStatus === target ||
          crmStatus.includes(target);

        if (!matchesStatus) return false;
      }

      return true;
    })
    .sort((a, b) => {
      // Rank: temporary active first (under verification), then payment, then rest
      const rank = (st: string) => {
        const s = st.toLowerCase().replace(/[\s_]+/g, ' ');
        if (s === 'temporary active' || s === 'temp active') return 0;
        if (s === 'payment') return 1;
        return 2;
      };

      const byRank = rank(a.status) - rank(b.status);
      if (byRank !== 0) return byRank;
      return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
    });

  // Status Filter Options per Sections 5.1, 6.1, 7.1
  const getStatusOptions = () => {
    if (effectiveSource === 'website') {
      return [
        'All',
        'New',
        'Contacted',
        'In Progress',
        'Registration Pending',
        'KYC Pending',
        'Payment Pending',
        'Converted',
        'Not Interested',
        'Closed',
        'Temporary Active',
        'Active',
      ];
    }
    return [
      'All',
      'Active',
      'Pending',
      'Completed',
      'Inactive',
      'Temporary Active',
    ];
  };

  const statusOptions = getStatusOptions();

  const clearFilters = () => {
    setSearchQuery('');
    setStatusFilter('All');
    setDatePreset('all');
    setStartDate('');
    setEndDate('');
    fetchLeads(true, '', '');
  };

  const hasActiveFilters = Boolean(
    searchQuery.trim() || statusFilter !== 'All' || datePreset !== 'all' || startDate || endDate
  );

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '1.75rem' }}>
      {/* Title Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
        <div
          style={{
            width: '44px',
            height: '44px',
            borderRadius: '12px',
            background: 'var(--primary-light)',
            color: 'var(--primary)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <HeaderIcon size={22} />
        </div>
        <div>
          <h2 style={{ fontSize: '1.75rem', color: 'var(--text-main)' }}>{headerInfo.title}</h2>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem', marginTop: '0.15rem' }}>
            {headerInfo.description}
          </p>
        </div>
      </div>

      {/* Filter Toolbar */}
      <div
        className="card"
        style={{
          padding: '1.25rem',
          display: 'flex',
          flexDirection: 'column',
          gap: '1rem',
        }}
      >
        {/* Row 1: Search Bar & Status Dropdown */}
        <div style={{ display: 'flex', alignItems: 'center', flexWrap: 'wrap', gap: '0.85rem' }}>
          {/* Search Input */}
          <div className="form-control-wrapper" style={{ flex: '1 1 300px', minWidth: '240px' }}>
            <Search size={16} className="input-icon-left" />
            <input
              type="text"
              className="form-input has-left-icon"
              placeholder="Search by vendor name, business, phone number, email, or city..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>

          {/* Status Filter */}
          <div style={{ minWidth: '190px' }}>
            <select
              className="form-select"
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
            >
              {statusOptions.map((opt) => (
                <option key={opt} value={opt}>
                  {opt === 'All' ? 'All Statuses' : `Status: ${opt}`}
                </option>
              ))}
            </select>
          </div>

          <button
            className="btn btn-sm btn-outline"
            onClick={() => fetchLeads(true)}
            style={{ marginLeft: 'auto' }}
            title="Refresh List"
          >
            <RefreshCw size={14} />
            <span>Refresh</span>
          </button>
        </div>

        {/* Row 2: Date Filter Presets (Today, This Week, This Month, Custom Date) */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            flexWrap: 'wrap',
            gap: '0.75rem',
            borderTop: '1px solid var(--border-subtle)',
            paddingTop: '0.85rem',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', flexWrap: 'wrap', gap: '0.4rem' }}>
            <span style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-subtle)', marginRight: '0.25rem' }}>
              Date Filter:
            </span>

            {[
              { id: 'all', label: 'All Dates' },
              { id: 'today', label: 'Today' },
              { id: 'week', label: 'This Week' },
              { id: 'month', label: 'This Month' },
              { id: 'custom', label: 'Custom Date' },
            ].map((p) => {
              const isSelected = datePreset === p.id;
              return (
                <button
                  key={p.id}
                  onClick={() => handleDatePreset(p.id as any)}
                  style={{
                    padding: '0.35rem 0.75rem',
                    borderRadius: '6px',
                    border: '1px solid',
                    borderColor: isSelected ? 'var(--primary)' : 'var(--border-subtle)',
                    background: isSelected ? 'var(--primary-light)' : 'white',
                    color: isSelected ? 'var(--primary)' : 'var(--text-muted)',
                    fontSize: '0.75rem',
                    fontWeight: isSelected ? 700 : 500,
                    cursor: 'pointer',
                    transition: 'all 0.15s ease',
                  }}
                >
                  {p.label}
                </button>
              );
            })}

            {datePreset === 'custom' && (
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', marginLeft: '0.5rem' }}>
                <input
                  type="date"
                  className="form-input"
                  value={startDate}
                  onChange={(e) => setStartDate(e.target.value)}
                  style={{ width: 'auto', padding: '0.35rem 0.65rem', fontSize: '0.75rem' }}
                />
                <span style={{ color: 'var(--text-subtle)', fontSize: '0.75rem' }}>to</span>
                <input
                  type="date"
                  className="form-input"
                  value={endDate}
                  onChange={(e) => setEndDate(e.target.value)}
                  style={{ width: 'auto', padding: '0.35rem 0.65rem', fontSize: '0.75rem' }}
                />
                <button
                  className="btn btn-sm btn-outline"
                  onClick={() => fetchLeads(true)}
                  style={{ padding: '0.35rem 0.65rem', fontSize: '0.75rem' }}
                >
                  Apply
                </button>
              </div>
            )}
          </div>

          {/* Clear Filters button */}
          {hasActiveFilters && (
            <button
              className="btn btn-sm btn-outline"
              onClick={clearFilters}
              style={{ color: 'var(--danger)', borderColor: 'var(--danger-border)' }}
            >
              <X size={14} />
              <span>Clear Filters</span>
            </button>
          )}
        </div>
      </div>

      {/* Error Banner */}
      {error && (
        <div
          style={{
            padding: '1rem',
            background: 'var(--danger-light)',
            borderRadius: 'var(--radius-md)',
            color: 'var(--danger)',
            fontSize: '0.875rem',
            display: 'flex',
            alignItems: 'center',
            gap: '0.5rem',
          }}
        >
          <AlertCircle size={18} />
          <span>{error}</span>
        </div>
      )}

      {/* Loading Skeleton / List */}
      {isLoading ? (
        <div style={{ padding: '3.5rem', textAlign: 'center' }}>
          <Loader2 size={32} className="spinner" style={{ margin: '0 auto 1rem auto' }} />
          <p style={{ color: 'var(--text-muted)' }}>Loading {headerInfo.title}...</p>
        </div>
      ) : filteredVendors.length === 0 ? (
        <div className="card" style={{ padding: '3.5rem', textAlign: 'center' }}>
          <HeaderIcon size={40} color="var(--text-subtle)" style={{ margin: '0 auto 0.75rem auto' }} />
          <h3 style={{ marginBottom: '0.25rem', color: 'var(--text-main)' }}>No Leads Found</h3>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem', maxWidth: '420px', margin: '0 auto' }}>
            {hasActiveFilters
              ? 'No leads matched your search or status filter. Try clearing or relaxing filters.'
              : `There are currently no active ${headerInfo.title.toLowerCase()} in the queue.`}
          </p>
          {hasActiveFilters && (
            <button
              className="btn btn-outline"
              onClick={clearFilters}
              style={{ marginTop: '1rem' }}
            >
              Reset Filters
            </button>
          )}
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              fontSize: '0.825rem',
              color: 'var(--text-muted)',
              padding: '0 0.25rem',
            }}
          >
            <span>
              Showing <strong>{filteredVendors.length}</strong> of <strong>{total}</strong> leads
            </span>
            <span>Sorted: Verification Priority First</span>
          </div>

          {filteredVendors.map((vendor) => (
            <VendorStepperCard
              key={vendor.id}
              vendor={vendor}
              onRefreshList={() => fetchLeads(true)}
            />
          ))}

          {/* Load More Button */}
          {vendors.length < total && (
            <div style={{ textAlign: 'center', marginTop: '1rem' }}>
              <button
                className="btn btn-outline"
                onClick={() => fetchLeads(false)}
                disabled={isLoadingMore}
                style={{ minWidth: '180px' }}
              >
                {isLoadingMore ? (
                  <>
                    <Loader2 size={16} className="spinner" />
                    <span>Loading more leads...</span>
                  </>
                ) : (
                  <span>Load More ({total - vendors.length} remaining)</span>
                )}
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
};
