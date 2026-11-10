import React from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import { ArrowLeft, ChevronRight, Home } from 'lucide-react';
import { getSafeBackRoute, getAdminBreadcrumbs, ADMIN_ROUTES } from '../utils/navigationConfig';

interface AdminPageHeaderProps {
  title?: string;
  subtitle?: string;
  icon?: React.ComponentType<{ className?: string }>;
  actions?: React.ReactNode;
  fallbackBackRoute?: string;
  onBeforeBack?: () => boolean; // Return false to cancel back
}

export const AdminPageHeader: React.FC<AdminPageHeaderProps> = ({
  title,
  subtitle,
  icon: Icon,
  actions,
  fallbackBackRoute,
  onBeforeBack,
}) => {
  const navigate = useNavigate();
  const location = useLocation();

  const isDashboard = location.pathname === '/';
  const meta = ADMIN_ROUTES[location.pathname];
  const displayTitle = title || meta?.titleMr || 'प्रशासक फलक';
  const displaySubtitle = subtitle || meta?.titleEn || '';
  const breadcrumbs = getAdminBreadcrumbs(location.pathname);

  const handleBack = () => {
    if (onBeforeBack && !onBeforeBack()) {
      return;
    }
    const safeTarget = fallbackBackRoute || getSafeBackRoute(location.pathname, (location.state as any)?.from);
    navigate(safeTarget);
  };

  return (
    <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm mb-6 flex flex-col md:flex-row md:items-center justify-between gap-4">
      <div className="flex items-start space-x-3.5">
        {!isDashboard && (
          <button
            onClick={handleBack}
            title="मागील पानावर जा (Go Back)"
            className="p-2.5 rounded-xl border border-slate-200 hover:bg-slate-100 hover:border-slate-300 text-slate-600 transition flex-shrink-0 shadow-sm mt-0.5"
          >
            <ArrowLeft className="w-4 h-4" />
          </button>
        )}

        {Icon && (
          <div className="p-2.5 bg-brand-blue/10 text-brand-blue rounded-xl flex-shrink-0 hidden sm:flex">
            <Icon className="w-5 h-5" />
          </div>
        )}

        <div>
          {/* Breadcrumbs */}
          <nav className="flex items-center space-x-1.5 text-xs text-slate-400 font-medium mb-1">
            <Link to="/" className="hover:text-brand-blue flex items-center gap-1 transition">
              <Home className="w-3 h-3" />
              <span>डॅशबोर्ड</span>
            </Link>
            {breadcrumbs.slice(1).map((crumb, idx) => (
              <React.Fragment key={crumb.path}>
                <ChevronRight className="w-3 h-3 text-slate-300" />
                {idx === breadcrumbs.length - 2 ? (
                  <span className="text-slate-700 font-bold">{crumb.label}</span>
                ) : (
                  <Link to={crumb.path} className="hover:text-brand-blue transition">
                    {crumb.label}
                  </Link>
                )}
              </React.Fragment>
            ))}
          </nav>

          {/* Current Page Title */}
          <h1 className="text-lg font-black text-slate-800 leading-tight flex items-center gap-2">
            <span>{displayTitle}</span>
            {displaySubtitle && (
              <span className="hidden lg:inline text-xs font-semibold text-slate-400">
                ({displaySubtitle})
              </span>
            )}
          </h1>
        </div>
      </div>

      {/* Action buttons (Add, Export, Filters, etc.) */}
      {actions && <div className="flex items-center space-x-2.5 flex-wrap">{actions}</div>}
    </div>
  );
};
