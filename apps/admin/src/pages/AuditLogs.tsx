import React, { useState } from 'react';
import { Search, Download, Eye, X, ShieldCheck } from 'lucide-react';
import { useToast } from '../components/Toast';
import { AdminPageHeader } from '../components/AdminPageHeader';

interface AuditLog {
  id: string;
  admin_email: string;
  action: 'CREATE' | 'UPDATE' | 'DELETE' | 'APPROVE' | 'REJECT' | 'PUBLISH';
  module: string;
  details: string;
  ip_address: string;
  timestamp: string;
}

const INITIAL_AUDIT_LOGS: AuditLog[] = [
  {
    id: 'aud-1',
    admin_email: 'admin@nardana.org',
    action: 'PUBLISH',
    module: 'जाहिराती (Advertisements)',
    details: 'महालक्ष्मी किराणा स्टोअर्स ची होम कॅरोसेल जाहिरात प्रकाशित केली.',
    ip_address: '103.24.188.12',
    timestamp: '2026-11-10T16:45:00Z',
  },
  {
    id: 'aud-2',
    admin_email: 'admin@nardana.org',
    action: 'UPDATE',
    module: 'ॲप अपडेट (App Update)',
    details: 'किमान समर्थित व्हर्जन v1.0.0 वर सेट केले आणि सक्तीचे अपडेट सक्रिय केले.',
    ip_address: '103.24.188.12',
    timestamp: '2026-11-10T16:20:00Z',
  },
  {
    id: 'aud-3',
    admin_email: 'admin@nardana.org',
    action: 'APPROVE',
    module: 'व्यवसाय (Businesses)',
    details: 'जय भवानी इलेक्ट्रिकल वर्क्स या नवीन व्यवसायाची पडताळणी करून मंजुरी दिली.',
    ip_address: '103.24.188.12',
    timestamp: '2026-11-10T15:10:00Z',
  },
  {
    id: 'aud-4',
    admin_email: 'admin@nardana.org',
    action: 'CREATE',
    module: 'गाव सूचना (Notices)',
    details: 'पाणी पुरवठा वेळापत्रक दुरुस्ती सूचना प्रकाशित केली.',
    ip_address: '103.24.188.12',
    timestamp: '2026-11-10T11:00:00Z',
  },
  {
    id: 'aud-5',
    admin_email: 'superadmin@nardana.org',
    action: 'UPDATE',
    module: 'भौगोलिक कव्हरेज (Scope)',
    details: 'केवळ नरडाणा गाव (पिन ४२५४०४) कार्यक्षेत्र निश्चित केले. इतर गावे पूर्णतः वगळली.',
    ip_address: '103.24.188.12',
    timestamp: '2026-11-10T09:30:00Z',
  },
];

