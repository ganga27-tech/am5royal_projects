import React, { useState } from 'react';
import { useAuth } from '../auth/AuthContext';
import { useNavigate, useLocation } from 'react-router-dom';
import { Code2, ShieldAlert, Lock, User, ArrowRight, ShieldCheck } from 'lucide-react';

export const LoginPage: React.FC = () => {
  const { login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const [identifier, setIdentifier] = useState<string>('dev@am5royal.com');
  const [password, setPassword] = useState<string>('Dev@am5royal2026');
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!identifier || !password) return;

    setIsLoading(true);
    setError(null);
    try {
      const profile = await login(identifier, password);
      if (profile.role === 'qa') {
        navigate('/qa-dashboard');
      } else if (profile.role === 'developer') {
        navigate('/developer-dashboard');
      } else {
        navigate('/');
      }
    } catch (err: any) {
      setError(err?.response?.data?.detail || 'Authentication failed. Please check credentials.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleQuickLogin = (role: 'developer' | 'qa' | 'admin') => {
    if (role === 'developer') {
      setIdentifier('dev@am5royal.com');
      setPassword('Dev@am5royal2026');
    } else if (role === 'qa') {
      setIdentifier('qa@am5royal.com');
      setPassword('Qa@am5royal2026');
    } else {
      setIdentifier('admin@am5royal.com');
      setPassword('Admin@am5royal2026');
    }
  };

  return (
    <div className="min-h-screen bg-[#080B12] flex items-center justify-center p-4">
      <div className="w-full max-w-md space-y-6">
        {/* Brand Header */}
        <div className="text-center space-y-2">
          <div className="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-[#0E1420] border border-[#263247] shadow-lg text-[#22D3EE] mb-2">
            <Code2 className="w-6 h-6" />
          </div>
          <h1 className="text-xl font-bold tracking-tight text-[#F1F5F9] uppercase">
            AM5 Royal Developer Control Center
          </h1>
          <p className="text-xs text-[#94A3B8] font-mono">
            ENGINEERING & QA OPERATIONAL PLATFORM
          </p>
        </div>

        {/* Login Box */}
        <div className="rounded-xl bg-[#0E1420] border border-[#263247] p-6 shadow-2xl">
          <form onSubmit={handleSubmit} className="space-y-4">
            {error && (
              <div className="p-3 rounded-lg bg-[#FB4B5F]/10 border border-[#FB4B5F]/30 text-xs text-[#FB4B5F]">
                {error}
              </div>
            )}

            <div>
              <label className="block text-xs font-medium text-[#94A3B8] mb-1.5 font-mono">
                WORK EMAIL / PHONE
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-[#475569]">
                  <User className="w-4 h-4" />
                </div>
                <input
                  type="text"
                  required
                  value={identifier}
                  onChange={(e) => setIdentifier(e.target.value)}
                  placeholder="dev@am5royal.com"
                  className="w-full pl-9 pr-3 py-2 bg-[#151E2E] border border-[#263247] rounded-lg text-xs text-[#F1F5F9] placeholder-[#475569] focus:outline-none focus:border-[#22D3EE] transition font-mono"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-medium text-[#94A3B8] mb-1.5 font-mono">
                SECURITY PASSWORD
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-[#475569]">
                  <Lock className="w-4 h-4" />
                </div>
                <input
                  type="password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••••••"
                  className="w-full pl-9 pr-3 py-2 bg-[#151E2E] border border-[#263247] rounded-lg text-xs text-[#F1F5F9] placeholder-[#475569] focus:outline-none focus:border-[#22D3EE] transition font-mono"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={isLoading}
              className="w-full py-2.5 px-4 bg-[#22D3EE] hover:bg-[#06B6D4] text-[#080B12] font-semibold rounded-lg text-xs tracking-wider uppercase transition flex items-center justify-center gap-2 shadow-lg disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isLoading ? 'Authenticating...' : 'Sign In to Console'}
              <ArrowRight className="w-4 h-4" />
            </button>
          </form>

          {/* Role selector shortcuts */}
          <div className="mt-6 pt-5 border-t border-[#263247] space-y-3">
            <div className="text-[11px] font-mono text-[#94A3B8] text-center uppercase tracking-wider">
              Quick Test Credentials
            </div>
            <div className="grid grid-cols-3 gap-2">
              <button
                type="button"
                onClick={() => handleQuickLogin('developer')}
                className="p-2 rounded-lg bg-[#151E2E] hover:bg-[#1B2638] border border-[#22D3EE]/30 text-left transition"
              >
                <div className="text-[10px] font-mono text-[#22D3EE] uppercase font-bold">DEVELOPER</div>
                <div className="text-[11px] text-[#F1F5F9] truncate">Vishal</div>
              </button>

              <button
                type="button"
                onClick={() => handleQuickLogin('qa')}
                className="p-2 rounded-lg bg-[#151E2E] hover:bg-[#1B2638] border border-[#8B5CF6]/30 text-left transition"
              >
                <div className="text-[10px] font-mono text-[#A78BFA] uppercase font-bold">QA LEAD</div>
                <div className="text-[11px] text-[#F1F5F9] truncate">Sarah</div>
              </button>

              <button
                type="button"
                onClick={() => handleQuickLogin('admin')}
                className="p-2 rounded-lg bg-[#151E2E] hover:bg-[#1B2638] border border-[#FB4B5F]/30 text-left transition"
              >
                <div className="text-[10px] font-mono text-[#FB4B5F] uppercase font-bold">ADMIN</div>
                <div className="text-[11px] text-[#F1F5F9] truncate">Royal Admin</div>
              </button>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="text-center text-[11px] font-mono text-[#475569]">
          HOSTINGER VPS PRODUCTION ENVIRONMENT • AM5 ROYAL MARKETPLACE
        </div>
      </div>
    </div>
  );
};
