// ============================================================================
// AM5 ROYAL • Centralized Axios API Client
// Handles BaseURL, Authorization Interceptors, and Robust Error Normalization
// ============================================================================

import axios, { AxiosError, AxiosInstance, InternalAxiosRequestConfig } from 'axios';
import { storage } from '../utils/storage';

// Base URL: Vite environment variable or proxy fallback in dev / production API
const BASE_URL =
  import.meta.env.VITE_API_BASE_URL ||
  (import.meta.env.DEV ? '/api/v1' : 'https://api.am5royal.com/api/v1');

export const apiClient: AxiosInstance = axios.create({
  baseURL: BASE_URL,
  timeout: 30000,
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
});

// Request Interceptor: Attach JWT Token
apiClient.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = storage.getToken();
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response Interceptor: Handle 401 Unauthorized & Normalize Error Details
apiClient.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    if (error.response?.status === 401) {
      // Clear token and emit auth expired event if not already on login
      if (!window.location.pathname.includes('/login')) {
        storage.clearSession();
        window.location.href = '/login?expired=true';
      }
    }
    return Promise.reject(error);
  }
);

// Helper to extract clean error message from backend
export function extractErrorMessage(error: unknown): string {
  if (axios.isAxiosError(error)) {
    const data = error.response?.data;
    if (data) {
      if (typeof data === 'string') return data;
      if (data.detail) {
        if (Array.isArray(data.detail)) {
          return data.detail.map((d: any) => d.msg || JSON.stringify(d)).join(', ');
        }
        return String(data.detail);
      }
      if (data.message) return String(data.message);
      if (data.error) return String(data.error);
    }
    if (error.message) return error.message;
  }
  if (error instanceof Error) return error.message;
  return 'An unexpected error occurred. Please check your connection and try again.';
}
