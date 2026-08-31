// ============================================================================
// AM5 ROYAL • Telecaller Authentication Context
// Complete session persistence, role validation, and reactive auth state
// ============================================================================

import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { EmployeeProfile } from '../types';
import { authApi } from '../api/authApi';
import { storage } from '../utils/storage';

interface AuthContextType {
  token: string | null;
  role: string | null;
  user: EmployeeProfile | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (identifier: string, pass: string) => Promise<void>;
  logout: () => void;
  refreshProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [token, setToken] = useState<string | null>(storage.getToken());
  const [role, setRole] = useState<string | null>(storage.getRole());
  const [user, setUser] = useState<EmployeeProfile | null>(storage.getUser<EmployeeProfile>());
  const [isLoading, setIsLoading] = useState<boolean>(true);

  // Load and verify current profile on mount if token exists
  const refreshProfile = useCallback(async () => {
    const currentToken = storage.getToken();
    if (!currentToken) {
      setIsLoading(false);
      return;
    }
    try {
      const profile = await authApi.getCurrentEmployee();
      setUser(profile);
      storage.setUser(profile);
    } catch (err) {
      console.error('Failed to load profile on mount:', err);
      // If unauthorized, token will be cleared by interceptor
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    refreshProfile();
  }, [refreshProfile]);

  const login = async (identifier: string, pass: string) => {
    setIsLoading(true);
    try {
      const resp = await authApi.login(identifier, pass);
      storage.setToken(resp.access_token);
      storage.setRole(resp.role);
      setToken(resp.access_token);
      setRole(resp.role);

      // Verify and load profile
      const profile = await authApi.getCurrentEmployee();
      storage.setUser(profile);
      setUser(profile);
    } finally {
      setIsLoading(false);
    }
  };

  const logout = () => {
    storage.clearSession();
    setToken(null);
    setRole(null);
    setUser(null);
  };

  const isAuthenticated = Boolean(token);

  return (
    <AuthContext.Provider
      value={{
        token,
        role,
        user,
        isAuthenticated,
        isLoading,
        login,
        logout,
        refreshProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
