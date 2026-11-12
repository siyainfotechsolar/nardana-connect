import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ToastProvider } from './components/Toast';
import { AuthProvider } from './context/AuthContext';
import { ProtectedRoute } from './components/ProtectedRoute';
import { Layout } from './components/Layout';

// Pages
import { Login } from './pages/Login';
import { Dashboard } from './pages/Dashboard';
import { Villages } from './pages/Villages';
import { Categories } from './pages/Categories';
import { Businesses } from './pages/Businesses';
import { Services } from './pages/Services';
import { Jobs } from './pages/Jobs';
import { Marketplace } from './pages/Marketplace';
import { Notices } from './pages/Notices';
import { EmergencyContacts } from './pages/EmergencyContacts';
import { Advertisements } from './pages/Advertisements';
import { Users } from './pages/Users';
import { Election } from './pages/Election';
import { Complaints } from './pages/Complaints';
import { Reviews } from './pages/Reviews';
import { Notifications } from './pages/Notifications';
import { HomeLayout } from './pages/HomeLayout';
import { Settings } from './pages/Settings';
import { AppUpdate } from './pages/AppUpdate';
import { Reports } from './pages/Reports';
import { AuditLogs } from './pages/AuditLogs';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      staleTime: 1000 * 60 * 5,
    },
  },
});

export const App: React.FC = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <ToastProvider>
          <BrowserRouter>
            <Routes>
              {/* Public Admin Login Route */}
              <Route path="/login" element={<Login />} />

              {/* Protected Admin Routes */}
              <Route
                path="/"
                element={
                  <ProtectedRoute>
                    <Layout />
                  </ProtectedRoute>
                }
              >
                <Route index element={<Dashboard />} />
                <Route path="villages" element={<Villages />} />
                <Route path="users" element={<Users />} />
                <Route path="categories" element={<Categories />} />
                <Route path="businesses" element={<Businesses />} />
                <Route path="services" element={<Services />} />
                <Route path="jobs" element={<Jobs />} />
                <Route path="marketplace" element={<Marketplace />} />
                <Route path="notices" element={<Notices />} />
                <Route path="emergency-contacts" element={<EmergencyContacts />} />
                <Route path="advertisements" element={<Advertisements />} />
                <Route path="election" element={<Election />} />
                <Route path="complaints" element={<Complaints />} />
                <Route path="reviews" element={<Reviews />} />
                <Route path="notifications" element={<Notifications />} />
                <Route path="home-layout" element={<HomeLayout />} />
                <Route path="reports" element={<Reports />} />
                <Route path="audit-logs" element={<AuditLogs />} />
                <Route path="app-update" element={<AppUpdate />} />
                <Route path="settings" element={<Settings />} />
              </Route>

              {/* Safe catch-all redirect to Admin Dashboard */}
              <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
          </BrowserRouter>
        </ToastProvider>
      </AuthProvider>
    </QueryClientProvider>
  );
};

export default App;
