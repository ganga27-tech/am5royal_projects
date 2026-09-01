import React, { createContext, useContext, useState, useEffect } from 'react';
import { UserProfile, UserRole } from '../types/developer';
import { developerApi } from '../api/developerApi';

interface AuthContextType {
  user: UserProfile | null;
  token: string | null;
  role: UserRole | null;
  isLoading: boolean;
  login: (identifier: string, pass: string) => Promise<UserProfile>;
  logout: () => void;
  hasRole: (roles: UserRole[]) => boolean;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<UserProfile | null>(() => {
    const saved = localStorage.getItem('am5_dev_user');
    return saved ? JSON.parse(saved) : null;
  });
  const [token, setToken] = useState<string | null>(() => localStorage.getItem('am5_dev_token'));
  const [isLoading, setIsLoading] = useState<boolean>(true);

  useEffect(() => {
    const initAuth = async () => {
      if (token) {
        try {
          const profile = await developerApi.getMe();
          setUser(profile);
          localStorage.setItem('am5_dev_user', JSON.stringify(profile));
        } catch {
          logout();
        }
      }
      setIsLoading(false);
    };
    initAuth();
  }, [token]);

  const login = async (identifier: string, pass: string): Promise<UserProfile> => {
    setIsLoading(true);
    try {
      const data = await developerApi.login(identifier, pass);
      localStorage.setItem('am5_dev_token', data.access_token);
      setToken(data.access_token);

      const profile = await developerApi.getMe();
      setUser(profile);
      localStorage.setItem('am5_dev_user', JSON.stringify(profile));
      return profile;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = () => {
    localStorage.removeItem('am5_dev_token');
    localStorage.removeItem('am5_dev_user');
    setToken(null);
    setUser(null);
  };

  const hasRole = (roles: UserRole[]): boolean => {
    if (!user) return false;
    if (user.role === 'admin' || user.role === 'super_admin') return true;
    return roles.includes(user.role);
  };

  const refreshUser = async () => {
    if (token) {
      try {
        const profile = await developerApi.getMe();
        setUser(profile);
        localStorage.setItem('am5_dev_user', JSON.stringify(profile));
      } catch (err) {
        console.error('Failed to refresh user', err);
      }
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        role: user?.role || null,
        isLoading,
        login,
        logout,
        hasRole,
        refreshUser,
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
