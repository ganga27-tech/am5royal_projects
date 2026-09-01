// ============================================================================
// AM5 ROYAL • Developer & QA Control Center TypeScript Interfaces
// ============================================================================

export type UserRole = 'developer' | 'qa' | 'admin' | 'super_admin';

export interface UserProfile {
  id: number;
  first_name: string;
  last_name?: string;
  full_name: string;
  email: string;
  phone_number?: string;
  role: UserRole;
  status: string;
}

export type BugSeverity = 'low' | 'medium' | 'high' | 'critical';
export type BugPriority = 'low' | 'medium' | 'high' | 'critical';

export type BugStatus =
  | 'NEW'
  | 'ASSIGNED_TO_DEVELOPER'
  | 'IN_PROGRESS'
  | 'FIXED'
  | 'READY_FOR_QA'
  | 'QA_TESTING'
  | 'VERIFIED'
  | 'QA_REJECTED'
  | 'REOPENED'
  | 'CLOSED';

export type TaskStatus = 'todo' | 'in_progress' | 'blocked' | 'completed';
export type TaskPriority = 'low' | 'medium' | 'high' | 'critical';

export interface BugComment {
  id: number;
  bug_id: number;
  author_id: number;
  author_name: string;
  author_role: string;
  message: string;
  attachment_url?: string;
  created_at: string;
}

export interface BugActivityHistory {
  id: number;
  bug_id: number;
  actor_id: number;
  actor_name: string;
  actor_role: string;
  action: string;
  old_value?: string;
  new_value?: string;
  notes?: string;
  created_at: string;
}

export interface Bug {
  id: number;
  bug_code: string;
  project_id: number;
  project_name?: string;
  module_id?: number;
  module_name?: string;
  api_id?: number;
  api_name?: string;
  title: string;
  description?: string;
  severity: BugSeverity;
  priority: BugPriority;
  status: BugStatus;
  environment: string;
  browser?: string;
  os?: string;
  reported_by_id: number;
  reporter_name?: string;
  assigned_developer_id?: number;
  developer_name?: string;
  assigned_qa_id?: number;
  qa_name?: string;
  steps_to_reproduce?: string;
  expected_result?: string;
  actual_result?: string;
  technical_notes?: string;
  developer_notes?: string;
  qa_notes?: string;
  api_endpoint?: string;
  request_payload_reference?: string;
  response_reference?: string;
  commit_reference?: string;
  release_version?: string;
  attachment_urls?: string[];
  reopened_count: number;
  fixed_at?: string;
  verified_at?: string;
  closed_at?: string;
  created_at?: string;
  updated_at?: string;
  comments: BugComment[];
  activity_history: BugActivityHistory[];
}

export interface BugListResponse {
  items: Bug[];
  total: number;
  page: number;
  page_size: number;
  total_pages: number;
}

export interface ProjectMember {
  id: number;
  project_id: number;
  employee_id: number;
  full_name: string;
  email: string;
  system_role: string;
  project_role: string;
  created_at?: string;
}

export interface Project {
  id: number;
  name: string;
  slug: string;
  description?: string;
  status: string;
  progress: number;
  repository_url?: string;
  created_by_id?: number;
  project_head_id?: number;
  project_head_name?: string;
  project_head_email?: string;
  created_at?: string;
  updated_at?: string;
  modules_count: number;
  apis_count: number;
  open_bugs_count: number;
  active_tasks_count: number;
}

export interface ProjectWorkspace {
  project: Project;
  members: ProjectMember[];
  modules: Module[];
  apis: ApiEndpoint[];
  bugs: Bug[];
  tasks: DevTask[];
}

export interface Module {
  id: number;
  project_id: number;
  name: string;
  description?: string;
  status: string;
  progress: number;
  created_at?: string;
  updated_at?: string;
  apis_count: number;
  bugs_count: number;
  tasks_count: number;
}

export interface ApiEndpoint {
  id: number;
  project_id: number;
  module_id?: number;
  name: string;
  endpoint: string;
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
  status: string;
  version: string;
  description?: string;
  health_status: 'healthy' | 'degraded' | 'down';
  last_tested_at?: string;
  created_at?: string;
  updated_at?: string;
}

export interface TaskComment {
  id: number;
  task_id: number;
  author_id: number;
  author_name: string;
  author_role: string;
  message: string;
  created_at: string;
}

