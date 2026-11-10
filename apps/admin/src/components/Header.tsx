import React from 'react';
import { Globe, Download, ShieldCheck } from 'lucide-react';

export const Header: React.FC = () => {
  return (
    <header className="bg-white border-b border-slate-200 px-6 py-3 flex items-center justify-between shadow-sm sticky top-0 z-10">
      <div className="flex items-center space-x-3">
        <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-emerald-50 text-brand-green border border-emerald-200">
          <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
          लाइव्ह सिस्टीम (Live)
        </span>
        <span className="hidden sm:inline text-xs text-slate-500 font-medium">
          कव्हरेज: नरडाणा आणि परिसर (७ गावे)
        </span>
      </div>

      <div className="flex items-center space-x-3">
        <a
          href="/download.html"
          target="_blank"
          rel="noreferrer"
          className="hidden sm:inline-flex items-center gap-1.5 text-xs font-semibold text-brand-blue bg-blue-50 hover:bg-blue-100 px-2.5 py-1.5 rounded-lg border border-blue-200 transition"
        >
          <Download className="w-3.5 h-3.5" />
          <span>APK डाऊनलोड</span>
        </a>

        <div className="flex items-center space-x-1.5 text-xs font-medium text-slate-600 bg-slate-100 px-2.5 py-1.5 rounded-lg border border-slate-200">
          <Globe className="w-3.5 h-3.5 text-brand-blue" />
          <span>मराठी (प्राथमिक)</span>
        </div>

        <div className="flex items-center space-x-2 pl-2 border-l border-slate-200">
          <div className="w-8 h-8 rounded-full bg-brand-blue text-white flex items-center justify-center text-xs font-black shadow-sm">
            NC
          </div>
          <div className="text-left text-xs">
            <p className="font-bold text-slate-800 leading-tight">Admin</p>
            <p className="text-[11px] text-slate-400 flex items-center gap-1">
              <ShieldCheck className="w-3 h-3 text-brand-green" /> व्यवस्थापक
            </p>
          </div>
        </div>
      </div>
    </header>
  );
};
