import React, { useState } from 'react';
import { BugComment } from '../types/developer';
import { developerApi } from '../api/developerApi';
import { Send, User } from 'lucide-react';

interface CommentsListProps {
  bugId: number;
  comments: BugComment[];
  onCommentAdded: () => void;
}

export const CommentsList: React.FC<CommentsListProps> = ({ bugId, comments, onCommentAdded }) => {
  const [message, setMessage] = useState<string>('');
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!message.trim() || isSubmitting) return;

    setIsSubmitting(true);
    setError(null);
    try {
      await developerApi.addBugComment(bugId, message.trim());
      setMessage('');
      onCommentAdded();
    } catch (err: any) {
      setError(err?.response?.data?.detail || 'Failed to post comment.');
    } finally {
      setIsSubmitting(false);
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
    <div className="space-y-4">
      {/* Comments thread */}
      <div className="space-y-3 max-h-[420px] overflow-y-auto pr-1">
        {comments && comments.length > 0 ? (
          comments.map((comment) => {
            const isQA = comment.author_role.toLowerCase() === 'qa';
            const isDev = comment.author_role.toLowerCase() === 'developer';
            return (
              <div
                key={comment.id}
                className="p-3.5 rounded-lg bg-[#151E2E]/80 border border-[#263247] space-y-1.5"
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <div className="p-1 rounded bg-[#0E1420] border border-[#263247] text-[#94A3B8]">
                      <User className="w-3 h-3" />
                    </div>
                    <span className="text-xs font-semibold text-[#F1F5F9]">{comment.author_name}</span>
                    <span
                      className={`text-[10px] font-mono uppercase px-1.5 py-0.2 rounded border ${
                        isQA
                          ? 'bg-[#1C1635] text-[#A78BFA] border-[#8B5CF6]/30'
                          : isDev
                          ? 'bg-[#0E1E2E] text-[#22D3EE] border-[#22D3EE]/30'
                          : 'bg-[#1B2638] text-[#94A3B8] border-[#263247]'
                      }`}
                    >
                      {comment.author_role}
                    </span>
                  </div>
                  <span className="text-[11px] font-mono text-[#475569]">
                    {formatTimestamp(comment.created_at)}
                  </span>
                </div>

                <p className="text-xs text-[#F1F5F9] leading-relaxed whitespace-pre-wrap pl-6">
                  {comment.message}
                </p>
              </div>
            );
          })
        ) : (
          <div className="text-center py-6 text-xs text-[#94A3B8] font-mono">
            No technical notes or comments yet.
          </div>
        )}
      </div>

      {/* Comment Input */}
      <form onSubmit={handleSubmit} className="space-y-2 pt-2 border-t border-[#263247]">
        {error && <div className="text-xs text-[#FB4B5F]">{error}</div>}
        <div className="flex items-end gap-2">
          <textarea
            rows={2}
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder="Add engineering comment, reproduction notes, or verification result..."
            className="flex-1 rounded-md bg-[#151E2E] border border-[#263247] px-3 py-2 text-xs text-[#F1F5F9] placeholder-[#475569] focus:outline-none focus:border-[#22D3EE] resize-none"
          />
          <button
            type="submit"
            disabled={!message.trim() || isSubmitting}
            className="p-2.5 rounded-md bg-[#22D3EE] text-[#080B12] hover:bg-[#06B6D4] disabled:opacity-50 disabled:cursor-not-allowed transition shrink-0"
          >
            <Send className="w-4 h-4" />
          </button>
        </div>
      </form>
    </div>
  );
};
