import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { Job } from '../types/database';
import { Briefcase, CheckCircle, XCircle } from 'lucide-react';

export const Jobs: React.FC = () => {
  const [jobs, setJobs] = useState<Job[]>([]);
  const [loading, setLoading] = useState(true);

  async function fetchJobs() {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('jobs')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setJobs(data || []);
    } catch (err) {
      console.error('Error fetching jobs:', err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchJobs();
  }, []);

  async function updateStatus(id: string, newStatus: 'approved' | 'rejected') {
    try {
      const { error } = await supabase
        .from('jobs')
        .update({ status: newStatus, updated_at: new Date().toISOString() })
        .eq('id', id);

      if (error) throw error;
      setJobs(prev => prev.map(j => j.id === id ? { ...j, status: newStatus } : j));
    } catch (err) {
      console.error('Error updating job status:', err);
    }
  }

  return (
    <div className="space-y-5">
      <div>
        <h2 className="text-xl font-bold text-slate-900">रोजगार व नोकऱ्या (Jobs & Employment)</h2>
        <p className="text-xs text-slate-500">स्थानिक उद्योजक व व्यापाऱ्यांनी पोस्ट केलेल्या नोकऱ्यांची पडताळणी</p>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
          <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
            <tr>
              <th className="px-5 py-3">पदाचे नाव (Job Title)</th>
              <th className="px-5 py-3">कंपनी / मालक (Company)</th>
              <th className="px-5 py-3">पगार (Salary Range)</th>
              <th className="px-5 py-3">प्रकार (Type)</th>
              <th className="px-5 py-3">स्थिती (Status)</th>
              <th className="px-5 py-3 text-right">कृती (Actions)</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {loading ? (
              <tr>
                <td colSpan={6} className="px-5 py-6 text-center text-slate-400">माहिती लोड होत आहे...</td>
              </tr>
            ) : jobs.length === 0 ? (
              <tr>
                <td colSpan={6} className="px-5 py-6 text-center text-slate-400">सध्या नोकऱ्या उपलब्ध नाहीत.</td>
              </tr>
            ) : (
              jobs.map((j) => (
                <tr key={j.id} className="hover:bg-slate-50/70">
                  <td className="px-5 py-3.5 font-bold text-slate-800 flex items-center gap-1.5">
                    <Briefcase className="w-3.5 h-3.5 text-brand-blue" /> {j.job_title}
                  </td>
                  <td className="px-5 py-3.5 text-slate-600">{j.company_name}</td>
                  <td className="px-5 py-3.5 text-slate-600">{j.salary_range || 'चर्चेनुसार'}</td>
                  <td className="px-5 py-3.5">
                    <span className="px-2 py-0.5 rounded text-[11px] font-medium bg-slate-100 text-slate-700">
                      {j.job_type}
                    </span>
                  </td>
                  <td className="px-5 py-3.5">
                    <span className="px-2 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-100 text-emerald-800">
                      {j.status}
                    </span>
                  </td>
                  <td className="px-5 py-3.5 text-right space-x-1.5">
                    <button
                      onClick={() => updateStatus(j.id, 'approved')}
                      className="p-1 text-emerald-600 hover:bg-emerald-50 rounded"
                      title="मंजूर करा"
                    >
                      <CheckCircle className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => updateStatus(j.id, 'rejected')}
                      className="p-1 text-rose-600 hover:bg-rose-50 rounded"
                      title="नाकारा"
                    >
                      <XCircle className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

