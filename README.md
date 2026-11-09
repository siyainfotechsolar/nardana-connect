# NARDANA CONNECT (नरडाणा कनेक्ट)
### Complete Village Community Platform
**Tagline**: *आपलं गाव, आपली डिजिटल ओळख!*  
**Coverage**: Nardana + Surrounding Villages (Waghadi, Hol, Betawad, Chimthane, Vardi, Shindkheda)  
**Region**: Taluka Shindkheda, District Dhule, Maharashtra, India  
**Citizen Access**: 100% Free

---

## 📌 Project Overview
Nardana Connect is an independent village community application designed to serve citizens, local shops, service providers, and Gram Panchayat administration. 

> [!IMPORTANT]
> **Strict Community Guidelines**: This project does not contain any CRM, sales tracking, solar enquiries, lead management, or business promotion modules.

---

## 🏛️ Architecture & Modules
- **`apps/mobile`**: Flutter Latest Stable Android Citizen Application (Material 3, Riverpod, GoRouter, Supabase Flutter, Dual Language: Marathi & English).
- **`apps/admin`**: React 19 + TypeScript + Vite + Tailwind CSS Web Admin Dashboard (Vercel-ready).
- **`supabase/migrations`**: PostgreSQL database migrations with Row Level Security (RLS) enabled on all tables.
- **`supabase/seed`**: Initial village directory, categorized services, and emergency contacts.
- **`docs/`**: Setup, Architecture, and Verification testing documentation.

---

## 📱 Features (Phase 1 Citizen App)
1. **Bilingual Support**: Marathi-first with instant toggle to English.
2. **Village Switcher**: Select between Nardana, Waghadi, Hol, Betawad, Chimthane, Vardi, and Shindkheda.
3. **Emergency Quick Dial**: 1-tap call to Police (112), Ambulance (108), MSEDCL Electricity (1912), Gram Panchayat, and Snake Rescuers.
4. **Local Services Directory**: Direct phone and WhatsApp contact with verified electricians, plumbers, grocery shops, medical stores, tractors on rent, CSC centers, and mechanics.
5. **Village Notices & Alerts**: Official Gram Panchayat notices, water supply schedules, and scheduled power outage updates.
6. **Jobs & Employment**: Community employment vacancies with direct employer contact.
7. **Buy & Sell Marketplace**: Local village buy & sell board without intermediaries.
8. **Public Access**: Complete browsing experience with no mandatory login required.

---

## 🚀 Getting Started

### 1. Web Admin Panel
```bash
cd apps/admin
npm install
npm run dev
npm run build
```

### 2. Flutter Mobile Application
```bash
cd apps/mobile
flutter pub get
flutter test
flutter run
```

### 3. Supabase Backend
- Schema Migration: `supabase/migrations/20261109000000_initial_community_schema.sql`
- Seed Data: `supabase/seed/seed.sql`
- Live Project: `zrnukpkufwrexrvysmpw` (Active & Healthy)
