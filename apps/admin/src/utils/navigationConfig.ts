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
    titleMr: 'स्थानिक व्यवसाय व सेवा',
    titleEn: 'Local Businesses & Services',
    parentPath: '/',
    breadcrumbLabel: 'व्यवसाय व सेवा',
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
    breadcrumbLabel: 'नागरिक व वापरकर्ते',
  },
  '/election': {
    titleMr: 'ग्रामपंचायत निवडणूक व उमेदवार',
    titleEn: 'Elections & Candidates',
    parentPath: '/',
    breadcrumbLabel: 'निवडणूक व उमेदवार',
  },
  '/reports': {
    titleMr: 'ग्राम अहवाल व आकडेवारी',
    titleEn: 'Village Analytics & Reports',
    parentPath: '/',
    breadcrumbLabel: 'अहवाल व आकडेवारी',
  },
  '/app-update': {
    titleMr: 'ॲप आवृत्ती आणि सक्तीचे अपडेट',
    titleEn: 'App Update Management',
    parentPath: '/settings',
    breadcrumbLabel: 'ॲप अपडेट',
  },
  '/settings': {
    titleMr: 'सिस्टीम सेटिंग्ज व तातडीचे संपर्क',
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

