import React, { useState, useRef, useEffect } from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import { 
  ArrowLeft, 
  ChevronRight, 
  Download, 
  ShieldCheck, 
  LogOut, 
  Settings as SettingsIcon, 
  User, 
  ChevronDown 
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { getSafeBackRoute, getAdminBreadcrumbs, ADMIN_ROUTES } from '../utils/navigationConfig';

export const Header: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { user, logout } = useAuth();
  const [profileOpen, setProfileOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const isDashboard = location.pathname === '/';
  const meta = ADMIN_ROUTES[location.pathname];
  const breadcrumbs = getAdminBreadcrumbs(location.pathname);

  // Close dropdown on outside click
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setProfileOpen(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleBack = () => {
    const safeTarget = getSafeBackRoute(location.pathname, (location.state as any)?.from);
    navigate(safeTarget);
  };

  const handleLogout = () => {
    if (window.confirm('तुम्हाला ॲडमिन पॅनेलमधून लॉगआउट करायचे आहे का?')) {
      logout();
      navigate('/login');
    }
  };

  return (
    <header className="bg-white border-b border-slate-200 px-6 py-2.5 flex items-center justify-between shadow-sm sticky top-0 z-30 select-none">
      {/* Left side: Back Arrow, Breadcrumbs & Page Title */}
      <div className="flex items-center space-x-3 min-w-0">
        {!isDashboard && (
          <button
            onClick={handleBack}
            title="मागील पानावर जा (Back to previous Admin page)"
            className="p-2 rounded-lg border border-slate-200 hover:bg-slate-100 text-slate-700 hover:text-brand-blue transition shadow-sm flex items-center justify-center flex-shrink-0"
          >
            <ArrowLeft className="w-4 h-4" />
          </button>
        )}

        <div className="min-w-0">
          {/* Breadcrumbs */}
          <nav className="flex items-center space-x-1.5 text-[11px] text-slate-400 font-medium truncate">
            {breadcrumbs.map((crumb, idx) => (
              <React.Fragment key={crumb.path}>
                {idx > 0 && <ChevronRight className="w-3 h-3 text-slate-300 flex-shrink-0" />}
                {idx === breadcrumbs.length - 1 ? (
                  <span className="text-slate-800 font-bold truncate">{crumb.label}</span>
                ) : (
                  <Link to={crumb.path} className="hover:text-brand-blue transition truncate">
                    {crumb.label}
                  </Link>
                )}
              </React.Fragment>
            ))}
          </nav>

          {/* Page Title */}
          <h2 className="text-sm font-black text-slate-800 leading-tight truncate">
            {meta?.titleMr || 'नरडाणा कनेक्ट व्यवस्थापन'}
          </h2>
        </div>
      </div>

      {/* Right side: Live Status, APK Download & Profile Menu */}
      <div className="flex items-center space-x-3 flex-shrink-0">
        {/* Coverage Status Pill */}
        <div className="hidden md:flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-emerald-50 text-brand-green border border-emerald-200">
          <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
          <span>लाईव्ह • केवळ नरडाणा गाव</span>
        </div>

        {/* APK Download Link */}
        <a
          href="/download.html"
          target="_blank"
          rel="noreferrer"
          className="hidden sm:inline-flex items-center gap-1.5 text-xs font-semibold text-brand-blue bg-blue-50 hover:bg-blue-100 px-2.5 py-1.5 rounded-lg border border-blue-200 transition"
        >
          <Download className="w-3.5 h-3.5" />
          <span>APK</span>
        </a>

        {/* Admin Profile Dropdown */}
        <div className="relative" ref={dropdownRef}>
          <button
            onClick={() => setProfileOpen(!profileOpen)}
            className="flex items-center space-x-2 p-1.5 rounded-xl hover:bg-slate-100 transition border border-transparent hover:border-slate-200"
          >
            <div className="w-8 h-8 rounded-full bg-brand-blue text-white flex items-center justify-center text-xs font-black shadow-sm">
              NC
            </div>
            <div className="text-left text-xs hidden lg:block">
              <p className="font-bold text-slate-800 leading-tight">
                {user?.name || 'Admin'}
              </p>
              <p className="text-[10px] text-slate-400 flex items-center gap-1">
                <ShieldCheck className="w-3 h-3 text-brand-green" /> व्यवस्थापक
              </p>
            </div>
            <ChevronDown className="w-3.5 h-3.5 text-slate-400" />
          </button>

          {/* Dropdown Menu */}
          {profileOpen && (
            <div className="absolute right-0 mt-2 w-56 bg-white rounded-2xl shadow-xl border border-slate-200 py-2 z-50">
              <div className="px-4 py-2 border-b border-slate-100">
                <p className="text-xs font-bold text-slate-800">{user?.name || 'Admin'}</p>
                <p className="text-[11px] text-slate-400 font-mono truncate">{user?.email || 'admin@nardanaconnect.in'}</p>
                <span className="inline-block mt-1 px-2 py-0.5 rounded-md text-[10px] font-bold bg-blue-50 text-brand-blue">
                  सुपर ॲडमिन (Super Admin)
                </span>
              </div>

              <div className="py-1">
                <Link
                  to="/settings"
                  onClick={() => setProfileOpen(false)}
                  className="flex items-center space-x-2.5 px-4 py-2 text-xs font-medium text-slate-700 hover:bg-slate-50 hover:text-brand-blue transition"
                >
                  <SettingsIcon className="w-4 h-4 text-slate-400" />
                  <span>सिस्टीम सेटिंग्ज (Settings)</span>
                </Link>

                <Link
                  to="/app-update"
                  onClick={() => setProfileOpen(false)}
                  className="flex items-center space-x-2.5 px-4 py-2 text-xs font-medium text-slate-700 hover:bg-slate-50 hover:text-brand-blue transition"
                >
                  <User className="w-4 h-4 text-slate-400" />
                  <span>ॲप अपडेट मॅनेजर</span>
                </Link>
              </div>

              <div className="border-t border-slate-100 pt-1">
                <button
                  onClick={handleLogout}
                  className="w-full flex items-center space-x-2.5 px-4 py-2 text-xs font-bold text-red-600 hover:bg-red-50 transition text-left"
                >
                  <LogOut className="w-4 h-4 text-red-500" />
                  <span>बाहेर पडा (Logout)</span>
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};
