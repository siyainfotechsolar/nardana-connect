import React, { useState } from 'react';
import { 
  Vote, 
  Search, 
  Plus, 
  Eye, 
  Edit, 
  Trash2, 
  Phone, 
  ArrowLeft,
  X
} from 'lucide-react';
import { useToast } from '../components/Toast';
import { AdminPageHeader } from '../components/AdminPageHeader';

interface CandidateRecord {
  id: string;
  name: string;
  ward: string;
  symbol: string;
  education: string;
  age: number;
  phone: string;
  agenda: string;
  status: 'active' | 'withdrawn';
}

const INITIAL_CANDIDATES: CandidateRecord[] = [
  {
    id: 'cnd-01',
    name: 'दिलीप आनंदा पाटील',
    ward: 'प्रभाग क्र. १ (वॉर्ड १)',
    symbol: 'कमळ (Lotus)',
    education: 'बी.ए. (B.A.)',
    age: 46,
    phone: '9822011223',
    agenda: 'नरडाणा गावातील पाणी पुरवठा योजना नियमित करणे व नवीन सिमेंट रस्ते बांधणे.',
    status: 'active',
  },
  {
    id: 'cnd-02',
    name: 'अनिता सुनील चौधरी',
    ward: 'प्रभाग क्र. २ (वॉर्ड २)',
    symbol: 'शिट्टी (Whistle)',
    education: '१२ वी उत्तीर्ण',
    age: 38,
    phone: '9421556677',
    agenda: 'महिला बचत गटांना बळकटी देणे आणि प्राथमिक आरोग्य केंद्रात २४ तास रुग्णवाहिका सेवा सुरू करणे.',
    status: 'active',
  },
  {
    id: 'cnd-03',
    name: 'सुरेश काशिनाथ माळी',
    ward: 'प्रभाग क्र. ३ (वॉर्ड ३)',
    symbol: 'विमान (Aeroplane)',
    education: 'डी.एड. (D.Ed.)',
    age: 52,
    phone: '9890887766',
    agenda: 'गावातील सांडपाणी व्यवस्थापन, कचरा व्यवस्थापन व शेतकरी सेवा केंद्र सक्षम करणे.',
    status: 'active',
  },
];

