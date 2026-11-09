import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { Business } from '../types/database';
import { Store, Phone, CheckCircle, XCircle } from 'lucide-react';

export const Businesses: React.FC = () => {
  const [businesses, setBusinesses] = useState<Business[]>([]);
  const [loading, setLoading] = useState(true);

  async function fetchBusinesses() {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('businesses')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setBusinesses(data || []);
    } catch (err) {
      console.error('Error fetching businesses:', err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchBusinesses();
  }, []);

  async function updateStatus(id: string, newStatus: 'approved' | 'rejected') {
    try {
      const { error } = await supabase
        .from('businesses')
        .update({ status: newStatus, updated_at: new Date().toISOString() })
        .eq('id', id);

      if (error) throw error;
      setBusinesses(prev => prev.map(b => b.id === id ? { ...b, status: newStatus } : b));
    } catch (err) {
      console.error('Error updating business status:', err);
    }
  }

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-bold text-slate-900">स्थानिक व्यवसाय व सेवा (Businesses & Services)</h2>
          <p className="text-xs text-slate-500">नागरिकांनी नोंदणी केलेले व्यवसाय, दुकाने आणि सेवांची यादी व मंजुरी</p>
        </div>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
          <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
            <tr>
              <th className="px-5 py-3">व्यवसायाचे नाव (Business Name)</th>
              <th className="px-5 py-3">मालकाचे नाव (Owner)</th>
              <th className="px-5 py-3">संपर्क (Phone / WhatsApp)</th>
              <th className="px-5 py-3">पत्ता (Address)</th>
              <th className="px-5 py-3">स्थिती (Status)</th>
              <th className="px-5 py-3 text-right">कृती (Actions)</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {loading ? (
              <tr>
                <td colSpan={6} className="px-5 py-6 text-center text-slate-400">माहिती लोड होत आहे...</td>
              </tr>
            ) : businesses.length === 0 ? (
              <tr>
                <td colSpan={6} className="px-5 py-6 text-center text-slate-400">कोणतेही व्यवसाय नोंदणीकृत नाहीत.</td>
              </tr>
            ) : (
              businesses.map((b) => (
                <tr key={b.id} className="hover:bg-slate-50/70">
                  <td className="px-5 py-3.5">
                    <p className="font-bold text-slate-800 flex items-center gap-1.5">
                      <Store className="w-3.5 h-3.5 text-brand-blue" /> {b.business_name_mr}
                    </p>
                    <p className="text-[11px] text-slate-500">{b.business_name_en}</p>
                  </td>
                  <td className="px-5 py-3.5 text-slate-700 font-medium">{b.owner_name}</td>
                  <td className="px-5 py-3.5 text-slate-600">
                    <div className="flex items-center gap-1">
                      <Phone className="w-3 h-3 text-brand-green" /> {b.phone}
                    </div>
                  </td>
                  <td className="px-5 py-3.5 text-slate-600 max-w-xs truncate">{b.address}</td>
                  <td className="px-5 py-3.5">
                    {b.status === 'approved' && (
                      <span className="px-2 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-100 text-emerald-800">
                        मंजूर (Approved)
                      </span>
                    )}
                    {b.status === 'pending' && (
                      <span className="px-2 py-0.5 rounded-full text-[11px] font-semibold bg-amber-100 text-amber-800">
                        प्रलंबित (Pending)
                      </span>
                    )}
                    {b.status === 'rejected' && (
                      <span className="px-2 py-0.5 rounded-full text-[11px] font-semibold bg-rose-100 text-rose-800">
                        नाकारले (Rejected)
                      </span>
                    )}
                  </td>
                  <td className="px-5 py-3.5 text-right space-x-1.5">
                    {b.status !== 'approved' && (
                      <button
                        onClick={() => updateStatus(b.id, 'approved')}
                        className="p-1 text-emerald-600 hover:bg-emerald-50 rounded"
                        title="मंजूर करा"
                      >
                        <CheckCircle className="w-4 h-4" />
                      </button>
                    )}
                    {b.status !== 'rejected' && (
                      <button
                        onClick={() => updateStatus(b.id, 'rejected')}
                        className="p-1 text-rose-600 hover:bg-rose-50 rounded"
                        title="नाकारा"
                      >
                        <XCircle className="w-4 h-4" />
                      </button>
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

