export interface RouteMeta {
  titleMr: string;
  titleEn: string;
  parentPath: string;
  breadcrumbLabel: string;
}

export const ADMIN_ROUTES: Record<string, RouteMeta> = {
  '/': {
    titleMr: 'डॅशबोर्ड',
    titleEn: 'Dashboard',
    parentPath: '/',
    breadcrumbLabel: 'डॅशबोर्ड',
  },
  '/villages': {
    titleMr: 'गाव माहिती व रूपरेषा',
    titleEn: 'Village Profile',
    parentPath: '/',
    breadcrumbLabel: 'गाव माहिती',
  },
  '/categories': {
    titleMr: 'कॅटेगरी व्यवस्थापन',
    titleEn: 'Category Management',
    parentPath: '/',
    breadcrumbLabel: 'कॅटेगरी',
  },
  '/businesses': {
    titleMr: 'स्थानिक व्यवसाय व्यवस्थापन',
    titleEn: 'Local Businesses',
    parentPath: '/',
    breadcrumbLabel: 'व्यवसाय',
  },
  '/services': {
    titleMr: 'स्थानिक सेवा व्यवस्थापन',
    titleEn: 'Local Services',
    parentPath: '/',
    breadcrumbLabel: 'सेवा',
  },
  '/jobs': {
    titleMr: 'स्थानिक रोजगार व नोकऱ्या',
    titleEn: 'Jobs & Employment',
    parentPath: '/',
    breadcrumbLabel: 'रोजगार',
  },
  '/marketplace': {
    titleMr: 'स्थानिक खरेदी - विक्री बाजारपेठ',
    titleEn: 'Buy & Sell Marketplace',
    parentPath: '/',
    breadcrumbLabel: 'बाजारपेठ',
  },
  '/notices': {
    titleMr: 'गाव व ग्रामपंचायत अधिकृत सूचना',
    titleEn: 'Gram Panchayat Notices',
    parentPath: '/',
    breadcrumbLabel: 'गाव सूचना',
  },
  '/emergency-contacts': {
    titleMr: 'तातडीचे व आपत्कालीन क्रमांक',
    titleEn: 'Emergency Helplines',
    parentPath: '/',
    breadcrumbLabel: 'तातडीचे संपर्क',
  },
  '/advertisements': {
    titleMr: 'जाहिरात व्यवस्थापन',
    titleEn: 'Advertisement Management',
    parentPath: '/',
    breadcrumbLabel: 'जाहिराती',
  },
  '/users': {
    titleMr: 'नागरिक व वापरकर्ते निर्देशिका',
    titleEn: 'Citizens & Users Directory',
    parentPath: '/',
    breadcrumbLabel: 'नागरिक',
  },
  '/election': {
    titleMr: 'ग्रामपंचायत निवडणूक व उमेदवार',
    titleEn: 'Elections & Candidates',
    parentPath: '/',
    breadcrumbLabel: 'निवडणूक व्यवस्थापन',
  },
  '/complaints': {
    titleMr: 'नागरिक तक्रार निवारण',
    titleEn: 'Complaints & Grievances',
    parentPath: '/',
    breadcrumbLabel: 'तक्रार निवारण',
  },
  '/reviews': {
    titleMr: 'नागरिक अभिप्राय व रेटिंग',
    titleEn: 'Reviews & Feedback',
    parentPath: '/',
    breadcrumbLabel: 'अभिप्राय',
  },
  '/notifications': {
    titleMr: 'पुश नोटिफिकेशन्स व्यवस्थापन',
    titleEn: 'Push Notifications',
    parentPath: '/',
    breadcrumbLabel: 'नोटिफिकेशन्स',
  },
  '/home-layout': {
    titleMr: 'होम स्क्रीन रचना व क्रम नियंत्रण',
    titleEn: 'Home Layout Configuration',
    parentPath: '/',
    breadcrumbLabel: 'होम लेआउट',
  },
  '/reports': {
    titleMr: 'ग्राम अहवाल व आकडेवारी',
    titleEn: 'Village Analytics & Reports',
    parentPath: '/',
    breadcrumbLabel: 'अहवाल',
  },
  '/audit-logs': {
    titleMr: 'प्रशासकीय सुरक्षा ऑडिट लॉग',
    titleEn: 'Security Audit Logs',
    parentPath: '/',
    breadcrumbLabel: 'ऑडिट लॉग',
  },
  '/app-update': {
    titleMr: 'ॲप आवृत्ती आणि सक्तीचे अपडेट',
    titleEn: 'App Update Management',
    parentPath: '/settings',
    breadcrumbLabel: 'ॲप अपडेट',
  },
  '/settings': {
    titleMr: 'प्लॅटफॉर्म सेटिंग्ज व संरचना',
    titleEn: 'System Settings',
    parentPath: '/',
    breadcrumbLabel: 'सेटिंग्ज',
  },
};

/**
 * Returns safe back navigation route.
 * Never redirects out of Admin panel.
 */
export function getSafeBackRoute(currentPath: string, stateFrom?: string): string {
  // If state.from was provided and is an internal admin route (starts with /), prioritize it
  if (stateFrom && stateFrom.startsWith('/') && stateFrom !== currentPath) {
    return stateFrom;
  }

  // Exact match in route table
  const meta = ADMIN_ROUTES[currentPath];
  if (meta && meta.parentPath && meta.parentPath !== currentPath) {
    return meta.parentPath;
  }

  // Handle nested/subroutes like /users/:id or /reports/:id
  const parts = currentPath.split('/').filter(Boolean);
  if (parts.length > 1) {
    return '/' + parts[0];
  }

  // Default fallback is admin dashboard
  return '/';
}

/**
 * Generates breadcrumb list for current path
 */
export function getAdminBreadcrumbs(currentPath: string): { label: string; path: string }[] {
  const crumbs: { label: string; path: string }[] = [{ label: 'डॅशबोर्ड', path: '/' }];

  if (currentPath === '/') return crumbs;

  const parts = currentPath.split('/').filter(Boolean);
  let accumulated = '';

  for (let i = 0; i < parts.length; i++) {
    accumulated += '/' + parts[i];
    const meta = ADMIN_ROUTES[accumulated];
    if (meta) {
      crumbs.push({ label: meta.breadcrumbLabel, path: accumulated });
    } else {
      // Dynamic param (e.g. ID)
      crumbs.push({ label: 'तपशील (' + parts[i] + ')', path: accumulated });
    }
  }

  return crumbs;
}

