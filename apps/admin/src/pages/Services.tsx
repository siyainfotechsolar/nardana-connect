import React, { useState } from 'react';
import { Wrench, Search, Plus, Eye, CheckCircle, XCircle, Trash2, Phone, X } from 'lucide-react';
import { useToast } from '../components/Toast';
import { AdminPageHeader } from '../components/AdminPageHeader';

interface ServiceRecord {
  id: string;
  name_mr: string;
  name_en?: string;
  category: string;
  provider_name: string;
  phone: string;
  address: string;
  description?: string;
  opening_hours: string;
  status: 'pending' | 'approved' | 'rejected';
  created_at: string;
}

const INITIAL_SERVICES: ServiceRecord[] = [
  {
    id: 'srv-1',
    name_mr: 'साई प्लंबिंग व पाईपलाईन फिटिंग',
    name_en: 'Sai Plumbing Services',
    category: 'प्लंबर व पाणी फिटिंग',
    provider_name: 'कैलास माळी',
    phone: '9421889900',
    address: 'स्टेशन परिसर, नरडाणा',
    description: 'घरगुती व शेतातील पाईपलाईन लीकेज दुरुस्ती आणि नवीन नळ जोडणी.',
    opening_hours: 'सकाळी ८:०० ते संध्याकाळी ८:००',
    status: 'approved',
    created_at: '2026-11-08T10:00:00Z',
  },
  {
    id: 'srv-2',
    name_mr: 'जय भवानी इलेक्ट्रिकल वर्क्स',
    name_en: 'Jai Bhavani Electrical Works',
    category: 'इलेक्ट्रिशियन',
    provider_name: 'सचिन पाटील',
    phone: '9823012345',
    address: 'स्टेशन रोड, नरडाणा',
    description: 'घरगुती व शेती पंपाचे सर्व प्रकारचे वायरिंग व मोटार दुरुस्ती काम.',
    opening_hours: 'सकाळी ९:०० ते रात्री ८:००',
    status: 'approved',
    created_at: '2026-11-09T11:00:00Z',
  },
  {
    id: 'srv-3',
    name_mr: 'किसान ट्रॅक्टर व रोटाव्हेटर सर्व्हिस',
    name_en: 'Kisan Tractor Service',
    category: 'ट्रॅक्टर व शेती अवजारे भाड्याने',
    provider_name: 'दिनेश चौधरी',
    phone: '9765432100',
    address: 'हायवे चौक, नरडाणा',
    description: 'नांगरणी, रोटाव्हेटर आणि पेरणीसाठी २४ तास महिंद्रा ट्रॅक्टर उपलब्ध.',
    opening_hours: '२४ तास सेवा',
    status: 'approved',
    created_at: '2026-11-09T14:30:00Z',
  },
  {
    id: 'srv-4',
    name_mr: 'गजानन सुतारकाम व फर्निचर',
    name_en: 'Gajanan Carpentry Works',
    category: 'सुतारकाम व फर्निचर',
    provider_name: 'अमोल सुतार',
    phone: '9822334455',
    address: 'कुंभार गल्ली, नरडाणा',
    description: 'सर्व प्रकारचे लाकडी दरवाजे, खिडक्या व कपाट बनवणे व दुरुस्तीचे काम.',
    opening_hours: 'सकाळी ८:३० ते संध्याकाळी ६:३०',
    status: 'approved',
    created_at: '2026-11-10T09:15:00Z',
  },
  {
    id: 'srv-5',
    name_mr: 'नरडाणा ऑटो रिक्षा व स्थानिक प्रवासी वाहतूक',
    name_en: 'Nardana Auto Service',
    category: 'ऑटो / टॅक्सी वाहतूक',
    provider_name: 'संतोष भिल',
    phone: '9822445566',
    address: 'रेल्वे स्टेशन चौक, नरडाणा',
    description: 'नरडाणा ते शिंदखेडा, धुळे व गावातील प्रवासासाठी २४ तास ऑटो सेवा.',
    opening_hours: '२४ तास सेवा',
    status: 'approved',
    created_at: '2026-11-10T12:00:00Z',
  },
];

