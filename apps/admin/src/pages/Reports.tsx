import React, { useState } from 'react';
import { 
  FileText, 
  Download, 
  Eye, 
  ArrowLeft, 
  BarChart3, 
  Users, 
  Store, 
  Briefcase, 
  ShoppingBag, 
  Megaphone, 
  Bell,
  Printer
} from 'lucide-react';
import { useToast } from '../components/Toast';
import { AdminPageHeader } from '../components/AdminPageHeader';

interface ReportCategory {
  id: string;
  titleMr: string;
  titleEn: string;
  icon: React.ComponentType<{ className?: string }>;
  statSummary: string;
  description: string;
  period: string;
  metrics: { label: string; value: string; change: string }[];
  details: { key: string; val: string }[];
}

const REPORT_CATEGORIES: ReportCategory[] = [
  {
    id: 'rep-biz',
    titleMr: 'स्थानिक व्यवसाय व सेवा अहवाल',
    titleEn: 'Business Directory & Categories Report',
    icon: Store,
    statSummary: '४८ नोंदणीकृत दुकाने व व्यावसायिक',
    description: 'नरडाणा गावातील सर्व सक्रिय दुकाने, तंत्रज्ञ व शेती सेवांचे प्रवर्गनिहाय विश्लेषण.',
    period: 'मासिक (Monthly) • नोव्हेंबर २०२६',
    metrics: [
      { label: 'एकूण दुकाने', value: '४८', change: '+१२% या महिन्यात' },
      { label: 'सक्रिय कॅटेगरीज', value: '१०', change: '१००% पूर्ण' },
      { label: 'नागरिक कॉल संपर्क', value: '३८२', change: '+२८%' },
    ],
    details: [
      { key: 'सर्वाधिक संपर्क झालेली कॅटेगरी', val: 'इलेक्ट्रिशियन व शेती पंप सेवा (१४२ कॉल)' },
      { key: 'दुसऱ्या क्रमांकाची कॅटेगरी', val: 'किराणा व दैनंदिन गरजा (९८ कॉल)' },
      { key: 'सरासरी प्रतिसाद वेळ', val: '१५ मिनिटे' },
      { key: 'नरडाणा बाजारपेठ कव्हरेज', val: '१००% केवळ नरडाणा गाव' },
    ],
  },
  {
    id: 'rep-jobs',
    titleMr: 'रोजगार व नोकरी संधी अहवाल',
    titleEn: 'Employment & Youth Opportunities Report',
    icon: Briefcase,
    statSummary: '१६ उपलब्ध नोकऱ्या • २८ अर्जदार',
    description: 'स्थानिक तरुणांना गावातच रोजगार मिळण्याच्या संधी आणि अर्जांचे विश्लेषण.',
    period: 'मासिक (Monthly) • नोव्हेंबर २०२६',
    metrics: [
      { label: 'सक्रिय नोकरी जाहिराती', value: '१६', change: '+४ नवीन' },
      { label: 'स्थानिक उमेदवारांचे अर्ज', value: '२८', change: '+१५%' },
      { label: 'यशस्वी मुलाखती', value: '९', change: '+३३%' },
    ],
    details: [
      { key: 'सर्वाधिक मागणी असलेले पद', val: 'दुकान सहाय्यक / सेल्समन' },
      { key: 'सरासरी पगार श्रेणी', val: '₹८,००० ते ₹१५,०००' },
      { key: 'स्थानिक कंपन्या / दुकाने', val: '१२ मालक' },
      { key: 'पात्रता निकष', val: '१० वी / १२ वी उत्तीर्ण' },
    ],
  },
  {
    id: 'rep-mkt',
    titleMr: 'खरेदी - विक्री बाजारपेठ अहवाल',
    titleEn: 'Buy & Sell Marketplace Trade Report',
    icon: ShoppingBag,
    statSummary: '३२ सक्रिय वस्तू • ₹२.४ लाख व्यवहार मूल्य',
    description: 'स्थानिक नागरिकांच्या थेट खरेदी-विक्री वस्तू आणि दलालीमुक्त व्यापाराचा अहवाल.',
    period: 'मासिक (Monthly) • नोव्हेंबर २०२६',
    metrics: [
      { label: 'नोंदणीकृत वस्तू', value: '३२', change: '+६ या आठवड्यात' },
      { label: 'थेट संपर्क झाले', value: '१२०+', change: '+१८%' },
      { label: 'दलालीमुक्त बचत', value: '₹१४,०००+', change: 'शेतकऱ्यांना थेट लाभ' },
    ],
    details: [
      { key: 'सर्वाधिक विक्री झालेला प्रवर्ग', val: 'शेती अवजारे व ट्रॅक्टर उपकरणे' },
      { key: 'दुसरा लोकप्रिय प्रवर्ग', val: 'घरगुती फर्निचर व इलेक्ट्रॉनिक्स' },
      { key: 'सरासरी विक्री वेळ', val: '४ दिवस' },
      { key: 'व्यापार क्षेत्र मर्यादा', val: 'केवळ नरडाणा गाव सीमा' },
    ],
  },
  {
    id: 'rep-notices',
    titleMr: 'ग्रामपंचायत सूचना पोहोच अहवाल',
    titleEn: 'Gram Panchayat Announcements Reach Report',
    icon: Bell,
    statSummary: '२४ अधिकृत सूचना • १,४५० नागरिक वाचक',
    description: 'ग्रामपंचायत नरडाणा, पाणी पुरवठा आणि महावितरण सूचनांचा गावकऱ्यांपर्यंतचा पोहोच.',
    period: 'मासिक (Monthly) • नोव्हेंबर २०२६',
    metrics: [
      { label: 'प्रसिद्ध सूचना', value: '२४', change: '१००% अधिकृत' },
      { label: 'एकूण व्ह्यूज (Views)', value: '४,२८०', change: '+४५%' },
      { label: 'व्हॉट्सॲप शेअर्स', value: '६१०', change: '+६०%' },
    ],
    details: [
      { key: 'सर्वाधिक वाचलेली सूचना', val: 'पाणी पुरवठा पाईपलाईन दुरुस्ती व वेळ बदल' },
      { key: 'तात्काळ आपत्कालीन सूचना', val: '१ (महावितरण वीज दुरुस्ती)' },
      { key: 'PDF डाऊनलोड्स संख्या', val: '३४२ डाऊनलोड्स' },
      { key: 'प्राधिकरण संपर्क कॉल', val: '८४ कॉल' },
    ],
  },
  {
    id: 'rep-ads',
    titleMr: 'जाहिरात प्रभाव व क्लिक अहवाल',
    titleEn: 'Advertisement Impressions & CTR Report',
    icon: Megaphone,
    statSummary: '२४,५०० इम्प्रेशन्स • ९८० क्लिक्स (४.०% CTR)',
    description: 'स्थानिक नरडाणा दुकानदारांच्या प्रायोजित बॅनर आणि कॅरोसेल जाहिरातींची आकडेवारी.',
    period: 'मासिक (Monthly) • नोव्हेंबर २०२६',
    metrics: [
      { label: 'एकूण इम्प्रेशन्स', value: '२४.५K', change: '+२२%' },
      { label: 'थेट क्लिक्स', value: '९८०', change: '+१९%' },
      { label: 'क्लिक दर (CTR)', value: '४.०%', change: 'उत्कृष्ट प्रभाव' },
    ],
    details: [
      { key: 'सर्वोत्कृष्ट जाहिरात', val: 'महाजन किराणा सुपर सेल' },
      { key: 'सर्वाधिक क्लिक प्लेसमेंट', val: 'होम कॅरोसेल (Home Carousel)' },
      { key: 'थेट फोन कॉल सुरू झाले', val: '३१० कॉल' },
      { key: 'व्हॉट्सॲप लीड्स निर्माण झाल्या', val: '४२० मेसेज' },
    ],
  },
  {
    id: 'rep-users',
    titleMr: 'नागरिक नोंदणी व सहभाग अहवाल',
    titleEn: 'Citizen Registrations & Engagement Report',
    icon: Users,
    statSummary: '१,८५० नोंदणीकृत नागरिक • ९२% सक्रिय',
    description: 'नरडाणा गावातील कुटुंब व नागरिक डिजिटल सहभागाची सर्वसमावेशक माहिती.',
    period: 'वार्षिक (Yearly) • २०२६',
    metrics: [
      { label: 'नोंदणीकृत गावकरी', value: '१,८५०', change: '+४८० यंदा' },
      { label: 'दैनिक सक्रिय वापरकर्ते', value: '४२०', change: '+३५%' },
      { label: 'वॉर्डनिहाय कव्हरेज', value: '५/५ वॉर्ड', change: '१००% गाव समाविष्ट' },
    ],
    details: [
      { key: 'सर्वाधिक नागरिक असलेला वॉर्ड', val: 'वॉर्ड २ (मेन बाजारपेठ परिसर)' },
      { key: 'मोबाइल ॲप इन्स्टॉलेशन्स', val: '१,४२० Android डिव्हाइसेस' },
      { key: 'सक्रिय मराठी भाषा प्रमाण', val: '८८% वापरकर्ते मराठी' },
      { key: 'भौगोलिक मर्यादा पडताळणी', val: '१००% नरडाणा गावकरी' },
    ],
  },
];

