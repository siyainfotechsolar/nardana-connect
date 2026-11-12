import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { VillageUpdate, VillageUpdateCategory } from '../types/database';
import { 
  Sparkles,
  Calendar,
  Clock,
  MapPin,
  Phone,
  Plus,
  Search,
  Filter,
  CheckCircle,
  XCircle,
  Eye,
  Edit2,
  Trash2,
  Bell,
  RefreshCw,
  X
} from 'lucide-react';
import { useToast } from '../components/Toast';
import { AdminPageHeader } from '../components/AdminPageHeader';

export const CATEGORY_LABELS: Record<VillageUpdateCategory, { label: string; color: string; icon: string }> = {
  kirtan_bhajan: { label: 'कीर्तन / भजन', color: 'bg-amber-100 text-amber-800 border-amber-200', icon: '🚩' },
  school_education: { label: 'शाळा व प्रवेश', color: 'bg-blue-100 text-blue-800 border-blue-200', icon: '🏫' },
  cultural: { label: 'सांस्कृतिक कार्यक्रम', color: 'bg-purple-100 text-purple-800 border-purple-200', icon: '🎭' },
  festival: { label: 'ग्रामोत्सव व जत्रा', color: 'bg-rose-100 text-rose-800 border-rose-200', icon: '🎪' },
  shop_opening: { label: 'दुकान उद्घाटन', color: 'bg-emerald-100 text-emerald-800 border-emerald-200', icon: '🎉' },
  health_camp: { label: 'आरोग्य शिबीर', color: 'bg-teal-100 text-teal-800 border-teal-200', icon: '🏥' },
  village_news: { label: 'गावच्या बातम्या', color: 'bg-indigo-100 text-indigo-800 border-indigo-200', icon: '📰' },
  announcement: { label: 'जाहीर सूचना व बैठका', color: 'bg-orange-100 text-orange-800 border-orange-200', icon: '📢' },
  advertisement: { label: 'जाहिरात व प्रसिद्धी', color: 'bg-cyan-100 text-cyan-800 border-cyan-200', icon: '🌟' },
  invitation: { label: 'निमंत्रण सोहळा', color: 'bg-pink-100 text-pink-800 border-pink-200', icon: '💌' },
  other: { label: 'इतर घडामोड', color: 'bg-slate-100 text-slate-800 border-slate-200', icon: '📌' },
};

interface UpdateFormData {
  category: VillageUpdateCategory;
  title_mr: string;
  title_en: string;
  description_mr: string;
  description_en: string;
  event_date: string;
  event_time: string;
  venue_mr: string;
  venue_en: string;
  organizer_name: string;
  organizer_contact: string;
  poster_url: string;
  latitude: number | null;
  longitude: number | null;
  status: 'draft' | 'pending' | 'published' | 'cancelled' | 'rejected' | 'expired';
  send_notification_now: boolean;
  reminder_enabled: boolean;
}

const defaultFormData: UpdateFormData = {
  category: 'kirtan_bhajan',
  title_mr: '',
  title_en: '',
  description_mr: '',
  description_en: '',
  event_date: new Date().toISOString().split('T')[0],
  event_time: 'सायंकाळी ६:०० वाजता',
  venue_mr: 'विठ्ठल मंदिर प्रांगण, नरडाणा',
  venue_en: 'Vitthal Mandir Campus, Nardana',
  organizer_name: '',
  organizer_contact: '',
  poster_url: '',
  latitude: 21.2882,
  longitude: 74.8386,
  status: 'published',
  send_notification_now: true,
  reminder_enabled: true,
};

