import React from 'react';
import { UserCheck, Globe } from 'lucide-react';

export const Header: React.FC = () => {
  return (
    <header className="bg-white border-b border-slate-200 px-6 py-3.5 flex items-center justify-between shadow-sm sticky top-0 z-10">
      <div className="flex items-center space-x-2">
        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-50 text-brand-green border border-emerald-200">
          ● लाइव्ह सिस्टीम (Live)
        </span>
        <span className="text-sm text-slate-500 font-medium">
          कव्हरेज: नरडाणा आणि परिसर (Nardana & Nearby Villages)
        </span>
      </div>

      <div className="flex items-center space-x-4">
        <div className="flex items-center space-x-1.5 text-xs font-medium text-slate-600 bg-slate-100 px-2.5 py-1.5 rounded-lg border border-slate-200">
          <Globe className="w-3.5 h-3.5 text-brand-blue" />
          <span>मराठी / English</span>
        </div>

        <div className="flex items-center space-x-2 pl-3 border-l border-slate-200">
          <div className="w-8 h-8 rounded-full bg-brand-blue text-white flex items-center justify-center text-xs font-bold shadow-sm">
            NA
          </div>
          <div className="text-left text-xs">
            <p className="font-semibold text-slate-800 leading-tight">Admin</p>
            <p className="text-slate-400 flex items-center gap-1">
              <UserCheck className="w-3 h-3 text-brand-green" /> व्यवस्थापक
            </p>
          </div>
        </div>
      </div>
    </header>
  );
};

