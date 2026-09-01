import React from 'react';
import { BugActivityHistory } from '../types/developer';
import { Clock, CheckCircle, AlertCircle, ArrowRight, UserPlus, MessageSquare } from 'lucide-react';

interface ActivityTimelineProps {
  history: BugActivityHistory[];
}

export const ActivityTimeline: React.FC<ActivityTimelineProps> = ({ history }) => {
  if (!history || history.length === 0) {
    return (
      <div className="text-center py-6 text-xs text-[#94A3B8] font-mono">
        No state change history recorded yet.
      </div>
    );
  }

  const getActionIcon = (action: string) => {
    switch (action) {
      case 'BUG_CREATED':
        return <AlertCircle className="w-3.5 h-3.5 text-[#22D3EE]" />;
      case 'BUG_ASSIGNED':
      case 'REASSIGNED':
        return <UserPlus className="w-3.5 h-3.5 text-[#8B5CF6]" />;
      case 'FIX_SUBMITTED':
      case 'READY_FOR_QA':
        return <CheckCircle className="w-3.5 h-3.5 text-[#FBBF24]" />;
      case 'QA_VERIFIED':
      case 'BUG_CLOSED':
        return <CheckCircle className="w-3.5 h-3.5 text-[#34D399]" />;
      case 'QA_REJECTED':
      case 'BUG_REOPENED':
        return <AlertCircle className="w-3.5 h-3.5 text-[#FB4B5F]" />;
      case 'COMMENT_ADDED':
        return <MessageSquare className="w-3.5 h-3.5 text-[#38BDF8]" />;
      default:
        return <Clock className="w-3.5 h-3.5 text-[#94A3B8]" />;
    }
  };

  const formatTimestamp = (iso: string) => {
    try {
      const d = new Date(iso);
      return d.toLocaleString('en-US', {
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
      });
    } catch {
      return iso;
    }
  };

  return (
    <div className="relative pl-6 space-y-6 before:absolute before:left-2.5 before:top-2 before:bottom-2 before:w-[1px] before:bg-[#263247]">
      {history.map((event) => (
        <div key={event.id} className="relative group">
          {/* Dot Icon */}
          <div className="absolute -left-6 top-0.5 p-1 rounded-full bg-[#0E1420] border border-[#263247] flex items-center justify-center">
            {getActionIcon(event.action)}
          </div>

          <div className="flex flex-col gap-1">
            <div className="flex items-center gap-2 flex-wrap">
              <span className="text-xs font-semibold text-[#F1F5F9]">{event.actor_name}</span>
              <span className="text-[10px] font-mono uppercase px-1.5 py-0.2 rounded bg-[#151E2E] text-[#94A3B8] border border-[#263247]">
                {event.actor_role}
              </span>
              <span className="text-[11px] font-mono text-[#475569]">
                {formatTimestamp(event.created_at)}
              </span>
            </div>

            {/* Transition Flow */}
            {event.old_value && event.new_value && (
              <div className="flex items-center gap-1.5 text-xs font-mono text-[#94A3B8] mt-0.5">
                <span className="text-[#94A3B8]">{event.old_value.replace(/_/g, ' ')}</span>
                <ArrowRight className="w-3 h-3 text-[#475569]" />
                <span className="text-[#22D3EE] font-medium">{event.new_value.replace(/_/g, ' ')}</span>
              </div>
            )}

            {/* Notes */}
            {event.notes && (
              <div className="text-xs text-[#94A3B8] bg-[#151E2E]/80 border border-[#263247] rounded-md p-2.5 mt-1 font-sans">
                {event.notes}
              </div>
            )}
          </div>
        </div>
      ))}
    </div>
  );
};
