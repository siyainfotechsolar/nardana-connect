import React, { useState } from 'react';
import { 
  Users as UsersIcon, 
  Search, 
  UserPlus, 
  Eye, 
  Ban, 
  CheckCircle2, 
  Phone, 
  MapPin, 
  ArrowLeft,
  X,
  Filter,
  Briefcase,
  Store,
  ShoppingBag
} from 'lucide-react';
import { useToast } from '../components/Toast';
import { AdminPageHeader } from '../components/AdminPageHeader';

interface UserRecord {
  id: string;
  name: string;
  phone: string;
  ward: string;
  role: 'citizen' | 'business_owner' | 'gram_panchayat_staff';
  status: 'active' | 'pending' | 'blocked';
  joined_date: string;
  businesses_count: number;
  jobs_count: number;
  marketplace_count: number;
}

const INITIAL_USERS: UserRecord[] = [
  {
    id: 'usr-101',
    name: 'सचिन दत्तात्रय पाटील',
    phone: '9823012345',
    ward: 'स्टेशन रोड, वॉर्ड १',
    role: 'business_owner',
    status: 'active',
    joined_date: '२०२६-०१-१५',
    businesses_count: 1,
    jobs_count: 2,
    marketplace_count: 0,
  },
  {
    id: 'usr-102',
    name: 'प्रमोद वसंत महाजन',
    phone: '9422054321',
    ward: 'मेन बाजारपेठ, वॉर्ड २',
    role: 'business_owner',
    status: 'active',
    joined_date: '२०२६-०१-१८',
    businesses_count: 1,
    jobs_count: 0,
    marketplace_count: 3,
  },
  {
    id: 'usr-103',
    name: 'ज्ञानेश्वर बापूराव पाटील',
    phone: '9890123456',
    ward: 'कुंभार गल्ली, वॉर्ड ३',
    role: 'citizen',
    status: 'active',
    joined_date: '२०२६-०२-०२',
    businesses_count: 0,
    jobs_count: 1,
    marketplace_count: 1,
  },
  {
    id: 'usr-104',
    name: 'दिनेश रामदास चौधरी',
    phone: '9765432100',
    ward: 'हायवे चौक, वॉर्ड ४',
    role: 'business_owner',
    status: 'active',
    joined_date: '२०२६-०२-१०',
    businesses_count: 1,
    jobs_count: 1,
    marketplace_count: 0,
  },
  {
    id: 'usr-105',
    name: 'सुरेश विठ्ठल माळी',
    phone: '9421889900',
    ward: 'स्टेशन परिसर, वॉर्ड १',
    role: 'citizen',
    status: 'pending',
    joined_date: '२०२६-०३-०१',
    businesses_count: 0,
    jobs_count: 0,
    marketplace_count: 0,
  },
];

