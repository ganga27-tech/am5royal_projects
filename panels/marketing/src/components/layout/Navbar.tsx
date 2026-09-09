import React, { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { useLocation } from 'react-router-dom';
import {
  Search,
  Bell,
  Sparkles,
  ChevronDown,
  LogOut,
  ShieldCheck,
  Activity,
  Layers,
  Sparkle,
} from 'lucide-react';

interface NavbarProps {
  onOpenQuickAction: () => void;
}

const PAGE_TITLES: Record<string, { title: string; category: string }> = {
  '/': { title: 'Marketing Command Center', category: 'Executive Dashboard' },
  '/seo': { title: 'SEO Command Suite (On/Off Page)', category: 'Search Engine Optimization' },
  '/backlinks': { title: 'Backlinks & Domain Outreach CRM', category: 'Link Building & PR' },
  '/blogs': { title: 'Blogs Publishing Studio', category: 'Content Marketing' },
  '/articles': { title: 'Articles & Media PR Tracker', category: 'Brand Awareness' },
  '/smm': { title: 'Social Media Marketing (SMM)', category: 'Organic & Paid Reach' },
  '/google-ads': { title: 'Google Ads Performance Command', category: 'Paid Advertising' },
  '/analytics': { title: 'Google Analytics 4 Telemetry', category: 'Web Traffic & Engagement' },
  '/leads': { title: 'Leads & Conversions Funnel', category: 'Inbound CRM & Attribution' },
  '/strategies': { title: 'Marketing Growth Strategies', category: 'Quarterly Roadmaps' },
  '/content-creations': { title: 'Content & Copywriting Studio', category: 'Creative Production' },
};

export const Navbar: React.FC<NavbarProps> = ({ onOpenQuickAction }) => {
  const { user, logout, switchRole } = useAuth();
  const [isProfileMenuOpen, setIsProfileMenuOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const location = useLocation();

  const currentRoute = PAGE_TITLES[location.pathname] || {
    title: 'Marketing Hub',
    category: 'AM5 ROYAL Portal',
  };

  return (
    <header className="sticky top-0 z-40 w-full border-b border-[#EAE2D2] bg-[#FFFFFF]/95 backdrop-blur-xl transition-all shadow-cream-sm">
      <div className="flex h-16 sm:h-20 items-center justify-between px-4 sm:px-8 gap-4">
        {/* Left: Breadcrumbs / Active Page Title (NO Duplicate Logo) */}
        <div className="flex items-center gap-3">
          <div>
            <div className="flex items-center gap-2">
              <span className="text-[11px] font-extrabold uppercase tracking-wider text-[#9B7314]">
                {currentRoute.category}
              </span>
              <span className="text-[#D5C29F] font-bold">•</span>
              <div className="inline-flex items-center gap-1.5 rounded-full border border-emerald-200 bg-emerald-50 px-2 py-0.5 text-[10px] font-bold text-emerald-800">
                <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
                <span>Live Telemetry</span>
              </div>
            </div>
            <h2 className="font-serif text-base sm:text-lg font-black text-[#1E1B18] tracking-tight truncate max-w-xs sm:max-w-md">
              {currentRoute.title}
            </h2>
          </div>
        </div>

        {/* Center: Global Omnichannel Search */}
        <div className="hidden md:flex flex-1 max-w-md mx-4">
          <div className="relative w-full">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-[#8E8276]" />
            <input
              type="text"
              placeholder="Search campaigns, backlinks, blogs, leads..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] pl-10 pr-4 py-2 text-xs sm:text-sm text-[#1E1B18] placeholder-[#8E8276] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none transition-all shadow-inner"
            />
          </div>
        </div>

        {/* Right: Quick Action, Alerts & Persona Profile */}
        <div className="flex items-center gap-2 sm:gap-4">
          {/* Quick Create Action Button */}
          <button
            onClick={onOpenQuickAction}
            className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] px-3.5 py-2 text-xs sm:text-sm font-bold text-[#1E1B18] shadow-cream-md hover:scale-[1.02] active:scale-[0.98] transition-all"
          >
            <Sparkles className="h-4 w-4" />
            <span className="hidden sm:inline">Quick Action</span>
          </button>

          {/* User Profile & Persona Switcher */}
          <div className="relative">
            <button
              onClick={() => setIsProfileMenuOpen(!isProfileMenuOpen)}
              className="flex items-center gap-2 rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] hover:bg-[#FFFFFF] p-1.5 sm:px-3 sm:py-2 text-left transition-all"
            >
              <img
                src={user?.avatarUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'}
                alt={user?.name || 'User'}
                className="h-7 w-7 sm:h-8 sm:w-8 rounded-lg object-cover border border-[#C59A27]/40 shadow-sm"
              />
              <div className="hidden lg:block">
                <p className="text-xs font-bold text-[#1E1B18] leading-tight">
                  {user?.name}
                </p>
                <p className="text-[10px] font-semibold text-[#9B7314] flex items-center gap-1">
                  <ShieldCheck className="w-3 h-3 text-emerald-600" />
                  {user?.roleTitle}
                </p>
              </div>
              <ChevronDown className="h-3.5 w-3.5 text-[#8E8276]" />
            </button>

            {/* Profile Dropdown */}
            {isProfileMenuOpen && (
              <div className="absolute right-0 mt-2 w-64 rounded-2xl border border-[#EAE2D2] bg-[#FFFFFF] p-2 shadow-cream-xl z-50 animate-fadeIn text-left">
                <div className="p-3 border-b border-[#EAE2D2]">
                  <p className="text-xs font-bold text-[#1E1B18]">{user?.name}</p>
                  <p className="text-[11px] text-[#8E8276] truncate">{user?.email}</p>
                  <span className="inline-block mt-2 rounded-full bg-[#C59A27]/10 px-2 py-0.5 text-[10px] font-bold text-[#9B7314] border border-[#C59A27]/25">
                    {user?.roleTitle}
                  </span>
                </div>

                {/* Role Switcher */}
                <div className="py-2 border-b border-[#EAE2D2]">
                  <p className="px-3 text-[10px] font-bold uppercase tracking-wider text-[#8E8276] mb-1">
                    Switch Active Persona
                  </p>
                  <button
                    onClick={() => { switchRole('marketing_head'); setIsProfileMenuOpen(false); }}
                    className="w-full text-left px-3 py-1.5 text-xs rounded-lg hover:bg-[#FAF6EF] text-[#4D443B] font-medium flex items-center justify-between"
                  >
                    <span>👑 Marketing Head</span>
                    {user?.role === 'marketing_head' && <span className="text-[#C59A27] text-xs font-bold">✓</span>}
                  </button>
                  <button
                    onClick={() => { switchRole('seo_lead'); setIsProfileMenuOpen(false); }}
                    className="w-full text-left px-3 py-1.5 text-xs rounded-lg hover:bg-[#FAF6EF] text-[#4D443B] font-medium flex items-center justify-between"
                  >
                    <span>🔍 SEO Lead</span>
                    {user?.role === 'seo_lead' && <span className="text-[#C59A27] text-xs font-bold">✓</span>}
                  </button>
                  <button
                    onClick={() => { switchRole('growth_hacker'); setIsProfileMenuOpen(false); }}
                    className="w-full text-left px-3 py-1.5 text-xs rounded-lg hover:bg-[#FAF6EF] text-[#4D443B] font-medium flex items-center justify-between"
                  >
                    <span>🚀 Growth Hacker</span>
                    {user?.role === 'growth_hacker' && <span className="text-[#C59A27] text-xs font-bold">✓</span>}
                  </button>
                  <button
                    onClick={() => { switchRole('content_strategist'); setIsProfileMenuOpen(false); }}
                    className="w-full text-left px-3 py-1.5 text-xs rounded-lg hover:bg-[#FAF6EF] text-[#4D443B] font-medium flex items-center justify-between"
                  >
                    <span>✍️ Content Strategist</span>
                    {user?.role === 'content_strategist' && <span className="text-[#C59A27] text-xs font-bold">✓</span>}
                  </button>
                </div>

                <div className="pt-2">
                  <button
                    onClick={logout}
                    className="w-full flex items-center gap-2 px-3 py-2 text-xs font-bold text-rose-600 rounded-xl hover:bg-rose-50 transition-colors"
                  >
                    <LogOut className="w-3.5 h-3.5" />
                    <span>Sign Out</span>
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </header>
  );
};
