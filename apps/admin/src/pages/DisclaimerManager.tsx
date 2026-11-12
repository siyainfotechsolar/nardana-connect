import React, { useState, useEffect } from 'react';
import { 
  Gavel, 
  Layers, 
  History, 
  ShieldCheck, 
  Plus, 
  Edit, 
  Trash2, 
  Eye, 
  Send, 
  Clock 
} from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useToast } from '../components/Toast';
import { AdminPageHeader } from '../components/AdminPageHeader';

interface DisclaimerSection {
  id: string;
  section_key: string;
  title_mr: string;
  title_en: string;
  content_mr: string;
  content_en: string;
  display_order: number;
  is_active: boolean;
  is_material: boolean;
  requires_reacceptance: boolean;
  approval_status: string;
  version: string;
  updated_at: string;
}

interface FeatureMapping {
  id: string;
  feature_id: string;
  feature_name: string;
  section_key: string;
  is_feature_active: boolean;
  disclaimer_status: string;
  disclaimer_version: string;
  requires_reacceptance: boolean;
  effective_date: string;
  admin_notes: string | null;
}

interface VersionRecord {
  id: string;
  version_number: string;
  changelog_mr: string;
  changelog_en: string;
  is_material_change: boolean;
  requires_reacceptance: boolean;
  published_by: string;
  effective_date: string;
  created_at: string;
  document_snapshot: any;
}

interface ChangeLogRecord {
  id: string;
  section_key: string;
  previous_version: string | null;
  new_version: string | null;
  change_type: string;
  reason: string | null;
  admin_id: string;
  created_at: string;
}

