import 'package:equatable/equatable.dart';

class SystemHealth extends Equatable {
  const SystemHealth({
    required this.status,
    required this.api,
    required this.database,
    required this.redis,
    required this.rateLimitBackend,
    required this.metricsEnabled,
    required this.enforceHttps,
    required this.env,
  });

  final String status;
  final String api;
  final String database;
  final String redis;
  final String rateLimitBackend;
  final bool metricsEnabled;
  final bool enforceHttps;
  final String env;

  factory SystemHealth.fromJson(Map<String, dynamic> json) {
    return SystemHealth(
      status: json['status'] as String? ?? 'down',
      api: json['api'] as String? ?? 'up',
      database: json['database'] as String? ?? 'down',
      redis: json['redis'] as String? ?? 'down',
      rateLimitBackend: json['rate_limit_backend'] as String? ?? 'memory',
      metricsEnabled: json['metrics_enabled'] as bool? ?? false,
      enforceHttps: json['enforce_https'] as bool? ?? false,
      env: json['env'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [status, database, redis, rateLimitBackend];
}
