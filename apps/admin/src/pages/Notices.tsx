import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { Notice } from '../types/database';
import { Bell, Plus, ShieldCheck } from 'lucide-react';

export const Notices: React.FC = () => {
  const [notices, setNotices] = useState<Notice[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchNotices() {
      try {
        setLoading(true);
        const { data, error } = await supabase
          .from('notices')
          .select('*')
          .order('published_date', { ascending: false });

        if (error) throw error;
        setNotices(data || []);
      } catch (err) {
        console.error('Error fetching notices:', err);
      } finally {
        setLoading(false);
      }
    }

    fetchNotices();
  }, []);

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-bold text-slate-900">गाव सूचना व घोषणा (Village Notices & Updates)</h2>
          <p className="text-xs text-slate-500">ग्रामपंचायत अधिकृत सूचना, पाणीपुरवठा व वीज खंडित होण्याबाबत संदेश व्यवस्थापन</p>
        </div>
        <button className="flex items-center space-x-1.5 px-3.5 py-2 bg-brand-green text-white rounded-lg text-xs font-semibold hover:bg-emerald-700 transition shadow-sm">
          <Plus className="w-4 h-4" />
          <span>नवीन सूचना प्रसिद्ध करा</span>
        </button>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
          <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
            <tr>
              <th className="px-5 py-3">सूचनेचे शीर्षक (मराठी)</th>
              <th className="px-5 py-3">शीर्षक (English)</th>
              <th className="px-5 py-3">प्राधान्य (Priority)</th>
              <th className="px-5 py-3">प्रकार (Authority)</th>
              <th className="px-5 py-3">तारीख (Date)</th>
              <th className="px-5 py-3">स्थिती</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {loading ? (
              <tr>
                <td colSpan={6} className="px-5 py-6 text-center text-slate-400">माहिती लोड होत आहे...</td>
              </tr>
            ) : notices.length === 0 ? (
              <tr>
                <td colSpan={6} className="px-5 py-6 text-center text-slate-400">सूचना उपलब्ध नाहीत.</td>
              </tr>
            ) : (
              notices.map((n) => (
                <tr key={n.id} className="hover:bg-slate-50/70">
                  <td className="px-5 py-3.5 font-bold text-slate-800 flex items-center gap-1.5">
                    <Bell className="w-3.5 h-3.5 text-brand-yellow" /> {n.title_mr}
                  </td>
                  <td className="px-5 py-3.5 text-slate-600">{n.title_en}</td>
                  <td className="px-5 py-3.5">
                    <span className={`px-2 py-0.5 rounded text-[11px] font-semibold ${
                      n.priority === 'emergency' ? 'bg-red-100 text-red-800' :
                      n.priority === 'high' ? 'bg-amber-100 text-amber-800' :
                      'bg-slate-100 text-slate-700'
                    }`}>
                      {n.priority}
                    </span>
                  </td>
                  <td className="px-5 py-3.5">
                    {n.is_gram_panchayat ? (
                      <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-100 text-emerald-800">
                        <ShieldCheck className="w-3 h-3" /> ग्रामपंचायत अधिकृत
                      </span>
                    ) : (
                      <span className="text-slate-500 text-[11px]">सार्वजनिक</span>
                    )}
                  </td>
                  <td className="px-5 py-3.5 text-slate-500">
                    {new Date(n.published_date).toLocaleDateString('mr-IN')}
                  </td>
                  <td className="px-5 py-3.5">
                    <span className="px-2 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-100 text-emerald-800">
                      {n.status}
                    </span>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

