import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { Business, Category } from '../types/database';
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
  Clock,
  X,
  Crosshair,
  ExternalLink,
  AlertTriangle,
  Compass,
  Navigation
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
  latitude: number | null;
  longitude: number | null;
  location_accuracy_meters: number | null;
  location_captured_at: string | null;
  location_confirmed: boolean;
}

const defaultFormData: BusinessFormData = {
  business_name_mr: '',
  business_name_en: '',
  owner_name: '',
  phone: '',
  whatsapp: '',
  village_id: 'a0000000-0000-0000-0000-000000000001',
  category_id: '',
  address: '',
  description: '',
  opening_hours: 'सकाळी ९:०० ते रात्री ८:००',
  status: 'approved',
  latitude: null,
  longitude: null,
  location_accuracy_meters: null,
  location_captured_at: null,
  location_confirmed: false,
};

export const Businesses: React.FC = () => {
  const [businesses, setBusinesses] = useState<Business[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);

  // Filters
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'pending' | 'approved' | 'rejected'>('all');
  const [categoryFilter, setCategoryFilter] = useState<string>('all');

  // Modals
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [viewingBusiness, setViewingBusiness] = useState<Business | null>(null);
  const [editingBusiness, setEditingBusiness] = useState<Business | null>(null);
  const [formData, setFormData] = useState<BusinessFormData>(defaultFormData);
  const [submitting, setSubmitting] = useState(false);
  const [capturingLocation, setCapturingLocation] = useState(false);

  const { showToast } = useToast();

  async function loadData() {
    try {
      setLoading(true);
      const [bizRes, catRes] = await Promise.all([
        supabase
          .from('businesses')
          .select('*')
          .order('created_at', { ascending: false }),
        supabase
          .from('categories')
          .select('*')
          .eq('is_active', true)
          .order('sort_order'),
      ]);

      if (bizRes.error) throw bizRes.error;
      if (catRes.error) throw catRes.error;

      setBusinesses(bizRes.data || []);
      setCategories(catRes.data || []);

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
      village_id: 'a0000000-0000-0000-0000-000000000001',
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
      latitude: b.latitude ?? null,
      longitude: b.longitude ?? null,
      location_accuracy_meters: b.location_accuracy_meters ?? null,
      location_captured_at: b.location_captured_at ?? null,
      location_confirmed: b.latitude !== null && b.latitude !== undefined,
    });
    setIsModalOpen(true);
  }

  const handleCaptureLocation = () => {
    if (!navigator.geolocation) {
      showToast('ब्राउझरमध्ये GPS जिओलोकेशन सपोर्ट उपलब्ध नाही.', 'error');
      return;
    }
    setCapturingLocation(true);
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const lat = parseFloat(pos.coords.latitude.toFixed(6));
        const lng = parseFloat(pos.coords.longitude.toFixed(6));
        const acc = Math.round(pos.coords.accuracy);
        const now = new Date().toISOString();
        setFormData(prev => ({
          ...prev,
          latitude: lat,
          longitude: lng,
          location_accuracy_meters: acc,
          location_captured_at: now,
          location_confirmed: true,
        }));
        setCapturingLocation(false);
        showToast(
          `📍 GPS लोकेशन प्राप्त! (${lat}, ${lng}) - अचूकता: ±${acc} मीटर`,
          acc > 80 ? 'info' : 'success'
        );
      },
      (err) => {
        setCapturingLocation(false);
        let msg = 'GPS लोकेशन मिळवता आले नाही.';
        if (err.code === 1) msg = 'GPS परवानगी नाकारली गेली आहे. कृपया ब्राउझरमध्ये लोकेशन अनुमती द्या.';
        else if (err.code === 2) msg = 'GPS स्थान उपलब्ध नाही. कृपया फोनचे लोकेशन/GPS सुरू असल्याची खात्री करा.';
        else if (err.code === 3) msg = 'GPS शोधताना वेळ संपली (Timeout). पुन्हा प्रयत्न करा.';
        showToast(msg, 'error');
      },
      {
        enableHighAccuracy: true,
        timeout: 15000,
        maximumAge: 0,
      }
    );
  };

  const handleClearLocation = () => {
    setFormData(prev => ({
      ...prev,
      latitude: null,
      longitude: null,
      location_accuracy_meters: null,
      location_captured_at: null,
      location_confirmed: false,
    }));
    showToast('GPS लोकेशन हटवले.', 'info');
  };

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!formData.business_name_mr.trim() || !formData.phone.trim()) {
      showToast('कृपया व्यवसायाचे नाव व फोन नंबर प्रविष्ट करा.', 'error');
      return;
    }

    if (formData.latitude !== null && !formData.location_confirmed) {
      showToast('कृपया प्रत्यक्ष उपस्थिती व अचूकतेची पुष्टी (Confirmation Checkbox) निवडा.', 'error');
      return;
    }

    try {
      setSubmitting(true);
      const isGpsValid = formData.latitude !== null && formData.longitude !== null;
      const now = new Date().toISOString();

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
            latitude: formData.latitude,
            longitude: formData.longitude,
            location_accuracy_meters: formData.location_accuracy_meters,
            location_captured_at: formData.location_captured_at,
            location_verified_by: isGpsValid ? 'Admin' : null,
            location_verified_at: isGpsValid ? now : null,
            updated_at: now,
          })
          .eq('id', editingBusiness.id);

        if (error) throw error;
        showToast('व्यवसायाची माहिती व GPS लोकेशन यशस्वीपणे अपडेट झाले!', 'success');
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
            latitude: formData.latitude,
            longitude: formData.longitude,
            location_accuracy_meters: formData.location_accuracy_meters,
            location_captured_at: formData.location_captured_at,
            location_verified_by: isGpsValid ? 'Admin' : null,
            location_verified_at: isGpsValid ? now : null,
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

  const getVillageName = (_vid: string) => {
    return 'नरडाणा';
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
    const matchesCategory = categoryFilter === 'all' || b.category_id === categoryFilter;

    return matchesSearch && matchesStatus && matchesCategory;
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

          <div className="flex items-center gap-1.5 px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-semibold text-slate-700">
            <MapPin className="w-3.5 h-3.5 text-brand-green flex-shrink-0" />
            <span>गाव: नरडाणा (४२५४०४)</span>
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
                  <tr 
                    key={b.id} 
                    onClick={() => setViewingBusiness(b)} 
                    className="hover:bg-blue-50/70 transition cursor-pointer group"
                    title="सविस्तर माहिती पाहण्यासाठी क्लिक करा"
                  >
                    <td className="px-5 py-3.5">
                      <div className="flex items-center justify-between">
                        <div>
                          <p className="font-bold text-slate-800 flex items-center gap-1.5 group-hover:text-brand-blue transition">
                            <Store className="w-3.5 h-3.5 text-brand-blue flex-shrink-0" />
                            <span>{b.business_name_mr}</span>
                          </p>
                          <p className="text-[11px] text-slate-500">{b.business_name_en}</p>
                        </div>
                        <span className="text-[10px] text-brand-blue bg-blue-100 font-semibold px-2 py-0.5 rounded opacity-0 group-hover:opacity-100 transition mr-2">
                          तपशील ↗
                        </span>
                      </div>
                    </td>
                    <td className="px-5 py-3.5">
                      <p className="font-medium text-slate-700 flex items-center gap-1">
                        <MapPin className="w-3 h-3 text-brand-green" /> {getVillageName(b.village_id)}
                      </p>
                      <p className="text-[11px] text-slate-500">{getCategoryName(b.category_id)}</p>
                      {b.latitude && b.longitude ? (
                        <div className="flex items-center gap-1 text-[10px] text-emerald-700 font-semibold mt-1">
                          <Crosshair className="w-2.5 h-2.5 text-emerald-600" />
                          <span>GPS नोंदणीकृत (±{b.location_accuracy_meters ? Math.round(b.location_accuracy_meters) : 10}m)</span>
                        </div>
                      ) : (
                        <div className="flex items-center gap-1 text-[10px] text-amber-700 font-medium mt-1">
                          <AlertTriangle className="w-2.5 h-2.5 text-amber-500" />
                          <span>GPS नोंद बाकी</span>
                        </div>
                      )}
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
                    <td className="px-5 py-3.5 text-right space-x-1" onClick={(e) => e.stopPropagation()}>
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
                    गाव (Village)
                  </label>
                  <div className="w-full px-3 py-2 border border-slate-200 rounded-lg bg-slate-50 text-xs font-bold text-slate-700 flex items-center gap-1.5">
                    <MapPin className="w-3.5 h-3.5 text-brand-green" />
                    <span>नरडाणा (Nardana - 425404)</span>
                  </div>
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

              {/* GPS Location Capture Section */}
              <div className="p-3.5 rounded-xl border border-blue-200 bg-blue-50/40 space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-1.5">
                    <Crosshair className="w-4 h-4 text-brand-blue" />
                    <span className="font-bold text-slate-800 text-xs">GPS लोकेशन मॅपिंग (Google Maps)</span>
                  </div>
                  {formData.latitude && formData.longitude ? (
                    <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                      (formData.location_accuracy_meters || 0) <= 30
                        ? 'bg-emerald-100 text-emerald-800'
                        : (formData.location_accuracy_meters || 0) <= 80
                        ? 'bg-amber-100 text-amber-800'
                        : 'bg-rose-100 text-rose-800'
                    }`}>
                      ±{formData.location_accuracy_meters || 10}m अचूकता
                    </span>
                  ) : (
                    <span className="text-[10px] text-slate-400 font-medium">नोंद बाकी</span>
                  )}
                </div>

                <div className="flex flex-wrap items-center gap-2">
                  <button
                    type="button"
                    onClick={handleCaptureLocation}
                    disabled={capturingLocation}
                    className="flex items-center gap-1.5 px-3 py-2 bg-brand-blue hover:bg-brand-dark text-white rounded-lg text-xs font-semibold shadow-sm transition disabled:opacity-50"
                  >
                    <Navigation className={`w-3.5 h-3.5 ${capturingLocation ? 'animate-spin' : ''}`} />
                    <span>{capturingLocation ? 'GPS स्थान शोधत आहे...' : formData.latitude ? 'पुन्हा अचूक GPS मिळवा (Recapture)' : '📍 सध्याचे अचूक GPS लोकेशन मिळवा'}</span>
                  </button>

                  {formData.latitude && formData.longitude && (
                    <>
                      <a
                        href={`https://www.google.com/maps?q=${formData.latitude},${formData.longitude}`}
                        target="_blank"
                        rel="noreferrer"
                        className="flex items-center gap-1 px-2.5 py-2 border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 rounded-lg text-xs font-semibold transition"
                      >
                        <ExternalLink className="w-3.5 h-3.5 text-brand-blue" />
                        <span>Google Maps वर तपासा</span>
                      </a>
                      <button
                        type="button"
                        onClick={handleClearLocation}
                        className="px-2.5 py-2 text-rose-600 hover:bg-rose-50 rounded-lg text-xs font-medium transition"
                      >
                        हटवा
                      </button>
                    </>
                  )}
                </div>

                {formData.latitude && formData.longitude ? (
                  <div className="space-y-2 pt-1 border-t border-blue-100">
                    <div className="grid grid-cols-2 gap-2 text-[11px] font-mono text-slate-700 bg-white/70 p-2 rounded-lg border border-blue-100">
                      <div>अक्षांश (Lat): <strong>{formData.latitude}</strong></div>
                      <div>रेखांश (Lng): <strong>{formData.longitude}</strong></div>
                    </div>
                    {formData.location_accuracy_meters && formData.location_accuracy_meters > 80 && (
                      <div className="flex items-start gap-1.5 p-2 rounded bg-amber-50 border border-amber-200 text-[11px] text-amber-800">
                        <AlertTriangle className="w-3.5 h-3.5 text-amber-600 flex-shrink-0 mt-0.5" />
                        <span>GPS अचूकता कमजोर (±{formData.location_accuracy_meters}m) आहे. कृपया दुकानाच्या बाहेर खुल्या आकाशाखाली पुन्हा लोकेशन मिळवा.</span>
                      </div>
                    )}
                    <label className="flex items-start gap-2 pt-1 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={formData.location_confirmed}
                        onChange={(e) => setFormData({ ...formData, location_confirmed: e.target.checked })}
                        className="mt-0.5 rounded text-brand-blue focus:ring-brand-blue"
                      />
                      <span className="text-[11px] text-slate-700 font-medium">
                        मी या दुकानाच्या प्रत्यक्ष जागी उपस्थित राहून हे GPS लोकेशन नोंदवले असून ते अचूक आहे याची खात्री करतो.
                      </span>
                    </label>
                  </div>
                ) : (
                  <p className="text-[11px] text-slate-500 leading-relaxed">
                    ℹ️ दुकानाच्या प्रत्यक्ष जागेवर जाऊन वरील बटण दाबा. हे लोकेशन ॲपमधील नागरिकांना थेट गुगल मॅप्सवर दिशामार्ग दाखवण्यासाठी वापरले जाईल.
                  </p>
                )}
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
          <div className="bg-white rounded-2xl max-w-lg w-full max-h-[90vh] overflow-y-auto shadow-2xl border border-slate-200">
            {/* Modal Header */}
            <div className="p-5 bg-gradient-to-r from-brand-dark to-brand-blue text-white rounded-t-2xl relative">
              <button
                onClick={() => setViewingBusiness(null)}
                className="absolute top-4 right-4 text-white/70 hover:text-white bg-white/10 p-1.5 rounded-lg transition"
              >
                <X className="w-4 h-4" />
              </button>
              
              <div className="flex items-center gap-2 mb-2">
                <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-brand-yellow text-slate-900">
                  स्थानिक व्यवसाय
                </span>
                <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                  viewingBusiness.status === 'approved' ? 'bg-emerald-500 text-white' :
                  viewingBusiness.status === 'pending' ? 'bg-amber-400 text-slate-900' :
                  'bg-rose-500 text-white'
                }`}>
                  {viewingBusiness.status === 'approved' ? '✓ मंजूर (Approved)' :
                   viewingBusiness.status === 'pending' ? '⏳ प्रलंबित (Pending Review)' :
                   '✕ नाकारलेले (Rejected)'}
                </span>
              </div>

              <h3 className="font-extrabold text-xl text-white flex items-center gap-2">
                <Store className="w-5 h-5 text-brand-yellow flex-shrink-0" />
                <span>{viewingBusiness.business_name_mr}</span>
              </h3>
              {viewingBusiness.business_name_en && (
                <p className="text-xs text-slate-300 font-medium mt-0.5">{viewingBusiness.business_name_en}</p>
              )}

              <div className="flex flex-wrap gap-2 mt-3 text-xs">
                <span className="px-2.5 py-1 rounded-md bg-white/15 text-white flex items-center gap-1 font-medium">
                  <MapPin className="w-3 h-3 text-emerald-300" /> {getVillageName(viewingBusiness.village_id)}
                </span>
                <span className="px-2.5 py-1 rounded-md bg-white/15 text-white flex items-center gap-1 font-medium">
                  <Filter className="w-3 h-3 text-amber-300" /> {getCategoryName(viewingBusiness.category_id)}
                </span>
              </div>
            </div>

            {/* Modal Body */}
            <div className="p-6 space-y-4 text-xs">
              {/* Owner and Contact Grid */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200">
                  <p className="text-[11px] font-semibold text-slate-500 uppercase tracking-wider mb-1">मालक / संचालक</p>
                  <p className="font-bold text-slate-800 text-sm">{viewingBusiness.owner_name}</p>
                </div>

                <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200">
                  <p className="text-[11px] font-semibold text-slate-500 uppercase tracking-wider mb-1">कामाची वेळ</p>
                  <p className="font-bold text-slate-800 text-xs flex items-center gap-1">
                    <Clock className="w-3.5 h-3.5 text-brand-blue" />
                    <span>{(viewingBusiness as any).opening_hours || 'सकाळी ९:०० ते रात्री ८:००'}</span>
                  </p>
                </div>
              </div>

              {/* Direct Calling / WhatsApp Bar */}
              <div className="p-3.5 rounded-xl bg-blue-50/60 border border-blue-200 flex flex-wrap items-center justify-between gap-3">
                <div className="flex items-center gap-2">
                  <Phone className="w-4 h-4 text-brand-blue" />
                  <div>
                    <p className="font-bold text-slate-900 font-mono text-xs">{viewingBusiness.phone}</p>
                    {viewingBusiness.whatsapp && (
                      <p className="text-[11px] text-emerald-700 font-mono">WA: {viewingBusiness.whatsapp}</p>
                    )}
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <a
                    href={`tel:${viewingBusiness.phone}`}
                    className="px-3 py-1.5 bg-brand-blue text-white rounded-lg font-semibold text-xs flex items-center gap-1 hover:bg-brand-dark transition shadow-sm"
                  >
                    <Phone className="w-3 h-3" /> कॉल करा
                  </a>
                  {viewingBusiness.whatsapp && (
                    <a
                      href={`https://wa.me/91${viewingBusiness.whatsapp.replace(/\D/g, '')}`}
                      target="_blank"
                      rel="noreferrer"
                      className="px-3 py-1.5 bg-brand-green text-white rounded-lg font-semibold text-xs flex items-center gap-1 hover:bg-emerald-700 transition shadow-sm"
                    >
                      <MessageSquare className="w-3 h-3" /> WhatsApp
                    </a>
                  )}
                </div>
              </div>

              {/* Address */}
              <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200">
                <p className="text-[11px] font-semibold text-slate-500 uppercase tracking-wider mb-1 flex items-center gap-1">
                  <MapPin className="w-3.5 h-3.5 text-rose-500" /> पत्ता व स्थान
                </p>
                <p className="text-slate-800 text-xs leading-relaxed font-medium">{viewingBusiness.address}</p>
              </div>

              {/* GPS Location & Directions Card */}
              <div className="p-3.5 rounded-xl bg-blue-50/60 border border-blue-200 space-y-2">
                <div className="flex items-center justify-between">
                  <p className="text-[11px] font-semibold text-slate-600 uppercase tracking-wider flex items-center gap-1">
                    <Compass className="w-3.5 h-3.5 text-brand-blue" /> GPS लोकेशन व थेट नेव्हिगेशन
                  </p>
                  {viewingBusiness.latitude && viewingBusiness.longitude ? (
                    <span className="px-2 py-0.5 bg-emerald-100 text-emerald-800 text-[10px] font-bold rounded-full">
                      ✓ GPS पडताळणीकृत (±{viewingBusiness.location_accuracy_meters ? Math.round(viewingBusiness.location_accuracy_meters) : 10}m)
                    </span>
                  ) : (
                    <span className="px-2 py-0.5 bg-amber-100 text-amber-800 text-[10px] font-bold rounded-full">
                      ⚠️ GPS उपलब्ध नाही
                    </span>
                  )}
                </div>
                {viewingBusiness.latitude && viewingBusiness.longitude ? (
                  <div className="flex flex-wrap items-center justify-between gap-2 pt-1">
                    <div className="text-[11px] font-mono text-slate-700 bg-white/70 px-2.5 py-1 rounded border border-blue-100">
                      {viewingBusiness.latitude}, {viewingBusiness.longitude}
                    </div>
                    <a
                      href={`https://www.google.com/maps/dir/?api=1&destination=${viewingBusiness.latitude},${viewingBusiness.longitude}`}
                      target="_blank"
                      rel="noreferrer"
                      className="px-3 py-1.5 bg-brand-blue hover:bg-brand-dark text-white rounded-lg font-semibold text-xs flex items-center gap-1 shadow-sm transition"
                    >
                      <Navigation className="w-3 h-3" />
                      <span>Google Maps दिशामार्ग ↗</span>
                    </a>
                  </div>
                ) : (
                  <p className="text-[11px] text-slate-500">
                    या व्यवसायासाठी अद्याप GPS नोंदणी केलेली नाही. 'संपादित करा' वर क्लिक करून GPS लोकेशन मिळवा.
                  </p>
                )}
              </div>

              {/* Description */}
              {viewingBusiness.description && (
                <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200">
                  <p className="text-[11px] font-semibold text-slate-500 uppercase tracking-wider mb-1">
                    माहिती व सेवा वर्णन
                  </p>
                  <p className="text-slate-700 text-xs leading-relaxed whitespace-pre-line">
                    {viewingBusiness.description}
                  </p>
                </div>
              )}

              {/* Registration Meta */}
              <div className="flex items-center justify-between text-[11px] text-slate-400 pt-1">
                <span>नोंदणी दिनांक: {new Date(viewingBusiness.created_at).toLocaleDateString('mr-IN')}</span>
                <span>आयडी: {viewingBusiness.id.slice(0, 8)}...</span>
              </div>

              {/* Action Toolbar Inside Modal */}
              <div className="flex flex-wrap items-center justify-between gap-2 pt-4 border-t border-slate-200">
                <div className="flex items-center gap-2">
                  {viewingBusiness.status !== 'approved' && (
                    <button
                      onClick={() => {
                        updateStatus(viewingBusiness.id, 'approved');
                        setViewingBusiness(prev => prev ? { ...prev, status: 'approved' } : null);
                      }}
                      className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg font-semibold text-xs flex items-center gap-1 transition shadow-sm"
                    >
                      <CheckCircle className="w-3.5 h-3.5" /> मंजूर करा
                    </button>
                  )}
                  {viewingBusiness.status !== 'rejected' && (
                    <button
                      onClick={() => {
                        updateStatus(viewingBusiness.id, 'rejected');
                        setViewingBusiness(prev => prev ? { ...prev, status: 'rejected' } : null);
                      }}
                      className="px-3 py-1.5 bg-rose-600 hover:bg-rose-700 text-white rounded-lg font-semibold text-xs flex items-center gap-1 transition shadow-sm"
                    >
                      <XCircle className="w-3.5 h-3.5" /> नाकारा
                    </button>
                  )}
                  <button
                    onClick={() => {
                      const target = viewingBusiness;
                      setViewingBusiness(null);
                      handleOpenEdit(target);
                    }}
                    className="px-3 py-1.5 border border-slate-300 hover:bg-slate-100 text-slate-700 rounded-lg font-semibold text-xs flex items-center gap-1 transition"
                  >
                    <Edit2 className="w-3.5 h-3.5 text-brand-blue" /> संपादित करा
                  </button>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    onClick={() => {
                      const target = viewingBusiness;
                      setViewingBusiness(null);
                      handleDelete(target);
                    }}
                    className="p-2 text-rose-600 hover:bg-rose-50 rounded-lg transition"
                    title="हटवा"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => setViewingBusiness(null)}
                    className="px-4 py-1.5 bg-slate-200 hover:bg-slate-300 text-slate-800 rounded-lg font-semibold text-xs transition"
                  >
                    बंद करा
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
