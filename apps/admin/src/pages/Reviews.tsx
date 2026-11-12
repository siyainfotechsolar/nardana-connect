import React, { useState } from 'react';
import { Star, Search, CheckCircle, EyeOff, Trash2, Eye, X } from 'lucide-react';
import { useToast } from '../components/Toast';
import { AdminPageHeader } from '../components/AdminPageHeader';

interface Review {
  id: string;
  target_name: string;
  reviewer_name: string;
  rating: number;
  comment: string;
  created_at: string;
  status: 'approved' | 'pending' | 'hidden';
}

const INITIAL_REVIEWS: Review[] = [
  {
    id: 'rev-1',
    target_name: 'जय भवानी इलेक्ट्रिकल वर्क्स',
    reviewer_name: 'सचिन आनंदा पाटील',
    rating: 5,
    comment: 'शेतातील पंपाचे वायरिंग वेळेवर आणि योग्य दरात करून दिले. खूप चांगली सेवा!',
    created_at: '2026-11-09T14:00:00Z',
    status: 'approved',
  },
  {
    id: 'rev-2',
    target_name: 'महालक्ष्मी सुपर किराणा स्टोअर्स',
    reviewer_name: 'अनिता चौधरी',
    rating: 4,
    comment: 'किराणा चांगल्या दर्जाचा असतो व घरपोच सेवा देखील उपलब्ध आहे.',
    created_at: '2026-11-10T10:30:00Z',
    status: 'approved',
  },
  {
    id: 'rev-3',
    target_name: 'किसान ट्रॅक्टर सर्व्हिसेस',
    reviewer_name: 'दिनेश पाटील',
    rating: 5,
    comment: 'नांगरणीचे काम वेळेवर पूर्ण केले. चालक अतिशय हुशार आहे.',
    created_at: '2026-11-10T16:00:00Z',
    status: 'approved',
  },
  {
    id: 'rev-4',
    target_name: 'धनवंतरी मेडिकल स्टोअर्स',
    reviewer_name: 'कैलास माळी',
    rating: 5,
    comment: 'रात्रीच्या वेळी तातडीने औषध उपलब्ध करून दिले. धन्यवाद!',
    created_at: '2026-11-11T09:00:00Z',
    status: 'pending',
  },
];

