import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { 
  Server, 
  Palette, 
  PhoneCall, 
  Plus, 
  Trash2, 
  X, 
  Smartphone, 
  ExternalLink 
} from 'lucide-react';
import { useToast } from '../components/Toast';

interface EmergencyContact {
  id: string;
  name_mr: string;
  name_en: string;
  category: string;
  phone: string;
  alternate_phone?: string;
  sort_order: number;
  is_active: boolean;
}

export const Settings: React.FC = () => {
  const [contacts, setContacts] = useState<EmergencyContact[]>([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [nameMr, setNameMr] = useState('');
  const [nameEn, setNameEn] = useState('');
  const [phone, setPhone] = useState('');
  const [category, setCategory] = useState('आरोग्य (Health)');
  const [submitting, setSubmitting] = useState(false);

  const { showToast } = useToast();

  async function fetchEmergencyContacts() {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('emergency_contacts')
        .select('*')
        .order('sort_order');

      if (error) throw error;
      setContacts(data || []);
    } catch (err: any) {
      console.error('Error fetching emergency contacts:', err);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchEmergencyContacts();
  }, []);

  async function handleAddContact(e: React.FormEvent) {
    e.preventDefault();
    if (!nameMr.trim() || !phone.trim()) {
      showToast('नाव आणि फोन नंबर आवश्यक आहे.', 'error');
      return;
    }

    try {
      setSubmitting(true);
      const { error } = await supabase
        .from('emergency_contacts')
        .insert({
          name_mr: nameMr.trim(),
          name_en: nameEn.trim() || nameMr.trim(),
          phone: phone.trim(),
          category: category,
          sort_order: (contacts.length + 1) * 10,
          is_active: true,
        });

      if (error) throw error;
      showToast('तातडीचा संपर्क क्रमांक जोडला!', 'success');
      setNameMr('');
      setNameEn('');
      setPhone('');
      setIsModalOpen(false);
      fetchEmergencyContacts();
    } catch (err: any) {
      showToast('जतन करताना त्रुटी: ' + err.message, 'error');
    } finally {
      setSubmitting(false);
    }
  }

  async function handleDeleteContact(id: string, name: string) {
    if (!window.confirm(`तुम्हाला '${name}' हा संपर्क क्रमांक हटवायचा आहे का?`)) return;

    try {
      const { error } = await supabase
        .from('emergency_contacts')
        .delete()
        .eq('id', id);

      if (error) throw error;
      setContacts(prev => prev.filter(c => c.id !== id));
      showToast('संपर्क क्रमांक हटवला.', 'success');
    } catch (err: any) {
      showToast('हटवताना त्रुटी: ' + err.message, 'error');
    }
  }

  return (
    <div className="space-y-6 max-w-5xl">
      <div>
        <h2 className="text-xl font-bold text-slate-900">प्लॅटफॉर्म सेटिंग्ज व नियंत्रण (Settings)</h2>
        <p className="text-xs text-slate-500">
          नरडाणा कनेक्ट कम्युनिटी ॲप (केवळ नरडाणा गाव), तातडीचे दूरध्वनी क्रमांक व बॅकएंड संरचना माहिती
        </p>
      </div>

      {/* Emergency Contacts Management */}
      <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-sm space-y-4">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div>
            <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
              <PhoneCall className="w-4 h-4 text-rose-600" />
              तातडीचे व आपत्कालीन दूरध्वनी क्रमांक (Emergency Helplines)
            </h3>
            <p className="text-xs text-slate-500">
              ॲपमधील "आपत्कालीन" टॅबमध्ये गावकर्‍यांसाठी दिसणारे महत्वाचे सरकारी व रुग्णवाहिका क्रमांक
            </p>
          </div>
          <button
            onClick={() => setIsModalOpen(true)}
            className="flex items-center space-x-1 px-3 py-1.5 bg-rose-600 text-white rounded-lg text-xs font-semibold hover:bg-rose-700 transition"
          >
            <Plus className="w-3.5 h-3.5" />
            <span>नवीन हेल्पलाइन जोडा</span>
          </button>
        </div>

        <div className="divide-y divide-slate-100 border border-slate-200 rounded-lg overflow-hidden">
          {loading ? (
            <p className="p-4 text-xs text-slate-400 text-center">माहिती लोड होत आहे...</p>
          ) : contacts.length === 0 ? (
            <p className="p-4 text-xs text-slate-400 text-center">कोणतेही आपत्कालीन संपर्क नाहीत.</p>
          ) : (
            contacts.map((c) => (
              <div key={c.id} className="p-3 flex items-center justify-between hover:bg-slate-50 transition text-xs">
                <div className="space-y-0.5">
                  <p className="font-bold text-slate-800">{c.name_mr} ({c.name_en})</p>
                  <p className="text-[11px] text-slate-500">{c.category}</p>
                </div>
                <div className="flex items-center gap-3">
                  <span className="font-mono font-bold text-brand-blue bg-blue-50 px-2 py-0.5 rounded border border-blue-200">
                    {c.phone}
                  </span>
                  <button
                    onClick={() => handleDeleteContact(c.id, c.name_mr)}
                    className="p-1 text-slate-400 hover:text-rose-600 rounded"
                    title="हटवा"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      </div>

      {/* Brand Color Tokens */}
      <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-sm space-y-4">
        <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
          <Palette className="w-4 h-4 text-brand-blue" /> अधिकृत ब्रँडिंग आणि रंगसंगती
        </h3>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 text-xs">
          <div className="p-3 rounded-lg border border-slate-200 bg-white">
            <div className="w-full h-8 rounded bg-[#123B67] mb-2 shadow-inner"></div>
            <p className="font-bold">Deep Blue</p>
            <p className="text-slate-400 font-mono text-[11px]">#123B67 (Primary)</p>
          </div>
          <div className="p-3 rounded-lg border border-slate-200 bg-white">
            <div className="w-full h-8 rounded bg-[#16A36A] mb-2 shadow-inner"></div>
            <p className="font-bold">Green</p>
            <p className="text-slate-400 font-mono text-[11px]">#16A36A (Secondary)</p>
          </div>
          <div className="p-3 rounded-lg border border-slate-200 bg-white">
            <div className="w-full h-8 rounded bg-[#F3B83F] mb-2 shadow-inner"></div>
            <p className="font-bold">Golden Yellow</p>
            <p className="text-slate-400 font-mono text-[11px]">#F3B83F (Accent)</p>
          </div>
          <div className="p-3 rounded-lg border border-slate-200 bg-white">
            <div className="w-full h-8 rounded bg-slate-900 mb-2 shadow-inner"></div>
            <p className="font-bold">Dark Slate</p>
            <p className="text-slate-400 font-mono text-[11px]">#0D2745 (Sidebar)</p>
          </div>
        </div>
      </div>

      {/* Backend & Deployment Status */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-sm space-y-3">
          <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
            <Server className="w-4 h-4 text-brand-green" /> सूपरबेस बॅकएंड माहिती
          </h3>
          <div className="space-y-1.5 text-xs text-slate-600">
            <p><strong>प्रकल्प (Project):</strong> Nardana Connect (zrnukpkufwrexrvysmpw)</p>
            <p><strong>डेटाबेस:</strong> Supabase PostgreSQL (18 Tables)</p>
            <p><strong>FCM पुश नोटिफिकेशन्स:</strong> village-seva-2026</p>
            <p><strong>साठवणूक:</strong> business-photos, notice-attachments, advertisements</p>
          </div>
        </div>

        <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-sm space-y-3">
          <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
            <Smartphone className="w-4 h-4 text-brand-blue" /> ॲप वितरण माहिती
          </h3>
          <div className="space-y-1.5 text-xs text-slate-600">
            <p><strong>मोबाईल ॲप:</strong> Nardana Connect Android v1.0.0</p>
            <p><strong>पॅकेज नाव:</strong> in.nardana.connect.nardana_connect</p>
            <p><strong>पब्लिश स्थिती:</strong> GitHub Release APK Hosted</p>
            <div className="pt-1">
              <a
                href="https://nardana-connect.vercel.app/download.html"
                target="_blank"
                rel="noreferrer"
                className="text-brand-blue font-semibold hover:underline inline-flex items-center gap-1"
              >
                डाऊनलोड पोर्टल पहा <ExternalLink className="w-3 h-3" />
              </a>
            </div>
          </div>
        </div>
      </div>

      {/* Add Emergency Contact Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-sm w-full shadow-2xl border border-slate-200 p-6 space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <h3 className="font-bold text-sm text-slate-900 flex items-center gap-2">
                <PhoneCall className="w-4 h-4 text-rose-600" /> नवीन हेल्पलाइन जोडा
              </h3>
              <button onClick={() => setIsModalOpen(false)} className="text-slate-400 hover:text-slate-600 p-1">
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleAddContact} className="space-y-3 text-xs">
              <div>
                <label className="block font-semibold text-slate-700 mb-1">नाव (मराठीत) *</label>
                <input
                  type="text"
                  required
                  placeholder="उदा. प्राथमिक आरोग्य केंद्र, नरडाणा"
                  value={nameMr}
                  onChange={(e) => setNameMr(e.target.value)}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">नाव (English)</label>
                <input
                  type="text"
                  placeholder="e.g. Primary Health Center"
                  value={nameEn}
                  onChange={(e) => setNameEn(e.target.value)}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">फोन नंबर *</label>
                <input
                  type="tel"
                  required
                  placeholder="उदा. 02566-224422 किंवा 108"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs font-mono"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">प्रवर्ग</label>
                <select
                  value={category}
                  onChange={(e) => setCategory(e.target.value)}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:border-brand-blue text-xs bg-white"
                >
                  <option value="आरोग्य व रुग्णवाहिका">आरोग्य व रुग्णवाहिका</option>
                  <option value="पोलीस व सुरक्षा">पोलीस व सुरक्षा</option>
                  <option value="महावितरण (वीज)">महावितरण (वीज)</option>
                  <option value="ग्रामपंचायत">ग्रामपंचायत</option>
                  <option value="अग्निशामक व इतर">अग्निशामक व इतर</option>
                </select>
              </div>

              <div className="flex justify-end gap-2 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-3.5 py-1.5 border border-slate-200 text-slate-600 rounded-lg hover:bg-slate-50"
                >
                  रद्द करा
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className="px-3.5 py-1.5 bg-rose-600 text-white rounded-lg hover:bg-rose-700 font-semibold disabled:opacity-50"
                >
                  {submitting ? 'जतन करत आहे...' : 'जोडा'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
