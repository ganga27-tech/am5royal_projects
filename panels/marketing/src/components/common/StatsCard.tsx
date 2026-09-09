import React, { ReactNode } from 'react';
import { LucideIcon, TrendingUp, TrendingDown } from 'lucide-react';

interface StatsCardProps {
  title: string;
  value: string | number;
  subtitle?: string;
  icon: LucideIcon;
  change?: string;
  isPositive?: boolean;
  colorClass?: string;
  extra?: ReactNode;
}

export const StatsCard: React.FC<StatsCardProps> = ({
  title,
  value,
  subtitle,
  icon: Icon,
  change,
  isPositive = true,
  colorClass = 'from-[#FAF6EF] to-[#F5EFEB] text-[#9B7314] border-[#E5D8C1]',
  extra,
}) => {
  return (
    <div className="glass-card glass-card-hover rounded-2xl p-5 relative overflow-hidden flex flex-col justify-between shadow-cream-sm bg-[#FFFFFF]">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-[11px] font-extrabold uppercase tracking-wider text-[#8E8276]">
            {title}
          </p>
          <h3 className="font-outfit text-2xl sm:text-3xl font-black text-[#1E1B18] mt-1 tracking-tight">
            {value}
          </h3>
        </div>

        <div className={`rounded-xl bg-gradient-to-br p-3 border ${colorClass} shadow-sm`}>
          <Icon className="h-5 w-5" />
        </div>
      </div>

      <div className="mt-4 flex items-center justify-between pt-3 border-t border-[#EAE2D2] text-xs">
        <div className="flex items-center gap-1.5">
          {change && (
            <span
              className={`flex items-center gap-0.5 font-bold ${
                isPositive ? 'text-emerald-700 bg-emerald-50 px-1.5 py-0.5 rounded border border-emerald-200' : 'text-rose-700 bg-rose-50 px-1.5 py-0.5 rounded border border-rose-200'
              }`}
            >
              {isPositive ? (
                <TrendingUp className="h-3.5 w-3.5" />
              ) : (
                <TrendingDown className="h-3.5 w-3.5" />
              )}
              {change}
            </span>
          )}
          {subtitle && (
            <span className="text-[#8E8276] truncate font-medium text-[11px]">{subtitle}</span>
          )}
        </div>

        {extra}
      </div>
    </div>
  );
};