export const Services: React.FC = () => {
  const [services, setServices] = useState<ServiceRecord[]>(INITIAL_SERVICES);
  const [searchTerm, setSearchTerm] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');
  const [viewingService, setViewingService] = useState<ServiceRecord | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const { showToast } = useToast();

  // Form states
  const [formNameMr, setFormNameMr] = useState('');
  const [formCategory, setFormCategory] = useState('इलेक्ट्रिशियन');
  const [formProvider, setFormProvider] = useState('');
  const [formPhone, setFormPhone] = useState('');
  const [formAddress, setFormAddress] = useState('नरडाणा');
  const [formHours, setFormHours] = useState('सकाळी ८:०० ते संध्याकाळी ८:००');
  const [formDesc, setFormDesc] = useState('');

  const filtered = services.filter((s) => {
    const matchesSearch =
      s.name_mr.toLowerCase().includes(searchTerm.toLowerCase()) ||
      s.provider_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      s.phone.includes(searchTerm);
    const matchesCat = categoryFilter === 'all' || s.category === categoryFilter;
    const matchesStatus = statusFilter === 'all' || s.status === statusFilter;
    return matchesSearch && matchesCat && matchesStatus;
  });

  const handleAddService = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formNameMr.trim() || !formPhone.trim()) {
      showToast('नाव आणि फोन नंबर आवश्यक आहे.', 'error');
      return;
    }

    const newRecord: ServiceRecord = {
      id: `srv-${Date.now()}`,
      name_mr: formNameMr.trim(),
      category: formCategory,
      provider_name: formProvider.trim() || 'स्थानिक कारागीर',
      phone: formPhone.trim(),
      address: formAddress.trim(),
      description: formDesc.trim(),
      opening_hours: formHours.trim(),
      status: 'approved',
      created_at: new Date().toISOString(),
    };

    setServices([newRecord, ...services]);
    showToast('नवीन सेवा यशस्वीरीत्या जोडली!', 'success');
    setIsModalOpen(false);
    setFormNameMr('');
    setFormProvider('');
    setFormPhone('');
    setFormDesc('');
  };

  const handleUpdateStatus = (id: string, newStatus: 'approved' | 'rejected') => {
    setServices((prev) =>
      prev.map((s) => (s.id === id ? { ...s, status: newStatus } : s))
    );
    showToast(newStatus === 'approved' ? 'सेवा मंजूर केली!' : 'सेवा नाकारली.', 'success');
    if (viewingService?.id === id) {
      setViewingService((prev) => (prev ? { ...prev, status: newStatus } : null));
    }
  };

  const handleDelete = (id: string) => {
    if (!window.confirm('तुम्हाला ही सेवा हटवायची आहे का?')) return;
    setServices((prev) => prev.filter((s) => s.id !== id));
    showToast('सेवा यशस्वीरीत्या हटवली.', 'success');
    setViewingService(null);
  };

  return (
    <div className="space-y-6">
      <AdminPageHeader
        title="स्थानिक सेवा व्यवस्थापन (Local Services)"
        subtitle="नरडाणा गावातील प्लंबर, इलेक्ट्रिशियन, ट्रॅक्टर व घरगुती सेवांचे नियंत्रण"
        actions={
          <button
            onClick={() => setIsModalOpen(true)}
            className="flex items-center space-x-1.5 px-4 py-2 bg-brand-blue hover:bg-blue-700 text-white rounded-xl text-xs font-semibold shadow-sm transition"
          >
            <Plus className="w-4 h-4" />
            <span>नवीन सेवा जोडा</span>
          </button>
        }
      />

      {/* Filter and Search Bar */}
      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col md:flex-row gap-3 items-center justify-between">
        <div className="relative w-full md:w-80">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
          <input
            type="text"
            placeholder="सेवा, कारागीर किंवा फोन शोधा..."
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
            <option value="all">सर्व कॅटेगरी</option>
            <option value="प्लंबर व पाणी फिटिंग">प्लंबर</option>
            <option value="इलेक्ट्रिशियन">इलेक्ट्रिशियन</option>
            <option value="ट्रॅक्टर व शेती अवजारे भाड्याने">ट्रॅक्टर / शेती</option>
            <option value="सुतारकाम व फर्निचर">सुतारकाम</option>
            <option value="ऑटो / टॅक्सी वाहतूक">ऑटो / टॅक्सी</option>
          </select>

          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="px-3 py-2 border border-slate-200 rounded-lg text-xs bg-white focus:outline-none focus:border-brand-blue"
          >
            <option value="all">सर्व स्थिती</option>
            <option value="approved">मंजूर (Approved)</option>
            <option value="pending">प्रलंबित (Pending)</option>
            <option value="rejected">नाकारलेले (Rejected)</option>
          </select>
        </div>
      </div>

      {/* Services Table */}
      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
          <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
            <tr>
              <th className="px-5 py-3">सेवेचे नाव</th>
              <th className="px-5 py-3">कॅटेगरी</th>
              <th className="px-5 py-3">कारागीर / मालक</th>
              <th className="px-5 py-3">संपर्क नंबर</th>
              <th className="px-5 py-3">ठिकाण</th>
              <th className="px-5 py-3">स्थिती</th>
              <th className="px-5 py-3 text-right">कृती</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {filtered.length === 0 ? (
              <tr>
                <td colSpan={7} className="px-5 py-8 text-center text-slate-400">
                  कोणतीही सेवा आढळली नाही.
                </td>
              </tr>
            ) : (
              filtered.map((s) => (
                <tr
                  key={s.id}
                  onClick={() => setViewingService(s)}
                  className="hover:bg-blue-50/60 cursor-pointer transition"
                >
                  <td className="px-5 py-3.5 font-bold text-slate-800 flex items-center gap-2">
                    <Wrench className="w-3.5 h-3.5 text-brand-blue flex-shrink-0" />
                    <span>{s.name_mr}</span>
                  </td>
                  <td className="px-5 py-3.5">
                    <span className="px-2 py-0.5 rounded text-[11px] font-semibold bg-blue-50 text-brand-blue">
                      {s.category}
                    </span>
                  </td>
                  <td className="px-5 py-3.5 text-slate-700">{s.provider_name}</td>
                  <td className="px-5 py-3.5 font-mono text-slate-600">{s.phone}</td>
                  <td className="px-5 py-3.5 text-slate-500">{s.address}</td>
                  <td className="px-5 py-3.5">
                    <span
                      className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                        s.status === 'approved'
                          ? 'bg-emerald-100 text-emerald-800'
                          : s.status === 'pending'
                          ? 'bg-amber-100 text-amber-800'
                          : 'bg-rose-100 text-rose-800'
                      }`}
                    >
                      {s.status === 'approved' ? 'मंजूर' : s.status === 'pending' ? 'प्रलंबित' : 'नाकारले'}
                    </span>
                  </td>
                  <td className="px-5 py-3.5 text-right space-x-1" onClick={(e) => e.stopPropagation()}>
                    <button
                      onClick={() => setViewingService(s)}
                      className="p-1 hover:text-brand-blue text-slate-400"
                      title="तपशील पहा"
                    >
                      <Eye className="w-4 h-4" />
                    </button>
                    {s.status !== 'approved' && (
                      <button
                        onClick={() => handleUpdateStatus(s.id, 'approved')}
                        className="p-1 hover:text-emerald-600 text-slate-400"
                        title="मंजूर करा"
                      >
                        <CheckCircle className="w-4 h-4" />
                      </button>
                    )}
                    {s.status !== 'rejected' && (
                      <button
                        onClick={() => handleUpdateStatus(s.id, 'rejected')}
                        className="p-1 hover:text-rose-600 text-slate-400"
                        title="नाकारा"
                      >
                        <XCircle className="w-4 h-4" />
                      </button>
                    )}
                    <button
                      onClick={() => handleDelete(s.id)}
                      className="p-1 hover:text-rose-600 text-slate-400"
                      title="हटवा"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Create Service Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl border border-slate-200 space-y-4">
            <div className="flex items-center justify-between border-b pb-3">
              <h3 className="font-bold text-sm text-slate-900 flex items-center gap-2">
                <Wrench className="w-4 h-4 text-brand-blue" /> नवीन सेवा नोंदणी (Nardana Only)
              </h3>
              <button onClick={() => setIsModalOpen(false)} className="text-slate-400 hover:text-slate-600">
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleAddService} className="space-y-3 text-xs">
              <div>
                <label className="block font-semibold mb-1">सेवेचे नाव *</label>
                <input
                  type="text"
                  required
                  placeholder="उदा. साई प्लंबिंग वर्क्स"
                  value={formNameMr}
                  onChange={(e) => setFormNameMr(e.target.value)}
                  className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-brand-blue"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold mb-1">कॅटेगरी *</label>
                  <select
                    value={formCategory}
                    onChange={(e) => setFormCategory(e.target.value)}
                    className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-brand-blue bg-white"
                  >
                    <option value="प्लंबर व पाणी फिटिंग">प्लंबर</option>
                    <option value="इलेक्ट्रिशियन">इलेक्ट्रिशियन</option>
                    <option value="ट्रॅक्टर व शेती अवजारे भाड्याने">ट्रॅक्टर / शेती</option>
                    <option value="सुतारकाम व फर्निचर">सुतारकाम</option>
                    <option value="ऑटो / टॅक्सी वाहतूक">ऑटो / टॅक्सी</option>
                    <option value="महा-ई-सेवा व झेरॉक्स">महा-ई-सेवा</option>
                  </select>
                </div>
                <div>
                  <label className="block font-semibold mb-1">कारागीर / मालकाचे नाव *</label>
                  <input
                    type="text"
                    required
                    placeholder="उदा. कैलास माळी"
                    value={formProvider}
                    onChange={(e) => setFormProvider(e.target.value)}
                    className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-brand-blue"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold mb-1">मोबाईल नंबर *</label>
                  <input
                    type="tel"
                    required
                    placeholder="उदा. 9822011223"
                    value={formPhone}
                    onChange={(e) => setFormPhone(e.target.value)}
                    className="w-full px-3 py-2 border rounded-lg font-mono focus:outline-none focus:border-brand-blue"
                  />
                </div>
                <div>
                  <label className="block font-semibold mb-1">कामाची वेळ</label>
                  <input
                    type="text"
                    placeholder="उदा. सकाळी ८:०० ते संध्याकाळी ८:००"
                    value={formHours}
                    onChange={(e) => setFormHours(e.target.value)}
                    className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-brand-blue"
                  />
                </div>
              </div>

              <div>
                <label className="block font-semibold mb-1">पत्ता (नरडाणा गाव)</label>
                <input
                  type="text"
                  placeholder="उदा. स्टेशन परिसर, नरडाणा"
                  value={formAddress}
                  onChange={(e) => setFormAddress(e.target.value)}
                  className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-brand-blue"
                />
              </div>

              <div>
                <label className="block font-semibold mb-1">तपशील व उपलब्ध काम</label>
                <textarea
                  rows={2}
                  placeholder="कामाचे स्वरूप, दर व अनुभव..."
                  value={formDesc}
                  onChange={(e) => setFormDesc(e.target.value)}
                  className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-brand-blue"
                />
              </div>

              <div className="flex justify-end gap-2 pt-3 border-t">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 border text-slate-600 rounded-lg hover:bg-slate-50"
                >
                  रद्द करा
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-brand-blue text-white rounded-lg hover:bg-blue-700 font-semibold"
                >
                  जतन करा
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Details View Modal */}
      {viewingService && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-md w-full shadow-2xl overflow-hidden border border-slate-200">
            <div className="px-6 py-4 bg-slate-50 border-b flex items-center justify-between">
              <div>
                <h3 className="font-bold text-base text-slate-900">{viewingService.name_mr}</h3>
                <span className="text-xs text-brand-blue font-semibold">{viewingService.category}</span>
              </div>
              <button onClick={() => setViewingService(null)} className="p-1 rounded-lg text-slate-400 hover:text-slate-600">
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="p-6 space-y-3 text-xs text-slate-700">
              <div className="p-3 bg-blue-50/70 rounded-xl border border-blue-200 flex items-center justify-between">
                <div>
                  <span className="text-[11px] text-blue-800 font-semibold block">कारागीर संपर्क</span>
                  <span className="font-mono text-base font-bold text-brand-blue">{viewingService.phone}</span>
                </div>
                <a
                  href={`tel:${viewingService.phone}`}
                  className="px-3 py-1.5 bg-brand-blue text-white rounded-lg font-bold text-xs hover:bg-blue-700 flex items-center gap-1"
                >
                  <Phone className="w-3.5 h-3.5" /> कॉल करा
                </a>
              </div>

              <div className="space-y-2 bg-slate-50 p-4 rounded-xl border">
                <div className="flex justify-between py-1 border-b">
                  <span className="text-slate-500">मालक / कारागीर:</span>
                  <span className="font-bold text-slate-800">{viewingService.provider_name}</span>
                </div>
                <div className="flex justify-between py-1 border-b">
                  <span className="text-slate-500">कामाची वेळ:</span>
                  <span className="font-bold text-slate-800">{viewingService.opening_hours}</span>
                </div>
                <div className="flex justify-between py-1 border-b">
                  <span className="text-slate-500">पत्ता:</span>
                  <span className="font-bold text-brand-blue">{viewingService.address}</span>
                </div>
                <div className="flex justify-between py-1">
                  <span className="text-slate-500">सध्याची स्थिती:</span>
                  <span
                    className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                      viewingService.status === 'approved'
                        ? 'bg-emerald-100 text-emerald-800'
                        : 'bg-amber-100 text-amber-800'
                    }`}
                  >
                    {viewingService.status === 'approved' ? 'सक्रिय (Live on Mobile App)' : 'प्रलंबित'}
                  </span>
                </div>
              </div>

              {viewingService.description && (
                <div>
                  <span className="font-semibold block mb-1">वर्णन:</span>
                  <p className="text-slate-600 bg-white p-2.5 rounded-lg border">{viewingService.description}</p>
                </div>
              )}
            </div>

            <div className="px-6 py-3.5 bg-slate-50 border-t flex items-center justify-between">
              <button
                onClick={() => handleDelete(viewingService.id)}
                className="px-3 py-1.5 text-rose-600 hover:bg-rose-50 rounded-lg font-semibold inline-flex items-center gap-1 text-xs"
              >
                <Trash2 className="w-3.5 h-3.5" /> हटवा
              </button>
              <button
                onClick={() => setViewingService(null)}
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
