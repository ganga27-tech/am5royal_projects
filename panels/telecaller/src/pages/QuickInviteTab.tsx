// ============================================================================
// AM5 ROYAL • Tab 1: WhatsApp & SMS Quick Tool + Lead Pipeline & Stuck Vendors
// Mirrors Flutter: _buildQuickInviteTab(), _buildLeadPipelineTab(), _stuckVendors
// ============================================================================

import React, { useState } from 'react';
import { vendorActionsApi } from '../api/vendorActionsApi';
import { Validation } from '../utils/validation';
import { PipelineLead, StuckVendor } from '../types';
import { extractErrorMessage } from '../api/client';
import {
  MessageSquareShare,
  UserPlus,
  Send,
  PhoneCall,
  CheckCircle2,
  AlertCircle,
  HelpCircle,
  Clock,
  ChevronDown,
  Sparkles,
  Loader2,
  AlertTriangle,
} from 'lucide-react';

export const QuickInviteTab: React.FC = () => {
  // Quick Lead Registration State
  const [vendorName, setVendorName] = useState('');
  const [vendorPhone, setVendorPhone] = useState('');
  const [category, setCategory] = useState('Home Cleaning');
  const [regErrors, setRegErrors] = useState<Record<string, string>>({});
  const [regSuccess, setRegSuccess] = useState<string | null>(null);

  // WhatsApp Invite Direct Tool
  const [invitePhone, setInvitePhone] = useState('');
  const [inviteName, setInviteName] = useState('');
  const [isSendingInvite, setIsSendingInvite] = useState(false);
  const [inviteNotice, setInviteNotice] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  // Pipeline Filter State
  const [selectedPipelineTab, setSelectedPipelineTab] = useState<'New' | 'Follow-up' | 'Not Interested'>('New');

  // Pipeline Leads State (persists during session like Flutter)
  const [leads, setLeads] = useState<PipelineLead[]>([
    {
      id: 'l1',
      name: 'Ramesh Kumar',
      phone: '+91 9988776655',
      category: 'Home Cleaning',
      status: 'New',
      note: 'Wants to register next week. Interested in premium tier.',
      lastCalled: '2026-06-18',
    },
    {
      id: 'l2',
      name: 'Vikram Mehra',
      phone: '+91 8877665544',
      category: 'Plumbing',
      status: 'Follow-up',
      note: 'Busy during noon. Call back after 6 PM.',
      lastCalled: '2026-06-19',
    },
    {
      id: 'l3',
      name: 'Suresh Reddy',
      phone: '+91 7766554433',
      category: 'AC Repair',
      status: 'New',
      note: 'Highly interested, send WhatsApp link.',
      lastCalled: 'N/A',
    },
    {
      id: 'l4',
      name: 'Gautam Sen',
      phone: '+91 6655443322',
      category: 'Electrical Services',
      status: 'Not Interested',
      note: 'Already using another aggregator.',
      lastCalled: '2026-06-15',
    },
  ]);

  // Stuck Vendors List (from Flutter lines 94-122)
  const [stuckVendors] = useState<StuckVendor[]>([
    {
      id: 's1',
      businessName: 'Balaji Electricals',
      ownerName: 'Venkatesh Prasad',
      phone: '+91 9443322110',
      stuckStage: 'Verification Documents',
      lastActive: '2 hours ago',
      helperNote: 'Uploaded GST but Aadhaar selfie failed.',
    },
    {
      id: 's2',
      businessName: 'Quick Dry Cleaners',
      ownerName: 'Sonia Gandhi',
      phone: '+91 8332211009',
      stuckStage: 'Service Additions',
      lastActive: '1 day ago',
      helperNote: 'Stuck selecting subcategory pricing list.',
    },
    {
      id: 's3',
      businessName: 'Home-care Solutions',
      ownerName: 'Amit Shah',
      phone: '+91 7221100998',
      stuckStage: 'OTP Verification',
      lastActive: '3 days ago',
      helperNote: 'Entered wrong number twice during signup.',
    },
  ]);

  const categoriesList = [
    'Home Cleaning',
    'Plumbing',
    'AC & Appliance Repair',
    'Electrical Services',
    'Salon & Beauty',
    'Painting',
  ];

  // Validate and submit Quick Onboarding Lead
  const handleRegisterLead = (e: React.FormEvent) => {
    e.preventDefault();
    setRegSuccess(null);

    const nameCheck = Validation.required(vendorName, 'Vendor Name');
    const phoneCheck = Validation.mobile(vendorPhone);

    const newErrors: Record<string, string> = {};
    if (!nameCheck.isValid) newErrors.name = nameCheck.error!;
    if (!phoneCheck.isValid) newErrors.phone = phoneCheck.error!;

    setRegErrors(newErrors);
    if (Object.keys(newErrors).length > 0) return;

    const newLead: PipelineLead = {
      id: `l_${Date.now()}`,
      name: vendorName.trim(),
      phone: vendorPhone.trim(),
      category,
      status: 'New',
      note: 'Registered from Quick Onboarding panel.',
      lastCalled: 'N/A',
    };

    setLeads((prev) => [newLead, ...prev]);
    setRegSuccess(`Lead "${vendorName}" registered in Lead Pipeline (+10 pts claimed)!`);

    // Pre-fill WhatsApp invite tool
    setInviteName(vendorName);
    setInvitePhone(vendorPhone);

    setVendorName('');
    setVendorPhone('');
    setRegErrors({});
  };

  // Direct WhatsApp Invite sender
  const handleSendWhatsAppInvite = async (phoneToSend?: string, nameToSend?: string) => {
    const targetPhone = phoneToSend || invitePhone;
    const targetName = nameToSend || inviteName;

    const phoneCheck = Validation.mobile(targetPhone);
    const nameCheck = Validation.required(targetName, 'Vendor Name');

    if (!phoneCheck.isValid || !nameCheck.isValid) {
      setInviteNotice({
        type: 'error',
        message: phoneCheck.error || nameCheck.error || 'Please enter valid phone and name',
      });
      return;
    }

    setIsSendingInvite(true);
    setInviteNotice(null);
    try {
      await vendorActionsApi.sendWhatsAppInvite(targetPhone, targetName);
      setInviteNotice({
        type: 'success',
        message: `WhatsApp invitation sent successfully to ${targetPhone}!`,
      });
      if (!phoneToSend) {
        setInvitePhone('');
        setInviteName('');
      }
    } catch (err) {
      setInviteNotice({
        type: 'error',
        message: extractErrorMessage(err),
      });
    } finally {
      setIsSendingInvite(false);
    }
  };

  // Move lead status
  const handleMoveLeadStatus = (leadId: string, newStatus: 'New' | 'Follow-up' | 'Not Interested') => {
    setLeads((prev) =>
      prev.map((l) => (l.id === leadId ? { ...l, status: newStatus } : l))
    );
  };

  // Filtered leads
  const filteredLeads = leads.filter(
    (l) => l.status.toLowerCase() === selectedPipelineTab.toLowerCase()
  );

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '2.25rem' }}>
      {/* Title */}
      <div>
        <h2 style={{ fontSize: '1.75rem', color: 'var(--text-main)' }}>
          WhatsApp & SMS Outreach Engine
        </h2>
        <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem', marginTop: '0.25rem' }}>
          Capture incoming partner inquiries, trigger instant WhatsApp links, and manage your call pipeline.
        </p>
      </div>

      {/* Top 2-Column Section: Quick Lead Registration + Instant Invite Tool */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(360px, 1fr))', gap: '1.5rem' }}>
        {/* Box 1: Quick Lead Capture */}
        <div className="card" style={{ padding: '1.75rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem', marginBottom: '1.25rem' }}>
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
              <UserPlus size={18} />
            </div>
            <div>
              <h3 style={{ fontSize: '1.1rem' }}>Quick Lead Registration</h3>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                Lock in your referral attribution while talking to a partner
              </p>
            </div>
          </div>

          {regSuccess && (
            <div
              style={{
                padding: '0.75rem 1rem',
                background: 'var(--success-light)',
                border: '1px solid var(--success)',
                borderRadius: 'var(--radius-md)',
                color: '#065f46',
                fontSize: '0.825rem',
                marginBottom: '1rem',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
              }}
            >
              <CheckCircle2 size={16} />
              <span>{regSuccess}</span>
            </div>
          )}

          <form onSubmit={handleRegisterLead}>
            <div className="form-group">
              <label className="form-label">
                Owner / Vendor Full Name <span className="required-star">*</span>
              </label>
              <input
                type="text"
                className={`form-input ${regErrors.name ? 'is-invalid' : ''}`}
                placeholder="e.g. Ramesh Kumar"
                value={vendorName}
                onChange={(e) => setVendorName(e.target.value)}
              />
              {regErrors.name && <div className="form-error-msg">{regErrors.name}</div>}
            </div>

            <div className="form-group">
              <label className="form-label">
                Mobile Phone Number <span className="required-star">*</span>
              </label>
              <input
                type="tel"
                className={`form-input ${regErrors.phone ? 'is-invalid' : ''}`}
                placeholder="10-digit mobile number"
                value={vendorPhone}
                onChange={(e) => setVendorPhone(e.target.value)}
                maxLength={10}
              />
              {regErrors.phone && <div className="form-error-msg">{regErrors.phone}</div>}
            </div>

            <div className="form-group">
              <label className="form-label">Primary Service Category</label>
              <select
                className="form-select"
                value={category}
                onChange={(e) => setCategory(e.target.value)}
              >
                {categoriesList.map((cat) => (
                  <option key={cat} value={cat}>
                    {cat}
                  </option>
                ))}
              </select>
            </div>

            <button type="submit" className="btn btn-primary" style={{ width: '100%', marginTop: '0.5rem' }}>
              <Sparkles size={16} />
              <span>Register Lead & Claim Attribution</span>
            </button>
          </form>
        </div>

        {/* Box 2: Instant WhatsApp Invite Dispatch */}
        <div
          className="card"
          style={{
            padding: '1.75rem',
            background: 'linear-gradient(135deg, #ffffff 0%, #f0fdfa 100%)',
            border: '1.5px solid rgba(13, 148, 136, 0.25)',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem', marginBottom: '1.25rem' }}>
            <div
              style={{
                width: '36px',
                height: '36px',
                borderRadius: '10px',
                background: 'var(--secondary-light)',
                color: 'var(--secondary)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <MessageSquareShare size={18} />
            </div>
            <div>
              <h3 style={{ fontSize: '1.1rem', color: '#0f766e' }}>WhatsApp Direct Dispatch</h3>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                Sends an official AM5 Royal registration link directly to the partner's WhatsApp
              </p>
            </div>
          </div>

          {inviteNotice && (
            <div
              style={{
                padding: '0.75rem 1rem',
                background: inviteNotice.type === 'success' ? 'var(--success-light)' : 'var(--danger-light)',
                border: `1px solid ${inviteNotice.type === 'success' ? 'var(--success)' : 'var(--danger-border)'}`,
                borderRadius: 'var(--radius-md)',
                color: inviteNotice.type === 'success' ? '#065f46' : 'var(--danger)',
                fontSize: '0.825rem',
                marginBottom: '1rem',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
              }}
            >
              {inviteNotice.type === 'success' ? <CheckCircle2 size={16} /> : <AlertCircle size={16} />}
              <span>{inviteNotice.message}</span>
            </div>
          )}

          <div>
            <div className="form-group">
              <label className="form-label">
                Recipient Partner Name <span className="required-star">*</span>
              </label>
              <input
                type="text"
                className="form-input"
                placeholder="Partner Name"
                value={inviteName}
                onChange={(e) => setInviteName(e.target.value)}
              />
            </div>

            <div className="form-group">
              <label className="form-label">
                WhatsApp Phone Number <span className="required-star">*</span>
              </label>
              <input
                type="tel"
                className="form-input"
                placeholder="10-digit mobile phone"
                value={invitePhone}
                onChange={(e) => setInvitePhone(e.target.value)}
                maxLength={10}
              />
            </div>

            <button
              type="button"
              className="btn btn-secondary"
              style={{ width: '100%', marginTop: '0.5rem' }}
              onClick={() => handleSendWhatsAppInvite()}
              disabled={isSendingInvite}
            >
              {isSendingInvite ? (
                <>
                  <Loader2 size={16} className="spinner" />
                  <span>Dispatching WhatsApp Invite...</span>
                </>
              ) : (
                <>
                  <Send size={16} />
                  <span>Send WhatsApp Invitation Link</span>
                </>
              )}
            </button>
          </div>
        </div>
      </div>

      {/* Middle Section: Lead Pipeline & Calls */}
      <div className="card" style={{ padding: '1.75rem' }}>
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            flexWrap: 'wrap',
            gap: '1rem',
            marginBottom: '1.5rem',
          }}
        >
          <div>
            <h3 style={{ fontSize: '1.2rem' }}>Lead Pipeline & Call Log</h3>
            <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
              Follow up with prospective partners and track call notes
            </p>
          </div>

          {/* Filter Pills */}
          <div style={{ display: 'flex', gap: '0.5rem' }}>
            {(['New', 'Follow-up', 'Not Interested'] as const).map((tab) => {
              const count = leads.filter((l) => l.status === tab).length;
              const isSelected = selectedPipelineTab === tab;
              return (
                <button
                  key={tab}
                  onClick={() => setSelectedPipelineTab(tab)}
                  style={{
                    padding: '0.45rem 0.95rem',
                    borderRadius: 'var(--radius-md)',
                    border: `1px solid ${isSelected ? 'var(--primary)' : 'var(--border-subtle)'}`,
                    background: isSelected ? 'var(--primary)' : 'var(--bg-surface)',
                    color: isSelected ? 'white' : 'var(--text-main)',
                    fontFamily: 'var(--font-heading)',
                    fontSize: '0.825rem',
                    fontWeight: 700,
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.45rem',
                    transition: 'all 0.15s',
                  }}
                >
                  <span>{tab}</span>
                  <span
                    style={{
                      fontSize: '0.7rem',
                      padding: '0.1rem 0.4rem',
                      borderRadius: '9999px',
                      background: isSelected ? 'rgba(255, 255, 255, 0.25)' : 'var(--bg-subtle)',
                      color: isSelected ? 'white' : 'var(--text-muted)',
                    }}
                  >
                    {count}
                  </span>
                </button>
              );
            })}
          </div>
        </div>

        {/* Leads List */}
        {filteredLeads.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '3.5rem 1rem' }}>
            <p style={{ fontWeight: 600, color: 'var(--text-muted)' }}>
              No leads currently in "{selectedPipelineTab}" list.
            </p>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            {filteredLeads.map((lead) => (
              <div
                key={lead.id}
                style={{
                  padding: '1.25rem',
                  borderRadius: 'var(--radius-md)',
                  border: '1px solid var(--border-subtle)',
                  background: 'var(--bg-surface)',
                  display: 'flex',
                  alignItems: 'flex-start',
                  justifyContent: 'space-between',
                  gap: '1rem',
                  boxShadow: 'var(--shadow-sm)',
                }}
              >
                {/* Left: Initial Avatar + Lead Info */}
                <div style={{ display: 'flex', gap: '1rem', flex: 1 }}>
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
                      fontWeight: 800,
                      fontSize: '1.1rem',
                      flexShrink: 0,
                    }}
                  >
                    {lead.name[0]}
                  </div>

                  <div style={{ flex: 1 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
                      <span style={{ fontWeight: 700, fontSize: '1rem', color: 'var(--text-main)' }}>
                        {lead.name}
                      </span>
                      <span
                        style={{
                          fontSize: '0.7rem',
                          fontWeight: 700,
                          padding: '0.15rem 0.5rem',
                          borderRadius: '6px',
                          background: 'var(--bg-subtle)',
                          color: 'var(--text-muted)',
                        }}
                      >
                        {lead.category}
                      </span>
                    </div>

                    <div style={{ fontSize: '0.825rem', color: 'var(--text-muted)', marginTop: '0.2rem' }}>
                      Phone: <span style={{ fontFamily: 'monospace', fontWeight: 600 }}>{lead.phone}</span>
                    </div>

                    {/* Note Box */}
                    <div
                      style={{
                        marginTop: '0.6rem',
                        padding: '0.65rem 0.85rem',
                        borderRadius: 'var(--radius-sm)',
                        background: 'var(--bg-subtle)',
                        fontSize: '0.8rem',
                        color: 'var(--text-muted)',
                      }}
                    >
                      {lead.note}
                    </div>

                    <div style={{ fontSize: '0.725rem', color: 'var(--text-subtle)', marginTop: '0.4rem' }}>
                      Last call attempt: {lead.lastCalled}
                    </div>
                  </div>
                </div>

                {/* Right: Actions */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', alignItems: 'flex-end' }}>
                  <div style={{ display: 'flex', gap: '0.5rem' }}>
                    <a
                      href={`tel:${lead.phone}`}
                      className="btn btn-sm btn-outline"
                      style={{ textDecoration: 'none', color: '#059669', borderColor: '#a7f3d0' }}
                      title="Call Phone"
                    >
                      <PhoneCall size={14} />
                      <span>Call</span>
                    </a>

                    <button
                      className="btn btn-sm btn-outline"
                      style={{ color: 'var(--primary)', borderColor: 'var(--primary-glow)' }}
                      onClick={() => handleSendWhatsAppInvite(lead.phone, lead.name)}
                      title="Send WhatsApp Invite"
                    >
                      <Send size={14} />
                      <span>Invite</span>
                    </button>
                  </div>

                  {/* Status Dropdown */}
                  <select
                    className="form-select"
                    value={lead.status}
                    onChange={(e) =>
                      handleMoveLeadStatus(
                        lead.id,
                        e.target.value as 'New' | 'Follow-up' | 'Not Interested'
                      )
                    }
                    style={{
                      padding: '0.35rem 0.65rem',
                      fontSize: '0.775rem',
                      fontWeight: 600,
                      width: 'auto',
                    }}
                  >
                    <option value="New">Status: New</option>
                    <option value="Follow-up">Status: Follow-up</option>
                    <option value="Not Interested">Status: Not Interested</option>
                  </select>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Bottom Section: Stuck Vendors Assistance Pool */}
      <div className="card" style={{ padding: '1.75rem' }}>
        <div style={{ marginBottom: '1.25rem' }}>
          <h3 style={{ fontSize: '1.2rem', color: '#991b1b' }}>
            Stuck Vendors Needing Telecaller Assistance
          </h3>
          <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
            These partners began onboarding but dropped off before completing verification. Call to assist them.
          </p>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '1rem' }}>
          {stuckVendors.map((sv) => (
            <div
              key={sv.id}
              style={{
                padding: '1.15rem',
                borderRadius: 'var(--radius-md)',
                border: '1px solid #fee2e2',
                background: '#fffbfb',
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'space-between',
                gap: '0.75rem',
              }}
            >
              <div>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                  <div style={{ fontWeight: 700, fontSize: '0.95rem', color: '#991b1b' }}>
                    {sv.businessName}
                  </div>
                  <span
                    style={{
                      fontSize: '0.7rem',
                      fontWeight: 700,
                      padding: '0.15rem 0.45rem',
                      borderRadius: '6px',
                      background: '#fee2e2',
                      color: '#b91c1c',
                    }}
                  >
                    Stuck: {sv.stuckStage}
                  </span>
                </div>

                <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: '0.25rem' }}>
                  {sv.ownerName} • <span style={{ fontFamily: 'monospace' }}>{sv.phone}</span>
                </div>

                <div
                  style={{
                    marginTop: '0.5rem',
                    fontSize: '0.775rem',
                    color: '#7f1d1d',
                    background: '#fef2f2',
                    padding: '0.45rem 0.65rem',
                    borderRadius: '6px',
                  }}
                >
                  Note: {sv.helperNote}
                </div>
              </div>

              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingTop: '0.5rem', borderTop: '1px solid #fee2e2' }}>
                <span style={{ fontSize: '0.725rem', color: 'var(--text-subtle)' }}>
                  Active {sv.lastActive}
                </span>
                <a
                  href={`tel:${sv.phone}`}
                  className="btn btn-sm btn-danger"
                  style={{ textDecoration: 'none' }}
                >
                  <PhoneCall size={13} />
                  <span>Assist Now</span>
                </a>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
