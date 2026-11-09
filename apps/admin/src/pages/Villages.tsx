import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { Village } from '../types/database';
import { MapPin, Plus, Check, X } from 'lucide-react';

export const Villages: React.FC = () => {
  const [villages, setVillages] = useState<Village[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchVillages() {
      try {
        setLoading(true);
        const { data, error } = await supabase
          .from('villages')
          .select('*')
          .order('name_mr');

        if (error) throw error;
        setVillages(data || []);
      } catch (err) {
        console.error('Error fetching villages:', err);
      } finally {
        setLoading(false);
      }
    }

    fetchVillages();
  }, []);

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-bold text-slate-900">गाव व्यवस्थापन (Village Management)</h2>
          <p className="text-xs text-slate-500">नरडाणा आणि परिसरातील समाविष्ट गावांची यादी व नियंत्रण</p>
        </div>
        <button className="flex items-center space-x-1.5 px-3.5 py-2 bg-brand-blue text-white rounded-lg text-xs font-semibold hover:bg-brand-dark transition shadow-sm">
          <Plus className="w-4 h-4" />
          <span>नवीन गाव जोडा</span>
        </button>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
          <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
            <tr>
              <th className="px-5 py-3">गावाचे नाव (मराठी)</th>
              <th className="px-5 py-3">गाव (English)</th>
              <th className="px-5 py-3">तालुका (Taluka)</th>
              <th className="px-5 py-3">जिल्हा (District)</th>
              <th className="px-5 py-3">पिनकोड</th>
              <th className="px-5 py-3">स्थिती (Status)</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {loading ? (
              <tr>
                <td colSpan={6} className="px-5 py-6 text-center text-slate-400">माहिती लोड होत आहे...</td>
              </tr>
            ) : villages.length === 0 ? (
              <tr>
                <td colSpan={6} className="px-5 py-6 text-center text-slate-400">गावे उपलब्ध नाहीत.</td>
              </tr>
            ) : (
              villages.map((v) => (
                <tr key={v.id} className="hover:bg-slate-50/70">
                  <td className="px-5 py-3.5 font-bold text-slate-800 flex items-center gap-1.5">
                    <MapPin className="w-3.5 h-3.5 text-brand-green" /> {v.name_mr}
                  </td>
                  <td className="px-5 py-3.5 text-slate-600">{v.name_en}</td>
                  <td className="px-5 py-3.5 text-slate-600">{v.taluka}</td>
                  <td className="px-5 py-3.5 text-slate-600">{v.district}</td>
                  <td className="px-5 py-3.5 text-slate-600">{v.pincode}</td>
                  <td className="px-5 py-3.5">
                    {v.is_active ? (
                      <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-100 text-emerald-800">
                        <Check className="w-3 h-3" /> सक्रिय
                      </span>
                    ) : (
                      <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-600">
                        <X className="w-3 h-3" /> निष्क्रिय
                      </span>
                    )}
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

