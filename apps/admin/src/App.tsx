import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Layout } from './components/Layout';
import { Dashboard } from './pages/Dashboard';
import { Villages } from './pages/Villages';
import { Categories } from './pages/Categories';
import { Businesses } from './pages/Businesses';
import { Jobs } from './pages/Jobs';
import { Marketplace } from './pages/Marketplace';
import { Notices } from './pages/Notices';
import { Settings } from './pages/Settings';

const queryClient = new QueryClient();

export const App: React.FC = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Layout />}>
            <Route index element={<Dashboard />} />
            <Route path="villages" element={<Villages />} />
            <Route path="categories" element={<Categories />} />
            <Route path="businesses" element={<Businesses />} />
            <Route path="jobs" element={<Jobs />} />
            <Route path="marketplace" element={<Marketplace />} />
            <Route path="notices" element={<Notices />} />
            <Route path="settings" element={<Settings />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  );
};

export default App;

