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
import { Jobs } from './pages/Jobs';
import { Marketplace } from './pages/Marketplace';
import { Notices } from './pages/Notices';
import { Advertisements } from './pages/Advertisements';
import { Users } from './pages/Users';
import { Election } from './pages/Election';
import { Reports } from './pages/Reports';
import { AppUpdate } from './pages/AppUpdate';
import { Settings } from './pages/Settings';

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
                <Route path="categories" element={<Categories />} />
                <Route path="businesses" element={<Businesses />} />
                <Route path="jobs" element={<Jobs />} />
                <Route path="marketplace" element={<Marketplace />} />
                <Route path="notices" element={<Notices />} />
                <Route path="advertisements" element={<Advertisements />} />
                <Route path="users" element={<Users />} />
                <Route path="election" element={<Election />} />
                <Route path="reports" element={<Reports />} />
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
