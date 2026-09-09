import React, { ReactNode, useEffect } from 'react';
import { X } from 'lucide-react';

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  subtitle?: string;
  children: ReactNode;
  maxWidth?: string;
}

export const Modal: React.FC<ModalProps> = ({
  isOpen,
  onClose,
  title,
  subtitle,
  children,
  maxWidth = 'max-w-xl',
}) => {
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    if (isOpen) {
      document.body.style.overflow = 'hidden';
      window.addEventListener('keydown', handleKeyDown);
    }
    return () => {
      document.body.style.overflow = 'unset';
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 overflow-y-auto">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-[#1E1B18]/50 backdrop-blur-md transition-opacity"
        onClick={onClose}
      />

      {/* Dialog Body */}
      <div
        className={`relative w-full ${maxWidth} rounded-3xl border border-[#E5D8C1] bg-[#FFFFFF] p-6 sm:p-8 shadow-cream-xl transition-all z-10 max-h-[90vh] flex flex-col`}
      >
        {/* Header */}
        <div className="flex items-start justify-between border-b border-[#EAE2D2] pb-4 mb-4">
          <div>
            <h3 className="font-outfit text-base sm:text-lg font-bold text-[#1E1B18] flex items-center gap-2">
              {title}
            </h3>
            {subtitle && (
              <p className="text-xs text-[#8E8276] mt-0.5">{subtitle}</p>
            )}
          </div>
          <button
            onClick={onClose}
            className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] p-2 text-[#8E8276] hover:bg-[#FAF6EF] hover:text-[#1E1B18] transition-colors"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        {/* Scrollable Content Container */}
        <div className="overflow-y-auto flex-1 pr-1 custom-scrollbar">
          {children}
        </div>
      </div>
    </div>
  );
};
