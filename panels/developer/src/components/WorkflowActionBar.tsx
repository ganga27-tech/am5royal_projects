import React, { useState } from 'react';
import { Bug, BugStatus, UserRole } from '../types/developer';
import { useAuth } from '../auth/AuthContext';
import { developerApi } from '../api/developerApi';
import { Modal } from './Modal';
import {
  Play,
  CheckCircle2,
  XCircle,
  RotateCcw,
  Send,
  UserCheck,
  Lock,
  ArrowRight,
} from 'lucide-react';

interface WorkflowActionBarProps {
  bug: Bug;
  onBugUpdated: (updatedBug: Bug) => void;
}

export const WorkflowActionBar: React.FC<WorkflowActionBarProps> = ({ bug, onBugUpdated }) => {
  const { user } = useAuth();
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  // Modals
  const [isTransitionModalOpen, setIsTransitionModalOpen] = useState<boolean>(false);
  const [targetStatus, setTargetStatus] = useState<BugStatus | null>(null);
  const [transitionNotes, setTransitionNotes] = useState<string>('');
  const [commitRef, setCommitRef] = useState<string>('');
  const [releaseVer, setReleaseVer] = useState<string>('');

  const currentStatus = bug.status;
  const userRole: UserRole = user?.role || 'developer';
  const isAdmin = userRole === 'admin' || userRole === 'super_admin';
  const isQA = userRole === 'qa' || isAdmin;
  const isDev = userRole === 'developer' || isAdmin;

  const openTransitionDialog = (nextSt: BugStatus) => {
    setTargetStatus(nextSt);
    setTransitionNotes('');
    setCommitRef(bug.commit_reference || '');
    setReleaseVer(bug.release_version || '');
    setError(null);
    setIsTransitionModalOpen(true);
  };

  const handleExecuteTransition = async () => {
    if (!targetStatus) return;
    setIsLoading(true);
    setError(null);
    try {
      const updated = await developerApi.transitionBug(bug.id, {
        new_status: targetStatus,
        notes: transitionNotes.trim() || undefined,
        commit_reference: commitRef.trim() || undefined,
        release_version: releaseVer.trim() || undefined,
      });
      setIsTransitionModalOpen(false);
      onBugUpdated(updated);
    } catch (err: any) {
      setError(err?.response?.data?.detail || 'Failed to update bug status.');
    } finally {
      setIsLoading(false);
    }
  };

  // Determine permitted actions
  const renderActionButtons = () => {
    const buttons: React.ReactNode[] = [];

    // Developer Actions
    if (isDev) {
      if (currentStatus === 'ASSIGNED_TO_DEVELOPER') {
        buttons.push(
          <button
            key="start-work"
            onClick={() => openTransitionDialog('IN_PROGRESS')}
            className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-md text-xs font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] transition shadow-sm"
          >
            <Play className="w-3.5 h-3.5 fill-current" />
            Start Work (In Progress)
          </button>
        );
      }

      if (currentStatus === 'IN_PROGRESS') {
        buttons.push(
          <button
            key="submit-qa"
            onClick={() => openTransitionDialog('READY_FOR_QA')}
            className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-md text-xs font-semibold bg-[#34D399] text-[#080B12] hover:bg-[#10B981] transition shadow-sm"
          >
            <CheckCircle2 className="w-3.5 h-3.5" />
            Mark Fixed & Submit to QA
          </button>
        );
      }

      if (currentStatus === 'QA_REJECTED' || currentStatus === 'REOPENED') {
        buttons.push(
          <button
            key="resume-work"
            onClick={() => openTransitionDialog('IN_PROGRESS')}
            className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-md text-xs font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] transition"
          >
            <RotateCcw className="w-3.5 h-3.5" />
            Resume Work (In Progress)
          </button>
        );
      }
    }

    // QA Actions
    if (isQA) {
      if (currentStatus === 'READY_FOR_QA') {
        buttons.push(
          <button
            key="start-testing"
            onClick={() => openTransitionDialog('QA_TESTING')}
            className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-md text-xs font-semibold bg-[#38BDF8] text-[#080B12] hover:bg-[#0284C7] transition"
          >
            <Play className="w-3.5 h-3.5 fill-current" />
            Begin QA Testing
          </button>
        );
      }

      if (currentStatus === 'QA_TESTING') {
        buttons.push(
          <button
            key="verify-pass"
            onClick={() => openTransitionDialog('VERIFIED')}
            className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-md text-xs font-semibold bg-[#34D399] text-[#080B12] hover:bg-[#10B981] transition"
          >
            <CheckCircle2 className="w-3.5 h-3.5" />
            Verify Fix (PASS)
          </button>
        );
        buttons.push(
          <button
            key="reject-fail"
            onClick={() => openTransitionDialog('QA_REJECTED')}
            className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-md text-xs font-semibold bg-[#FB4B5F] text-white hover:bg-[#E11D48] transition"
          >
            <XCircle className="w-3.5 h-3.5" />
            Reject Fix (FAIL)
          </button>
        );
      }

      if (currentStatus === 'VERIFIED') {
        buttons.push(
          <button
            key="close-defect"
            onClick={() => openTransitionDialog('CLOSED')}
            className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-md text-xs font-semibold bg-[#151E2E] text-[#94A3B8] hover:text-[#F1F5F9] hover:bg-[#1B2638] border border-[#263247] transition"
          >
            <Lock className="w-3.5 h-3.5" />
            Close Defect
          </button>
        );
      }

      if (currentStatus === 'CLOSED') {
        buttons.push(
          <button
            key="reopen-defect"
            onClick={() => openTransitionDialog('REOPENED')}
            className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-md text-xs font-semibold bg-[#FB4B5F]/10 text-[#FB4B5F] hover:bg-[#FB4B5F]/20 border border-[#FB4B5F]/30 transition"
          >
            <RotateCcw className="w-3.5 h-3.5" />
            Reopen Defect
          </button>
        );
      }
    }

    return buttons;
  };

  const actionButtons = renderActionButtons();

  return (
    <div className="rounded-lg bg-[#0E1420] border border-[#263247] p-4 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
      <div className="flex items-center gap-3">
        <div className="p-2 rounded-lg bg-[#151E2E] border border-[#263247]">
          <UserCheck className="w-4 h-4 text-[#22D3EE]" />
        </div>
        <div>
          <div className="text-[11px] font-mono uppercase tracking-wider text-[#94A3B8]">
            Workflow Status Engine
          </div>
          <div className="text-sm font-semibold text-[#F1F5F9] flex items-center gap-2 mt-0.5">
            Current Stage: <span className="text-[#22D3EE] font-mono">{currentStatus.replace(/_/g, ' ')}</span>
          </div>
        </div>
      </div>

      <div className="flex flex-wrap items-center gap-2.5">
        {actionButtons.length > 0 ? (
          actionButtons
        ) : (
          <div className="text-xs text-[#94A3B8] italic flex items-center gap-1.5 py-1.5 px-3 bg-[#151E2E] rounded border border-[#263247]">
            <span>No state transition available for your role ({userRole.toUpperCase()}) in this stage.</span>
          </div>
        )}
      </div>

      {/* Transition Input Modal */}
      <Modal
        isOpen={isTransitionModalOpen}
        onClose={() => setIsTransitionModalOpen(false)}
        title={`Transition Status to ${targetStatus?.replace(/_/g, ' ')}`}
        subtitle="This action will advance the bug lifecycle and notify assigned engineers."
      >
        <div className="space-y-4">
          {error && (
            <div className="p-3 rounded bg-[#FB4B5F]/10 border border-[#FB4B5F]/30 text-xs text-[#FB4B5F]">
              {error}
            </div>
          )}

          <div>
            <label className="block text-xs font-medium text-[#94A3B8] mb-1.5">
              Engineering Notes & Justification (Required for verification & rejects)
            </label>
            <textarea
              rows={3}
              value={transitionNotes}
              onChange={(e) => setTransitionNotes(e.target.value)}
              placeholder="Detail reproduction check, root cause fix, or re-test observations..."
              className="w-full rounded-md bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] placeholder-[#475569] focus:outline-none focus:border-[#22D3EE] transition font-sans"
            />
          </div>

          {targetStatus === 'READY_FOR_QA' && (
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-medium text-[#94A3B8] mb-1">
                  Commit Reference / PR #
                </label>
                <input
                  type="text"
                  value={commitRef}
                  onChange={(e) => setCommitRef(e.target.value)}
                  placeholder="e.g. c09f507 or #142"
                  className="w-full rounded-md bg-[#151E2E] border border-[#263247] px-3 py-1.5 text-xs text-[#F1F5F9] font-mono placeholder-[#475569] focus:outline-none focus:border-[#22D3EE]"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-[#94A3B8] mb-1">
                  Release Version
                </label>
                <input
                  type="text"
                  value={releaseVer}
                  onChange={(e) => setReleaseVer(e.target.value)}
                  placeholder="e.g. v1.4.3"
                  className="w-full rounded-md bg-[#151E2E] border border-[#263247] px-3 py-1.5 text-xs text-[#F1F5F9] font-mono placeholder-[#475569] focus:outline-none focus:border-[#22D3EE]"
                />
              </div>
            </div>
          )}

          <div className="flex items-center justify-end gap-3 pt-3 border-t border-[#263247]">
            <button
              type="button"
              onClick={() => setIsTransitionModalOpen(false)}
              disabled={isLoading}
              className="px-3 py-1.5 text-xs font-medium text-[#94A3B8] hover:text-[#F1F5F9] transition"
            >
              Cancel
            </button>
            <button
              type="button"
              onClick={handleExecuteTransition}
              disabled={isLoading}
              className="flex items-center gap-1.5 px-4 py-1.5 text-xs font-semibold bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] rounded-md transition"
            >
              {isLoading ? 'Executing...' : 'Confirm Transition'}
              <ArrowRight className="w-3.5 h-3.5" />
            </button>
          </div>
        </div>
      </Modal>
    </div>
  );
};
