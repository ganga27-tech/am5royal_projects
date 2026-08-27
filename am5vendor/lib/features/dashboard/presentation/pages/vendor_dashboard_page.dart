import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/colors.dart';

class VendorDashboardPage extends StatefulWidget {
  const VendorDashboardPage({super.key});

  @override
  State<VendorDashboardPage> createState() => _VendorDashboardPageState();
}

class _VendorDashboardPageState extends State<VendorDashboardPage> {
  final ApiClient _apiClient = di.sl<ApiClient>();
  
  bool _isLoading = true;
  String? _errorMessage;
  String _filterType = "last_7_days";

  // Summary data
  int _totalServices = 0;
  int _todaysServices = 0;
  int _pending = 0;
  int _accepted = 0;
  int _rejected = 0;
  int _completed = 0;
  int _cancelled = 0;
  double _totalEarnings = 0.0;
  double _todaysEarnings = 0.0;
  double _avgRating = 0.0;
  int _totalReviews = 0;

  // KPI data
  double _completionRate = 0.0;
  double _acceptanceRate = 0.0;
  double _rejectionRate = 0.0;
  double _responseTime = 0.0;
  double _satisfactionScore = 0.0;
  double _repeatCustomerPercent = 0.0;

  // Graph data
  List<Map<String, dynamic>> _graphData = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Fetch Summary
      final summaryRes = await _apiClient.dio.get('/vendor/dashboard/summary');
      final s = summaryRes.data;
      
      // 2. Fetch KPIs
      final kpiRes = await _apiClient.dio.get('/vendor/dashboard/kpis');
      final k = kpiRes.data;

      // 3. Fetch Graph
      final graphRes = await _apiClient.dio.get(
        '/vendor/dashboard/analytics-graph',
        queryParameters: {'filter_type': _filterType},
      );
      final g = List<Map<String, dynamic>>.from(graphRes.data);

