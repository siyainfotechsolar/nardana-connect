import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { Job, Village } from '../types/database';
import { 
  Briefcase, 
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

interface JobFormData {
  job_title: string;
  company_name: string;
  employer_name: string;
  contact_number: string;
  job_location: string;
  village_id: string;
  salary_range: string;
  qualification: string;
  experience: string;
  job_type: string;
  description: string;
  status: 'pending' | 'approved' | 'rejected';
}

const defaultFormData: JobFormData = {
  job_title: '',
  company_name: '',
  employer_name: '',
  contact_number: '',
  job_location: 'नरडाणा (Nardana)',
  village_id: '',
  salary_range: 'चर्चेनुसार (Negotiable)',
  qualification: '१० वी / १२ वी किंवा अनुभव',
  experience: 'अनुभवी / नवीन उमेदवार',
  job_type: 'Full-time',
  description: '',
  status: 'approved',
};

export const Jobs: React.FC = () => {
  const [jobs, setJobs] = useState<Job[]>([]);
  const [villages, setVillages] = useState<Village[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'pending' | 'approved' | 'rejected'>('all');

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [viewingJob, setViewingJob] = useState<Job | null>(null);
  const [formData, setFormData] = useState<JobFormData>(defaultFormData);
  const [submitting, setSubmitting] = useState(false);

  const { showToast } = useToast();

  async function loadData() {
    try {
      setLoading(true);
      const [jobsRes, vilRes] = await Promise.all([
        supabase
          .from('jobs')
          .select('*')
          .order('created_at', { ascending: false }),
        supabase
          .from('villages')
          .select('*')
          .eq('is_active', true)
          .order('name_mr'),
      ]);

      if (jobsRes.error) throw jobsRes.error;
      if (vilRes.error) throw vilRes.error;

      setJobs(jobsRes.data || []);
      setVillages(vilRes.data || []);

      if (vilRes.data && vilRes.data.length > 0 && !formData.village_id) {
        defaultFormData.village_id = vilRes.data[0].id;
      }
    } catch (err: any) {
      console.error('Error fetching jobs:', err);
      showToast('नोकऱ्या लोड करताना त्रुटी: ' + (err.message || ''), 'error');
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
    if (!formData.job_title.trim() || !formData.company_name.trim() || !formData.contact_number.trim()) {
      showToast('कृपया आवश्यक माहिती (शीर्षक, कंपनी, फोन) भरा.', 'error');
      return;
    }

    try {
      setSubmitting(true);
      const { error } = await supabase
        .from('jobs')
        .insert({
          job_title: formData.job_title.trim(),
          company_name: formData.company_name.trim(),
          employer_name: formData.employer_name.trim() || formData.company_name.trim(),
          contact_number: formData.contact_number.trim(),
          job_location: formData.job_location.trim(),
          village_id: formData.village_id || villages[0]?.id,
          salary_range: formData.salary_range.trim(),
          qualification: formData.qualification.trim(),
          experience: formData.experience.trim(),
          job_type: formData.job_type,
          description: formData.description.trim() || 'अधिक माहितीसाठी दिलेल्या क्रमांकावर संपर्क साधा.',
          status: formData.status,
        });

      if (error) throw error;
      showToast('नवीन रोजगार यशस्वीपणे जोडला!', 'success');
      setIsModalOpen(false);
      loadData();
    } catch (err: any) {
      console.error('Save job error:', err);
      showToast('रोजगार सेव्ह करताना त्रुटी: ' + (err.message || ''), 'error');
    } finally {
      setSubmitting(false);
    }
  }

  async function updateStatus(id: string, newStatus: 'approved' | 'rejected') {
    try {
      const { error } = await supabase
        .from('jobs')
        .update({ status: newStatus, updated_at: new Date().toISOString() })
        .eq('id', id);

      if (error) throw error;
      setJobs(prev => prev.map(j => (j.id === id ? { ...j, status: newStatus } : j)));
      showToast(
        newStatus === 'approved' ? 'रोजगार मंजूर केला!' : 'रोजगार नाकारला.',
        newStatus === 'approved' ? 'success' : 'info'
      );
    } catch (err: any) {
      console.error('Error updating job status:', err);
      showToast('स्थिती बदलताना त्रुटी: ' + (err.message || ''), 'error');
    }
  }

  async function handleDelete(job: Job) {
    if (!window.confirm(`तुम्हाला नक्की '${job.job_title}' ही नोकरी हटवायची आहे का?`)) {
      return;
    }

    try {
      const { error } = await supabase
        .from('jobs')
        .delete()
        .eq('id', job.id);

      if (error) throw error;
      setJobs(prev => prev.filter(j => j.id !== job.id));
      showToast('रोजगार नोंद यशस्वीपणे हटवली.', 'success');
    } catch (err: any) {
      showToast('हटवताना त्रुटी: ' + err.message, 'error');
    }
  }

  const filteredJobs = jobs.filter((j) => {
    const matchesSearch =
      j.job_title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      j.company_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      j.contact_number.includes(searchTerm);
    const matchesStatus = statusFilter === 'all' || j.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const pendingCount = jobs.filter(j => j.status === 'pending').length;

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h2 className="text-xl font-bold text-slate-900">रोजगार व नोकऱ्या (Jobs & Employment)</h2>
          <p className="text-xs text-slate-500">
            स्थानिक शेती, दुकाने, कंपन्या आणि उद्योजकांकडील उपलब्ध रोजगारांचे व्यवस्थापन ({jobs.length} नोंदी)
          </p>
        </div>
        <button
          onClick={handleOpenAdd}
          className="flex items-center justify-center space-x-1.5 px-4 py-2.5 bg-brand-blue text-white rounded-lg text-xs font-semibold hover:bg-brand-dark transition shadow-sm active:scale-95"
        >
          <Plus className="w-4 h-4" />
          <span>नवीन रोजगार जोडा</span>
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
            सर्व ({jobs.length})
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
            onClick={() => setStatusFilter('rejected')}
            className={`px-3 py-1.5 rounded-lg text-xs font-medium transition ${
              statusFilter === 'rejected'
                ? 'bg-rose-600 text-white shadow-sm font-semibold'
                : 'text-rose-800 bg-rose-50 hover:bg-rose-100'
            }`}
          >
            नाकारलेले
          </button>
        </div>

        <div className="flex items-center gap-2">
          <Search className="w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="नोकरीचे पद, कंपनी किंवा फोन नंबर शोधा..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full text-xs text-slate-800 placeholder-slate-400 focus:outline-none"
          />
        </div>
      </div>

      {/* Jobs Table */}
      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
            <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
              <tr>
                <th className="px-5 py-3">पदाचे नाव (Job Title)</th>
                <th className="px-5 py-3">कंपनी / मालक</th>
                <th className="px-5 py-3">पगार (Salary)</th>
                <th className="px-5 py-3">प्रकार</th>
                <th className="px-5 py-3">संपर्क</th>
                <th className="px-5 py-3">स्थिती</th>
                <th className="px-5 py-3 text-right">कृती</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {loading ? (
                <tr>
                  <td colSpan={7} className="px-5 py-8 text-center text-slate-400">माहिती लोड होत आहे...</td>
                </tr>
              ) : filteredJobs.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-5 py-8 text-center text-slate-400">
                    कोणतेही रोजगार सापडले नाहीत.
                  </td>
                </tr>
              ) : (
                filteredJobs.map((j) => (
                  <tr key={j.id} className="hover:bg-slate-50/70 transition">
                    <td className="px-5 py-3.5 font-bold text-slate-800 flex items-center gap-1.5">
                      <Briefcase className="w-3.5 h-3.5 text-brand-blue flex-shrink-0" />
                      <span>{j.job_title}</span>
                    </td>
                    <td className="px-5 py-3.5 text-slate-600">
                      <p className="font-medium text-slate-800">{j.company_name}</p>
                      <p className="text-[11px] text-slate-500">{j.job_location}</p>
                    </td>
                    <td className="px-5 py-3.5 text-brand-blue font-semibold">
                      {j.salary_range || 'चर्चेनुसार'}
                    </td>
                    <td className="px-5 py-3.5">
                      <span className="px-2 py-0.5 rounded text-[11px] font-medium bg-slate-100 text-slate-700">
                        {j.job_type}
                      </span>
                    </td>
                    <td className="px-5 py-3.5 text-slate-600 font-mono">
                      <div className="flex items-center gap-1">
                        <Phone className="w-3 h-3 text-brand-green" /> {j.contact_number}
                      </div>
                    </td>
                    <td className="px-5 py-3.5">
                      {j.status === 'approved' && (
                        <span className="px-2.5 py-1 rounded-full text-[11px] font-semibold bg-emerald-100 text-emerald-800">
                          मंजूर
                        </span>
                      )}
                      {j.status === 'pending' && (
                        <span className="px-2.5 py-1 rounded-full text-[11px] font-semibold bg-amber-100 text-amber-800">
                          प्रलंबित
                        </span>
                      )}
                      {j.status === 'rejected' && (
                        <span className="px-2.5 py-1 rounded-full text-[11px] font-semibold bg-rose-100 text-rose-800">
                          नाकारले
                        </span>
                      )}
                    </td>
                    <td className="px-5 py-3.5 text-right space-x-1">
                      {j.status !== 'approved' && (
                        <button
                          onClick={() => updateStatus(j.id, 'approved')}
                          className="px-2 py-1 text-emerald-700 bg-emerald-50 hover:bg-emerald-100 rounded text-[11px] font-semibold inline-flex items-center gap-1 transition"
                          title="मंजूर करा"
                        >
                          <CheckCircle className="w-3 h-3" /> मंजूर
                        </button>
                      )}
                      {j.status !== 'rejected' && (
                        <button
                          onClick={() => updateStatus(j.id, 'rejected')}
                          className="px-2 py-1 text-rose-700 bg-rose-50 hover:bg-rose-100 rounded text-[11px] font-semibold inline-flex items-center gap-1 transition"
                          title="नाकारा"
                        >
                          <XCircle className="w-3 h-3" /> नाकारा
                        </button>
                      )}
                      <button
                        onClick={() => setViewingJob(j)}
                        className="p-1.5 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded transition"
                        title="तपशील पहा"
                      >
                        <Eye className="w-3.5 h-3.5" />
                      </button>
                      <button
                        onClick={() => handleDelete(j)}
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

      {/* Add Job Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-lg w-full max-h-[90vh] overflow-y-auto shadow-2xl border border-slate-200">
            <div className="px-6 py-4 bg-slate-50 border-b border-slate-200 flex items-center justify-between sticky top-0 bg-slate-50 z-10">
              <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
                <Briefcase className="w-4 h-4 text-brand-blue" /> नवीन रोजगार जाहिरात जोडा
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
                    पदाचे नाव (Job Title) <span className="text-rose-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="उदा. ड्रायव्हर, सेल्समन, मजूर"
                    value={formData.job_title}
                    onChange={(e) => setFormData({ ...formData, job_title: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    कंपनी / दुकान नाव <span className="text-rose-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="उदा. किसान ॲग्रो, महालक्ष्मी स्टोअर्स"
                    value={formData.company_name}
                    onChange={(e) => setFormData({ ...formData, company_name: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">
                    संपर्क फोन नंबर <span className="text-rose-500">*</span>
                  </label>
                  <input
                    type="tel"
                    required
                    placeholder="उदा. 9876543210"
                    value={formData.contact_number}
                    onChange={(e) => setFormData({ ...formData, contact_number: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">कामाचे ठिकाण</label>
                  <input
                    type="text"
                    placeholder="उदा. नरडाणा एमआयडीसी, मुख्य बाजार"
                    value={formData.job_location}
                    onChange={(e) => setFormData({ ...formData, job_location: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">पगार (Salary Range)</label>
                  <input
                    type="text"
                    placeholder="उदा. ₹12,000 - ₹15,000"
                    value={formData.salary_range}
                    onChange={(e) => setFormData({ ...formData, salary_range: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">प्रकार (Job Type)</label>
                  <select
                    value={formData.job_type}
                    onChange={(e) => setFormData({ ...formData, job_type: e.target.value })}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs bg-white"
                  >
                    <option value="Full-time">फुल टाईम (Full-time)</option>
                    <option value="Part-time">पार्ट टाईम (Part-time)</option>
                    <option value="Daily Wage">रोजंदारी (Daily Wage)</option>
                    <option value="Contract">कंत्राटी (Contract)</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">कामाचे वर्णन / अटी</label>
                <textarea
                  rows={2}
                  placeholder="कामाच्या वेळा, जबाबदाऱ्या किंवा विशेष पात्रता..."
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">स्थिती</label>
                <select
                  value={formData.status}
                  onChange={(e) => setFormData({ ...formData, status: e.target.value as any })}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs bg-white font-medium"
                >
                  <option value="approved">मंजूर (Approved - तत्काळ ॲपमध्ये प्रसिद्ध करा)</option>
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
                  {submitting ? 'जतन करत आहे...' : 'रोजगार जोडा'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* View Job Modal */}
      {viewingJob && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-md w-full shadow-2xl overflow-hidden border border-slate-200 p-6 space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <h3 className="font-bold text-base text-slate-900 flex items-center gap-2">
                <Briefcase className="w-5 h-5 text-brand-blue" />
                {viewingJob.job_title}
              </h3>
              <button
                onClick={() => setViewingJob(null)}
                className="text-slate-400 hover:text-slate-600 p-1 rounded"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-2 text-xs text-slate-700">
              <p><strong>कंपनी / मालक:</strong> {viewingJob.company_name}</p>
              <p><strong>ठिकाण:</strong> {viewingJob.job_location}</p>
              <p><strong>पगार:</strong> {viewingJob.salary_range || 'चर्चेनुसार'}</p>
              <p><strong>प्रकार:</strong> {viewingJob.job_type}</p>
              <p><strong>पात्रता:</strong> {viewingJob.qualification || 'अनुभव'}</p>
              <p><strong>संपर्क:</strong> {viewingJob.contact_number}</p>
              <p><strong>वर्णन:</strong> {viewingJob.description}</p>
              <p>
                <strong>स्थिती:</strong>{' '}
                <span className={`px-2 py-0.5 rounded font-bold ${
                  viewingJob.status === 'approved' ? 'bg-emerald-100 text-emerald-800' :
                  viewingJob.status === 'pending' ? 'bg-amber-100 text-amber-800' :
                  'bg-rose-100 text-rose-800'
                }`}>
                  {viewingJob.status}
                </span>
              </p>
            </div>

            <div className="flex justify-end gap-2 pt-3 border-t border-slate-100">
              <button
                onClick={() => setViewingJob(null)}
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
