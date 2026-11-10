import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { Advertisement, Category } from '../types/database';
import { 
  Megaphone, 
  Plus, 
  Search, 
  Trash2, 
  Edit2, 
  Check, 
  X, 
  Eye, 
  Upload, 
  BarChart3, 
  MousePointerClick, 
  Calendar, 
  Phone, 
  MessageSquare, 
  Globe, 
  CheckCircle2, 
  Clock, 
  Sparkles
} from 'lucide-react';
import { useToast } from '../components/Toast';

interface AdFormData {
  title_mr: string;
  title_en: string;
  description_mr: string;
  description_en: string;
  image_url: string;
  placement: 'home_carousel' | 'sponsored_card' | 'category_banner' | 'popup';
  category_id: string;
  target_type: 'none' | 'business' | 'phone' | 'whatsapp' | 'url' | 'notice';
  target_url: string;
  phone: string;
  whatsapp: string;
  start_date: string;
  end_date: string;
  is_active: boolean;
  priority: number;
  advertiser_name: string;
  advertiser_contact: string;
}

const defaultFormData: AdFormData = {
  title_mr: '',
  title_en: '',
  description_mr: '',
  description_en: '',
  image_url: 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800&auto=format&fit=crop&q=80',
  placement: 'home_carousel',
  category_id: '',
  target_type: 'phone',
  target_url: '',
  phone: '',
  whatsapp: '',
  start_date: new Date().toISOString().split('T')[0],
  end_date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
  is_active: true,
  priority: 5,
  advertiser_name: '',
  advertiser_contact: '',
};

