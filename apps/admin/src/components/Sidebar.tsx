import React from 'react';
import { NavLink } from 'react-router-dom';
import { 
  LayoutDashboard, 
  Users, 
  Layers, 
  Store, 
  Wrench, 
  Briefcase, 
  ShoppingBag, 
  Bell, 
  PhoneCall, 
  Megaphone, 
  Vote, 
  AlertCircle, 
  MessageSquareQuote, 
  Send, 
  LayoutGrid, 
  Settings, 
  Smartphone, 
  BarChart3, 
  ShieldCheck,
  Car,
  Gavel,
  Bus 
} from 'lucide-react';

export const navItems = [
  { to: '/', label: '१. डॅशबोर्ड (Dashboard)', icon: LayoutDashboard },
  { to: '/users', label: '२. नागरिक (Users)', icon: Users },
  { to: '/categories', label: '३. कॅटेगरी (Categories)', icon: Layers },
  { to: '/businesses', label: '४. व्यवसाय (Businesses)', icon: Store },
  { to: '/services', label: '५. सेवा (Services)', icon: Wrench },
  { to: '/vehicles', label: '६. गाडी भाड्याने (Vehicle Rental)', icon: Car },
  { to: '/bus-timetable', label: '७. एसटी बस वेळापत्रक (Bus Time Table)', icon: Bus },
  { to: '/jobs', label: '८. रोजगार (Jobs)', icon: Briefcase },
  { to: '/marketplace', label: '९. खरेदी - विक्री (Buy & Sell)', icon: ShoppingBag },
  { to: '/notices', label: '१०. गाव सूचना (Notices)', icon: Bell },
  { to: '/emergency-contacts', label: '११. तातडीचे संपर्क (Emergency)', icon: PhoneCall },
  { to: '/advertisements', label: '१२. जाहिराती (Advertisements)', icon: Megaphone },
  { to: '/election', label: '१३. निवडणूक (Election)', icon: Vote },
  { to: '/complaints', label: '१४. तक्रारी (Complaints)', icon: AlertCircle },
  { to: '/reviews', label: '१५. अभिप्राय (Reviews)', icon: MessageSquareQuote },
  { to: '/notifications', label: '१६. नोटिफिकेशन्स (Push Alerts)', icon: Send },
  { to: '/home-layout', label: '१७. होम लेआउट (Home Layout)', icon: LayoutGrid },
  { to: '/disclaimer', label: '१८. कायदेशीर अस्वीकरण (Disclaimer)', icon: Gavel },
  { to: '/settings', label: '१९. ॲप सेटिंग्ज (Settings)', icon: Settings },
  { to: '/app-update', label: '२०. ॲप अपडेट (App Update)', icon: Smartphone },
  { to: '/reports', label: '२१. अहवाल (Reports)', icon: BarChart3 },
  { to: '/audit-logs', label: '२२. ऑडिट लॉग (Audit Logs)', icon: ShieldCheck },
];

export const Sidebar: React.FC = () => {
  return (
    <aside className="w-64 bg-brand-dark text-white flex flex-col h-screen flex-shrink-0 select-none border-r border-white/5">
      {/* Brand Logo & Name */}
      <div className="p-4 border-b border-white/10 flex items-center space-x-3 flex-shrink-0">
        <img 
          src="/app-logo.png" 
          alt="Nardana Connect" 
          className="w-9 h-9 rounded-xl object-cover shadow-md border border-brand-yellow/40 bg-white" 
        />
        <div className="min-w-0">
          <h1 className="font-bold text-base leading-tight tracking-wide truncate">नरडाणा कनेक्ट</h1>
          <p className="text-[11px] text-brand-yellow font-medium truncate">Nardana Admin (22 Modules)</p>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-2 space-y-0.5 overflow-y-auto">
        {navItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            className={({ isActive }) =>
              `flex items-center space-x-2.5 px-3 py-2 rounded-lg text-xs font-medium transition-all ${
                isActive
                  ? 'bg-brand-blue text-white shadow-sm font-semibold border-l-4 border-brand-yellow'
                  : 'text-slate-300 hover:bg-white/5 hover:text-white'
              }`
            }
          >
            <item.icon className="w-4 h-4 text-brand-yellow flex-shrink-0" />
            <span className="truncate">{item.label}</span>
          </NavLink>
        ))}
      </nav>

      {/* Footer Info & Developer Attribution */}
      <div className="p-3 border-t border-white/10 space-y-1.5 flex-shrink-0 bg-brand-dark">
        <div className="text-xs text-slate-300 flex items-center space-x-2">
          <ShieldCheck className="w-4 h-4 text-brand-green flex-shrink-0" />
          <span className="text-[11px] font-semibold text-emerald-400">केवळ नरडाणा गाव (४२५४०४)</span>
        </div>
        <div className="pt-1.5 border-t border-white/5 text-center">
          <p className="text-[10px] text-slate-400">Developed with ❤️ by</p>
          <p className="text-xs font-semibold text-brand-yellow">Siya Infotech</p>
        </div>
      </div>
    </aside>
  );
};
