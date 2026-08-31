// ============================================================================
// AM5 ROYAL • Sidebar Navigation Component
// Desktop sidebar with luminous indicators, icon badges, and help guide
// ============================================================================

import React from 'react';
import {
  LayoutDashboard,
  MessageSquareShare,
  Globe,
  Smartphone,
  Settings,
  HelpCircle,
  TrendingUp,
} from 'lucide-react';

export interface SidebarProps {
  activeTab: number;
  onTabChange: (tab: number) => void;
  websiteLeadsCount?: number;
  appLeadsCount?: number;
}

export const Sidebar: React.FC<SidebarProps> = ({
  activeTab,
  onTabChange,
  websiteLeadsCount,
  appLeadsCount,
}) => {
  const navItems = [
    {
      id: 0,
      title: 'Performance Overview',
      subtitle: 'Stats, Payouts & Onboarded',
      icon: LayoutDashboard,
    },
    {
      id: 1,
      title: 'WhatsApp & SMS Tool',
      subtitle: 'Quick Invites & Lead Pipeline',
      icon: MessageSquareShare,
    },
    {
      id: 2,
      title: 'Company Website Leads',
      subtitle: 'Web Signups & Verification',
      icon: Globe,
      badge: websiteLeadsCount,
    },
    {
      id: 3,
      title: 'Company App Leads',
      subtitle: 'Mobile Signups & Verification',
      icon: Smartphone,
      badge: appLeadsCount,
    },
    {
      id: 4,
      title: 'Settings & Bank Profile',
      subtitle: 'Account & Banking Details',
      icon: Settings,
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
        padding: '1.5rem 1rem',
        minHeight: 'calc(100vh - 65px)',
      }}
    >
      {/* Top: Nav buttons */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '0.4rem' }}>
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
              onClick={() => onTabChange(item.id)}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '0.85rem',
                padding: '0.8rem 1rem',
                borderRadius: 'var(--radius-md)',
                border: '1px solid',
                borderColor: isActive ? 'rgba(79, 70, 229, 0.2)' : 'transparent',
                background: isActive
                  ? 'linear-gradient(135deg, rgba(79, 70, 229, 0.1) 0%, rgba(99, 102, 241, 0.05) 100%)'
                  : 'transparent',
                color: isActive ? 'var(--primary)' : 'var(--text-muted)',
                cursor: 'pointer',
                textAlign: 'left',
                transition: 'all 0.2s ease',
                width: '100%',
                position: 'relative',
              }}
              onMouseEnter={(e) => {
                if (!isActive) {
                  e.currentTarget.style.backgroundColor = 'var(--bg-subtle)';
                  e.currentTarget.style.color = 'var(--text-main)';
                }
              }}
              onMouseLeave={(e) => {
                if (!isActive) {
                  e.currentTarget.style.backgroundColor = 'transparent';
                  e.currentTarget.style.color = 'var(--text-muted)';
                }
              }}
            >
              {/* Active left indicator accent */}
              {isActive && (
                <div
                  style={{
                    position: 'absolute',
                    left: '0px',
                    top: '20%',
                    bottom: '20%',
                    width: '3.5px',
                    borderRadius: '0 4px 4px 0',
                    background: 'var(--primary)',
                  }}
                />
              )}

              <div
                style={{
                  width: '36px',
                  height: '36px',
                  borderRadius: '10px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  background: isActive ? 'var(--primary)' : 'var(--bg-subtle)',
                  color: isActive ? 'white' : 'var(--text-muted)',
                  boxShadow: isActive ? '0 4px 10px var(--primary-glow)' : 'none',
                  flexShrink: 0,
                  transition: 'all 0.2s ease',
                }}
              >
                <Icon size={18} />
              </div>

              <div style={{ flex: 1, minWidth: 0 }}>
                <div
                  style={{
                    fontFamily: 'var(--font-heading)',
                    fontSize: '0.875rem',
                    fontWeight: isActive ? 700 : 600,
                    color: isActive ? 'var(--primary-dark)' : 'var(--text-main)',
                    lineHeight: 1.2,
                  }}
                >
                  {item.title}
                </div>
                <div
                  style={{
                    fontSize: '0.725rem',
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

              {item.badge !== undefined && item.badge > 0 && (
                <span
                  style={{
                    padding: '0.15rem 0.5rem',
                    borderRadius: '9999px',
                    fontSize: '0.7rem',
                    fontWeight: 700,
                    background: isActive ? 'var(--primary)' : 'var(--bg-subtle)',
                    color: isActive ? 'white' : 'var(--text-main)',
                  }}
                >
                  {item.badge}
                </span>
              )}
            </button>
          );
        })}
      </div>

      {/* Bottom: Pro Operational Guideline Card */}
      <div
        style={{
          background: 'linear-gradient(135deg, #eef2ff 0%, #f0fdfa 100%)',
          borderRadius: 'var(--radius-md)',
          border: '1px solid rgba(79, 70, 229, 0.15)',
          padding: '1rem',
          marginTop: '1.5rem',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.4rem' }}>
          <TrendingUp size={16} color="var(--primary)" />
          <span
            style={{
              fontFamily: 'var(--font-heading)',
              fontWeight: 700,
              fontSize: '0.8rem',
              color: 'var(--primary-dark)',
            }}
          >
            Telecaller Standard
          </span>
        </div>
        <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)', lineHeight: 1.45 }}>
          Lock in referral points by registering vendor profiles directly while engaged on the call.
        </p>
      </div>
    </aside>
  );
};
