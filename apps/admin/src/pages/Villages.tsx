import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { Village } from '../types/database';
import { MapPin, Plus, Check, X, Edit2, Trash2, Search } from 'lucide-react';
import { useToast } from '../components/Toast';

interface VillageFormData {
  name_mr: string;
  name_en: string;
  taluka: string;
  district: string;
  pincode: string;
  is_active: boolean;
}

const defaultFormData: VillageFormData = {
  name_mr: '',
  name_en: '',
  taluka: 'शिंदखेडा (Shindkheda)',
  district: 'धुळे (Dhule)',
  pincode: '425404',
  is_active: true,
};

export const Villages: React.FC = () => {
  const [villages, setVillages] = useState<Village[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingVillage, setEditingVillage] = useState<Village | null>(null);
  const [formData, setFormData] = useState<VillageFormData>(defaultFormData);
  const [submitting, setSubmitting] = useState(false);
  const { showToast } = useToast();

  async function fetchVillages() {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('villages')
        .select('*')
        .order('name_mr');

      if (error) throw error;
      setVillages(data || []);
    } catch (err: any) {
      console.error('Error fetching villages:', err);
      showToast('गावे लोड करण्यात त्रुटी: ' + (err.message || 'Error'), 'error');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchVillages();
  }, []);

  function handleOpenAdd() {
    setEditingVillage(null);
    setFormData(defaultFormData);
    setIsModalOpen(true);
  }

  function handleOpenEdit(village: Village) {
    setEditingVillage(village);
    setFormData({
      name_mr: village.name_mr,
      name_en: village.name_en,
      taluka: village.taluka,
      district: village.district,
      pincode: village.pincode,
      is_active: village.is_active,
    });
    setIsModalOpen(true);
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!formData.name_mr.trim() || !formData.name_en.trim()) {
      showToast('कृपया मराठी व इंग्रजी नाव भरा.', 'error');
      return;
    }

    try {
      setSubmitting(true);
      if (editingVillage) {
        const { error } = await supabase
          .from('villages')
          .update({
            name_mr: formData.name_mr.trim(),
            name_en: formData.name_en.trim(),
            taluka: formData.taluka.trim(),
            district: formData.district.trim(),
            pincode: formData.pincode.trim(),
            is_active: formData.is_active,
          })
          .eq('id', editingVillage.id);

        if (error) throw error;
        showToast('गावाची माहिती यशस्वीपणे अपडेट केली!', 'success');
      } else {
        const { error } = await supabase
          .from('villages')
          .insert({
            name_mr: formData.name_mr.trim(),
            name_en: formData.name_en.trim(),
            taluka: formData.taluka.trim(),
            district: formData.district.trim(),
            pincode: formData.pincode.trim(),
            is_active: formData.is_active,
          });

        if (error) throw error;
        showToast('नवीन गाव यशस्वीपणे जोडले!', 'success');
      }

      setIsModalOpen(false);
      fetchVillages();
    } catch (err: any) {
      console.error('Save error:', err);
      showToast('गाव सेव्ह करताना त्रुटी: ' + (err.message || ''), 'error');
    } finally {
      setSubmitting(false);
    }
  }

  async function handleToggleStatus(village: Village) {
    try {
      const nextStatus = !village.is_active;
      const { error } = await supabase
        .from('villages')
        .update({ is_active: nextStatus })
        .eq('id', village.id);

      if (error) throw error;
      setVillages(prev =>
        prev.map(v => (v.id === village.id ? { ...v, is_active: nextStatus } : v))
      );
      showToast(
        nextStatus ? `${village.name_mr} सक्रिय केले.` : `${village.name_mr} निष्क्रिय केले.`,
        'success'
      );
    } catch (err: any) {
      showToast('स्थिती बदलताना त्रुटी: ' + err.message, 'error');
    }
  }

  async function handleDelete(village: Village) {
    if (!window.confirm(`तुम्हाला नक्की '${village.name_mr}' हे गाव हटवायचे आहे का?`)) {
      return;
    }

    try {
      const { error } = await supabase
        .from('villages')
        .delete()
        .eq('id', village.id);

      if (error) throw error;
      setVillages(prev => prev.filter(v => v.id !== village.id));
      showToast(`${village.name_mr} गाव यशस्वीपणे हटवले.`, 'success');
    } catch (err: any) {
      showToast('गाव हटवताना त्रुटी (स्थानिक व्यवसाय लिंक असू शकतात): ' + err.message, 'error');
    }
  }

  const filteredVillages = villages.filter(v =>
    v.name_mr.toLowerCase().includes(searchTerm.toLowerCase()) ||
    v.name_en.toLowerCase().includes(searchTerm.toLowerCase()) ||
    v.taluka.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="space-y-5">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h2 className="text-xl font-bold text-slate-900">गाव व्यवस्थापन (Village Management)</h2>
          <p className="text-xs text-slate-500">
            नरडाणा आणि परिसरातील समाविष्ट गावांची यादी व नियंत्रण ({villages.length} गावे)
          </p>
        </div>
        <button
          onClick={handleOpenAdd}
          className="flex items-center justify-center space-x-1.5 px-4 py-2.5 bg-brand-blue text-white rounded-lg text-xs font-semibold hover:bg-brand-dark transition shadow-sm active:scale-95"
        >
          <Plus className="w-4 h-4" />
          <span>नवीन गाव जोडा</span>
        </button>
      </div>

      {/* Search Bar */}
      <div className="bg-white p-3 rounded-xl border border-slate-200 shadow-sm flex items-center gap-2">
        <Search className="w-4 h-4 text-slate-400" />
        <input
          type="text"
          placeholder="गावाच्या नावाने शोधा (उदा. नरडाणा, Waghadi)..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full text-xs text-slate-800 placeholder-slate-400 focus:outline-none"
        />
        {searchTerm && (
          <button onClick={() => setSearchTerm('')} className="text-slate-400 hover:text-slate-600 text-xs">
            रद्द करा
          </button>
        )}
      </div>

      {/* Village Table */}
      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
            <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
              <tr>
                <th className="px-5 py-3">गावाचे नाव (मराठी)</th>
                <th className="px-5 py-3">गाव (English)</th>
                <th className="px-5 py-3">तालुका</th>
                <th className="px-5 py-3">जिल्हा</th>
                <th className="px-5 py-3">पिनकोड</th>
                <th className="px-5 py-3">स्थिती</th>
                <th className="px-5 py-3 text-right">कृती</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {loading ? (
                <tr>
                  <td colSpan={7} className="px-5 py-8 text-center text-slate-400">माहिती लोड होत आहे...</td>
                </tr>
              ) : filteredVillages.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-5 py-8 text-center text-slate-400">
                    कोणतेही गाव सापडले नाही.
                  </td>
                </tr>
              ) : (
                filteredVillages.map((v) => (
                  <tr key={v.id} className="hover:bg-slate-50/70 transition">
                    <td className="px-5 py-3.5 font-bold text-slate-800 flex items-center gap-1.5">
                      <MapPin className="w-3.5 h-3.5 text-brand-green flex-shrink-0" />
                      <span>{v.name_mr}</span>
                    </td>
                    <td className="px-5 py-3.5 text-slate-600 font-medium">{v.name_en}</td>
                    <td className="px-5 py-3.5 text-slate-600">{v.taluka}</td>
                    <td className="px-5 py-3.5 text-slate-600">{v.district}</td>
                    <td className="px-5 py-3.5 text-slate-600 font-mono">{v.pincode}</td>
                    <td className="px-5 py-3.5">
                      <button
                        onClick={() => handleToggleStatus(v)}
                        title="स्थिती बदलण्यासाठी क्लिक करा"
                        className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-semibold transition ${
                          v.is_active
                            ? 'bg-emerald-100 text-emerald-800 hover:bg-emerald-200'
                            : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                        }`}
                      >
                        {v.is_active ? <Check className="w-3 h-3" /> : <X className="w-3 h-3" />}
                        <span>{v.is_active ? 'सक्रिय' : 'निष्क्रिय'}</span>
                      </button>
                    </td>
                    <td className="px-5 py-3.5 text-right space-x-1">
                      <button
                        onClick={() => handleOpenEdit(v)}
                        className="p-1.5 text-slate-600 hover:text-brand-blue hover:bg-blue-50 rounded transition"
                        title="संपादित करा"
                      >
                        <Edit2 className="w-3.5 h-3.5" />
                      </button>
                      <button
                        onClick={() => handleDelete(v)}
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

      {/* Add / Edit Village Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-md w-full shadow-2xl overflow-hidden border border-slate-200">
            <div className="px-6 py-4 bg-slate-50 border-b border-slate-200 flex items-center justify-between">
              <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
                <MapPin className="w-4 h-4 text-brand-green" />
                {editingVillage ? 'गाव माहिती संपादित करा' : 'नवीन गाव जोडा'}
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
                  गावाचे नाव (मराठीत) <span className="text-rose-500">*</span>
                </label>
                <input
                  type="text"
                  required
                  placeholder="उदा. नरडाणा, बेटावद, वाघाळी"
                  value={formData.name_mr}
                  onChange={(e) => setFormData({ ...formData, name_mr: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  Village Name (English) <span className="text-rose-500">*</span>
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Nardana, Betawad"
                  value={formData.name_en}
                  onChange={(e) => setFormData({ ...formData, name_en: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">तालुका</label>
                  <input
                    type="text"
                    value={formData.taluka}
                    onChange={(e) => setFormData({ ...formData, taluka: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">जिल्हा</label>
                  <input
                    type="text"
                    value={formData.district}
                    onChange={(e) => setFormData({ ...formData, district: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                  />
                </div>
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">पिनकोड</label>
                <input
                  type="text"
                  value={formData.pincode}
                  onChange={(e) => setFormData({ ...formData, pincode: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                />
              </div>

              <div className="flex items-center gap-2 pt-2">
                <input
                  type="checkbox"
                  id="is_active"
                  checked={formData.is_active}
                  onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                  className="rounded text-brand-blue focus:ring-brand-blue"
                />
                <label htmlFor="is_active" className="text-slate-700 font-medium cursor-pointer">
                  सक्रिय गाव (ॲपमध्ये गावकर्‍यांना निवडीसाठी उपलब्ध करा)
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
                  className="px-4 py-2 bg-brand-blue text-white rounded-lg hover:bg-brand-dark font-semibold disabled:opacity-50"
                >
                  {submitting ? 'जतन करत आहे...' : editingVillage ? 'बदल सेव्ह करा' : 'गाव जोडा'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
