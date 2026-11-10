import React, { useState, useEffect } from 'react';
import { 
  Smartphone, 
  DownloadCloud, 
  AlertTriangle, 
  RotateCw, 
  Save, 
  Send, 
  History, 
  Eye, 
  Layers, 
  Sparkles 
} from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useToast } from '../components/Toast';
import { AppUpdateHistory } from '../types/database';

export const AppUpdate: React.FC = () => {
  const { showToast } = useToast();
  const [history, setHistory] = useState<AppUpdateHistory[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [publishing, setPublishing] = useState(false);
  const [previewTab, setPreviewTab] = useState<'force' | 'optional' | 'maintenance'>('force');

  // Form State
  const [latestVersion, setLatestVersion] = useState('1.0.0');
  const [latestBuild, setLatestBuild] = useState(1);
  const [minVersion, setMinVersion] = useState('1.0.0');
  const [minBuild, setMinBuild] = useState(1);
  const [forceUpdateEnabled, setForceUpdateEnabled] = useState(false);
  const [optionalUpdateEnabled, setOptionalUpdateEnabled] = useState(true);
  const [maintenanceMode, setMaintenanceMode] = useState(false);

  const [titleMr, setTitleMr] = useState('');
  const [titleEn, setTitleEn] = useState('');
  const [messageMr, setMessageMr] = useState('');
  const [messageEn, setMessageEn] = useState('');
  const [notesMr, setNotesMr] = useState('');
  const [notesEn, setNotesEn] = useState('');
  const [maintMr, setMaintMr] = useState('');
  const [maintEn, setMaintEn] = useState('');

  const [playStoreUrl, setPlayStoreUrl] = useState('');
  const [apkDownloadUrl, setApkDownloadUrl] = useState('');

  useEffect(() => {
    fetchUpdateConfig();
    fetchHistory();
  }, []);

  const fetchUpdateConfig = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('app_update_config')
        .select('*')
        .eq('platform', 'android')
        .single();

      if (error && error.code !== 'PGRST116') {
        console.error('Error fetching config:', error);
      } else if (data) {
        setLatestVersion(data.latest_version);
        setLatestBuild(data.latest_build_number);
        setMinVersion(data.minimum_supported_version);
        setMinBuild(data.minimum_supported_build);
        setForceUpdateEnabled(data.force_update_enabled);
        setOptionalUpdateEnabled(data.optional_update_enabled);
        setMaintenanceMode(data.maintenance_mode);

        setTitleMr(data.update_title_mr || '');
        setTitleEn(data.update_title_en || '');
        setMessageMr(data.update_message_mr || '');
        setMessageEn(data.update_message_en || '');
        setNotesMr(data.release_notes_mr || '');
        setNotesEn(data.release_notes_en || '');
        setMaintMr(data.maintenance_message_mr || '');
        setMaintEn(data.maintenance_message_en || '');

        setPlayStoreUrl(data.play_store_url || '');
        setApkDownloadUrl(data.apk_download_url || '');
      }
    } catch (err: any) {
      showToast('कॉन्फिगरेशन लोड करताना त्रुटी: ' + err.message, 'error');
    } finally {
      setLoading(false);
    }
  };

  const fetchHistory = async () => {
    try {
      const { data, error } = await supabase
        .from('app_update_history')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(10);

      if (!error && data) {
        setHistory(data);
      }
    } catch (err) {
      console.error('Failed to load update history:', err);
    }
  };

  const handleSaveDraft = async () => {
    try {
      setSaving(true);
      const payload = {
        platform: 'android',
        latest_version: latestVersion.trim(),
        latest_build_number: Number(latestBuild),
        minimum_supported_version: minVersion.trim(),
        minimum_supported_build: Number(minBuild),
        force_update_enabled: forceUpdateEnabled,
        optional_update_enabled: optionalUpdateEnabled,
        maintenance_mode: maintenanceMode,
        update_title_mr: titleMr.trim(),
        update_title_en: titleEn.trim(),
        update_message_mr: messageMr.trim(),
        update_message_en: messageEn.trim(),
        release_notes_mr: notesMr.trim(),
        release_notes_en: notesEn.trim(),
        maintenance_message_mr: maintMr.trim(),
        maintenance_message_en: maintEn.trim(),
        play_store_url: playStoreUrl.trim(),
        apk_download_url: apkDownloadUrl.trim(),
        updated_at: new Date().toISOString(),
      };

      const { error } = await supabase
        .from('app_update_config')
        .upsert(payload, { onConflict: 'platform' });

      if (error) throw error;
      showToast('अपडेट मसुदा यशस्वीरीत्या जतन झाला.', 'success');
      fetchUpdateConfig();
    } catch (err: any) {
      showToast('मसुदा जतन करताना त्रुटी: ' + err.message, 'error');
    } finally {
      setSaving(false);
    }
  };

  const handlePublishUpdate = async () => {
    if (!window.confirm('तुम्हाला हे अपडेट धोरण सर्व Android वापरकर्त्यांसाठी लाईव्ह प्रकाशित करायचे आहे का?')) {
      return;
    }

    try {
      setPublishing(true);
      const payload = {
        platform: 'android',
        latest_version: latestVersion.trim(),
        latest_build_number: Number(latestBuild),
        minimum_supported_version: minVersion.trim(),
        minimum_supported_build: Number(minBuild),
        force_update_enabled: forceUpdateEnabled,
        optional_update_enabled: optionalUpdateEnabled,
        maintenance_mode: maintenanceMode,
        update_title_mr: titleMr.trim(),
        update_title_en: titleEn.trim(),
        update_message_mr: messageMr.trim(),
        update_message_en: messageEn.trim(),
        release_notes_mr: notesMr.trim(),
        release_notes_en: notesEn.trim(),
        maintenance_message_mr: maintMr.trim(),
        maintenance_message_en: maintEn.trim(),
        play_store_url: playStoreUrl.trim(),
        apk_download_url: apkDownloadUrl.trim(),
        updated_at: new Date().toISOString(),
      };

      const { data: updatedConfig, error: configError } = await supabase
        .from('app_update_config')
        .upsert(payload, { onConflict: 'platform' })
        .select()
        .single();

      if (configError) throw configError;

      // Log into update history
      const historyLog = {
        config_id: updatedConfig.id,
        platform: 'android',
        latest_version: latestVersion.trim(),
        latest_build_number: Number(latestBuild),
        minimum_supported_version: minVersion.trim(),
        minimum_supported_build: Number(minBuild),
        force_update_enabled: forceUpdateEnabled,
        optional_update_enabled: optionalUpdateEnabled,
        maintenance_mode: maintenanceMode,
        change_summary: notesMr.trim() || 'नवीन आवृत्ती धोरण प्रकाशित केले',
        updated_by: 'Nardana Super Admin',
      };

      await supabase.from('app_update_history').insert(historyLog);

      showToast('🚀 नवीन ॲप अपडेट धोरण त्वरित लाईव्ह प्रकाशित करण्यात आले आहे!', 'success');
      fetchUpdateConfig();
      fetchHistory();
    } catch (err: any) {
      showToast('प्रकाशन करताना त्रुटी: ' + err.message, 'error');
    } finally {
      setPublishing(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <div className="flex items-center space-x-3 text-brand-blue">
          <RotateCw className="w-6 h-6 animate-spin" />
          <span className="font-semibold">अपडेट धोरण लोड होत आहे...</span>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div className="flex items-start space-x-4">
          <div className="p-3 bg-brand-blue/10 text-brand-blue rounded-xl">
            <Smartphone className="w-8 h-8" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-xl font-black text-slate-800">ॲप आवृत्ती आणि सक्तीचे अपडेट व्यवस्थापन</h2>
              <span className="px-2.5 py-0.5 rounded-full text-xs font-bold bg-blue-50 text-brand-blue border border-blue-200">
                Android Centralized Policy
              </span>
            </div>
            <p className="text-xs text-slate-500 mt-1">
              नरडाणा कनेक्ट (NARDANA CONNECT) Android ॲपच्या आवृत्तीचे नियम, सक्तीचे अपडेट आणि मेंटेनन्स मोड येथून नियंत्रित करा.
            </p>
          </div>
        </div>

        <div className="flex items-center space-x-3">
          <button
            onClick={handleSaveDraft}
            disabled={saving || publishing}
            className="flex items-center space-x-2 px-4 py-2.5 rounded-xl border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 font-bold text-xs transition shadow-sm"
          >
            <Save className="w-4 h-4 text-slate-500" />
            <span>{saving ? 'जतन होत आहे...' : 'मसुदा सेव्ह करा'}</span>
          </button>

          <button
            onClick={handlePublishUpdate}
            disabled={saving || publishing}
            className="flex items-center space-x-2 px-5 py-2.5 rounded-xl bg-brand-blue hover:bg-blue-700 text-white font-bold text-xs transition shadow-md"
          >
            <Send className="w-4 h-4" />
            <span>{publishing ? 'प्रकाशित होत आहे...' : 'अपडेट धोरण प्रसिद्ध करा'}</span>
          </button>
        </div>
      </div>

      {/* Main Grid: Settings vs Live Simulator */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left Form: Configuration */}
        <div className="lg:col-span-7 space-y-6">
          {/* Status Indicators & Toggles */}
          <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
            <h3 className="text-sm font-bold text-slate-800 flex items-center gap-2 border-b border-slate-100 pb-3">
              <Layers className="w-4 h-4 text-brand-blue" />
              <span>अपडेट नियंत्रण स्विच (Update Triggers)</span>
            </h3>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              {/* Force Update Toggle */}
              <div className={`p-4 rounded-xl border transition cursor-pointer ${
                forceUpdateEnabled ? 'bg-red-50 border-red-200' : 'bg-slate-50 border-slate-200'
              }`} onClick={() => setForceUpdateEnabled(!forceUpdateEnabled)}>
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold text-slate-700">सक्तीचे अपडेट (Force Update)</span>
                  <input
                    type="checkbox"
                    checked={forceUpdateEnabled}
                    onChange={(e) => setForceUpdateEnabled(e.target.checked)}
                    className="w-4 h-4 text-red-600 rounded"
                  />
                </div>
                <p className="text-[11px] text-slate-500 mt-1 leading-snug">
                  किमान व्हर्जनखालील ॲप्सना ब्लॉक करून नवीन व्हर्जन घेणे बंधनकारक करेल.
                </p>
              </div>

              {/* Optional Update Toggle */}
              <div className={`p-4 rounded-xl border transition cursor-pointer ${
                optionalUpdateEnabled ? 'bg-emerald-50 border-emerald-200' : 'bg-slate-50 border-slate-200'
              }`} onClick={() => setOptionalUpdateEnabled(!optionalUpdateEnabled)}>
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold text-slate-700">पर्यायी अपडेट (Optional)</span>
                  <input
                    type="checkbox"
                    checked={optionalUpdateEnabled}
                    onChange={(e) => setOptionalUpdateEnabled(e.target.checked)}
                    className="w-4 h-4 text-emerald-600 rounded"
                  />
                </div>
                <p className="text-[11px] text-slate-500 mt-1 leading-snug">
                  नवीन व्हर्जन उपलब्ध असल्यास नागरिकांना पॉपअप सूचना दाखवेल (Later पर्याय उपलब्ध).
                </p>
              </div>

              {/* Maintenance Mode Toggle */}
              <div className={`p-4 rounded-xl border transition cursor-pointer ${
                maintenanceMode ? 'bg-amber-50 border-amber-300' : 'bg-slate-50 border-slate-200'
              }`} onClick={() => setMaintenanceMode(!maintenanceMode)}>
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold text-slate-700">मेंटेनन्स मोड (Maintenance)</span>
                  <input
                    type="checkbox"
                    checked={maintenanceMode}
                    onChange={(e) => setMaintenanceMode(e.target.checked)}
                    className="w-4 h-4 text-amber-600 rounded"
                  />
                </div>
                <p className="text-[11px] text-slate-500 mt-1 leading-snug">
                  सर्व ॲप तात्पुरते लॉक करून दुरुस्ती चालू असल्याचा फलक दाखवेल.
                </p>
              </div>
            </div>
          </div>

          {/* Versions and Builds */}
          <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
            <h3 className="text-sm font-bold text-slate-800 flex items-center gap-2 border-b border-slate-100 pb-3">
              <Smartphone className="w-4 h-4 text-brand-green" />
              <span>व्हर्जन आणि बिल्ड नंबर (Semantic Versioning)</span>
            </h3>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  नवीनतम व्हर्जन (Latest Version)
                </label>
                <input
                  type="text"
                  value={latestVersion}
                  onChange={(e) => setLatestVersion(e.target.value)}
                  placeholder="उदा. 1.0.1"
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-xs font-bold text-slate-800 focus:outline-none focus:border-brand-blue"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  नवीनतम बिल्ड (Latest Build Number)
                </label>
                <input
                  type="number"
                  value={latestBuild}
                  onChange={(e) => setLatestBuild(Number(e.target.value))}
                  placeholder="उदा. 2"
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-xs font-bold text-slate-800 focus:outline-none focus:border-brand-blue"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  किमान आवश्यक व्हर्जन (Minimum Supported Version)
                </label>
                <input
                  type="text"
                  value={minVersion}
                  onChange={(e) => setMinVersion(e.target.value)}
                  placeholder="उदा. 1.0.0"
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-xs font-bold text-slate-800 focus:outline-none focus:border-brand-blue"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  किमान आवश्यक बिल्ड (Minimum Supported Build)
                </label>
                <input
                  type="number"
                  value={minBuild}
                  onChange={(e) => setMinBuild(Number(e.target.value))}
                  placeholder="उदा. 1"
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-xs font-bold text-slate-800 focus:outline-none focus:border-brand-blue"
                />
              </div>
            </div>
          </div>

          {/* Multilingual Titles & Messages */}
          <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
            <h3 className="text-sm font-bold text-slate-800 flex items-center gap-2 border-b border-slate-100 pb-3">
              <Sparkles className="w-4 h-4 text-brand-yellow" />
              <span>अपडेट शीर्षक व संदेश (Marathi &amp; English)</span>
            </h3>

            <div className="space-y-3">
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  मराठी अपडेट शीर्षक (Title - Marathi)
                </label>
                <input
                  type="text"
                  value={titleMr}
                  onChange={(e) => setTitleMr(e.target.value)}
                  placeholder="उदा. नरडाणा कनेक्टचे नवीन अपडेट उपलब्ध आहे!"
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-xs text-slate-800 focus:outline-none focus:border-brand-blue"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  मराठी संदेश (Message - Marathi)
                </label>
                <textarea
                  rows={2}
                  value={messageMr}
                  onChange={(e) => setMessageMr(e.target.value)}
                  placeholder="कृपया चांगल्या अनुभवासाठी ॲप अपडेट करा..."
                  className="w-full px-3.5 py-2 rounded-xl border border-slate-200 text-xs text-slate-800 focus:outline-none focus:border-brand-blue"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  मराठी नवीन वैशिष्ट्ये / बदल (Release Notes - Marathi)
                </label>
                <textarea
                  rows={3}
                  value={notesMr}
                  onChange={(e) => setNotesMr(e.target.value)}
                  placeholder="• जाहिरात व्यवस्थापन मॉड्यूल जोडले&#10;• ग्लोबल बॅक बटण सुरक्षितता सुधारली"
                  className="w-full px-3.5 py-2 rounded-xl border border-slate-200 text-xs text-slate-800 font-mono focus:outline-none focus:border-brand-blue"
                />
              </div>

              <div className="pt-2 border-t border-slate-100">
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  English Title &amp; Release Notes (Optional)
                </label>
                <input
                  type="text"
                  value={titleEn}
                  onChange={(e) => setTitleEn(e.target.value)}
                  placeholder="e.g. New Nardana Connect Update Available"
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-xs text-slate-800 focus:outline-none focus:border-brand-blue mb-2"
                />
                <textarea
                  rows={2}
                  value={notesEn}
                  onChange={(e) => setNotesEn(e.target.value)}
                  placeholder="e.g. Performance optimizations and Android back gesture fixes."
                  className="w-full px-3.5 py-2 rounded-xl border border-slate-200 text-xs text-slate-800 font-mono focus:outline-none focus:border-brand-blue"
                />
              </div>
            </div>
          </div>

          {/* Maintenance Message */}
          <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
            <h3 className="text-sm font-bold text-slate-800 flex items-center gap-2 border-b border-slate-100 pb-3">
              <AlertTriangle className="w-4 h-4 text-amber-500" />
              <span>मेंटेनन्स मोड संदेश (Maintenance Message)</span>
            </h3>

            <div>
              <label className="block text-xs font-bold text-slate-700 mb-1">
                मराठी मेंटेनन्स संदेश
              </label>
              <textarea
                rows={2}
                value={maintMr}
                onChange={(e) => setMaintMr(e.target.value)}
                placeholder="नरडाणा कनेक्ट सर्व्हरवर देखभाल काम सुरू आहे. कृपया काही वेळाने पुन्हा प्रयत्न करा."
                className="w-full px-3.5 py-2 rounded-xl border border-slate-200 text-xs text-slate-800 focus:outline-none focus:border-brand-blue"
              />
            </div>
          </div>

          {/* Distribution URLs */}
          <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
            <h3 className="text-sm font-bold text-slate-800 flex items-center gap-2 border-b border-slate-100 pb-3">
              <DownloadCloud className="w-4 h-4 text-brand-blue" />
              <span>डाऊनलोड लिंक्स (Distribution URLs)</span>
            </h3>

            <div className="space-y-3">
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  Google Play Store URL
                </label>
                <input
                  type="url"
                  value={playStoreUrl}
                  onChange={(e) => setPlayStoreUrl(e.target.value)}
                  placeholder="https://play.google.com/store/apps/details?id=in.nardana.connect"
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-xs font-mono text-slate-800 focus:outline-none focus:border-brand-blue"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  अधिकृत थेट APK डाऊनलोड URL (Direct APK Link)
                </label>
                <input
                  type="url"
                  value={apkDownloadUrl}
                  onChange={(e) => setApkDownloadUrl(e.target.value)}
                  placeholder="https://github.com/siya-infotech/nardana-connect/releases/download/v1.0.0/app-release.apk"
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-xs font-mono text-slate-800 focus:outline-none focus:border-brand-blue"
                />
              </div>
            </div>
          </div>
        </div>

        {/* Right Preview: Live Smartphone Simulator */}
        <div className="lg:col-span-5 space-y-6">
          <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm sticky top-20">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3 mb-4">
              <div className="flex items-center gap-2">
                <Eye className="w-4 h-4 text-brand-blue" />
                <h3 className="text-sm font-bold text-slate-800">थेट मोबाईल स्क्रीन प्रिव्ह्यू (Live Preview)</h3>
              </div>
            </div>

            {/* Preview Mode Selector */}
            <div className="flex bg-slate-100 p-1 rounded-xl mb-4 text-xs font-bold">
              <button
                onClick={() => setPreviewTab('force')}
                className={`flex-1 py-1.5 rounded-lg transition ${
                  previewTab === 'force' ? 'bg-white text-red-600 shadow-sm' : 'text-slate-600'
                }`}
              >
                सक्तीचे अपडेट
              </button>
              <button
                onClick={() => setPreviewTab('optional')}
                className={`flex-1 py-1.5 rounded-lg transition ${
                  previewTab === 'optional' ? 'bg-white text-emerald-700 shadow-sm' : 'text-slate-600'
                }`}
              >
                पर्यायी संवाद
              </button>
              <button
                onClick={() => setPreviewTab('maintenance')}
                className={`flex-1 py-1.5 rounded-lg transition ${
                  previewTab === 'maintenance' ? 'bg-white text-amber-700 shadow-sm' : 'text-slate-600'
                }`}
              >
                मेंटेनन्स
              </button>
            </div>

            {/* Simulated Phone Mockup */}
            <div className="w-full max-w-[320px] mx-auto bg-slate-900 rounded-[36px] p-3 shadow-2xl border-4 border-slate-800">
              {/* Screen Notch */}
              <div className="w-24 h-4 bg-slate-800 rounded-full mx-auto mb-2"></div>

              {/* Simulated Screen Body */}
              <div className="bg-white rounded-[26px] h-[520px] overflow-hidden flex flex-col justify-between p-4 relative select-none">
                {previewTab === 'force' && (
                  <div className="flex flex-col items-center justify-center h-full text-center space-y-3">
                    <div className="w-16 h-16 rounded-2xl bg-brand-blue flex items-center justify-center text-white font-black text-2xl shadow-md">
                      NC
                    </div>

                    <h4 className="text-base font-black text-slate-800 leading-tight">
                      {titleMr || 'ॲप अपडेट करणे आवश्यक आहे!'}
                    </h4>

                    <span className="text-[11px] font-bold text-brand-blue">
                      नरडाणा कनेक्ट (Nardana Connect)
                    </span>

                    {/* Version Badge */}
                    <div className="bg-slate-50 border border-slate-200 rounded-lg px-3 py-2 text-left w-full space-y-1">
                      <div className="flex justify-between text-[11px]">
                        <span className="text-slate-500">तुमची आवृत्ती:</span>
                        <span className="font-bold text-red-600">v1.0.0 (1)</span>
                      </div>
                      <div className="flex justify-between text-[11px]">
                        <span className="text-slate-500">आवश्यक आवृत्ती:</span>
                        <span className="font-bold text-emerald-600">v{latestVersion} ({latestBuild})</span>
                      </div>
                    </div>

                    <p className="text-[11px] text-slate-600 leading-relaxed max-h-16 overflow-y-auto">
                      {messageMr || 'नवीन तांत्रिक बदल व सुरक्षेसाठी हे अपडेट घेणे अनिवार्य आहे.'}
                    </p>

                    {notesMr && (
                      <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-200 text-left w-full text-[10px] text-slate-600 font-mono">
                        <p className="font-bold text-slate-800 mb-1">नवीन वैशिष्ट्ये:</p>
                        <p className="whitespace-pre-line">{notesMr}</p>
                      </div>
                    )}

                    <div className="w-full pt-2">
                      <button className="w-full py-2.5 bg-brand-blue text-white rounded-xl font-bold text-xs shadow-md">
                        आता अपडेट करा (Update Now)
                      </button>
                      <p className="text-[10px] text-slate-400 mt-1">
                        सक्तीचे अपडेट: मागे जाता येणार नाही.
                      </p>
                    </div>
                  </div>
                )}

                {previewTab === 'optional' && (
                  <div className="flex flex-col items-center justify-center h-full">
                    {/* Simulated Background */}
                    <div className="w-full bg-slate-100 rounded-xl p-3 mb-4 text-center opacity-60">
                      <p className="text-xs font-bold text-slate-400">नरडाणा कनेक्ट मुख्य स्क्रीन</p>
                    </div>

                    {/* Dialog Card */}
                    <div className="bg-white border-2 border-emerald-200 rounded-2xl p-4 shadow-xl w-full text-center space-y-3">
                      <div className="w-10 h-10 bg-emerald-100 text-emerald-700 rounded-full flex items-center justify-center mx-auto">
                        <Sparkles className="w-5 h-5" />
                      </div>

                      <h4 className="text-sm font-bold text-slate-800">
                        {titleMr || 'नवीन अपडेट उपलब्ध आहे'}
                      </h4>

                      <p className="text-[11px] text-slate-600">
                        {messageMr || 'नरडाणा कनेक्टचे नवीन व्हर्जन उपलब्ध आहे. आपण आता अपडेट करू शकता.'}
                      </p>

                      <div className="flex gap-2 pt-1">
                        <button className="flex-1 py-1.5 border border-slate-300 rounded-lg text-slate-600 font-bold text-xs">
                          नंतर (Later)
                        </button>
                        <button className="flex-1 py-1.5 bg-brand-green text-white rounded-lg font-bold text-xs">
                          अपडेट करा
                        </button>
                      </div>
                    </div>
                  </div>
                )}

                {previewTab === 'maintenance' && (
                  <div className="flex flex-col items-center justify-center h-full text-center space-y-4">
                    <div className="w-14 h-14 bg-amber-100 text-amber-600 rounded-full flex items-center justify-center mx-auto">
                      <AlertTriangle className="w-7 h-7" />
                    </div>

                    <h4 className="text-base font-bold text-slate-800">
                      सिस्टीम देखभाल सुरू आहे
                    </h4>

                    <p className="text-xs text-slate-600 leading-relaxed">
                      {maintMr || 'नरडाणा कनेक्ट सर्व्हरवर देखभाल काम सुरू आहे. कृपया काही वेळाने पुन्हा प्रयत्न करा.'}
                    </p>

                    <button className="px-4 py-2 border border-slate-300 rounded-xl text-xs font-bold text-slate-700 flex items-center gap-1.5 mx-auto">
                      <RotateCw className="w-3.5 h-3.5" />
                      <span>पुन्हा तपासा</span>
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Audit History Log */}
      <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
        <h3 className="text-sm font-bold text-slate-800 flex items-center gap-2 border-b border-slate-100 pb-3">
          <History className="w-4 h-4 text-brand-blue" />
          <span>अपडेट इतिहास आणि ऑडिट लॉग (Update Release History)</span>
        </h3>

        {history.length === 0 ? (
          <p className="text-xs text-slate-500 py-4 text-center">अद्याप कोणताही अपडेट इतिहास नोंदवलेला नाही.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50 text-slate-600 border-b border-slate-200">
                <tr>
                  <th className="py-2.5 px-3">दिनांक व वेळ</th>
                  <th className="py-2.5 px-3">व्हर्जन (Build)</th>
                  <th className="py-2.5 px-3">किमान व्हर्जन</th>
                  <th className="py-2.5 px-3">सक्तीचे अपडेट?</th>
                  <th className="py-2.5 px-3">मेंटेनन्स?</th>
                  <th className="py-2.5 px-3">प्रशासक</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {history.map((h) => (
                  <tr key={h.id} className="hover:bg-slate-50">
                    <td className="py-2.5 px-3 text-slate-500 font-mono">
                      {new Date(h.created_at).toLocaleString('mr-IN')}
                    </td>
                    <td className="py-2.5 px-3 font-bold text-brand-blue">
                      v{h.latest_version} ({h.latest_build_number})
                    </td>
                    <td className="py-2.5 px-3 text-slate-700 font-semibold">
                      v{h.minimum_supported_version}
                    </td>
                    <td className="py-2.5 px-3">
                      {h.force_update_enabled ? (
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-red-100 text-red-700">होय (Force)</span>
                      ) : (
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-slate-100 text-slate-600">नाही</span>
                      )}
                    </td>
                    <td className="py-2.5 px-3">
                      {h.maintenance_mode ? (
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-amber-100 text-amber-700">सक्रिय</span>
                      ) : (
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-slate-100 text-slate-600">बंद</span>
                      )}
                    </td>
                    <td className="py-2.5 px-3 text-slate-600 font-medium">
                      {h.updated_by}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
};
