import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { ShieldCheck, Lock, Mail, ArrowRight, CheckCircle2 } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../components/Toast';

export const Login: React.FC = () => {
  const [email, setEmail] = useState('admin@nardanaconnect.in');
  const [password, setPassword] = useState('nardana2026');
  const [loading, setLoading] = useState(false);

  const { login } = useAuth();
  const { showToast } = useToast();
  const navigate = useNavigate();
  const location = useLocation();

  // Retrieve origin route if redirected from protected route
  const from = (location.state as any)?.from?.pathname || '/';

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      showToast('कृपया ईमेल आणि पासवर्ड प्रविष्ट करा.', 'error');
      return;
    }

    setLoading(true);
    try {
      const success = await login(email, password);
      if (success) {
        showToast('व्यवस्थापक लॉगिन यशस्वी! स्वागत आहे.', 'success');
        navigate(from, { replace: true });
      } else {
        showToast('अवैध ईमेल किंवा पासवर्ड.', 'error');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleQuickDemo = async () => {
    setEmail('admin@nardanaconnect.in');
    setPassword('nardana2026');
    setLoading(true);
    await login('admin@nardanaconnect.in', 'nardana2026');
    showToast('डेमो ॲडमिन लॉगिन यशस्वी!', 'success');
    navigate(from, { replace: true });
  };

  return (
    <div className="min-h-screen bg-slate-900 flex flex-col justify-center items-center p-4 relative select-none">
      {/* Decorative gradient background */}
      <div className="absolute inset-0 bg-gradient-to-tr from-brand-blue/30 via-slate-900 to-brand-green/20 pointer-events-none" />

      <div className="relative w-full max-w-md bg-white rounded-3xl shadow-2xl border border-slate-100 overflow-hidden">
        {/* Top Header */}
        <div className="bg-brand-blue p-8 text-center text-white relative">
          <div className="w-16 h-16 bg-white/10 rounded-2xl flex items-center justify-center mx-auto mb-3 shadow-inner border border-white/20">
            <ShieldCheck className="w-9 h-9 text-brand-yellow" />
          </div>
          <h1 className="text-2xl font-black tracking-tight">नरडाणा कनेक्ट</h1>
          <p className="text-xs text-blue-100 font-medium mt-1">
            वेब ॲडमिन पॅनेल (Web Admin Panel)
          </p>
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-bold bg-white/15 text-white mt-3 border border-white/20">
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
            केवळ नरडाणा गाव (पिन: ४२५४०४)
          </div>
        </div>

        {/* Form Body */}
        <div className="p-8 space-y-6">
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1">
                प्रशासक ईमेल (Admin Email)
              </label>
              <div className="relative">
                <Mail className="w-4 h-4 text-slate-400 absolute left-3.5 top-3" />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="admin@nardanaconnect.in"
                  className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:border-brand-blue"
                  required
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1">
                पासवर्ड (Password)
              </label>
              <div className="relative">
                <Lock className="w-4 h-4 text-slate-400 absolute left-3.5 top-3" />
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:border-brand-blue"
                  required
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 bg-brand-blue hover:bg-blue-700 text-white font-bold text-sm rounded-xl transition shadow-md flex items-center justify-center gap-2 mt-2"
            >
              <span>{loading ? 'प्रवेश करत आहे...' : 'ॲडमिन पॅनेलमध्ये लॉगिन करा'}</span>
              <ArrowRight className="w-4 h-4" />
            </button>
          </form>

          {/* Quick Demo Access Button */}
          <div className="pt-4 border-t border-slate-100 text-center">
            <button
              onClick={handleQuickDemo}
              type="button"
              className="w-full py-2.5 px-4 bg-emerald-50 hover:bg-emerald-100 text-emerald-800 font-bold text-xs rounded-xl border border-emerald-200 transition flex items-center justify-center gap-2"
            >
              <CheckCircle2 className="w-4 h-4 text-emerald-600" />
              <span>१-क्लिक चाचणी लॉगिन (Quick Demo Access)</span>
            </button>
          </div>
        </div>

        {/* Footer */}
        <div className="bg-slate-50 px-6 py-3 border-t border-slate-100 text-center">
          <p className="text-[11px] text-slate-400">
            आपलं गाव, आपली डिजिटल ओळख! Developed by <strong className="text-slate-600">Siya Infotech &amp; Solar Energy</strong>
          </p>
        </div>
      </div>
    </div>
  );
};
