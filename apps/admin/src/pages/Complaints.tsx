import React, { useState } from 'react';
import { Search, Eye, CheckCircle2, Trash2, X } from 'lucide-react';
import { useToast } from '../components/Toast';
import { AdminPageHeader } from '../components/AdminPageHeader';

interface Complaint {
  id: string;
  citizen_name: string;
  phone: string;
  ward: string;
  category: string;
  subject: string;
  description: string;
  status: 'pending' | 'in_progress' | 'resolved' | 'rejected';
  resolution_notes?: string;
  created_at: string;
}

const INITIAL_COMPLAINTS: Complaint[] = [
  {
    id: 'cmp-101',
    citizen_name: 'प्रमोद महाजन',
    phone: '9422054321',
    ward: 'प्रभाग २ (मेन बाजारपेठ)',
    category: 'पाणी पुरवठा (Water Supply)',
    subject: 'बाजारपेठ चौकातील मुख्य पाईपलाईन गळती',
    description: 'मेन बाजारपेठेत भाजी मंडईजवळ नळाची पाईपलाईन फुटल्याने पिण्याचे पाणी वाया जात असून चिखल झाला आहे.',
    status: 'pending',
    created_at: '2026-11-10T08:30:00Z',
  },
  {
    id: 'cmp-102',
    citizen_name: 'सचिन आनंदा पाटील',
    phone: '9823012345',
    ward: 'प्रभाग १ (स्टेशन परिसर)',
    category: 'रस्त्यावरील दिवे (Street Light)',
    subject: 'रेल्वे स्टेशन रोडवरील ३ पथदिवे बंद आहेत',
    description: 'गेल्या ४ दिवसांपासून स्टेशन चौकातील पथदिवे बंद असल्याने रात्रीच्या वेळी ये-जा करणाऱ्या ग्रामस्थांना अंधाराचा त्रास होतो.',
    status: 'in_progress',
    resolution_notes: 'महावितरण वायरमनला कळवले असून दुरुस्ती सुरू आहे.',
    created_at: '2026-11-09T19:00:00Z',
  },
  {
    id: 'cmp-103',
    citizen_name: 'कैलास पुंडलिक माळी',
    phone: '9421889900',
    ward: 'प्रभाग ४ (माळी गल्ली)',
    category: 'कचरा व स्वच्छता (Sanitation)',
    subject: 'माळी गल्ली कॉर्नरवरील कचरा कुंडीची नियमित उचल होत नाही',
    description: 'कचरा जास्त साचल्याने दुर्गंधी पसरली असून डासांचा प्रादुर्भाव वाढला आहे. तात्काळ घंटागाडी पाठवावी.',
    status: 'resolved',
    resolution_notes: 'ग्रामपंचायत स्वच्छता कर्मचाऱ्यांनी कचरा उचलून परिसर स्वच्छ केला व जंतुनाशक पावडर टाकली.',
    created_at: '2026-11-08T10:15:00Z',
  },
  {
    id: 'cmp-104',
    citizen_name: 'योगेश पवार',
    phone: '9970112233',
    ward: 'प्रभाग ३ (नवीन वसाहत)',
    category: 'रस्ते दुरुस्ती (Road Repair)',
    subject: 'हायवे सर्व्हिस रोडवर मोठे खड्डे पडले आहेत',
    description: 'दोन चाकी वाहने घसरून अपघात होण्याची शक्यता आहे.',
    status: 'pending',
    created_at: '2026-11-10T14:00:00Z',
  },
];

