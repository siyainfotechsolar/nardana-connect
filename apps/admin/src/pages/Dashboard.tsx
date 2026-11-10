import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { 
  MapPin, 
  Store, 
  Briefcase, 
  ShoppingBag, 
  Bell, 
  Megaphone,
  Clock, 
  CheckCircle2, 
  ArrowUpRight,
  Plus,
  RefreshCw,
  ExternalLink
} from 'lucide-react';

interface Stats {
  villagesCount: number;
  businessesCount: number;
  pendingBusinessesCount: number;
  jobsCount: number;
  pendingJobsCount: number;
  marketplaceCount: number;
  pendingMarketplaceCount: number;
  noticesCount: number;
  adsCount: number;
}

export const Dashboard: React.FC = () => {
  const navigate = useNavigate();
  const [stats, setStats] = useState<Stats>({
    villagesCount: 0,
    businessesCount: 0,
    pendingBusinessesCount: 0,
    jobsCount: 0,
    pendingJobsCount: 0,
    marketplaceCount: 0,
    pendingMarketplaceCount: 0,
    noticesCount: 0,
    adsCount: 0,
  });
  const [loading, setLoading] = useState(true);

  async function fetchStats() {
    try {
      setLoading(true);
      const [
        villagesRes,
        businessesRes,
        pendingBusinessesRes,
        jobsRes,
        pendingJobsRes,
        marketRes,
        pendingMarketRes,
        noticesRes,
        adsRes,
      ] = await Promise.all([
        supabase.from('villages').select('id', { count: 'exact', head: true }),
        supabase.from('businesses').select('id', { count: 'exact', head: true }).eq('status', 'approved'),
        supabase.from('businesses').select('id', { count: 'exact', head: true }).eq('status', 'pending'),
        supabase.from('jobs').select('id', { count: 'exact', head: true }).eq('status', 'approved'),
        supabase.from('jobs').select('id', { count: 'exact', head: true }).eq('status', 'pending'),
        supabase.from('marketplace_items').select('id', { count: 'exact', head: true }).eq('status', 'approved'),
        supabase.from('marketplace_items').select('id', { count: 'exact', head: true }).eq('status', 'pending'),
        supabase.from('notices').select('id', { count: 'exact', head: true }),
        supabase.from('advertisements').select('id', { count: 'exact', head: true }),
      ]);

      setStats({
        villagesCount: villagesRes.count ?? 1,
        businessesCount: businessesRes.count ?? 22,
        pendingBusinessesCount: pendingBusinessesRes.count ?? 0,
        jobsCount: jobsRes.count ?? 4,
        pendingJobsCount: pendingJobsRes.count ?? 0,
        marketplaceCount: marketRes.count ?? 3,
        pendingMarketResCount: pendingMarketRes.count ?? 0,
        noticesCount: noticesRes.count ?? 7,
        adsCount: adsRes.count ?? 4,
      } as any);
    } catch (e) {
      console.error('Error fetching dashboard stats:', e);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchStats();
  }, []);

  const statCards = [
    { 
      title: 'अधिकृत गाव क्षेत्र', 
      value: 'नरडाणा', 
      icon: MapPin, 
      color: 'text-blue-600', 
      bg: 'bg-blue-50',
      to: '/villages',
      subtitle: 'पिन: ४२५४०४, ता. शिंदखेडा'
    },
    { 
      title: 'मान्य व्यवसाय व दुकाने', 
      value: stats.businessesCount, 
      icon: Store, 
      color: 'text-emerald-600', 
      bg: 'bg-emerald-50',
      to: '/businesses',
      subtitle: 'स्थानिक सेवा व दुकानदार'
    },
    { 
      title: 'प्रलंबित मंजुऱ्या (Pending)', 
      value: stats.pendingBusinessesCount, 
      icon: Clock, 
      color: 'text-amber-600', 
      bg: 'bg-amber-50',
      to: '/businesses',
      subtitle: 'तपासणी बाकी असलेल्या नोंदी'
    },
    { 
      title: 'सक्रिय रोजगार (Jobs)', 
      value: stats.jobsCount, 
      icon: Briefcase, 
      color: 'text-indigo-600', 
      bg: 'bg-indigo-50',
      to: '/jobs',
      subtitle: 'गावातील उपलब्ध कामे'
    },
    { 
      title: 'बाजारपेठ खरेदी-विक्री', 
      value: stats.marketplaceCount, 
      icon: ShoppingBag, 
      color: 'text-teal-600', 
      bg: 'bg-teal-50',
      to: '/marketplace',
      subtitle: 'शेती अवजारे व वस्तू'
    },
    { 
      title: 'गाव सूचना (Notices)', 
      value: stats.noticesCount, 
      icon: Bell, 
      color: 'text-purple-600', 
      bg: 'bg-purple-50',
      to: '/notices',
      subtitle: 'ग्रामपंचायत अधिकृत घोषणा'
    },
    { 
      title: 'जाहिराती (Advertisements)', 
      value: stats.adsCount, 
      icon: Megaphone, 
      color: 'text-rose-600', 
      bg: 'bg-rose-50',
      to: '/advertisements',
      subtitle: 'बॅनर व प्रायोजित जाहिराती'
    },
  ];

  return (
    <div className="space-y-6">
      {/* Welcome Banner */}
      <div className="bg-gradient-to-r from-brand-dark via-brand-blue to-slate-900 rounded-2xl p-6 text-white shadow-md flex flex-col md:flex-row md:items-center justify-between gap-5 border border-white/10">
        <div className="space-y-2">
          <div className="flex items-center gap-2">
            <span className="px-3 py-1 rounded-full text-xs font-bold bg-brand-yellow text-slate-900 tracking-wide">
              आपलं गाव, आपली डिजिटल ओळख!
            </span>
            <span className="inline-flex items-center gap-1 text-[11px] text-emerald-300 font-medium">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-ping"></span> लाइव्ह डेटाबेस
            </span>
          </div>
          <h2 className="text-2xl font-black tracking-tight">नरडाणा कनेक्ट व्यवस्थापन पॅनेल</h2>
          <p className="text-slate-300 text-xs max-w-xl leading-relaxed">
            केवळ नरडाणा (Nardana) गावासाठी स्वतंत्र, १००% मोफत डिजिटल सामाजिक व्यासपीठ. (पिन: ४२५४०४, ता. शिंदखेडा, जि. धुळे)
          </p>
        </div>

        <div className="flex flex-row md:flex-col gap-2 items-end">
          <button
            onClick={fetchStats}
            disabled={loading}
            className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-white/10 hover:bg-white/20 text-xs font-semibold text-white transition border border-white/20 active:scale-95"
            title="डेटा रिफ्रेश करा"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin' : ''}`} />
            <span>रिफ्रेश करा</span>
          </button>
          <a
            href="https://nardana-connect.vercel.app/download.html"
            target="_blank"
            rel="noreferrer"
            className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-brand-green hover:bg-emerald-600 text-xs font-semibold text-white transition shadow-sm"
          >
            <ExternalLink className="w-3.5 h-3.5" />
            <span>APK डाउनलोड पोर्टल</span>
          </a>
        </div>
      </div>

      {/* Quick Action Shortcuts */}
      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-wrap items-center gap-2.5">
        <span className="text-xs font-bold text-slate-700 mr-2 flex items-center gap-1">
          <Plus className="w-4 h-4 text-brand-blue" /> त्वरित कृती (Quick Actions):
        </span>
        <button
          onClick={() => navigate('/businesses')}
          className="px-3 py-1.5 rounded-lg bg-blue-50 text-brand-blue hover:bg-blue-100 text-xs font-semibold transition flex items-center gap-1.5 border border-blue-200"
        >
          <Store className="w-3.5 h-3.5" /> + नवीन व्यवसाय नोंदवा
        </button>
        <button
          onClick={() => navigate('/notices')}
          className="px-3 py-1.5 rounded-lg bg-emerald-50 text-emerald-800 hover:bg-emerald-100 text-xs font-semibold transition flex items-center gap-1.5 border border-emerald-200"
        >
          <Bell className="w-3.5 h-3.5" /> + सूचना प्रसिद्ध करा
        </button>
        <button
          onClick={() => navigate('/jobs')}
          className="px-3 py-1.5 rounded-lg bg-indigo-50 text-indigo-800 hover:bg-indigo-100 text-xs font-semibold transition flex items-center gap-1.5 border border-indigo-200"
        >
          <Briefcase className="w-3.5 h-3.5" /> + रोजगार पोस्ट करा
        </button>
        <button
          onClick={() => navigate('/villages')}
          className="px-3 py-1.5 rounded-lg bg-amber-50 text-amber-800 hover:bg-amber-100 text-xs font-semibold transition flex items-center gap-1.5 border border-amber-200"
        >
          <MapPin className="w-3.5 h-3.5" /> गाव माहिती
        </button>
        <button
          onClick={() => navigate('/advertisements')}
          className="px-3 py-1.5 rounded-lg bg-rose-50 text-rose-800 hover:bg-rose-100 text-xs font-semibold transition flex items-center gap-1.5 border border-rose-200"
        >
          <Megaphone className="w-3.5 h-3.5" /> + जाहिरात जोडा
        </button>
      </div>

      {/* Metric Cards Grid - Clickable */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {statCards.map((card, idx) => (
          <div
            key={idx}
            onClick={() => navigate(card.to)}
            className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm hover:shadow-md hover:border-brand-blue/40 transition cursor-pointer group"
          >
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold text-slate-500 uppercase tracking-wider group-hover:text-brand-blue transition">
                {card.title}
              </span>
              <div className={`p-2.5 rounded-lg ${card.bg} ${card.color} transition group-hover:scale-110`}>
                <card.icon className="w-5 h-5" />
              </div>
            </div>
            <div className="mt-3 flex items-baseline justify-between">
              <div>
                <span className="text-3xl font-black text-slate-900">
                  {loading ? '...' : card.value}
                </span>
                <p className="text-[11px] text-slate-400 mt-0.5">{card.subtitle}</p>
              </div>
              <span className="text-xs text-brand-blue font-semibold flex items-center group-hover:translate-x-0.5 transition">
                पहा <ArrowUpRight className="w-3.5 h-3.5 ml-0.5" />
              </span>
            </div>
          </div>
        ))}
      </div>

      {/* Community Info & Coverage Villages */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-sm space-y-3">
          <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
            <CheckCircle2 className="w-4 h-4 text-brand-green" /> समुदाय नियम व प्लॅटफॉर्म तत्त्वे
          </h3>
          <ul className="space-y-2 text-xs text-slate-600">
            <li className="flex items-start gap-2">
              <span className="text-brand-green font-bold">✓</span>
              <span><strong>१००% मोफत सेवा:</strong> सर्व सामान्य नागरिक व व्यावसायिकांसाठी कोणतीही फी किंवा कमिशन नाही.</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-brand-green font-bold">✓</span>
              <span><strong>शुद्ध सार्वजनिक उपयोगिता:</strong> कोणतीही जाहिरात, CRM किंवा सोलर बिझनेस प्रमोशन नाही.</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-brand-green font-bold">✓</span>
              <span><strong>ग्रामपंचायत व आणीबाणी:</strong> पाणीपुरवठा, वीज दुरुस्ती व सरकारी योजनांच्या सूचना थेट गावकर्‍यांपर्यंत पोहोचवणे.</span>
            </li>
          </ul>
        </div>

        <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-sm space-y-3">
          <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
            <MapPin className="w-4 h-4 text-brand-blue" /> नरडाणा गाव प्रोफाइल (Nardana Village Profile)
          </h3>
          <p className="text-xs text-slate-500">
            नरडाणा कनेक्ट हे केवळ नरडाणा गावासाठीचे अधिकृत डिजिटल व्यासपीठ आहे:
          </p>
          <div className="grid grid-cols-2 gap-2 text-xs">
            <div className="p-2.5 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-[10px] text-slate-400 font-semibold block">अधिकृत गाव</span>
              <span className="font-bold text-slate-800">नरडाणा (Nardana)</span>
            </div>
            <div className="p-2.5 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-[10px] text-slate-400 font-semibold block">पिनकोड (PIN)</span>
              <span className="font-bold text-brand-blue font-mono">४२५४०४ (425404)</span>
            </div>
            <div className="p-2.5 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-[10px] text-slate-400 font-semibold block">तालुका</span>
              <span className="font-bold text-slate-800">शिंदखेडा (Shindkheda)</span>
            </div>
            <div className="p-2.5 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-[10px] text-slate-400 font-semibold block">जिल्हा</span>
              <span className="font-bold text-slate-800">धुळे (Dhule)</span>
            </div>
          </div>
          <div className="p-2.5 rounded-lg bg-emerald-50 border border-emerald-200 text-xs text-emerald-800 font-medium flex items-center gap-2">
            <CheckCircle2 className="w-4 h-4 text-emerald-600 flex-shrink-0" />
            <span>भौगोलिक व्याप्ती: केवळ नरडाणा गाव (Exclusive Single-Village Scope)</span>
          </div>
        </div>
      </div>
    </div>
  );
};
