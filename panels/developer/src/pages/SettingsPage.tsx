import React from 'react';
import { useAuth } from '../auth/AuthContext';
import { Settings, User, Bell, Key, Shield, HardDrive, Check } from 'lucide-react';

export const SettingsPage: React.FC = () => {
  const { user } = useAuth();
  const token = localStorage.getItem('am5_dev_token');

  return (
    <div className="space-y-6 max-w-4xl">
      {/* Header */}
      <div>
        <h1 className="text-lg font-bold text-[#F1F5F9] uppercase tracking-wide flex items-center gap-2">
          <Settings className="w-5 h-5 text-[#22D3EE]" /> Developer Environment & Preferences
        </h1>
        <p className="text-xs text-[#94A3B8] font-mono mt-0.5">
          CREDENTIALS, NOTIFICATION DISPATCH & ENGINEERING PROFILE
        </p>
      </div>

      {/* Profile Info */}
      <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-4">
        <div className="flex items-center gap-2 border-b border-[#263247] pb-3">
          <User className="w-4 h-4 text-[#22D3EE]" />
          <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
            Engineer Identity & Role
          </h2>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs font-mono">
          <div>
            <span className="text-[10px] text-[#475569] block mb-1">FULL NAME</span>
            <div className="p-2.5 rounded bg-[#151E2E] border border-[#263247] text-[#F1F5F9] font-bold">
              {user?.full_name}
            </div>
          </div>

          <div>
            <span className="text-[10px] text-[#475569] block mb-1">WORK EMAIL</span>
            <div className="p-2.5 rounded bg-[#151E2E] border border-[#263247] text-[#F1F5F9]">
              {user?.email}
            </div>
          </div>

          <div>
            <span className="text-[10px] text-[#475569] block mb-1">SYSTEM ROLE</span>
            <div className="p-2.5 rounded bg-[#151E2E] border border-[#263247] text-[#22D3EE] font-bold uppercase">
              {user?.role}
            </div>
          </div>

          <div>
            <span className="text-[10px] text-[#475569] block mb-1">STATUS</span>
            <div className="p-2.5 rounded bg-[#151E2E] border border-[#263247] text-[#34D399] font-bold uppercase">
              {user?.status}
            </div>
          </div>
        </div>
      </div>

      {/* Active Session JWT Token */}
      <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-3">
        <div className="flex items-center gap-2 border-b border-[#263247] pb-3">
          <Key className="w-4 h-4 text-[#FBBF24]" />
          <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
            Bearer Session Token
          </h2>
        </div>
        <p className="text-xs text-[#94A3B8]">
          Used to authenticate REST API requests against Hostinger VPS backend.
        </p>
        <div className="p-3 rounded bg-[#151E2E] border border-[#263247] text-xs font-mono text-[#94A3B8] break-all select-all">
          {token || 'No active token'}
        </div>
      </div>

      {/* Palette & Design Verification */}
      <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-5 space-y-3">
        <div className="flex items-center gap-2 border-b border-[#263247] pb-3">
          <HardDrive className="w-4 h-4 text-[#8B5CF6]" />
          <h2 className="text-xs font-bold text-[#F1F5F9] font-mono uppercase tracking-wider">
            Engineered Dark Palette Standards
          </h2>
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 text-xs font-mono">
          <div className="p-2.5 rounded bg-[#080B12] border border-[#263247] text-center">
            <span className="block text-[10px] text-[#94A3B8]">BACKGROUND</span>
            <span className="font-bold text-[#F1F5F9]">#080B12</span>
          </div>
          <div className="p-2.5 rounded bg-[#0E1420] border border-[#263247] text-center">
            <span className="block text-[10px] text-[#94A3B8]">PANEL SURFACE</span>
            <span className="font-bold text-[#F1F5F9]">#0E1420</span>
          </div>
          <div className="p-2.5 rounded bg-[#151E2E] border border-[#263247] text-center">
            <span className="block text-[10px] text-[#94A3B8]">PRIMARY CYAN</span>
            <span className="font-bold text-[#22D3EE]">#22D3EE</span>
          </div>
          <div className="p-2.5 rounded bg-[#151E2E] border border-[#263247] text-center">
            <span className="block text-[10px] text-[#94A3B8]">SECONDARY VIOLET</span>
            <span className="font-bold text-[#8B5CF6]">#8B5CF6</span>
          </div>
        </div>
      </div>
    </div>
  );
};
