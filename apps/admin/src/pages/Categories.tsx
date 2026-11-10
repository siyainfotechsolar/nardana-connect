import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { Category } from '../types/database';
import { Layers, Plus, Check, X, Edit2, Trash2, Search, Filter, Eye, ArrowRight } from 'lucide-react';
import { useToast } from '../components/Toast';

interface CategoryFormData {
  name_mr: string;
  name_en: string;
  slug: string;
  group_type: string;
  icon: string;
  sort_order: number;
  is_active: boolean;
}

const defaultFormData: CategoryFormData = {
  name_mr: '',
  name_en: '',
  slug: '',
  group_type: 'services',
  icon: 'briefcase',
  sort_order: 10,
  is_active: true,
};

const groupTypeOptions = [
  { value: 'all', label: 'सर्व ग्रुप (All)' },
  { value: 'shops', label: 'दुकाने (Shops)' },
  { value: 'services', label: 'घरगुती व तंत्रज्ञान सेवा (Services)' },
  { value: 'agriculture', label: 'कृषी व शेती सेवा (Agriculture)' },
  { value: 'health', label: 'आरोग्य व औषध (Health)' },
  { value: 'transport', label: 'वाहतूक व वाहने (Transport)' },
  { value: 'education', label: 'शिक्षण व इतर (Education)' },
];