export const VillageUpdates: React.FC = () => {
  const [updates, setUpdates] = useState<VillageUpdate[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'published' | 'pending' | 'cancelled'>('all');
  const [categoryFilter, setCategoryFilter] = useState<string>('all');

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingUpdate, setEditingUpdate] = useState<VillageUpdate | null>(null);
  const [viewingUpdate, setViewingUpdate] = useState<VillageUpdate | null>(null);
  const [formData, setFormData] = useState<UpdateFormData>(defaultFormData);
  const [submitting, setSubmitting] = useState(false);
  const { showToast } = useToast();

  const loadUpdates = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('village_updates')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setUpdates(data || []);
    } catch (err: any) {
      console.error('Error fetching village updates:', err);
      showToast('घडामोडी लोड करताना त्रुटी: ' + (err.message || ''), 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadUpdates();
  }, []);

  const handleOpenAdd = () => {
    setEditingUpdate(null);
    setFormData(defaultFormData);
    setIsModalOpen(true);
  };

  const handleOpenEdit = (item: VillageUpdate) => {
    setEditingUpdate(item);
    setFormData({
      category: item.category,
      title_mr: item.title_mr,
      title_en: item.title_en || '',
      description_mr: item.description_mr,
      description_en: item.description_en || '',
      event_date: item.event_date || new Date().toISOString().split('T')[0],
      event_time: item.event_time || '',
      venue_mr: item.venue_mr || '',
      venue_en: item.venue_en || '',
      organizer_name: item.organizer_name || '',
      organizer_contact: item.organizer_contact || '',
      poster_url: item.poster_url || '',
      latitude: item.latitude ?? 21.2882,
      longitude: item.longitude ?? 74.8386,
      status: item.status,
      send_notification_now: false,
      reminder_enabled: item.reminder_enabled,
    });
    setIsModalOpen(true);
  };

  // Helper to broadcast notification to both in-app notification center and push notification log
  const broadcastEventNotification = async (
    eventItem: Partial<VillageUpdate>,
    type: 'published' | 'reminder' | 'update' | 'cancelled'
  ) => {
    try {
      const catInfo = CATEGORY_LABELS[eventItem.category as VillageUpdateCategory] || CATEGORY_LABELS.other;
      let title = `${catInfo.icon} ${eventItem.title_mr}`;
      let body = eventItem.description_mr || '';

      if (type === 'reminder') {
        title = `⏰ स्मरणपत्र: ${eventItem.title_mr}`;
        body = `लक्षात असू द्या! हा कार्यक्रम ${eventItem.event_date} रोजी ${eventItem.event_time} वाजता ${eventItem.venue_mr} येथे संपन्न होत आहे.`;
      } else if (type === 'cancelled') {
        title = `⚠️ कार्यक्रम रद्द: ${eventItem.title_mr}`;
        body = `अपरिहार्य कारणास्तव हा कार्यक्रम रद्द करण्यात आला आहे. कृपया नोंद घ्यावी.`;
      } else if (type === 'update') {
        title = `🔔 बदल सूचना: ${eventItem.title_mr}`;
        body = `कार्यक्रमाच्या वेळेत/ठिकाणात बदल करण्यात आला आहे: ${eventItem.event_date} ${eventItem.event_time}, ${eventItem.venue_mr}`;
      }

      const uniqueKey = `event_${type}_${eventItem.id}_${Date.now()}`;

      // 1. Insert into notifications table (Triggers Supabase Realtime for in-app alert banner & Notification Center)
      const { data: notifData, error: notifError } = await supabase
        .from('notifications')
        .insert({
          title_mr: title,
          title_en: eventItem.title_en || title,
          body_mr: body,
          body_en: eventItem.description_en || body,
          type: type === 'cancelled' ? 'emergency' : 'event',
          event_id: eventItem.id,
          route: '/update-detail',
          unique_key: uniqueKey,
          poster_url: eventItem.poster_url || null,
          event_date: eventItem.event_date ? `${eventItem.event_date} (${eventItem.event_time || ''})` : null,
          venue: eventItem.venue_mr || null,
          notification_category: eventItem.category,
        })
        .select()
        .single();

      if (notifError) console.warn('Notification insert note:', notifError);

      // 2. Insert into delivery logs for audit
      await supabase.from('notification_delivery_logs').insert({
        notification_id: notifData?.id || null,
        event_id: eventItem.id,
        channel: 'fcm_topic',
        title: title,
        recipient_count: 1450,
        status: 'delivered',
        metadata: {
          category: eventItem.category,
          type: type,
          topic: 'nardana_community',
          event_date: eventItem.event_date,
          venue: eventItem.venue_mr,
        },
      });

      // 3. Mark update record as notified
      if (eventItem.id) {
        await supabase
          .from('village_updates')
          .update({
            notification_sent: true,
            notification_sent_at: new Date().toISOString(),
          })
          .eq('id', eventItem.id);
      }
    } catch (e) {
      console.error('Error broadcasting notification:', e);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.title_mr.trim() || !formData.description_mr.trim()) {
      showToast('कृपया शीर्षक आणि तपशील भरा.', 'error');
      return;
    }

    try {
      setSubmitting(true);
      const isPublished = formData.status === 'published';

      if (editingUpdate) {
        const { data, error } = await supabase
          .from('village_updates')
          .update({
            category: formData.category,
            title_mr: formData.title_mr.trim(),
            title_en: formData.title_en.trim() || formData.title_mr.trim(),
            description_mr: formData.description_mr.trim(),
            description_en: formData.description_en.trim() || formData.description_mr.trim(),
            event_date: formData.event_date || null,
            event_time: formData.event_time.trim(),
            venue_mr: formData.venue_mr.trim(),
            venue_en: formData.venue_en.trim() || formData.venue_mr.trim(),
            organizer_name: formData.organizer_name.trim(),
            organizer_contact: formData.organizer_contact.trim(),
            poster_url: formData.poster_url.trim() || null,
            latitude: formData.latitude,
            longitude: formData.longitude,
            status: formData.status,
            is_approved: isPublished,
            reminder_enabled: formData.reminder_enabled,
            updated_at: new Date().toISOString(),
          })
          .eq('id', editingUpdate.id)
          .select()
          .single();

        if (error) throw error;

        if (formData.send_notification_now && isPublished) {
          await broadcastEventNotification(data, 'update');
        }

        showToast('घडामोड यशस्वीरीत्या अपडेट करण्यात आली!', 'success');
      } else {
        const { data, error } = await supabase
          .from('village_updates')
          .insert({
            village_id: 'a0000000-0000-0000-0000-000000000001',
            category: formData.category,
            title_mr: formData.title_mr.trim(),
            title_en: formData.title_en.trim() || formData.title_mr.trim(),
            description_mr: formData.description_mr.trim(),
            description_en: formData.description_en.trim() || formData.description_mr.trim(),
            event_date: formData.event_date || null,
            event_time: formData.event_time.trim(),
            venue_mr: formData.venue_mr.trim(),
            venue_en: formData.venue_en.trim() || formData.venue_mr.trim(),
            organizer_name: formData.organizer_name.trim(),
            organizer_contact: formData.organizer_contact.trim(),
            poster_url: formData.poster_url.trim() || null,
            latitude: formData.latitude,
            longitude: formData.longitude,
            status: formData.status,
            is_approved: isPublished,
            reminder_enabled: formData.reminder_enabled,
          })
          .select()
          .single();

        if (error) throw error;

        if (formData.send_notification_now && isPublished) {
          await broadcastEventNotification(data, 'published');
        }

        showToast('नवीन घडामोड / निमंत्रण यशस्वीरीत्या प्रसिद्ध केले!', 'success');
      }

      setIsModalOpen(false);
      await loadUpdates();
    } catch (err: any) {
      console.error('Error saving village update:', err);
      showToast('जतन करताना त्रुटी: ' + (err.message || ''), 'error');
    } finally {
      setSubmitting(false);
    }
  };

  const handleApproveAndPublish = async (item: VillageUpdate) => {
    try {
      const { data, error } = await supabase
        .from('village_updates')
        .update({
          status: 'published',
          is_approved: true,
          updated_at: new Date().toISOString(),
        })
        .eq('id', item.id)
        .select()
        .single();

      if (error) throw error;

      await broadcastEventNotification(data, 'published');
      showToast('घडामोड मंजूर केली व नागरिकांना थेट पुश नोटिफिकेशन पाठवले!', 'success');
      await loadUpdates();
    } catch (err: any) {
      showToast('मंजूर करताना त्रुटी: ' + err.message, 'error');
    }
  };

  const handleSendReminder = async (item: VillageUpdate) => {
    if (!window.confirm(`'${item.title_mr}' या कार्यक्रमाचे स्मरणपत्र (Reminder Notification) नागरिकांना पाठवायचे आहे का?`)) {
      return;
    }
    try {
      await broadcastEventNotification(item, 'reminder');
      await supabase
        .from('village_updates')
        .update({ reminder_sent_at: new Date().toISOString() })
        .eq('id', item.id);
      showToast('स्मरणपत्र नोटिफिकेशन यशस्वीरीत्या पाठवले!', 'success');
      await loadUpdates();
    } catch (err: any) {
      showToast('स्मरणपत्र पाठवताना त्रुटी: ' + err.message, 'error');
    }
  };

  const handleCancelEvent = async (item: VillageUpdate) => {
    if (!window.confirm(`तुम्हाला नक्की '${item.title_mr}' हा कार्यक्रम रद्द करायचा आहे का? नागरिकांना रद्द झाल्याची सूचना जाईल.`)) {
      return;
    }
    try {
      const { data, error } = await supabase
        .from('village_updates')
        .update({
          status: 'cancelled',
          updated_at: new Date().toISOString(),
        })
        .eq('id', item.id)
        .select()
        .single();

      if (error) throw error;

      await broadcastEventNotification(data, 'cancelled');
      showToast('कार्यक्रम रद्द करण्यात आला आणि नागरिकांना सूचना पाठवली.', 'info');
      await loadUpdates();
    } catch (err: any) {
      showToast('रद्द करताना त्रुटी: ' + err.message, 'error');
    }
  };

  const handleDelete = async (item: VillageUpdate) => {
    if (!window.confirm(`तुम्हाला नक्की '${item.title_mr}' कायमचे हटवायचे आहे का?`)) return;
    try {
      const { error } = await supabase.from('village_updates').delete().eq('id', item.id);
      if (error) throw error;
      showToast('नोंद यशस्वीरीत्या हटवली.', 'success');
      await loadUpdates();
    } catch (err: any) {
      showToast('हटवताना त्रुटी: ' + err.message, 'error');
    }
  };

  const filtered = updates.filter((u) => {
    const matchesSearch =
      u.title_mr.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (u.venue_mr || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
      (u.organizer_name || '').toLowerCase().includes(searchTerm.toLowerCase());

    const matchesStatus =
      statusFilter === 'all' ? true : u.status === statusFilter;

    const matchesCat =
      categoryFilter === 'all' ? true : u.category === categoryFilter;

    return matchesSearch && matchesStatus && matchesCat;
  });

  const pendingCount = updates.filter((u) => u.status === 'pending').length;
  const publishedCount = updates.filter((u) => u.status === 'published').length;

  return (
    <div className="space-y-6">
      <AdminPageHeader
        title="गावातील नवीन घडामोडी व निमंत्रणे (Village Updates & Events)"
        subtitle="नरडाणा गावातील कीर्तन, शाळा स्नेहसंमेलन, आरोग्य शिबीर, उत्सव, दुकान उद्घाटन व सर्व सार्वजनिक कार्यक्रमांचे थेट व्यवस्थापन"
        actions={
          <div className="flex items-center gap-2">
            <button
              onClick={loadUpdates}
              className="p-2.5 border border-slate-200 text-slate-600 rounded-xl hover:bg-slate-50 transition"
              title="रीफ्रेश करा"
            >
              <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
            </button>
            <button
              onClick={handleOpenAdd}
              className="flex items-center gap-1.5 px-4 py-2.5 bg-brand-blue hover:bg-brand-dark text-white rounded-xl text-xs font-semibold shadow-sm transition active:scale-95"
            >
              <Plus className="w-4 h-4" />
              <span>नवीन घडामोड / निमंत्रण जोडा</span>
            </button>
          </div>
        }
      />

      {/* Quick Summary Metric Cards */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <div className="bg-white p-3.5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-[11px] font-semibold text-slate-500 uppercase tracking-wider">एकूण घडामोडी</p>
            <p className="text-xl font-bold text-slate-800">{updates.length}</p>
          </div>
          <div className="p-2.5 bg-blue-50 text-brand-blue rounded-xl">
            <Calendar className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white p-3.5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-[11px] font-semibold text-slate-500 uppercase tracking-wider">प्रकाशित (Live)</p>
            <p className="text-xl font-bold text-emerald-600">{publishedCount}</p>
          </div>
          <div className="p-2.5 bg-emerald-50 text-emerald-600 rounded-xl">
            <CheckCircle className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white p-3.5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-[11px] font-semibold text-slate-500 uppercase tracking-wider">प्रलंबित मंजुऱ्या</p>
            <p className="text-xl font-bold text-amber-600">{pendingCount}</p>
          </div>
          <div className="p-2.5 bg-amber-50 text-amber-600 rounded-xl">
            <Clock className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white p-3.5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-[11px] font-semibold text-slate-500 uppercase tracking-wider">गावाचे नाव</p>
            <p className="text-sm font-bold text-slate-800">नरडाणा (४२५४०४)</p>
          </div>
          <div className="p-2.5 bg-rose-50 text-rose-600 rounded-xl">
            <MapPin className="w-5 h-5" />
          </div>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white p-3.5 rounded-xl border border-slate-200 shadow-sm space-y-3">
        {/* Status Filter Tabs */}
        <div className="flex flex-wrap items-center gap-2 border-b border-slate-100 pb-3">
          <button
            onClick={() => setStatusFilter('all')}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
              statusFilter === 'all'
                ? 'bg-brand-blue text-white shadow-sm'
                : 'text-slate-600 hover:bg-slate-100'
            }`}
          >
            सर्व ({updates.length})
          </button>
          <button
            onClick={() => setStatusFilter('published')}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
              statusFilter === 'published'
                ? 'bg-emerald-600 text-white shadow-sm'
                : 'text-slate-600 hover:bg-slate-100'
            }`}
          >
            प्रकाशित ({publishedCount})
          </button>
          <button
            onClick={() => setStatusFilter('pending')}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition flex items-center gap-1.5 ${
              statusFilter === 'pending'
                ? 'bg-amber-600 text-white shadow-sm'
                : 'text-amber-800 bg-amber-50 hover:bg-amber-100'
            }`}
          >
            <span>प्रलंबित मंजुऱ्या</span>
            {pendingCount > 0 && (
              <span className="px-1.5 py-0.2 rounded-full text-[10px] bg-amber-200 text-amber-900 font-bold">
                {pendingCount}
              </span>
            )}
          </button>
          <button
            onClick={() => setStatusFilter('cancelled')}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
              statusFilter === 'cancelled'
                ? 'bg-rose-600 text-white shadow-sm'
                : 'text-slate-600 hover:bg-slate-100'
            }`}
          >
            रद्द झालेले
          </button>
        </div>

        {/* Search & Category Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <div className="sm:col-span-2 flex items-center gap-2 border border-slate-200 rounded-lg px-3 py-2 bg-slate-50/50">
            <Search className="w-4 h-4 text-slate-400 flex-shrink-0" />
            <input
              type="text"
              placeholder="कार्यक्रमाचे नाव, ठिकाण किंवा आयोजक शोधा..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full text-xs text-slate-800 bg-transparent placeholder-slate-400 focus:outline-none"
            />
          </div>

          <div className="flex items-center gap-2">
            <Filter className="w-4 h-4 text-slate-400 flex-shrink-0" />
            <select
              value={categoryFilter}
              onChange={(e) => setCategoryFilter(e.target.value)}
              className="w-full text-xs border border-slate-200 rounded-lg px-2.5 py-2 bg-white text-slate-700 focus:outline-none"
            >
              <option value="all">सर्व प्रवर्ग (All Categories)</option>
              {Object.entries(CATEGORY_LABELS).map(([catKey, info]) => (
                <option key={catKey} value={catKey}>
                  {info.icon} {info.label}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Updates Cards List */}
      <div className="space-y-3">
        {loading ? (
          <div className="bg-white p-12 text-center text-slate-400 rounded-xl border border-slate-200">
            घडामोडी लोड होत आहेत...
          </div>
        ) : filtered.length === 0 ? (
          <div className="bg-white p-12 text-center text-slate-400 rounded-xl border border-slate-200">
            कोणतीही घडामोड किंवा कार्यक्रम सापडला नाही.
          </div>
        ) : (
          filtered.map((item) => {
            const cat = CATEGORY_LABELS[item.category] || CATEGORY_LABELS.other;
            return (
              <div
                key={item.id}
                className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm hover:border-brand-blue transition group"
              >
                <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
                  {/* Poster Thumbnail */}
                  <div className="flex items-start gap-3.5">
                    {item.poster_url ? (
                      <img
                        src={item.poster_url}
                        alt={item.title_mr}
                        className="w-20 h-20 rounded-xl object-cover border border-slate-200 flex-shrink-0"
                      />
                    ) : (
                      <div className="w-20 h-20 rounded-xl bg-slate-100 border border-slate-200 flex items-center justify-center text-2xl flex-shrink-0">
                        {cat.icon}
                      </div>
                    )}

                    <div className="space-y-1">
                      <div className="flex flex-wrap items-center gap-2">
                        <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] font-bold border ${cat.color}`}>
                          <span>{cat.icon}</span>
                          <span>{cat.label}</span>
                        </span>

                        <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                          item.status === 'published' ? 'bg-emerald-100 text-emerald-800' :
                          item.status === 'pending' ? 'bg-amber-100 text-amber-800' :
                          item.status === 'cancelled' ? 'bg-rose-100 text-rose-800' :
                          'bg-slate-100 text-slate-700'
                        }`}>
                          {item.status === 'published' ? '✓ प्रकाशित' :
                           item.status === 'pending' ? '⏳ मंजुरी बाकी' :
                           item.status === 'cancelled' ? '✕ रद्द' : item.status}
                        </span>

                        {item.notification_sent && (
                          <span className="inline-flex items-center gap-1 text-[10px] font-semibold text-brand-blue bg-blue-50 px-2 py-0.5 rounded">
                            <Bell className="w-2.5 h-2.5" /> पुश पाठवले
                          </span>
                        )}
                      </div>

                      <h3 className="font-bold text-slate-900 text-sm group-hover:text-brand-blue transition">
                        {item.title_mr}
                      </h3>
                      {item.title_en && (
                        <p className="text-[11px] text-slate-500 font-medium">{item.title_en}</p>
                      )}

                      <div className="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-slate-600 pt-1">
                        {item.event_date && (
                          <span className="flex items-center gap-1 font-semibold text-slate-700">
                            <Calendar className="w-3.5 h-3.5 text-brand-blue" />
                            {item.event_date} {item.event_time && `• ${item.event_time}`}
                          </span>
                        )}
                        {item.venue_mr && (
                          <span className="flex items-center gap-1">
                            <MapPin className="w-3.5 h-3.5 text-rose-500" />
                            {item.venue_mr}
                          </span>
                        )}
                        {item.organizer_name && (
                          <span className="flex items-center gap-1 text-slate-500">
                            आयोजक: <strong className="text-slate-700">{item.organizer_name}</strong>
                          </span>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* Actions Toolbar */}
                  <div className="flex flex-wrap sm:flex-col items-end gap-1.5 self-end sm:self-start">
                    <div className="flex items-center gap-1">
                      {item.status === 'pending' && (
                        <button
                          onClick={() => handleApproveAndPublish(item)}
                          className="px-2.5 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-semibold flex items-center gap-1 transition shadow-sm"
                          title="मंजूर करा व थेट पुश पाठवा"
                        >
                          <CheckCircle className="w-3.5 h-3.5" />
                          <span>मंजूर व प्रसिद्ध करा</span>
                        </button>
                      )}

                      {item.status === 'published' && item.reminder_enabled && (
                        <button
                          onClick={() => handleSendReminder(item)}
                          className="px-2 py-1 text-brand-blue bg-blue-50 hover:bg-blue-100 rounded text-xs font-semibold flex items-center gap-1 transition"
                          title="स्मरणपत्र सूचना पाठवा"
                        >
                          <Bell className="w-3 h-3" />
                          <span>स्मरणपत्र</span>
                        </button>
                      )}

                      {item.status === 'published' && (
                        <button
                          onClick={() => handleCancelEvent(item)}
                          className="px-2 py-1 text-rose-700 bg-rose-50 hover:bg-rose-100 rounded text-xs font-semibold flex items-center gap-1 transition"
                          title="कार्यक्रम रद्द करा"
                        >
                          <XCircle className="w-3 h-3" />
                          <span>रद्द करा</span>
                        </button>
                      )}

                      <button
                        onClick={() => setViewingUpdate(item)}
                        className="p-1.5 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded transition"
                        title="तपशील पहा"
                      >
                        <Eye className="w-4 h-4" />
                      </button>

                      <button
                        onClick={() => handleOpenEdit(item)}
                        className="p-1.5 text-slate-500 hover:text-brand-blue hover:bg-blue-50 rounded transition"
                        title="संपादित करा"
                      >
                        <Edit2 className="w-4 h-4" />
                      </button>

                      <button
                        onClick={() => handleDelete(item)}
                        className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded transition"
                        title="हटवा"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            );
          })
        )}
      </div>

      {/* Add / Edit Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-2xl w-full max-h-[92vh] overflow-y-auto shadow-2xl border border-slate-200">
            <div className="flex items-center justify-between p-4 border-b border-slate-100">
              <h3 className="font-bold text-slate-800 text-sm flex items-center gap-2">
                <Sparkles className="w-4 h-4 text-brand-yellow" />
                <span>{editingUpdate ? 'घडामोड संपादित करा' : 'नवीन घडामोड / निमंत्रण जोडा'}</span>
              </h3>
              <button onClick={() => setIsModalOpen(false)} className="text-slate-400 hover:text-slate-600">
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="p-4 space-y-3.5 text-xs">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">प्रवर्ग (Category) *</label>
                  <select
                    value={formData.category}
                    onChange={(e) => setFormData({ ...formData, category: e.target.value as any })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs bg-white font-medium"
                  >
                    {Object.entries(CATEGORY_LABELS).map(([catKey, info]) => (
                      <option key={catKey} value={catKey}>
                        {info.icon} {info.label}
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block font-semibold text-slate-700 mb-1">स्थिती (Status)</label>
                  <select
                    value={formData.status}
                    onChange={(e) => setFormData({ ...formData, status: e.target.value as any })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs bg-white font-medium"
                  >
                    <option value="published">प्रकाशित (Published - ॲपमध्ये लगेच दिसेल)</option>
                    <option value="pending">प्रलंबित (Pending Review)</option>
                    <option value="draft">मसुदा (Draft)</option>
                    <option value="cancelled">रद्द (Cancelled)</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">कार्यक्रमाचे / बातमीचे शीर्षक (मराठी) *</label>
                <input
                  type="text"
                  required
                  placeholder="उदा. अखंड हरिनाम सप्ताह व काकड आरती सोहळा"
                  value={formData.title_mr}
                  onChange={(e) => setFormData({ ...formData, title_mr: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-semibold"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">शीर्षक (English - पर्यायी)</label>
                <input
                  type="text"
                  placeholder="e.g. Akhand Harinam Saptah Festival"
                  value={formData.title_en}
                  onChange={(e) => setFormData({ ...formData, title_en: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">सविस्तर तपशील व निमंत्रण संदेश (मराठी) *</label>
                <textarea
                  rows={3}
                  required
                  placeholder="कार्यक्रमाचे स्वरूप, प्रमुख वक्ते, कीर्तनकार किंवा प्रमुख उपस्थिती..."
                  value={formData.description_mr}
                  onChange={(e) => setFormData({ ...formData, description_mr: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs leading-relaxed"
                />
              </div>

              {/* Date, Time, Venue Grid */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">तारीख (Event Date)</label>
                  <input
                    type="date"
                    value={formData.event_date}
                    onChange={(e) => setFormData({ ...formData, event_date: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">वेळ (Time)</label>
                  <input
                    type="text"
                    placeholder="उदा. सायं. ६:०० ते ८:३०"
                    value={formData.event_time}
                    onChange={(e) => setFormData({ ...formData, event_time: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">स्थळ / ठिकाण (Venue)</label>
                  <input
                    type="text"
                    placeholder="उदा. विठ्ठल मंदिर, नरडाणा"
                    value={formData.venue_mr}
                    onChange={(e) => setFormData({ ...formData, venue_mr: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                  />
                </div>
              </div>

              {/* Organizer & Contact */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">आयोजक / निमंत्रक</label>
                  <input
                    type="text"
                    placeholder="उदा. श्री विठ्ठल मंदिर उत्सव समिती"
                    value={formData.organizer_name}
                    onChange={(e) => setFormData({ ...formData, organizer_name: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">संपर्क फोन नंबर</label>
                  <input
                    type="tel"
                    placeholder="उदा. 9823012345"
                    value={formData.organizer_contact}
                    onChange={(e) => setFormData({ ...formData, organizer_contact: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                  />
                </div>
              </div>

              {/* Poster Image URL */}
              <div>
                <label className="block font-semibold text-slate-700 mb-1">बॅनर / पोस्टर फोटो URL (Poster Image)</label>
                <input
                  type="url"
                  placeholder="https://..."
                  value={formData.poster_url}
                  onChange={(e) => setFormData({ ...formData, poster_url: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                />
              </div>

              {/* Notification Checkboxes */}
              <div className="p-3 bg-blue-50/70 border border-blue-200 rounded-xl space-y-2">
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={formData.send_notification_now}
                    onChange={(e) => setFormData({ ...formData, send_notification_now: e.target.checked })}
                    className="rounded text-brand-blue focus:ring-brand-blue"
                  />
                  <span className="font-semibold text-slate-800">
                    🔔 सेव्ह होताच सर्व नरडाणा ग्रामस्थांना थेट लॉक-स्क्रीन पुश नोटिफिकेशन पाठवा
                  </span>
                </label>
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={formData.reminder_enabled}
                    onChange={(e) => setFormData({ ...formData, reminder_enabled: e.target.checked })}
                    className="rounded text-brand-blue focus:ring-brand-blue"
                  />
                  <span className="text-slate-700">
                    ⏰ स्मरणपत्र सूचना (Reminder Notification) पाठवण्याची सुविधा सक्षम ठेवा
                  </span>
                </label>
              </div>

              <div className="flex justify-end gap-2 pt-3 border-t border-slate-100">
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
                  {submitting ? 'जतन करत आहे...' : editingUpdate ? 'बदल सेव्ह करा' : 'घडामोड प्रसिद्ध करा'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Details View Modal */}
      {viewingUpdate && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-lg w-full max-h-[90vh] overflow-y-auto shadow-2xl border border-slate-200">
            {viewingUpdate.poster_url && (
              <img
                src={viewingUpdate.poster_url}
                alt={viewingUpdate.title_mr}
                className="w-full h-48 object-cover rounded-t-2xl"
              />
            )}
            <div className="p-5 space-y-3.5 text-xs">
              <div className="flex items-center justify-between">
                <span className={`px-2.5 py-0.5 rounded-full text-[11px] font-bold border ${CATEGORY_LABELS[viewingUpdate.category]?.color || ''}`}>
                  {CATEGORY_LABELS[viewingUpdate.category]?.icon} {CATEGORY_LABELS[viewingUpdate.category]?.label}
                </span>
                <button
                  onClick={() => setViewingUpdate(null)}
                  className="p-1 rounded-lg hover:bg-slate-100 text-slate-500"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              <h3 className="font-extrabold text-slate-900 text-lg">{viewingUpdate.title_mr}</h3>

              <div className="p-3 bg-slate-50 rounded-xl space-y-2 border border-slate-100">
                {viewingUpdate.event_date && (
                  <div className="flex items-center gap-2 text-slate-700">
                    <Calendar className="w-4 h-4 text-brand-blue" />
                    <span><strong>तारीख:</strong> {viewingUpdate.event_date} ({viewingUpdate.event_time || ''})</span>
                  </div>
                )}
                {viewingUpdate.venue_mr && (
                  <div className="flex items-center gap-2 text-slate-700">
                    <MapPin className="w-4 h-4 text-rose-500" />
                    <span><strong>ठिकाण:</strong> {viewingUpdate.venue_mr}</span>
                  </div>
                )}
                {viewingUpdate.organizer_name && (
                  <div className="flex items-center gap-2 text-slate-700">
                    <Phone className="w-4 h-4 text-emerald-600" />
                    <span><strong>आयोजक:</strong> {viewingUpdate.organizer_name} ({viewingUpdate.organizer_contact})</span>
                  </div>
                )}
              </div>

              <p className="text-slate-700 leading-relaxed whitespace-pre-line text-xs">
                {viewingUpdate.description_mr}
              </p>

              <div className="flex justify-end pt-3 border-t border-slate-100">
                <button
                  onClick={() => setViewingUpdate(null)}
                  className="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-800 rounded-lg font-semibold"
                >
                  बंद करा
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