export const Advertisements: React.FC = () => {
  const [ads, setAds] = useState<Advertisement[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [placementFilter, setPlacementFilter] = useState<string>('all');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'inactive' | 'expired'>('all');

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingAd, setEditingAd] = useState<Advertisement | null>(null);
  const [viewingAd, setViewingAd] = useState<Advertisement | null>(null);
  const [formData, setFormData] = useState<AdFormData>(defaultFormData);
  const [submitting, setSubmitting] = useState(false);
  const [uploadingImage, setUploadingImage] = useState(false);
  const [previewMode, setPreviewMode] = useState<'form' | 'preview'>('form');

  const { showToast } = useToast();

  async function loadData() {
    try {
      setLoading(true);
      const [adsRes, catRes] = await Promise.all([
        supabase
          .from('advertisements')
          .select('*')
          .order('priority', { ascending: false })
          .order('created_at', { ascending: false }),
        supabase
          .from('categories')
          .select('*')
          .order('sort_order'),
      ]);

      if (adsRes.error) throw adsRes.error;
      if (catRes.error) throw catRes.error;

      setAds(adsRes.data || []);
      setCategories(catRes.data || []);
    } catch (err: any) {
      console.error('Error fetching advertisements:', err);
      showToast('जाहिराती लोड करताना त्रुटी: ' + (err.message || ''), 'error');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();

    // Subscribe to realtime updates
    const channel = supabase
      .channel('public:advertisements')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'advertisements' }, () => {
        loadData();
      })
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, []);

  function handleOpenAdd() {
    setEditingAd(null);
    setFormData({
      ...defaultFormData,
      start_date: new Date().toISOString().split('T')[0],
      end_date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
    });
    setPreviewMode('form');
    setIsModalOpen(true);
  }

  function handleOpenEdit(ad: Advertisement) {
    setEditingAd(ad);
    setFormData({
      title_mr: ad.title_mr,
      title_en: ad.title_en,
      description_mr: ad.description_mr || '',
      description_en: ad.description_en || '',
      image_url: ad.image_url,
      placement: ad.placement,
      category_id: ad.category_id || '',
      target_type: ad.target_type,
      target_url: ad.target_url || '',
      phone: ad.phone || '',
      whatsapp: ad.whatsapp || '',
      start_date: ad.start_date.split('T')[0],
      end_date: ad.end_date.split('T')[0],
      is_active: ad.is_active,
      priority: ad.priority,
      advertiser_name: ad.advertiser_name || '',
      advertiser_contact: ad.advertiser_contact || '',
    });
    setPreviewMode('form');
    setIsModalOpen(true);
  }

  async function handleImageUpload(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;

    try {
      setUploadingImage(true);
      const fileExt = file.name.split('.').pop();
      const fileName = `ad_${Date.now()}_${Math.random().toString(36).substring(7)}.${fileExt}`;
      const filePath = `ad-banners/${fileName}`;

      const { error: uploadError } = await supabase.storage
        .from('advertisements')
        .upload(filePath, file, { cacheControl: '3600', upsert: true });

      if (uploadError) throw uploadError;

      const { data: { publicUrl } } = supabase.storage
        .from('advertisements')
        .getPublicUrl(filePath);

      setFormData(prev => ({ ...prev, image_url: publicUrl }));
      showToast('फोटो यशस्वीपणे अपलोड केला!', 'success');
    } catch (err: any) {
      console.error('Upload error:', err);
      showToast('फोटो अपलोड करताना त्रुटी: ' + (err.message || ''), 'error');
    } finally {
      setUploadingImage(false);
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!formData.title_mr.trim() || !formData.title_en.trim()) {
      showToast('कृपया जाहिरातीचे मराठी व इंग्रजी शीर्षक भरा.', 'error');
      return;
    }
    if (!formData.image_url.trim()) {
      showToast('कृपया जाहिरात बॅनर फोटो जोडा किंवा अपलोड करा.', 'error');
      return;
    }

    try {
      setSubmitting(true);
      const payload: any = {
        village_id: 'a0000000-0000-0000-0000-000000000001',
        title_mr: formData.title_mr.trim(),
        title_en: formData.title_en.trim(),
        description_mr: formData.description_mr.trim() || null,
        description_en: formData.description_en.trim() || null,
        image_url: formData.image_url.trim(),
        placement: formData.placement,
        category_id: formData.category_id ? formData.category_id : null,
        target_type: formData.target_type,
        target_url: formData.target_url.trim() || null,
        phone: formData.phone.trim() || null,
        whatsapp: formData.whatsapp.trim() || null,
        start_date: new Date(formData.start_date).toISOString(),
        end_date: new Date(formData.end_date).toISOString(),
        is_active: formData.is_active,
        priority: Number(formData.priority) || 0,
        advertiser_name: formData.advertiser_name.trim() || null,
        advertiser_contact: formData.advertiser_contact.trim() || null,
        updated_at: new Date().toISOString(),
      };

      if (editingAd) {
        const { error } = await supabase
          .from('advertisements')
          .update(payload)
          .eq('id', editingAd.id);

        if (error) throw error;
        showToast('जाहिरात यशस्वीपणे अपडेट केली!', 'success');
      } else {
        const { error } = await supabase
          .from('advertisements')
          .insert(payload);

        if (error) throw error;
        showToast('नवीन जाहिरात प्रसिद्ध केली!', 'success');
      }

      setIsModalOpen(false);
      loadData();
    } catch (err: any) {
      console.error('Save advertisement error:', err);
      showToast('जाहिरात सेव्ह करताना त्रुटी: ' + (err.message || ''), 'error');
    } finally {
      setSubmitting(false);
    }
  }

  async function handleToggleStatus(ad: Advertisement) {
    try {
      const nextStatus = !ad.is_active;
      const { error } = await supabase
        .from('advertisements')
        .update({ is_active: nextStatus, updated_at: new Date().toISOString() })
        .eq('id', ad.id);

      if (error) throw error;
      setAds(prev => prev.map(a => a.id === ad.id ? { ...a, is_active: nextStatus } : a));
      showToast(nextStatus ? 'जाहिरात सक्रिय केली.' : 'जाहिरात निष्क्रिय केली.', 'success');
    } catch (err: any) {
      showToast('स्थिती बदलताना त्रुटी: ' + err.message, 'error');
    }
  }

  async function handleDelete(ad: Advertisement) {
    if (!window.confirm(`तुम्हाला नक्की '${ad.title_mr}' ही जाहिरात हटवायची आहे का?`)) return;

    try {
      const { error } = await supabase
        .from('advertisements')
        .delete()
        .eq('id', ad.id);

      if (error) throw error;
      setAds(prev => prev.filter(a => a.id !== ad.id));
      showToast('जाहिरात यशस्वीपणे हटवली.', 'success');
    } catch (err: any) {
      showToast('हटवताना त्रुटी: ' + err.message, 'error');
    }
  }

  // Analytics Computation
  const now = new Date();
  const totalAds = ads.length;
  const activeAds = ads.filter(a => a.is_active && new Date(a.end_date) >= now && new Date(a.start_date) <= now).length;
  const expiredAds = ads.filter(a => new Date(a.end_date) < now).length;
  const totalImpressions = ads.reduce((acc, curr) => acc + (curr.impressions_count || 0), 0);
  const totalClicks = ads.reduce((acc, curr) => acc + (curr.clicks_count || 0), 0);
  const avgCtr = totalImpressions > 0 ? ((totalClicks / totalImpressions) * 100).toFixed(1) : '0.0';

  // Filtering
  const filteredAds = ads.filter((ad) => {
    const isExpired = new Date(ad.end_date) < now;
    const isActive = ad.is_active && !isExpired;

    const matchesSearch =
      ad.title_mr.toLowerCase().includes(searchTerm.toLowerCase()) ||
      ad.title_en.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (ad.advertiser_name && ad.advertiser_name.toLowerCase().includes(searchTerm.toLowerCase()));

    const matchesPlacement = placementFilter === 'all' || ad.placement === placementFilter;

    let matchesStatus = true;
    if (statusFilter === 'active') matchesStatus = isActive;
    else if (statusFilter === 'inactive') matchesStatus = !ad.is_active && !isExpired;
    else if (statusFilter === 'expired') matchesStatus = isExpired;

    return matchesSearch && matchesPlacement && matchesStatus;
  });

  const getPlacementBadge = (p: string) => {
    switch (p) {
      case 'home_carousel':
        return <span className="px-2 py-0.5 rounded text-[11px] font-semibold bg-blue-50 text-brand-blue border border-blue-200">मुख्य कॅरोसेल</span>;
      case 'sponsored_card':
        return <span className="px-2 py-0.5 rounded text-[11px] font-semibold bg-amber-50 text-amber-800 border border-amber-200">प्रायोजित कार्ड</span>;
      case 'category_banner':
        return <span className="px-2 py-0.5 rounded text-[11px] font-semibold bg-emerald-50 text-emerald-800 border border-emerald-200">कॅटेगरी बॅनर</span>;
      case 'popup':
        return <span className="px-2 py-0.5 rounded text-[11px] font-semibold bg-purple-50 text-purple-800 border border-purple-200">पॉपअप बॅनर</span>;
      default:
        return <span>{p}</span>;
    }
  };

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h2 className="text-xl font-bold text-slate-900 flex items-center gap-2">
            <Megaphone className="w-5 h-5 text-brand-blue" />
            जाहिरात व्यवस्थापन (Advertisement Module)
          </h2>
          <p className="text-xs text-slate-500">
            नरडाणा गावातील स्थानिक व्यावसायिक व सेवांच्या जाहिराती, बॅनर, प्लेसमेंट व क्लिक्स ट्रॅकिंग
          </p>
        </div>
        <button
          onClick={handleOpenAdd}
          className="flex items-center justify-center space-x-1.5 px-4 py-2.5 bg-brand-blue text-white rounded-lg text-xs font-semibold hover:bg-brand-dark transition shadow-sm active:scale-95"
        >
          <Plus className="w-4 h-4" />
          <span>+ नवीन जाहिरात तयार करा</span>
        </button>
      </div>

      {/* Analytics KPI Dashboard Cards */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <p className="text-[11px] font-bold text-slate-500 uppercase">एकूण जाहिराती</p>
          <p className="text-2xl font-black text-slate-800 mt-1">{totalAds}</p>
          <span className="text-[10px] text-slate-400">सर्व नोंदणीकृत</span>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <p className="text-[11px] font-bold text-emerald-600 uppercase flex items-center gap-1">
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
            सक्रिय (Active)
          </p>
          <p className="text-2xl font-black text-emerald-700 mt-1">{activeAds}</p>
          <span className="text-[10px] text-slate-400">ॲपमध्ये थेट प्रदर्शित</span>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <p className="text-[11px] font-bold text-amber-600 uppercase flex items-center gap-1">
            <Clock className="w-3 h-3 text-amber-500" />
            मुदत संपलेल्या
          </p>
          <p className="text-2xl font-black text-amber-700 mt-1">{expiredAds}</p>
          <span className="text-[10px] text-slate-400">स्वयंचलित लपवल्या</span>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <p className="text-[11px] font-bold text-slate-500 uppercase flex items-center gap-1">
            <Eye className="w-3 h-3 text-brand-blue" /> इम्प्रेशन्स
          </p>
          <p className="text-2xl font-black text-brand-blue mt-1">{totalImpressions}</p>
          <span className="text-[10px] text-slate-400">गावकर्‍यांनी पाहिले</span>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <p className="text-[11px] font-bold text-slate-500 uppercase flex items-center gap-1">
            <MousePointerClick className="w-3 h-3 text-purple-600" /> क्लिक्स
          </p>
          <p className="text-2xl font-black text-purple-700 mt-1">{totalClicks}</p>
          <span className="text-[10px] text-slate-400">कॉल / संपर्क प्रतिसाद</span>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <p className="text-[11px] font-bold text-slate-500 uppercase flex items-center gap-1">
            <BarChart3 className="w-3 h-3 text-teal-600" /> सरासरी CTR
          </p>
          <p className="text-2xl font-black text-teal-700 mt-1">{avgCtr}%</p>
          <span className="text-[10px] text-slate-400">क्लिक दर (Response)</span>
        </div>
      </div>

      {/* Scope Policy Badge */}
      <div className="bg-blue-50/70 border border-blue-200 rounded-xl p-3 flex items-center justify-between text-xs text-slate-700">
        <div className="flex items-center gap-2">
          <Sparkles className="w-4 h-4 text-brand-yellow flex-shrink-0" />
          <span>
            <strong>स्थानिक नरडाणा कव्हरेज:</strong> सर्व जाहिराती केवळ नरडाणा गाव क्षेत्रातील स्थानिक व्यवसाय, दुकाने व शेती सेवांसाठीच मर्यादित आहेत.
          </span>
        </div>
        <span className="hidden md:inline-flex px-2 py-0.5 rounded text-[10px] font-bold bg-white text-brand-blue border border-blue-200">
          📍 नरडाणा (४२५४०४)
        </span>
      </div>

      {/* Filters & Search Toolbar */}
      <div className="bg-white p-3.5 rounded-xl border border-slate-200 shadow-sm flex flex-col sm:flex-row gap-3">
        <div className="flex-1 flex items-center gap-2 border border-slate-200 rounded-lg px-3 py-2 bg-slate-50 focus-within:bg-white focus-within:border-brand-blue transition">
          <Search className="w-4 h-4 text-slate-400 flex-shrink-0" />
          <input
            type="text"
            placeholder="जाहिरात किंवा जाहिरातदाराच्या नावाने शोधा..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full text-xs text-slate-800 bg-transparent placeholder-slate-400 focus:outline-none"
          />
          {searchTerm && (
            <button onClick={() => setSearchTerm('')} className="text-slate-400 hover:text-slate-600 text-xs">
              रद्द करा
            </button>
          )}
        </div>

        <div className="flex items-center gap-2 sm:w-48">
          <select
            value={placementFilter}
            onChange={(e) => setPlacementFilter(e.target.value)}
            className="w-full text-xs border border-slate-200 rounded-lg px-2.5 py-2 bg-white text-slate-700 focus:outline-none"
          >
            <option value="all">सर्व प्लेसमेंट (All Placements)</option>
            <option value="home_carousel">मुख्य कॅरोसेल (Carousel)</option>
            <option value="sponsored_card">प्रायोजित कार्ड (Card)</option>
            <option value="category_banner">कॅटेगरी बॅनर (Category)</option>
            <option value="popup">पॉपअप (Popup)</option>
          </select>
        </div>

        <div className="flex items-center gap-2 sm:w-44">
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value as any)}
            className="w-full text-xs border border-slate-200 rounded-lg px-2.5 py-2 bg-white text-slate-700 focus:outline-none"
          >
            <option value="all">सर्व स्थिती (All Status)</option>
            <option value="active">सक्रिय (Active)</option>
            <option value="inactive">निष्क्रिय (Inactive)</option>
            <option value="expired">मुदत संपलेल्या (Expired)</option>
          </select>
        </div>
      </div>

      {/* Advertisements Table */}
      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
            <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
              <tr>
                <th className="px-4 py-3">बॅनर फोटो</th>
                <th className="px-4 py-3">जाहिरात शीर्षक व तपशील</th>
                <th className="px-4 py-3">प्लेसमेंट</th>
                <th className="px-4 py-3">कृती / संपर्क</th>
                <th className="px-4 py-3">कालावधी (Validity)</th>
                <th className="px-4 py-3">प्रतिसाद (Views / Clicks)</th>
                <th className="px-4 py-3">स्थिती</th>
                <th className="px-4 py-3 text-right">व्यवस्थापन</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {loading ? (
                <tr>
                  <td colSpan={8} className="px-4 py-10 text-center text-slate-400">माहिती लोड होत आहे...</td>
                </tr>
              ) : filteredAds.length === 0 ? (
                <tr>
                  <td colSpan={8} className="px-4 py-10 text-center text-slate-400">
                    कोणतीही जाहिरात सापडली नाही.
                  </td>
                </tr>
              ) : (
                filteredAds.map((ad) => {
                  const isExpired = new Date(ad.end_date) < now;
                  const isActive = ad.is_active && !isExpired;
                  const ctr = (ad.impressions_count || 0) > 0 
                    ? (((ad.clicks_count || 0) / ad.impressions_count) * 100).toFixed(1) 
                    : '0.0';

                  return (
                    <tr 
                      key={ad.id} 
                      onClick={() => setViewingAd(ad)} 
                      className="hover:bg-blue-50/70 transition cursor-pointer group"
                      title="सविस्तर जाहिरात माहिती पाहण्यासाठी क्लिक करा"
                    >
                      <td className="px-4 py-3">
                        <div className="w-16 h-11 rounded-lg overflow-hidden border border-slate-200 bg-slate-100 shadow-xs flex-shrink-0">
                          <img
                            src={ad.image_url}
                            alt={ad.title_mr}
                            className="w-full h-full object-cover group-hover:scale-105 transition"
                            onError={(e) => {
                              (e.target as any).src = 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=300&auto=format&fit=crop&q=80';
                            }}
                          />
                        </div>
                      </td>

                      <td className="px-4 py-3 max-w-xs">
                        <div className="space-y-0.5">
                          <div className="flex items-center justify-between">
                            <p className="font-bold text-slate-900 leading-tight line-clamp-1 group-hover:text-brand-blue transition">
                              {ad.title_mr}
                            </p>
                            <span className="text-[10px] text-brand-blue bg-blue-100 font-semibold px-2 py-0.2 rounded opacity-0 group-hover:opacity-100 transition mr-2">
                              तपशील ↗
                            </span>
                          </div>
                          <p className="text-[11px] text-slate-400 line-clamp-1">{ad.title_en}</p>
                          {ad.advertiser_name && (
                            <p className="text-[10px] text-slate-500 font-medium">
                              जाहिरातदार: {ad.advertiser_name} {ad.advertiser_contact && `(${ad.advertiser_contact})`}
                            </p>
                          )}
                        </div>
                      </td>

                      <td className="px-4 py-3">
                        {getPlacementBadge(ad.placement)}
                        <p className="text-[10px] text-slate-400 mt-1 font-mono">प्राधान्य: {ad.priority}</p>
                      </td>

                      <td className="px-4 py-3">
                        <div className="space-y-1 text-[11px]">
                          {ad.target_type === 'phone' && (
                            <span className="inline-flex items-center gap-1 font-mono text-blue-700 bg-blue-50 px-2 py-0.5 rounded border border-blue-100">
                              <Phone className="w-3 h-3 text-blue-600" /> {ad.phone || 'कॉल'}
                            </span>
                          )}
                          {ad.target_type === 'whatsapp' && (
                            <span className="inline-flex items-center gap-1 font-mono text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-100">
                              <MessageSquare className="w-3 h-3 text-emerald-600" /> {ad.whatsapp || 'व्हॉट्सॲप'}
                            </span>
                          )}
                          {ad.target_type === 'url' && (
                            <span className="inline-flex items-center gap-1 text-slate-600 bg-slate-50 px-2 py-0.5 rounded border border-slate-200">
                              <Globe className="w-3 h-3 text-slate-500" /> बाह्य लिंक
                            </span>
                          )}
                          {ad.target_type === 'none' && (
                            <span className="text-slate-400">केवळ प्रदर्शन (View Only)</span>
                          )}
                        </div>
                      </td>

                      <td className="px-4 py-3">
                        <div className="space-y-0.5 text-[11px]">
                          <p className="text-slate-600 flex items-center gap-1">
                            <Calendar className="w-3 h-3 text-slate-400" />
                            {new Date(ad.start_date).toLocaleDateString('mr-IN')}
                          </p>
                          <p className={`font-medium ${isExpired ? 'text-rose-600' : 'text-slate-500'}`}>
                            ते {new Date(ad.end_date).toLocaleDateString('mr-IN')}
                          </p>
                        </div>
                      </td>

                      <td className="px-4 py-3">
                        <div className="space-y-0.5 font-mono text-[11px]">
                          <p className="text-slate-700 font-bold flex items-center gap-1">
                            <Eye className="w-3 h-3 text-brand-blue" /> {ad.impressions_count || 0}
                          </p>
                          <p className="text-purple-700 flex items-center gap-1">
                            <MousePointerClick className="w-3 h-3 text-purple-600" /> {ad.clicks_count || 0} ({ctr}%)
                          </p>
                        </div>
                      </td>

                      <td className="px-4 py-3">
                        <button
                          onClick={() => handleToggleStatus(ad)}
                          title="स्थिती बदलण्यासाठी क्लिक करा"
                          className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-semibold transition ${
                            isExpired
                              ? 'bg-rose-100 text-rose-800'
                              : isActive
                              ? 'bg-emerald-100 text-emerald-800 hover:bg-emerald-200'
                              : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                          }`}
                        >
                          {isExpired ? (
                            <span>मुदत संपली</span>
                          ) : isActive ? (
                            <>
                              <Check className="w-3 h-3" />
                              <span>सक्रिय</span>
                            </>
                          ) : (
                            <>
                              <X className="w-3 h-3" />
                              <span>निष्क्रिय</span>
                            </>
                          )}
                        </button>
                      </td>

                      <td className="px-4 py-3 text-right space-x-1" onClick={(e) => e.stopPropagation()}>
                        <button
                          onClick={() => setViewingAd(ad)}
                          className="p-1.5 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded transition"
                          title="सविस्तर तपशील पहा"
                        >
                          <Eye className="w-3.5 h-3.5" />
                        </button>
                        <button
                          onClick={() => handleOpenEdit(ad)}
                          className="p-1.5 text-slate-600 hover:text-brand-blue hover:bg-blue-50 rounded transition"
                          title="संपादित करा"
                        >
                          <Edit2 className="w-3.5 h-3.5" />
                        </button>
                        <button
                          onClick={() => handleDelete(ad)}
                          className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded transition"
                          title="हटवा"
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                        </button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add / Edit / Preview Advertisement Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-2xl w-full shadow-2xl overflow-hidden border border-slate-200 max-h-[92vh] flex flex-col">
            {/* Modal Header */}
            <div className="px-6 py-4 bg-slate-50 border-b border-slate-200 flex items-center justify-between flex-shrink-0">
              <div className="flex items-center gap-3">
                <Megaphone className="w-5 h-5 text-brand-blue" />
                <h3 className="font-bold text-sm text-slate-800">
                  {editingAd ? 'जाहिरात संपादित करा' : 'नवीन जाहिरात तयार करा'}
                </h3>
              </div>

              <div className="flex items-center gap-2">
                <div className="bg-slate-200 p-0.5 rounded-lg flex items-center text-xs">
                  <button
                    type="button"
                    onClick={() => setPreviewMode('form')}
                    className={`px-3 py-1 rounded-md font-semibold transition ${
                      previewMode === 'form' ? 'bg-white text-slate-800 shadow-xs' : 'text-slate-600'
                    }`}
                  >
                    फॉर्म (Form)
                  </button>
                  <button
                    type="button"
                    onClick={() => setPreviewMode('preview')}
                    className={`px-3 py-1 rounded-md font-semibold transition ${
                      previewMode === 'preview' ? 'bg-white text-brand-blue shadow-xs' : 'text-slate-600'
                    }`}
                  >
                    थेट प्रीव्ह्यू (Preview)
                  </button>
                </div>
                <button
                  onClick={() => setIsModalOpen(false)}
                  className="text-slate-400 hover:text-slate-600 p-1.5 rounded-lg ml-1"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>
            </div>

            {/* Modal Body */}
            <div className="overflow-y-auto p-6 flex-1 text-xs">
              {previewMode === 'preview' ? (
                /* Interactive Live Preview */
                <div className="space-y-5">
                  <div className="p-3 bg-amber-50 border border-amber-200 rounded-xl text-amber-800 flex items-center gap-2">
                    <Eye className="w-4 h-4 text-amber-600 flex-shrink-0" />
                    <span>मोबाईल ॲपमध्ये गावकर्‍यांना ही जाहिरात अशी दिसेल:</span>
                  </div>

                  {/* Card Simulation */}
                  <div className="max-w-md mx-auto bg-white rounded-2xl border border-slate-200 shadow-lg overflow-hidden">
                    <div className="relative aspect-video bg-slate-100">
                      <img
                        src={formData.image_url}
                        alt="Preview"
                        className="w-full h-full object-cover"
                        onError={(e) => {
                          (e.target as any).src = 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800&auto=format&fit=crop&q=80';
                        }}
                      />
                      <div className="absolute top-2.5 left-2.5 bg-slate-900/80 backdrop-blur-xs text-white text-[10px] font-bold px-2 py-0.5 rounded-md flex items-center gap-1">
                        <Megaphone className="w-3 h-3 text-brand-yellow" />
                        <span>प्रायोजित • नरडाणा</span>
                      </div>
                    </div>

                    <div className="p-4 space-y-2">
                      <h4 className="font-bold text-sm text-slate-900 leading-snug">
                        {formData.title_mr || 'जाहिरातीचे मराठी शीर्षक'}
                      </h4>
                      <p className="text-[11px] text-slate-500 line-clamp-2">
                        {formData.description_mr || 'जाहिरातीचा तपशील येथे दिसेल.'}
                      </p>

                      <div className="pt-2 flex items-center gap-2">
                        {formData.phone && (
                          <div className="flex-1 px-3 py-2 bg-brand-blue text-white rounded-lg text-center font-bold text-xs flex items-center justify-center gap-1.5 shadow-sm">
                            <Phone className="w-3.5 h-3.5" /> कॉल करा
                          </div>
                        )}
                        {formData.whatsapp && (
                          <div className="flex-1 px-3 py-2 bg-emerald-600 text-white rounded-lg text-center font-bold text-xs flex items-center justify-center gap-1.5 shadow-sm">
                            <MessageSquare className="w-3.5 h-3.5" /> व्हॉट्सॲप
                          </div>
                        )}
                        {!formData.phone && !formData.whatsapp && (
                          <div className="w-full px-3 py-2 bg-slate-100 text-slate-700 rounded-lg text-center font-bold text-xs">
                            तपशील पहा
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              ) : (
                /* Input Form */
                <form id="ad-form" onSubmit={handleSubmit} className="space-y-4">
                  {/* Title Fields */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block font-semibold text-slate-700 mb-1">
                        जाहिरात शीर्षक (मराठीत) <span className="text-rose-500">*</span>
                      </label>
                      <input
                        type="text"
                        required
                        placeholder="उदा. श्री गजानन कृषी सेवा केंद्र, नरडाणा"
                        value={formData.title_mr}
                        onChange={(e) => setFormData({ ...formData, title_mr: e.target.value })}
                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                      />
                    </div>
                    <div>
                      <label className="block font-semibold text-slate-700 mb-1">
                        Ad Title (English) <span className="text-rose-500">*</span>
                      </label>
                      <input
                        type="text"
                        required
                        placeholder="e.g. Shri Gajanan Krishi Seva Kendra, Nardana"
                        value={formData.title_en}
                        onChange={(e) => setFormData({ ...formData, title_en: e.target.value })}
                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                      />
                    </div>
                  </div>

                  {/* Descriptions */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block font-semibold text-slate-700 mb-1">तपशील व ऑफर (मराठीत)</label>
                      <textarea
                        rows={2}
                        placeholder="उदा. रब्बी हंगामासाठी सेंद्रिय खतांवर खास सवलत. नरडाणा."
                        value={formData.description_mr}
                        onChange={(e) => setFormData({ ...formData, description_mr: e.target.value })}
                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                      />
                    </div>
                    <div>
                      <label className="block font-semibold text-slate-700 mb-1">Description (English)</label>
                      <textarea
                        rows={2}
                        placeholder="e.g. Special discounts on organic fertilizers. Nardana."
                        value={formData.description_en}
                        onChange={(e) => setFormData({ ...formData, description_en: e.target.value })}
                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                      />
                    </div>
                  </div>

                  {/* Image Banner Upload & URL */}
                  <div className="p-3.5 bg-slate-50 border border-slate-200 rounded-xl space-y-2.5">
                    <label className="block font-semibold text-slate-700">
                      बॅनर फोटो (Image Banner) <span className="text-rose-500">*</span>
                    </label>

                    <div className="flex flex-col sm:flex-row items-center gap-3">
                      <div className="w-24 h-16 rounded-lg overflow-hidden border border-slate-300 bg-white flex-shrink-0 shadow-xs">
                        <img
                          src={formData.image_url}
                          alt="Banner Preview"
                          className="w-full h-full object-cover"
                          onError={(e) => {
                            (e.target as any).src = 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=300&auto=format&fit=crop&q=80';
                          }}
                        />
                      </div>

                      <div className="flex-1 w-full space-y-2">
                        <div className="flex items-center gap-2">
                          <label className="cursor-pointer inline-flex items-center gap-1.5 px-3 py-1.5 bg-white border border-slate-300 rounded-lg text-slate-700 hover:bg-slate-100 font-semibold transition text-xs shadow-xs">
                            <Upload className="w-3.5 h-3.5 text-brand-blue" />
                            <span>{uploadingImage ? 'अपलोड होत आहे...' : 'फोटो अपलोड करा (Upload Image)'}</span>
                            <input
                              type="file"
                              accept="image/*"
                              disabled={uploadingImage}
                              onChange={handleImageUpload}
                              className="hidden"
                            />
                          </label>
                          <span className="text-[11px] text-slate-400">किंवा थेट इमेज लिंक टाका</span>
                        </div>

                        <input
                          type="url"
                          required
                          placeholder="https://... किंवा वरून फोटो निवडा"
                          value={formData.image_url}
                          onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
                          className="w-full px-3 py-1.5 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                        />
                      </div>
                    </div>
                  </div>

                  {/* Placement & Priority */}
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div>
                      <label className="block font-semibold text-slate-700 mb-1">
                        प्लेसमेंट (Ad Placement) <span className="text-rose-500">*</span>
                      </label>
                      <select
                        value={formData.placement}
                        onChange={(e) => setFormData({ ...formData, placement: e.target.value as any })}
                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs bg-white font-medium"
                      >
                        <option value="home_carousel">मुख्य कॅरोसेल (Home Carousel)</option>
                        <option value="sponsored_card">प्रायोजित कार्ड (Sponsored Card)</option>
                        <option value="category_banner">कॅटेगरी बॅनर (Category Banner)</option>
                        <option value="popup">पॉपअप बॅनर (Popup Banner)</option>
                      </select>
                    </div>

                    <div>
                      <label className="block font-semibold text-slate-700 mb-1">संबंधित कॅटेगरी (ऐच्छिक)</label>
                      <select
                        value={formData.category_id}
                        onChange={(e) => setFormData({ ...formData, category_id: e.target.value })}
                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs bg-white"
                      >
                        <option value="">सर्व प्रवर्गांसाठी (General)</option>
                        {categories.map((c) => (
                          <option key={c.id} value={c.id}>
                            {c.name_mr} ({c.name_en})
                          </option>
                        ))}
                      </select>
                    </div>

                    <div>
                      <label className="block font-semibold text-slate-700 mb-1">
                        प्राधान्यक्रम (Priority: 1-10)
                      </label>
                      <input
                        type="number"
                        min="0"
                        max="100"
                        value={formData.priority}
                        onChange={(e) => setFormData({ ...formData, priority: parseInt(e.target.value) || 0 })}
                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                      />
                    </div>
                  </div>

                  {/* Action Targets */}
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div>
                      <label className="block font-semibold text-slate-700 mb-1">कृती प्रकार (Target Type)</label>
                      <select
                        value={formData.target_type}
                        onChange={(e) => setFormData({ ...formData, target_type: e.target.value as any })}
                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs bg-white"
                      >
                        <option value="phone">थेट फोन कॉल (Phone Call)</option>
                        <option value="whatsapp">व्हॉट्सॲप मेसेज (WhatsApp)</option>
                        <option value="url">वेबसाईट लिंक (External URL)</option>
                        <option value="none">केवळ बॅनर (No Click Action)</option>
                      </select>
                    </div>

                    <div>
                      <label className="block font-semibold text-slate-700 mb-1">फोन नंबर (कॉलसाठी)</label>
                      <input
                        type="tel"
                        placeholder="उदा. 9823012345"
                        value={formData.phone}
                        onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                      />
                    </div>

                    <div>
                      <label className="block font-semibold text-slate-700 mb-1">व्हॉट्सॲप नंबर</label>
                      <input
                        type="tel"
                        placeholder="उदा. 9823012345"
                        value={formData.whatsapp}
                        onChange={(e) => setFormData({ ...formData, whatsapp: e.target.value })}
                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                      />
                    </div>
                  </div>

                  {formData.target_type === 'url' && (
                    <div>
                      <label className="block font-semibold text-slate-700 mb-1">वेबसाईट URL</label>
                      <input
                        type="url"
                        placeholder="https://example.com"
                        value={formData.target_url}
                        onChange={(e) => setFormData({ ...formData, target_url: e.target.value })}
                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                      />
                    </div>
                  )}

                  {/* Dates & Status */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block font-semibold text-slate-700 mb-1">
                        सुरू होण्याची तारीख (Start Date) <span className="text-rose-500">*</span>
                      </label>
                      <input
                        type="date"
                        required
                        value={formData.start_date}
                        onChange={(e) => setFormData({ ...formData, start_date: e.target.value })}
                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                      />
                    </div>

                    <div>
                      <label className="block font-semibold text-slate-700 mb-1">
                        समाप्ती तारीख (End Date) <span className="text-rose-500">*</span>
                      </label>
                      <input
                        type="date"
                        required
                        value={formData.end_date}
                        onChange={(e) => setFormData({ ...formData, end_date: e.target.value })}
                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                      />
                    </div>
                  </div>

                  {/* Advertiser Information */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-1">
                    <div>
                      <label className="block font-semibold text-slate-700 mb-1">जाहिरातदाराचे नाव</label>
                      <input
                        type="text"
                        placeholder="उदा. अशोक पाटील (नरडाणा)"
                        value={formData.advertiser_name}
                        onChange={(e) => setFormData({ ...formData, advertiser_name: e.target.value })}
                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                      />
                    </div>

                    <div>
                      <label className="block font-semibold text-slate-700 mb-1">जाहिरातदार संपर्क नंबर</label>
                      <input
                        type="tel"
                        placeholder="उदा. 9823012345"
                        value={formData.advertiser_contact}
                        onChange={(e) => setFormData({ ...formData, advertiser_contact: e.target.value })}
                        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                      />
                    </div>
                  </div>

                  {/* Active Toggle */}
                  <div className="flex items-center gap-2 pt-2 border-t border-slate-100">
                    <input
                      type="checkbox"
                      id="ad_is_active"
                      checked={formData.is_active}
                      onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                      className="rounded text-brand-blue focus:ring-brand-blue"
                    />
                    <label htmlFor="ad_is_active" className="text-slate-700 font-semibold cursor-pointer">
                      सक्रिय जाहिरात (ॲपमध्ये गावकर्‍यांना तत्काळ दर्शवा)
                    </label>
                  </div>
                </form>
              )}
            </div>

            {/* Modal Footer */}
            <div className="px-6 py-3.5 bg-slate-50 border-t border-slate-200 flex items-center justify-between flex-shrink-0">
              <div className="text-[11px] text-slate-500 flex items-center gap-1">
                <CheckCircle2 className="w-3.5 h-3.5 text-brand-green" />
                <span>केवळ नरडाणा गाव कार्यक्षेत्र</span>
              </div>

              <div className="flex items-center gap-2">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 border border-slate-200 text-slate-600 rounded-lg hover:bg-slate-100 font-medium text-xs"
                >
                  रद्द करा
                </button>
                <button
                  type="submit"
                  form="ad-form"
                  disabled={submitting}
                  className="px-4 py-2 bg-brand-blue text-white rounded-lg hover:bg-brand-dark font-semibold text-xs disabled:opacity-50 shadow-sm"
                >
                  {submitting ? 'जतन करत आहे...' : editingAd ? 'बदल सेव्ह करा' : 'जाहिरात प्रसिद्ध करा'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
      {/* View Advertisement Details Modal */}
      {viewingAd && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-lg w-full shadow-2xl overflow-hidden border border-slate-200">
            {/* Header */}
            <div className="px-6 py-4 bg-slate-50 border-b border-slate-200 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="p-2 bg-blue-100 rounded-lg text-brand-blue">
                  <Megaphone className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-bold text-base text-slate-900 leading-tight">
                    {viewingAd.title_mr}
                  </h3>
                  <p className="text-xs text-slate-500">
                    {viewingAd.advertiser_name ? `जाहिरातदार: ${viewingAd.advertiser_name}` : 'नरडाणा स्थानिक जाहिरात'}
                  </p>
                </div>
              </div>
              <button
                onClick={() => setViewingAd(null)}
                className="text-slate-400 hover:text-slate-600 p-1.5 rounded-lg hover:bg-slate-200 transition"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="p-6 space-y-4 text-xs text-slate-700 max-h-[75vh] overflow-y-auto">
              {/* Banner Preview */}
              <div className="w-full aspect-video rounded-xl overflow-hidden border border-slate-200 bg-slate-100 shadow-inner">
                <img
                  src={viewingAd.image_url}
                  alt={viewingAd.title_mr}
                  className="w-full h-full object-cover"
                  onError={(e) => {
                    (e.target as any).src = 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=600&auto=format&fit=crop&q=80';
                  }}
                />
              </div>

              {/* Badges & Placement */}
              <div className="flex flex-wrap items-center gap-2">
                {getPlacementBadge(viewingAd.placement)}
                <span className="px-2 py-0.5 rounded text-[11px] font-bold bg-slate-100 text-slate-700 border border-slate-200">
                  प्राधान्य: {viewingAd.priority}
                </span>
                <span className={`px-2 py-0.5 rounded text-[11px] font-bold ${
                  new Date(viewingAd.end_date) < new Date()
                    ? 'bg-rose-100 text-rose-800'
                    : viewingAd.is_active
                    ? 'bg-emerald-100 text-emerald-800'
                    : 'bg-slate-100 text-slate-600'
                }`}>
                  {new Date(viewingAd.end_date) < new Date()
                    ? 'मुदत संपली (Expired)'
                    : viewingAd.is_active
                    ? '✓ सक्रिय (Active)'
                    : 'निष्क्रिय (Inactive)'}
                </span>
              </div>

              {/* Real-time Analytics */}
              <div className="grid grid-cols-3 gap-2.5 p-3.5 bg-blue-50/60 rounded-xl border border-blue-200 text-center">
                <div>
                  <p className="text-[10px] text-slate-500 font-bold uppercase">इम्प्रेशन्स (Views)</p>
                  <p className="text-lg font-black text-brand-blue">{viewingAd.impressions_count || 0}</p>
                </div>
                <div className="border-x border-blue-200">
                  <p className="text-[10px] text-slate-500 font-bold uppercase">एकूण क्लिक्स</p>
                  <p className="text-lg font-black text-purple-700">{viewingAd.clicks_count || 0}</p>
                </div>
                <div>
                  <p className="text-[10px] text-slate-500 font-bold uppercase">CTR दर</p>
                  <p className="text-lg font-black text-emerald-700">
                    {(viewingAd.impressions_count || 0) > 0 
                      ? (((viewingAd.clicks_count || 0) / viewingAd.impressions_count) * 100).toFixed(1) 
                      : '0.0'}%
                  </p>
                </div>
              </div>

              {/* Titles & Descriptions */}
              <div className="space-y-2 bg-slate-50/70 p-4 rounded-xl border border-slate-100">
                <div>
                  <span className="text-[11px] text-slate-500 font-semibold">मराठी शीर्षक:</span>
                  <p className="font-bold text-slate-900 text-sm">{viewingAd.title_mr}</p>
                </div>
                {viewingAd.title_en && (
                  <div>
                    <span className="text-[11px] text-slate-500 font-semibold">English Title:</span>
                    <p className="text-slate-700">{viewingAd.title_en}</p>
                  </div>
                )}
                {viewingAd.description_mr && (
                  <div>
                    <span className="text-[11px] text-slate-500 font-semibold">मराठी मजकूर:</span>
                    <p className="text-slate-800 leading-relaxed whitespace-pre-line mt-0.5">{viewingAd.description_mr}</p>
                  </div>
                )}
                {viewingAd.description_en && (
                  <div>
                    <span className="text-[11px] text-slate-500 font-semibold">English Description:</span>
                    <p className="text-slate-600">{viewingAd.description_en}</p>
                  </div>
                )}
              </div>

              {/* Validity & Target */}
              <div className="space-y-1.5 p-3.5 bg-slate-50 rounded-xl border border-slate-200 text-xs">
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="text-slate-500">कालावधी (Validity):</span>
                  <span className="font-bold text-slate-800 font-mono">
                    {new Date(viewingAd.start_date).toLocaleDateString('mr-IN')} ते {new Date(viewingAd.end_date).toLocaleDateString('mr-IN')}
                  </span>
                </div>
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="text-slate-500">कृती प्रकार (Action):</span>
                  <span className="font-semibold text-slate-800">{viewingAd.target_type}</span>
                </div>
                {viewingAd.phone && (
                  <div className="flex justify-between py-1 border-b border-slate-200">
                    <span className="text-slate-500">फोन नंबर:</span>
                    <a href={`tel:${viewingAd.phone}`} className="font-mono font-bold text-brand-blue hover:underline">
                      {viewingAd.phone}
                    </a>
                  </div>
                )}
                {viewingAd.whatsapp && (
                  <div className="flex justify-between py-1 border-b border-slate-200">
                    <span className="text-slate-500">व्हॉट्सॲप नंबर:</span>
                    <a href={`https://wa.me/91${viewingAd.whatsapp}`} target="_blank" rel="noreferrer" className="font-mono font-bold text-emerald-600 hover:underline">
                      {viewingAd.whatsapp}
                    </a>
                  </div>
                )}
                {viewingAd.target_url && (
                  <div className="flex justify-between py-1">
                    <span className="text-slate-500">वेबसाईट:</span>
                    <a href={viewingAd.target_url} target="_blank" rel="noreferrer" className="text-brand-blue hover:underline truncate max-w-[200px]">
                      {viewingAd.target_url}
                    </a>
                  </div>
                )}
              </div>
            </div>

            {/* Footer */}
            <div className="px-6 py-3.5 bg-slate-50 border-t border-slate-200 flex items-center justify-between">
              <button
                onClick={() => {
                  const toEdit = viewingAd;
                  setViewingAd(null);
                  handleOpenEdit(toEdit);
                }}
                className="px-3.5 py-1.5 bg-brand-blue text-white rounded-lg hover:bg-brand-dark text-xs font-semibold inline-flex items-center gap-1 transition"
              >
                <Edit2 className="w-3.5 h-3.5" /> जाहिरात संपादित करा
              </button>
              <button
                onClick={() => setViewingAd(null)}
                className="px-4 py-1.5 bg-slate-200 text-slate-700 rounded-lg hover:bg-slate-300 text-xs font-semibold"
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