export const Reviews: React.FC = () => {
  const [reviews, setReviews] = useState<Review[]>(INITIAL_REVIEWS);
  const [viewingReview, setViewingReview] = useState<Review | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [ratingFilter, setRatingFilter] = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');
  const { showToast } = useToast();

  const filtered = reviews.filter((r) => {
    const matchesSearch =
      r.target_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      r.reviewer_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      r.comment.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesRating = ratingFilter === 'all' || r.rating.toString() === ratingFilter;
    const matchesStatus = statusFilter === 'all' || r.status === statusFilter;
    return matchesSearch && matchesRating && matchesStatus;
  });

  const handleUpdateStatus = (id: string, newStatus: Review['status']) => {
    setReviews((prev) => prev.map((r) => (r.id === id ? { ...r, status: newStatus } : r)));
    if (viewingReview && viewingReview.id === id) {
      setViewingReview((prev) => (prev ? { ...prev, status: newStatus } : null));
    }
    showToast(newStatus === 'approved' ? 'अभिप्राय मंजूर केला!' : 'अभिप्राय लपवला.', 'success');
  };

  const handleDelete = (id: string) => {
    if (!window.confirm('तुम्हाला हा अभिप्राय हटवायचा आहे का?')) return;
    setReviews((prev) => prev.filter((r) => r.id !== id));
    if (viewingReview && viewingReview.id === id) {
      setViewingReview(null);
    }
    showToast('अभिप्राय हटवला.', 'success');
  };

  return (
    <div className="space-y-6">
      <AdminPageHeader
        title="नागरिक अभिप्राय व रेटिंग (Reviews & Feedback)"
        subtitle="नरडाणा ॲपमधील दुकाने व सेवांबद्दल नागरिकांनी दिलेले अभिप्राय व नियंत्रण"
      />

      {/* Filter and Search Bar */}
      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col md:flex-row gap-3 items-center justify-between">
        <div className="relative w-full md:w-80">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
          <input
            type="text"
            placeholder="दुकान, नागरिक किंवा टिप्पणी शोधा..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-9 pr-4 py-2 border border-slate-200 rounded-lg text-xs focus:outline-none focus:border-brand-blue"
          />
        </div>

        <div className="flex items-center gap-2 w-full md:w-auto">
          <select
            value={ratingFilter}
            onChange={(e) => setRatingFilter(e.target.value)}
            className="px-3 py-2 border border-slate-200 rounded-lg text-xs bg-white focus:outline-none focus:border-brand-blue"
          >
            <option value="all">सर्व रेटिंग्ज</option>
            <option value="5">५ स्टार (⭐⭐⭐⭐⭐)</option>
            <option value="4">४ स्टार (⭐⭐⭐⭐)</option>
            <option value="3">३ स्टार (⭐⭐⭐)</option>
          </select>

          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="px-3 py-2 border border-slate-200 rounded-lg text-xs bg-white focus:outline-none focus:border-brand-blue"
          >
            <option value="all">सर्व स्थिती</option>
            <option value="approved">मंजूर (Approved)</option>
            <option value="pending">प्रलंबित (Pending)</option>
            <option value="hidden">लपवलेले (Hidden)</option>
          </select>
        </div>
      </div>

      {/* Reviews Table */}
      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <table className="min-w-full divide-y divide-slate-200 text-left text-xs">
          <thead className="bg-slate-50 text-slate-600 font-semibold uppercase">
            <tr>
              <th className="px-5 py-3">दुकान / व्यवसाय</th>
              <th className="px-5 py-3">नागरिक (Reviewer)</th>
              <th className="px-5 py-3">रेटिंग</th>
              <th className="px-5 py-3">टिप्पणी व अभिप्राय</th>
              <th className="px-5 py-3">तारीख</th>
              <th className="px-5 py-3">स्थिती</th>
              <th className="px-5 py-3 text-right">कृती</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {filtered.map((r) => (
              <tr 
                key={r.id} 
                onClick={() => setViewingReview(r)}
                className="hover:bg-blue-50/70 transition cursor-pointer group"
                title="सविस्तर अभिप्राय पाहण्यासाठी क्लिक करा"
              >
                <td className="px-5 py-3.5 font-bold text-slate-800 group-hover:text-brand-blue">
                  {r.target_name}
                </td>
                <td className="px-5 py-3.5 text-slate-700 font-medium">{r.reviewer_name}</td>
                <td className="px-5 py-3.5">
                  <div className="flex items-center gap-0.5 text-amber-500">
                    {Array.from({ length: 5 }).map((_, i) => (
                      <Star
                        key={i}
                        className={`w-3.5 h-3.5 ${i < r.rating ? 'fill-amber-400 text-amber-400' : 'text-slate-300'}`}
                      />
                    ))}
                    <span className="ml-1 text-slate-700 font-bold">{r.rating}.0</span>
                  </div>
                </td>
                <td className="px-5 py-3.5 text-slate-600 max-w-xs truncate">{r.comment}</td>
                <td className="px-5 py-3.5 text-slate-400 whitespace-nowrap">
                  {new Date(r.created_at).toLocaleDateString('mr-IN')}
                </td>
                <td className="px-5 py-3.5">
                  <span
                    className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                      r.status === 'approved'
                        ? 'bg-emerald-100 text-emerald-800'
                        : r.status === 'pending'
                        ? 'bg-amber-100 text-amber-800'
                        : 'bg-slate-100 text-slate-600'
                    }`}
                  >
                    {r.status === 'approved' ? 'प्रदर्शित' : r.status === 'pending' ? 'प्रलंबित' : 'लपवले'}
                  </span>
                </td>
                <td className="px-5 py-3.5 text-right space-x-1" onClick={(e) => e.stopPropagation()}>
                  <button
                    onClick={() => setViewingReview(r)}
                    className="p-1 hover:text-brand-blue text-slate-400"
                    title="तपशील पहा"
                  >
                    <Eye className="w-4 h-4" />
                  </button>
                  {r.status !== 'approved' && (
                    <button
                      onClick={() => handleUpdateStatus(r.id, 'approved')}
                      className="p-1 hover:text-emerald-600 text-slate-400"
                      title="मंजूर करा"
                    >
                      <CheckCircle className="w-4 h-4" />
                    </button>
                  )}
                  {r.status !== 'hidden' && (
                    <button
                      onClick={() => handleUpdateStatus(r.id, 'hidden')}
                      className="p-1 hover:text-amber-600 text-slate-400"
                      title="लपवा"
                    >
                      <EyeOff className="w-4 h-4" />
                    </button>
                  )}
                  <button
                    onClick={() => handleDelete(r.id)}
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

      {/* Review Details Modal */}
      {viewingReview && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white rounded-2xl max-w-lg w-full shadow-2xl overflow-hidden border border-slate-200">
            <div className="px-6 py-4 bg-slate-50 border-b border-slate-200 flex items-center justify-between">
              <div>
                <h3 className="font-bold text-base text-slate-900 leading-tight">
                  {viewingReview.target_name}
                </h3>
                <p className="text-xs text-slate-500">नागरिक अभिप्राय व मूल्यमापन तपशील</p>
              </div>
              <button
                onClick={() => setViewingReview(null)}
                className="text-slate-400 hover:text-slate-600 p-1.5 rounded-lg hover:bg-slate-200 transition"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="p-6 space-y-4 text-xs text-slate-700">
              <div className="flex items-center justify-between p-3.5 bg-amber-50/70 rounded-xl border border-amber-200">
                <div>
                  <span className="text-[11px] text-amber-800 font-semibold block">दिलेले रेटिंग</span>
                  <div className="flex items-center gap-1 mt-0.5">
                    {Array.from({ length: 5 }).map((_, i) => (
                      <Star
                        key={i}
                        className={`w-4 h-4 ${i < viewingReview.rating ? 'fill-amber-400 text-amber-400' : 'text-slate-300'}`}
                      />
                    ))}
                    <span className="ml-2 font-black text-amber-900 text-sm">{viewingReview.rating}.0 / 5.0</span>
                  </div>
                </div>
                <span
                  className={`px-3 py-1 rounded-full text-xs font-bold ${
                    viewingReview.status === 'approved'
                      ? 'bg-emerald-100 text-emerald-800'
                      : viewingReview.status === 'pending'
                      ? 'bg-amber-100 text-amber-800'
                      : 'bg-slate-100 text-slate-600'
                  }`}
                >
                  {viewingReview.status === 'approved' ? '✓ मंजूर (सार्वजनिक)' : viewingReview.status === 'pending' ? '⏳ प्रलंबित' : '🚫 लपवले'}
                </span>
              </div>

              <div className="space-y-2 bg-slate-50 p-4 rounded-xl border border-slate-200">
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="text-slate-500">नागरिकाचे नाव:</span>
                  <span className="font-bold text-slate-800">{viewingReview.reviewer_name}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-slate-200">
                  <span className="text-slate-500">तारीख:</span>
                  <span className="font-mono text-slate-700">
                    {new Date(viewingReview.created_at).toLocaleDateString('mr-IN', {
                      weekday: 'long',
                      year: 'numeric',
                      month: 'long',
                      day: 'numeric',
                    })}
                  </span>
                </div>
                <div className="flex justify-between py-1">
                  <span className="text-slate-500">कार्यक्षेत्र:</span>
                  <span className="font-bold text-brand-blue">नरडाणा गाव (४२५४०४)</span>
                </div>
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">अभिप्राय / टिप्पणी:</label>
                <div className="p-3 bg-white rounded-lg border border-slate-200 text-slate-800 text-xs leading-relaxed italic">
                  "{viewingReview.comment}"
                </div>
              </div>
            </div>

            <div className="px-6 py-3.5 bg-slate-50 border-t border-slate-200 flex items-center justify-between">
              <div className="flex items-center gap-2">
                {viewingReview.status !== 'approved' && (
                  <button
                    onClick={() => handleUpdateStatus(viewingReview.id, 'approved')}
                    className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-semibold inline-flex items-center gap-1 shadow-sm transition"
                  >
                    <CheckCircle className="w-3.5 h-3.5" /> मंजूर करा
                  </button>
                )}
                {viewingReview.status !== 'hidden' && (
                  <button
                    onClick={() => handleUpdateStatus(viewingReview.id, 'hidden')}
                    className="px-3 py-1.5 bg-amber-600 hover:bg-amber-700 text-white rounded-lg text-xs font-semibold inline-flex items-center gap-1 shadow-sm transition"
                  >
                    <EyeOff className="w-3.5 h-3.5" /> लपवा
                  </button>
                )}
                <button
                  onClick={() => handleDelete(viewingReview.id)}
                  className="px-3 py-1.5 text-rose-600 hover:bg-rose-50 rounded-lg text-xs font-semibold inline-flex items-center gap-1 transition"
                >
                  <Trash2 className="w-3.5 h-3.5" /> हटवा
                </button>
              </div>

              <button
                onClick={() => setViewingReview(null)}
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
