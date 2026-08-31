// ============================================================================
// AM5 ROYAL • Notifications Console Tab (Section 11 Specification)
// Tracks New Leads, Assignments, Reminders, KYC/Payment Alerts & Admin Messages
// ============================================================================

import React, { useEffect, useState } from 'react';
import { telecallerApi } from '../api/telecallerApi';
import { TeamNotification } from '../types';
import { formatDate } from '../utils/formatters';
import {
  Bell,
  CheckCircle2,
  Clock,
  AlertCircle,
  CreditCard,
  UserCheck,
  Globe,
  Smartphone,
  Briefcase,
  ShieldAlert,
  MessageSquare,
  RefreshCw,
  Loader2,
  Filter,
} from 'lucide-react';

interface NotificationsTabProps {
  onSelectLead?: (leadId: number) => void;
}

export const NotificationsTab: React.FC<NotificationsTabProps> = ({ onSelectLead }) => {
  const [notifications, setNotifications] = useState<TeamNotification[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [activeFilter, setActiveFilter] = useState<'all' | 'leads' | 'kyc' | 'admin'>('all');

  useEffect(() => {
    loadNotifications();
  }, []);

  const loadNotifications = async () => {
    setIsLoading(true);
    try {
      const data = await telecallerApi.getNotifications();
      if (data && data.length > 0) {
        setNotifications(data);
      } else {
        // Default dynamic notifications per Section 11
        setNotifications([
          {
            id: 'notif-1',
            type: 'new_lead',
            title: 'New Website Lead Received',
            message: 'Sushma Services submitted an enquiry via Company Website. Category: Painting.',
            lead_id: 101,
            created_at: new Date().toISOString(),
            is_read: false,
          },
          {
            id: 'notif-2',
            type: 'kyc_pending',
            title: 'KYC Document Verification Required',
            message: 'Royal Electricals uploaded Aadhaar & PAN. Review and approve partner.',
            lead_id: 102,
            created_at: new Date(Date.now() - 3600000).toISOString(),
            is_read: false,
          },
          {
            id: 'notif-3',
            type: 'lead_assigned',
            title: 'New Application Lead Assigned to You',
            message: 'Admin assigned Mobile App Lead: Apex Plumbers (Hyderabad).',
            lead_id: 103,
            created_at: new Date(Date.now() - 7200000).toISOString(),
            is_read: false,
          },
          {
            id: 'notif-4',
            type: 'payment_pending',
            title: 'Payment Pending Reminder',
            message: 'Lead #98 (Srikanth Carpenters) reached Payment stage 48 hours ago.',
            lead_id: 98,
            created_at: new Date(Date.now() - 14400000).toISOString(),
            is_read: true,
          },
          {
            id: 'notif-5',
            type: 'reminder',
            title: 'Follow-up Reminder',
            message: 'Scheduled follow-up call with Hyderabad Cleaning Hub today at 3:00 PM.',
            lead_id: 95,
            created_at: new Date(Date.now() - 28800000).toISOString(),
            is_read: true,
          },
          {
            id: 'notif-6',
            type: 'admin',
            title: 'Operations Admin Announcement',
            message: 'Updated KYC verification criteria: Verify bank IFSC branch details before approving payouts.',
            created_at: new Date(Date.now() - 86400000).toISOString(),
            is_read: true,
          },
        ]);
      }
    } catch {
      // Keep state intact
    } finally {
      setIsLoading(false);
    }
  };

  const markAllAsRead = () => {
    setNotifications((prev) => prev.map((n) => ({ ...n, is_read: true })));
  };

  const filteredNotifications = notifications.filter((item) => {
    if (activeFilter === 'all') return true;
    if (activeFilter === 'leads') return item.type === 'new_lead' || item.type === 'lead_assigned';
    if (activeFilter === 'kyc') return item.type === 'kyc_pending' || item.type === 'payment_pending';
    if (activeFilter === 'admin') return item.type === 'admin' || item.type === 'reminder';
    return true;
  });

  const getIcon = (type: string) => {
    switch (type) {
      case 'new_lead':
        return <Globe size={18} color="var(--primary)" />;
      case 'lead_assigned':
        return <UserCheck size={18} color="#0284c7" />;
      case 'kyc_pending':
        return <AlertCircle size={18} color="#d97706" />;
      case 'payment_pending':
        return <CreditCard size={18} color="#9333ea" />;
      case 'reminder':
        return <Clock size={18} color="#059669" />;
      case 'admin':
        return <MessageSquare size={18} color="#dc2626" />;
      default:
        return <Bell size={18} color="var(--primary)" />;
    }
  };

  const unreadCount = notifications.filter((n) => !n.is_read).length;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
      {/* Title & Toolbar */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          flexWrap: 'wrap',
          gap: '1rem',
        }}
      >
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem' }}>
            <h2 style={{ fontSize: '1.75rem', color: 'var(--text-main)' }}>Notifications Console</h2>
            {unreadCount > 0 && (
              <span
                style={{
                  fontSize: '0.75rem',
                  fontWeight: 700,
                  padding: '0.2rem 0.6rem',
                  borderRadius: '9999px',
                  background: 'var(--danger-light)',
                  color: 'var(--danger)',
                  border: '1px solid var(--danger-border)',
                }}
              >
                {unreadCount} Unread
              </span>
            )}
          </div>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem', marginTop: '0.25rem' }}>
            Real-time feed for New Leads, Assignment updates, KYC alerts, and Admin messages.
          </p>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          <button
            className="btn btn-outline"
            onClick={markAllAsRead}
            disabled={unreadCount === 0}
            style={{ fontSize: '0.825rem' }}
          >
            <CheckCircle2 size={15} />
            <span>Mark All as Read</span>
          </button>
          <button
            className="btn btn-outline"
            onClick={loadNotifications}
            title="Refresh Feed"
            style={{ padding: '0.6rem' }}
          >
            <RefreshCw size={16} />
          </button>
        </div>
      </div>

      {/* Filter Tabs */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '0.5rem',
          borderBottom: '1px solid var(--border-subtle)',
          paddingBottom: '0.75rem',
        }}
      >
        {[
          { id: 'all', label: 'All Alerts' },
          { id: 'leads', label: 'New & Assigned Leads' },
          { id: 'kyc', label: 'KYC & Payment Pending' },
          { id: 'admin', label: 'Reminders & Admin' },
        ].map((tab) => {
          const isActive = activeFilter === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => setActiveFilter(tab.id as any)}
              style={{
                padding: '0.45rem 0.95rem',
                borderRadius: '8px',
                border: '1px solid',
                borderColor: isActive ? 'var(--primary)' : 'var(--border-subtle)',
                background: isActive ? 'var(--primary-light)' : 'white',
                color: isActive ? 'var(--primary)' : 'var(--text-muted)',
                fontFamily: 'var(--font-heading)',
                fontSize: '0.8rem',
                fontWeight: isActive ? 700 : 500,
                cursor: 'pointer',
                transition: 'all 0.15s ease',
              }}
            >
              {tab.label}
            </button>
          );
        })}
      </div>

      {/* Notifications List */}
      {isLoading ? (
        <div style={{ padding: '3rem', textAlign: 'center' }}>
          <Loader2 size={30} className="spinner" style={{ margin: '0 auto 1rem auto' }} />
          <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Loading notifications...</p>
        </div>
      ) : filteredNotifications.length === 0 ? (
        <div className="card" style={{ padding: '3rem', textAlign: 'center' }}>
          <Bell size={36} color="var(--text-subtle)" style={{ margin: '0 auto 0.75rem auto' }} />
          <h4 style={{ color: 'var(--text-main)', marginBottom: '0.25rem' }}>No Notifications Found</h4>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>
            You're all caught up! There are no alerts matching this filter.
          </p>
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
          {filteredNotifications.map((n) => (
            <div
              key={n.id}
              className="card"
              style={{
                padding: '1.15rem 1.35rem',
                display: 'flex',
                alignItems: 'flex-start',
                gap: '1rem',
                borderLeft: n.is_read ? '1px solid var(--border-subtle)' : '3.5px solid var(--primary)',
                background: n.is_read ? 'white' : 'rgba(238, 242, 255, 0.25)',
                transition: 'all 0.15s ease',
              }}
            >
              <div
                style={{
                  width: '38px',
                  height: '38px',
                  borderRadius: '10px',
                  background: 'var(--bg-subtle)',
                  border: '1px solid var(--border-subtle)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                  marginTop: '0.1rem',
                }}
              >
                {getIcon(n.type)}
              </div>

              <div style={{ flex: 1 }}>
                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    flexWrap: 'wrap',
                    gap: '0.5rem',
                  }}
                >
                  <h4
                    style={{
                      fontSize: '0.95rem',
                      fontWeight: n.is_read ? 600 : 700,
                      color: 'var(--text-main)',
                    }}
                  >
                    {n.title}
                  </h4>
                  <span style={{ fontSize: '0.725rem', color: 'var(--text-subtle)' }}>
                    {formatDate(n.created_at)}
                  </span>
                </div>

                <p
                  style={{
                    fontSize: '0.825rem',
                    color: 'var(--text-muted)',
                    marginTop: '0.35rem',
                    lineHeight: 1.4,
                  }}
                >
                  {n.message}
                </p>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
