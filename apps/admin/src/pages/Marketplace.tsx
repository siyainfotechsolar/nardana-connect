import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { MarketplaceItem, Village } from '../types/database';
import { 
  ShoppingBag, 
  CheckCircle, 
  XCircle, 
  Plus, 
  Search, 
  Trash2, 
  Eye, 
  X, 
  Phone 
} from 'lucide-react';
import { useToast } from '../components/Toast';

interface MarketplaceFormData {
  title: string;
  category: string;
  price: number;
  description: string;
  seller_name: string;
  phone: string;
  listing_type: 'SELL' | 'WANTED';
  village_id: string;
  status: 'pending' | 'approved' | 'rejected';
}

const defaultFormData: MarketplaceFormData = {
  title: '',
  category: 'शेती अवजारे (Farm Tools)',
  price: 0,
  description: '',
  seller_name: '',
  phone: '',
  listing_type: 'SELL',
  village_id: '',
  status: 'approved',
};

export const Marketplace: React.FC = () => {
  const [items, setItems] = useState<MarketplaceItem[]>([]);
  const [villages, setVillages] = useState<Village[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'pending' | 'approved' | 'sold'>('all');

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [viewingItem, setViewingItem] = useState<MarketplaceItem | null>(null);
  const [formData, setFormData] = useState<MarketplaceFormData>(defaultFormData);
  const [submitting, setSubmitting] = useState(false);

  const { showToast } = useToast();

  async function loadData() {
    try {
      setLoading(true);
      const [itemsRes, vilRes] = await Promise.all([
        supabase
          .from('marketplace_items')
          .select('*')
          .order('created_at', { ascending: false }),
        supabase
          .from('villages')
          .select('*')
          .eq('is_active', true)
          .order('name_mr'),
      ]);

      if (itemsRes.error) throw itemsRes.error;
      if (vilRes.error) throw vilRes.error;

      setItems(itemsRes.data || []);
      setVillages(vilRes.data || []);

      if (vilRes.data && vilRes.data.length > 0 && !formData.village_id) {
        defaultFormData.village_id = vilRes.data[0].id;
      }
    } catch (err: any) {
      console.error('Error fetching marketplace items:', err);
      showToast('बाजारपेठ लोड करताना त्रुटी: ' + (err.message || ''), 'error');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  function handleOpenAdd() {
    setFormData({
      ...defaultFormData,
      village_id: villages[0]?.id || '',
    });
    setIsModalOpen(true);
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!formData.title.trim() || !formData.seller_name.trim() || !formData.phone.trim()) {
      showToast('कृपया वस्तूचे नाव, विक्रेता व फोन नंबर भरा.', 'error');
      return;
    }

    try {
      setSubmitting(true);
      const { error } = await supabase
        .from('marketplace_items')
        .insert({
          title: formData.title.trim(),
          category: formData.category,
          price: Number(formData.price) || 0,
          description: formData.description.trim() || 'उत्तम स्थितीत उपलब्ध.',
          seller_name: formData.seller_name.trim(),
          phone: formData.phone.trim(),
          listing_type: formData.listing_type,
          village_id: formData.village_id || villages[0]?.id,
          status: formData.status,
          is_sold: false,
          images: [],
        });

      if (error) throw error;
      showToast('नवीन वस्तू बाजारपेठेत जोडली!', 'success');
      setIsModalOpen(false);
      loadData();
    } catch (err: any) {
      console.error('Save item error:', err);
      showToast('वस्तू सेव्ह करताना त्रुटी: ' + (err.message || ''), 'error');
    } finally {
      setSubmitting(false);
    }
  }

  async function updateStatus(id: string, newStatus: 'approved' | 'rejected') {
    try {
      const { error } = await supabase
        .from('marketplace_items')
        .update({ status: newStatus, updated_at: new Date().toISOString() })
        .eq('id', id);

      if (error) throw error;
      setItems(prev => prev.map(i => (i.id === id ? { ...i, status: newStatus } : i)));
      showToast(
        newStatus === 'approved' ? 'वस्तू मंजूर करण्यात आली!' : 'वस्तू नाकारली.',
        newStatus === 'approved' ? 'success' : 'info'
      );
    } catch (err: any) {
      console.error('Error updating marketplace status:', err);
      showToast('स्थिती बदलताना त्रुटी: ' + (err.message || ''), 'error');
    }
  }

  async function toggleSold(item: MarketplaceItem) {
    try {
      const nextSold = !item.is_sold;
      const { error } = await supabase
        .from('marketplace_items')
        .update({ is_sold: nextSold, updated_at: new Date().toISOString() })
        .eq('id', item.id);

      if (error) throw error;
      setItems(prev => prev.map(i => (i.id === item.id ? { ...i, is_sold: nextSold } : i)));
      showToast(nextSold ? 'विक्री झाली म्हणून चिन्हांकित केले.' : 'विक्रीसाठी उपलब्ध केले.', 'success');
    } catch (err: any) {
      showToast('स्थिती बदलताना त्रुटी: ' + err.message, 'error');
    }
  }

  async function handleDelete(item: MarketplaceItem) {
    if (!window.confirm(`तुम्हाला नक्की '${item.title}' ही वस्तू हटवायची आहे का?`)) {
      return;
    }

    try {
      const { error } = await supabase
        .from('marketplace_items')
        .delete()
        .eq('id', item.id);

      if (error) throw error;
      setItems(prev => prev.filter(i => i.id !== item.id));
      showToast('वस्तू यशस्वीपणे हटवली.', 'success');
    } catch (err: any) {
      showToast('हटवताना त्रुटी: ' + err.message, 'error');
    }
  }

  const filteredItems = items.filter((item) => {
    const matchesSearch =
      item.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.seller_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.phone.includes(searchTerm) ||
      item.category.toLowerCase().includes(searchTerm.toLowerCase());
    
    if (statusFilter === 'sold') {
      return matchesSearch && item.is_sold;
    }
    const matchesStatus = statusFilter === 'all' || item.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const pendingCount = items.filter(i => i.status === 'pending').length;

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h2 className="text-xl font-bold text-slate-900">खरेदी - विक्री बाजारपेठ (Marketplace)</h2>
          <p className="text-xs text-slate-500">
            गावकऱ्यांची शेती अवजारे, ट्रॅक्टर, वाहने, जनावरे व इतर वस्तूंसाठी मंजुरी नियंत्रण ({items.length} वस्तू)
          </p>
        </div>
        <button
          onClick={handleOpenAdd}
          className="flex items-center justify-center space-x-1.5 px-4 py-2.5 bg-brand-blue text-white rounded-lg text-xs font-semibold hover:bg-brand-dark transition shadow-sm active:scale-95"
        >
          <Plus className="w-4 h-4" />
          <span>नवीन वस्तू जोडा</span>
        </button>
      </div>

      {/* Filter Tabs & Search */}
      <div className="bg-white p-3.5 rounded-xl border border-slate-200 shadow-sm space-y-3">
        <div className="flex flex-wrap items-center gap-2 border-b border-slate-100 pb-3">
          <button
            onClick={() => setStatusFilter('all')}
            className={`px-3 py-1.5 rounded-lg text-xs font-medium transition ${
              statusFilter === 'all'
                ? 'bg-brand-blue text-white shadow-sm font-semibold'
                : 'text-slate-600 hover:bg-slate-100'
            }`}
          >
            सर्व ({items.length})
          </button>
          <button
            onClick={() => setStatusFilter('pending')}
            className={`px-3 py-1.5 rounded-lg text-xs font-medium transition flex items-center gap-1.5 ${
              statusFilter === 'pending'
                ? 'bg-amber-600 text-white shadow-sm font-semibold'
                : 'text-amber-800 bg-amber-50 hover:bg-amber-100'
            }`}
          >
            <span>प्रलंबित ({pendingCount})</span>
          </button>
          <button
            onClick={() => setStatusFilter('approved')}
            className={`px-3 py-1.5 rounded-lg text-xs font-medium transition ${
              statusFilter === 'approved'
                ? 'bg-emerald-600 text-white shadow-sm font-semibold'
                : 'text-emerald-800 bg-emerald-50 hover:bg-emerald-100'
            }`}
          >
            मंजूर (Approved)
          </button>
          <button
            onClick={() => setStatusFilter('sold')}
            className={`px-3 py-1.5 rounded-lg text-xs font-medium transition ${
              statusFilter === 'sold'
                ? 'bg-purple-600 text-white shadow-sm font-semibold'
                : 'text-purple-800 bg-purple-50 hover:bg-purple-100'
            }`}
          >
            विक्री झालेली (Sold)
          </button>
        </div>

        <div className="flex items-center gap-2">
          <Search className="w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="वस्तूचे नाव, विक्रेता, फोन किंवा प्रवर्ग शोधा..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full text-xs text-slate-800 placeholder-slate-400 focus:outline-none"
          />
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
            <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
              <tr>
                <th className="px-5 py-3">वस्तूचे नाव (Item)</th>
                <th className="px-5 py-3">प्रवर्ग</th>
                <th className="px-5 py-3">किंमत (Price)</th>
                <th className="px-5 py-3">विक्रेता व संपर्क</th>
                <th className="px-5 py-3">प्रकार</th>
                <th className="px-5 py-3">स्थिती</th>
                <th className="px-5 py-3 text-right">कृती</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {loading ? (
                <tr>
                  <td colSpan={7} className="px-5 py-8 text-center text-slate-400">माहिती लोड होत आहे...</td>
                </tr>
              ) : filteredItems.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-5 py-8 text-center text-slate-400">
                    कोणत्याही वस्तू सापडल्या नाहीत.
                  </td>
                </tr>
              ) : (
                filteredItems.map((item) => (
                  <tr key={item.id} className="hover:bg-slate-50/70 transition">
                    <td className="px-5 py-3.5 font-bold text-slate-800 flex items-center gap-1.5">
                      <ShoppingBag className="w-3.5 h-3.5 text-brand-green flex-shrink-0" />
                      <span>{item.title}</span>
                    </td>
                    <td className="px-5 py-3.5 text-slate-600">{item.category}</td>
                    <td className="px-5 py-3.5 font-bold text-brand-blue">
                      ₹{Number(item.price).toLocaleString('en-IN')}
                    </td>
                    <td className="px-5 py-3.5 text-slate-600">
                      <p className="font-medium text-slate-800">{item.seller_name}</p>
                      <p className="text-[11px] text-slate-500 font-mono flex items-center gap-1">
                        <Phone className="w-2.5 h-2.5 text-brand-green" /> {item.phone}
                      </p>
                    </td>
                    <td className="px-5 py-3.5">
                      <span className={`px-2 py-0.5 rounded text-[11px] font-semibold ${
                        item.listing_type === 'SELL' ? 'bg-blue-100 text-blue-800' : 'bg-amber-100 text-amber-800'
                      }`}>
                        {item.listing_type === 'SELL' ? 'विक्री (Sell)' : 'हवे आहे (Wanted)'}
                      </span>
                    </td>
                    <td className="px-5 py-3.5">
                      {item.is_sold ? (
                        <span className="px-2 py-0.5 rounded-full text-[11px] font-semibold bg-purple-100 text-purple-800">
                          विक्री झाली
                        </span>
                      ) : item.status === 'approved' ? (
                        <span className="px-2 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-100 text-emerald-800">
                          मंजूर
                        </span>
                      ) : item.status === 'pending' ? (
                        <span className="px-2 py-0.5 rounded-full text-[11px] font-semibold bg-amber-100 text-amber-800">
                          प्रलंबित
                        </span>
                      ) : (
                        <span className="px-2 py-0.5 rounded-full text-[11px] font-semibold bg-rose-100 text-rose-800">
                          नाकारले
                        </span>
                      )}
                    </td>
                    <td className="px-5 py-3.5 text-right space-x-1">
                      {item.status !== 'approved' && (
                        <button
                          onClick={() => updateStatus(item.id, 'approved')}
                          className="px-2 py-1 text-emerald-700 bg-emerald-50 hover:bg-emerald-100 rounded text-[11px] font-semibold inline-flex items-center gap-1 transition"
                          title="मंजूर करा"
                        >
                          <CheckCircle className="w-3 h-3" /> मंजूर
                        </button>
                      )}
                      {item.status !== 'rejected' && (
                        <button
                          onClick={() => updateStatus(item.id, 'rejected')}
                          className="px-2 py-1 text-rose-700 bg-rose-50 hover:bg-rose-100 rounded text-[11px] font-semibold inline-flex items-center gap-1 transition"
                          title="नाकारा"
                        >
                          <XCircle className="w-3 h-3" /> नाकारा
                        </button>
                      )}
                      <button
                        onClick={() => toggleSold(item)}
                        className={`px-2 py-1 rounded text-[11px] font-medium transition ${
                          item.is_sold
                            ? 'text-purple-700 bg-purple-50 hover:bg-purple-100'
                            : 'text-slate-600 bg-slate-100 hover:bg-slate-200'
                        }`}
                        title="विक्री स्थिती बदला"
                      >
                        {item.is_sold ? 'पुन्हा विका' : 'विकले'}
                      </button>
                      <button
                        onClick={() => setViewingItem(item)}
                        className="p-1.5 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded transition"
                        title="तपशील"
                      >
                        <Eye className="w-3.5 h-3.5" />
                      </button>
                      <button
                        onClick={() => handleDelete(item)}
                        className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded transition"
                        title="हटवा"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add Item Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-lg w-full max-h-[90vh] overflow-y-auto shadow-2xl border border-slate-200">
            <div className="px-6 py-4 bg-slate-50 border-b border-slate-200 flex items-center justify-between sticky top-0 bg-slate-50 z-10">
              <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
                <ShoppingBag className="w-4 h-4 text-brand-green" /> नवीन वस्तू बाजारपेठेत जोडा
              </h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1 rounded"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="p-6 space-y-4 text-xs">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    वस्तूचे नाव <span className="text-rose-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="उदा. महिंद्रा ट्रॅक्टर 475 DI"
                    value={formData.title}
                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">प्रवर्ग (Category)</label>
                  <select
                    value={formData.category}
                    onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs bg-white"
                  >
                    <option value="शेती अवजारे (Farm Tools)">शेती अवजारे (Farm Tools)</option>
                    <option value="ट्रॅक्टर व वाहने (Vehicles)">ट्रॅक्टर व वाहने (Vehicles)</option>
                    <option value="जनावरे व पशुधन (Livestock)">जनावरे व पशुधन (Livestock)</option>
                    <option value="बियाणे व खते (Seeds & Fertilizer)">बियाणे व खते (Seeds & Fertilizer)</option>
                    <option value="इलेक्ट्रॉनिक्स व इतर (General Items)">इलेक्ट्रॉनिक्स व इतर (General Items)</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    किंमत (₹) <span className="text-rose-500">*</span>
                  </label>
                  <input
                    type="number"
                    required
                    placeholder="उदा. 250000"
                    value={formData.price}
                    onChange={(e) => setFormData({ ...formData, price: Number(e.target.value) })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">प्रकार</label>
                  <select
                    value={formData.listing_type}
                    onChange={(e) => setFormData({ ...formData, listing_type: e.target.value as any })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs bg-white"
                  >
                    <option value="SELL">विक्रीसाठी (Sell)</option>
                    <option value="WANTED">हवे आहे (Wanted)</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    विक्रेत्याचे नाव <span className="text-rose-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="उदा. ज्ञानेश्वर पाटील"
                    value={formData.seller_name}
                    onChange={(e) => setFormData({ ...formData, seller_name: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    संपर्क फोन नंबर <span className="text-rose-500">*</span>
                  </label>
                  <input
                    type="tel"
                    required
                    placeholder="उदा. 9876543210"
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                  />
                </div>
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">वस्तूचे वर्णन</label>
                <textarea
                  rows={2}
                  placeholder="मॉडेल, स्थिती, किंवा किंमतीबाबत तपशील..."
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                />
              </div>

              <div className="flex justify-end gap-2 pt-4 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 border border-slate-200 text-slate-600 rounded-lg hover:bg-slate-50 font-medium"
                >
                  रद्द करा
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className="px-4 py-2 bg-brand-blue text-white rounded-lg hover:bg-brand-dark font-semibold disabled:opacity-50"
                >
                  {submitting ? 'जतन करत आहे...' : 'वस्तू जोडा'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* View Modal */}
      {viewingItem && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-md w-full shadow-2xl overflow-hidden border border-slate-200 p-6 space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <h3 className="font-bold text-base text-slate-900 flex items-center gap-2">
                <ShoppingBag className="w-5 h-5 text-brand-green" />
                {viewingItem.title}
              </h3>
              <button
                onClick={() => setViewingItem(null)}
                className="text-slate-400 hover:text-slate-600 p-1 rounded"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-2 text-xs text-slate-700">
              <p><strong>प्रवर्ग:</strong> {viewingItem.category}</p>
              <p><strong>किंमत:</strong> ₹{Number(viewingItem.price).toLocaleString('en-IN')}</p>
              <p><strong>विक्रेता:</strong> {viewingItem.seller_name}</p>
              <p><strong>फोन:</strong> {viewingItem.phone}</p>
              <p><strong>प्रकार:</strong> {viewingItem.listing_type === 'SELL' ? 'विक्री (Sell)' : 'हवे आहे (Wanted)'}</p>
              <p><strong>वर्णन:</strong> {viewingItem.description}</p>
              <p>
                <strong>स्थिती:</strong>{' '}
                <span className={`px-2 py-0.5 rounded font-bold ${
                  viewingItem.is_sold ? 'bg-purple-100 text-purple-800' :
                  viewingItem.status === 'approved' ? 'bg-emerald-100 text-emerald-800' :
                  'bg-amber-100 text-amber-800'
                }`}>
                  {viewingItem.is_sold ? 'विक्री झाली (Sold)' : viewingItem.status}
                </span>
              </p>
            </div>

            <div className="flex justify-end gap-2 pt-3 border-t border-slate-100">
              <button
                onClick={() => setViewingItem(null)}
                className="px-4 py-2 bg-slate-100 text-slate-700 rounded-lg hover:bg-slate-200 text-xs font-semibold"
              >
                बंद करा
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