export const Users: React.FC = () => {
  const { showToast } = useToast();
  const [users, setUsers] = useState<UserRecord[]>(INITIAL_USERS);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'pending' | 'blocked'>('all');
  const [roleFilter, setRoleFilter] = useState<'all' | 'citizen' | 'business_owner'>('all');

  const [selectedUser, setSelectedUser] = useState<UserRecord | null>(null);
  const [isAddOpen, setIsAddOpen] = useState(false);

  // New User Form State
  const [newName, setNewName] = useState('');
  const [newPhone, setNewPhone] = useState('');
  const [newWard, setNewWard] = useState('मेन बाजारपेठ, वॉर्ड २');
  const [newRole, setNewRole] = useState<'citizen' | 'business_owner'>('citizen');

  const isFormDirty = newName.trim().length > 0 || newPhone.trim().length > 0;

  const filteredUsers = users.filter((u) => {
    const matchesSearch =
      u.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      u.phone.includes(searchTerm) ||
      u.ward.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = statusFilter === 'all' || u.status === statusFilter;
    const matchesRole = roleFilter === 'all' || u.role === roleFilter;
    return matchesSearch && matchesStatus && matchesRole;
  });

  const handleToggleStatus = (id: string, currentStatus: string) => {
    const nextStatus = currentStatus === 'active' ? 'blocked' : 'active';
    setUsers((prev) =>
      prev.map((u) => (u.id === id ? { ...u, status: nextStatus as any } : u))
    );
    if (selectedUser?.id === id) {
      setSelectedUser((prev) => (prev ? { ...prev, status: nextStatus as any } : null));
    }
    showToast(
      nextStatus === 'blocked' ? 'वापरकर्ता ब्लॉक करण्यात आला आहे.' : 'वापरकर्ता सक्रिय केला!',
      nextStatus === 'blocked' ? 'error' : 'success'
    );
  };

  const handleApprove = (id: string) => {
    setUsers((prev) =>
      prev.map((u) => (u.id === id ? { ...u, status: 'active' } : u))
    );
    if (selectedUser?.id === id) {
      setSelectedUser((prev) => (prev ? { ...prev, status: 'active' } : null));
    }
    showToast('वापरकर्ता यशस्वीरीत्या मंजूर (Approved) करण्यात आला.', 'success');
  };

  const handleCloseAddModal = () => {
    if (isFormDirty) {
      if (!window.confirm('तुम्ही भरलेली माहिती अजून सेव्ह झालेली नाही. मागे जायचे आहे का?')) {
        return;
      }
    }
    setIsAddOpen(false);
    setNewName('');
    setNewPhone('');
  };

  const handleCreateUser = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newName.trim() || newPhone.trim().length !== 10) {
      showToast('कृपया वैध नाव आणि १० अंकी मोबाईल नंबर प्रविष्ट करा.', 'error');
      return;
    }

    const newUser: UserRecord = {
      id: 'usr-' + (Date.now() % 10000),
      name: newName.trim(),
      phone: newPhone.trim(),
      ward: newWard,
      role: newRole,
      status: 'active',
      joined_date: new Date().toISOString().split('T')[0],
      businesses_count: 0,
      jobs_count: 0,
      marketplace_count: 0,
    };

    setUsers([newUser, ...users]);
    showToast('नवीन नागरिक नोंदणी यशस्वीरीत्या जोडली!', 'success');
    setIsAddOpen(false);
    setNewName('');
    setNewPhone('');
  };

  return (
    <div className="space-y-6">
      <AdminPageHeader
        title="नागरिक व वापरकर्ते निर्देशिका"
        subtitle="Citizens & Users Management"
        icon={UsersIcon}
        actions={
          <button
            onClick={() => setIsAddOpen(true)}
            className="flex items-center space-x-2 px-4 py-2.5 rounded-xl bg-brand-blue hover:bg-blue-700 text-white font-bold text-xs transition shadow-sm"
          >
            <UserPlus className="w-4 h-4" />
            <span>नवीन वापरकर्ता जोडा</span>
          </button>
        }
      />

      {/* Search and Filters */}
      <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-sm flex flex-col md:flex-row gap-3 items-center justify-between">
        <div className="relative w-full md:w-80">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-3" />
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="नाव, मोबाईल किंवा वॉर्ड शोधा..."
            className="w-full pl-10 pr-4 py-2 rounded-xl border border-slate-200 text-xs text-slate-800 focus:outline-none focus:border-brand-blue"
          />
        </div>

        <div className="flex items-center space-x-2 w-full md:w-auto">
          <div className="flex items-center space-x-1.5 text-xs text-slate-500 font-bold">
            <Filter className="w-3.5 h-3.5" />
            <span>स्थिती:</span>
          </div>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value as any)}
            className="px-3 py-1.5 rounded-xl border border-slate-200 text-xs font-semibold text-slate-700 focus:outline-none focus:border-brand-blue bg-white"
          >
            <option value="all">सर्व स्थिती</option>
            <option value="active">सक्रिय (Active)</option>
            <option value="pending">प्रलंबित (Pending)</option>
            <option value="blocked">ब्लॉक (Blocked)</option>
          </select>

          <select
            value={roleFilter}
            onChange={(e) => setRoleFilter(e.target.value as any)}
            className="px-3 py-1.5 rounded-xl border border-slate-200 text-xs font-semibold text-slate-700 focus:outline-none focus:border-brand-blue bg-white"
          >
            <option value="all">सर्व भूमिका</option>
            <option value="citizen">गावकरी नागरिक</option>
            <option value="business_owner">दुकानदार / व्यावसायिक</option>
          </select>
        </div>
      </div>

      {/* Users Table */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50 text-slate-600 font-bold border-b border-slate-200 select-none">
              <tr>
                <th className="py-3 px-4">नागरिक नाव</th>
                <th className="py-3 px-4">मोबाईल</th>
                <th className="py-3 px-4">नरडाणा वॉर्ड / गल्ली</th>
                <th className="py-3 px-4">भूमिका</th>
                <th className="py-3 px-4">स्थिती</th>
                <th className="py-3 px-4">नोंदणी तारीख</th>
                <th className="py-3 px-4 text-right">कृती (Actions)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredUsers.length === 0 ? (
                <tr>
                  <td colSpan={7} className="py-8 text-center text-slate-400">
                    कोणतेही वापरकर्ते सापडले नाहीत.
                  </td>
                </tr>
              ) : (
                filteredUsers.map((u) => (
                  <tr key={u.id} className="hover:bg-slate-50 transition">
                    <td className="py-3 px-4 font-bold text-slate-800">
                      <div className="flex items-center space-x-2">
                        <div className="w-7 h-7 rounded-full bg-brand-blue/10 text-brand-blue font-bold flex items-center justify-center text-[11px]">
                          {u.name.slice(0, 1)}
                        </div>
                        <span>{u.name}</span>
                      </div>
                    </td>
                    <td className="py-3 px-4 font-mono text-slate-600">{u.phone}</td>
                    <td className="py-3 px-4 text-slate-600">{u.ward}</td>
                    <td className="py-3 px-4">
                      {u.role === 'business_owner' ? (
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-blue-50 text-brand-blue border border-blue-200">
                          व्यावसायिक
                        </span>
                      ) : (
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-slate-100 text-slate-600">
                          गावकरी
                        </span>
                      )}
                    </td>
                    <td className="py-3 px-4">
                      {u.status === 'active' && (
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                          सक्रिय
                        </span>
                      )}
                      {u.status === 'pending' && (
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-200">
                          प्रलंबित
                        </span>
                      )}
                      {u.status === 'blocked' && (
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-red-50 text-red-700 border border-red-200">
                          ब्लॉक
                        </span>
                      )}
                    </td>
                    <td className="py-3 px-4 font-mono text-slate-500">{u.joined_date}</td>
                    <td className="py-3 px-4 text-right">
                      <div className="flex items-center justify-end space-x-2">
                        <button
                          onClick={() => setSelectedUser(u)}
                          title="तपशील पहा (View Details)"
                          className="p-1.5 rounded-lg border border-slate-200 hover:bg-slate-100 text-brand-blue transition"
                        >
                          <Eye className="w-3.5 h-3.5" />
                        </button>
                        {u.status === 'pending' ? (
                          <button
                            onClick={() => handleApprove(u.id)}
                            title="मंजूर करा (Approve)"
                            className="p-1.5 rounded-lg border border-emerald-200 bg-emerald-50 hover:bg-emerald-100 text-emerald-700 transition"
                          >
                            <CheckCircle2 className="w-3.5 h-3.5" />
                          </button>
                        ) : (
                          <button
                            onClick={() => handleToggleStatus(u.id, u.status)}
                            title={u.status === 'active' ? 'ब्लॉक करा (Block)' : 'सक्रिय करा (Unblock)'}
                            className={`p-1.5 rounded-lg border transition ${
                              u.status === 'active'
                                ? 'border-red-200 hover:bg-red-50 text-red-600'
                                : 'border-emerald-200 hover:bg-emerald-50 text-emerald-700'
                            }`}
                          >
                            <Ban className="w-3.5 h-3.5" />
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* User Details Modal (Safe Back to Users) */}
      {selectedUser && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl max-w-lg w-full p-6 shadow-2xl border border-slate-100 space-y-5 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center space-x-3">
                <button
                  onClick={() => setSelectedUser(null)}
                  title="वापरकर्त्यांच्या यादीवर परत जा"
                  className="p-2 rounded-xl border border-slate-200 hover:bg-slate-100 text-slate-600 transition"
                >
                  <ArrowLeft className="w-4 h-4" />
                </button>
                <div>
                  <h3 className="text-base font-black text-slate-800 leading-tight">नागरिक तपशील (User Details)</h3>
                  <p className="text-[11px] text-slate-400">ID: {selectedUser.id}</p>
                </div>
              </div>
              <button
                onClick={() => setSelectedUser(null)}
                className="p-1.5 rounded-xl text-slate-400 hover:text-slate-600 hover:bg-slate-100"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-4">
              <div className="bg-slate-50 p-4 rounded-2xl border border-slate-200 flex items-center space-x-4">
                <div className="w-14 h-14 rounded-2xl bg-brand-blue text-white flex items-center justify-center text-xl font-black shadow-md">
                  {selectedUser.name.slice(0, 1)}
                </div>
                <div>
                  <h4 className="font-bold text-slate-800 text-sm">{selectedUser.name}</h4>
                  <p className="text-xs text-slate-500 flex items-center gap-1 mt-0.5">
                    <Phone className="w-3 h-3 text-brand-green" /> {selectedUser.phone}
                  </p>
                  <p className="text-xs text-slate-500 flex items-center gap-1 mt-0.5">
                    <MapPin className="w-3 h-3 text-red-500" /> {selectedUser.ward} (नरडाणा)
                  </p>
                </div>
              </div>

              {/* Counts Grid */}
              <div className="grid grid-cols-3 gap-2 text-center">
                <div className="p-3 bg-blue-50 rounded-xl border border-blue-200">
                  <Store className="w-4 h-4 text-brand-blue mx-auto mb-1" />
                  <p className="text-xs font-bold text-slate-700">{selectedUser.businesses_count}</p>
                  <p className="text-[10px] text-slate-500">नोंदणीकृत दुकाने</p>
                </div>
                <div className="p-3 bg-emerald-50 rounded-xl border border-emerald-200">
                  <Briefcase className="w-4 h-4 text-emerald-600 mx-auto mb-1" />
                  <p className="text-xs font-bold text-slate-700">{selectedUser.jobs_count}</p>
                  <p className="text-[10px] text-slate-500">नोकरी जाहिराती</p>
                </div>
                <div className="p-3 bg-amber-50 rounded-xl border border-amber-200">
                  <ShoppingBag className="w-4 h-4 text-amber-600 mx-auto mb-1" />
                  <p className="text-xs font-bold text-slate-700">{selectedUser.marketplace_count}</p>
                  <p className="text-[10px] text-slate-500">बाजारपेठ वस्तू</p>
                </div>
              </div>

              <div className="bg-slate-50 p-3 rounded-xl border border-slate-200 space-y-1.5 text-xs">
                <div className="flex justify-between">
                  <span className="text-slate-500">नोंदणी तारीख:</span>
                  <span className="font-semibold text-slate-800">{selectedUser.joined_date}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">सद्यस्थिती:</span>
                  <span className="font-bold">
                    {selectedUser.status === 'active' && <span className="text-emerald-600">सक्रिय (Active)</span>}
                    {selectedUser.status === 'pending' && <span className="text-amber-600">प्रलंबित (Pending)</span>}
                    {selectedUser.status === 'blocked' && <span className="text-red-600">ब्लॉक (Blocked)</span>}
                  </span>
                </div>
              </div>
            </div>

            <div className="flex items-center justify-between pt-2 border-t border-slate-100">
              <button
                onClick={() => setSelectedUser(null)}
                className="px-4 py-2 border border-slate-300 rounded-xl text-xs font-bold text-slate-700 hover:bg-slate-50 transition"
              >
                मागे जा (Back to Users)
              </button>

              <div className="flex items-center space-x-2">
                {selectedUser.status === 'pending' ? (
                  <button
                    onClick={() => handleApprove(selectedUser.id)}
                    className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold transition shadow-sm"
                  >
                    मंजूर करा (Approve)
                  </button>
                ) : (
                  <button
                    onClick={() => handleToggleStatus(selectedUser.id, selectedUser.status)}
                    className={`px-4 py-2 rounded-xl text-xs font-bold transition shadow-sm text-white ${
                      selectedUser.status === 'active' ? 'bg-red-600 hover:bg-red-700' : 'bg-emerald-600 hover:bg-emerald-700'
                    }`}
                  >
                    {selectedUser.status === 'active' ? 'वापरकर्ता ब्लॉक करा' : 'वापरकर्ता अनब्लॉक करा'}
                  </button>
                )}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Add User Modal */}
      {isAddOpen && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-100 space-y-4 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center space-x-2">
                <button
                  type="button"
                  onClick={handleCloseAddModal}
                  className="p-1.5 rounded-lg border border-slate-200 hover:bg-slate-100 text-slate-600 transition"
                  title="मागे जा"
                >
                  <ArrowLeft className="w-4 h-4" />
                </button>
                <h3 className="text-base font-black text-slate-800">नवीन नागरिक जोडा</h3>
              </div>
              <button
                type="button"
                onClick={handleCloseAddModal}
                className="p-1 rounded-lg text-slate-400 hover:text-slate-600"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleCreateUser} className="space-y-3.5">
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  पूर्ण नाव (Full Name) *
                </label>
                <input
                  type="text"
                  value={newName}
                  onChange={(e) => setNewName(e.target.value)}
                  placeholder="उदा. राहुल शांताराम पाटील"
                  className="w-full px-3.5 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-brand-blue"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  मोबाईल नंबर (१० अंकी) *
                </label>
                <input
                  type="tel"
                  maxLength={10}
                  value={newPhone}
                  onChange={(e) => setNewPhone(e.target.value)}
                  placeholder="98XXXXXXXX"
                  className="w-full px-3.5 py-2 rounded-xl border border-slate-200 text-xs font-mono font-semibold focus:outline-none focus:border-brand-blue"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  नरडाणा वॉर्ड / गल्ली (Ward in Nardana) *
                </label>
                <select
                  value={newWard}
                  onChange={(e) => setNewWard(e.target.value)}
                  className="w-full px-3.5 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-brand-blue bg-white"
                >
                  <option value="स्टेशन रोड, वॉर्ड १">स्टेशन रोड, वॉर्ड १</option>
                  <option value="मेन बाजारपेठ, वॉर्ड २">मेन बाजारपेठ, वॉर्ड २</option>
                  <option value="कुंभार गल्ली, वॉर्ड ३">कुंभार गल्ली, वॉर्ड ३</option>
                  <option value="हायवे चौक, वॉर्ड ४">हायवे चौक, वॉर्ड ४</option>
                  <option value="ग्रामपंचायत परिसर, वॉर्ड ५">ग्रामपंचायत परिसर, वॉर्ड ५</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  वापरकर्ता प्रकार (Role)
                </label>
                <select
                  value={newRole}
                  onChange={(e) => setNewRole(e.target.value as any)}
                  className="w-full px-3.5 py-2 rounded-xl border border-slate-200 text-xs font-semibold focus:outline-none focus:border-brand-blue bg-white"
                >
                  <option value="citizen">गावकरी नागरिक (Citizen)</option>
                  <option value="business_owner">दुकानदार / व्यावसायिक (Business Owner)</option>
                </select>
              </div>

              <div className="flex items-center justify-between pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={handleCloseAddModal}
                  className="px-4 py-2 border border-slate-300 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-50 transition"
                >
                  रद्द करा (Cancel)
                </button>
                <button
                  type="submit"
                  className="px-5 py-2 bg-brand-blue hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition shadow-md"
                >
                  नागरिक जतन करा (Save)
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
