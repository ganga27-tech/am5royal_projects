// ============================================================================
// AM5 ROYAL • Local Storage Helpers for Token & User Session
// ============================================================================

const TOKEN_KEY = 'am5_telecaller_auth_token';
const ROLE_KEY = 'am5_telecaller_role';
const USER_KEY = 'am5_telecaller_profile';

export const storage = {
  getToken(): string | null {
    return localStorage.getItem(TOKEN_KEY);
  },

  setToken(token: string): void {
    localStorage.setItem(TOKEN_KEY, token);
  },

  getRole(): string | null {
    return localStorage.getItem(ROLE_KEY);
  },

  setRole(role: string): void {
    localStorage.setItem(ROLE_KEY, role);
  },

  getUser<T>(): T | null {
    const raw = localStorage.getItem(USER_KEY);
    if (!raw) return null;
    try {
      return JSON.parse(raw) as T;
    } catch {
      return null;
    }
  },

  setUser<T>(user: T): void {
    localStorage.setItem(USER_KEY, JSON.stringify(user));
  },

  clearSession(): void {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(ROLE_KEY);
    localStorage.removeItem(USER_KEY);
  },
};
