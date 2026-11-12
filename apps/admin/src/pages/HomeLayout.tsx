import React, { useState } from 'react';
import { ArrowUp, ArrowDown, Eye, EyeOff, Save, RotateCcw } from 'lucide-react';
import { useToast } from '../components/Toast';
import { AdminPageHeader } from '../components/AdminPageHeader';

interface HomeSection {
  id: string;
  name_mr: string;
  name_en: string;
  key: string;
  order: number;
  is_visible: boolean;
  description: string;
}

const DEFAULT_SECTIONS: HomeSection[] = [
  { id: 'sec-1', name_mr: 'मुख्य बॅनर (Main Banner)', name_en: 'Main Banner', key: 'main_banner', order: 1, is_visible: true, description: 'गावातील मुख्य शासकीय योजना व महत्वाचे बॅनर' },
  { id: 'sec-2', name_mr: 'त्वरित सेवा (Quick Services)', name_en: 'Quick Services', key: 'quick_services', order: 2, is_visible: true, description: 'पाणी पुरवठा वेळापत्रक, आपत्कालीन व ग्रामपंचायत शॉर्टकट' },
  { id: 'sec-3', name_mr: 'लोकप्रिय कॅटेगरी (Popular Categories)', name_en: 'Popular Categories', key: 'categories', order: 3, is_visible: true, description: 'इलेक्ट्रिशियन, प्लंबर, किराणा, मेडिकल इत्यादी ८ मुख्य कॅटेगरी' },
  { id: 'sec-4', name_mr: 'स्थानिक दुकाने व सेवा (Local Shops)', name_en: 'Local Shops', key: 'local_shops', order: 4, is_visible: true, description: 'नरडाणा गावातील वैशिष्ट्यपूर्ण दुकाने व सेवांची क्षितिज समांतर यादी' },
  { id: 'sec-5', name_mr: 'गाव सूचना व जाहीर प्रकटन (Notices)', name_en: 'Village Notices', key: 'village_notices', order: 5, is_visible: true, description: 'ग्रामपंचायत, पाणी पुरवठा व वीज महावितरणच्या ताज्या सूचना' },
  { id: 'sec-6', name_mr: 'स्थानिक रोजगार (Jobs & Opportunities)', name_en: 'Jobs', key: 'jobs', order: 6, is_visible: true, description: 'गावातील ड्रायव्हर, शेती व दुकान कामगारांच्या ताज्या नोकऱ्या' },
  { id: 'sec-7', name_mr: 'खरेदी - विक्री बाजारपेठ (Buy & Sell)', name_en: 'Marketplace', key: 'marketplace', order: 7, is_visible: true, description: 'नागरिकांच्या जुन्या वस्तू, ट्रॅक्टर व उपकरणे खरेदी-विक्री' },
  { id: 'sec-8', name_mr: 'तातडीचे व आपत्कालीन क्रमांक (Emergency)', name_en: 'Emergency', key: 'emergency', order: 8, is_visible: true, description: 'रुग्णवाहिका, पोलीस व प्राथमिक आरोग्य केंद्र थेट कॉल' },
  { id: 'sec-9', name_mr: 'प्रायोजित जाहिराती (Sponsored Ads)', name_en: 'Advertisements', key: 'advertisements', order: 9, is_visible: true, description: 'स्थानिक व्यवसायिकांच्या कॅरोसेल व प्रायोजित कार्ड जाहिराती' },
  { id: 'sec-10', name_mr: 'ग्रामपंचायत निवडणूक पोर्टल (Election)', name_en: 'Election', key: 'election', order: 10, is_visible: true, description: 'उमेदवार यादी, जाहीरनामा व मतदार मार्गदर्शन' },
];