export const Reports: React.FC = () => {
  const { showToast } = useToast();
  const [selectedReport, setSelectedReport] = useState<ReportCategory | null>(null);

  const handleExportCSV = (report: ReportCategory) => {
    const csvContent =
      'data:text/csv;charset=utf-8,' +
      `अहवाल,${report.titleMr}\n` +
      `इंग्रजी नाव,${report.titleEn}\n` +
      `कालावधी,${report.period}\n\n` +
      'मेट्रिक,मूल्य,बदल\n' +
      report.metrics.map((m) => `"${m.label}","${m.value}","${m.change}"`).join('\n') +
      '\n\nतपशील,माहिती\n' +
      report.details.map((d) => `"${d.key}","${d.val}"`).join('\n');

    const encodedUri = encodeURI(csvContent);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    link.setAttribute('download', `Nardana_${report.id}_Report.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    showToast(`'${report.titleMr}' CSV अहवाल यशस्वीरीत्या डाऊनलोड झाला!`, 'success');
  };

  const handlePrint = () => {
    window.print();
  };

  return (
    <div className="space-y-6">
      <AdminPageHeader
        title="ग्राम अहवाल व आकडेवारी"
        subtitle="Village Analytics & Progress Reports"
        icon={BarChart3}
        actions={
          <div className="flex items-center space-x-2">
            <button
              onClick={() => showToast('सर्व अहवालांचे एकत्रित मासिक संकलन डाऊनलोड केले जात आहे...', 'info')}
              className="flex items-center space-x-2 px-4 py-2.5 rounded-xl border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 font-bold text-xs transition shadow-sm"
            >
              <Download className="w-4 h-4 text-slate-500" />
              <span>एकत्रित अहवाल डाऊनलोड</span>
            </button>
          </div>
        }
      />

      {/* Main Reports Grid or Detailed View */}
      {!selectedReport ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {REPORT_CATEGORIES.map((r) => {
            const Icon = r.icon;
            return (
              <div
                key={r.id}
                className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm hover:shadow-md transition flex flex-col justify-between"
              >
                <div className="space-y-3">
                  <div className="flex items-start justify-between">
                    <div className="p-3 bg-brand-blue/10 text-brand-blue rounded-xl">
                      <Icon className="w-6 h-6" />
                    </div>
                    <span className="text-[10px] font-bold text-slate-400 bg-slate-50 px-2 py-0.5 rounded-full border border-slate-200">
                      {r.period.split('•')[0]}
                    </span>
                  </div>

                  <div>
                    <h3 className="font-black text-slate-800 text-sm">{r.titleMr}</h3>
                    <p className="text-[11px] text-slate-400 font-semibold">{r.titleEn}</p>
                  </div>

                  <p className="text-xs font-bold text-brand-green bg-emerald-50 px-2.5 py-1 rounded-lg border border-emerald-200 inline-block">
                    {r.statSummary}
                  </p>

                  <p className="text-xs text-slate-500 line-clamp-2 leading-relaxed">
                    {r.description}
                  </p>
                </div>

                <div className="pt-4 mt-4 border-t border-slate-100 flex items-center justify-between">
                  <button
                    onClick={() => handleExportCSV(r)}
                    title="CSV डाऊनलोड करा"
                    className="p-2 rounded-xl text-slate-400 hover:text-brand-blue hover:bg-slate-50 transition border border-transparent hover:border-slate-200"
                  >
                    <Download className="w-4 h-4" />
                  </button>

                  <button
                    onClick={() => setSelectedReport(r)}
                    className="flex items-center space-x-1.5 px-3.5 py-1.5 bg-brand-blue hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition shadow-sm"
                  >
                    <Eye className="w-3.5 h-3.5" />
                    <span>सविस्तर अहवाल पहा</span>
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      ) : (
        /* Detailed Report View (Safe Back to Reports) */
        <div className="space-y-6 animate-in fade-in zoom-in-95 duration-150">
          {/* Detailed View Header */}
          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div className="flex items-center space-x-3">
              <button
                onClick={() => setSelectedReport(null)}
                title="अहवालांच्या मुख्य यादीवर परत जा (Back to Reports)"
                className="p-2.5 rounded-xl border border-slate-200 hover:bg-slate-100 text-slate-700 transition shadow-sm flex items-center justify-center"
              >
                <ArrowLeft className="w-4 h-4" />
              </button>
              <div>
                <h2 className="text-lg font-black text-slate-800 leading-tight">
                  {selectedReport.titleMr}
                </h2>
                <p className="text-xs text-slate-400 font-semibold">{selectedReport.titleEn} • {selectedReport.period}</p>
              </div>
            </div>

            <div className="flex items-center space-x-2.5">
              <button
                onClick={() => handleExportCSV(selectedReport)}
                className="flex items-center space-x-1.5 px-3.5 py-2 bg-emerald-50 hover:bg-emerald-100 text-emerald-800 border border-emerald-200 rounded-xl text-xs font-bold transition"
              >
                <Download className="w-3.5 h-3.5" />
                <span>CSV एक्सपोर्ट</span>
              </button>
              <button
                onClick={handlePrint}
                className="flex items-center space-x-1.5 px-3.5 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold transition"
              >
                <Printer className="w-3.5 h-3.5" />
                <span>प्रिंट करा</span>
              </button>
            </div>
          </div>

          {/* Metrics 3-Card Grid */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {selectedReport.metrics.map((m, idx) => (
              <div key={idx} className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm space-y-1">
                <span className="text-xs font-bold text-slate-500">{m.label}</span>
                <p className="text-2xl font-black text-brand-blue">{m.value}</p>
                <span className="inline-block text-[11px] font-bold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-md border border-emerald-200">
                  {m.change}
                </span>
              </div>
            ))}
          </div>

          {/* Details Table */}
          <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 space-y-4">
            <h3 className="text-sm font-bold text-slate-800 border-b border-slate-100 pb-3 flex items-center gap-2">
              <FileText className="w-4 h-4 text-brand-blue" />
              <span>सविस्तर विश्लेषण व कार्यक्षेत्र निरीक्षण (Detailed Analytics)</span>
            </h3>

            <div className="divide-y divide-slate-100 text-xs">
              {selectedReport.details.map((d, idx) => (
                <div key={idx} className="py-3 flex flex-col sm:flex-row sm:items-center justify-between gap-1">
                  <span className="font-semibold text-slate-600">{d.key}</span>
                  <span className="font-bold text-slate-900 bg-slate-50 px-3 py-1 rounded-lg border border-slate-200">
                    {d.val}
                  </span>
                </div>
              ))}
            </div>

            <div className="pt-4 border-t border-slate-100 flex items-center justify-between">
              <button
                onClick={() => setSelectedReport(null)}
                className="px-4 py-2 border border-slate-300 rounded-xl text-xs font-bold text-slate-700 hover:bg-slate-50 transition"
              >
                मागे जा (Back to Reports List)
              </button>

              <span className="text-[11px] text-slate-400 font-semibold">
                प्रमाणित: नरडाणा ग्रामपंचायत व स्थानिक डेटाबेसमधून थेट संकलित
              </span>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
