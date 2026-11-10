import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { Business, Village, Category } from '../types/database';
import { 
  Store, 
  Phone, 
  MessageSquare, 
  CheckCircle, 
  XCircle, 
  Plus, 
  Search, 
  Filter, 
  Trash2, 
  Edit2, 
  MapPin, 
  Eye, 
  X 
} from 'lucide-react';
import { useToast } from '../components/Toast';

interface BusinessFormData {
  business_name_mr: string;
  business_name_en: string;
  owner_name: string;
  phone: string;
  whatsapp: string;
  village_id: string;
  category_id: string;
  address: string;
  description: string;
  opening_hours: string;
  status: 'pending' | 'approved' | 'rejected';
}

const defaultFormData: BusinessFormData = {
  business_name_mr: '',
  business_name_en: '',
  owner_name: '',
  phone: '',
  whatsapp: '',
  village_id: '',
  category_id: '',
  address: '',
  description: '',
  opening_hours: 'सकाळी ९:०० ते रात्री ८:००',
  status: 'approved',
};

export const Businesses: React.FC = () => {
  const [businesses, setBusinesses] = useState<Business[]>([]);
  const [villages, setVillages] = useState<Village[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);

  // Filters
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'pending' | 'approved' | 'rejected'>('all');
  const [villageFilter, setVillageFilter] = useState<string>('all');
  const [categoryFilter, setCategoryFilter] = useState<string>('all');

  // Modals
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [viewingBusiness, setViewingBusiness] = useState<Business | null>(null);
  const [editingBusiness, setEditingBusiness] = useState<Business | null>(null);
  const [formData, setFormData] = useState<BusinessFormData>(defaultFormData);
  const [submitting, setSubmitting] = useState(false);

  const { showToast } = useToast();

  async function loadData() {
    try {
      setLoading(true);
      const [bizRes, vilRes, catRes] = await Promise.all([
        supabase
          .from('businesses')
          .select('*')
          .order('created_at', { ascending: false }),
        supabase
          .from('villages')
          .select('*')
          .eq('is_active', true)
          .order('name_mr'),
        supabase
          .from('categories')
          .select('*')
          .eq('is_active', true)
          .order('sort_order'),
      ]);

      if (bizRes.error) throw bizRes.error;
      if (vilRes.error) throw vilRes.error;
      if (catRes.error) throw catRes.error;

      setBusinesses(bizRes.data || []);
      setVillages(vilRes.data || []);
      setCategories(catRes.data || []);

      if (vilRes.data && vilRes.data.length > 0 && !formData.village_id) {
        defaultFormData.village_id = vilRes.data[0].id;
      }
      if (catRes.data && catRes.data.length > 0 && !formData.category_id) {
        defaultFormData.category_id = catRes.data[0].id;
      }
    } catch (err: any) {
      console.error('Error fetching businesses data:', err);
      showToast('माहिती लोड करताना त्रुटी: ' + (err.message || ''), 'error');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  function handleOpenAdd() {
    setEditingBusiness(null);
    setFormData({
      ...defaultFormData,
      village_id: villages[0]?.id || '',
      category_id: categories[0]?.id || '',
    });
    setIsModalOpen(true);
  }

  function handleOpenEdit(b: Business) {
    setEditingBusiness(b);
    setFormData({
      business_name_mr: b.business_name_mr,
      business_name_en: b.business_name_en,
      owner_name: b.owner_name,
      phone: b.phone,
      whatsapp: b.whatsapp || '',
      village_id: b.village_id,
      category_id: b.category_id,
      address: b.address,
      description: b.description || '',
      opening_hours: (b as any).opening_hours || 'सकाळी ९:०० ते रात्री ८:००',
      status: b.status,
    });
    setIsModalOpen(true);
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!formData.business_name_mr.trim() || !formData.phone.trim()) {
      showToast('कृपया व्यवसायाचे नाव व फोन नंबर प्रविष्ट करा.', 'error');
      return;
    }

    try {
      setSubmitting(true);
      if (editingBusiness) {
        const { error } = await supabase
          .from('businesses')
          .update({
            business_name_mr: formData.business_name_mr.trim(),
            business_name_en: formData.business_name_en.trim() || formData.business_name_mr.trim(),
            owner_name: formData.owner_name.trim(),
            phone: formData.phone.trim(),
            whatsapp: formData.whatsapp.trim() || formData.phone.trim(),
            village_id: formData.village_id,
            category_id: formData.category_id,
            address: formData.address.trim(),
            description: formData.description.trim(),
            opening_hours: formData.opening_hours.trim(),
            status: formData.status,
            updated_at: new Date().toISOString(),
          })
          .eq('id', editingBusiness.id);

        if (error) throw error;
        showToast('व्यवसायाची माहिती यशस्वीपणे अपडेट झाली!', 'success');
      } else {
        const { error } = await supabase
          .from('businesses')
          .insert({
            business_name_mr: formData.business_name_mr.trim(),
            business_name_en: formData.business_name_en.trim() || formData.business_name_mr.trim(),
            owner_name: formData.owner_name.trim(),
            phone: formData.phone.trim(),
            whatsapp: formData.whatsapp.trim() || formData.phone.trim(),
            village_id: formData.village_id,
            category_id: formData.category_id,
            address: formData.address.trim(),
            description: formData.description.trim(),
            opening_hours: formData.opening_hours.trim(),
            status: formData.status,
            photos: [],
          });

        if (error) throw error;
        showToast('नवीन व्यवसाय यशस्वीपणे जोडला!', 'success');
      }

      setIsModalOpen(false);
      loadData();
    } catch (err: any) {
      console.error('Error saving business:', err);
      showToast('व्यवसाय जतन करताना त्रुटी: ' + (err.message || ''), 'error');
    } finally {
      setSubmitting(false);
    }
  }

  async function updateStatus(id: string, newStatus: 'approved' | 'rejected') {
    try {
      const { error } = await supabase
        .from('businesses')
        .update({ status: newStatus, updated_at: new Date().toISOString() })
        .eq('id', id);

      if (error) throw error;

      setBusinesses(prev =>
        prev.map(b => (b.id === id ? { ...b, status: newStatus } : b))
      );
      showToast(
        newStatus === 'approved' ? 'व्यवसाय मंजूर (Approved) करण्यात आला!' : 'व्यवसाय नाकारला (Rejected).',
        newStatus === 'approved' ? 'success' : 'info'
      );
    } catch (err: any) {
      console.error('Error updating business status:', err);
      showToast('स्थिती बदलण्यात अयशस्वी: ' + (err.message || ''), 'error');
    }
  }

  async function handleDelete(b: Business) {
    if (!window.confirm(`तुम्हाला नक्की '${b.business_name_mr}' हा व्यवसाय हटवायचा आहे का?`)) {
      return;
    }

    try {
      const { error } = await supabase
        .from('businesses')
        .delete()
        .eq('id', b.id);

      if (error) throw error;
      setBusinesses(prev => prev.filter(x => x.id !== b.id));
      showToast('व्यवसाय यशस्वीपणे हटवला.', 'success');
    } catch (err: any) {
      showToast('व्यवसाय हटवताना त्रुटी: ' + err.message, 'error');
    }
  }

  const getVillageName = (vid: string) => {
    return villages.find(v => v.id === vid)?.name_mr || 'गाव';
  };

  const getCategoryName = (cid: string) => {
    return categories.find(c => c.id === cid)?.name_mr || 'कॅटेगरी';
  };

  const filteredBusinesses = businesses.filter((b) => {
    const matchesSearch =
      b.business_name_mr.toLowerCase().includes(searchTerm.toLowerCase()) ||
      b.business_name_en.toLowerCase().includes(searchTerm.toLowerCase()) ||
      b.owner_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      b.phone.includes(searchTerm);
    const matchesStatus = statusFilter === 'all' || b.status === statusFilter;
    const matchesVillage = villageFilter === 'all' || b.village_id === villageFilter;
    const matchesCategory = categoryFilter === 'all' || b.category_id === categoryFilter;

    return matchesSearch && matchesStatus && matchesVillage && matchesCategory;
  });

  const pendingCount = businesses.filter(b => b.status === 'pending').length;

  return (
    <div className="space-y-5">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h2 className="text-xl font-bold text-slate-900">स्थानिक व्यवसाय व सेवा (Businesses & Services)</h2>
          <p className="text-xs text-slate-500">
            स्थानिक दुकाने, तंत्रज्ञ व सेवांची नोंदणी, मंजुरी आणि व्यवस्थापन (एकूण: {businesses.length})
          </p>
        </div>
        <button
          onClick={handleOpenAdd}
          className="flex items-center justify-center space-x-1.5 px-4 py-2.5 bg-brand-blue text-white rounded-lg text-xs font-semibold hover:bg-brand-dark transition shadow-sm active:scale-95"
        >
          <Plus className="w-4 h-4" />
          <span>नवीन व्यवसाय जोडा</span>
        </button>
      </div>

      {/* Filter Tabs & Search */}
      <div className="bg-white p-3.5 rounded-xl border border-slate-200 shadow-sm space-y-3">
        {/* Status Pills */}
        <div className="flex flex-wrap items-center gap-2 border-b border-slate-100 pb-3">
          <button
            onClick={() => setStatusFilter('all')}
            className={`px-3 py-1.5 rounded-lg text-xs font-medium transition ${
              statusFilter === 'all'
                ? 'bg-brand-blue text-white shadow-sm font-semibold'
                : 'text-slate-600 hover:bg-slate-100'
            }`}
          >
            सर्व ({businesses.length})
          </button>
          <button
            onClick={() => setStatusFilter('pending')}
            className={`px-3 py-1.5 rounded-lg text-xs font-medium transition flex items-center gap-1.5 ${
              statusFilter === 'pending'
                ? 'bg-amber-600 text-white shadow-sm font-semibold'
                : 'text-amber-800 bg-amber-50 hover:bg-amber-100'
            }`}
          >
            <span>प्रलंबित मंजुऱ्या (Pending)</span>
            {pendingCount > 0 && (
              <span className="px-1.5 py-0.2 rounded-full text-[10px] bg-amber-200 text-amber-900 font-bold">
                {pendingCount}
              </span>
            )}
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
            onClick={() => setStatusFilter('rejected')}
            className={`px-3 py-1.5 rounded-lg text-xs font-medium transition ${
              statusFilter === 'rejected'
                ? 'bg-rose-600 text-white shadow-sm font-semibold'
                : 'text-rose-800 bg-rose-50 hover:bg-rose-100'
            }`}
          >
            नाकारलेले (Rejected)
          </button>
        </div>

        {/* Search & Village/Category Dropdowns */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <div className="flex items-center gap-2 border border-slate-200 rounded-lg px-3 py-2 bg-slate-50/50">
            <Search className="w-4 h-4 text-slate-400 flex-shrink-0" />
            <input
              type="text"
              placeholder="व्यवसाय, मालक किंवा फोन शोधा..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full text-xs text-slate-800 bg-transparent placeholder-slate-400 focus:outline-none"
            />
          </div>

          <div className="flex items-center gap-2">
            <MapPin className="w-4 h-4 text-slate-400 flex-shrink-0" />
            <select
              value={villageFilter}
              onChange={(e) => setVillageFilter(e.target.value)}
              className="w-full text-xs border border-slate-200 rounded-lg px-2.5 py-2 bg-white text-slate-700 focus:outline-none"
            >
              <option value="all">सर्व गावे (All Villages)</option>
              {villages.map((v) => (
                <option key={v.id} value={v.id}>
                  {v.name_mr} ({v.name_en})
                </option>
              ))}
            </select>
          </div>

          <div className="flex items-center gap-2">
            <Filter className="w-4 h-4 text-slate-400 flex-shrink-0" />
            <select
              value={categoryFilter}
              onChange={(e) => setCategoryFilter(e.target.value)}
              className="w-full text-xs border border-slate-200 rounded-lg px-2.5 py-2 bg-white text-slate-700 focus:outline-none"
            >
              <option value="all">सर्व कॅटेगरी (All Categories)</option>
              {categories.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name_mr}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Businesses Table */}
      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
            <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
              <tr>
                <th className="px-5 py-3">व्यवसायाचे नाव (Business Name)</th>
                <th className="px-5 py-3">गाव / कॅटेगरी</th>
                <th className="px-5 py-3">मालक (Owner)</th>
                <th className="px-5 py-3">संपर्क (Phone)</th>
                <th className="px-5 py-3">स्थिती</th>
                <th className="px-5 py-3 text-right">मंजुरी व कृती</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {loading ? (
                <tr>
                  <td colSpan={6} className="px-5 py-8 text-center text-slate-400">माहिती लोड होत आहे...</td>
                </tr>
              ) : filteredBusinesses.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-5 py-8 text-center text-slate-400">
                    कोणतेही व्यवसाय सापडले नाहीत.
                  </td>
                </tr>
              ) : (
                filteredBusinesses.map((b) => (
                  <tr key={b.id} className="hover:bg-slate-50/70 transition">
                    <td className="px-5 py-3.5">
                      <p className="font-bold text-slate-800 flex items-center gap-1.5">
                        <Store className="w-3.5 h-3.5 text-brand-blue flex-shrink-0" />
                        <span>{b.business_name_mr}</span>
                      </p>
                      <p className="text-[11px] text-slate-500">{b.business_name_en}</p>
                    </td>
                    <td className="px-5 py-3.5">
                      <p className="font-medium text-slate-700 flex items-center gap-1">
                        <MapPin className="w-3 h-3 text-brand-green" /> {getVillageName(b.village_id)}
                      </p>
                      <p className="text-[11px] text-slate-500">{getCategoryName(b.category_id)}</p>
                    </td>
                    <td className="px-5 py-3.5 text-slate-700 font-medium">{b.owner_name}</td>
                    <td className="px-5 py-3.5 text-slate-600">
                      <div className="flex items-center gap-1">
                        <Phone className="w-3 h-3 text-brand-green" /> {b.phone}
                      </div>
                      {b.whatsapp && (
                        <div className="flex items-center gap-1 text-[11px] text-emerald-600">
                          <MessageSquare className="w-2.5 h-2.5" /> WA: {b.whatsapp}
                        </div>
                      )}
                    </td>
                    <td className="px-5 py-3.5">
                      {b.status === 'approved' && (
                        <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-emerald-100 text-emerald-800">
                          <CheckCircle className="w-3 h-3" /> मंजूर
                        </span>
                      )}
                      {b.status === 'pending' && (
                        <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-amber-100 text-amber-800">
                          प्रलंबित
                        </span>
                      )}
                      {b.status === 'rejected' && (
                        <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-rose-100 text-rose-800">
                          <XCircle className="w-3 h-3" /> नाकारले
                        </span>
                      )}
                    </td>
                    <td className="px-5 py-3.5 text-right space-x-1">
                      {b.status !== 'approved' && (
                        <button
                          onClick={() => updateStatus(b.id, 'approved')}
                          className="px-2 py-1 text-emerald-700 bg-emerald-50 hover:bg-emerald-100 rounded text-[11px] font-semibold inline-flex items-center gap-1 transition"
                          title="मंजूर करा"
                        >
                          <CheckCircle className="w-3 h-3" /> मंजूर करा
                        </button>
                      )}
                      {b.status !== 'rejected' && (
                        <button
                          onClick={() => updateStatus(b.id, 'rejected')}
                          className="px-2 py-1 text-rose-700 bg-rose-50 hover:bg-rose-100 rounded text-[11px] font-semibold inline-flex items-center gap-1 transition"
                          title="नाकारा"
                        >
                          <XCircle className="w-3 h-3" /> नाकारा
                        </button>
                      )}
                      <button
                        onClick={() => setViewingBusiness(b)}
                        className="p-1.5 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded transition"
                        title="तपशील पहा"
                      >
                        <Eye className="w-3.5 h-3.5" />
                      </button>
                      <button
                        onClick={() => handleOpenEdit(b)}
                        className="p-1.5 text-slate-500 hover:text-brand-blue hover:bg-blue-50 rounded transition"
                        title="संपादित करा"
                      >
                        <Edit2 className="w-3.5 h-3.5" />
                      </button>
                      <button
                        onClick={() => handleDelete(b)}
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

      {/* Add / Edit Business Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-lg w-full max-h-[90vh] overflow-y-auto shadow-2xl border border-slate-200">
            <div className="px-6 py-4 bg-slate-50 border-b border-slate-200 flex items-center justify-between sticky top-0 bg-slate-50 z-10">
              <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
                <Store className="w-4 h-4 text-brand-blue" />
                {editingBusiness ? 'व्यवसाय संपादित करा' : 'नवीन व्यवसाय नोंदवा'}
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
                    व्यवसायाचे नाव (मराठी) <span className="text-rose-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="उदा. जय भवानी मेडिकल"
                    value={formData.business_name_mr}
                    onChange={(e) => setFormData({ ...formData, business_name_mr: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">नाव (English)</label>
                  <input
                    type="text"
                    placeholder="e.g. Jai Bhavani Medical"
                    value={formData.business_name_en}
                    onChange={(e) => setFormData({ ...formData, business_name_en: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    गाव निवडा <span className="text-rose-500">*</span>
                  </label>
                  <select
                    value={formData.village_id}
                    onChange={(e) => setFormData({ ...formData, village_id: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs bg-white"
                  >
                    {villages.map((v) => (
                      <option key={v.id} value={v.id}>
                        {v.name_mr} ({v.name_en})
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    कॅटेगरी निवडा <span className="text-rose-500">*</span>
                  </label>
                  <select
                    value={formData.category_id}
                    onChange={(e) => setFormData({ ...formData, category_id: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs bg-white"
                  >
                    {categories.map((c) => (
                      <option key={c.id} value={c.id}>
                        {c.name_mr}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    मालकाचे नाव <span className="text-rose-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="उदा. राहुल पाटील"
                    value={formData.owner_name}
                    onChange={(e) => setFormData({ ...formData, owner_name: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    फोन नंबर <span className="text-rose-500">*</span>
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

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">WhatsApp नंबर</label>
                  <input
                    type="tel"
                    placeholder="रिकामे ठेवल्यास फोन नंबर वापरेल"
                    value={formData.whatsapp}
                    onChange={(e) => setFormData({ ...formData, whatsapp: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">कामाची वेळ</label>
                  <input
                    type="text"
                    value={formData.opening_hours}
                    onChange={(e) => setFormData({ ...formData, opening_hours: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                  />
                </div>
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">पत्ता (Address)</label>
                <input
                  type="text"
                  placeholder="उदा. मुख्य बाजारपेठ, ग्रामपंचायत शेजारी, नरडाणा"
                  value={formData.address}
                  onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">तपशील व सेवा वर्णन</label>
                <textarea
                  rows={2}
                  placeholder="उपलब्ध उत्पादने किंवा सेवांबद्दल माहिती..."
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">स्थिती (Status)</label>
                <select
                  value={formData.status}
                  onChange={(e) => setFormData({ ...formData, status: e.target.value as any })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs bg-white font-medium"
                >
                  <option value="approved">मंजूर (Approved - ॲपमध्ये तत्काळ दिसेल)</option>
                  <option value="pending">प्रलंबित (Pending Review)</option>
                  <option value="rejected">नाकारले (Rejected)</option>
                </select>
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
                  {submitting ? 'जतन करत आहे...' : editingBusiness ? 'बदल सेव्ह करा' : 'व्यवसाय जोडा'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* View Business Details Modal */}
      {viewingBusiness && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-md w-full shadow-2xl overflow-hidden border border-slate-200 p-6 space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <h3 className="font-bold text-base text-slate-900 flex items-center gap-2">
                <Store className="w-5 h-5 text-brand-blue" />
                {viewingBusiness.business_name_mr}
              </h3>
              <button
                onClick={() => setViewingBusiness(null)}
                className="text-slate-400 hover:text-slate-600 p-1 rounded"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-2 text-xs text-slate-700">
              <p><strong>इंग्रजी नाव:</strong> {viewingBusiness.business_name_en}</p>
              <p><strong>गाव:</strong> {getVillageName(viewingBusiness.village_id)}</p>
              <p><strong>कॅटेगरी:</strong> {getCategoryName(viewingBusiness.category_id)}</p>
              <p><strong>मालक:</strong> {viewingBusiness.owner_name}</p>
              <p><strong>फोन:</strong> {viewingBusiness.phone}</p>
              {viewingBusiness.whatsapp && (
                <p><strong>WhatsApp:</strong> {viewingBusiness.whatsapp}</p>
              )}
              <p><strong>पत्ता:</strong> {viewingBusiness.address}</p>
              {viewingBusiness.description && (
                <p><strong>माहिती:</strong> {viewingBusiness.description}</p>
              )}
              <p>
                <strong>स्थिती:</strong>{' '}
                <span className={`px-2 py-0.5 rounded font-bold ${
                  viewingBusiness.status === 'approved' ? 'bg-emerald-100 text-emerald-800' :
                  viewingBusiness.status === 'pending' ? 'bg-amber-100 text-amber-800' :
                  'bg-rose-100 text-rose-800'
                }`}>
                  {viewingBusiness.status}
                </span>
              </p>
            </div>

            <div className="flex justify-end gap-2 pt-3 border-t border-slate-100">
              <button
                onClick={() => setViewingBusiness(null)}
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
