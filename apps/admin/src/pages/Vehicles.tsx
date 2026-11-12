import React, { useState, useEffect } from 'react';
import { 
  Car, 
  Phone, 
  CheckCircle, 
  Plus, 
  Search, 
  Eye, 
  Edit, 
  Trash2, 
  RefreshCw 
} from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useToast } from '../components/Toast';
import { AdminPageHeader } from '../components/AdminPageHeader';

interface VehicleListing {
  id: string;
  driver_name: string;
  vehicle_type: string;
  vehicle_model: string;
  vehicle_number: string | null;
  seating_capacity: number | null;
  load_capacity: string | null;
  ac_available: boolean;
  rental_rate_optional: string | null;
  contact_number: string;
  whatsapp_number: string | null;
  location_text: string | null;
  availability_status: string; // 'available' | 'busy'
  approval_status: string; // 'approved' | 'pending' | 'rejected'
  verification_status: string; // 'verified' | 'unverified'
  is_active: boolean;
  photo_url: string | null;
  created_at: string;
}

export const Vehicles: React.FC = () => {
  const { showToast } = useToast();
  const [vehicles, setVehicles] = useState<VehicleListing[]>([]);
  const [loading, setLoading] = useState(true);
  const [filterStatus, setFilterStatus] = useState<string>('all');
  const [filterCategory, setFilterCategory] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingVehicle, setEditingVehicle] = useState<VehicleListing | null>(null);

  // Form State
  const [driverName, setDriverName] = useState('');
  const [vehicleType, setVehicleType] = useState('अर्टिगा (७ सीटर)');
  const [vehicleModel, setVehicleModel] = useState('');
  const [vehicleNumber, setVehicleNumber] = useState('');
  const [seatingCapacity, setSeatingCapacity] = useState<number | ''>('');
  const [loadCapacity, setLoadCapacity] = useState('');
  const [acAvailable, setAcAvailable] = useState(false);
  const [rentalRate, setRentalRate] = useState('');
  const [contactNumber, setContactNumber] = useState('');
  const [whatsappNumber, setWhatsappNumber] = useState('');
  const [locationText, setLocationText] = useState('नरडाणा');
  const [availabilityStatus, setAvailabilityStatus] = useState('available');
  const [approvalStatus, setApprovalStatus] = useState('approved');
  const [photoUrl, setPhotoUrl] = useState('');
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    fetchVehicles();
  }, []);

  const fetchVehicles = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('vehicle_listings')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setVehicles(data || []);
    } catch (err: any) {
      console.error('Error fetching vehicles:', err);
      showToast('वाहनांची माहिती आणताना त्रुटी: ' + (err.message || 'Error'), 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleOpenAddModal = () => {
    setEditingVehicle(null);
    setDriverName('');
    setVehicleType('अर्टिगा (७ सीटर)');
    setVehicleModel('');
    setVehicleNumber('');
    setSeatingCapacity('');
    setLoadCapacity('');
    setAcAvailable(false);
    setRentalRate('');
    setContactNumber('');
    setWhatsappNumber('');
    setLocationText('नरडाणा');
    setAvailabilityStatus('available');
    setApprovalStatus('approved');
    setPhotoUrl('');
    setIsModalOpen(true);
  };

  const handleOpenEditModal = (v: VehicleListing) => {
    setEditingVehicle(v);
    setDriverName(v.driver_name);
    setVehicleType(v.vehicle_type);
    setVehicleModel(v.vehicle_model);
    setVehicleNumber(v.vehicle_number || '');
    setSeatingCapacity(v.seating_capacity || '');
    setLoadCapacity(v.load_capacity || '');
    setAcAvailable(v.ac_available);
    setRentalRate(v.rental_rate_optional || '');
    setContactNumber(v.contact_number);
    setWhatsappNumber(v.whatsapp_number || v.contact_number);
    setLocationText(v.location_text || 'नरडाणा');
    setAvailabilityStatus(v.availability_status);
    setApprovalStatus(v.approval_status);
    setPhotoUrl(v.photo_url || '');
    setIsModalOpen(true);
  };

  const handleSaveVehicle = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!driverName.trim() || !vehicleModel.trim() || !contactNumber.trim()) {
      showToast('कृपया चालक नाव, मॉडेल आणि संपर्क क्रमांक भरा.', 'error');
      return;
    }

    try {
      setSaving(true);
      const payload: any = {
        driver_name: driverName.trim(),
        vehicle_type: vehicleType,
        vehicle_model: vehicleModel.trim(),
        vehicle_number: vehicleNumber.trim() || null,
        seating_capacity: seatingCapacity === '' ? null : Number(seatingCapacity),
        load_capacity: loadCapacity.trim() || null,
        ac_available: acAvailable,
        rental_rate_optional: rentalRate.trim() || null,
        contact_number: contactNumber.trim(),
        whatsapp_number: whatsappNumber.trim() || contactNumber.trim(),
        location_text: locationText.trim() || 'नरडाणा',
        availability_status: availabilityStatus,
        approval_status: approvalStatus,
        verification_status: 'verified',
        is_active: true,
        photo_url: photoUrl.trim() || null,
        updated_at: new Date().toISOString(),
      };

      if (editingVehicle) {
        const { error } = await supabase
          .from('vehicle_listings')
          .update(payload)
          .eq('id', editingVehicle.id);
        if (error) throw error;
        showToast('गाडीची माहिती यशस्वीरित्या अपडेट केली!', 'success');
      } else {
        const { error } = await supabase
          .from('vehicle_listings')
          .insert([payload]);
        if (error) throw error;
        showToast('नवीन गाडीची नोंद यशस्वी झाली!', 'success');
      }

      setIsModalOpen(false);
      fetchVehicles();
    } catch (err: any) {
      console.error('Error saving vehicle:', err);
      showToast('जतन करताना त्रुटी: ' + (err.message || 'Error'), 'error');
    } finally {
      setSaving(false);
    }
  };

  const handleQuickApproval = async (id: string, status: 'approved' | 'rejected') => {
    try {
      const { error } = await supabase
        .from('vehicle_listings')
        .update({ approval_status: status, updated_at: new Date().toISOString() })
        .eq('id', id);

      if (error) throw error;
      showToast(status === 'approved' ? 'गाडी मंजूर (Approved) केली!' : 'गाडी नामंजूर (Rejected) केली.', 'success');
      fetchVehicles();
    } catch (err: any) {
      showToast('त्रुटी: ' + (err.message || 'Error'), 'error');
    }
  };

  const handleToggleActive = async (id: string, current: boolean) => {
    try {
      const { error } = await supabase
        .from('vehicle_listings')
        .update({ is_active: !current, updated_at: new Date().toISOString() })
        .eq('id', id);

      if (error) throw error;
      showToast(current ? 'गाडी लपवली (Hidden)' : 'गाडी सक्रिय केली (Visible)', 'success');
      fetchVehicles();
    } catch (err: any) {
      showToast('त्रुटी: ' + (err.message || 'Error'), 'error');
    }
  };

  const handleDelete = async (id: string, name: string) => {
    if (!window.confirm(`खरोखर "${name}" ही नोंद हटवायची आहे का?`)) return;
    try {
      const { error } = await supabase.from('vehicle_listings').delete().eq('id', id);
      if (error) throw error;
      showToast('गाडीची नोंद हटवली.', 'success');
      fetchVehicles();
    } catch (err: any) {
      showToast('हटवताना त्रुटी: ' + err.message, 'error');
    }
  };

  // Filtered Listings
  const filteredVehicles = vehicles.filter((v) => {
    if (filterStatus !== 'all' && v.approval_status !== filterStatus) return false;
    if (filterCategory !== 'all' && v.vehicle_type !== filterCategory) return false;
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      const match =
        v.driver_name.toLowerCase().includes(q) ||
        v.vehicle_model.toLowerCase().includes(q) ||
        v.vehicle_type.toLowerCase().includes(q) ||
        (v.contact_number && v.contact_number.includes(q)) ||
        (v.location_text && v.location_text.toLowerCase().includes(q));
      if (!match) return false;
    }
    return true;
  });

  const totalCount = vehicles.length;
  const approvedCount = vehicles.filter((v) => v.approval_status === 'approved').length;
  const pendingCount = vehicles.filter((v) => v.approval_status === 'pending').length;
  const availableCount = vehicles.filter((v) => v.availability_status === 'available' && v.is_active).length;

  return (
    <div className="space-y-6">
      <AdminPageHeader
        title="गाडी भाड्याने व चालक व्यवस्थापन (Vehicle Rental Directory)"
        subtitle="केवळ नरडाणा गाव (पिन: ४२५४०४) मधील कार, टॅक्सी, अर्टिगा, ट्रॅक्टर, जेसीबी व मालवाहतूक वाहने"
        actions={
          <button
            onClick={handleOpenAddModal}
            className="flex items-center space-x-2 bg-brand-blue hover:bg-brand-blue/90 text-white px-4 py-2 rounded-lg text-sm font-semibold shadow-sm transition"
          >
            <Plus className="w-4 h-4" />
            <span>नवीन गाडी जोडा</span>
          </button>
        }
      />

      {/* Metric Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <p className="text-xs text-slate-500 font-medium">एकूण वाहने (Total)</p>
          <p className="text-2xl font-bold text-slate-800 mt-1">{totalCount}</p>
        </div>
        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <p className="text-xs text-emerald-600 font-medium">मंजूर व सक्रिय (Approved)</p>
          <p className="text-2xl font-bold text-emerald-700 mt-1">{approvedCount}</p>
        </div>
        <div className="bg-white p-4 rounded-xl border border-amber-200 bg-amber-50/50 shadow-sm">
          <p className="text-xs text-amber-700 font-medium">पडताळणी प्रलंबित (Pending Review)</p>
          <p className="text-2xl font-bold text-amber-800 mt-1">{pendingCount}</p>
        </div>
        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <p className="text-xs text-blue-600 font-medium">सध्या उपलब्ध (Available Now)</p>
          <p className="text-2xl font-bold text-blue-700 mt-1">{availableCount}</p>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col md:flex-row gap-3 items-center justify-between">
        <div className="flex flex-wrap items-center gap-2 w-full md:w-auto">
          <div className="relative flex-1 md:w-64">
            <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              placeholder="चालक, वाहन किंवा मोबाईल शोधा..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-3 py-1.5 text-xs rounded-lg border border-slate-200 focus:outline-none focus:ring-1 focus:ring-brand-blue"
            />
          </div>

          <select
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
            className="text-xs border border-slate-200 rounded-lg px-3 py-1.5 focus:outline-none bg-white font-medium"
          >
            <option value="all">सर्व स्थिती (All Status)</option>
            <option value="approved">फक्त मंजूर (Approved)</option>
            <option value="pending">प्रलंबित (Pending Review)</option>
            <option value="rejected">नामंजूर (Rejected)</option>
          </select>

          <select
            value={filterCategory}
            onChange={(e) => setFilterCategory(e.target.value)}
            className="text-xs border border-slate-200 rounded-lg px-3 py-1.5 focus:outline-none bg-white font-medium"
          >
            <option value="all">सर्व कॅटेगरी (All Types)</option>
            <option value="अर्टिगा (७ सीटर)">अर्टिगा (७ सीटर)</option>
            <option value="इनोव्हा">इनोव्हा</option>
            <option value="कार">कार</option>
            <option value="टॅक्सी">टॅक्सी</option>
            <option value="पिकअप / छोटा हत्ती">पिकअप / छोटा हत्ती</option>
            <option value="ट्रॅक्टर">ट्रॅक्टर</option>
            <option value="जेसीबी (JCB)">जेसीबी (JCB)</option>
            <option value="टेम्पो">टेम्पो</option>
            <option value="ट्रक">ट्रक</option>
            <option value="बस / ट्रॅव्हलर">बस / ट्रॅव्हलर</option>
          </select>
        </div>

        <button
          onClick={fetchVehicles}
          className="flex items-center space-x-1 text-xs text-slate-500 hover:text-slate-800 px-3 py-1.5 border border-slate-200 rounded-lg"
        >
          <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin' : ''}`} />
          <span>रिफ्रेश</span>
        </button>
      </div>

      {/* Vehicle Listings Table */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50 text-slate-600 font-semibold border-b border-slate-200">
              <tr>
                <th className="py-3 px-4">वाहन व चालक</th>
                <th className="py-3 px-4">कॅटेगरी व मॉडेल</th>
                <th className="py-3 px-4">क्षमता व AC</th>
                <th className="py-3 px-4">संपर्क व पत्ता</th>
                <th className="py-3 px-4">स्थिती (Availability)</th>
                <th className="py-3 px-4">मंजुरी (Approval)</th>
                <th className="py-3 px-4 text-right">कृती (Actions)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {loading ? (
                <tr>
                  <td colSpan={7} className="text-center py-10 text-slate-400">
                    माहिती लोड होत आहे...
                  </td>
                </tr>
              ) : filteredVehicles.length === 0 ? (
                <tr>
                  <td colSpan={7} className="text-center py-10 text-slate-400">
                    कोणतीही गाडी आढळली नाही.
                  </td>
                </tr>
              ) : (
                filteredVehicles.map((v) => (
                  <tr key={v.id} className="hover:bg-slate-50/70 transition">
                    <td className="py-3 px-4">
                      <div className="flex items-center space-x-3">
                        {v.photo_url ? (
                          <img
                            src={v.photo_url}
                            alt={v.driver_name}
                            className="w-10 h-10 rounded-lg object-cover border border-slate-200"
                          />
                        ) : (
                          <div className="w-10 h-10 rounded-lg bg-blue-50 text-brand-blue flex items-center justify-center font-bold">
                            <Car className="w-5 h-5" />
                          </div>
                        )}
                        <div>
                          <p className="font-bold text-slate-900">{v.driver_name}</p>
                          <p className="text-[11px] text-slate-500 font-mono">
                            {v.vehicle_number || 'नोंदणीकृत वाहन'}
                          </p>
                        </div>
                      </div>
                    </td>

                    <td className="py-3 px-4">
                      <span className="inline-block px-2 py-0.5 rounded bg-blue-50 text-brand-blue font-semibold text-[11px]">
                        {v.vehicle_type}
                      </span>
                      <p className="font-medium text-slate-800 mt-1">{v.vehicle_model}</p>
                    </td>

                    <td className="py-3 px-4">
                      {v.seating_capacity && (
                        <p className="text-slate-700">{v.seating_capacity} सीटर</p>
                      )}
                      {v.load_capacity && (
                        <p className="text-slate-600 text-[11px]">{v.load_capacity}</p>
                      )}
                      {v.ac_available ? (
                        <span className="text-[10px] font-bold text-cyan-700 bg-cyan-50 px-1.5 py-0.5 rounded">
                          ❄️ AC
                        </span>
                      ) : (
                        <span className="text-[10px] text-slate-400">Non-AC</span>
                      )}
                    </td>

                    <td className="py-3 px-4">
                      <div className="flex items-center space-x-1.5 text-slate-800 font-semibold">
                        <Phone className="w-3.5 h-3.5 text-brand-blue" />
                        <span>{v.contact_number}</span>
                      </div>
                      <p className="text-[11px] text-slate-500 mt-0.5">
                        📍 {v.location_text || 'नरडाणा'}
                      </p>
                    </td>

                    <td className="py-3 px-4">
                      <span
                        className={`inline-flex items-center px-2 py-1 rounded-full text-[11px] font-bold ${
                          v.availability_status === 'available'
                            ? 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                            : 'bg-amber-50 text-amber-700 border border-amber-200'
                        }`}
                      >
                        {v.availability_status === 'available' ? '🟢 उपलब्ध' : '🟠 कामावर'}
                      </span>
                    </td>

                    <td className="py-3 px-4">
                      <span
                        className={`inline-flex items-center px-2 py-1 rounded-full text-[11px] font-bold ${
                          v.approval_status === 'approved'
                            ? 'bg-emerald-50 text-emerald-700'
                            : v.approval_status === 'pending'
                            ? 'bg-amber-50 text-amber-700'
                            : 'bg-rose-50 text-rose-700'
                        }`}
                      >
                        {v.approval_status === 'approved'
                          ? 'मंजूर'
                          : v.approval_status === 'pending'
                          ? 'प्रलंबित'
                          : 'नामंजूर'}
                      </span>
                    </td>

                    <td className="py-3 px-4 text-right">
                      <div className="flex items-center justify-end space-x-1.5">
                        {v.approval_status === 'pending' && (
                          <button
                            onClick={() => handleQuickApproval(v.id, 'approved')}
                            className="p-1.5 text-emerald-600 hover:bg-emerald-50 rounded"
                            title="मंजूर करा"
                          >
                            <CheckCircle className="w-4 h-4" />
                          </button>
                        )}
                        <button
                          onClick={() => handleOpenEditModal(v)}
                          className="p-1.5 text-slate-600 hover:bg-slate-100 rounded"
                          title="संपादित करा"
                        >
                          <Edit className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => handleToggleActive(v.id, v.is_active)}
                          className={`p-1.5 rounded ${
                            v.is_active
                              ? 'text-emerald-600 hover:bg-emerald-50'
                              : 'text-slate-400 hover:bg-slate-100'
                          }`}
                          title={v.is_active ? 'लपवा' : 'दाखवा'}
                        >
                          <Eye className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => handleDelete(v.id, v.driver_name)}
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
          <div className="bg-white rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto shadow-2xl">
            <div className="p-5 border-b border-slate-100 flex items-center justify-between sticky top-0 bg-white">
              <h3 className="font-bold text-base text-slate-900">
                {editingVehicle ? 'गाडी माहिती संपादन' : 'नवीन गाडी नोंदणी (Add Vehicle)'}
              </h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleSaveVehicle} className="p-6 space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    चालक / मालकाचे नाव *
                  </label>
                  <input
                    type="text"
                    required
                    value={driverName}
                    onChange={(e) => setDriverName(e.target.value)}
                    placeholder="उदा. कैलास निवृत्ती पाटील"
                    className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none focus:ring-1 focus:ring-brand-blue"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    वाहन प्रकार (Vehicle Type) *
                  </label>
                  <select
                    value={vehicleType}
                    onChange={(e) => setVehicleType(e.target.value)}
                    className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none bg-white font-medium"
                  >
                    <option value="अर्टिगा (७ सीटर)">अर्टिगा (७ सीटर)</option>
                    <option value="इनोव्हा">इनोव्हा</option>
                    <option value="कार">कार</option>
                    <option value="टॅक्सी">टॅक्सी</option>
                    <option value="पिकअप / छोटा हत्ती">पिकअप / छोटा हत्ती</option>
                    <option value="ट्रॅक्टर">ट्रॅक्टर</option>
                    <option value="जेसीबी (JCB)">जेसीबी (JCB)</option>
                    <option value="टेम्पो">टेम्पो</option>
                    <option value="ट्रक">ट्रक</option>
                    <option value="बस / ट्रॅव्हलर">बस / ट्रॅव्हलर</option>
                    <option value="इतर वाहने">इतर वाहने</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    गाडीचे मॉडेल / नाव *
                  </label>
                  <input
                    type="text"
                    required
                    value={vehicleModel}
                    onChange={(e) => setVehicleModel(e.target.value)}
                    placeholder="उदा. Maruti Ertiga VXi (CNG)"
                    className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none focus:ring-1 focus:ring-brand-blue"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    गाडी क्रमांक (नोंदणी / गोपनीय)
                  </label>
                  <input
                    type="text"
                    value={vehicleNumber}
                    onChange={(e) => setVehicleNumber(e.target.value)}
                    placeholder="उदा. MH 18 BX 4412"
                    className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    बैठक क्षमता (व्यक्ती)
                  </label>
                  <input
                    type="number"
                    value={seatingCapacity}
                    onChange={(e) =>
                      setSeatingCapacity(e.target.value === '' ? '' : Number(e.target.value))
                    }
                    placeholder="उदा. ७"
                    className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    वजन क्षमता / शेती अवजारे
                  </label>
                  <input
                    type="text"
                    value={loadCapacity}
                    onChange={(e) => setLoadCapacity(e.target.value)}
                    placeholder="उदा. १.५ टन / रोटाव्हेटरसह"
                    className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    कॉलसाठी मोबाईल क्रमांक *
                  </label>
                  <input
                    type="text"
                    required
                    maxLength={10}
                    value={contactNumber}
                    onChange={(e) => setContactNumber(e.target.value)}
                    placeholder="९४२१८८९९०१"
                    className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    WhatsApp क्रमांक
                  </label>
                  <input
                    type="text"
                    maxLength={10}
                    value={whatsappNumber}
                    onChange={(e) => setWhatsappNumber(e.target.value)}
                    placeholder="९४२१८८९९०१"
                    className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    थांबण्याचे ठिकाण (नरडाणा)
                  </label>
                  <input
                    type="text"
                    value={locationText}
                    onChange={(e) => setLocationText(e.target.value)}
                    placeholder="उदा. स्टेशन परिसर, नरडाणा"
                    className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    अंदाजे भाडे / दर (ऐच्छिक)
                  </label>
                  <input
                    type="text"
                    value={rentalRate}
                    onChange={(e) => setRentalRate(e.target.value)}
                    placeholder="उदा. ₹१२ प्रति किमी"
                    className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    गाडीची स्थिती (Availability)
                  </label>
                  <select
                    value={availabilityStatus}
                    onChange={(e) => setAvailabilityStatus(e.target.value)}
                    className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none bg-white font-medium"
                  >
                    <option value="available">🟢 उपलब्ध (Available)</option>
                    <option value="busy">🟠 कामावर (Busy)</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    मंजुरी स्थिती (Approval)
                  </label>
                  <select
                    value={approvalStatus}
                    onChange={(e) => setApprovalStatus(e.target.value)}
                    className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none bg-white font-medium"
                  >
                    <option value="approved">मंजूर (Approved)</option>
                    <option value="pending">प्रलंबित (Pending Review)</option>
                    <option value="rejected">नामंजूर (Rejected)</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  गाडीचा फोटो URL (ऐच्छिक)
                </label>
                <input
                  type="url"
                  value={photoUrl}
                  onChange={(e) => setPhotoUrl(e.target.value)}
                  placeholder="https://..."
                  className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none"
                />
              </div>

              <div className="flex items-center space-x-2 pt-2">
                <input
                  type="checkbox"
                  id="acCheckbox"
                  checked={acAvailable}
                  onChange={(e) => setAcAvailable(e.target.checked)}
                  className="rounded text-brand-blue"
                />
                <label htmlFor="acCheckbox" className="text-xs font-medium text-slate-700">
                  वातानुकूलित यंत्रणा (AC) उपलब्ध आहे
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
                  className="px-5 py-2 rounded-lg bg-brand-blue hover:bg-brand-blue/90 text-white text-xs font-semibold shadow-sm"
                >
                  {saving ? 'जतन होत आहे...' : editingVehicle ? 'अपडेट करा' : 'नोंदणी जोडा'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
export default Vehicles;
