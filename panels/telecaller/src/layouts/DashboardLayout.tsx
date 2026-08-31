// ============================================================================
// AM5 ROYAL • Dashboard Layout Shell
// Coordinates responsive layout, header, sidebar, and main page scroll
// ============================================================================

import React from 'react';
import { Header } from './Header';
import { Sidebar } from './Sidebar';

interface DashboardLayoutProps {
  children: React.ReactNode;
  activeTab: number;
  onTabChange: (tab: number) => void;
  websiteLeadsCount?: number;
  appLeadsCount?: number;
  freelancerLeadsCount?: number;
  unreadNotificationsCount?: number;
  onOpenContactAdmin?: () => void;
}

export const DashboardLayout: React.FC<DashboardLayoutProps> = ({
  children,
  activeTab,
  onTabChange,
  websiteLeadsCount,
  appLeadsCount,
  freelancerLeadsCount,
  unreadNotificationsCount,
  onOpenContactAdmin,
}) => {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
      <Header />
      <div style={{ display: 'flex', flex: 1, minHeight: 0 }}>
        <Sidebar
          activeTab={activeTab}
          onTabChange={onTabChange}
          websiteLeadsCount={websiteLeadsCount}
          appLeadsCount={appLeadsCount}
          freelancerLeadsCount={freelancerLeadsCount}
          unreadNotificationsCount={unreadNotificationsCount}
          onOpenContactAdmin={onOpenContactAdmin}
        />
        <main
          style={{
            flex: 1,
            padding: '2rem 2.5rem',
            overflowY: 'auto',
            background: 'var(--bg-app)',
            minWidth: 0,
          }}
        >
          <div style={{ maxWidth: '1400px', margin: '0 auto' }}>{children}</div>
        </main>
      </div>
    </div>
  );
};
