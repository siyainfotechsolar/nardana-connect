import React from 'react';
import { Shield, Server, Palette } from 'lucide-react';

export const Settings: React.FC = () => {
  return (
    <div className="space-y-6 max-w-4xl">
      <div>
        <h2 className="text-xl font-bold text-slate-900">प्लॅटफॉर्म सेटिंग्ज (Platform Settings)</h2>
        <p className="text-xs text-slate-500">नरडाणा कनेक्ट कम्युनिटी ॲप व डेटाबेस संरचना माहिती</p>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-sm space-y-4">
        <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
          <Palette className="w-4 h-4 text-brand-blue" /> अधिकृत ब्रँडिंग आणि रंगसंगती
        </h3>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 text-xs">
          <div className="p-3 rounded-lg border border-slate-200 bg-white">
            <div className="w-full h-8 rounded bg-[#123B67] mb-2"></div>
            <p className="font-bold">Deep Blue</p>
            <p className="text-slate-400 font-mono text-[11px]">#123B67 (Primary)</p>
          </div>
          <div className="p-3 rounded-lg border border-slate-200 bg-white">
            <div className="w-full h-8 rounded bg-[#16A36A] mb-2"></div>
            <p className="font-bold">Green</p>
            <p className="text-slate-400 font-mono text-[11px]">#16A36A (Secondary)</p>
          </div>
          <div className="p-3 rounded-lg border border-slate-200 bg-white">
            <div className="w-full h-8 rounded bg-[#F3B83F] mb-2"></div>
            <p className="font-bold">Golden Yellow</p>
            <p className="text-slate-400 font-mono text-[11px]">#F3B83F (Accent)</p>
          </div>
          <div className="p-3 rounded-lg border border-slate-200 bg-white">
            <div className="w-full h-8 rounded bg-white border border-slate-200 mb-2"></div>
            <p className="font-bold">White</p>
            <p className="text-slate-400 font-mono text-[11px]">#FFFFFF (Background)</p>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-sm space-y-3">
        <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
          <Server className="w-4 h-4 text-brand-green" /> सूपरबेस बॅकएंड माहिती
        </h3>
        <div className="space-y-2 text-xs text-slate-600">
          <p><strong>प्रकल्प (Project):</strong> Nardana Connect (zrnukpkufwrexrvysmpw)</p>
          <p><strong>डेटाबेस:</strong> Supabase PostgreSQL with RLS Enabled</p>
          <p><strong>प्रमाणीकरण (Auth):</strong> Supabase Mobile OTP / Email</p>
          <p><strong>साठवणूक (Storage):</strong> business-photos, marketplace-photos, notice-attachments</p>
        </div>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-sm space-y-3">
        <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
          <Shield className="w-4 h-4 text-amber-600" /> सुरक्षा आणि परवानगी तत्त्वे (RLS Policies)
        </h3>
        <p className="text-xs text-slate-600 leading-relaxed">
          सर्व डेटाबेस टेबल्सवर रो-लेव्हल सिक्युरिटी (RLS) सक्रिय करण्यात आलेली आहे. सामान्य नागरिक सार्वजनिक मंजूर माहिती लॉगिन नसतानाही पाहू शकतात, तर जाहिरात किंवा नोकरी पोस्ट करण्यासाठी मोबाइल पडताळणी आवश्यक आहे. व्यवस्थापक सर्व नोंदींना पडताळणीअंती मंजूर किंवा नाकारू शकतात.
        </p>
      </div>
    </div>
  );
};
