import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../admin/data/datasources/admin_remote_data_source.dart';
import '../../../admin/data/models/hr_models.dart';

class HrManagementTab extends StatefulWidget {
  const HrManagementTab({super.key, required this.isDark});

  final bool isDark;

  @override
  State<HrManagementTab> createState() => _HrManagementTabState();
}

class _HrManagementTabState extends State<HrManagementTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  List<JobOpeningModel> _openings = [];
  List<JobApplicationModel> _applications = [];
  bool _loadingOpenings = false;
  bool _loadingApplications = false;
  int _applicationsTotal = 0;
  int _applicationsSkip = 0;
  final int _applicationsLimit = 20;
  int? _filterOpeningId;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOpenings();
    _loadApplications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOpenings() async {
    setState(() => _loadingOpenings = true);
    try {
      final ds = di.sl<AdminRemoteDataSource>();
      final openings = await ds.getHrOpenings();
      if (!mounted) return;
      setState(() {
        _openings = openings;
        _loadingOpenings = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingOpenings = false);
      _showSnack('Failed to load openings: $e', isError: true);
    }
  }

  Future<void> _loadApplications({bool reset = false}) async {
    if (reset) _applicationsSkip = 0;
    setState(() => _loadingApplications = true);
    try {
      final ds = di.sl<AdminRemoteDataSource>();
      final res = await ds.getHrApplications(
        jobOpeningId: _filterOpeningId,
        status: _filterStatus,
        search: _searchController.text.trim(),
        skip: _applicationsSkip,
        limit: _applicationsLimit,
      );
      if (!mounted) return;
      setState(() {
        _applications = res.items;
        _applicationsTotal = res.total;
        _loadingApplications = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingApplications = false);
      _showSnack('Failed to load applications: $e', isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
      ),
    );
  }

  Future<void> _showCreateOpeningDialog() async {
    final titleController = TextEditingController();
    final departmentController = TextEditingController();
    final locationController = TextEditingController(text: 'Pan India (Remote / Hybrid)');
    final experienceController = TextEditingController(text: '1-3 Years');
    final descriptionController = TextEditingController();
    final skillsController = TextEditingController();
    String category = 'Tech';
    String employmentType = 'Full-Time';

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Job Opening'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Job Title'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'Tech', child: Text('Tech')),
                    DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
                    DropdownMenuItem(value: 'Operations', child: Text('Operations')),
                    DropdownMenuItem(value: 'HR', child: Text('HR')),
                  ],
                  onChanged: (v) => category = v ?? 'Tech',
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: departmentController,
                  decoration: const InputDecoration(labelText: 'Department'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: experienceController,
                  decoration: const InputDecoration(labelText: 'Experience'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: skillsController,
                  decoration: const InputDecoration(
                    labelText: 'Key Skills (comma separated)',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (created != true) return;

    final title = titleController.text.trim();
    final department = departmentController.text.trim();
    final description = descriptionController.text.trim();
    if (title.length < 2) {
      _showSnack('Job title must be at least 2 characters', isError: true);
      return;
    }
    if (department.length < 2) {
      _showSnack('Department must be at least 2 characters', isError: true);
      return;
    }
    if (description.length < 3) {
      _showSnack('Description must be at least 3 characters', isError: true);
      return;
    }

    try {
      final ds = di.sl<AdminRemoteDataSource>();
      await ds.createHrOpening({
        'title': title,
        'category': category,
        'department': department,
        'employment_type': employmentType,
        'location': locationController.text.trim(),
        'experience_years': experienceController.text.trim(),
        'description': description,
        'key_skills': skillsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'is_active': true,
      });
      _showSnack('Job opening created');
      await _loadOpenings();
      await _loadApplications(reset: true);
    } catch (e) {
      _showSnack('Failed to create opening: $e', isError: true);
    }
  }

  Future<void> _openResume(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnack('Could not open resume', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HR Management',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0D3B66),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage job openings and review candidate applications',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showCreateOpeningDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Opening'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.accent : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.accentLight : AppColors.primary,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
          indicatorColor: isDark ? AppColors.accent : AppColors.primary,
          tabs: const [
            Tab(text: 'Job Openings'),
            Tab(text: 'Applications'),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOpeningsTab(isDark),
              _buildApplicationsTab(isDark, dateFmt),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOpeningsTab(bool isDark) {
    if (_loadingOpenings) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_openings.isEmpty) {
      return Center(
        child: Text(
          'No job openings yet. Create one to get started.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOpenings,
      child: ListView.separated(
        itemCount: _openings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final opening = _openings[index];
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            opening.title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0D3B66),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _statusChip(
                            opening.isActive ? 'Active' : 'Inactive',
                            opening.isActive ? Colors.green : Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${opening.category} • ${opening.department} • ${opening.location}',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: opening.keySkills
                            .take(6)
                            .map(
                              (s) => Chip(
                                label: Text(s, style: const TextStyle(fontSize: 11)),
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                if (opening.isActive)
                  IconButton(
                    tooltip: 'Deactivate',
                    onPressed: () async {
                      try {
                        await di.sl<AdminRemoteDataSource>().deactivateHrOpening(opening.id);
                        _showSnack('Opening deactivated');
                        await _loadOpenings();
                      } catch (e) {
                        _showSnack('Failed: $e', isError: true);
                      }
                    },
                    icon: Icon(Icons.pause_circle_outline, color: Colors.orange.shade700),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildApplicationsTab(bool isDark, DateFormat dateFmt) {
    return Column(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search name, email, ref...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (_) => _loadApplications(reset: true),
              ),
            ),
            DropdownButton<int?>(
              value: _filterOpeningId,
              hint: const Text('All Roles'),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('All Roles')),
                ..._openings.map(
                  (o) => DropdownMenuItem<int?>(
                    value: o.id,
                    child: Text(o.title),
                  ),
                ),
              ],
              onChanged: (v) {
                setState(() => _filterOpeningId = v);
                _loadApplications(reset: true);
              },
            ),
            DropdownButton<String?>(
              value: _filterStatus,
              hint: const Text('All Status'),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Status')),
                DropdownMenuItem(value: 'submitted', child: Text('Submitted')),
                DropdownMenuItem(value: 'reviewed', child: Text('Reviewed')),
                DropdownMenuItem(value: 'shortlisted', child: Text('Shortlisted')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              ],
              onChanged: (v) {
                setState(() => _filterStatus = v);
                _loadApplications(reset: true);
              },
            ),
            ElevatedButton(
              onPressed: () => _loadApplications(reset: true),
              child: const Text('Search'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _loadingApplications
              ? const Center(child: CircularProgressIndicator())
              : _applications.isEmpty
                  ? Center(
                      child: Text(
                        'No applications found.',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _loadApplications(reset: true),
                      child: ListView.separated(
                        itemCount: _applications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final app = _applications[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.05),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        app.fullName,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF0D3B66),
                                        ),
                                      ),
                                    ),
                                    _statusChip(app.status, _statusColor(app.status)),
                                    const SizedBox(width: 8),
                                    PopupMenuButton<String>(
                                      onSelected: (status) async {
                                        try {
                                          await di
                                              .sl<AdminRemoteDataSource>()
                                              .updateHrApplicationStatus(app.id, status);
                                          _showSnack('Status updated');
                                          await _loadApplications();
                                        } catch (e) {
                                          _showSnack('Failed: $e', isError: true);
                                        }
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(value: 'reviewed', child: Text('Mark Reviewed')),
                                        PopupMenuItem(value: 'shortlisted', child: Text('Shortlist')),
                                        PopupMenuItem(value: 'rejected', child: Text('Reject')),
                                      ],
                                      child: const Icon(Icons.more_vert),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${app.jobTitle} • ${app.jobCategory}',
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${app.email} • ${app.phone}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${app.currentLocation} • ${app.totalExperience} • Notice: ${app.noticePeriod}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      app.applicationReference,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.accentLight : AppColors.primary,
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: () => _openResume(app.resumeUrl),
                                      icon: const Icon(Icons.description_outlined, size: 18),
                                      label: Text(app.resumeFileName),
                                    ),
                                    Text(
                                      dateFmt.format(app.createdAt.toLocal()),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ),
        if (_applicationsTotal > _applicationsLimit)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _applicationsSkip <= 0
                      ? null
                      : () {
                          setState(() {
                            _applicationsSkip =
                                (_applicationsSkip - _applicationsLimit).clamp(0, 999999);
                          });
                          _loadApplications();
                        },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${_applicationsSkip + 1}-${(_applicationsSkip + _applications.length).clamp(0, _applicationsTotal)} of $_applicationsTotal',
                ),
                IconButton(
                  onPressed: _applicationsSkip + _applicationsLimit >= _applicationsTotal
                      ? null
                      : () {
                          setState(() => _applicationsSkip += _applicationsLimit);
                          _loadApplications();
                        },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'shortlisted':
        return Colors.green;
      case 'reviewed':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
