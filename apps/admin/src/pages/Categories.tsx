import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { Category } from '../types/database';
import { Layers, Plus, Check } from 'lucide-react';

export const Categories: React.FC = () => {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchCategories() {
      try {
        setLoading(true);
        const { data, error } = await supabase
          .from('categories')
          .select('*')
          .order('sort_order');

        if (error) throw error;
        setCategories(data || []);
      } catch (err) {
        console.error('Error fetching categories:', err);
      } finally {
        setLoading(false);
      }
    }

    fetchCategories();
  }, []);

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-bold text-slate-900">कॅटेगरी व्यवस्थापन (Categories)</h2>
          <p className="text-xs text-slate-500">घरगुती सेवा, दुकाने, शेती, वाहतूक, आरोग्य व शिक्षण प्रवर्ग</p>
        </div>
        <button className="flex items-center space-x-1.5 px-3.5 py-2 bg-brand-blue text-white rounded-lg text-xs font-semibold hover:bg-brand-dark transition shadow-sm">
          <Plus className="w-4 h-4" />
          <span>नवीन कॅटेगरी</span>
        </button>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
          <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
            <tr>
              <th className="px-5 py-3">कॅटेगरी (मराठी)</th>
              <th className="px-5 py-3">Category (English)</th>
              <th className="px-5 py-3">ग्रुप (Group Type)</th>
              <th className="px-5 py-3">आयकॉन (Icon)</th>
              <th className="px-5 py-3">क्रम (Sort Order)</th>
              <th className="px-5 py-3">स्थिती</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {loading ? (
              <tr>
                <td colSpan={6} className="px-5 py-6 text-center text-slate-400">माहिती लोड होत आहे...</td>
              </tr>
            ) : categories.length === 0 ? (
              <tr>
                <td colSpan={6} className="px-5 py-6 text-center text-slate-400">कॅटेगरी उपलब्ध नाहीत.</td>
              </tr>
            ) : (
              categories.map((c) => (
                <tr key={c.id} className="hover:bg-slate-50/70">
                  <td className="px-5 py-3.5 font-bold text-slate-800 flex items-center gap-1.5">
                    <Layers className="w-3.5 h-3.5 text-brand-blue" /> {c.name_mr}
                  </td>
                  <td className="px-5 py-3.5 text-slate-600">{c.name_en}</td>
                  <td className="px-5 py-3.5">
                    <span className="px-2 py-0.5 rounded text-[11px] font-medium bg-slate-100 text-slate-700">
                      {c.group_type}
                    </span>
                  </td>
                  <td className="px-5 py-3.5 text-slate-500 font-mono text-[11px]">{c.icon}</td>
                  <td className="px-5 py-3.5 text-slate-600">{c.sort_order}</td>
                  <td className="px-5 py-3.5">
                    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-100 text-emerald-800">
                      <Check className="w-3 h-3" /> सक्रिय
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