export const Election: React.FC = () => {
  const { showToast } = useToast();
  const [candidates, setCandidates] = useState<CandidateRecord[]>(INITIAL_CANDIDATES);
  const [searchTerm, setSearchTerm] = useState('');
  const [wardFilter, setWardFilter] = useState('all');

  const [selectedCandidate, setSelectedCandidate] = useState<CandidateRecord | null>(null);
  const [editingCandidate, setEditingCandidate] = useState<CandidateRecord | null>(null);
  const [isAddOpen, setIsAddOpen] = useState(false);

  // Form Fields
  const [formName, setFormName] = useState('');
  const [formWard, setFormWard] = useState('प्रभाग क्र. १ (वॉर्ड १)');
  const [formSymbol, setFormSymbol] = useState('');
  const [formEducation, setFormEducation] = useState('');
  const [formAge, setFormAge] = useState(35);
  const [formPhone, setFormPhone] = useState('');
  const [formAgenda, setFormAgenda] = useState('');

  const isFormDirty = formName.trim().length > 0 || formPhone.trim().length > 0;

  const filtered = candidates.filter((c) => {
    const matchesSearch =
      c.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      c.symbol.toLowerCase().includes(searchTerm.toLowerCase()) ||
      c.phone.includes(searchTerm);
    const matchesWard = wardFilter === 'all' || c.ward === wardFilter;
    return matchesSearch && matchesWard;
  });

  const handleOpenAdd = () => {
    setFormName('');
    setFormWard('प्रभाग क्र. १ (वॉर्ड १)');
    setFormSymbol('');
    setFormEducation('');
    setFormAge(35);
    setFormPhone('');
    setFormAgenda('');
    setIsAddOpen(true);
  };

  const handleOpenEdit = (c: CandidateRecord) => {
    setEditingCandidate(c);
    setFormName(c.name);
    setFormWard(c.ward);
    setFormSymbol(c.symbol);
    setFormEducation(c.education);
    setFormAge(c.age);
    setFormPhone(c.phone);
    setFormAgenda(c.agenda);
  };

  const handleCloseForm = () => {
    if (isFormDirty) {
      if (!window.confirm('तुम्ही भरलेली माहिती अजून सेव्ह झालेली नाही. मागे जायचे आहे का?')) {
        return;
      }
    }
    setIsAddOpen(false);
    setEditingCandidate(null);
  };

  const handleSaveForm = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formName.trim() || !formSymbol.trim() || formPhone.trim().length !== 10) {
      showToast('कृपया नाव, चिन्ह आणि १० अंकी संपर्क नंबर भरा.', 'error');
      return;
    }

    if (editingCandidate) {
      setCandidates((prev) =>
        prev.map((c) =>
          c.id === editingCandidate.id
            ? {
                ...c,
                name: formName.trim(),
                ward: formWard,
                symbol: formSymbol.trim(),
                education: formEducation.trim(),
                age: Number(formAge),
                phone: formPhone.trim(),
                agenda: formAgenda.trim(),
              }
            : c
        )
      );
      showToast('उमेदवार माहिती यशस्वीरीत्या अपडेट केली!', 'success');
      setEditingCandidate(null);
    } else {
      const newCand: CandidateRecord = {
        id: 'cnd-' + (Date.now() % 10000),
        name: formName.trim(),
        ward: formWard,
        symbol: formSymbol.trim(),
        education: formEducation.trim() || 'माहिती नाही',
        age: Number(formAge) || 30,
        phone: formPhone.trim(),
        agenda: formAgenda.trim() || 'गावाचा सर्वांगीण विकास.',
        status: 'active',
      };
      setCandidates([newCand, ...candidates]);
      showToast('नवीन उमेदवार यशस्वीरीत्या जोडला!', 'success');
      setIsAddOpen(false);
    }
  };

  const handleDelete = (id: string, name: string) => {
    if (!window.confirm(`तुम्हाला '${name}' या उमेदवाराची नोंदणी हटवायची आहे का?`)) return;
    setCandidates((prev) => prev.filter((c) => c.id !== id));
    if (selectedCandidate?.id === id) setSelectedCandidate(null);
    showToast('उमेदवार यशस्वीरीत्या हटवला.', 'success');
  };

  return (
    <div className="space-y-6">
      <AdminPageHeader
        title="ग्रामपंचायत निवडणूक व उमेदवार निर्देशिका"
        subtitle="Gram Panchayat Elections & Candidates"
        icon={Vote}
        actions={
          <button
            onClick={handleOpenAdd}
            className="flex items-center space-x-2 px-4 py-2.5 rounded-xl bg-brand-blue hover:bg-blue-700 text-white font-bold text-xs transition shadow-sm"
          >
            <Plus className="w-4 h-4" />
            <span>नवीन उमेदवार जोडा</span>
          </button>
        }
      />

      {/* Filter and Search */}
      <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-sm flex flex-col md:flex-row gap-3 items-center justify-between">
        <div className="relative w-full md:w-80">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-3" />
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="उमेदवार नाव, चिन्ह किंवा फोन शोधा..."
            className="w-full pl-10 pr-4 py-2 rounded-xl border border-slate-200 text-xs text-slate-800 focus:outline-none focus:border-brand-blue"
          />
        </div>

        <div className="flex items-center space-x-2 w-full md:w-auto">
          <span className="text-xs text-slate-500 font-bold">प्रभाग (Ward):</span>
          <select
            value={wardFilter}
            onChange={(e) => setWardFilter(e.target.value)}
            className="px-3 py-1.5 rounded-xl border border-slate-200 text-xs font-semibold text-slate-700 focus:outline-none focus:border-brand-blue bg-white"
          >
            <option value="all">सर्व प्रभाग (All Wards)</option>
            <option value="प्रभाग क्र. १ (वॉर्ड १)">प्रभाग क्र. १ (वॉर्ड १)</option>
            <option value="प्रभाग क्र. २ (वॉर्ड २)">प्रभाग क्र. २ (वॉर्ड २)</option>
            <option value="प्रभाग क्र. ३ (वॉर्ड ३)">प्रभाग क्र. ३ (वॉर्ड ३)</option>
            <option value="प्रभाग क्र. ४ (वॉर्ड ४)">प्रभाग क्र. ४ (वॉर्ड ४)</option>
          </select>
        </div>
      </div>

      {/* Candidates List Table */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50 text-slate-600 font-bold border-b border-slate-200 select-none">
              <tr>
                <th className="py-3 px-4">उमेदवार नाव</th>
                <th className="py-3 px-4">प्रभाग (Ward)</th>
                <th className="py-3 px-4">निवडणूक चिन्ह</th>
                <th className="py-3 px-4">शिक्षण व वय</th>
                <th className="py-3 px-4">मोबाईल संपर्क</th>
                <th className="py-3 px-4">स्थिती</th>
                <th className="py-3 px-4 text-right">कृती (Actions)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={7} className="py-8 text-center text-slate-400">
                    कोणतेही उमेदवार सापडले नाहीत.
                  </td>
                </tr>
              ) : (
                filtered.map((c) => (
                  <tr key={c.id} className="hover:bg-slate-50 transition">
                    <td className="py-3 px-4 font-bold text-slate-800">
                      <div className="flex items-center space-x-2">
                        <div className="w-7 h-7 rounded-full bg-brand-blue/10 text-brand-blue font-bold flex items-center justify-center text-[11px]">
                          {c.name.slice(0, 1)}
                        </div>
                        <span>{c.name}</span>
                      </div>
                    </td>
                    <td className="py-3 px-4 font-semibold text-brand-blue">{c.ward}</td>
                    <td className="py-3 px-4 font-bold text-amber-800 bg-amber-50/50 rounded-lg px-2 py-1">
                      {c.symbol}
                    </td>
                    <td className="py-3 px-4 text-slate-600">
                      {c.education} ({c.age} वर्षे)
                    </td>
                    <td className="py-3 px-4 font-mono text-slate-600">{c.phone}</td>
                    <td className="py-3 px-4">
                      <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                        सक्रिय उमेदवार
                      </span>
                    </td>
                    <td className="py-3 px-4 text-right">
                      <div className="flex items-center justify-end space-x-2">
                        <button
                          onClick={() => setSelectedCandidate(c)}
                          title="तपशील पहा (View Details)"
                          className="p-1.5 rounded-lg border border-slate-200 hover:bg-slate-100 text-brand-blue transition"
                        >
                          <Eye className="w-3.5 h-3.5" />
                        </button>
                        <button
                          onClick={() => handleOpenEdit(c)}
                          title="माहिती संपादित करा (Edit)"
                          className="p-1.5 rounded-lg border border-slate-200 hover:bg-slate-100 text-slate-700 transition"
                        >
                          <Edit className="w-3.5 h-3.5" />
                        </button>
                        <button
                          onClick={() => handleDelete(c.id, c.name)}
                          title="हटवा (Delete)"
                          className="p-1.5 rounded-lg border border-red-200 hover:bg-red-50 text-red-600 transition"
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Candidate Details Modal (Safe Back to Candidates) */}
      {selectedCandidate && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl max-w-lg w-full p-6 shadow-2xl border border-slate-100 space-y-5 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center space-x-3">
                <button
                  onClick={() => setSelectedCandidate(null)}
                  title="उमेदवारांच्या यादीवर परत जा"
                  className="p-2 rounded-xl border border-slate-200 hover:bg-slate-100 text-slate-600 transition"
                >
                  <ArrowLeft className="w-4 h-4" />
                </button>
                <div>
                  <h3 className="text-base font-black text-slate-800 leading-tight">उमेदवार तपशील (Candidate Details)</h3>
                  <p className="text-[11px] text-slate-400">ID: {selectedCandidate.id}</p>
                </div>
              </div>
              <button
                onClick={() => setSelectedCandidate(null)}
                className="p-1.5 rounded-xl text-slate-400 hover:text-slate-600 hover:bg-slate-100"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-4">
              <div className="bg-slate-50 p-4 rounded-2xl border border-slate-200 flex items-center space-x-4">
                <div className="w-14 h-14 rounded-2xl bg-brand-blue text-white flex items-center justify-center text-xl font-black shadow-md">
                  {selectedCandidate.name.slice(0, 1)}
                </div>
                <div>
                  <h4 className="font-bold text-slate-800 text-sm">{selectedCandidate.name}</h4>
                  <p className="text-xs text-brand-blue font-bold mt-0.5">{selectedCandidate.ward}</p>
                  <p className="text-xs text-slate-500 flex items-center gap-1 mt-0.5">
                    <Phone className="w-3 h-3 text-brand-green" /> {selectedCandidate.phone}
                  </p>
                </div>
              </div>

              <div className="bg-amber-50 p-3 rounded-xl border border-amber-200 flex items-center justify-between text-xs">
                <span className="font-bold text-amber-900">निवडणूक चिन्ह:</span>
                <span className="font-black text-amber-900 bg-white px-3 py-1 rounded-lg border border-amber-300">
                  {selectedCandidate.symbol}
                </span>
              </div>

              <div className="bg-slate-50 p-3.5 rounded-xl border border-slate-200 space-y-2 text-xs">
                <div className="flex justify-between">
                  <span className="text-slate-500">शिक्षण:</span>
                  <span className="font-semibold text-slate-800">{selectedCandidate.education}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">वय:</span>
                  <span className="font-semibold text-slate-800">{selectedCandidate.age} वर्षे</span>
                </div>
                <div className="pt-2 border-t border-slate-200">
                  <p className="font-bold text-slate-700 mb-1">उमेदवाराचा जाहीरनामा / उद्दिष्टे:</p>
                  <p className="text-slate-600 leading-relaxed">{selectedCandidate.agenda}</p>
                </div>
              </div>
            </div>

            <div className="flex items-center justify-between pt-2 border-t border-slate-100">
              <button
                onClick={() => setSelectedCandidate(null)}
                className="px-4 py-2 border border-slate-300 rounded-xl text-xs font-bold text-slate-700 hover:bg-slate-50 transition"
              >
                मागे जा (Back to Candidates)
              </button>
              <button
                onClick={() => {
                  const c = selectedCandidate;
                  setSelectedCandidate(null);
                  handleOpenEdit(c);
                }}
                className="px-4 py-2 bg-brand-blue hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition shadow-sm flex items-center gap-1.5"
              >
                <Edit className="w-3.5 h-3.5" />
                <span>संपादित करा (Edit Candidate)</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Add / Edit Candidate Modal */}
      {(isAddOpen || editingCandidate) && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-100 space-y-4 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center space-x-2">
                <button
                  type="button"
                  onClick={handleCloseForm}
                  className="p-1.5 rounded-lg border border-slate-200 hover:bg-slate-100 text-slate-600 transition"
                  title="मागे जा"
                >
                  <ArrowLeft className="w-4 h-4" />
                </button>
                <h3 className="text-base font-black text-slate-800">
                  {editingCandidate ? 'उमेदवार माहिती संपादित करा' : 'नवीन उमेदवार नोंदणी'}
                </h3>
              </div>
              <button
                type="button"
                onClick={handleCloseForm}
                className="p-1 rounded-lg text-slate-400 hover:text-slate-600"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleSaveForm} className="space-y-3">
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  उमेदवाराचे पूर्ण नाव *
                </label>
                <input
                  type="text"
                  value={formName}
                  onChange={(e) => setFormName(e.target.value)}
                  placeholder="उदा. रमेश भास्कर पाटील"
                  className="w-full px-3.5 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-brand-blue"
                  required
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    प्रभाग (Ward) *
                  </label>
                  <select
                    value={formWard}
                    onChange={(e) => setFormWard(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-brand-blue bg-white"
                  >
                    <option value="प्रभाग क्र. १ (वॉर्ड १)">प्रभाग क्र. १</option>
                    <option value="प्रभाग क्र. २ (वॉर्ड २)">प्रभाग क्र. २</option>
                    <option value="प्रभाग क्र. ३ (वॉर्ड ३)">प्रभाग क्र. ३</option>
                    <option value="प्रभाग क्र. ४ (वॉर्ड ४)">प्रभाग क्र. ४</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    निवडणूक चिन्ह *
                  </label>
                  <input
                    type="text"
                    value={formSymbol}
                    onChange={(e) => setFormSymbol(e.target.value)}
                    placeholder="उदा. कमळ / शिट्टी"
                    className="w-full px-3.5 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-brand-blue"
                    required
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    शिक्षण
                  </label>
                  <input
                    type="text"
                    value={formEducation}
                    onChange={(e) => setFormEducation(e.target.value)}
                    placeholder="उदा. १० वी / बी.ए."
                    className="w-full px-3.5 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-brand-blue"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    वय
                  </label>
                  <input
                    type="number"
                    value={formAge}
                    onChange={(e) => setFormAge(Number(e.target.value))}
                    className="w-full px-3.5 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-brand-blue"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  मोबाईल नंबर (१० अंकी) *
                </label>
                <input
                  type="tel"
                  maxLength={10}
                  value={formPhone}
                  onChange={(e) => setFormPhone(e.target.value)}
                  placeholder="98XXXXXXXX"
                  className="w-full px-3.5 py-2 rounded-xl border border-slate-200 text-xs font-mono font-semibold focus:outline-none focus:border-brand-blue"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  जाहीरनामा / उद्देश
                </label>
                <textarea
                  rows={2}
                  value={formAgenda}
                  onChange={(e) => setFormAgenda(e.target.value)}
                  placeholder="गावाच्या विकासासाठी प्राथमिक उद्दिष्टे..."
                  className="w-full px-3.5 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:border-brand-blue"
                />
              </div>

              <div className="flex items-center justify-between pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={handleCloseForm}
                  className="px-4 py-2 border border-slate-300 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-50 transition"
                >
                  रद्द करा (Cancel)
                </button>
                <button
                  type="submit"
                  className="px-5 py-2 bg-brand-blue hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition shadow-md"
                >
                  {editingCandidate ? 'बदल जतन करा' : 'उमेदवार जोडा'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
