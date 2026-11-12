import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { PhoneCall, Search, Plus, Eye, Trash2, X, Phone, ShieldCheck } from 'lucide-react';
import { useToast } from '../components/Toast';
import { AdminPageHeader } from '../components/AdminPageHeader';

interface Contact {
  id: string;
  name_mr: string;
  name_en?: string;
  category: string;
  phone: string;
  sort_order: number;
  is_active: boolean;
}

const DEFAULT_HELPLINES: Contact[] = [
  {
    id: 'em-1',
    name_mr: 'ग्रामपंचायत कार्यालय नरडाणा (Gram Panchayat Nardana)',
    name_en: 'Gram Panchayat Office Nardana',
    category: 'प्रशासकीय कार्यालय',
    phone: '02566258200',
    sort_order: 10,
    is_active: true,
  },
  {
    id: 'em-2',
    name_mr: 'प्राथमिक आरोग्य केंद्र नरडाणा (PHC Nardana)',
    name_en: 'Primary Health Centre Nardana',
    category: 'आरोग्य व रुग्णालय',
    phone: '02566258210',
    sort_order: 20,
    is_active: true,
  },
  {
    id: 'em-3',
    name_mr: '१०८ रुग्णवाहिका तात्काळ सेवा (Emergency Ambulance)',
    name_en: '108 Ambulance Service',
    category: 'रुग्णवाहिका (Ambulance)',
    phone: '108',
    sort_order: 30,
    is_active: true,
  },
  {
    id: 'em-4',
    name_mr: 'नरडाणा पोलीस दूरक्षेत्र (Nardana Police Outpost)',
    name_en: 'Nardana Police Outpost',
    category: 'पोलीस व सुरक्षा',
    phone: '02566258222',
    sort_order: 40,
    is_active: true,
  },
  {
    id: 'em-5',
    name_mr: 'महावितरण वीज तक्रार केंद्र (MSEDCL Electricity Substation)',
    name_en: 'MSEDCL Nardana',
    category: 'वीज पुरवठा (Electricity)',
    phone: '18002333435',
    sort_order: 50,
    is_active: true,
  },
  {
    id: 'em-6',
    name_mr: 'सर्पमित्र हेल्पलाइन (Snake Rescuer Nardana)',
    name_en: 'Snake Rescuer Helpline',
    category: 'वन्यजीव व सर्पमित्र',
    phone: '9421526400',
    sort_order: 60,
    is_active: true,
  },
  {
    id: 'em-7',
    name_mr: 'अग्निशामक दल (Fire Emergency)',
    name_en: 'Fire Emergency',
    category: 'अग्निशामक दल',
    phone: '101',
    sort_order: 70,
    is_active: true,
  },
];

