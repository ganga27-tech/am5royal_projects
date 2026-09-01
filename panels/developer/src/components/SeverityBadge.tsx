import React from 'react';
import { BugSeverity } from '../types/developer';

interface SeverityBadgeProps {
  severity: BugSeverity | string;
}

export const SeverityBadge: React.FC<SeverityBadgeProps> = ({ severity }) => {
  const getStyle = () => {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 'text-[#FB4B5F] bg-[#FB4B5F]/10 border-[#FB4B5F]/30';
      case 'high':
        return 'text-[#FBBF24] bg-[#FBBF24]/10 border-[#FBBF24]/30';
      case 'medium':
        return 'text-[#38BDF8] bg-[#38BDF8]/10 border-[#38BDF8]/30';
      case 'low':
      default:
        return 'text-[#94A3B8] bg-[#94A3B8]/10 border-[#94A3B8]/20';
    }
  };

  return (
    <span
      className={`inline-flex items-center px-2 py-0.5 rounded text-[11px] font-mono font-medium border uppercase tracking-wider ${getStyle()}`}
    >
      {severity}
    </span>
  );
};