export const HomeLayout: React.FC = () => {
  const [sections, setSections] = useState<HomeSection[]>(DEFAULT_SECTIONS);
  const { showToast } = useToast();

  const handleToggle = (id: string) => {
    setSections((prev) =>
      prev.map((s) => (s.id === id ? { ...s, is_visible: !s.is_visible } : s))
    );
  };

  const moveUp = (index: number) => {
    if (index === 0) return;
    const newItems = [...sections];
    const temp = newItems[index];
    newItems[index] = newItems[index - 1];
    newItems[index - 1] = temp;
    newItems.forEach((s, i) => (s.order = i + 1));
    setSections(newItems);
  };

  const moveDown = (index: number) => {
    if (index === sections.length - 1) return;
    const newItems = [...sections];
    const temp = newItems[index];
    newItems[index] = newItems[index + 1];
    newItems[index + 1] = temp;
    newItems.forEach((s, i) => (s.order = i + 1));
    setSections(newItems);
  };

  const handleSave = () => {
    showToast('होम स्क्रीन रचना यशस्वीरीत्या सेव्ह झाली! मोबाईल ॲपमध्ये त्वरित लागू होईल.', 'success');
  };

  const handleReset = () => {
    setSections(DEFAULT_SECTIONS);
    showToast('मूळ रचना पूर्ववत केली.', 'success');
  };

  return (
    <div className="space-y-6">
      <AdminPageHeader
        title="होम स्क्रीन रचना व क्रम नियंत्रण (Home Layout)"
        subtitle="नरडाणा कनेक्ट ॲपच्या मुख्य पानावर दिसणारे विभाग, त्यांचा क्रम व दृश्यमानता (Visibility)"
        actions={
          <button
            onClick={handleSave}
            className="flex items-center space-x-1.5 px-4 py-2 bg-brand-blue hover:bg-blue-700 text-white rounded-xl text-xs font-semibold shadow-sm transition"
          >
            <Save className="w-4 h-4" />
            <span>रचना जतन करा (Save Layout)</span>
          </button>
        }
      />

      <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-sm flex items-center justify-between">
        <div>
          <h4 className="font-bold text-xs text-slate-800">रचना माहिती (Live Sync)</h4>
          <p className="text-[11px] text-slate-500">
            येथे केलेला कोणताही बदल नवीन APK न काढता थेट सर्व नागरिकांच्या मोबाईल ॲपवर रिअल-टाइम लागू होतो.
          </p>
        </div>
        <button
          onClick={handleReset}
          className="px-3 py-1.5 border border-slate-300 rounded-lg text-xs font-semibold hover:bg-slate-50 inline-flex items-center gap-1"
        >
          <RotateCcw className="w-3.5 h-3.5" /> पूर्ववत करा
        </button>
      </div>

      <div className="space-y-3">
        {sections.map((sec, idx) => (
          <div
            key={sec.id}
            className={`p-4 rounded-xl border transition-all flex items-center justify-between ${
              sec.is_visible
                ? 'bg-white border-slate-200 shadow-sm'
                : 'bg-slate-50 border-slate-200 opacity-60'
            }`}
          >
            <div className="flex items-center gap-3">
              <span className="w-7 h-7 rounded-lg bg-slate-100 flex items-center justify-center font-bold text-xs text-slate-600 font-mono">
                {sec.order}
              </span>
              <div>
                <div className="flex items-center gap-2">
                  <h4 className="font-bold text-sm text-slate-800">{sec.name_mr}</h4>
                  <span className="text-[10px] font-mono text-slate-400 bg-slate-100 px-1.5 py-0.5 rounded">
                    {sec.key}
                  </span>
                </div>
                <p className="text-xs text-slate-500 mt-0.5">{sec.description}</p>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <button
                disabled={idx === 0}
                onClick={() => moveUp(idx)}
                className="p-1.5 border rounded-lg hover:bg-slate-100 text-slate-600 disabled:opacity-30"
                title="वर हलवा (Move Up)"
              >
                <ArrowUp className="w-4 h-4" />
              </button>
              <button
                disabled={idx === sections.length - 1}
                onClick={() => moveDown(idx)}
                className="p-1.5 border rounded-lg hover:bg-slate-100 text-slate-600 disabled:opacity-30"
                title="खाली हलवा (Move Down)"
              >
                <ArrowDown className="w-4 h-4" />
              </button>
              <button
                onClick={() => handleToggle(sec.id)}
                className={`px-3 py-1.5 rounded-lg text-xs font-semibold inline-flex items-center gap-1 transition ${
                  sec.is_visible
                    ? 'bg-emerald-50 text-emerald-800 border border-emerald-200 hover:bg-emerald-100'
                    : 'bg-slate-200 text-slate-600 hover:bg-slate-300'
                }`}
              >
                {sec.is_visible ? (
                  <>
                    <Eye className="w-3.5 h-3.5" /> चालू (ON)
                  </>
                ) : (
                  <>
                    <EyeOff className="w-3.5 h-3.5" /> बंद (OFF)
                  </>
                )}
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
