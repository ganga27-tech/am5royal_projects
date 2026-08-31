// ============================================================================
// AM5 ROYAL • Telecaller Master Dashboard Shell
// Coordinates all 5 tabs inside the DashboardLayout
// Mirrors Flutter: telecaller_dashboard_page.dart
// ============================================================================

import React, { useState } from 'react';
import { DashboardLayout } from '../layouts/DashboardLayout';
import { PerformanceTab } from './PerformanceTab';
import { QuickInviteTab } from './QuickInviteTab';
import { CompanyLeadsTab } from './CompanyLeadsTab';
import { SettingsTab } from './SettingsTab';

export const DashboardPage: React.FC = () => {
  const [activeTab, setActiveTab] = useState<number>(0);
  const [websiteLeadsCount, setWebsiteLeadsCount] = useState<number | undefined>();
  const [appLeadsCount, setAppLeadsCount] = useState<number | undefined>();

  const renderActiveTab = () => {
    switch (activeTab) {
      case 0:
        return <PerformanceTab />;
      case 1:
        return <QuickInviteTab />;
      case 2:
        return (
          <CompanyLeadsTab
            isWebsite={true}
            onCountUpdate={(cnt) => setWebsiteLeadsCount(cnt)}
          />
        );
      case 3:
        return (
          <CompanyLeadsTab
            isWebsite={false}
            onCountUpdate={(cnt) => setAppLeadsCount(cnt)}
          />
        );
      case 4:
        return <SettingsTab />;
      default:
        return <PerformanceTab />;
    }
  };

  return (
    <DashboardLayout
      activeTab={activeTab}
      onTabChange={(tab) => setActiveTab(tab)}
      websiteLeadsCount={websiteLeadsCount}
      appLeadsCount={appLeadsCount}
    >
      {renderActiveTab()}
    </DashboardLayout>
  );
};
