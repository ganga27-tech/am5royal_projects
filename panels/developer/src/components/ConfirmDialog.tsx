import React from 'react';
import { Modal } from './Modal';
import { AlertTriangle } from 'lucide-react';

interface ConfirmDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  isDestructive?: boolean;
  isLoading?: boolean;
}

export const ConfirmDialog: React.FC<ConfirmDialogProps> = ({
  isOpen,
  onClose,
  onConfirm,
  title,
  message,
  confirmText = 'Confirm',
  cancelText = 'Cancel',
  isDestructive = false,
  isLoading = false,
}) => {
  return (
    <Modal isOpen={isOpen} onClose={onClose} title={title} maxWidth="sm">
      <div className="flex items-start gap-4">
        <div
          className={`p-2.5 rounded-lg shrink-0 ${
            isDestructive ? 'bg-[#FB4B5F]/10 text-[#FB4B5F]' : 'bg-[#22D3EE]/10 text-[#22D3EE]'
          }`}
        >
          <AlertTriangle className="w-5 h-5" />
        </div>
        <p className="text-sm text-[#94A3B8] leading-relaxed mt-0.5">{message}</p>
      </div>

      <div className="flex items-center justify-end gap-3 mt-6 pt-4 border-t border-[#263247]">
        <button
          type="button"
          onClick={onClose}
          disabled={isLoading}
          className="px-3.5 py-1.5 rounded-md text-xs font-medium text-[#94A3B8] hover:text-[#F1F5F9] hover:bg-[#1B2638] border border-[#263247] transition"
        >
          {cancelText}
        </button>
        <button
          type="button"
          onClick={onConfirm}
          disabled={isLoading}
          className={`px-4 py-1.5 rounded-md text-xs font-semibold transition ${
            isDestructive
              ? 'bg-[#FB4B5F] hover:bg-[#E11D48] text-white'
              : 'bg-[#22D3EE] hover:bg-[#06B6D4] text-[#080B12]'
          }`}
        >
          {isLoading ? 'Processing...' : confirmText}
        </button>
      </div>
    </Modal>
  );
};
