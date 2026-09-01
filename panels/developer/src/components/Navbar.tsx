import React, { useState, useEffect } from 'react';
import { useAuth } from '../auth/AuthContext';
import { developerApi } from '../api/developerApi';
import { NotificationItem } from '../types/developer';
import { Bell, LogOut, Check, ExternalLink } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

interface NavbarProps {
  isCollapsed: boolean;
}

export const Navbar: React.FC<NavbarProps> = ({ isCollapsed }) => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const [unreadCount, setUnreadCount] = useState<number>(0);
  const [notifications, setNotifications] = useState<NotificationItem[]>([]);
  const [isNotifOpen, setIsNotifOpen] = useState<boolean>(false);

  const fetchNotifications = async () => {
    try {
      const [cntData, listData] = await Promise.all([
        developerApi.getUnreadCount(),
        developerApi.listNotifications(10),
      ]);
      setUnreadCount(cntData.unread_count);
      setNotifications(listData);
    } catch {
      // non-critical
    }
  };

  useEffect(() => {
    fetchNotifications();
    const interval = setInterval(fetchNotifications, 20000);
    return () => clearInterval(interval);
  }, []);

  const handleMarkAllRead = async () => {
    try {
      await developerApi.markAllNotificationsRead();
      setUnreadCount(0);
      setNotifications((prev) => prev.map((n) => ({ ...n, is_read: true })));
    } catch (err) {
      console.error(err);
    }
  };

  const handleNotificationClick = async (n: NotificationItem) => {
    if (!n.is_read) {
      await developerApi.markNotificationRead(n.id);
      setUnreadCount((c) => Math.max(0, c - 1));
      setNotifications((prev) => prev.map((item) => (item.id === n.id ? { ...item, is_read: true } : item)));
    }
    setIsNotifOpen(false);
    if (n.reference_type === 'bug' && n.reference_id) {
      navigate(`/bugs/${n.reference_id}`);
    } else if (n.reference_type === 'task') {
      navigate('/tasks');
    }
  };

  const getRoleBadge = () => {
    const role = user?.role?.toLowerCase() || 'developer';
    if (role === 'qa') {
      return (
        <span className="px-2 py-0.5 rounded text-[11px] font-mono font-semibold bg-[#1C1635] text-[#A78BFA] border border-[#8B5CF6]/30 uppercase tracking-wider">
          QA ENGINEER
        </span>
      );
    }
    if (role === 'admin' || role === 'super_admin') {
      return (
        <span className="px-2 py-0.5 rounded text-[11px] font-mono font-semibold bg-[#2A1015] text-[#FB4B5F] border border-[#FB4B5F]/30 uppercase tracking-wider">
          ADMIN
        </span>
      );
    }
    return (
      <span className="px-2 py-0.5 rounded text-[11px] font-mono font-semibold bg-[#0E1E2E] text-[#22D3EE] border border-[#22D3EE]/30 uppercase tracking-wider">
        DEVELOPER
      </span>
    );
  };

  return (
    <header
      className={`h-16 fixed top-0 right-0 z-20 bg-[#0E1420]/95 backdrop-blur-sm border-b border-[#263247] flex items-center justify-between px-6 transition-all duration-200 ${
        isCollapsed ? 'left-16' : 'left-60'
      }`}
    >
      {/* Left info */}
      <div className="flex items-center gap-2">
        <span className="text-xs font-mono text-[#94A3B8]">ENV:</span>
        <span className="text-xs font-mono text-[#34D399] bg-[#34D399]/10 px-2.5 py-0.5 rounded border border-[#34D399]/30">
          HOSTINGER CLUSTER • PRODUCTION
        </span>
      </div>

      {/* Right controls */}
      <div className="flex items-center gap-4">
        {/* Notifications Popover */}
        <div className="relative">
          <button
            onClick={() => setIsNotifOpen(!isNotifOpen)}
            className="p-2 rounded-lg text-[#94A3B8] hover:text-[#F1F5F9] hover:bg-[#151E2E] border border-transparent hover:border-[#263247] transition relative"
            title="Notifications"
          >
            <Bell className="w-4 h-4" />
            {unreadCount > 0 && (
              <span className="absolute -top-1 -right-1 px-1.5 py-0.2 rounded-full text-[10px] font-bold bg-[#FB4B5F] text-white">
                {unreadCount}
              </span>
            )}
          </button>

          {isNotifOpen && (
            <div className="absolute right-0 mt-2 w-80 rounded-lg bg-[#0E1420] border border-[#263247] shadow-2xl overflow-hidden z-50">
              <div className="p-3 border-b border-[#263247] flex items-center justify-between bg-[#151E2E]/80">
                <span className="text-xs font-semibold text-[#F1F5F9]">Notifications</span>
                {unreadCount > 0 && (
                  <button
                    onClick={handleMarkAllRead}
                    className="text-[11px] text-[#22D3EE] hover:underline flex items-center gap-1"
                  >
                    <Check className="w-3 h-3" /> Mark all read
                  </button>
                )}
              </div>

              <div className="max-h-72 overflow-y-auto divide-y divide-[#263247]">
                {notifications && notifications.length > 0 ? (
                  notifications.map((n) => (
                    <div
                      key={n.id}
                      onClick={() => handleNotificationClick(n)}
                      className={`p-3 text-xs cursor-pointer hover:bg-[#151E2E] transition ${
                        !n.is_read ? 'bg-[#151E2E]/40 border-l-2 border-[#22D3EE]' : ''
                      }`}
                    >
                      <div className="font-semibold text-[#F1F5F9] flex items-center justify-between">
                        <span>{n.title}</span>
                        {!n.is_read && (
                          <span className="w-1.5 h-1.5 rounded-full bg-[#22D3EE]" />
                        )}
                      </div>
                      <p className="text-[#94A3B8] text-[11px] mt-1 line-clamp-2">{n.message}</p>
                    </div>
                  ))
                ) : (
                  <div className="p-6 text-center text-xs text-[#94A3B8]">
                    No notifications yet
                  </div>
                )}
              </div>
            </div>
          )}
        </div>

        {/* User Info (Only name and avatar, no email or role) */}
        <div className="flex items-center gap-3 pl-3 border-l border-[#263247]">
          <div className="flex items-center gap-2">
            <div className="w-7 h-7 rounded-full bg-[#151E2E] border border-[#263247] flex items-center justify-center text-xs font-bold font-mono text-[#22D3EE]">
              {user?.full_name ? user.full_name.charAt(0).toUpperCase() : 'U'}
            </div>
            <div className="text-xs font-semibold text-[#F1F5F9]">
              {user?.full_name || 'Engineering User'}
            </div>
          </div>

          <button
            onClick={logout}
            className="p-2 rounded-lg text-[#94A3B8] hover:text-[#FB4B5F] hover:bg-[#151E2E] border border-transparent hover:border-[#263247] transition"
            title="Sign Out"
          >
            <LogOut className="w-4 h-4" />
          </button>
        </div>
      </div>
    </header>
  );
};
