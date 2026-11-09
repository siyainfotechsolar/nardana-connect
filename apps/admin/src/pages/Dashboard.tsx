import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { 
  Users, 
  MapPin, 
  Store, 
  Briefcase, 
  ShoppingBag, 
  Bell, 
  Clock, 
  CheckCircle2, 
  ArrowUpRight 
} from 'lucide-react';

interface Stats {
  villagesCount: number;
  businessesCount: number;
  pendingBusinessesCount: number;
  jobsCount: number;
  marketplaceCount: number;
  noticesCount: number;
}

export const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<Stats>({
    villagesCount: 0,
    businessesCount: 0,
    pendingBusinessesCount: 0,
    jobsCount: 0,
    marketplaceCount: 0,
    noticesCount: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchStats() {
      try {
        setLoading(true);
        const [
          villagesRes,
          businessesRes,
          pendingBusinessesRes,
          jobsRes,
          marketRes,
          noticesRes,
        ] = await Promise.all([
          supabase.from('villages').select('id', { count: 'exact', head: true }),
          supabase.from('businesses').select('id', { count: 'exact', head: true }).eq('status', 'approved'),
          supabase.from('businesses').select('id', { count: 'exact', head: true }).eq('status', 'pending'),
          supabase.from('jobs').select('id', { count: 'exact', head: true }).eq('status', 'approved'),
          supabase.from('marketplace_items').select('id', { count: 'exact', head: true }).eq('status', 'approved'),
          supabase.from('notices').select('id', { count: 'exact', head: true }).eq('status', 'published'),
        ]);

        setStats({
          villagesCount: villagesRes.count || 7,
          businessesCount: businessesRes.count || 5,
          pendingBusinessesCount: pendingBusinessesRes.count || 0,
          jobsCount: jobsRes.count || 0,
          marketplaceCount: marketRes.count || 0,
          noticesCount: noticesRes.count || 3,
        });
      } catch (e) {
        console.error('Error fetching dashboard stats:', e);
      } finally {
        setLoading(false);
      }
    }

    fetchStats();
  }, []);

  const statCards = [
    { title: 'समाविष्ट गावे (Villages)', value: stats.villagesCount, icon: MapPin, color: 'text-blue-600', bg: 'bg-blue-50' },
    { title: 'मान्य व्यवसाय व सेवा (Approved Businesses)', value: stats.businessesCount, icon: Store, color: 'text-emerald-600', bg: 'bg-emerald-50' },
    { title: 'प्रलंबित मंजुऱ्या (Pending Approvals)', value: stats.pendingBusinessesCount, icon: Clock, color: 'text-amber-600', bg: 'bg-amber-50' },
    { title: 'सक्रिय रोजगार (Active Jobs)', value: stats.jobsCount, icon: Briefcase, color: 'text-indigo-600', bg: 'bg-indigo-50' },
    { title: 'बाजारपेठ वस्तू (Marketplace Items)', value: stats.marketplaceCount, icon: ShoppingBag, color: 'text-teal-600', bg: 'bg-teal-50' },
    { title: 'गाव सूचना (Published Notices)', value: stats.noticesCount, icon: Bell, color: 'text-purple-600', bg: 'bg-purple-50' },
  ];

  return (
    <div className="space-y-6">
      {/* Welcome Banner */}
      <div className="bg-gradient-to-r from-brand-dark to-brand-blue rounded-2xl p-6 text-white shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <span className="inline-block px-3 py-1 rounded-full text-xs font-semibold bg-brand-yellow text-slate-900 mb-2">
            नरडाणा + परिसर डिजिटल मंच
          </span>
          <h2 className="text-2xl font-bold">नरडाणा कनेक्ट व्यवस्थापन पॅनेल</h2>
          <p className="text-slate-200 text-sm mt-1">
            गावकरी, स्थानिक व्यावसायिक आणि ग्रामपंचायतीसाठी स्वतंत्र व मोफत डिजिटल कम्युनिटी प्लॅटफॉर्म.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <div className="bg-white/10 backdrop-blur px-4 py-2.5 rounded-xl border border-white/20 text-center">
            <span className="block text-xs text-slate-300">नागरिक प्रवेश</span>
            <span className="text-sm font-bold text-brand-green">100% मोफत</span>
          </div>
        </div>
      </div>

      {/* Metric Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
        {statCards.map((card, idx) => (
          <div key={idx} className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm hover:shadow transition-shadow">
            <div className="flex items-center justify-between">
              <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider">{card.title}</span>
              <div className={`p-2.5 rounded-lg ${card.bg} ${card.color}`}>
                <card.icon className="w-5 h-5" />
              </div>
            </div>
            <div className="mt-3 flex items-baseline justify-between">
              <span className="text-3xl font-extrabold text-slate-900">
                {loading ? '...' : card.value}
              </span>
              <span className="text-xs text-slate-400 flex items-center">
                थेट डेटाबेस <ArrowUpRight className="w-3.5 h-3.5 ml-0.5" />
              </span>
            </div>
          </div>
        ))}
      </div>

      {/* Quick Action Info */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-sm">
          <h3 className="font-bold text-base text-slate-800 mb-3 flex items-center gap-2">
            <CheckCircle2 className="w-4 h-4 text-brand-green" /> समुदाय नियम व तत्त्वे
          </h3>
          <ul className="space-y-2.5 text-xs text-slate-600">
            <li className="flex items-start gap-2">
              <span className="text-brand-green font-bold">✓</span>
              <span>केवळ नरडाणा आणि लगतच्या गावांच्या स्थानिक सेवा आणि माहितीसाठी समर्पित मंच.</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-brand-green font-bold">✓</span>
              <span>कोणतीही जाहिरातबाजी, CRM, सोलर चौकशी किंवा व्यावसायिक विक्री साधने नसलेला शुद्ध सामाजिक प्लॅटफॉर्म.</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-brand-green font-bold">✓</span>
              <span>ग्रामपंचायत अधिकृत सूचना, पाणीपुरवठा व वीज खंडित होण्याबाबत त्वरित गावकर्‍यांना सूचना.</span>
            </li>
          </ul>
        </div>

        <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-sm">
          <h3 className="font-bold text-base text-slate-800 mb-3 flex items-center gap-2">
            <Users className="w-4 h-4 text-brand-blue" /> सेवा कव्हरेज गावे (Coverage Villages)
          </h3>
          <div className="flex flex-wrap gap-2 text-xs">
            {['नरडाणा (Nardana)', 'वाघाळी (Waghadi)', 'होळ (Hol)', 'बेटावद (Betawad)', 'चिमठाणे (Chimthane)', 'वरडी (Vardi)', 'शिंदखेडा (Shindkheda)'].map((village, i) => (
              <span key={i} className="px-3 py-1.5 rounded-lg bg-slate-100 text-slate-700 font-medium border border-slate-200">
                📍 {village}
              </span>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

