import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { UserRole } from '../types/marketing';
import {
  Crown,
  Lock,
  Mail,
  ArrowRight,
  ShieldCheck,
  Sparkles,
  Zap,
  TrendingUp,
  Search,
  CheckCircle2,
} from 'lucide-react';

export const Login: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(true);
  const [errorMessage, setErrorMessage] = useState('');
  const { login, isLoading } = useAuth();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage('');
    if (!email.trim() || !password.trim()) {
      setErrorMessage('Please enter your email/phone and password.');
      return;
    }
    const success = await login(email, password, undefined, rememberMe);
    if (!success) {
      setErrorMessage('Invalid credentials. Please verify your email/phone and password.');
    }
  };

  const handleQuickPreset = (presetEmail: string) => {
    setEmail(presetEmail);
    setPassword('am5royal2026');
    setErrorMessage('');
  };

  const personas = [
    { role: 'marketing_head', title: 'Marketing Head', email: 'marketing.head@am5royal.com', icon: '👑', desc: 'Full Omnichannel Command' },
    { role: 'growth_hacker', title: 'Growth Hacker', email: 'growth@am5royal.com', icon: '🚀', desc: 'Google Ads & Paid Conversions' },
    { role: 'seo_lead', title: 'SEO Lead', email: 'seo.lead@am5royal.com', icon: '🔍', desc: 'On/Off-Page & Backlinks' },
    { role: 'content_strategist', title: 'Content Strategist', email: 'content@am5royal.com', icon: '✍️', desc: 'Blogs, PR & Copywriting' },
    { role: 'smm_specialist', title: 'SMM Specialist', email: 'smm@am5royal.com', icon: '📱', desc: 'Social Reach & Viral Content' },
  ];

  return (
    <div className="min-h-screen bg-[#FAF7F2] flex items-center justify-center p-4 sm:p-6 lg:p-10 relative overflow-hidden">
      {/* Luxurious Background Radial Highlights */}
      <div className="absolute -top-40 -left-40 w-96 h-96 bg-[#C59A27]/10 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute -bottom-40 -right-40 w-96 h-96 bg-[#0F4C81]/10 rounded-full blur-3xl pointer-events-none" />

      <div className="w-full max-w-5xl grid grid-cols-1 lg:grid-cols-12 rounded-3xl border border-[#E5D8C1] bg-[#FFFFFF] shadow-cream-xl overflow-hidden relative z-10">
        {/* Left Side: Brand Story & Presets */}
        <div className="lg:col-span-6 p-8 sm:p-12 bg-gradient-to-br from-[#FAF6EF] via-[#FFFFFF] to-[#FAF6EF] border-b lg:border-b-0 lg:border-r border-[#EAE2D2] flex flex-col justify-between text-left">
          <div>
            {/* Logo Badge */}
            <div className="inline-flex items-center gap-3 p-2 rounded-2xl bg-[#FFFFFF] border border-[#E5D8C1] shadow-cream-sm mb-6">
              <img
                src="/am5royal_logo.png"
                alt="AM5 ROYAL"
                className="h-12 w-auto object-contain"
              />
              <div className="pr-3">
                <p className="font-serif font-black text-xs text-[#1E1B18] tracking-widest uppercase">
                  AM5 ROYAL
                </p>
                <p className="text-[10px] font-bold text-[#9B7314] uppercase">
                  Marketing Portal
                </p>
              </div>
            </div>

            <h1 className="font-serif text-2xl sm:text-3xl font-black text-[#1E1B18] tracking-tight leading-snug">
              Omnichannel <span className="gold-gradient-text">Growth Engine</span>
            </h1>
            <p className="text-xs sm:text-sm text-[#685D51] mt-2 leading-relaxed">
              Enterprise control center for SEO auditing, backlinks CRM, blogs studio, PR media, Google Ads telemetry, and high-ticket leads.
            </p>

            {/* Persona Quick Select */}
            <div className="mt-8 space-y-2.5">
              <p className="text-[11px] font-extrabold uppercase tracking-wider text-[#8E8276]">
                1-Click Authorized Personas
              </p>
              <div className="space-y-2">
                {personas.map((p) => (
                  <button
                    key={p.role}
                    type="button"
                    onClick={() => handleQuickPreset(p.email)}
                    className={`w-full flex items-center justify-between p-3 rounded-2xl border transition-all text-left ${
                      email === p.email
                        ? 'border-[#C59A27] bg-[#FAF6EF] shadow-cream-sm'
                        : 'border-[#EAE2D2] bg-[#FFFFFF] hover:bg-[#FAF7F2] hover:border-[#D5C29F]'
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      <span className="text-base">{p.icon}</span>
                      <div>
                        <p className="text-xs font-bold text-[#1E1B18]">{p.title}</p>
                        <p className="text-[10px] text-[#8E8276]">{p.desc}</p>
                      </div>
                    </div>
                    {email === p.email && (
                      <CheckCircle2 className="w-4 h-4 text-[#C59A27]" />
                    )}
                  </button>
                ))}
              </div>
            </div>
          </div>

          <div className="mt-8 pt-4 border-t border-[#EAE2D2] flex items-center justify-between text-[11px] text-[#8E8276]">
            <span className="flex items-center gap-1 font-semibold text-[#685D51]">
              <ShieldCheck className="w-3.5 h-3.5 text-emerald-600" />
              256-Bit Encrypted Session
            </span>
            <span>v2.4 Production</span>
          </div>
        </div>

        {/* Right Side: Login Form */}
        <div className="lg:col-span-6 p-8 sm:p-12 flex flex-col justify-center text-left bg-[#FFFFFF]">
          <div className="max-w-md mx-auto w-full">
            <h2 className="font-outfit text-xl sm:text-2xl font-black text-[#1E1B18]">
              Sign In to Marketing Hub
            </h2>
            <p className="text-xs text-[#8E8276] mt-1">
              Enter your credentials or select an authorized persona to continue.
            </p>

            {errorMessage && (
              <div className="mt-4 p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-semibold">
                {errorMessage}
              </div>
            )}

            <form onSubmit={handleLogin} className="mt-6 space-y-4">
              <div>
                <label className="block text-xs font-bold text-[#4D443B] uppercase tracking-wider mb-2">
                  Email or Phone Number
                </label>
                <div className="relative">
                  <Mail className="w-4 h-4 text-[#8E8276] absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] text-[#1E1B18] text-sm focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none transition-all shadow-inner"
                    placeholder="e.g. marketing.head@am5royal.com"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-[#4D443B] uppercase tracking-wider mb-2">
                  Password
                </label>
                <div className="relative">
                  <Lock className="w-4 h-4 text-[#8E8276] absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="password"
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] text-[#1E1B18] text-sm focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none transition-all shadow-inner"
                    placeholder="••••••••••••"
                  />
                </div>
              </div>

              <div className="flex items-center justify-between text-xs pt-1">
                <label className="flex items-center gap-2 cursor-pointer text-[#685D51]">
                  <input
                    type="checkbox"
                    checked={rememberMe}
                    onChange={(e) => setRememberMe(e.target.checked)}
                    className="rounded border-[#D5C29F] text-[#C59A27] focus:ring-[#C59A27]"
                  />
                  <span>Remember session for 30 days</span>
                </label>
              </div>

              <button
                type="submit"
                disabled={isLoading}
                className="w-full mt-6 py-3 px-4 rounded-xl bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] hover:from-[#BA9427] hover:to-[#BA9427] text-[#1E1B18] font-bold text-sm shadow-cream-md hover:scale-[1.02] active:scale-[0.98] transition-all flex items-center justify-center gap-2 disabled:opacity-50"
              >
                {isLoading ? (
                  <div className="w-5 h-5 border-2 border-[#1E1B18]/30 border-t-[#1E1B18] rounded-full animate-spin"></div>
                ) : (
                  <>
                    <span>Enter Marketing Hub</span>
                    <ArrowRight className="w-4 h-4" />
                  </>
                )}
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
};