export const DisclaimerManager: React.FC = () => {
  const { showToast } = useToast();
  const [activeTab, setActiveTab] = useState<'sections' | 'mappings' | 'versions' | 'logs'>('sections');
  const [loading, setLoading] = useState(true);

  // Data states
  const [currentVersion, setCurrentVersion] = useState('1.0.0');
  const [effectiveDate, setEffectiveDate] = useState('2026-11-12');
  const [sections, setSections] = useState<DisclaimerSection[]>([]);
  const [mappings, setMappings] = useState<FeatureMapping[]>([]);
  const [versions, setVersions] = useState<VersionRecord[]>([]);
  const [changeLogs, setChangeLogs] = useState<ChangeLogRecord[]>([]);
  const [acceptanceCount, setAcceptanceCount] = useState(0);

  // Section Modal State
  const [isSectionModalOpen, setIsSectionModalOpen] = useState(false);
  const [editingSection, setEditingSection] = useState<DisclaimerSection | null>(null);
  const [sectionKey, setSectionKey] = useState('');
  const [titleMr, setTitleMr] = useState('');
  const [titleEn, setTitleEn] = useState('');
  const [contentMr, setContentMr] = useState('');
  const [contentEn, setContentEn] = useState('');
  const [displayOrder, setDisplayOrder] = useState(1);
  const [isMaterial, setIsMaterial] = useState(false);
  const [requiresReacceptance, setRequiresReacceptance] = useState(false);
  const [approvalStatus, setApprovalStatus] = useState('approved');
  const [savingSection, setSavingSection] = useState(false);

  // Publish Version Modal State
  const [isPublishModalOpen, setIsPublishModalOpen] = useState(false);
  const [newVersionNumber, setNewVersionNumber] = useState('1.1.0');
  const [publishChangelogMr, setPublishChangelogMr] = useState('');
  const [publishChangelogEn, setPublishChangelogEn] = useState('');
  const [publishIsMaterial, setPublishIsMaterial] = useState(false);
  const [publishRequiresReacceptance, setPublishRequiresReacceptance] = useState(false);
  const [publishing, setPublishing] = useState(false);

  useEffect(() => {
    loadAllData();
  }, []);

  const loadAllData = async () => {
    try {
      setLoading(true);
      // 1. Document
      const { data: docData } = await supabase
        .from('disclaimer_documents')
        .select('*')
        .limit(1)
        .maybeSingle();
      if (docData) {
        setCurrentVersion(docData.current_version || '1.0.0');
        setEffectiveDate(docData.effective_date || '2026-11-12');
      }

      // 2. Sections
      const { data: secData, error: secErr } = await supabase
        .from('disclaimer_sections')
        .select('*')
        .order('display_order', { ascending: true });
      if (secErr) throw secErr;
      setSections(secData || []);

      // 3. Mappings
      const { data: mapData, error: mapErr } = await supabase
        .from('disclaimer_feature_mappings')
        .select('*')
        .order('feature_name', { ascending: true });
      if (mapErr) throw mapErr;
      setMappings(mapData || []);

      // 4. Versions
      const { data: verData, error: verErr } = await supabase
        .from('disclaimer_versions')
        .select('*')
        .order('created_at', { ascending: false });
      if (verErr) throw verErr;
      setVersions(verData || []);

      // 5. Change Logs
      const { data: logData } = await supabase
        .from('disclaimer_change_logs')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(30);
      setChangeLogs(logData || []);

      // 6. Acceptance count
      const { count } = await supabase
        .from('disclaimer_acceptances')
        .select('*', { count: 'exact', head: true });
      setAcceptanceCount(count || 0);

    } catch (err: any) {
      console.error('Error loading disclaimer data:', err);
      showToast('माहिती लोड करताना त्रुटी: ' + (err.message || 'Error'), 'error');
    } finally {
      setLoading(false);
    }
  };

  // Section Modal Handlers
  const handleOpenAddSection = () => {
    setEditingSection(null);
    setSectionKey('');
    setTitleMr('');
    setTitleEn('');
    setContentMr('');
    setContentEn('');
    setDisplayOrder(sections.length + 1);
    setIsMaterial(false);
    setRequiresReacceptance(false);
    setApprovalStatus('approved');
    setIsSectionModalOpen(true);
  };

  const handleOpenEditSection = (s: DisclaimerSection) => {
    setEditingSection(s);
    setSectionKey(s.section_key);
    setTitleMr(s.title_mr);
    setTitleEn(s.title_en);
    setContentMr(s.content_mr);
    setContentEn(s.content_en);
    setDisplayOrder(s.display_order);
    setIsMaterial(s.is_material);
    setRequiresReacceptance(s.requires_reacceptance);
    setApprovalStatus(s.approval_status);
    setIsSectionModalOpen(true);
  };

  const handleSaveSection = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!sectionKey.trim() || !titleMr.trim() || !contentMr.trim()) {
      showToast('कृपया कलम की, मराठी शीर्षक आणि मजकूर भरा.', 'error');
      return;
    }

    try {
      setSavingSection(true);
      const payload = {
        section_key: sectionKey.trim().toLowerCase(),
        title_mr: titleMr.trim(),
        title_en: titleEn.trim() || titleMr.trim(),
        content_mr: contentMr.trim(),
        content_en: contentEn.trim() || contentMr.trim(),
        display_order: Number(displayOrder),
        is_material: isMaterial,
        requires_reacceptance: requiresReacceptance,
        approval_status: approvalStatus,
        version: currentVersion,
        updated_at: new Date().toISOString(),
      };

      if (editingSection) {
        const { error } = await supabase
          .from('disclaimer_sections')
          .update(payload)
          .eq('id', editingSection.id);
        if (error) throw error;

        // Log Change
        await supabase.from('disclaimer_change_logs').insert({
          section_key: payload.section_key,
          previous_version: editingSection.version,
          new_version: currentVersion,
          change_type: 'updated',
          reason: `कलम संपादन: ${payload.title_mr}`,
          admin_id: 'Admin',
          old_content_mr: editingSection.content_mr,
          new_content_mr: payload.content_mr,
          old_content_en: editingSection.content_en,
          new_content_en: payload.content_en,
        });

        showToast('अस्वीकरण कलम यशस्वीरित्या अद्ययावत केले!', 'success');
      } else {
        const { error } = await supabase
          .from('disclaimer_sections')
          .insert([payload]);
        if (error) throw error;

        // Log Change
        await supabase.from('disclaimer_change_logs').insert({
          section_key: payload.section_key,
          previous_version: null,
          new_version: currentVersion,
          change_type: 'created',
          reason: `नवीन कलम जोडले: ${payload.title_mr}`,
          admin_id: 'Admin',
        });

        showToast('नवीन अस्वीकरण कलम जोडले गेले!', 'success');
      }

      setIsSectionModalOpen(false);
      loadAllData();
    } catch (err: any) {
      console.error('Error saving section:', err);
      showToast('कलम जतन करताना त्रुटी: ' + (err.message || 'Error'), 'error');
    } finally {
      setSavingSection(false);
    }
  };

  const handleArchiveSection = async (sec: DisclaimerSection) => {
    if (!window.confirm(`खरोखर "${sec.title_mr}" हे कलम निष्क्रिय/संग्रहित करायचे आहे का?`)) return;
    try {
      await supabase
        .from('disclaimer_sections')
        .update({ is_active: !sec.is_active, approval_status: sec.is_active ? 'archived' : 'approved', updated_at: new Date().toISOString() })
        .eq('id', sec.id);

      await supabase.from('disclaimer_change_logs').insert({
        section_key: sec.section_key,
        previous_version: sec.version,
        new_version: currentVersion,
        change_type: 'archived',
        reason: `कलम स्थिती बदलली: ${sec.is_active ? 'संग्रहित' : 'सक्रिय'}`,
        admin_id: 'Admin',
      });

      showToast('कलम स्थिती बदलली.', 'success');
      loadAllData();
    } catch (err: any) {
      showToast('त्रुटी: ' + err.message, 'error');
    }
  };

  // Publish New Version Handler
  const handlePublishNewVersion = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newVersionNumber.trim() || !publishChangelogMr.trim()) {
      showToast('कृपया आवृत्ती क्रमांक आणि मराठी बदल नोंद (Changelog) भरा.', 'error');
      return;
    }

    try {
      setPublishing(true);
      // 1. Take full immutable snapshot of all currently active sections
      const activeSectionsSnapshot = sections
        .filter((s) => s.is_active)
        .map((s) => ({
          section_key: s.section_key,
          title_mr: s.title_mr,
          title_en: s.title_en,
          content_mr: s.content_mr,
          content_en: s.content_en,
          display_order: s.display_order,
          is_material: s.is_material,
          requires_reacceptance: s.requires_reacceptance,
        }));

      const snapshot = {
        title_mr: 'नरडाणा कनेक्ट - अस्वीकरण (DISCLAIMER)',
        title_en: 'NARDANA CONNECT - LEGAL DISCLAIMER',
        version: newVersionNumber.trim(),
        published_at: new Date().toISOString(),
        sections_count: activeSectionsSnapshot.length,
        sections: activeSectionsSnapshot,
      };

      // 2. Insert into disclaimer_versions
      const { error: verErr } = await supabase.from('disclaimer_versions').insert({
        version_number: newVersionNumber.trim(),
        document_snapshot: snapshot,
        changelog_mr: publishChangelogMr.trim(),
        changelog_en: publishChangelogEn.trim() || publishChangelogMr.trim(),
        is_material_change: publishIsMaterial,
        requires_reacceptance: publishRequiresReacceptance,
        published_by: 'Admin',
        effective_date: new Date().toISOString().split('T')[0],
      });
      if (verErr) throw verErr;

      // 3. Update disclaimer_documents
      await supabase
        .from('disclaimer_documents')
        .update({
          current_version: newVersionNumber.trim(),
          effective_date: new Date().toISOString().split('T')[0],
          last_published_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .neq('id', '00000000-0000-0000-0000-000000000000');

      // 4. Update section versions
      await supabase
        .from('disclaimer_sections')
        .update({ version: newVersionNumber.trim(), updated_at: new Date().toISOString() })
        .eq('is_active', true);

      // 5. Update feature mappings version
      await supabase
        .from('disclaimer_feature_mappings')
        .update({
          disclaimer_version: newVersionNumber.trim(),
          requires_reacceptance: publishRequiresReacceptance,
          effective_date: new Date().toISOString().split('T')[0],
          updated_at: new Date().toISOString(),
        })
        .eq('is_feature_active', true);

      // 6. Record Change Log
      await supabase.from('disclaimer_change_logs').insert({
        section_key: 'all',
        previous_version: currentVersion,
        new_version: newVersionNumber.trim(),
        change_type: 'published',
        reason: `नवीन आवृत्ती v${newVersionNumber.trim()} अधिकृत प्रकाशित केली. (Re-acceptance: ${publishRequiresReacceptance ? 'होय' : 'नाही'})`,
        admin_id: 'Admin',
      });

      showToast(`नवीन अस्वीकरण आवृत्ती v${newVersionNumber.trim()} यशस्वीरित्या प्रकाशित झाली!`, 'success');
      setIsPublishModalOpen(false);
      loadAllData();
    } catch (err: any) {
      console.error('Error publishing version:', err);
      showToast('प्रकाशन करताना त्रुटी: ' + (err.message || 'Error'), 'error');
    } finally {
      setPublishing(false);
    }
  };

  // Toggle Feature Active & Auto-Check Disclaimer
  const handleToggleFeatureMapping = async (m: FeatureMapping) => {
    try {
      const nextActive = !m.is_feature_active;
      // Auto-check rule: if enabling feature, check if mapping has approved disclaimer
      const mappedSection = sections.find((s) => s.section_key === m.section_key);
      const isReady = mappedSection && mappedSection.is_active && mappedSection.approval_status === 'approved';

      const nextStatus = isReady ? 'approved' : 'pending_review';

      await supabase
        .from('disclaimer_feature_mappings')
        .update({
          is_feature_active: nextActive,
          disclaimer_status: nextStatus,
          updated_at: new Date().toISOString(),
        })
        .eq('id', m.id);

      if (!isReady && nextActive) {
        showToast(`सावधान: "${m.feature_name}" सक्रिय केले आहे, परंतु संबंधित अस्वीकरण कलम पडताळणी बाकी आहे!`, 'error');
      } else {
        showToast(`"${m.feature_name}" स्थिती बदलली.`, 'success');
      }

      loadAllData();
    } catch (err: any) {
      showToast('त्रुटी: ' + err.message, 'error');
    }
  };

  const pendingReviewCount = mappings.filter(
    (m) => m.is_feature_active && m.disclaimer_status !== 'approved'
  ).length;

  return (
    <div className="space-y-6">
      <AdminPageHeader
        title="कायदेशीर अस्वीकरण व्यवस्थापन (Dynamic Disclaimer Management)"
        subtitle="केवळ नरडाणा गाव (पिन: ४२५४०४) • १४ कलमे, स्वयंचलित आवृत्ती नियंत्रण व नागरिक स्वीकृती ट्रॅकिंग"
        actions={
          <div className="flex items-center space-x-2">
            <button
              onClick={() => {
                const parts = currentVersion.split('.').map(Number);
                const nextPatch = `${parts[0] || 1}.${(parts[1] || 0) + 1}.0`;
                setNewVersionNumber(nextPatch);
                setPublishChangelogMr('');
                setPublishChangelogEn('');
                setPublishIsMaterial(false);
                setPublishRequiresReacceptance(false);
                setIsPublishModalOpen(true);
              }}
              className="flex items-center space-x-2 bg-emerald-600 hover:bg-emerald-700 text-white px-3.5 py-2 rounded-lg text-xs font-semibold shadow-sm transition"
            >
              <Send className="w-4 h-4" />
              <span>नवीन आवृत्ती प्रकाशित करा (Publish)</span>
            </button>
            <button
              onClick={handleOpenAddSection}
              className="flex items-center space-x-2 bg-brand-blue hover:bg-brand-blue/90 text-white px-3.5 py-2 rounded-lg text-xs font-semibold shadow-sm transition"
            >
              <Plus className="w-4 h-4" />
              <span>नवीन कलम जोडा</span>
            </button>
          </div>
        }
      />

      {/* Metrics Row */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <p className="text-xs text-slate-500 font-medium">सध्याची अधिकृत आवृत्ती</p>
          <div className="flex items-center space-x-2 mt-1">
            <span className="text-2xl font-bold text-brand-blue">v{currentVersion}</span>
            <span className="text-[10px] bg-blue-50 text-brand-blue font-bold px-2 py-0.5 rounded-full border border-blue-200">
              Live
            </span>
          </div>
          <p className="text-[11px] text-slate-400 mt-0.5">प्रभावी: {effectiveDate}</p>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <p className="text-xs text-slate-500 font-medium">सक्रिय कलमे (Sections)</p>
          <p className="text-2xl font-bold text-slate-800 mt-1">
            {sections.filter((s) => s.is_active).length} / {sections.length}
          </p>
          <p className="text-[11px] text-slate-400 mt-0.5">मराठी व English द्वैभाषिक</p>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <p className="text-xs text-slate-500 font-medium">मॅप केलेले फीचर्स</p>
          <p className="text-2xl font-bold text-slate-800 mt-1">{mappings.length} फीचर्स</p>
          {pendingReviewCount > 0 ? (
            <p className="text-[11px] text-amber-600 font-bold mt-0.5">
              ⚠️ {pendingReviewCount} फीचर पुनरावलोकन बाकी
            </p>
          ) : (
            <p className="text-[11px] text-emerald-600 font-semibold mt-0.5">
              ✓ सर्व फीचर्स सुरक्षितपणे जोडलेले
            </p>
          )}
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <p className="text-xs text-slate-500 font-medium">नागरिक स्वीकृती नोंदी (Acceptances)</p>
          <p className="text-2xl font-bold text-emerald-700 mt-1">{acceptanceCount}</p>
          <p className="text-[11px] text-slate-400 mt-0.5">डिजिटल पडताळणीकृत</p>
        </div>
      </div>

      {/* Tabs */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="flex border-b border-slate-200 bg-slate-50/70 px-4">
          <button
            onClick={() => setActiveTab('sections')}
            className={`py-3 px-4 text-xs font-bold border-b-2 transition flex items-center space-x-2 ${
              activeTab === 'sections'
                ? 'border-brand-blue text-brand-blue bg-white shadow-sm'
                : 'border-transparent text-slate-500 hover:text-slate-800'
            }`}
          >
            <Gavel className="w-4 h-4" />
            <span>अस्वीकरण कलमे ({sections.length})</span>
          </button>

          <button
            onClick={() => setActiveTab('mappings')}
            className={`py-3 px-4 text-xs font-bold border-b-2 transition flex items-center space-x-2 ${
              activeTab === 'mappings'
                ? 'border-brand-blue text-brand-blue bg-white shadow-sm'
                : 'border-transparent text-slate-500 hover:text-slate-800'
            }`}
          >
            <Layers className="w-4 h-4" />
            <span>फीचर-टू-अस्वीकरण मॅपिंग ({mappings.length})</span>
            {pendingReviewCount > 0 && (
              <span className="w-2 h-2 rounded-full bg-amber-500 animate-pulse" />
            )}
          </button>

          <button
            onClick={() => setActiveTab('versions')}
            className={`py-3 px-4 text-xs font-bold border-b-2 transition flex items-center space-x-2 ${
              activeTab === 'versions'
                ? 'border-brand-blue text-brand-blue bg-white shadow-sm'
                : 'border-transparent text-slate-500 hover:text-slate-800'
            }`}
          >
            <History className="w-4 h-4" />
            <span>आवृत्ती इतिहास व स्नॅपशॉट ({versions.length})</span>
          </button>

          <button
            onClick={() => setActiveTab('logs')}
            className={`py-3 px-4 text-xs font-bold border-b-2 transition flex items-center space-x-2 ${
              activeTab === 'logs'
                ? 'border-brand-blue text-brand-blue bg-white shadow-sm'
                : 'border-transparent text-slate-500 hover:text-slate-800'
            }`}
          >
            <Clock className="w-4 h-4" />
            <span>बदल लॉग व ऑडिट (Audit Logs)</span>
          </button>
        </div>

        {/* Tab 1: Sections Management */}
        {activeTab === 'sections' && (
          <div className="p-4">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-50 text-slate-600 font-semibold border-b border-slate-200">
                  <tr>
                    <th className="py-2.5 px-3 w-12">क्र.</th>
                    <th className="py-2.5 px-3">कलम शीर्षक (मराठी व English)</th>
                    <th className="py-2.5 px-3">की (Key)</th>
                    <th className="py-2.5 px-3">मजकूर पूर्वावलोकन</th>
                    <th className="py-2.5 px-3">महत्त्व (Material)</th>
                    <th className="py-2.5 px-3">स्थिती</th>
                    <th className="py-2.5 px-3 text-right">कृती</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {loading ? (
                    <tr>
                      <td colSpan={7} className="text-center py-8 text-slate-400">
                        लोड होत आहे...
                      </td>
                    </tr>
                  ) : (
                    sections.map((s) => (
                      <tr key={s.id} className="hover:bg-slate-50/70 transition">
                        <td className="py-3 px-3 font-bold text-slate-500">{s.display_order}</td>
                        <td className="py-3 px-3">
                          <p className="font-bold text-slate-900">{s.title_mr}</p>
                          <p className="text-[11px] text-slate-500">{s.title_en}</p>
                        </td>
                        <td className="py-3 px-3 font-mono text-[11px] text-slate-600">
                          {s.section_key}
                        </td>
                        <td className="py-3 px-3 max-w-xs">
                          <p className="text-slate-700 line-clamp-2 leading-relaxed">
                            {s.content_mr}
                          </p>
                        </td>
                        <td className="py-3 px-3">
                          {s.is_material ? (
                            <span className="inline-block px-2 py-0.5 rounded text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-200">
                              महत्त्वाचे (Material)
                            </span>
                          ) : (
                            <span className="inline-block px-2 py-0.5 rounded text-[10px] text-slate-400">
                              सामान्य
                            </span>
                          )}
                        </td>
                        <td className="py-3 px-3">
                          <span
                            className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold ${
                              s.is_active
                                ? 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                                : 'bg-slate-100 text-slate-500'
                            }`}
                          >
                            {s.is_active ? '● सक्रिय' : '○ संग्रहित'}
                          </span>
                        </td>
                        <td className="py-3 px-3 text-right">
                          <div className="flex items-center justify-end space-x-1.5">
                            <button
                              onClick={() => handleOpenEditSection(s)}
                              className="p-1.5 text-slate-600 hover:bg-slate-100 rounded"
                              title="संपादन करा"
                            >
                              <Edit className="w-3.5 h-3.5" />
                            </button>
                            <button
                              onClick={() => handleArchiveSection(s)}
                              className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded"
                              title={s.is_active ? 'संग्रहित करा' : 'पुन्हा सक्रिय करा'}
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
        )}

        {/* Tab 2: Feature Mappings */}
        {activeTab === 'mappings' && (
          <div className="p-4 space-y-3">
            <div className="bg-blue-50/70 border border-blue-200 rounded-xl p-3 text-xs text-blue-900 flex items-start space-x-2">
              <ShieldCheck className="w-4 h-4 text-brand-blue flex-shrink-0 mt-0.5" />
              <div>
                <p className="font-bold">स्वयंचलित कायदेशीर संरक्षण प्रणाली (Automated Legal Protection):</p>
                <p className="mt-0.5 text-blue-800">
                  कोणतेही नवीन फीचर (उदा. बस वेळापत्रक, वाहन भाडे, खरेदी-विक्री) सुरू करण्यापूर्वी त्याचे अधिकृत अस्वीकरण कलम मंजूर असणे अनिवार्य आहे. कलम नसल्यास सिस्टीम आपोआप सावध करते.
                </p>
              </div>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-50 text-slate-600 font-semibold border-b border-slate-200">
                  <tr>
                    <th className="py-2.5 px-3">फीचर नाव (Feature Name)</th>
                    <th className="py-2.5 px-3">जोडलेले अस्वीकरण कलम (Mapped Section)</th>
                    <th className="py-2.5 px-3">पुनर्स्वीकृती आवश्यक?</th>
                    <th className="py-2.5 px-3">अस्वीकरण स्थिती</th>
                    <th className="py-2.5 px-3">फीचर स्थिती</th>
                    <th className="py-2.5 px-3 text-right">कृती</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {mappings.map((m) => {
                    const sec = sections.find((s) => s.section_key === m.section_key);
                    return (
                      <tr key={m.id} className="hover:bg-slate-50/70 transition">
                        <td className="py-3 px-3">
                          <p className="font-bold text-slate-900">{m.feature_name}</p>
                          <p className="text-[10.5px] font-mono text-slate-400">{m.feature_id}</p>
                        </td>
                        <td className="py-3 px-3">
                          {sec ? (
                            <div>
                              <p className="font-semibold text-brand-blue">{sec.title_mr}</p>
                              <p className="text-[11px] text-slate-500 font-mono">{m.section_key}</p>
                            </div>
                          ) : (
                            <span className="text-rose-600 font-bold">⚠️ कलम सापडले नाही</span>
                          )}
                        </td>
                        <td className="py-3 px-3">
                          {m.requires_reacceptance ? (
                            <span className="inline-block px-2 py-0.5 rounded text-[10px] font-bold bg-amber-50 text-amber-800 border border-amber-200">
                              होय (Re-acceptance Required)
                            </span>
                          ) : (
                            <span className="text-slate-400 text-[11px]">नाही</span>
                          )}
                        </td>
                        <td className="py-3 px-3">
                          <span
                            className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold ${
                              m.disclaimer_status === 'approved'
                                ? 'bg-emerald-50 text-emerald-700'
                                : 'bg-amber-50 text-amber-700'
                            }`}
                          >
                            {m.disclaimer_status === 'approved' ? '✓ मंजूर' : '⚠️ पुनरावलोकन प्रलंबित'}
                          </span>
                        </td>
                        <td className="py-3 px-3">
                          <span
                            className={`inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold ${
                              m.is_feature_active
                                ? 'bg-blue-50 text-brand-blue'
                                : 'bg-slate-100 text-slate-500'
                            }`}
                          >
                            {m.is_feature_active ? 'सक्रिय' : 'बंद'}
                          </span>
                        </td>
                        <td className="py-3 px-3 text-right">
                          <button
                            onClick={() => handleToggleFeatureMapping(m)}
                            className="px-2.5 py-1 text-[11px] font-semibold border border-slate-200 hover:bg-slate-100 rounded"
                          >
                            {m.is_feature_active ? 'बंद करा' : 'सुरू करा'}
                          </button>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* Tab 3: Versions History & Immutable Snapshots */}
        {activeTab === 'versions' && (
          <div className="p-4 space-y-4">
            <div className="space-y-3">
              {versions.map((ver) => (
                <div
                  key={ver.id}
                  className="p-4 rounded-xl border border-slate-200 hover:border-brand-blue/30 transition bg-white"
                >
                  <div className="flex flex-col md:flex-row md:items-center justify-between gap-2 border-b border-slate-100 pb-3">
                    <div className="flex items-center space-x-3">
                      <span className="bg-brand-blue text-white text-xs font-bold px-2.5 py-1 rounded-lg">
                        v{ver.version_number}
                      </span>
                      <span className="text-xs text-slate-500 font-medium">
                        प्रभावी दिनांक: {ver.effective_date}
                      </span>
                      {ver.is_material_change && (
                        <span className="text-[10px] bg-amber-50 text-amber-800 font-bold px-2 py-0.5 rounded border border-amber-200">
                          महत्त्वाचा बदल (Material Change)
                        </span>
                      )}
                      {ver.requires_reacceptance && (
                        <span className="text-[10px] bg-rose-50 text-rose-700 font-bold px-2 py-0.5 rounded border border-rose-200">
                          नागरिक पुनर्स्वीकृती आवश्यक
                        </span>
                      )}
                    </div>
                    <p className="text-[11px] text-slate-400">
                      प्रकाशित: {new Date(ver.created_at).toLocaleString('mr-IN')}
                    </p>
                  </div>

                  <div className="mt-3 grid grid-cols-1 md:grid-cols-2 gap-3 text-xs">
                    <div>
                      <p className="font-semibold text-slate-700 mb-0.5">बदल नोंद (मराठी):</p>
                      <p className="text-slate-600 bg-slate-50 p-2 rounded-lg border border-slate-100">
                        {ver.changelog_mr}
                      </p>
                    </div>
                    <div>
                      <p className="font-semibold text-slate-700 mb-0.5">Changelog (English):</p>
                      <p className="text-slate-600 bg-slate-50 p-2 rounded-lg border border-slate-100">
                        {ver.changelog_en}
                      </p>
                    </div>
                  </div>

                  <div className="mt-3 flex items-center justify-between text-[11px] text-slate-500 pt-2 border-t border-slate-100">
                    <span>स्नॅपशॉट कलमे: {ver.document_snapshot?.sections_count || '14'} कलमे संग्रहित</span>
                    <button
                      onClick={() => {
                        alert(JSON.stringify(ver.document_snapshot, null, 2));
                      }}
                      className="text-brand-blue hover:underline flex items-center space-x-1 font-semibold"
                    >
                      <Eye className="w-3.5 h-3.5" />
                      <span>पूर्ण स्नॅपशॉट JSON पहा</span>
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Tab 4: Change Logs & Audit */}
        {activeTab === 'logs' && (
          <div className="p-4">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-50 text-slate-600 font-semibold border-b border-slate-200">
                  <tr>
                    <th className="py-2.5 px-3">वेळ (Timestamp)</th>
                    <th className="py-2.5 px-3">कलम की</th>
                    <th className="py-2.5 px-3">कृती प्रकार</th>
                    <th className="py-2.5 px-3">आवृत्ती बदल</th>
                    <th className="py-2.5 px-3">तपशील व कारण</th>
                    <th className="py-2.5 px-3">ॲडमिन</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {changeLogs.map((log) => (
                    <tr key={log.id} className="hover:bg-slate-50/70 transition">
                      <td className="py-2.5 px-3 font-mono text-[11px] text-slate-500">
                        {new Date(log.created_at).toLocaleString('mr-IN')}
                      </td>
                      <td className="py-2.5 px-3 font-mono font-semibold text-slate-700">
                        {log.section_key}
                      </td>
                      <td className="py-2.5 px-3">
                        <span className="inline-block px-2 py-0.5 rounded text-[10px] font-bold bg-slate-100 text-slate-700 uppercase">
                          {log.change_type}
                        </span>
                      </td>
                      <td className="py-2.5 px-3 font-mono text-[11px]">
                        {log.previous_version ? `v${log.previous_version} → ` : ''}
                        <span className="font-bold text-brand-blue">v{log.new_version || '1.0.0'}</span>
                      </td>
                      <td className="py-2.5 px-3 text-slate-700 max-w-sm truncate">
                        {log.reason || 'बदल जतन केला.'}
                      </td>
                      <td className="py-2.5 px-3 text-slate-500 font-medium">
                        {log.admin_id}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>

      {/* Add / Edit Section Modal */}
      {isSectionModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto shadow-2xl">
            <div className="p-5 border-b border-slate-100 flex items-center justify-between sticky top-0 bg-white">
              <h3 className="font-bold text-base text-slate-900">
                {editingSection ? 'अस्वीकरण कलम संपादन' : 'नवीन अस्वीकरण कलम जोडा'}
              </h3>
              <button
                onClick={() => setIsSectionModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleSaveSection} className="p-6 space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    कलम की (Section Key / Slug) *
                  </label>
                  <input
                    type="text"
                    required
                    disabled={!!editingSection}
                    value={sectionKey}
                    onChange={(e) => setSectionKey(e.target.value)}
                    placeholder="उदा. bus_timetable"
                    className="w-full text-xs font-mono border border-slate-200 rounded-lg p-2.5 focus:outline-none focus:ring-1 focus:ring-brand-blue disabled:bg-slate-100"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    अनुक्रम क्रमांक (Display Order)
                  </label>
                  <input
                    type="number"
                    value={displayOrder}
                    onChange={(e) => setDisplayOrder(Number(e.target.value))}
                    className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    मराठी शीर्षक (Marathi Title) *
                  </label>
                  <input
                    type="text"
                    required
                    value={titleMr}
                    onChange={(e) => setTitleMr(e.target.value)}
                    placeholder="उदा. २. माहितीची अचूकता"
                    className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">
                    English Title
                  </label>
                  <input
                    type="text"
                    value={titleEn}
                    onChange={(e) => setTitleEn(e.target.value)}
                    placeholder="e.g. 2. Accuracy of Information"
                    className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  मराठी कायदेशीर मजकूर (Marathi Legal Content) *
                </label>
                <textarea
                  required
                  rows={4}
                  value={contentMr}
                  onChange={(e) => setContentMr(e.target.value)}
                  placeholder="अस्वीकरण कलमाचा अधिकृत मजकूर..."
                  className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none leading-relaxed"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  English Legal Content
                </label>
                <textarea
                  rows={4}
                  value={contentEn}
                  onChange={(e) => setContentEn(e.target.value)}
                  placeholder="English legal text for this section..."
                  className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none leading-relaxed"
                />
              </div>

              <div className="pt-2 border-t border-slate-100 flex flex-col space-y-2">
                <label className="flex items-center space-x-2 text-xs font-semibold text-slate-700 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={isMaterial}
                    onChange={(e) => setIsMaterial(e.target.checked)}
                    className="rounded text-brand-blue"
                  />
                  <span>हा महत्त्वाचा बदल आहे (Material Section - Citizens must take special note)</span>
                </label>

                <label className="flex items-center space-x-2 text-xs font-semibold text-slate-700 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={requiresReacceptance}
                    onChange={(e) => setRequiresReacceptance(e.target.checked)}
                    className="rounded text-brand-blue"
                  />
                  <span>नागरिकांकडून अनिवार्य पुनर्स्वीकृती आवश्यक करा (Require Re-acceptance)</span>
                </label>
              </div>

              <div className="pt-4 border-t border-slate-100 flex items-center justify-end space-x-2">
                <button
                  type="button"
                  onClick={() => setIsSectionModalOpen(false)}
                  className="px-4 py-2 rounded-lg border border-slate-200 text-xs font-semibold text-slate-600 hover:bg-slate-50"
                >
                  रद्द करा
                </button>
                <button
                  type="submit"
                  disabled={savingSection}
                  className="px-5 py-2 rounded-lg bg-brand-blue hover:bg-brand-blue/90 text-white text-xs font-semibold shadow-sm"
                >
                  {savingSection ? 'जतन होत आहे...' : editingSection ? 'अपडेट करा' : 'कलम जोडा'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Publish Version Modal */}
      {isPublishModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-white rounded-2xl w-full max-w-xl max-h-[90vh] overflow-y-auto shadow-2xl">
            <div className="p-5 border-b border-slate-100 flex items-center justify-between sticky top-0 bg-white">
              <h3 className="font-bold text-base text-slate-900">
                नवीन अस्वीकरण आवृत्ती प्रकाशन (Publish Legal Version)
              </h3>
              <button
                onClick={() => setIsPublishModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handlePublishNewVersion} className="p-6 space-y-4">
              <div className="bg-amber-50 border border-amber-200 rounded-xl p-3 text-xs text-amber-900">
                <p className="font-bold">कायदेशीर सूचना (Legal Notice):</p>
                <p className="mt-0.5 text-amber-800">
                  प्रकाशन केल्यावर सध्याच्या सर्व सक्रिय {sections.filter((s) => s.is_active).length} कलमांचा अपरिवर्तनीय स्नॅपशॉट डेटाबेसमध्ये कायमस्वरूपी सेव्ह होईल. जुन्या आवृत्त्या कधीही खोडल्या जाणार नाहीत.
                </p>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  नवीन आवृत्ती क्रमांक (Version Number) *
                </label>
                <input
                  type="text"
                  required
                  value={newVersionNumber}
                  onChange={(e) => setNewVersionNumber(e.target.value)}
                  placeholder="उदा. 1.1.0"
                  className="w-full text-xs font-mono font-bold border border-slate-200 rounded-lg p-2.5 focus:outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  बदल नोंद (मराठी Changelog) *
                </label>
                <textarea
                  required
                  rows={3}
                  value={publishChangelogMr}
                  onChange={(e) => setPublishChangelogMr(e.target.value)}
                  placeholder="उदा. गाडी भाड्याने व चालक डिरेक्टरीसाठी नवीन कायदेशीर अटी समाविष्ट केल्या..."
                  className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Changelog (English)
                </label>
                <textarea
                  rows={2}
                  value={publishChangelogEn}
                  onChange={(e) => setPublishChangelogEn(e.target.value)}
                  placeholder="e.g. Added legal terms for vehicle rental and driver directory..."
                  className="w-full text-xs border border-slate-200 rounded-lg p-2.5 focus:outline-none"
                />
              </div>

              <div className="pt-2 border-t border-slate-100 space-y-2">
                <label className="flex items-center space-x-2 text-xs font-semibold text-slate-700 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={publishIsMaterial}
                    onChange={(e) => setPublishIsMaterial(e.target.checked)}
                    className="rounded text-brand-blue"
                  />
                  <span>हा महत्त्वाचा बदल (Material Change) आहे</span>
                </label>

                <label className="flex items-center space-x-2 text-xs font-semibold text-slate-700 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={publishRequiresReacceptance}
                    onChange={(e) => setPublishRequiresReacceptance(e.target.checked)}
                    className="rounded text-brand-blue"
                  />
                  <span>नागरिकांकडून पुन्हा स्वीकृती अनिवार्य करा (Block affected features until accepted)</span>
                </label>
              </div>

              <div className="pt-4 border-t border-slate-100 flex items-center justify-end space-x-2">
                <button
                  type="button"
                  onClick={() => setIsPublishModalOpen(false)}
                  className="px-4 py-2 rounded-lg border border-slate-200 text-xs font-semibold text-slate-600 hover:bg-slate-50"
                >
                  रद्द करा
                </button>
                <button
                  type="submit"
                  disabled={publishing}
                  className="px-5 py-2 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold shadow-sm flex items-center space-x-1"
                >
                  <Send className="w-3.5 h-3.5" />
                  <span>{publishing ? 'प्रकाशन होत आहे...' : 'अधिकृत प्रकाशित करा'}</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
export default DisclaimerManager;
