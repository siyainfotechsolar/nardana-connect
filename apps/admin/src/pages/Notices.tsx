import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { Notice } from '../types/database';
import { 
  Bell, 
  Plus, 
  ShieldCheck, 
  Trash2, 
  Search, 
  Eye, 
  X, 
  Calendar, 
  MapPin 
} from 'lucide-react';
import { useToast } from '../components/Toast';

interface NoticeFormData {
  title_mr: string;
  title_en: string;
  description_mr: string;
  description_en: string;
  village_id: string;
  priority: 'normal' | 'high' | 'emergency';
  is_gram_panchayat: boolean;
  status: 'published' | 'draft';
}

const defaultFormData: NoticeFormData = {
  title_mr: '',
  title_en: '',
  description_mr: '',
  description_en: '',
  village_id: 'a0000000-0000-0000-0000-000000000001',
  priority: 'normal',
  is_gram_panchayat: true,
  status: 'published',
};

export const Notices: React.FC = () => {
  const [notices, setNotices] = useState<Notice[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [priorityFilter, setPriorityFilter] = useState<string>('all');

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [viewingNotice, setViewingNotice] = useState<Notice | null>(null);
  const [formData, setFormData] = useState<NoticeFormData>(defaultFormData);
  const [submitting, setSubmitting] = useState(false);

  const { showToast } = useToast();

  async function loadData() {
    try {
      setLoading(true);
      const noticesRes = await supabase
        .from('notices')
        .select('*')
        .order('published_date', { ascending: false });

      if (noticesRes.error) throw noticesRes.error;

      setNotices(noticesRes.data || []);
    } catch (err: any) {
      console.error('Error fetching notices:', err);
      showToast('सूचना लोड करताना त्रुटी: ' + (err.message || ''), 'error');
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
      village_id: 'a0000000-0000-0000-0000-000000000001',
    });
    setIsModalOpen(true);
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!formData.title_mr.trim() || !formData.description_mr.trim()) {
      showToast('कृपया सूचनेचे शीर्षक व माहिती भरा.', 'error');
      return;
    }

    try {
      setSubmitting(true);
      const { error } = await supabase
        .from('notices')
        .insert({
          title_mr: formData.title_mr.trim(),
          title_en: formData.title_en.trim() || formData.title_mr.trim(),
          description_mr: formData.description_mr.trim(),
          description_en: formData.description_en.trim() || formData.description_mr.trim(),
          village_id: 'a0000000-0000-0000-0000-000000000001',
          priority: formData.priority,
          is_gram_panchayat: formData.is_gram_panchayat,
          status: formData.status,
          published_date: new Date().toISOString(),
        });

      if (error) throw error;
      showToast('सूचना यशस्वीपणे प्रसिद्ध केली!', 'success');
      setIsModalOpen(false);
      loadData();
    } catch (err: any) {
      console.error('Save notice error:', err);
      showToast('सूचना प्रसिद्ध करताना त्रुटी: ' + (err.message || ''), 'error');
    } finally {
      setSubmitting(false);
    }
  }

  async function handleDelete(notice: Notice) {
    if (!window.confirm(`तुम्हाला नक्की '${notice.title_mr}' ही सूचना हटवायची आहे का?`)) {
      return;
    }

    try {
      const { error } = await supabase
        .from('notices')
        .delete()
        .eq('id', notice.id);

      if (error) throw error;
      setNotices(prev => prev.filter(n => n.id !== notice.id));
      showToast('सूचना यशस्वीपणे हटवली.', 'success');
    } catch (err: any) {
      showToast('हटवताना त्रुटी: ' + err.message, 'error');
    }
  }

  const getVillageName = (_vid: string) => {
    return 'नरडाणा';
  };

  const filteredNotices = notices.filter((n) => {
    const matchesSearch =
      n.title_mr.toLowerCase().includes(searchTerm.toLowerCase()) ||
      n.title_en.toLowerCase().includes(searchTerm.toLowerCase()) ||
      n.description_mr.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesPriority = priorityFilter === 'all' || n.priority === priorityFilter;
    return matchesSearch && matchesPriority;
  });

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h2 className="text-xl font-bold text-slate-900">गाव सूचना व घोषणा (Village Notices)</h2>
          <p className="text-xs text-slate-500">
            ग्रामपंचायत अधिकृत घोषणा, पाणीपुरवठा व वीज खंडित होण्याबाबत संदेश व्यवस्थापन ({notices.length} सूचना)
          </p>
        </div>
        <button
          onClick={handleOpenAdd}
          className="flex items-center justify-center space-x-1.5 px-4 py-2.5 bg-brand-green text-white rounded-lg text-xs font-semibold hover:bg-emerald-700 transition shadow-sm active:scale-95"
        >
          <Plus className="w-4 h-4" />
          <span>नवीन सूचना प्रसिद्ध करा</span>
        </button>
      </div>

      {/* Search & Filters */}
      <div className="bg-white p-3.5 rounded-xl border border-slate-200 shadow-sm flex flex-col sm:flex-row gap-3 items-center justify-between">
        <div className="flex items-center gap-2 w-full sm:w-80">
          <Search className="w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="सूचनेचे शीर्षक किंवा माहिती शोधा..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full text-xs text-slate-800 placeholder-slate-400 focus:outline-none"
          />
        </div>

        <div className="flex items-center gap-2 w-full sm:w-auto">
          <span className="text-xs text-slate-500 font-medium">प्राधान्य:</span>
          <select
            value={priorityFilter}
            onChange={(e) => setPriorityFilter(e.target.value)}
            className="text-xs border border-slate-200 rounded-lg px-2.5 py-1.5 bg-white text-slate-700 focus:outline-none"
          >
            <option value="all">सर्व सूचना (All)</option>
            <option value="emergency">तातडीची (Emergency)</option>
            <option value="high">महत्त्वाची (High)</option>
            <option value="normal">सामान्य (Normal)</option>
          </select>
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
            <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
              <tr>
                <th className="px-5 py-3">सूचनेचे शीर्षक (मराठी)</th>
                <th className="px-5 py-3">गाव</th>
                <th className="px-5 py-3">प्राधान्य</th>
                <th className="px-5 py-3">प्रकार (Authority)</th>
                <th className="px-5 py-3">तारीख</th>
                <th className="px-5 py-3">स्थिती</th>
                <th className="px-5 py-3 text-right">कृती</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {loading ? (
                <tr>
                  <td colSpan={7} className="px-5 py-8 text-center text-slate-400">माहिती लोड होत आहे...</td>
                </tr>
              ) : filteredNotices.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-5 py-8 text-center text-slate-400">
                    कोणत्याही सूचना उपलब्ध नाहीत.
                  </td>
                </tr>
              ) : (
                filteredNotices.map((n) => (
                  <tr key={n.id} className="hover:bg-slate-50/70 transition">
                    <td className="px-5 py-3.5">
                      <p className="font-bold text-slate-800 flex items-center gap-1.5">
                        <Bell className="w-3.5 h-3.5 text-brand-yellow flex-shrink-0" />
                        <span>{n.title_mr}</span>
                      </p>
                      <p className="text-[11px] text-slate-500 truncate max-w-xs">{n.description_mr}</p>
                    </td>
                    <td className="px-5 py-3.5 text-slate-600">
                      <span className="flex items-center gap-1">
                        <MapPin className="w-3 h-3 text-brand-blue" /> {getVillageName(n.village_id)}
                      </span>
                    </td>
                    <td className="px-5 py-3.5">
                      <span className={`px-2 py-0.5 rounded text-[11px] font-semibold ${
                        n.priority === 'emergency' ? 'bg-red-100 text-red-800 font-bold animate-pulse' :
                        n.priority === 'high' ? 'bg-amber-100 text-amber-800 font-bold' :
                        'bg-slate-100 text-slate-700'
                      }`}>
                        {n.priority === 'emergency' ? '🚨 तातडीची' : n.priority === 'high' ? '⚠️ महत्त्वाची' : 'सामान्य'}
                      </span>
                    </td>
                    <td className="px-5 py-3.5">
                      {n.is_gram_panchayat ? (
                        <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-emerald-100 text-emerald-800">
                          <ShieldCheck className="w-3 h-3" /> ग्रामपंचायत अधिकृत
                        </span>
                      ) : (
                        <span className="text-slate-500 text-[11px]">सार्वजनिक</span>
                      )}
                    </td>
                    <td className="px-5 py-3.5 text-slate-500">
                      <span className="flex items-center gap-1">
                        <Calendar className="w-3 h-3 text-slate-400" />
                        {new Date(n.published_date).toLocaleDateString('mr-IN')}
                      </span>
                    </td>
                    <td className="px-5 py-3.5">
                      <span className="px-2 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-100 text-emerald-800">
                        {n.status === 'published' ? 'प्रसिद्ध' : n.status}
                      </span>
                    </td>
                    <td className="px-5 py-3.5 text-right space-x-1">
                      <button
                        onClick={() => setViewingNotice(n)}
                        className="p-1.5 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded transition"
                        title="वाचा / तपशील"
                      >
                        <Eye className="w-3.5 h-3.5" />
                      </button>
                      <button
                        onClick={() => handleDelete(n)}
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

      {/* Add Notice Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-lg w-full max-h-[90vh] overflow-y-auto shadow-2xl border border-slate-200">
            <div className="px-6 py-4 bg-slate-50 border-b border-slate-200 flex items-center justify-between sticky top-0 bg-slate-50 z-10">
              <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
                <Bell className="w-4 h-4 text-brand-green" /> नवीन गाव सूचना प्रसिद्ध करा
              </h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1 rounded"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="p-6 space-y-4 text-xs">
              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  सूचनेचे शीर्षक (मराठीत) <span className="text-rose-500">*</span>
                </label>
                <input
                  type="text"
                  required
                  placeholder="उदा. उद्या नरडाणा गावात पाणीपुरवठा बंद राहील"
                  value={formData.title_mr}
                  onChange={(e) => setFormData({ ...formData, title_mr: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  Title (English)
                </label>
                <input
                  type="text"
                  placeholder="e.g. Water Supply Interruption Notice for Tomorrow"
                  value={formData.title_en}
                  onChange={(e) => setFormData({ ...formData, title_en: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">गाव (Village)</label>
                  <div className="w-full px-3 py-2 border border-slate-200 rounded-lg bg-slate-50 text-xs font-bold text-slate-700 flex items-center gap-1.5">
                    <MapPin className="w-3.5 h-3.5 text-brand-blue" />
                    <span>नरडाणा (Nardana - 425404)</span>
                  </div>
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">प्राधान्य (Priority)</label>
                  <select
                    value={formData.priority}
                    onChange={(e) => setFormData({ ...formData, priority: e.target.value as any })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs bg-white font-medium"
                  >
                    <option value="normal">सामान्य (Normal)</option>
                    <option value="high">महत्त्वाची (High)</option>
                    <option value="emergency">🚨 तातडीची / आणीबाणी (Emergency)</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  संपूर्ण सूचना मजकूर (मराठीत) <span className="text-rose-500">*</span>
                </label>
                <textarea
                  rows={4}
                  required
                  placeholder="सूचनेचे सविस्तर स्पष्टीकरण, वेळ, संपर्क अधिकारी..."
                  value={formData.description_mr}
                  onChange={(e) => setFormData({ ...formData, description_mr: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                />
              </div>

              <div className="flex items-center gap-2 pt-1">
                <input
                  type="checkbox"
                  id="gp_badge"
                  checked={formData.is_gram_panchayat}
                  onChange={(e) => setFormData({ ...formData, is_gram_panchayat: e.target.checked })}
                  className="rounded text-brand-green focus:ring-brand-green"
                />
                <label htmlFor="gp_badge" className="text-slate-700 font-medium cursor-pointer">
                  ग्रामपंचायत अधिकृत शिक्का / बॅज लावा
                </label>
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
                  className="px-4 py-2 bg-brand-green text-white rounded-lg hover:bg-emerald-700 font-semibold disabled:opacity-50"
                >
                  {submitting ? 'प्रसिद्ध करत आहे...' : 'सूचना प्रसिद्ध करा'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* View Notice Modal */}
      {viewingNotice && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-lg w-full shadow-2xl overflow-hidden border border-slate-200 p-6 space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <h3 className="font-bold text-base text-slate-900 flex items-center gap-2">
                <Bell className="w-5 h-5 text-brand-green" />
                {viewingNotice.title_mr}
              </h3>
              <button
                onClick={() => setViewingNotice(null)}
                className="text-slate-400 hover:text-slate-600 p-1 rounded"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-3 text-xs text-slate-700">
              <div className="flex flex-wrap gap-2 items-center">
                <span className="px-2 py-0.5 rounded bg-blue-50 text-blue-800 font-medium">
                  गाव: {getVillageName(viewingNotice.village_id)}
                </span>
                <span className={`px-2 py-0.5 rounded font-bold ${
                  viewingNotice.priority === 'emergency' ? 'bg-red-100 text-red-800' :
                  viewingNotice.priority === 'high' ? 'bg-amber-100 text-amber-800' :
                  'bg-slate-100 text-slate-700'
                }`}>
                  {viewingNotice.priority}
                </span>
                {viewingNotice.is_gram_panchayat && (
                  <span className="px-2 py-0.5 rounded bg-emerald-100 text-emerald-800 font-semibold flex items-center gap-1">
                    <ShieldCheck className="w-3 h-3" /> ग्रामपंचायत अधिकृत
                  </span>
                )}
              </div>

              <div className="bg-slate-50 p-4 rounded-xl border border-slate-100 text-xs leading-relaxed text-slate-800 whitespace-pre-line">
                {viewingNotice.description_mr}
              </div>

              {viewingNotice.description_en && (
                <div className="text-[11px] text-slate-500">
                  <p className="font-semibold text-slate-700 mb-0.5">English Summary:</p>
                  <p>{viewingNotice.description_en}</p>
                </div>
              )}

              <p className="text-[11px] text-slate-400">
                प्रसिद्ध दिनांक: {new Date(viewingNotice.published_date).toLocaleString('mr-IN')}
              </p>
            </div>

            <div className="flex justify-end gap-2 pt-3 border-t border-slate-100">
              <button
                onClick={() => setViewingNotice(null)}
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
