import React from 'react';
import { BugStatus, TaskStatus } from '../types/developer';

interface StatusBadgeProps {
  status: BugStatus | TaskStatus | string;
  size?: 'sm' | 'md';
}

export const StatusBadge: React.FC<StatusBadgeProps> = ({ status, size = 'md' }) => {
  const getStyle = () => {
    switch (status) {
      case 'NEW':
        return 'bg-[#0E1E2E] text-[#22D3EE] border-[#22D3EE]/30';
      case 'ASSIGNED_TO_DEVELOPER':
        return 'bg-[#1C1635] text-[#A78BFA] border-[#8B5CF6]/30';
      case 'IN_PROGRESS':
        return 'bg-[#261E0E] text-[#FCD34D] border-[#FBBF24]/30';
      case 'FIXED':
        return 'bg-[#0E241B] text-[#34D399] border-[#34D399]/30';
      case 'READY_FOR_QA':
        return 'bg-[#2A210D] text-[#FDE047] border-[#EAB308]/30';
      case 'QA_TESTING':
        return 'bg-[#0B2136] text-[#38BDF8] border-[#38BDF8]/30';
      case 'VERIFIED':
        return 'bg-[#062419] text-[#4ADE80] border-[#22C55E]/40 font-semibold';
      case 'QA_REJECTED':
      case 'REOPENED':
        return 'bg-[#2A1015] text-[#FB4B5F] border-[#FB4B5F]/40';
      case 'CLOSED':
        return 'bg-[#151E2E] text-[#94A3B8] border-[#263247]';
      case 'completed':
        return 'bg-[#0E241B] text-[#34D399] border-[#34D399]/30';
      case 'todo':
        return 'bg-[#151E2E] text-[#94A3B8] border-[#263247]';
      case 'blocked':
        return 'bg-[#2A1015] text-[#FB4B5F] border-[#FB4B5F]/40';
      default:
        return 'bg-[#151E2E] text-[#94A3B8] border-[#263247]';
    }
  };

  const formatText = (text: string) => {
    return text.replace(/_/g, ' ');
  };

  const sizeClasses = size === 'sm' ? 'text-[10px] px-1.5 py-0.5' : 'text-xs px-2.5 py-1';

  return (
    <span
      className={`inline-flex items-center gap-1.5 font-mono font-medium rounded border ${getStyle()} ${sizeClasses}`}
    >
      <span className="h-1.5 w-1.5 rounded-full bg-current opacity-80" />
      {formatText(status)}
    </span>
  );
};
