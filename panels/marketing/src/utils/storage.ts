// ============================================================================
// AM5 ROYAL • Secure Local Storage Utilities
// ============================================================================

import { MarketingUser } from '../types/marketing';

const TOKEN_KEY = 'am5_marketing_token';
const USER_KEY = 'am5_marketing_user';
const DATA_PREFIX = 'am5_mkt_';
const SCHEMA_VERSION_KEY = 'am5_mkt_schema_v2_zero';

// Automatically clear legacy mock cache on initial run
(() => {
  try {
    if (localStorage.getItem(SCHEMA_VERSION_KEY) !== 'active') {
      const keysToRemove: string[] = [];
      for (let i = 0; i < localStorage.length; i++) {
        const k = localStorage.key(i);
        if (k && (k.startsWith(DATA_PREFIX) || k === TOKEN_KEY || k === USER_KEY || k.startsWith('am5_mkt_'))) {
          keysToRemove.push(k);
        }
      }
      keysToRemove.forEach((k) => localStorage.removeItem(k));
      sessionStorage.clear();
      localStorage.setItem(SCHEMA_VERSION_KEY, 'active');
    }
  } catch (e) {
    console.warn('Could not initialize storage cleanup', e);
  }
})();

export const storage = {
  getToken: (): string | null => {
    return localStorage.getItem(TOKEN_KEY) || sessionStorage.getItem(TOKEN_KEY);
  },

  setToken: (token: string, remember: boolean = true) => {
    if (remember) {
      localStorage.setItem(TOKEN_KEY, token);
    } else {
      sessionStorage.setItem(TOKEN_KEY, token);
    }
  },

  getUser: (): MarketingUser | null => {
    const data = localStorage.getItem(USER_KEY) || sessionStorage.getItem(USER_KEY);
    if (!data) return null;
    try {
      return JSON.parse(data);
    } catch {
      return null;
    }
  },

  setUser: (user: MarketingUser, remember: boolean = true) => {
    const serialized = JSON.stringify(user);
    if (remember) {
      localStorage.setItem(USER_KEY, serialized);
    } else {
      sessionStorage.setItem(USER_KEY, serialized);
    }
  },

  clearSession: () => {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
    sessionStorage.removeItem(TOKEN_KEY);
    sessionStorage.removeItem(USER_KEY);
  },

  getData: <T>(key: string, defaultVal: T): T => {
    const raw = localStorage.getItem(DATA_PREFIX + key);
    if (!raw) return defaultVal;
    try {
      return JSON.parse(raw);
    } catch {
      return defaultVal;
    }
  },

  setData: <T>(key: string, val: T): void => {
    try {
      localStorage.setItem(DATA_PREFIX + key, JSON.stringify(val));
    } catch (e) {
      console.warn('Storage quota exceeded or error writing data', e);
    }
  }
};
