# NARDANA CONNECT: System Architecture

## Overview
**Nardana Connect** is an independent, free village community platform built specifically for Nardana and surrounding villages in Shindkheda Taluka, Dhule District, Maharashtra, India.

Tagline: **आपलं गाव, आपली डिजिटल ओळख!**

## Core Principles
1. **Community First**: Focus solely on local village services, shops, emergency information, notices, local jobs, and peer-to-peer buy/sell.
2. **Zero Business Intrusion**: Strictly no CRM, no sales management, no solar enquiries, no lead tracking, and no commercial business promotion.
3. **Frictionless Citizen Access**: Citizens can browse all approved services, emergency contacts, notices, and listings freely without mandatory login. Authentication via mobile OTP is only required when posting content.

## Monorepo Layout
```
nardana-connect/
  apps/
    mobile/       # Flutter Android Citizen Application (Material 3, Riverpod, GoRouter)
    admin/        # React + TypeScript + Vite + Tailwind CSS Web Admin Dashboard
  supabase/
    migrations/   # Versioned PostgreSQL schema migrations with Row Level Security
    seed/         # Initial village, category, and emergency contact seed data
    functions/    # Supabase Edge Functions for push notifications & moderation
  docs/
    setup/        # Installation & deployment guides
    architecture/ # Architectural specification & data models
    testing/      # Test verification reports
  assets/         # App icons, logos, and banners
```

## Technology Stack
- **Mobile**: Flutter 3.41+ / Dart 3.11+, Material 3, Riverpod state management, GoRouter, Supabase Flutter SDK, shared_preferences, url_launcher.
- **Admin**: React 19, TypeScript, Vite, Tailwind CSS, TanStack Query, Supabase JS SDK, Lucide Icons, Recharts.
- **Backend & Database**: Supabase PostgreSQL with Row Level Security (RLS) on all tables, Supabase Auth (Phone OTP/Email), Supabase Storage.
- **Hosting & CI/CD**: Vercel for Web Admin Panel SPA, GitHub for source version control.

