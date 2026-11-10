import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { Village } from '../types/database';
import { MapPin, Check, X, Edit2, Eye } from 'lucide-react';
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
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingVillage, setEditingVillage] = useState<Village | null>(null);
  const [viewingVillage, setViewingVillage] = useState<Village | null>(null);
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

  const filteredVillages = villages;

  return (
    <div className="space-y-5">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h2 className="text-xl font-bold text-slate-900">गाव माहिती (Village Profile)</h2>
          <p className="text-xs text-slate-500">
            नरडाणा गाव - अधिकृत भौगोलिक माहिती व प्रोफाइल (Exclusively Nardana Village)
          </p>
        </div>
        <div className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-emerald-50 text-emerald-800 text-xs font-semibold border border-emerald-200">
          <Check className="w-3.5 h-3.5 text-emerald-600" />
          <span>अधिकृत कार्यक्षेत्र: नरडाणा (एकमेव गाव)</span>
        </div>
      </div>

      {/* Scope Notice Card */}
      <div className="bg-blue-50 border border-blue-200 rounded-xl p-4 text-xs text-slate-700 flex items-start gap-3">
        <MapPin className="w-5 h-5 text-brand-blue flex-shrink-0 mt-0.5" />
        <div className="space-y-1">
          <p className="font-bold text-brand-blue">नरडाणा कनेक्ट धोरण (Nardana Only Policy):</p>
          <p className="text-slate-600 leading-relaxed">
            हे ॲप्लिकेशन आणि व्यवस्थापन पॅनेल केवळ <strong>नरडाणा गावासाठी</strong> कार्यरत आहे. सर्व दुकाने, रोजगार, सूचना आणि आणीबाणी सेवा नरडाणा गावाशीच संबंधित आहेत. इतर कोणतेही गाव जोडण्याची आवश्यकता नाही.
          </p>
        </div>
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
                  <tr 
                    key={v.id} 
                    onClick={() => setViewingVillage(v)} 
                    className="hover:bg-blue-50/70 transition cursor-pointer group"
                    title="सविस्तर गाव प्रोफाइल पाहण्यासाठी क्लिक करा"
                  >
                    <td className="px-5 py-3.5 font-bold text-slate-800">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-1.5 group-hover:text-brand-blue transition">
                          <MapPin className="w-3.5 h-3.5 text-brand-green flex-shrink-0" />
                          <span>{v.name_mr}</span>
                        </div>
                        <span className="text-[10px] text-brand-blue bg-blue-100 font-semibold px-2 py-0.5 rounded opacity-0 group-hover:opacity-100 transition mr-2">
                          तपशील ↗
                        </span>
                      </div>
                    </td>
                    <td className="px-5 py-3.5 text-slate-600 font-medium">{v.name_en}</td>
                    <td className="px-5 py-3.5 text-slate-600">{v.taluka}</td>
                    <td className="px-5 py-3.5 text-slate-600">{v.district}</td>
                    <td className="px-5 py-3.5 text-slate-600 font-mono">{v.pincode}</td>
                    <td className="px-5 py-3.5" onClick={(e) => e.stopPropagation()}>
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
                    <td className="px-5 py-3.5 text-right space-x-1" onClick={(e) => e.stopPropagation()}>
                      <button
                        onClick={() => setViewingVillage(v)}
                        className="px-2.5 py-1.5 text-xs font-semibold text-slate-700 hover:text-brand-blue hover:bg-blue-50 rounded-lg border border-slate-200 transition inline-flex items-center gap-1"
                        title="तपशील पहा"
                      >
                        <Eye className="w-3.5 h-3.5" />
                        <span>तपशील</span>
                      </button>
                      <button
                        onClick={() => handleOpenEdit(v)}
                        className="px-2.5 py-1.5 text-xs font-semibold text-slate-700 hover:text-brand-blue hover:bg-blue-50 rounded-lg border border-slate-200 transition inline-flex items-center gap-1"
                        title="संपादित करा"
                      >
                        <Edit2 className="w-3.5 h-3.5" />
                        <span>बदला</span>
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
                नरडाणा गाव माहिती संपादित करा
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
                  readOnly
                  value={formData.name_mr}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg bg-slate-50 font-bold text-slate-800 text-xs"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  Village Name (English) <span className="text-rose-500">*</span>
                </label>
                <input
                  type="text"
                  required
                  readOnly
                  value={formData.name_en}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg bg-slate-50 font-bold text-slate-800 text-xs"
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
      {/* View Village Profile Modal */}
      {viewingVillage && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-md w-full shadow-2xl overflow-hidden border border-slate-200">
            <div className="px-6 py-4 bg-slate-50 border-b border-slate-200 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="p-2 bg-emerald-100 rounded-lg text-brand-green">
                  <MapPin className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-bold text-base text-slate-900 leading-tight">
                    {viewingVillage.name_mr} गाव प्रोफाइल
                  </h3>
                  <p className="text-xs text-slate-500">{viewingVillage.name_en} Profile</p>
                </div>
              </div>
              <button
                onClick={() => setViewingVillage(null)}
                className="text-slate-400 hover:text-slate-600 p-1.5 rounded-lg hover:bg-slate-200 transition"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="p-6 space-y-4 text-xs text-slate-700">
              <div className="p-3.5 bg-emerald-50 rounded-xl border border-emerald-200 flex items-center gap-2.5">
                <Check className="w-4 h-4 text-emerald-700 flex-shrink-0" />
                <span className="text-emerald-900 font-bold text-xs">
                  अधिकृत कार्यक्षेत्र: नरडाणा गाव (पिनकोड: ४२५४०४)
                </span>
              </div>

              <div className="space-y-2 bg-slate-50 p-4 rounded-xl border border-slate-200">
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="text-slate-500">गावाचे नाव (मराठी):</span>
                  <span className="font-bold text-slate-900">{viewingVillage.name_mr}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="text-slate-500">Name (English):</span>
                  <span className="font-semibold text-slate-800">{viewingVillage.name_en}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="text-slate-500">तालुका:</span>
                  <span className="font-bold text-slate-800">{viewingVillage.taluka}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="text-slate-500">जिल्हा:</span>
                  <span className="font-bold text-slate-800">{viewingVillage.district}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="text-slate-500">पिनकोड (Postal PIN):</span>
                  <span className="font-mono font-bold text-brand-blue text-sm">{viewingVillage.pincode}</span>
                </div>
                <div className="flex justify-between py-1">
                  <span className="text-slate-500">स्थिती:</span>
                  <span className="px-2 py-0.5 rounded text-[11px] font-bold bg-emerald-100 text-emerald-800">
                    सक्रिय (Active)
                  </span>
                </div>
              </div>

              <div className="p-3 bg-blue-50/70 border border-blue-200 rounded-xl text-slate-600 text-[11px] leading-relaxed">
                नरडाणा कनेक्ट हे व्यासपीठ केवळ नरडाणा गावातील स्थानिक दुकाने, रोजगार, शेती अवजारे आणि ग्रामपंचायत सूचनांसाठी कार्यरत आहे.
              </div>
            </div>

            <div className="px-6 py-3.5 bg-slate-50 border-t border-slate-200 flex items-center justify-between">
              <button
                onClick={() => {
                  const toEdit = viewingVillage;
                  setViewingVillage(null);
                  handleOpenEdit(toEdit);
                }}
                className="px-3.5 py-1.5 bg-slate-100 text-slate-700 hover:bg-slate-200 rounded-lg text-xs font-semibold inline-flex items-center gap-1 transition"
              >
                <Edit2 className="w-3.5 h-3.5" /> माहिती बदला
              </button>
              <button
                onClick={() => setViewingVillage(null)}
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