export const Categories: React.FC = () => {
  const navigate = useNavigate();
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedGroup, setSelectedGroup] = useState('all');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingCategory, setEditingCategory] = useState<Category | null>(null);
  const [viewingCategory, setViewingCategory] = useState<Category | null>(null);
  const [formData, setFormData] = useState<CategoryFormData>(defaultFormData);
  const [submitting, setSubmitting] = useState(false);
  const { showToast } = useToast();

  async function fetchCategories() {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('categories')
        .select('*')
        .order('sort_order');

      if (error) throw error;
      setCategories(data || []);
    } catch (err: any) {
      console.error('Error fetching categories:', err);
      showToast('कॅटेगरी लोड करण्यात त्रुटी: ' + (err.message || ''), 'error');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchCategories();
  }, []);

  function handleOpenAdd() {
    setEditingCategory(null);
    setFormData({
      ...defaultFormData,
      sort_order: (categories.length + 1) * 10,
    });
    setIsModalOpen(true);
  }

  function handleOpenEdit(cat: Category) {
    setEditingCategory(cat);
    setFormData({
      name_mr: cat.name_mr,
      name_en: cat.name_en,
      slug: cat.slug,
      group_type: cat.group_type,
      icon: cat.icon,
      sort_order: cat.sort_order,
      is_active: cat.is_active,
    });
    setIsModalOpen(true);
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!formData.name_mr.trim() || !formData.name_en.trim()) {
      showToast('कृपया मराठी व इंग्रजी नाव भरा.', 'error');
      return;
    }

    const slug =
      formData.slug.trim() ||
      formData.name_en.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');

    try {
      setSubmitting(true);
      if (editingCategory) {
        const { error } = await supabase
          .from('categories')
          .update({
            name_mr: formData.name_mr.trim(),
            name_en: formData.name_en.trim(),
            slug: slug,
            group_type: formData.group_type,
            icon: formData.icon.trim() || 'tag',
            sort_order: Number(formData.sort_order),
            is_active: formData.is_active,
          })
          .eq('id', editingCategory.id);

        if (error) throw error;
        showToast('कॅटेगरी यशस्वीपणे अपडेट केली!', 'success');
      } else {
        const { error } = await supabase
          .from('categories')
          .insert({
            name_mr: formData.name_mr.trim(),
            name_en: formData.name_en.trim(),
            slug: slug,
            group_type: formData.group_type,
            icon: formData.icon.trim() || 'tag',
            sort_order: Number(formData.sort_order),
            is_active: formData.is_active,
          });

        if (error) throw error;
        showToast('नवीन कॅटेगरी यशस्वीपणे जोडली!', 'success');
      }

      setIsModalOpen(false);
      fetchCategories();
    } catch (err: any) {
      console.error('Save error:', err);
      showToast('कॅटेगरी सेव्ह करताना त्रुटी: ' + (err.message || ''), 'error');
    } finally {
      setSubmitting(false);
    }
  }

  async function handleToggleStatus(cat: Category) {
    try {
      const nextStatus = !cat.is_active;
      const { error } = await supabase
        .from('categories')
        .update({ is_active: nextStatus })
        .eq('id', cat.id);

      if (error) throw error;
      setCategories(prev =>
        prev.map(c => (c.id === cat.id ? { ...c, is_active: nextStatus } : c))
      );
      showToast(
        nextStatus ? `${cat.name_mr} सक्रिय केली.` : `${cat.name_mr} निष्क्रिय केली.`,
        'success'
      );
    } catch (err: any) {
      showToast('स्थिती बदलताना त्रुटी: ' + err.message, 'error');
    }
  }

  async function handleDelete(cat: Category) {
    if (!window.confirm(`तुम्हाला नक्की '${cat.name_mr}' ही कॅटेगरी हटवायची आहे का?`)) {
      return;
    }

    try {
      const { error } = await supabase
        .from('categories')
        .delete()
        .eq('id', cat.id);

      if (error) throw error;
      setCategories(prev => prev.filter(c => c.id !== cat.id));
      showToast(`${cat.name_mr} कॅटेगरी यशस्वीपणे हटवली.`, 'success');
    } catch (err: any) {
      showToast('कॅटेगरी हटवताना त्रुटी (व्यवसाय जोडलेले असू शकतात): ' + err.message, 'error');
    }
  }

  const filteredCategories = categories.filter((c) => {
    const matchesSearch =
      c.name_mr.toLowerCase().includes(searchTerm.toLowerCase()) ||
      c.name_en.toLowerCase().includes(searchTerm.toLowerCase()) ||
      c.slug.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesGroup = selectedGroup === 'all' || c.group_type === selectedGroup;
    return matchesSearch && matchesGroup;
  });

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h2 className="text-xl font-bold text-slate-900">कॅटेगरी व्यवस्थापन (Categories)</h2>
          <p className="text-xs text-slate-500">
            स्थानिक सेवा, दुकाने, शेती, वाहतूक, आरोग्य व इतर प्रवर्ग ({categories.length} कॅटेगरी)
          </p>
        </div>
        <button
          onClick={handleOpenAdd}
          className="flex items-center justify-center space-x-1.5 px-4 py-2.5 bg-brand-blue text-white rounded-lg text-xs font-semibold hover:bg-brand-dark transition shadow-sm active:scale-95"
        >
          <Plus className="w-4 h-4" />
          <span>नवीन कॅटेगरी जोडा</span>
        </button>
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white p-3 rounded-xl border border-slate-200 shadow-sm flex flex-col sm:flex-row gap-3 items-center justify-between">
        <div className="flex items-center gap-2 w-full sm:w-80">
          <Search className="w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="कॅटेगरी शोधा (उदा. किराणा, इलेक्ट्रिशियन, Grocery)..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full text-xs text-slate-800 placeholder-slate-400 focus:outline-none"
          />
        </div>

        <div className="flex items-center gap-2 w-full sm:w-auto">
          <Filter className="w-4 h-4 text-slate-400" />
          <select
            value={selectedGroup}
            onChange={(e) => setSelectedGroup(e.target.value)}
            className="text-xs border border-slate-200 rounded-lg px-2.5 py-1.5 bg-white text-slate-700 focus:outline-none"
          >
            {groupTypeOptions.map((opt) => (
              <option key={opt.value} value={opt.value}>
                {opt.label}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Categories Table */}
      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
            <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
              <tr>
                <th className="px-5 py-3">कॅटेगरी (मराठी)</th>
                <th className="px-5 py-3">Category (English)</th>
                <th className="px-5 py-3">ग्रुप (Group Type)</th>
                <th className="px-5 py-3">आयकॉन</th>
                <th className="px-5 py-3">क्रम</th>
                <th className="px-5 py-3">स्थिती</th>
                <th className="px-5 py-3 text-right">कृती</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {loading ? (
                <tr>
                  <td colSpan={7} className="px-5 py-8 text-center text-slate-400">माहिती लोड होत आहे...</td>
                </tr>
              ) : filteredCategories.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-5 py-8 text-center text-slate-400">
                    कोणतीही कॅटेगरी सापडली नाही.
                  </td>
                </tr>
              ) : (
                filteredCategories.map((c) => (
                  <tr 
                    key={c.id} 
                    onClick={() => setViewingCategory(c)} 
                    className="hover:bg-blue-50/70 transition cursor-pointer group"
                    title="सविस्तर कॅटेगरी माहिती पाहण्यासाठी क्लिक करा"
                  >
                    <td className="px-5 py-3.5 font-bold text-slate-800">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-1.5 group-hover:text-brand-blue transition">
                          <Layers className="w-3.5 h-3.5 text-brand-blue flex-shrink-0" />
                          <span>{c.name_mr}</span>
                        </div>
                        <span className="text-[10px] text-brand-blue bg-blue-100 font-semibold px-2 py-0.5 rounded opacity-0 group-hover:opacity-100 transition mr-2">
                          तपशील ↗
                        </span>
                      </div>
                    </td>
                    <td className="px-5 py-3.5 text-slate-600 font-medium">{c.name_en}</td>
                    <td className="px-5 py-3.5">
                      <span className="px-2 py-0.5 rounded text-[11px] font-medium bg-slate-100 text-slate-700">
                        {c.group_type}
                      </span>
                    </td>
                    <td className="px-5 py-3.5 text-slate-500 font-mono text-[11px]">{c.icon}</td>
                    <td className="px-5 py-3.5 text-slate-600">{c.sort_order}</td>
                    <td className="px-5 py-3.5" onClick={(e) => e.stopPropagation()}>
                      <button
                        onClick={() => handleToggleStatus(c)}
                        title="स्थिती बदलण्यासाठी क्लिक करा"
                        className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-semibold transition ${
                          c.is_active
                            ? 'bg-emerald-100 text-emerald-800 hover:bg-emerald-200'
                            : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                        }`}
                      >
                        {c.is_active ? <Check className="w-3 h-3" /> : <X className="w-3 h-3" />}
                        <span>{c.is_active ? 'सक्रिय' : 'निष्क्रिय'}</span>
                      </button>
                    </td>
                    <td className="px-5 py-3.5 text-right space-x-1" onClick={(e) => e.stopPropagation()}>
                      <button
                        onClick={() => setViewingCategory(c)}
                        className="p-1.5 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded transition"
                        title="तपशील पहा"
                      >
                        <Eye className="w-3.5 h-3.5" />
                      </button>
                      <button
                        onClick={() => handleOpenEdit(c)}
                        className="p-1.5 text-slate-600 hover:text-brand-blue hover:bg-blue-50 rounded transition"
                        title="संपादित करा"
                      >
                        <Edit2 className="w-3.5 h-3.5" />
                      </button>
                      <button
                        onClick={() => handleDelete(c)}
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

      {/* Add / Edit Category Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-md w-full shadow-2xl overflow-hidden border border-slate-200">
            <div className="px-6 py-4 bg-slate-50 border-b border-slate-200 flex items-center justify-between">
              <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
                <Layers className="w-4 h-4 text-brand-blue" />
                {editingCategory ? 'कॅटेगरी संपादित करा' : 'नवीन कॅटेगरी जोडा'}
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
                  कॅटेगरीचे नाव (मराठीत) <span className="text-rose-500">*</span>
                </label>
                <input
                  type="text"
                  required
                  placeholder="उदा. प्लंबिंग सेवा, किराणा स्टोअर्स"
                  value={formData.name_mr}
                  onChange={(e) => setFormData({ ...formData, name_mr: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  Category Name (English) <span className="text-rose-500">*</span>
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Plumbing Services, Grocery Stores"
                  value={formData.name_en}
                  onChange={(e) => setFormData({ ...formData, name_en: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">ग्रुप (Group Type)</label>
                  <select
                    value={formData.group_type}
                    onChange={(e) => setFormData({ ...formData, group_type: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs bg-white"
                  >
                    <option value="shops">दुकाने (Shops)</option>
                    <option value="services">घरगुती सेवा (Services)</option>
                    <option value="agriculture">कृषी (Agriculture)</option>
                    <option value="health">आरोग्य (Health)</option>
                    <option value="transport">वाहतूक (Transport)</option>
                    <option value="education">शिक्षण (Education)</option>
                  </select>
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">क्रम (Sort Order)</label>
                  <input
                    type="number"
                    value={formData.sort_order}
                    onChange={(e) => setFormData({ ...formData, sort_order: Number(e.target.value) })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">स्लग (Slug / ID)</label>
                  <input
                    type="text"
                    placeholder="उदा. grocery, plumbing"
                    value={formData.slug}
                    onChange={(e) => setFormData({ ...formData, slug: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">आयकॉन कोड</label>
                  <input
                    type="text"
                    placeholder="उदा. store, tool, heart"
                    value={formData.icon}
                    onChange={(e) => setFormData({ ...formData, icon: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                  />
                </div>
              </div>

              <div className="flex items-center gap-2 pt-2">
                <input
                  type="checkbox"
                  id="cat_is_active"
                  checked={formData.is_active}
                  onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                  className="rounded text-brand-blue focus:ring-brand-blue"
                />
                <label htmlFor="cat_is_active" className="text-slate-700 font-medium cursor-pointer">
                  सक्रिय कॅटेगरी (ॲपमध्ये ग्राहकांसाठी दाखवा)
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
                  {submitting ? 'जतन करत आहे...' : editingCategory ? 'बदल सेव्ह करा' : 'कॅटेगरी जोडा'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
      {/* View Category Modal */}
      {viewingCategory && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-md w-full shadow-2xl overflow-hidden border border-slate-200">
            <div className="px-6 py-4 bg-slate-50 border-b border-slate-200 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="p-2 bg-blue-100 rounded-lg text-brand-blue">
                  <Layers className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-bold text-base text-slate-900 leading-tight">
                    {viewingCategory.name_mr}
                  </h3>
                  <p className="text-xs text-slate-500">{viewingCategory.name_en}</p>
                </div>
              </div>
              <button
                onClick={() => setViewingCategory(null)}
                className="text-slate-400 hover:text-slate-600 p-1.5 rounded-lg hover:bg-slate-200 transition"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="p-6 space-y-4 text-xs text-slate-700">
              <div className="grid grid-cols-2 gap-3">
                <div className="p-3 bg-blue-50/60 rounded-xl border border-blue-100">
                  <span className="text-[11px] text-slate-500 font-semibold block">ग्रुप टाईप</span>
                  <span className="text-xs font-bold text-brand-blue uppercase">{viewingCategory.group_type}</span>
                </div>
                <div className="p-3 bg-slate-50 rounded-xl border border-slate-200">
                  <span className="text-[11px] text-slate-500 font-semibold block">स्थिती</span>
                  <span className={`inline-block mt-0.5 px-2 py-0.5 rounded text-[11px] font-bold ${
                    viewingCategory.is_active ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-600'
                  }`}>
                    {viewingCategory.is_active ? '✓ सक्रिय (Active)' : 'निष्क्रिय (Inactive)'}
                  </span>
                </div>
              </div>

              <div className="space-y-2 bg-slate-50/50 p-4 rounded-xl border border-slate-100 text-xs">
                <div className="flex justify-between py-1 border-b border-slate-100">
                  <span className="text-slate-500">कॅटेगरी स्लॅग (Slug):</span>
                  <span className="font-mono text-slate-800 font-bold">{viewingCategory.slug}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-slate-100">
                  <span className="text-slate-500">आयकॉन नाव:</span>
                  <span className="font-mono text-slate-800">{viewingCategory.icon}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-slate-100">
                  <span className="text-slate-500">क्रम (Sort Order):</span>
                  <span className="font-bold text-slate-800">{viewingCategory.sort_order}</span>
                </div>
                <div className="flex justify-between py-1">
                  <span className="text-slate-500">कार्यक्षेत्र:</span>
                  <span className="font-bold text-brand-green">केवळ नरडाणा गाव</span>
                </div>
              </div>

              <div className="p-3.5 bg-blue-50/70 border border-blue-200 rounded-xl flex items-center justify-between">
                <div>
                  <p className="font-bold text-slate-800 text-xs">या प्रवर्गातील व्यवसाय</p>
                  <p className="text-[11px] text-slate-500">नरडाणा गावातील नोंदी पहा</p>
                </div>
                <button
                  onClick={() => {
                    setViewingCategory(null);
                    navigate('/businesses');
                  }}
                  className="px-3 py-1.5 bg-brand-blue text-white rounded-lg font-bold text-xs hover:bg-brand-dark transition flex items-center gap-1"
                >
                  <span>व्यवसाय पहा</span>
                  <ArrowRight className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>

            <div className="px-6 py-3.5 bg-slate-50 border-t border-slate-200 flex items-center justify-between">
              <button
                onClick={() => {
                  const toEdit = viewingCategory;
                  setViewingCategory(null);
                  handleOpenEdit(toEdit);
                }}
                className="px-3.5 py-1.5 bg-slate-100 text-slate-700 hover:bg-slate-200 rounded-lg text-xs font-semibold inline-flex items-center gap-1 transition"
              >
                <Edit2 className="w-3.5 h-3.5" /> संपादित करा
              </button>
              <button
                onClick={() => setViewingCategory(null)}
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