export const Complaints: React.FC = () => {
  const [complaints, setComplaints] = useState<Complaint[]>(INITIAL_COMPLAINTS);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [categoryFilter, setCategoryFilter] = useState('all');
  const [viewingComplaint, setViewingComplaint] = useState<Complaint | null>(null);
  const [resolutionInput, setResolutionInput] = useState('');
  const { showToast } = useToast();

  const filtered = complaints.filter((c) => {
    const matchesSearch =
      c.citizen_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      c.subject.toLowerCase().includes(searchTerm.toLowerCase()) ||
      c.phone.includes(searchTerm);
    const matchesStatus = statusFilter === 'all' || c.status === statusFilter;
    const matchesCat = categoryFilter === 'all' || c.category === categoryFilter;
    return matchesSearch && matchesStatus && matchesCat;
  });

  const handleUpdateStatus = (id: string, newStatus: Complaint['status']) => {
    setComplaints((prev) =>
      prev.map((c) =>
        c.id === id
          ? {
              ...c,
              status: newStatus,
              resolution_notes: resolutionInput.trim() ? resolutionInput.trim() : c.resolution_notes,
            }
          : c
      )
    );
    showToast(`तक्रार स्थिती अद्ययावत केली: ${newStatus}`, 'success');
    if (viewingComplaint?.id === id) {
      setViewingComplaint((prev) =>
        prev
          ? {
              ...prev,
              status: newStatus,
              resolution_notes: resolutionInput.trim() ? resolutionInput.trim() : prev.resolution_notes,
            }
          : null
      );
    }
    setResolutionInput('');
  };

  const handleDelete = (id: string) => {
    if (!window.confirm('तुम्हाला ही तक्रार हटवायची आहे का?')) return;
    setComplaints((prev) => prev.filter((c) => c.id !== id));
    showToast('तक्रार हटवली.', 'success');
    setViewingComplaint(null);
  };

  return (
    <div className="space-y-6">
      <AdminPageHeader
        title="नागरिक तक्रार निवारण (Grievance Redressal)"
        subtitle="नरडाणा ग्रामस्थांच्या पाणी, वीज, रस्ते व स्वच्छतेशी संबंधित समस्यांचे निवारण"
      />

      {/* Stats Summary */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <p className="text-xs text-slate-500 font-semibold">एकूण तक्रारी</p>
          <p className="text-xl font-black text-slate-900 mt-1">{complaints.length}</p>
        </div>
        <div className="bg-white p-4 rounded-xl border border-amber-200 shadow-sm">
          <p className="text-xs text-amber-700 font-semibold">प्रलंबित (Pending)</p>
          <p className="text-xl font-black text-amber-600 mt-1">
            {complaints.filter((c) => c.status === 'pending').length}
          </p>
        </div>
        <div className="bg-white p-4 rounded-xl border border-blue-200 shadow-sm">
          <p className="text-xs text-blue-700 font-semibold">प्रगतीपथावर (In Progress)</p>
          <p className="text-xl font-black text-brand-blue mt-1">
            {complaints.filter((c) => c.status === 'in_progress').length}
          </p>
        </div>
        <div className="bg-white p-4 rounded-xl border border-emerald-200 shadow-sm">
          <p className="text-xs text-emerald-700 font-semibold">निवारण झाले (Resolved)</p>
          <p className="text-xl font-black text-emerald-600 mt-1">
            {complaints.filter((c) => c.status === 'resolved').length}
          </p>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col md:flex-row gap-3 items-center justify-between">
        <div className="relative w-full md:w-80">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
          <input
            type="text"
            placeholder="नागरिकाचे नाव, विषय किंवा फोन शोधा..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-9 pr-4 py-2 border border-slate-200 rounded-lg text-xs focus:outline-none focus:border-brand-blue"
          />
        </div>

        <div className="flex items-center gap-2 w-full md:w-auto">
          <select
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
            className="px-3 py-2 border border-slate-200 rounded-lg text-xs bg-white focus:outline-none focus:border-brand-blue"
          >
            <option value="all">सर्व प्रवर्ग</option>
            <option value="पाणी पुरवठा (Water Supply)">पाणी पुरवठा</option>
            <option value="रस्त्यावरील दिवे (Street Light)">रस्त्यावरील दिवे</option>
            <option value="कचरा व स्वच्छता (Sanitation)">कचरा व स्वच्छता</option>
            <option value="रस्ते दुरुस्ती (Road Repair)">रस्ते दुरुस्ती</option>
          </select>

          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="px-3 py-2 border border-slate-200 rounded-lg text-xs bg-white focus:outline-none focus:border-brand-blue"
          >
            <option value="all">सर्व स्थिती</option>
            <option value="pending">प्रलंबित (Pending)</option>
            <option value="in_progress">प्रगतीपथावर (In Progress)</option>
            <option value="resolved">निवारण झाले (Resolved)</option>
            <option value="rejected">नाकारले (Rejected)</option>
          </select>
        </div>
      </div>

      {/* Complaints Table */}
      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
          <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
            <tr>
              <th className="px-5 py-3">तक्रारदार नागरिक</th>
              <th className="px-5 py-3">प्रभाग / वॉर्ड</th>
              <th className="px-5 py-3">विषय व प्रवर्ग</th>
              <th className="px-5 py-3">दाखल तारीख</th>
              <th className="px-5 py-3">स्थिती</th>
              <th className="px-5 py-3 text-right">कृती</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {filtered.map((c) => (
              <tr
                key={c.id}
                onClick={() => setViewingComplaint(c)}
                className="hover:bg-blue-50/60 cursor-pointer transition"
              >
                <td className="px-5 py-3.5">
                  <p className="font-bold text-slate-800">{c.citizen_name}</p>
                  <p className="font-mono text-slate-500 text-[11px]">{c.phone}</p>
                </td>
                <td className="px-5 py-3.5 text-slate-600">{c.ward}</td>
                <td className="px-5 py-3.5">
                  <p className="font-semibold text-slate-800">{c.subject}</p>
                  <span className="text-[10px] text-brand-blue bg-blue-50 px-2 py-0.5 rounded font-semibold">
                    {c.category}
                  </span>
                </td>
                <td className="px-5 py-3.5 text-slate-500">
                  {new Date(c.created_at).toLocaleDateString('mr-IN')}
                </td>
                <td className="px-5 py-3.5">
                  <span
                    className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                      c.status === 'resolved'
                        ? 'bg-emerald-100 text-emerald-800'
                        : c.status === 'in_progress'
                        ? 'bg-blue-100 text-blue-800'
                        : c.status === 'pending'
                        ? 'bg-amber-100 text-amber-800'
                        : 'bg-rose-100 text-rose-800'
                    }`}
                  >
                    {c.status === 'resolved'
                      ? 'निवारण झाले'
                      : c.status === 'in_progress'
                      ? 'काम सुरू'
                      : c.status === 'pending'
                      ? 'प्रलंबित'
                      : 'नाकारले'}
                  </span>
                </td>
                <td className="px-5 py-3.5 text-right space-x-1" onClick={(e) => e.stopPropagation()}>
                  <button
                    onClick={() => setViewingComplaint(c)}
                    className="p-1 hover:text-brand-blue text-slate-400"
                    title="तपशील पहा"
                  >
                    <Eye className="w-4 h-4" />
                  </button>
                  {c.status !== 'resolved' && (
                    <button
                      onClick={() => handleUpdateStatus(c.id, 'resolved')}
                      className="p-1 hover:text-emerald-600 text-slate-400"
                      title="निवारण झाले म्हणून मार्क करा"
                    >
                      <CheckCircle2 className="w-4 h-4" />
                    </button>
                  )}
                  <button
                    onClick={() => handleDelete(c.id)}
                    className="p-1 hover:text-rose-600 text-slate-400"
                    title="हटवा"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Details & Resolution Modal */}
      {viewingComplaint && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-lg w-full shadow-2xl overflow-hidden border border-slate-200">
            <div className="px-6 py-4 bg-slate-50 border-b flex items-center justify-between">
              <div>
                <h3 className="font-bold text-base text-slate-900">{viewingComplaint.subject}</h3>
                <span className="text-xs text-brand-blue font-semibold">{viewingComplaint.category}</span>
              </div>
              <button onClick={() => setViewingComplaint(null)} className="p-1 rounded-lg text-slate-400 hover:text-slate-600">
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="p-6 space-y-4 text-xs text-slate-700">
              <div className="space-y-2 bg-slate-50 p-4 rounded-xl border">
                <div className="flex justify-between py-1 border-b">
                  <span className="text-slate-500">तक्रारदार:</span>
                  <span className="font-bold text-slate-800">{viewingComplaint.citizen_name}</span>
                </div>
                <div className="flex justify-between py-1 border-b">
                  <span className="text-slate-500">संपर्क नंबर:</span>
                  <span className="font-mono font-bold text-brand-blue">{viewingComplaint.phone}</span>
                </div>
                <div className="flex justify-between py-1 border-b">
                  <span className="text-slate-500">प्रभाग / ठिकाण:</span>
                  <span className="font-bold text-slate-800">{viewingComplaint.ward}</span>
                </div>
                <div className="flex justify-between py-1">
                  <span className="text-slate-500">सध्याची स्थिती:</span>
                  <span
                    className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                      viewingComplaint.status === 'resolved'
                        ? 'bg-emerald-100 text-emerald-800'
                        : viewingComplaint.status === 'in_progress'
                        ? 'bg-blue-100 text-blue-800'
                        : 'bg-amber-100 text-amber-800'
                    }`}
                  >
                    {viewingComplaint.status === 'resolved'
                      ? 'निवारण झाले (Resolved)'
                      : viewingComplaint.status === 'in_progress'
                      ? 'काम सुरू (In Progress)'
                      : 'प्रलंबित (Pending)'}
                  </span>
                </div>
              </div>

              <div>
                <span className="font-semibold block mb-1">तक्रारीचे सविस्तर वर्णन:</span>
                <p className="text-slate-700 bg-white p-3 rounded-lg border leading-relaxed">{viewingComplaint.description}</p>
              </div>

              {viewingComplaint.resolution_notes && (
                <div className="bg-emerald-50 p-3 rounded-xl border border-emerald-200">
                  <span className="font-semibold text-emerald-900 block mb-1">प्रशासकीय निवारण टिप्पणी:</span>
                  <p className="text-emerald-800 text-xs leading-relaxed">{viewingComplaint.resolution_notes}</p>
                </div>
              )}

              {/* Status Update Actions */}
              <div className="space-y-2 pt-2 border-t">
                <label className="block font-semibold text-slate-800">निवारण टिप्पणी जोडा (Resolution Note):</label>
                <input
                  type="text"
                  placeholder="उदा. नळ दुरुस्ती काम पूर्ण झाले आहे..."
                  value={resolutionInput}
                  onChange={(e) => setResolutionInput(e.target.value)}
                  className="w-full px-3 py-2 border rounded-lg text-xs focus:outline-none focus:border-brand-blue"
                />

                <div className="flex gap-2 pt-1">
                  <button
                    onClick={() => handleUpdateStatus(viewingComplaint.id, 'in_progress')}
                    className="flex-1 py-1.5 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition"
                  >
                    काम सुरू करा
                  </button>
                  <button
                    onClick={() => handleUpdateStatus(viewingComplaint.id, 'resolved')}
                    className="flex-1 py-1.5 bg-emerald-600 text-white rounded-lg font-semibold hover:bg-emerald-700 transition"
                  >
                    निवारण झाले
                  </button>
                  <button
                    onClick={() => handleUpdateStatus(viewingComplaint.id, 'rejected')}
                    className="py-1.5 px-3 border border-rose-300 text-rose-600 rounded-lg font-semibold hover:bg-rose-50"
                  >
                    नाकारा
                  </button>
                </div>
              </div>
            </div>

            <div className="px-6 py-3.5 bg-slate-50 border-t flex items-center justify-between">
              <button
                onClick={() => handleDelete(viewingComplaint.id)}
                className="px-3 py-1.5 text-rose-600 hover:bg-rose-50 rounded-lg font-semibold inline-flex items-center gap-1 text-xs"
              >
                <Trash2 className="w-3.5 h-3.5" /> हटवा
              </button>
              <button
                onClick={() => setViewingComplaint(null)}
                className="px-4 py-1.5 bg-slate-200 text-slate-700 rounded-lg hover:bg-slate-300 font-semibold text-xs"
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
