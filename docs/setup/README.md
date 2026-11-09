# NARDANA CONNECT: Setup & Installation Guide

## Prerequisites
- **Node.js**: v20+ / v26+
- **Flutter SDK**: 3.24+ / 3.41+
- **Supabase CLI / Project**: Active project with URL and Anon key
- **Git**

## 1. Environment Configuration
Copy `.env.example` to `.env` in root or project folders:
```bash
cp .env.example .env
```
Ensure `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` are configured.

## 2. Web Admin Panel (`apps/admin`)
```bash
cd apps/admin
npm install
npm run dev      # Local development server at http://localhost:3000
npm run build    # Compiles production SPA bundle to dist/
```

### Vercel Deployment Settings:
- **Framework Preset**: Vite
- **Root Directory**: `apps/admin`
- **Build Command**: `npm run build`
- **Output Directory**: `dist`
- **Environment Variables**:
  - `VITE_SUPABASE_URL`: Your Supabase Project URL
  - `VITE_SUPABASE_ANON_KEY`: Your Supabase Public Anon Key

## 3. Flutter Mobile App (`apps/mobile`)
```bash
cd apps/mobile
flutter pub get
flutter run          # Runs in debug mode on connected device or Chrome
flutter build apk    # Builds production Android APK
```

## 4. Supabase Database Migrations
Migrations are stored in `supabase/migrations/`:
- `20261109000000_initial_community_schema.sql`: Contains tables, RLS policies, indexes, and triggers.
- `supabase/seed/seed.sql`: Contains Nardana & nearby village data, categorized local services, and emergency contacts.