export const EmergencyContacts: React.FC = () => {
  const [contacts, setContacts] = useState<Contact[]>(DEFAULT_HELPLINES);
  const [searchTerm, setSearchTerm] = useState('');
  const [viewingContact, setViewingContact] = useState<Contact | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const { showToast } = useToast();

  // Form states
  const [formNameMr, setFormNameMr] = useState('');
  const [formCategory, setFormCategory] = useState('आरोग्य व रुग्णालय');
  const [formPhone, setFormPhone] = useState('');

  async function fetchContacts() {
    try {
      const { data, error } = await supabase.from('emergency_contacts').select('*').order('sort_order');
      if (!error && data && data.length > 0) {
        setContacts(data);
      }
    } catch (_) {}
  }

  useEffect(() => {
    fetchContacts();
  }, []);

  const filtered = contacts.filter(
    (c) =>
      c.name_mr.toLowerCase().includes(searchTerm.toLowerCase()) ||
      c.category.toLowerCase().includes(searchTerm.toLowerCase()) ||
      c.phone.includes(searchTerm)
  );

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formNameMr.trim() || !formPhone.trim()) {
      showToast('नाव व फोन नंबर आवश्यक आहे.', 'error');
      return;
    }

    const newContact: Contact = {
      id: `em-${Date.now()}`,
      name_mr: formNameMr.trim(),
      category: formCategory,
      phone: formPhone.trim(),
      sort_order: (contacts.length + 1) * 10,
      is_active: true,
    };

    setContacts([...contacts, newContact]);
    showToast('तातडीचा दूरध्वनी क्रमांक यशस्वीरीत्या जोडला!', 'success');
    setIsModalOpen(false);
    setFormNameMr('');
    setFormPhone('');

    try {
      await supabase.from('emergency_contacts').insert(newContact);
    } catch (_) {}
  };

  const handleDelete = async (id: string, name: string) => {
    if (!window.confirm(`तुम्हाला '${name}' हा संपर्क क्रमांक हटवायचा आहे का?`)) return;
    setContacts(contacts.filter((c) => c.id !== id));
    showToast('क्रमांक हटवला गेला.', 'success');
    setViewingContact(null);

    try {
      await supabase.from('emergency_contacts').delete().eq('id', id);
    } catch (_) {}
  };

  return (
    <div className="space-y-6">
      <AdminPageHeader
        title="तातडीचे व आपत्कालीन क्रमांक (Emergency Contacts)"
        subtitle="नरडाणा गावकर्‍यांसाठी २४ तास आवश्यक असणारे शासकीय व आरोग्य दूरध्वनी क्रमांक"
        actions={
          <button
            onClick={() => setIsModalOpen(true)}
            className="flex items-center space-x-1.5 px-4 py-2 bg-rose-600 hover:bg-rose-700 text-white rounded-xl text-xs font-semibold shadow-sm transition"
          >
            <Plus className="w-4 h-4" />
            <span>नवीन हेल्पलाइन जोडा</span>
          </button>
        }
      />

      {/* Search Bar */}
      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between">
        <div className="relative w-full md:w-80">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
          <input
            type="text"
            placeholder="नाव, प्रवर्ग किंवा फोन नंबर शोधा..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-9 pr-4 py-2 border border-slate-200 rounded-lg text-xs focus:outline-none focus:border-brand-blue"
          />
        </div>
        <div className="text-xs text-slate-500 font-semibold flex items-center gap-1.5">
          <ShieldCheck className="w-4 h-4 text-emerald-600" />
          <span>केवळ नरडाणा गाव कार्यक्षेत्र</span>
        </div>
      </div>

      {/* Contacts Table */}
      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
          <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
            <tr>
              <th className="px-5 py-3">संस्थेचे / सेवेचे नाव</th>
              <th className="px-5 py-3">प्रवर्ग</th>
              <th className="px-5 py-3">दूरध्वनी क्रमांक</th>
              <th className="px-5 py-3">कार्यक्षेत्र</th>
              <th className="px-5 py-3">स्थिती</th>
              <th className="px-5 py-3 text-right">कृती</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {filtered.map((c) => (
              <tr
                key={c.id}
                onClick={() => setViewingContact(c)}
                className="hover:bg-blue-50/60 cursor-pointer transition"
              >
                <td className="px-5 py-3.5 font-bold text-slate-800 flex items-center gap-2">
                  <PhoneCall className="w-3.5 h-3.5 text-rose-600 flex-shrink-0" />
                  <span>{c.name_mr}</span>
                </td>
                <td className="px-5 py-3.5 text-slate-600">{c.category}</td>
                <td className="px-5 py-3.5">
                  <span className="font-mono font-bold text-brand-blue bg-blue-50 px-2 py-0.5 rounded border border-blue-200">
                    {c.phone}
                  </span>
                </td>
                <td className="px-5 py-3.5 text-slate-600 font-semibold">नरडाणा (४२५४०४)</td>
                <td className="px-5 py-3.5">
                  <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-100 text-emerald-800">
                    सक्रिय २४ तास
                  </span>
                </td>
                <td className="px-5 py-3.5 text-right space-x-1" onClick={(e) => e.stopPropagation()}>
                  <button
                    onClick={() => setViewingContact(c)}
                    className="p-1 hover:text-brand-blue text-slate-400"
                    title="तपशील पहा"
                  >
                    <Eye className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDelete(c.id, c.name_mr)}
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

      {/* Add Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-sm w-full p-6 shadow-2xl border border-slate-200 space-y-4">
            <div className="flex items-center justify-between border-b pb-3">
              <h3 className="font-bold text-sm text-slate-900 flex items-center gap-2">
                <PhoneCall className="w-4 h-4 text-rose-600" /> नवीन आपत्कालीन क्रमांक जोडा
              </h3>
              <button onClick={() => setIsModalOpen(false)} className="text-slate-400 hover:text-slate-600">
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleAdd} className="space-y-3 text-xs">
              <div>
                <label className="block font-semibold mb-1">नाव (मराठीत) *</label>
                <input
                  type="text"
                  required
                  placeholder="उदा. प्राथमिक आरोग्य केंद्र नरडाणा"
                  value={formNameMr}
                  onChange={(e) => setFormNameMr(e.target.value)}
                  className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-brand-blue"
                />
              </div>

              <div>
                <label className="block font-semibold mb-1">प्रवर्ग *</label>
                <select
                  value={formCategory}
                  onChange={(e) => setFormCategory(e.target.value)}
                  className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-brand-blue bg-white"
                >
                  <option value="आरोग्य व रुग्णालय">आरोग्य व रुग्णालय</option>
                  <option value="रुग्णवाहिका (Ambulance)">रुग्णवाहिका (Ambulance)</option>
                  <option value="पोलीस व सुरक्षा">पोलीस व सुरक्षा</option>
                  <option value="वीज पुरवठा (Electricity)">वीज पुरवठा (Electricity)</option>
                  <option value="प्रशासकीय कार्यालय">प्रशासकीय कार्यालय</option>
                  <option value="वन्यजीव व सर्पमित्र">वन्यजीव व सर्पमित्र</option>
                  <option value="अग्निशामक दल">अग्निशामक दल</option>
                </select>
              </div>

              <div>
                <label className="block font-semibold mb-1">दूरध्वनी क्रमांक *</label>
                <input
                  type="tel"
                  required
                  placeholder="उदा. 02566258210 किंवा 108"
                  value={formPhone}
                  onChange={(e) => setFormPhone(e.target.value)}
                  className="w-full px-3 py-2 border rounded-lg font-mono focus:outline-none focus:border-brand-blue"
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
                  className="px-4 py-2 bg-rose-600 text-white rounded-lg hover:bg-rose-700 font-semibold"
                >
                  जोडा
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Details View Modal */}
      {viewingContact && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-sm w-full shadow-2xl overflow-hidden border border-slate-200">
            <div className="px-6 py-4 bg-slate-50 border-b flex items-center justify-between">
              <div>
                <h3 className="font-bold text-base text-slate-900">{viewingContact.name_mr}</h3>
                <span className="text-xs text-rose-600 font-semibold">{viewingContact.category}</span>
              </div>
              <button onClick={() => setViewingContact(null)} className="p-1 rounded-lg text-slate-400 hover:text-slate-600">
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="p-6 space-y-4 text-xs text-slate-700">
              <div className="p-3 bg-rose-50/70 rounded-xl border border-rose-200 flex items-center justify-between">
                <div>
                  <span className="text-[11px] text-rose-800 font-semibold block">हेल्पलाइन क्रमांक</span>
                  <span className="font-mono text-base font-bold text-rose-700">{viewingContact.phone}</span>
                </div>
                <a
                  href={`tel:${viewingContact.phone}`}
                  className="px-3 py-1.5 bg-rose-600 text-white rounded-lg font-bold text-xs hover:bg-rose-700 flex items-center gap-1"
                >
                  <Phone className="w-3.5 h-3.5" /> चाचणी कॉल
                </a>
              </div>

              <div className="space-y-2 bg-slate-50 p-4 rounded-xl border">
                <div className="flex justify-between py-1 border-b">
                  <span className="text-slate-500">प्रवर्ग:</span>
                  <span className="font-bold text-slate-800">{viewingContact.category}</span>
                </div>
                <div className="flex justify-between py-1 border-b">
                  <span className="text-slate-500">अधिकृत गाव:</span>
                  <span className="font-bold text-brand-blue">नरडाणा गाव (४२५४०४)</span>
                </div>
                <div className="flex justify-between py-1">
                  <span className="text-slate-500">ॲपमधील स्थिती:</span>
                  <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-100 text-emerald-800">
                    सक्रिय २४ तास (Live)
                  </span>
                </div>
              </div>
            </div>

            <div className="px-6 py-3.5 bg-slate-50 border-t flex items-center justify-between">
              <button
                onClick={() => handleDelete(viewingContact.id, viewingContact.name_mr)}
                className="px-3 py-1.5 text-rose-600 hover:bg-rose-50 rounded-lg font-semibold inline-flex items-center gap-1 text-xs"
              >
                <Trash2 className="w-3.5 h-3.5" /> हटवा
              </button>
              <button
                onClick={() => setViewingContact(null)}
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
