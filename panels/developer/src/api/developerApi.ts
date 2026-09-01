import { apiClient } from './client';
import {
  UserProfile,
  GlobalDashboardStats,
  DeveloperDashboardStats,
  QADashboardStats,
  Bug,
  BugListResponse,
  Project,
  ProjectMember,
  ProjectWorkspace,
  Module,
  ApiEndpoint,
  DevTask,
  TeamMember,
  Deployment,
  NotificationItem,
  AuditLog,
  DatabaseDiagnostics,
  SecurityAudit,
  AnalyticsData,
  BugStatus,
} from '../types/developer';

export const developerApi = {
  // Auth
  async login(identifier: string, password: string) {
    const res = await apiClient.post<{ access_token: string; token_type: string; role: string }>(
      '/auth/login',
      { identifier, password }
    );
    return res.data;
  },

  async getMe() {
    const res = await apiClient.get<UserProfile>('/auth/me');
    return res.data;
  },

  // Dashboards
  async getGlobalDashboard() {
    const res = await apiClient.get<GlobalDashboardStats>('/dashboard/global');
    return res.data;
  },

  async getDeveloperDashboard() {
    const res = await apiClient.get<DeveloperDashboardStats>('/dashboard/developer');
    return res.data;
  },

  async getQADashboard() {
    const res = await apiClient.get<QADashboardStats>('/dashboard/qa');
    return res.data;
  },

  // Bugs
  async listBugs(params?: {
    project_id?: number;
    module_id?: number;
    severity?: string;
    priority?: string;
    status?: string;
    assigned_developer_id?: number;
    assigned_qa_id?: number;
    search?: string;
    page?: number;
    page_size?: number;
  }) {
    const res = await apiClient.get<BugListResponse>('/bugs', { params });
    return res.data;
  },

  async getBug(bugId: number) {
    const res = await apiClient.get<Bug>(`/bugs/${bugId}`);
    return res.data;
  },

  async createBug(data: {
    project_id: number;
    module_id?: number;
    api_id?: number;
    title: string;
    description?: string;
    severity: string;
    priority: string;
    environment: string;
    browser?: string;
    os?: string;
    assigned_developer_id?: number;
    assigned_qa_id?: number;
    steps_to_reproduce?: string;
    expected_result?: string;
    actual_result?: string;
    api_endpoint?: string;
    attachment_urls?: string[];
  }) {
    const res = await apiClient.post<Bug>('/bugs', data);
    return res.data;
  },

  async transitionBug(bugId: number, data: {
    new_status: BugStatus;
    notes?: string;
    reassign_to_id?: number;
    commit_reference?: string;
    release_version?: string;
  }) {
    const res = await apiClient.post<Bug>(`/bugs/${bugId}/transition`, data);
    return res.data;
  },

  async assignBug(bugId: number, data: {
    developer_id?: number;
    qa_id?: number;
    notes?: string;
  }) {
    const res = await apiClient.post<Bug>(`/bugs/${bugId}/assign`, data);
    return res.data;
  },

  async addBugComment(bugId: number, message: string, attachment_url?: string) {
    const res = await apiClient.post(`/bugs/${bugId}/comments`, { message, attachment_url });
    return res.data;
  },

  // Projects & Modules
  async listProjects() {
    const res = await apiClient.get<Project[]>('/projects');
    return res.data;
  },

  async getProject(projectId: number) {
    const res = await apiClient.get<Project>(`/projects/${projectId}`);
    return res.data;
  },

  async getProjectWorkspace(projectId: number) {
    const res = await apiClient.get<ProjectWorkspace>(`/projects/${projectId}/workspace`);
    return res.data;
  },

  async listProjectMembers(projectId: number) {
    const res = await apiClient.get<ProjectMember[]>(`/projects/${projectId}/members`);
    return res.data;
  },

  async addProjectMember(projectId: number, data: { employee_id: number; project_role: string }) {
    const res = await apiClient.post<ProjectMember>(`/projects/${projectId}/members`, data);
    return res.data;
  },

  async removeProjectMember(projectId: number, employeeId: number) {
    const res = await apiClient.delete(`/projects/${projectId}/members/${employeeId}`);
    return res.data;
  },

  async updateProjectHead(projectId: number, projectHeadId: number) {
    const res = await apiClient.put<Project>(`/projects/${projectId}/head`, { project_head_id: projectHeadId });
    return res.data;
  },

  async createProject(data: { name: string; slug: string; description?: string; repository_url?: string; project_head_id?: number }) {
    const res = await apiClient.post<Project>('/projects', data);
    return res.data;
  },

  async listModules(projectId?: number) {
    const res = await apiClient.get<Module[]>('/modules', { params: { project_id: projectId } });
    return res.data;
  },

  async createModule(data: { project_id: number; name: string; description?: string; status?: string }) {
    const res = await apiClient.post<Module>('/modules', data);
    return res.data;
  },

  // APIs
  async listApis(projectId?: number, moduleId?: number) {
    const res = await apiClient.get<ApiEndpoint[]>('/apis', { params: { project_id: projectId, module_id: moduleId } });
    return res.data;
  },

  async createApi(data: { project_id: number; module_id?: number; name: string; endpoint: string; method: string; version?: string; description?: string }) {
    const res = await apiClient.post<ApiEndpoint>('/apis', data);
    return res.data;
  },

  async testApi(apiId: number) {
    const res = await apiClient.post(`/apis/${apiId}/test`);
    return res.data;
  },

  // Tasks
  async listTasks(params?: { project_id?: number; status?: string; assigned_developer_id?: number }) {
    const res = await apiClient.get<DevTask[]>('/tasks', { params });
    return res.data;
  },

  async createTask(data: {
    project_id: number;
    module_id?: number;
    title: string;
    description?: string;
    priority?: string;
    assigned_developer_id?: number;
    assigned_qa_id?: number;
    due_date?: string;
  }) {
    const res = await apiClient.post<DevTask>('/tasks', data);
    return res.data;
  },

  async updateTask(taskId: number, data: Partial<DevTask>) {
    const res = await apiClient.put<DevTask>(`/tasks/${taskId}`, data);
    return res.data;
  },

  async addTaskComment(taskId: number, message: string) {
    const res = await apiClient.post(`/tasks/${taskId}/comments`, { message });
    return res.data;
  },

  // Team
  async listTeamMembers() {
    const res = await apiClient.get<TeamMember[]>('/team');
    return res.data;
  },

  // Deployments
  async listDeployments() {
    const res = await apiClient.get<Deployment[]>('/deployments');
    return res.data;
  },

  async createDeployment(data: { project_id: number; environment: string; version: string; commit_hash?: string; changelog?: string }) {
    const res = await apiClient.post<Deployment>('/deployments', data);
    return res.data;
  },

  // Analytics
  async getAnalytics(timeframe: string = '7d') {
    const res = await apiClient.get<AnalyticsData>('/analytics', { params: { timeframe } });
    return res.data;
  },

  // Diagnostics
  async getDatabaseDiagnostics() {
    const res = await apiClient.get<DatabaseDiagnostics>('/database');
    return res.data;
  },

  async getSecurityAudit() {
    const res = await apiClient.get<SecurityAudit>('/security');
    return res.data;
  },

  async listAuditLogs(action?: string, limit: number = 50) {
    const res = await apiClient.get<AuditLog[]>('/audit-logs', { params: { action, limit } });
    return res.data;
  },

  // Notifications
  async listNotifications(limit: number = 30) {
    const res = await apiClient.get<NotificationItem[]>('/notifications', { params: { limit } });
    return res.data;
  },

  async getUnreadCount() {
    const res = await apiClient.get<{ unread_count: number }>('/notifications/unread-count');
    return res.data;
  },

  async markNotificationRead(id: number) {
    const res = await apiClient.put(`/notifications/${id}/read`);
    return res.data;
  },

  async markAllNotificationsRead() {
    const res = await apiClient.put('/notifications/read-all');
    return res.data;
  },
};
