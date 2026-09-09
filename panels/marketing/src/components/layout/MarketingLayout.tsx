import React, { useState } from 'react';
import { Outlet, useNavigate } from 'react-router-dom';
import { Navbar } from './Navbar';
import { Sidebar } from './Sidebar';
import { Modal } from '../common/Modal';
import {
  Sparkles,
  Plus,
  Search,
  Link2,
  BookOpenText,
  Share2,
  BarChart3,
  UsersRound,
  Target,
  ArrowRight,
  Menu,
} from 'lucide-react';

export const MarketingLayout: React.FC = () => {
  const [isMobileSidebarOpen, setIsMobileSidebarOpen] = useState(false);
  const [isQuickActionModalOpen, setIsQuickActionModalOpen] = useState(false);
  const navigate = useNavigate();

  const quickActions = [
    { title: 'New SEO Audit', desc: 'Audit URL & keyword density', icon: Search, path: '/seo', color: 'text-amber-600 bg-amber-50' },
    { title: 'Record Inbound Lead', desc: 'Add new brand/partner lead', icon: UsersRound, path: '/leads', color: 'text-emerald-600 bg-emerald-50' },
    { title: 'Publish Blog Post', desc: 'Create editorial article', icon: BookOpenText, path: '/blogs', color: 'text-blue-600 bg-blue-50' },
    { title: 'Schedule SMM Post', desc: 'Instagram, FB & LinkedIn post', icon: Share2, path: '/smm', color: 'text-purple-600 bg-purple-50' },
    { title: 'New Google Ad Set', desc: 'Setup PMax / Search campaign', icon: BarChart3, path: '/google-ads', color: 'text-rose-600 bg-rose-50' },
    { title: 'Create Growth Strategy', desc: 'Quarterly roadmap & KPIs', icon: Target, path: '/strategies', color: 'text-gold-700 bg-gold-50' },
  ];

  return (
    <div className="min-h-screen bg-[#FAF7F2] text-[#1E1B18] flex flex-col">
      {/* Sidebar Navigation */}
      <Sidebar
        isMobileOpen={isMobileSidebarOpen}
        onCloseMobile={() => setIsMobileSidebarOpen(false)}
      />

      {/* Main Content Area */}
      <div className="lg:pl-72 flex flex-col flex-1">
        {/* Top Navbar */}
        <Navbar onOpenQuickAction={() => setIsQuickActionModalOpen(true)} />

        {/* Mobile Header Trigger */}
        <div className="lg:hidden flex items-center justify-between px-4 py-3 border-b border-[#EAE2D2] bg-[#FFFFFF]">
          <button
            onClick={() => setIsMobileSidebarOpen(true)}
            className="flex items-center gap-2 rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] p-2 text-[#4D443B]"
          >
            <Menu className="h-5 w-5" />
            <span className="text-xs font-bold">Marketing Menu</span>
          </button>
          <img src="/am5royal_logo.png" alt="AM5" className="h-8 w-auto object-contain" />
        </div>

        {/* Page Outlet */}
        <main className="flex-1 p-4 sm:p-8 max-w-7xl w-full mx-auto animate-fadeIn">
          <Outlet />
        </main>

        {/* Footer */}
        <footer className="border-t border-[#EAE2D2] bg-[#FFFFFF] px-6 py-4 text-center text-xs text-[#8E8276]">
          <div className="flex flex-col sm:flex-row items-center justify-between gap-2 max-w-7xl mx-auto">
            <div className="flex items-center gap-2">
              <img src="/am5royal_logo.png" alt="AM5 ROYAL" className="h-6 w-auto object-contain" />
              <span className="font-serif font-bold text-[#1E1B18]">AM5 ROYAL LUXURY MARKETPLACE</span>
            </div>
            <p>© 2026 MSKGRC AM5 ROYAL. Omnichannel Marketing Engine v2.4 (Production Grade).</p>
          </div>
        </footer>
      </div>

      {/* Quick Action Launcher Modal */}
      <Modal
        isOpen={isQuickActionModalOpen}
        onClose={() => setIsQuickActionModalOpen(false)}
        title="Marketing Command Quick Actions"
        subtitle="Instantly jump into creating campaigns, audits, or intake records"
        maxWidth="max-w-2xl"
      >
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5 pt-2">
          {quickActions.map((action, i) => {
            const Icon = action.icon;
            return (
              <button
                key={i}
                onClick={() => {
                  setIsQuickActionModalOpen(false);
                  navigate(action.path);
                }}
                className="group flex items-start gap-3.5 rounded-2xl border border-[#EAE2D2] bg-[#FAF7F2] p-4 text-left transition-all hover:bg-[#FFFFFF] hover:border-[#C59A27] hover:shadow-cream-md"
              >
                <div className={`rounded-xl p-3 ${action.color} border border-[#EAE2D2] group-hover:scale-110 transition-transform`}>
                  <Icon className="h-5 w-5" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-bold text-[#1E1B18] group-hover:text-[#9B7314] transition-colors flex items-center justify-between">
                    <span>{action.title}</span>
                    <ArrowRight className="h-3.5 w-3.5 text-[#BDB4AB] group-hover:text-[#9B7314] group-hover:translate-x-1 transition-all" />
                  </p>
                  <p className="text-xs text-[#8E8276] mt-0.5">{action.desc}</p>
                </div>
              </button>
            );
          })}
        </div>
      </Modal>
    </div>
  );
};
