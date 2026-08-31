// ============================================================================
// AM5 ROYAL • Company Leads Tab Component
// Powers Tab 2 (Website Leads) and Tab 3 (Application Leads) with 7-Step Workflow
// Mirrors Flutter: _buildCompanyLeadsTab()
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
} from 'lucide-react';

interface CompanyLeadsTabProps {
  isWebsite: boolean;
  onCountUpdate?: (count: number) => void;
}

export const CompanyLeadsTab: React.FC<CompanyLeadsTabProps> = ({
  isWebsite,
  onCountUpdate,
}) => {
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
  const [startDate, setStartDate] = useState<string>('');
  const [endDate, setEndDate] = useState<string>('');

  const leadSource = isWebsite ? 'company_website' : 'company_mobile';
  const title = isWebsite ? 'Company Website Leads' : 'Company Application Leads';
  const subtitle = isWebsite
    ? 'All leads and partner onboarding requests originating from the official Company Website.'
    : 'All leads and partner onboarding requests originating from the Company Mobile Application.';

  useEffect(() => {
    fetchLeads(true);
  }, [isWebsite]);

  const fetchLeads = async (reset = false) => {
    if (reset) {
      setIsLoading(true);
      setSkip(0);
    } else {
      setIsLoadingMore(true);
    }
    setError(null);

    const currentSkip = reset ? 0 : skip;

    try {
      const resp = await telecallerApi.getOnboardedVendors({
        leadSource,
        skip: currentSkip,
        limit,
        startDate: startDate || undefined,
        endDate: endDate || undefined,
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

  // Client-side filtering & sorting matching Flutter logic
  const filteredVendors = vendors
    .filter((v) => {
      // Exclude rejected
      if (v.status.toLowerCase() === 'rejected') return false;

      // Search Query filter
      if (searchQuery.trim()) {
        const q = searchQuery.toLowerCase();
        const haystack = `${v.businessName} ${v.firstName} ${v.lastName} ${v.mobileNumber} ${v.city}`.toLowerCase();
        if (!haystack.includes(q)) return false;
      }

      // Status Filter
      if (statusFilter !== 'All') {
        if (v.status.toLowerCase() !== statusFilter.toLowerCase()) {
          return false;
        }
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

  // Extract unique statuses for dropdown
  const statusOptions = [
    'All',
    'temporary active',
    'active',
    'payment',
    'business registration',
    'registration',
    'slots done',
    'services added',
  ];

  const clearFilters = () => {
    setSearchQuery('');
    setStatusFilter('All');
    setStartDate('');
    setEndDate('');
    fetchLeads(true);
  };

  const hasActiveFilters = Boolean(
    searchQuery.trim() || statusFilter !== 'All' || startDate || endDate
  );

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '1.75rem' }}>
      {/* Title */}
      <div>
        <h2 style={{ fontSize: '1.75rem', color: 'var(--text-main)' }}>{title}</h2>
        <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem', marginTop: '0.25rem' }}>
          {subtitle}
        </p>
      </div>

      {/* Filter Toolbar */}
      <div
        className="card"
        style={{
          padding: '1.25rem',
          display: 'flex',
          alignItems: 'center',
          flexWrap: 'wrap',
          gap: '1rem',
        }}
      >
        {/* Search Input */}
        <div className="form-control-wrapper" style={{ flex: '1 1 280px', minWidth: '240px' }}>
          <Search size={16} className="input-icon-left" />
          <input
            type="text"
            className="form-input has-left-icon"
            placeholder="Search by business, partner name, or mobile..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>

        {/* Status Filter */}
        <div style={{ minWidth: '180px' }}>
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

        {/* Date Filter */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem' }}>
          <input
            type="date"
            className="form-input"
            value={startDate}
            onChange={(e) => {
              setStartDate(e.target.value);
            }}
            title="Start Date"
            style={{ width: 'auto', padding: '0.5rem 0.75rem', fontSize: '0.825rem' }}
          />
          <span style={{ color: 'var(--text-subtle)', fontSize: '0.8rem' }}>to</span>
          <input
            type="date"
            className="form-input"
            value={endDate}
            onChange={(e) => {
              setEndDate(e.target.value);
            }}
            title="End Date"
            style={{ width: 'auto', padding: '0.5rem 0.75rem', fontSize: '0.825rem' }}
          />
          <button
            className="btn btn-sm btn-outline"
            onClick={() => fetchLeads(true)}
            title="Apply Date Range"
          >
            Apply
          </button>
        </div>

        {/* Clear Filters */}
        {hasActiveFilters && (
          <button className="btn btn-sm btn-outline" onClick={clearFilters} style={{ color: 'var(--danger)' }}>
            <X size={14} />
            <span>Clear</span>
          </button>
        )}

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

      {/* Main Content Area */}
      {isLoading ? (
        <div style={{ textAlign: 'center', padding: '5rem 0' }}>
          <Loader2 size={36} className="spinner" color="var(--primary)" />
          <p style={{ marginTop: '0.85rem', color: 'var(--text-muted)', fontSize: '0.875rem' }}>
            Loading {title.toLowerCase()}...
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
            <div style={{ fontWeight: 700 }}>Failed to Load Leads</div>
            <div style={{ fontSize: '0.825rem', marginTop: '0.2rem' }}>{error}</div>
          </div>
        </div>
      ) : filteredVendors.length === 0 ? (
        <div className="card" style={{ textAlign: 'center', padding: '4rem 1rem' }}>
          <p style={{ fontWeight: 700, color: 'var(--text-main)', fontSize: '1.05rem' }}>
            No leads found matching your criteria.
          </p>
          <p style={{ fontSize: '0.825rem', color: 'var(--text-muted)', marginTop: '0.35rem' }}>
            Try resetting your search query or adjusting your date and status filters.
          </p>
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
          {filteredVendors.map((vendor) => (
            <VendorStepperCard
              key={vendor.id}
              vendor={vendor}
              onRefreshList={() => fetchLeads(true)}
            />
          ))}

          {/* Load More Pagination */}
          {vendors.length < total && (
            <div style={{ textAlign: 'center', marginTop: '1.5rem' }}>
              <button
                className="btn btn-outline"
                onClick={() => fetchLeads(false)}
                disabled={isLoadingMore}
              >
                {isLoadingMore ? (
                  <>
                    <Loader2 size={16} className="spinner" />
                    <span>Loading More Leads...</span>
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
