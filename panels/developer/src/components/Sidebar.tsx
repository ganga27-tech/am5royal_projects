import React from 'react';
import { NavLink } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';
import {
  LayoutDashboard,
  Code2,
  Bug,
  CheckSquare,
  FolderGit2,
  Boxes,
  Network,
  Users,
  Rocket,
  BarChart3,
  Database,
  ShieldCheck,
  ScrollText,
  Settings,
  ChevronLeft,
  ChevronRight,
  ShieldAlert,
  Kanban,
} from 'lucide-react';

interface SidebarProps {
  isCollapsed: boolean;
  setIsCollapsed: (v: boolean) => void;
}

export const Sidebar: React.FC<SidebarProps> = ({ isCollapsed, setIsCollapsed }) => {
  const { user } = useAuth();
  const userRole = user?.role || 'developer';

  const navItemClass = ({ isActive }: { isActive: boolean }) =>
    `flex items-center gap-3 px-3 py-2 rounded-md text-xs font-medium transition ${
      isActive
        ? 'bg-[#1B2638] text-[#22D3EE] font-semibold border-l-2 border-[#22D3EE]'
        : 'text-[#94A3B8] hover:text-[#F1F5F9] hover:bg-[#151E2E]'
    } ${isCollapsed ? 'justify-center px-2' : ''}`;

  return (
    <aside
      className={`fixed left-0 top-0 bottom-0 z-30 bg-[#0E1420] border-r border-[#263247] flex flex-col transition-all duration-200 ${
        isCollapsed ? 'w-16' : 'w-60'
      }`}
    >
      {/* Brand Header */}
      <div className="h-16 flex items-center justify-between px-4 border-b border-[#263247] shrink-0">
        {!isCollapsed && (
          <div className="flex items-center gap-2.5 overflow-hidden">
            <div className="w-8 h-8 rounded-lg bg-[#151E2E] border border-[#22D3EE]/40 flex items-center justify-center text-[#22D3EE] font-bold text-sm">
              <Code2 className="w-4 h-4" />
            </div>
            <div className="truncate">
              <div className="text-xs font-bold tracking-wide text-[#F1F5F9] uppercase">AM5 DEV OPS</div>
              <div className="text-[10px] font-mono text-[#22D3EE]">CONTROL CENTER</div>
            </div>
          </div>
        )}

        {isCollapsed && (
          <div className="w-8 h-8 rounded-lg bg-[#151E2E] border border-[#22D3EE]/40 flex items-center justify-center text-[#22D3EE] font-bold text-sm mx-auto">
            <Code2 className="w-4 h-4" />
          </div>
        )}

        <button
          onClick={() => setIsCollapsed(!isCollapsed)}
          className={`p-1.5 rounded-md text-[#94A3B8] hover:text-[#F1F5F9] hover:bg-[#151E2E] transition ${
            isCollapsed ? 'hidden' : 'block'
          }`}
          title={isCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar'}
        >
          <ChevronLeft className="w-4 h-4" />
        </button>
      </div>

      {/* Nav List */}
      <div className="flex-1 overflow-y-auto py-4 px-3 space-y-6">
        {/* Dashboards */}
        <div>
          {!isCollapsed && (
            <div className="px-3 mb-2 text-[10px] font-mono uppercase tracking-wider text-[#475569]">
              Dashboards
            </div>
          )}
          <div className="space-y-1">
            <NavLink to="/board" className={navItemClass} title="Sprint Board">
              <Kanban className="w-4 h-4 shrink-0 text-[#22D3EE]" />
              {!isCollapsed && <span>Sprint Board</span>}
            </NavLink>

            <NavLink to="/" className={navItemClass} end title="Global Control Dashboard">
              <LayoutDashboard className="w-4 h-4 shrink-0" />
              {!isCollapsed && <span>Global Overview</span>}
            </NavLink>

            {(userRole === 'developer' || userRole === 'admin' || userRole === 'super_admin') && (
              <NavLink to="/developer-dashboard" className={navItemClass} title="Developer Dashboard">
                <Code2 className="w-4 h-4 shrink-0 text-[#22D3EE]" />
                {!isCollapsed && <span>Developer Hub</span>}
              </NavLink>
            )}

            {(userRole === 'qa' || userRole === 'admin' || userRole === 'super_admin') && (
              <NavLink to="/qa-dashboard" className={navItemClass} title="QA Defect Testing Dashboard">
                <ShieldAlert className="w-4 h-4 shrink-0 text-[#8B5CF6]" />
                {!isCollapsed && <span>QA Command</span>}
              </NavLink>
            )}
          </div>
        </div>

        {/* Work Tracking */}
        <div>
          {!isCollapsed && (
            <div className="px-3 mb-2 text-[10px] font-mono uppercase tracking-wider text-[#475569]">
              Defects & Tasks
            </div>
          )}
          <div className="space-y-1">
            <NavLink to="/bugs" className={navItemClass} title="Bugs & Defects Lifecycle">
              <Bug className="w-4 h-4 shrink-0 text-[#FB4B5F]" />
              {!isCollapsed && <span>Bugs & Defects</span>}
            </NavLink>
            <NavLink to="/tasks" className={navItemClass} title="Engineering Tasks">
              <CheckSquare className="w-4 h-4 shrink-0 text-[#FBBF24]" />
              {!isCollapsed && <span>Sprint Tasks</span>}
            </NavLink>
          </div>
        </div>

        {/* System Architecture */}
        <div>
          {!isCollapsed && (
            <div className="px-3 mb-2 text-[10px] font-mono uppercase tracking-wider text-[#475569]">
              Architecture
            </div>
          )}
          <div className="space-y-1">
            <NavLink to="/projects" className={navItemClass} title="Platform Projects">
              <FolderGit2 className="w-4 h-4 shrink-0 text-[#38BDF8]" />
              {!isCollapsed && <span>Projects</span>}
            </NavLink>
            <NavLink to="/modules" className={navItemClass} title="System Modules">
              <Boxes className="w-4 h-4 shrink-0 text-[#8B5CF6]" />
              {!isCollapsed && <span>Modules</span>}
            </NavLink>
            <NavLink to="/apis" className={navItemClass} title="API Catalog & Health">
              <Network className="w-4 h-4 shrink-0 text-[#34D399]" />
              {!isCollapsed && <span>API Catalog</span>}
            </NavLink>
          </div>
        </div>

        {/* Engineering Operations */}
        <div>
          {!isCollapsed && (
            <div className="px-3 mb-2 text-[10px] font-mono uppercase tracking-wider text-[#475569]">
              Operations
            </div>
          )}
          <div className="space-y-1">
            <NavLink to="/team" className={navItemClass} title="Engineering & QA Team">
              <Users className="w-4 h-4 shrink-0" />
              {!isCollapsed && <span>Team Roster</span>}
            </NavLink>
            <NavLink to="/deployments" className={navItemClass} title="Deployments History">
              <Rocket className="w-4 h-4 shrink-0" />
              {!isCollapsed && <span>Deployments</span>}
            </NavLink>
            <NavLink to="/analytics" className={navItemClass} title="Technical Analytics">
              <BarChart3 className="w-4 h-4 shrink-0" />
              {!isCollapsed && <span>Analytics</span>}
            </NavLink>
            <NavLink to="/database" className={navItemClass} title="Database Diagnostics">
              <Database className="w-4 h-4 shrink-0" />
              {!isCollapsed && <span>Database Health</span>}
            </NavLink>
            <NavLink to="/security" className={navItemClass} title="Security & Auth Audit">
              <ShieldCheck className="w-4 h-4 shrink-0" />
              {!isCollapsed && <span>Security Audit</span>}
            </NavLink>
            <NavLink to="/audit-logs" className={navItemClass} title="Audit Trail">
              <ScrollText className="w-4 h-4 shrink-0" />
              {!isCollapsed && <span>Audit Trail</span>}
            </NavLink>
            <NavLink to="/settings" className={navItemClass} title="Profile & Preferences">
              <Settings className="w-4 h-4 shrink-0" />
              {!isCollapsed && <span>Settings</span>}
            </NavLink>
          </div>
        </div>
      </div>

      {/* Footer Toggle if Collapsed */}
      {isCollapsed && (
        <div className="p-3 border-t border-[#263247] flex justify-center">
          <button
            onClick={() => setIsCollapsed(false)}
            className="p-1.5 rounded-md text-[#94A3B8] hover:text-[#F1F5F9] hover:bg-[#151E2E] transition"
            title="Expand Sidebar"
          >
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      )}
    </aside>
  );
};
