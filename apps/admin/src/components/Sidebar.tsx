import React from 'react';
import { NavLink } from 'react-router-dom';
import { 
  LayoutDashboard, 
  MapPin, 
  Layers, 
  Store, 
  Briefcase, 
  ShoppingBag, 
  Bell, 
  Settings,
  ShieldCheck
} from 'lucide-react';

const navItems = [
  { to: '/', label: 'डॅशबोर्ड (Dashboard)', icon: LayoutDashboard },
  { to: '/villages', label: 'गावे (Villages)', icon: MapPin },
  { to: '/categories', label: 'कॅटेगरी (Categories)', icon: Layers },
  { to: '/businesses', label: 'व्यवसाय व सेवा (Businesses)', icon: Store },
  { to: '/jobs', label: 'रोजगार (Jobs)', icon: Briefcase },
  { to: '/marketplace', label: 'बाजारपेठ (Marketplace)', icon: ShoppingBag },
  { to: '/notices', label: 'गाव सूचना (Notices)', icon: Bell },
  { to: '/settings', label: 'सेटिंग्ज (Settings)', icon: Settings },
];

export const Sidebar: React.FC = () => {
  return (
    <aside className="w-64 bg-brand-dark text-white flex flex-col min-h-screen">
      {/* Brand Logo & Name */}
      <div className="p-5 border-b border-white/10 flex items-center space-x-3">
        <div className="w-10 h-10 rounded-xl bg-brand-green flex items-center justify-center font-bold text-white shadow-md">
          NC
        </div>
        <div>
          <h1 className="font-bold text-lg leading-tight tracking-wide">नरडाणा कनेक्ट</h1>
          <p className="text-xs text-brand-yellow font-medium">Nardana Connect Admin</p>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-3 space-y-1 overflow-y-auto">
        {navItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            className={({ isActive }) =>
              `flex items-center space-x-3 px-3.5 py-2.5 rounded-lg text-sm font-medium transition-all ${
                isActive
                  ? 'bg-brand-blue text-white shadow-sm font-semibold border-l-4 border-brand-yellow'
                  : 'text-slate-300 hover:bg-white/5 hover:text-white'
              }`
            }
          >
            <item.icon className="w-4 h-4 text-brand-yellow" />
            <span>{item.label}</span>
          </NavLink>
        ))}
      </nav>

      {/* Footer Info */}
      <div className="p-4 border-t border-white/10 text-xs text-slate-400 flex items-center space-x-2">
        <ShieldCheck className="w-4 h-4 text-brand-green" />
        <span>आपलं गाव, आपली डिजिटल ओळख!</span>
      </div>
    </aside>
  );
};

