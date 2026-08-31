// ============================================================================
// AM5 ROYAL • Sidebar Navigation Component (Section 4 Specification)
// Features 8 Standard Menus: Dashboard, Website Leads, App Leads, Freelancer Leads,
// Notifications, My Performance, Settings, Contact Admin
// ============================================================================

import React from 'react';
import {
  LayoutDashboard,
  Globe,
  Smartphone,
  Briefcase,
  Bell,
  TrendingUp,
  Settings,
  HelpCircle,
} from 'lucide-react';

export interface SidebarProps {
  activeTab: number;
  onTabChange: (tab: number) => void;
  websiteLeadsCount?: number;
  appLeadsCount?: number;
  freelancerLeadsCount?: number;
  unreadNotificationsCount?: number;
  onOpenContactAdmin?: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({
  activeTab,
  onTabChange,
  websiteLeadsCount,
  appLeadsCount,
  freelancerLeadsCount,
  unreadNotificationsCount,
  onOpenContactAdmin,
}) => {
  // Exact 8 items per Section 4 Left Navigation Specification
  const navItems = [
    {
      id: 0,
      title: 'Dashboard',
      subtitle: 'Summary & Daily Desk Overview',
      icon: LayoutDashboard,
    },
    {
      id: 1,
      title: 'Company Website Leads',
      subtitle: 'Manage Website Enquiries',
      icon: Globe,
      badge: websiteLeadsCount,
    },
    {
      id: 2,
      title: 'Company App Leads',
      subtitle: 'Manage Mobile App Signups',
      icon: Smartphone,
      badge: appLeadsCount,
    },
    {
      id: 3,
      title: 'Freelancer Leads',
      subtitle: 'Manage Freelancer Signups',
      icon: Briefcase,
      badge: freelancerLeadsCount,
    },
    {
      id: 4,
      title: 'Notification',
      subtitle: 'Lead Alerts & Admin Messages',
      icon: Bell,
      badge: unreadNotificationsCount,
      badgeDanger: true,
    },
    {
      id: 5,
      title: 'My Performance',
      subtitle: 'Lead Metrics & Conversion Rate',
      icon: TrendingUp,
    },
    {
      id: 6,
      title: 'Settings',
      subtitle: 'Account & Banking Details',
      icon: Settings,
    },
    {
      id: 7,
      title: 'Contact Admin',
      subtitle: 'Support & Escalation Desk',
      icon: HelpCircle,
      isAction: true,
    },
  ];

  return (
    <aside
      style={{
        width: '280px',
        flexShrink: 0,
        background: 'var(--bg-surface)',
        borderRight: '1px solid var(--border-subtle)',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'space-between',
        padding: '1.25rem 1rem',
        minHeight: 'calc(100vh - 65px)',
      }}
    >
      {/* Top: Nav buttons */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '0.35rem' }}>
        <div
          style={{
            fontFamily: 'var(--font-heading)',
            fontSize: '0.7rem',
            fontWeight: 700,
            textTransform: 'uppercase',
            letterSpacing: '0.08em',
            color: 'var(--text-subtle)',
            padding: '0 0.75rem 0.5rem 0.75rem',
          }}
        >
          Operation Consoles
        </div>

        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;

          return (
            <button
              key={item.id}
              onClick={() => {
                if (item.id === 7 && onOpenContactAdmin) {
                  onOpenContactAdmin();
                } else {
                  onTabChange(item.id);
                }
              }}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '0.8rem',
                padding: '0.7rem 0.9rem',
                borderRadius: 'var(--radius-md)',
                border: '1px solid',
                borderColor: isActive ? 'rgba(79, 70, 229, 0.2)' : 'transparent',
                background: isActive
                  ? 'linear-gradient(135deg, rgba(79, 70, 229, 0.1) 0%, rgba(99, 102, 241, 0.05) 100%)'
                  : 'transparent',
                color: isActive ? 'var(--primary)' : 'var(--text-muted)',
                cursor: 'pointer',
                textAlign: 'left',
                transition: 'all 0.15s ease',
                width: '100%',
                position: 'relative',
              }}
              onMouseEnter={(e) => {
                if (!isActive) {
                  e.currentTarget.style.background = 'var(--bg-subtle)';
                  e.currentTarget.style.color = 'var(--text-main)';
                }
              }}
              onMouseLeave={(e) => {
                if (!isActive) {
                  e.currentTarget.style.background = 'transparent';
                  e.currentTarget.style.color = 'var(--text-muted)';
                }
              }}
            >
              {/* Left active luminous indicator */}
              {isActive && (
                <div
                  style={{
                    position: 'absolute',
                    left: 0,
                    top: '20%',
                    bottom: '20%',
                    width: '3.5px',
                    borderRadius: '0 4px 4px 0',
                    background: 'var(--primary)',
                    boxShadow: '0 0 8px var(--primary)',
                  }}
                />
              )}

              {/* Icon Container */}
              <div
                style={{
                  width: '34px',
                  height: '34px',
                  borderRadius: '10px',
                  background: isActive ? 'var(--primary)' : 'var(--bg-subtle)',
                  color: isActive ? 'white' : 'var(--text-muted)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                  transition: 'all 0.2s ease',
                  boxShadow: isActive ? '0 2px 8px var(--primary-glow)' : 'none',
                }}
              >
                <Icon size={17} />
              </div>

              {/* Title & Subtitle */}
              <div style={{ flex: 1, minWidth: 0 }}>
                <div
                  style={{
                    fontFamily: 'var(--font-heading)',
                    fontSize: '0.825rem',
                    fontWeight: isActive ? 700 : 600,
                    color: isActive ? 'var(--primary-dark)' : 'var(--text-main)',
                    lineHeight: 1.2,
                  }}
                >
                  {item.title}
                </div>
                <div
                  style={{
                    fontSize: '0.675rem',
                    color: isActive ? 'var(--primary)' : 'var(--text-subtle)',
                    marginTop: '0.15rem',
                    whiteSpace: 'nowrap',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                  }}
                >
                  {item.subtitle}
                </div>
              </div>

              {/* Counter Badge */}
              {item.badge !== undefined && item.badge > 0 && (
                <span
                  style={{
                    padding: '0.15rem 0.45rem',
                    borderRadius: '9999px',
                    fontSize: '0.675rem',
                    fontWeight: 700,
                    background: item.badgeDanger ? 'var(--danger-light)' : (isActive ? 'var(--primary)' : 'var(--bg-subtle)'),
                    color: item.badgeDanger ? 'var(--danger)' : (isActive ? 'white' : 'var(--text-main)'),
                    border: item.badgeDanger ? '1px solid var(--danger-border)' : 'none',
                  }}
                >
                  {item.badge}
                </span>
              )}
            </button>
          );
        })}
      </div>

      {/* Bottom Guideline Card */}
      <div
        style={{
          background: 'linear-gradient(135deg, #eef2ff 0%, #f0fdfa 100%)',
          borderRadius: 'var(--radius-md)',
          border: '1px solid rgba(79, 70, 229, 0.15)',
          padding: '0.9rem',
          marginTop: '1rem',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.35rem' }}>
          <TrendingUp size={15} color="var(--primary)" />
          <span
            style={{
              fontFamily: 'var(--font-heading)',
              fontWeight: 700,
              fontSize: '0.775rem',
              color: 'var(--primary-dark)',
            }}
          >
            Verification Standard
          </span>
        </div>
        <p style={{ fontSize: '0.725rem', color: 'var(--text-muted)', lineHeight: 1.45 }}>
          Verify KYC documents and contact numbers before activating partner accounts.
        </p>
      </div>
    </aside>
  );
};