export interface DevTask {
  id: number;
  project_id: number;
  project_name?: string;
  module_id?: number;
  module_name?: string;
  title: string;
  description?: string;
  priority: TaskPriority;
  status: TaskStatus;
  assigned_developer_id?: number;
  developer_name?: string;
  assigned_qa_id?: number;
  qa_name?: string;
  due_date?: string;
  completed_at?: string;
  created_by_id?: number;
  created_at?: string;
  updated_at?: string;
  comments: TaskComment[];
}

export interface TeamMember {
  id: number;
  first_name: string;
  last_name?: string;
  full_name: string;
  email: string;
  phone_number?: string;
  role: UserRole;
  status: string;
  active_bugs_count: number;
  completed_tasks_count: number;
  workload_score: number;
}

export interface Deployment {
  id: number;
  project_id: number;
  project_name?: string;
  environment: 'DEVELOPMENT' | 'STAGING' | 'PRODUCTION';
  version: string;
  commit_hash?: string;
  status: string;
  deployed_by_id: number;
  deployer_name?: string;
  changelog?: string;
  deployed_at: string;
}

export interface NotificationItem {
  id: number;
  recipient_id: number;
  sender_id?: number;
  sender_name?: string;
  title: string;
  message: string;
  notification_type: string;
  reference_type?: string;
  reference_id?: number;
  is_read: boolean;
  created_at: string;
}

export interface AuditLog {
  id: number;
  actor_id?: number;
  actor_name?: string;
  actor_role?: string;
  action: string;
  resource_type: string;
  resource_id?: string;
  details?: string;
  ip_address?: string;
  status: string;
  created_at: string;
}

export interface GlobalDashboardStats {
  projects_count: number;
  apis_count: number;
  open_bugs_count: number;
  developers_count: number;
  qa_count: number;
  development_progress: Record<string, number>;
  system_status: Record<string, { status: string; latency_ms?: number; uptime?: string; provider?: string }>;
  api_performance: {
    total_requests: number;
    avg_latency_ms: number;
    error_rate_percent: number;
    uptime_percent: number;
  };
  bug_summary: {
    critical: number;
    high: number;
    medium: number;
    low: number;
  };
  recent_activities: BugActivityHistory[];
  deployment_summary: Deployment[];
}

export interface DeveloperDashboardStats {
  my_projects_count: number;
  my_modules_count: number;
  my_tasks_count: number;
  my_open_bugs_count: number;
  critical_bugs_count: number;
  bugs_awaiting_action_count: number;
  bugs_returned_by_qa_count: number;
  completed_tasks_count: number;
  workload_percent: number;
  my_bugs: Bug[];
  my_tasks: DevTask[];
  recent_activity: BugActivityHistory[];
}

export interface QADashboardStats {
  new_bugs_count: number;
  assigned_to_dev_count: number;
  bugs_awaiting_qa_count: number;
  under_qa_testing_count: number;
  reopened_bugs_count: number;
  verified_bugs_count: number;
  critical_bugs_count: number;
  high_priority_bugs_count: number;
  average_resolution_hours: number;
  reopen_rate_percent: number;
  developer_wise_bugs: { developer_id: number; developer_name: string; open_bugs: number }[];
  module_wise_bugs: { module_id: number; module_name: string; open_bugs: number }[];
  awaiting_verification_bugs: Bug[];
}

export interface DatabaseDiagnostics {
  status: string;
  dialect: string;
  pool_size: number;
  pool_status: string;
  tables_overview: { table_name: string; label: string; row_count: number; primary_key: string }[];
  migrations_status: string;
}

export interface SecurityAudit {
  auth_health: string;
  total_logins_24h: number;
  failed_logins_24h: number;
  active_sessions_count: number;
  api_error_rate_percent: number;
  suspicious_indicators_count: number;
  recent_security_events: {
    id: number;
    actor_name: string;
    actor_role: string;
    action: string;
    resource_type: string;
    status: string;
    created_at: string;
  }[];
}

export interface AnalyticsData {
  timeframe: string;
  bug_trend: { date: string; created: number; fixed: number; verified: number; rejected: number }[];
  task_completion: { name: string; completed: number; pending: number }[];
  developer_workload: { developer: string; open_bugs: number; completed_tasks: number; workload: number }[];
  qa_workload: { qa: string; verified: number; rejected: number; pending_review: number }[];
  module_health: { module: string; health_score: number; open_bugs: number }[];
}