export const AuditLogs: React.FC = () => {
  const [logs] = useState<AuditLog[]>(INITIAL_AUDIT_LOGS);
  const [viewingLog, setViewingLog] = useState<AuditLog | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [actionFilter, setActionFilter] = useState('all');
  const { showToast } = useToast();

  const filtered = logs.filter((l) => {
    const matchesSearch =
      l.details.toLowerCase().includes(searchTerm.toLowerCase()) ||
      l.admin_email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      l.module.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesAction = actionFilter === 'all' || l.action === actionFilter;
    return matchesSearch && matchesAction;
  });

  const handleExport = () => {
    showToast('ऑडिट लॉग CSV अहवाल डाऊनलोड झाला!', 'success');
  };

  return (
    <div className="space-y-6">
      <AdminPageHeader
        title="प्रशासकीय सुरक्षा ऑडिट लॉग (Audit Logs)"
        subtitle="ॲडमिन पॅनेलमध्ये झालेल्या सर्व बदल, मंजुरी, हटवणे व पब्लिश कृतींची अपरिवर्तनीय नोंद"
        actions={
          <button
            onClick={handleExport}
            className="flex items-center space-x-1.5 px-3.5 py-2 bg-brand-blue text-white rounded-lg text-xs font-semibold hover:bg-brand-dark transition shadow-sm"
          >
            <Download className="w-4 h-4" />
            <span>अहवाल एक्सपोर्ट करा</span>
          </button>
        }
      />

      {/* Filter and Search Bar */}
      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col md:flex-row gap-3 items-center justify-between">
        <div className="relative w-full md:w-80">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
          <input
            type="text"
            placeholder="कृती, ॲडमिन किंवा तपशील शोधा..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-9 pr-4 py-2 border border-slate-200 rounded-lg text-xs focus:outline-none focus:border-brand-blue"
          />
        </div>

        <div className="flex items-center gap-2 w-full md:w-auto">
          <select
            value={actionFilter}
            onChange={(e) => setActionFilter(e.target.value)}
            className="px-3 py-2 border border-slate-200 rounded-lg text-xs bg-white focus:outline-none focus:border-brand-blue"
          >
            <option value="all">सर्व कृती (All Actions)</option>
            <option value="PUBLISH">पब्लिश (PUBLISH)</option>
            <option value="APPROVE">मंजूर (APPROVE)</option>
            <option value="UPDATE">अपडेट (UPDATE)</option>
            <option value="CREATE">तयार केले (CREATE)</option>
            <option value="DELETE">हटवले (DELETE)</option>
          </select>
        </div>
      </div>

      {/* Audit Logs Table */}
      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
          <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
            <tr>
              <th className="px-5 py-3">तारीख व वेळ</th>
              <th className="px-5 py-3">ॲडमिन वापरकर्ता</th>
              <th className="px-5 py-3">कृती (Action)</th>
              <th className="px-5 py-3">मॉड्यूल</th>
              <th className="px-5 py-3">सविस्तर तपशील</th>
              <th className="px-5 py-3">आयपी पत्ता</th>
              <th className="px-5 py-3 text-right">कृती</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 font-mono text-slate-700">
            {filtered.map((l) => (
              <tr 
                key={l.id} 
                onClick={() => setViewingLog(l)}
                className="hover:bg-blue-50/70 font-sans cursor-pointer group transition"
                title="सविस्तर ऑडिट तपशील पाहण्यासाठी क्लिक करा"
              >
                <td className="px-5 py-3.5 text-slate-500 whitespace-nowrap text-xs">
                  {new Date(l.timestamp).toLocaleString('mr-IN')}
                </td>
                <td className="px-5 py-3.5 font-bold text-slate-800 font-mono text-xs group-hover:text-brand-blue">
                  {l.admin_email}
                </td>
                <td className="px-5 py-3.5 whitespace-nowrap">
                  <span
                    className={`px-2 py-0.5 rounded text-[10px] font-bold font-mono ${
                      l.action === 'PUBLISH' || l.action === 'APPROVE'
                        ? 'bg-emerald-100 text-emerald-800'
                        : l.action === 'UPDATE'
                        ? 'bg-blue-100 text-blue-800'
                        : l.action === 'DELETE'
                        ? 'bg-rose-100 text-rose-800'
                        : 'bg-slate-100 text-slate-700'
                    }`}
                  >
                    {l.action}
                  </span>
                </td>
                <td className="px-5 py-3.5 text-slate-800 font-semibold text-xs">{l.module}</td>
                <td className="px-5 py-3.5 text-slate-600 text-xs max-w-md truncate">{l.details}</td>
                <td className="px-5 py-3.5 font-mono text-slate-400 text-xs">{l.ip_address}</td>
                <td className="px-5 py-3.5 text-right" onClick={(e) => e.stopPropagation()}>
                  <button
                    onClick={() => setViewingLog(l)}
                    className="p-1 hover:text-brand-blue text-slate-400"
                    title="तपशील पहा"
                  >
                    <Eye className="w-4 h-4" />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Audit Log Details Modal */}
      {viewingLog && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-md w-full shadow-2xl overflow-hidden border border-slate-200">
            <div className="px-6 py-4 bg-slate-50 border-b border-slate-200 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="p-2 bg-blue-100 rounded-lg text-brand-blue">
                  <ShieldCheck className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-bold text-base text-slate-900 leading-tight">
                    ऑडिट लॉग तपशील
                  </h3>
                  <p className="text-xs text-slate-500 font-mono">आयडी: {viewingLog.id}</p>
                </div>
              </div>
              <button
                onClick={() => setViewingLog(null)}
                className="text-slate-400 hover:text-slate-600 p-1.5 rounded-lg hover:bg-slate-200 transition"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="p-6 space-y-4 text-xs text-slate-700">
              <div className="space-y-2 bg-slate-50 p-4 rounded-xl border border-slate-200">
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="text-slate-500">ॲडमिन वापरकर्ता:</span>
                  <span className="font-bold font-mono text-slate-800">{viewingLog.admin_email}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="text-slate-500">कृती प्रकार:</span>
                  <span className="font-bold font-mono text-brand-blue">{viewingLog.action}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="text-slate-500">संबंधित विभाग:</span>
                  <span className="font-bold text-slate-800">{viewingLog.module}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="text-slate-500">आयपी ॲड्रेस:</span>
                  <span className="font-mono text-slate-600">{viewingLog.ip_address}</span>
                </div>
                <div className="flex justify-between py-1">
                  <span className="text-slate-500">वेळ व दिनांक:</span>
                  <span className="font-mono text-slate-700">
                    {new Date(viewingLog.timestamp).toLocaleString('mr-IN', {
                      dateStyle: 'full',
                      timeStyle: 'medium',
                    })}
                  </span>
                </div>
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">कृतीचा सविस्तर तपशील:</label>
                <div className="p-3 bg-white rounded-lg border border-slate-200 text-slate-800 text-xs leading-relaxed font-sans">
                  {viewingLog.details}
                </div>
              </div>
            </div>

            <div className="px-6 py-3.5 bg-slate-50 border-t border-slate-200 flex justify-end">
              <button
                onClick={() => setViewingLog(null)}
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