      setState(() {
        _totalServices = s['total_services'] ?? 0;
        _todaysServices = s['todays_services'] ?? 0;
        _pending = s['pending'] ?? 0;
        _accepted = s['accepted'] ?? 0;
        _rejected = s['rejected'] ?? 0;
        _completed = s['completed'] ?? 0;
        _cancelled = s['cancelled'] ?? 0;
        _totalEarnings = (s['total_earnings'] as num?)?.toDouble() ?? 0.0;
        _todaysEarnings = (s['todays_earnings'] as num?)?.toDouble() ?? 0.0;
        _avgRating = (s['average_rating'] as num?)?.toDouble() ?? 0.0;
        _totalReviews = s['total_reviews'] ?? 0;

        _completionRate = (k['completion_rate'] as num?)?.toDouble() ?? 0.0;
        _acceptanceRate = (k['acceptance_rate'] as num?)?.toDouble() ?? 0.0;
        _rejectionRate = (k['rejection_rate'] as num?)?.toDouble() ?? 0.0;
        _responseTime = (k['response_time_minutes'] as num?)?.toDouble() ?? 0.0;
        _satisfactionScore = (k['customer_satisfaction_score'] as num?)?.toDouble() ?? 0.0;
        _repeatCustomerPercent = (k['repeat_customer_percent'] as num?)?.toDouble() ?? 0.0;

        _graphData = g;
        _isLoading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.message ?? "Failed to load dashboard data.";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF7FBFF),
      appBar: AppBar(
        title: Text(
          'Vendor Dashboard',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchDashboardData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _fetchDashboardData,
                          child: const Text("Retry"),
                        )
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchDashboardData,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Filters ---
                        _buildFilterRow(isDark),
                        const SizedBox(height: 16),

                        // --- Summary Title ---
                        _buildSectionHeader("Overview Summary", isDark),
                        const SizedBox(height: 12),

                        // --- Summary Grid ---
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.5,
                          children: [
                            _buildStatCard("Total Services", "$_totalServices", Icons.work, Colors.blue, isDark),
                            _buildStatCard("Today's Services", "$_todaysServices", Icons.today, Colors.orange, isDark),
                            _buildStatCard("Total Earnings", "₹${_totalEarnings.toStringAsFixed(1)}", Icons.account_balance_wallet, Colors.green, isDark),
                            _buildStatCard("Today's Earnings", "₹${_todaysEarnings.toStringAsFixed(1)}", Icons.monetization_on, Colors.purple, isDark),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // --- Detailed Status Summary ---
                        _buildStatusRow(isDark),
                        const SizedBox(height: 24),

                        // --- Graph Title ---
                        _buildSectionHeader("Service Trends", isDark),
                        const SizedBox(height: 12),

                        // --- Bar Chart Trend ---
                        _buildTrendChart(isDark),
                        const SizedBox(height: 24),

                        // --- KPI Section ---
                        _buildSectionHeader("Key Performance Indicators", isDark),
                        const SizedBox(height: 12),
                        _buildKPICards(isDark),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildFilterRow(bool isDark) {
    final filters = {
      "today": "Today",
      "yesterday": "Yesterday",
      "last_7_days": "7 Days",
      "last_30_days": "30 Days",
      "this_month": "This Month",
    };

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.entries.map((entry) {
          final isSelected = _filterType == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                entry.value,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.accent,
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _filterType = entry.key;
                  });
                  _fetchDashboardData();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(bool isDark) {
    final statusList = [
      {"label": "Pending", "val": "$_pending", "color": Colors.orange},
      {"label": "Accepted", "val": "$_accepted", "color": Colors.blue},
      {"label": "Rejected", "val": "$_rejected", "color": Colors.red},
      {"label": "Completed", "val": "$_completed", "color": Colors.green},
      {"label": "Cancelled", "val": "$_cancelled", "color": Colors.grey},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: statusList.map((s) {
          return Expanded(
            child: Column(
              children: [
                Text(
                  s["val"] as String,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: s["color"] as Color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s["label"] as String,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendChart(bool isDark) {
    if (_graphData.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        child: Text("No trend data available.", style: GoogleFonts.outfit(color: Colors.grey)),
      );
    }

    // Find max value to scale chart
    int maxVal = 1;
    for (var pt in _graphData) {
      int r = pt["received"] ?? 0;
      int c = pt["completed"] ?? 0;
      if (r > maxVal) maxVal = r;
      if (c > maxVal) maxVal = c;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      height: 220,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _graphData.map((pt) {
          double rHeight = ((pt["received"] ?? 0) / maxVal) * 120.0;
          double cHeight = ((pt["completed"] ?? 0) / maxVal) * 120.0;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 8,
                        height: rHeight.clamp(4.0, 120.0),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: cHeight.clamp(4.0, 120.0),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pt["label"] ?? "",
                  style: GoogleFonts.outfit(fontSize: 8, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKPICards(bool isDark) {
    return Column(
      children: [
        _buildKPITile("Service Completion Rate", "${_completionRate.toStringAsFixed(1)}%", _completionRate / 100, Colors.green, isDark),
        const SizedBox(height: 8),
        _buildKPITile("Order Acceptance Rate", "${_acceptanceRate.toStringAsFixed(1)}%", _acceptanceRate / 100, Colors.blue, isDark),
        const SizedBox(height: 8),
        _buildKPITile("Response Time", "${_responseTime.toStringAsFixed(0)} mins", 1.0 - (_responseTime / 60.0).clamp(0.0, 1.0), Colors.purple, isDark),
        const SizedBox(height: 8),
        _buildKPITile("Repeat Customer Rate", "${_repeatCustomerPercent.toStringAsFixed(1)}%", _repeatCustomerPercent / 100, Colors.orange, isDark),
      ],
    );
  }

  Widget _buildKPITile(String title, String value, double progress, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[300] : AppColors.textPrimary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(8),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
