// ============================================================================
// AM5 ROYAL • Telecaller Master Dashboard Shell
// Coordinates all 8 consoles per Verification Team Members specification
// ============================================================================

import React, { useState, useEffect } from 'react';
import { DashboardLayout } from '../layouts/DashboardLayout';
import { PerformanceTab } from './PerformanceTab';
import { CompanyLeadsTab } from './CompanyLeadsTab';
import { NotificationsTab } from './NotificationsTab';
import { MyPerformanceTab } from './MyPerformanceTab';
import { SettingsTab } from './SettingsTab';
import { ContactAdminModal } from '../components/admin/ContactAdminModal';
import { telecallerApi } from '../api/telecallerApi';

export const DashboardPage: React.FC = () => {
  const [activeTab, setActiveTab] = useState<number>(0);
  const [websiteLeadsCount, setWebsiteLeadsCount] = useState<number | undefined>();
  const [appLeadsCount, setAppLeadsCount] = useState<number | undefined>();
  const [freelancerLeadsCount, setFreelancerLeadsCount] = useState<number | undefined>();
  const [unreadNotificationsCount, setUnreadNotificationsCount] = useState<number | undefined>(2);
  const [isContactAdminOpen, setIsContactAdminOpen] = useState<boolean>(false);

  useEffect(() => {
    fetchInitialCounts();
  }, []);

  const fetchInitialCounts = async () => {
    try {
      const [web, app, free] = await Promise.all([
        telecallerApi.getOnboardedVendors({ leadSource: 'company_website', limit: 1 }),
        telecallerApi.getOnboardedVendors({ leadSource: 'company_mobile', limit: 1 }),
        telecallerApi.getOnboardedVendors({ leadSource: 'freelancer', limit: 1 }),
      ]);
      setWebsiteLeadsCount(web.total);
      setAppLeadsCount(app.total);
      setFreelancerLeadsCount(free.total);
    } catch {
      // Keep state resilient
    }
  };

  const renderActiveTab = () => {
    switch (activeTab) {
      case 0:
        // Dashboard Overview (Overall Team Member Summary)
        return <PerformanceTab />;
      case 1:
        // Company Website Leads
        return (
          <CompanyLeadsTab
            sourceType="website"
            onCountUpdate={(cnt) => setWebsiteLeadsCount(cnt)}
          />
        );
      case 2:
        // Company Application Leads
        return (
          <CompanyLeadsTab
            sourceType="application"
            onCountUpdate={(cnt) => setAppLeadsCount(cnt)}
          />
        );
      case 3:
        // Freelancer Leads
        return (
          <CompanyLeadsTab
            sourceType="freelancer"
            onCountUpdate={(cnt) => setFreelancerLeadsCount(cnt)}
          />
        );
      case 4:
        // Notification
        return <NotificationsTab />;
      case 5:
        // My Performance (Section 12 specification)
        return <MyPerformanceTab />;
      case 6:
        // Settings
        return <SettingsTab />;
      default:
        return <PerformanceTab />;
    }
  };

  return (
    <>
      <DashboardLayout
        activeTab={activeTab}
        onTabChange={(tab) => {
          if (tab === 7) {
            setIsContactAdminOpen(true);
          } else {
            setActiveTab(tab);
          }
        }}
        websiteLeadsCount={websiteLeadsCount}
        appLeadsCount={appLeadsCount}
        freelancerLeadsCount={freelancerLeadsCount}
        unreadNotificationsCount={unreadNotificationsCount}
        onOpenContactAdmin={() => setIsContactAdminOpen(true)}
      >
        {renderActiveTab()}
      </DashboardLayout>

      {/* Section 4: Contact Admin Modal */}
      {isContactAdminOpen && (
        <ContactAdminModal
          isOpen={isContactAdminOpen}
          onClose={() => setIsContactAdminOpen(false)}
        />
      )}
    </>
  );
};
