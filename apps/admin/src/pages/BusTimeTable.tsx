import React, { useState, useEffect } from 'react';
import { 
  Bus, 
  Plus, 
  Edit, 
  Trash2, 
  Clock, 
  Eye, 
  EyeOff, 
  Save, 
  X,
  RefreshCw 
} from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useToast } from '../components/Toast';
import { AdminPageHeader } from '../components/AdminPageHeader';

interface BusEntry {
  id: string;
  route_mr: string;
  route_en: string;
  departure_time: string;
  is_published: boolean;
  display_order: number;
}

export const BusTimeTable: React.FC = () => {
  const { showToast } = useToast();
  const [buses, setBuses] = useState<BusEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingBus, setEditingBus] = useState<BusEntry | null>(null);

  // Form State
  const [routeMr, setRouteMr] = useState('');
  const [routeEn, setRouteEn] = useState('');
  const [departureTime, setDepartureTime] = useState('');
  const [displayOrder, setDisplayOrder] = useState(1);
  const [isPublished, setIsPublished] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    fetchBuses();
  }, []);

  const fetchBuses = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('bus_timetables')
        .select('*')
        .order('display_order', { ascending: true });

      if (error) throw error;
      setBuses(data || []);
    } catch (err: any) {
      console.error('Error fetching bus timetables:', err);
      showToast('एसटी वेळापत्रक लोड करताना त्रुटी: ' + (err.message || 'Error'), 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleOpenAddModal = () => {
    setEditingBus(null);
    setRouteMr('');
    setRouteEn('');
    setDepartureTime('');
    setDisplayOrder(buses.length + 1);
    setIsPublished(true);
    setIsModalOpen(true);
  };

  const handleOpenEditModal = (bus: BusEntry) => {
    setEditingBus(bus);
    setRouteMr(bus.route_mr);
    setRouteEn(bus.route_en);
    setDepartureTime(bus.departure_time);
    setDisplayOrder(bus.display_order);
    setIsPublished(bus.is_published);
    setIsModalOpen(true);
  };

  const handleSaveBus = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!routeMr.trim() || !departureTime.trim()) {
      showToast('कृपया बस मार्ग आणि प्रस्थान वेळ प्रविष्ट करा.', 'error');
      return;
    }

    try {
      setSaving(true);
      const payload = {
        route_mr: routeMr.trim(),
        route_en: routeEn.trim() || routeMr.trim(),
        departure_time: departureTime.trim(),
        display_order: Number(displayOrder) || 1,
        is_published: isPublished,
        updated_at: new Date().toISOString(),
      };

      if (editingBus) {
        const { error } = await supabase
          .from('bus_timetables')
          .update(payload)
          .eq('id', editingBus.id);
        if (error) throw error;
        showToast('बस मार्ग वेळापत्रक अपडेट केले!', 'success');
      } else {
        const { error } = await supabase
          .from('bus_timetables')
          .insert([payload]);
        if (error) throw error;
        showToast('नवीन बस मार्ग जोडला!', 'success');
      }

      setIsModalOpen(false);
      fetchBuses();
    } catch (err: any) {
      console.error('Error saving bus entry:', err);
      showToast('जतन करताना त्रुटी: ' + (err.message || 'Error'), 'error');
    } finally {
      setSaving(false);
    }
  };

  const handleTogglePublish = async (bus: BusEntry) => {
    try {
      const nextStatus = !bus.is_published;
      const { error } = await supabase
        .from('bus_timetables')
        .update({ is_published: nextStatus, updated_at: new Date().toISOString() })
        .eq('id', bus.id);

      if (error) throw error;
      showToast(nextStatus ? 'बस फेरी प्रकाशित केली!' : 'बस फेरी अप्रकाशित केली.', 'success');
      fetchBuses();
    } catch (err: any) {
      showToast('त्रुटी: ' + err.message, 'error');
    }
  };

  const handleDelete = async (id: string, route: string) => {
    if (!window.confirm(`खरोखर "${route}" ही बस फेरी हटवायची आहे का?`)) return;
    try {
      const { error } = await supabase.from('bus_timetables').delete().eq('id', id);
      if (error) throw error;
      showToast('बस फेरी हटवली.', 'success');
      fetchBuses();
    } catch (err: any) {
      showToast('हटवताना त्रुटी: ' + err.message, 'error');
    }
  };

  return (
    <div className="space-y-6">
      <AdminPageHeader
        title="एसटी बस वेळापत्रक (Bus Time Table)"
        subtitle="नरडाणा बस स्टॉपवरून सुटणाऱ्या एसटी बसेसची साधी व अचूक यादी"
        actions={
          <button
            onClick={handleOpenAddModal}
            className="flex items-center space-x-2 bg-brand-blue hover:bg-brand-blue/90 text-white px-4 py-2 rounded-lg text-xs font-semibold shadow-sm transition"
          >
            <Plus className="w-4 h-4" />
            <span>नवीन बस फेरी जोडा</span>
          </button>
        }
      />

      {/* Main Clean Table UI */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="p-4 border-b border-slate-100 flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <Bus className="w-5 h-5 text-brand-blue" />
            <span className="font-bold text-sm text-slate-800">
              एकूण बसेस: {buses.length} (प्रकाशित: {buses.filter((b) => b.is_published).length})
            </span>
          </div>
          <button
            onClick={fetchBuses}
            className="flex items-center space-x-1 text-xs text-slate-500 hover:text-slate-800 px-2.5 py-1.5 border border-slate-200 rounded-lg"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin' : ''}`} />
            <span>रिफ्रेश</span>
          </button>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50 text-slate-600 font-semibold border-b border-slate-200">
              <tr>
                <th className="py-3 px-4 w-12">क्र.</th>
                <th className="py-3 px-4">बस मार्ग (Bus Route)</th>
                <th className="py-3 px-4">प्रस्थान वेळ (Departure Time)</th>
                <th className="py-3 px-4">स्थिती</th>
                <th className="py-3 px-4 text-right">कृती</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {loading ? (
                <tr>
                  <td colSpan={5} className="text-center py-10 text-slate-400">
                    वेळापत्रक लोड होत आहे...
                  </td>
                </tr>
              ) : buses.length === 0 ? (
                <tr>
                  <td colSpan={5} className="text-center py-10 text-slate-400">
                    कोणतीही बस फेरी उपलब्ध नाही.
                  </td>
                </tr>
              ) : (
                buses.map((b, idx) => (
                  <tr key={b.id} className="hover:bg-slate-50/70 transition">
                    <td className="py-3 px-4 font-mono font-bold text-slate-500">
                      {idx + 1}
                    </td>
                    <td className="py-3 px-4">
                      <p className="font-bold text-slate-900 text-[13px]">{b.route_mr}</p>
                      <p className="text-[11px] text-slate-500">{b.route_en}</p>
                    </td>
                    <td className="py-3 px-4">
                      <div className="inline-flex items-center space-x-1.5 bg-blue-50 text-brand-blue font-bold px-2.5 py-1 rounded-lg border border-blue-200">
                        <Clock className="w-3.5 h-3.5" />
                        <span>{b.departure_time}</span>
                      </div>
                    </td>
                    <td className="py-3 px-4">
                      <span
                        className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10.5px] font-bold ${
                          b.is_published
                            ? 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                            : 'bg-slate-100 text-slate-500'
                        }`}
                      >
                        {b.is_published ? '● प्रकाशित' : '○ मसुदा (Draft)'}
                      </span>
                    </td>
                    <td className="py-3 px-4 text-right">
                      <div className="flex items-center justify-end space-x-1.5">
                        <button
                          onClick={() => handleTogglePublish(b)}
                          className={`p-1.5 rounded ${
                            b.is_published
                              ? 'text-emerald-600 hover:bg-emerald-50'
                              : 'text-slate-400 hover:bg-slate-100'
                          }`}
                          title={b.is_published ? 'अप्रकाशित करा' : 'प्रकाशित करा'}
                        >
                          {b.is_published ? <Eye className="w-4 h-4" /> : <EyeOff className="w-4 h-4" />}
                        </button>
                        <button
                          onClick={() => handleOpenEditModal(b)}
                          className="p-1.5 text-slate-600 hover:bg-slate-100 rounded"
                          title="संपादित करा"
                        >
                          <Edit className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => handleDelete(b.id, b.route_mr)}
                          className="p-1.5 text-rose-600 hover:bg-rose-50 rounded"
                          title="हटवा"
                        >
                          <Trash2 className="w-4 h-4" />
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

      {/* Add / Edit Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white rounded-2xl w-full max-w-lg shadow-2xl overflow-hidden">
            <div className="p-5 border-b border-slate-100 flex items-center justify-between">
              <h3 className="font-bold text-base text-slate-900 flex items-center space-x-2">
                <Bus className="w-5 h-5 text-brand-blue" />
                <span>{editingBus ? 'बस फेरी संपादन' : 'नवीन बस फेरी जोडा'}</span>
              </h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSaveBus} className="p-6 space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  बस मार्ग (मराठी) *
                </label>
                <input
                  type="text"
                  required
                  value={routeMr}
                  onChange={(e) => setRouteMr(e.target.value)}
                  placeholder="उदा. धुळे - शिंदखेडा - नरडाणा - दोंडाईचा"
                  className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none focus:ring-1 focus:ring-brand-blue font-medium"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Bus Route (English)
                </label>
                <input
                  type="text"
                  value={routeEn}
                  onChange={(e) => setRouteEn(e.target.value)}
                  placeholder="e.g. Dhule - Shindkheda - Nardana - Dondaicha"
                  className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    प्रस्थान वेळ (Departure Time) *
                  </label>
                  <input
                    type="text"
                    required
                    value={departureTime}
                    onChange={(e) => setDepartureTime(e.target.value)}
                    placeholder="उदा. सकाळी ०७:३०"
                    className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none font-bold text-brand-blue"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    अनुक्रम क्रमांक (Order)
                  </label>
                  <input
                    type="number"
                    value={displayOrder}
                    onChange={(e) => setDisplayOrder(Number(e.target.value))}
                    className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none"
                  />
                </div>
              </div>

              <div className="flex items-center space-x-2 pt-2">
                <input
                  type="checkbox"
                  id="pubCheckbox"
                  checked={isPublished}
                  onChange={(e) => setIsPublished(e.target.checked)}
                  className="rounded text-brand-blue"
                />
                <label htmlFor="pubCheckbox" className="text-xs font-medium text-slate-700">
                  नागरिकांसाठी ॲपवर प्रकाशित करा (Publish on App)
                </label>
              </div>

              <div className="pt-4 border-t border-slate-100 flex items-center justify-end space-x-2">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 rounded-lg border border-slate-200 text-xs font-semibold text-slate-600 hover:bg-slate-50"
                >
                  रद्द करा
                </button>
                <button
                  type="submit"
                  disabled={saving}
                  className="px-5 py-2 rounded-lg bg-brand-blue hover:bg-brand-blue/90 text-white text-xs font-semibold shadow-sm flex items-center space-x-1"
                >
                  <Save className="w-3.5 h-3.5" />
                  <span>{saving ? 'जतन होत आहे...' : editingBus ? 'अपडेट करा' : 'फेरी जोडा'}</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
export default BusTimeTable;

