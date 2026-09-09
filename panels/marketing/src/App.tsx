import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { MarketingLayout } from './components/layout/MarketingLayout';
import { Login } from './pages/Login';
import { Dashboard } from './pages/Dashboard';
import { SeoPage } from './pages/SeoPage';
import { BacklinksPage } from './pages/BacklinksPage';
import { BlogsPage } from './pages/BlogsPage';
import { ArticlesPage } from './pages/ArticlesPage';
import { SmmPage } from './pages/SmmPage';
import { GoogleAdsPage } from './pages/GoogleAdsPage';
import { AnalyticsPage } from './pages/AnalyticsPage';
import { LeadsPage } from './pages/LeadsPage';
import { StrategiesPage } from './pages/StrategiesPage';
import { ContentCreationsPage } from './pages/ContentCreationsPage';

// Protected Route Guard
const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-slate-950">
        <div className="w-12 h-12 border-4 border-amber-500/20 border-t-amber-500 rounded-full animate-spin"></div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return <>{children}</>;
};

// Public Route Guard (redirect to / if already logged in)
const PublicRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-slate-950">
        <div className="w-12 h-12 border-4 border-amber-500/20 border-t-amber-500 rounded-full animate-spin"></div>
      </div>
    );
  }

  if (isAuthenticated) {
    return <Navigate to="/" replace />;
  }

  return <>{children}</>;
};

export const App: React.FC = () => {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          {/* Public Login Route */}
          <Route
            path="/login"
            element={
              <PublicRoute>
                <Login />
              </PublicRoute>
            }
          />

          {/* Protected Marketing Panel Routes */}
          <Route
            path="/"
            element={
              <ProtectedRoute>
                <MarketingLayout />
              </ProtectedRoute>
            }
          >
            <Route index element={<Dashboard />} />
            <Route path="seo" element={<SeoPage />} />
            <Route path="backlinks" element={<BacklinksPage />} />
            <Route path="blogs" element={<BlogsPage />} />
            <Route path="articles" element={<ArticlesPage />} />
            <Route path="smm" element={<SmmPage />} />
            <Route path="google-ads" element={<GoogleAdsPage />} />
            <Route path="analytics" element={<AnalyticsPage />} />
            <Route path="leads" element={<LeadsPage />} />
            <Route path="strategies" element={<StrategiesPage />} />
            <Route path="content-creations" element={<ContentCreationsPage />} />
          </Route>

          {/* Fallback */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
};

export default App;
