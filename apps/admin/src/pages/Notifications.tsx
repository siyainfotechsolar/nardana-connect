import React, { useState } from 'react';
import { Send, Trash2 } from 'lucide-react';
import { useToast } from '../components/Toast';
import { AdminPageHeader } from '../components/AdminPageHeader';

interface NotificationLog {
  id: string;
  title_mr: string;
  body_mr: string;
  type: 'water' | 'electricity' | 'announcement' | 'emergency';
  sent_at: string;
  recipient_count: number;
}

const INITIAL_LOGS: NotificationLog[] = [
  {
    id: 'notif-1',
    title_mr: 'पाणी पुरवठा वेळापत्रक बदल',
    body_mr: 'उद्या सकाळी ७:०० ते ९:०० दरम्यान मेन बाजारपेठ भागात पाणीपुरवठा केला जाईल.',
    type: 'water',
    sent_at: '2026-11-10T17:00:00Z',
    recipient_count: 850,
  },
  {
    id: 'notif-2',
    title_mr: 'ग्रामसभा बैठक सूचना',
    body_mr: 'येत्या रविवारी सकाळी ११:०० वाजता ग्रामपंचायत प्रांगणात विशेष ग्रामसभेचे आयोजन.',
    type: 'announcement',
    sent_at: '2026-11-09T10:00:00Z',
    recipient_count: 1200,
  },
  {
    id: 'notif-3',
    title_mr: 'शेतीपंपासाठी थ्री-फेज वीज वेळ',
    body_mr: 'आज रात्री १२:०० ते सकाळी ८:०० दरम्यान शेतीपंपासाठी पूर्ण दाबाने वीज पुरवठा राहील.',
    type: 'electricity',
    sent_at: '2026-11-08T18:30:00Z',
    recipient_count: 620,
  },
];

