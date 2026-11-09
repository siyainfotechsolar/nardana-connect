import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { MarketplaceItem } from '../types/database';
import { ShoppingBag, CheckCircle, XCircle } from 'lucide-react';

export const Marketplace: React.FC = () => {
  const [items, setItems] = useState<MarketplaceItem[]>([]);
  const [loading, setLoading] = useState(true);

  async function fetchItems() {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('marketplace_items')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setItems(data || []);
    } catch (err) {
      console.error('Error fetching marketplace items:', err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchItems();
  }, []);

  async function updateStatus(id: string, newStatus: 'approved' | 'rejected') {
    try {
      const { error } = await supabase
        .from('marketplace_items')
        .update({ status: newStatus, updated_at: new Date().toISOString() })
        .eq('id', id);

      if (error) throw error;
      setItems(prev => prev.map(i => i.id === id ? { ...i, status: newStatus } : i));
    } catch (err) {
      console.error('Error updating marketplace status:', err);
    }
  }

  return (
    <div className="space-y-5">
      <div>
        <h2 className="text-xl font-bold text-slate-900">खरेदी - विक्री बाजारपेठ (Buy & Sell Marketplace)</h2>
        <p className="text-xs text-slate-500">गावकऱ्यांनी टाकलेल्या शेती अवजारे, वाहने, वस्तूंसाठी मंजुरी नियंत्रण</p>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
          <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
            <tr>
              <th className="px-5 py-3">वस्तूचे नाव (Item)</th>
              <th className="px-5 py-3">प्रवर्ग (Category)</th>
              <th className="px-5 py-3">किंमत (Price)</th>
              <th className="px-5 py-3">विक्रेता (Seller)</th>
              <th className="px-5 py-3">प्रकार (Type)</th>
              <th className="px-5 py-3">स्थिती</th>
              <th className="px-5 py-3 text-right">कृती</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {loading ? (
              <tr>
                <td colSpan={7} className="px-5 py-6 text-center text-slate-400">माहिती लोड होत आहे...</td>
              </tr>
            ) : items.length === 0 ? (
              <tr>
                <td colSpan={7} className="px-5 py-6 text-center text-slate-400">सध्या कोणत्याही वस्तू नाहीत.</td>
              </tr>
            ) : (
              items.map((item) => (
                <tr key={item.id} className="hover:bg-slate-50/70">
                  <td className="px-5 py-3.5 font-bold text-slate-800 flex items-center gap-1.5">
                    <ShoppingBag className="w-3.5 h-3.5 text-brand-green" /> {item.title}
                  </td>
                  <td className="px-5 py-3.5 text-slate-600">{item.category}</td>
                  <td className="px-5 py-3.5 font-bold text-brand-blue">₹{item.price.toLocaleString('en-IN')}</td>
                  <td className="px-5 py-3.5 text-slate-600">{item.seller_name} ({item.phone})</td>
                  <td className="px-5 py-3.5">
                    <span className={`px-2 py-0.5 rounded text-[11px] font-semibold ${
                      item.listing_type === 'SELL' ? 'bg-blue-100 text-blue-800' : 'bg-amber-100 text-amber-800'
                    }`}>
                      {item.listing_type === 'SELL' ? 'विक्री (Sell)' : 'हवे आहे (Wanted)'}
                    </span>
                  </td>
                  <td className="px-5 py-3.5">
                    <span className="px-2 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-100 text-emerald-800">
                      {item.status}
                    </span>
                  </td>
                  <td className="px-5 py-3.5 text-right space-x-1.5">
                    <button
                      onClick={() => updateStatus(item.id, 'approved')}
                      className="p-1 text-emerald-600 hover:bg-emerald-50 rounded"
                      title="मंजूर करा"
                    >
                      <CheckCircle className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => updateStatus(item.id, 'rejected')}
                      className="p-1 text-rose-600 hover:bg-rose-50 rounded"
                      title="नाकारा"
                    >
                      <XCircle className="w-4 h-4" />
                    </button>
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

