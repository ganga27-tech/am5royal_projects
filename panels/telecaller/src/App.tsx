// ============================================================================
// AM5 ROYAL • Telecaller Operations Application Router
// Configures Protected Routes, Browser Routing, and Context Providers
// ============================================================================

import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './auth/AuthContext';
import { ProtectedRoute } from './auth/ProtectedRoute';

import { LoginPage } from './pages/LoginPage';
import { DashboardPage } from './pages/DashboardPage';
import { VendorOnboardPage } from './pages/onboarding/VendorOnboardPage';
import { SelectCategoryPage } from './pages/onboarding/SelectCategoryPage';
import { SelectServicesPage } from './pages/onboarding/SelectServicesPage';

export const App: React.FC = () => {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          {/* Public Auth Route */}
          <Route path="/login" element={<LoginPage />} />

          {/* Protected Telecaller Dashboard Routes */}
          <Route
            path="/"
            element={
              <ProtectedRoute>
                <DashboardPage />
              </ProtectedRoute>
            }
          />

          {/* Protected 3-Step Vendor Onboarding Flow */}
          <Route
            path="/onboard"
            element={
              <ProtectedRoute>
                <VendorOnboardPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/onboard/categories"
            element={
              <ProtectedRoute>
                <SelectCategoryPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/onboard/services"
            element={
              <ProtectedRoute>
                <SelectServicesPage />
              </ProtectedRoute>
            }
          />

          {/* Fallback */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
};
