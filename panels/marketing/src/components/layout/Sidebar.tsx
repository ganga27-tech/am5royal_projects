import React from 'react';
import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard,
  Search,
  Link2,
  BookOpenText,
  Newspaper,
  Share2,
  BarChart3,
  Activity,
  UsersRound,
  Target,
  Sparkles,
  Crown,
  ChevronRight,
} from 'lucide-react';

interface SidebarProps {
  isMobileOpen: boolean;
  onCloseMobile: () => void;
}

const navItems = [
  { name: 'Command Center', path: '/', icon: LayoutDashboard, badge: 'Live' },
  { name: 'SEO (On/Off Page)', path: '/seo', icon: Search, badge: 'Audit' },
  { name: 'Backlinks & Outreach', path: '/backlinks', icon: Link2, badge: '34' },
  { name: 'Blogs Publishing', path: '/blogs', icon: BookOpenText, badge: '18' },
  { name: 'Articles & PR Media', path: '/articles', icon: Newspaper, badge: 'Vogue' },
  { name: 'SMM & Paid Ads', path: '/smm', icon: Share2, badge: 'Viral' },
  { name: 'Google Ads Command', path: '/google-ads', icon: BarChart3, badge: '4.8x' },
  { name: 'GA4 Telemetry', path: '/analytics', icon: Activity, badge: 'Active' },
  { name: 'Leads & Conversions', path: '/leads', icon: UsersRound, badge: 'Kanban' },
  { name: 'Growth Strategies', path: '/strategies', icon: Target, badge: 'Q3' },
  { name: 'Content & Copy Studio', path: '/content-creations', icon: Sparkles, badge: 'Studio' },
];

export const Sidebar: React.FC<SidebarProps> = ({ isMobileOpen, onCloseMobile }) => {
  return (
    <>
      {/* Mobile Backdrop */}
      {isMobileOpen && (
        <div
          className="fixed inset-0 z-40 bg-[#1E1B18]/40 backdrop-blur-sm lg:hidden transition-opacity"
          onClick={onCloseMobile}
        />
      )}

      {/* Sidebar Container */}
      <aside
        className={`fixed top-0 left-0 z-40 h-screen w-72 border-r border-[#EAE2D2] bg-[#FFFFFF] transition-transform duration-300 ease-in-out lg:translate-x-0 ${
          isMobileOpen ? 'translate-x-0 shadow-cream-xl' : '-translate-x-full'
        } flex flex-col justify-between`}
      >
        {/* Top Branding Section */}
        <div>
          <div className="flex h-20 items-center justify-between px-6 border-b border-[#EAE2D2] bg-gradient-to-r from-[#FAF6EF] via-[#FFFFFF] to-[#FAF6EF]">
            <div className="flex items-center gap-3">
              <div className="p-1 rounded-2xl bg-[#FFFFFF] border border-[#E5D8C1] shadow-cream-sm">
                <img
                  src="/am5royal_logo.png"
                  alt="AM5 ROYAL"
                  className="h-10 w-auto object-contain"
                />
              </div>
              <div>
                <div className="flex items-center gap-1.5">
                  <h2 className="font-serif text-sm font-black tracking-wider text-[#1E1B18] uppercase">
                    AM5 ROYAL
                  </h2>
                </div>
                <p className="text-[10px] font-bold text-[#9B7314] tracking-tight uppercase">
                  Growth & Marketing
                </p>
              </div>
            </div>
          </div>

          {/* Navigation Links */}
          <div className="p-4 space-y-1.5 overflow-y-auto max-h-[calc(100vh-170px)]">
            <p className="px-3 pt-2 pb-1 text-[10px] font-extrabold uppercase tracking-wider text-[#8E8276]">
              Marketing Suite (10 Domains)
            </p>

            {navItems.map((item) => {
              const Icon = item.icon;
              return (
                <NavLink
                  key={item.path}
                  to={item.path}
                  onClick={onCloseMobile}
                  className={({ isActive }) =>
                    `group relative flex items-center justify-between rounded-xl px-3.5 py-2.5 text-xs font-semibold transition-all ${
                      isActive
                        ? 'bg-gradient-to-r from-[#FAF6EF] to-[#F5EFEB] text-[#1E1B18] border border-[#C59A27]/40 shadow-cream-sm font-bold'
                        : 'text-[#685D51] hover:bg-[#FAF7F2] hover:text-[#1E1B18] border border-transparent'
                    }`
                  }
                >
                  {({ isActive }) => (
                    <>
                      <div className="flex items-center gap-3">
                        <div
                          className={`rounded-lg p-1.5 transition-colors ${
                            isActive
                              ? 'bg-[#C59A27] text-[#FFFFFF] shadow-sm'
                              : 'bg-[#FAF6EF] text-[#8E8276] group-hover:bg-[#FFFFFF] group-hover:text-[#C59A27] border border-[#EAE2D2]'
                          }`}
                        >
                          <Icon className="h-4 w-4" />
                        </div>
                        <span className="truncate">{item.name}</span>
                      </div>

                      <div className="flex items-center gap-1.5">
                        {item.badge && (
                          <span
                            className={`rounded-md px-1.5 py-0.5 text-[10px] font-extrabold uppercase transition-all ${
                              isActive
                                ? 'bg-[#C59A27]/15 text-[#8A6412] border border-[#C59A27]/30'
                                : 'bg-[#FAF6EF] text-[#8E8276] border border-[#EAE2D2]'
                            }`}
                          >
                            {item.badge}
                          </span>
                        )}
                        <ChevronRight
                          className={`h-3.5 w-3.5 text-[#BDB4AB] transition-transform ${
                            isActive ? 'translate-x-0.5 text-[#C59A27]' : 'group-hover:translate-x-0.5'
                          }`}
                        />
                      </div>
                    </>
                  )}
                </NavLink>
              );
            })}
          </div>
        </div>

        {/* Bottom Banner Badge */}
        <div className="p-4 border-t border-[#EAE2D2] bg-[#FAF7F2]">
          <div className="flex items-center gap-3 rounded-2xl bg-gradient-to-br from-[#FFFFFF] to-[#FAF6EF] p-3 border border-[#E5D8C1] shadow-cream-sm">
            <div className="rounded-xl bg-[#C59A27]/15 p-2 text-[#9B7314] border border-[#C59A27]/25">
              <Crown className="h-5 w-5 text-[#C59A27]" />
            </div>
            <div>
              <p className="text-xs font-bold text-[#1E1B18]">AM5 Royal Engine</p>
              <p className="text-[10px] text-[#8E8276]">Multi-Category Leader</p>
            </div>
          </div>
        </div>
      </aside>
    </>
  );
};
