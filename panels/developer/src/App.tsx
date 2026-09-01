import React from 'react';
import { BrowserRouter, Routes, Route, Navigate, Outlet } from 'react-router-dom';
import { AuthProvider, useAuth } from './auth/AuthContext';
import { DashboardLayout } from './layouts/DashboardLayout';

// Pages
import { LoginPage } from './pages/LoginPage';
import { KanbanBoardPage } from './pages/KanbanBoardPage';
import { GlobalDashboardPage } from './pages/GlobalDashboardPage';
import { DeveloperDashboardPage } from './pages/DeveloperDashboardPage';
import { QADashboardPage } from './pages/QADashboardPage';
import { BugsListPage } from './pages/BugsListPage';
import { BugDetailPage } from './pages/BugDetailPage';
import { ProjectsPage } from './pages/ProjectsPage';
import { ProjectDetailPage } from './pages/ProjectDetailPage';
import { ModulesPage } from './pages/ModulesPage';
import { ApisPage } from './pages/ApisPage';
import { TasksPage } from './pages/TasksPage';
import { DevelopersPage } from './pages/DevelopersPage';
import { DeploymentsPage } from './pages/DeploymentsPage';
import { AnalyticsPage } from './pages/AnalyticsPage';
import { DatabasePage } from './pages/DatabasePage';
import { SecurityPage } from './pages/SecurityPage';
import { AuditLogsPage } from './pages/AuditLogsPage';
import { SettingsPage } from './pages/SettingsPage';

// Protected Route Guard
const ProtectedRoute: React.FC = () => {
  const { user, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div className="min-h-screen bg-[#080B12] flex items-center justify-center">
        <div className="text-xs font-mono text-[#22D3EE] animate-pulse">
        </div>
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  return <DashboardLayout />;
};

export const App: React.FC = () => {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          {/* Public Authentication Route */}
          <Route path="/login" element={<LoginPage />} />

          {/* Authenticated Dashboard Routes */}
          <Route element={<ProtectedRoute />}>
            <Route path="/board" element={<KanbanBoardPage />} />
            <Route path="/" element={<GlobalDashboardPage />} />
            <Route path="/developer-dashboard" element={<DeveloperDashboardPage />} />
            <Route path="/qa-dashboard" element={<QADashboardPage />} />
            <Route path="/bugs" element={<BugsListPage />} />
            <Route path="/bugs/:bugId" element={<BugDetailPage />} />
            <Route path="/projects" element={<ProjectsPage />} />
            <Route path="/projects/:projectId" element={<ProjectDetailPage />} />
            <Route path="/modules" element={<ModulesPage />} />
            <Route path="/apis" element={<ApisPage />} />
            <Route path="/tasks" element={<TasksPage />} />
            <Route path="/team" element={<DevelopersPage />} />
            <Route path="/deployments" element={<DeploymentsPage />} />
            <Route path="/analytics" element={<AnalyticsPage />} />
            <Route path="/database" element={<DatabasePage />} />
            <Route path="/security" element={<SecurityPage />} />
            <Route path="/audit-logs" element={<AuditLogsPage />} />
            <Route path="/settings" element={<SettingsPage />} />
          </Route>

          {/* Catch-all */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  );
};