export const Notifications: React.FC = () => {
  const [logs, setLogs] = useState<NotificationLog[]>(INITIAL_LOGS);
  const [titleMr, setTitleMr] = useState('');
  const [bodyMr, setBodyMr] = useState('');
  const [type, setType] = useState<NotificationLog['type']>('announcement');
  const [isSending, setIsSending] = useState(false);
  const { showToast } = useToast();

  const handleSendNotification = (e: React.FormEvent) => {
    e.preventDefault();
    if (!titleMr.trim() || !bodyMr.trim()) {
      showToast('शीर्षक आणि संदेश आवश्यक आहे.', 'error');
      return;
    }

    setIsSending(true);
    setTimeout(() => {
      const newLog: NotificationLog = {
        id: `notif-${Date.now()}`,
        title_mr: titleMr.trim(),
        body_mr: bodyMr.trim(),
        type: type,
        sent_at: new Date().toISOString(),
        recipient_count: 1450,
      };

      setLogs([newLog, ...logs]);
      setIsSending(false);
      showToast('पुश नोटिफिकेशन सर्व नरडाणा ग्रामस्थांना यशस्वीरीत्या पाठवले!', 'success');
      setTitleMr('');
      setBodyMr('');
    }, 800);
  };

  const handleDelete = (id: string) => {
    setLogs((prev) => prev.filter((l) => l.id !== id));
    showToast('नोंद हटवली.', 'success');
  };

  return (
    <div className="space-y-6">
      <AdminPageHeader
        title="पुश नोटिफिकेशन्स व्यवस्थापन (Push Notifications)"
        subtitle="नरडाणा ग्रामस्थांना पाणी, वीज आणि आपत्कालीन सूचनांचे थेट संदेश पाठवा"
      />

      {/* Composer Card */}
      <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-sm space-y-4">
        <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
          <Send className="w-4 h-4 text-brand-blue" />
          <span>नवीन अलर्ट / संदेश तयार करा (Broadcast Message)</span>
        </h3>

        <form onSubmit={handleSendNotification} className="space-y-3 text-xs">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            <div className="sm:col-span-2">
              <label className="block font-semibold mb-1">संदेश शीर्षक (Notification Title) *</label>
              <input
                type="text"
                required
                placeholder="उदा. पाणी पुरवठा दुरुस्ती सूचना"
                value={titleMr}
                onChange={(e) => setTitleMr(e.target.value)}
                className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-brand-blue"
              />
            </div>
            <div>
              <label className="block font-semibold mb-1">अलर्ट प्रकार (Category) *</label>
              <select
                value={type}
                onChange={(e) => setType(e.target.value as any)}
                className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-brand-blue bg-white"
              >
                <option value="announcement">ग्रामपंचायत घोषणा</option>
                <option value="water">पाणी पुरवठा अलर्ट</option>
                <option value="electricity">वीज पुरवठा अलर्ट</option>
                <option value="emergency">तातडीचा आपत्कालीन संदेश</option>
              </select>
            </div>
          </div>

          <div>
            <label className="block font-semibold mb-1">संदेश तपशील (Message Body) *</label>
            <textarea
              required
              rows={3}
              placeholder="ग्रामस्थांसाठीचा सविस्तर संदेश येथे लिहा..."
              value={bodyMr}
              onChange={(e) => setBodyMr(e.target.value)}
              className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:border-brand-blue"
            />
          </div>

          <div className="flex items-center justify-between pt-2">
            <p className="text-[11px] text-slate-500">
              लक्ष्य: <strong>केवळ नरडाणा गाव (४२५४०४)</strong> मधील सर्व नागरिक.
            </p>
            <button
              type="submit"
              disabled={isSending}
              className="px-5 py-2 bg-brand-blue text-white rounded-lg hover:bg-blue-700 font-semibold disabled:opacity-50 inline-flex items-center gap-1.5"
            >
              <Send className="w-3.5 h-3.5" />
              <span>{isSending ? 'पाठवत आहे...' : 'सर्व ग्रामस्थांना पाठवा (Broadcast)'}</span>
            </button>
          </div>
        </form>
      </div>

      {/* History Table */}
      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <div className="px-5 py-3 bg-slate-50 border-b flex items-center justify-between">
          <h4 className="font-bold text-xs text-slate-800">पाठवलेल्या नोटिफिकेशन्सचा इतिहास</h4>
          <span className="text-[11px] text-slate-500">एकूण: {logs.length}</span>
        </div>
        <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
          <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
            <tr>
              <th className="px-5 py-3">शीर्षक</th>
              <th className="px-5 py-3">प्रकार</th>
              <th className="px-5 py-3">संदेश मजकूर</th>
              <th className="px-5 py-3">प्राप्तकर्ते</th>
              <th className="px-5 py-3">पाठवण्याची वेळ</th>
              <th className="px-5 py-3 text-right">हटवा</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {logs.map((l) => (
              <tr key={l.id} className="hover:bg-slate-50/70">
                <td className="px-5 py-3.5 font-bold text-slate-800">{l.title_mr}</td>
                <td className="px-5 py-3.5">
                  <span
                    className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                      l.type === 'water'
                        ? 'bg-blue-100 text-blue-800'
                        : l.type === 'electricity'
                        ? 'bg-amber-100 text-amber-800'
                        : l.type === 'emergency'
                        ? 'bg-rose-100 text-rose-800'
                        : 'bg-emerald-100 text-emerald-800'
                    }`}
                  >
                    {l.type === 'water'
                      ? 'पाणी'
                      : l.type === 'electricity'
                      ? 'वीज'
                      : l.type === 'emergency'
                      ? 'आपत्कालीन'
                      : 'घोषणा'}
                  </span>
                </td>
                <td className="px-5 py-3.5 text-slate-600 max-w-sm">{l.body_mr}</td>
                <td className="px-5 py-3.5 font-mono text-slate-700 font-semibold">
                  {l.recipient_count} नागरिक
                </td>
                <td className="px-5 py-3.5 text-slate-400">
                  {new Date(l.sent_at).toLocaleString('mr-IN')}
                </td>
                <td className="px-5 py-3.5 text-right">
                  <button
                    onClick={() => handleDelete(l.id)}
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
    </div>
  );
};

