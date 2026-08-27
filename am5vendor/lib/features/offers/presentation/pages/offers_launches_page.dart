import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/colors.dart';

class OffersLaunchesPage extends StatefulWidget {
  const OffersLaunchesPage({super.key});

  @override
  State<OffersLaunchesPage> createState() => _OffersLaunchesPageState();
}

class _OffersLaunchesPageState extends State<OffersLaunchesPage>
    with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = di.sl<ApiClient>();
  final ImagePicker _imagePicker = ImagePicker();
  late TabController _tabController;

  bool _isLoading = true;
  String? _errorMessage;
  bool _isUploadingMedia = false;

  List<dynamic> _offers = [];
  List<dynamic> _launches = [];
  List<dynamic> _salesMedia = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiClient.dio.get('/vendor/management/offers'),
        _apiClient.dio.get('/vendor/management/launches'),
        _apiClient.dio.get('/vendor/management/media'),
      ]);

      setState(() {
        _offers = results[0].data is List ? results[0].data : [];
        _launches = results[1].data is List ? results[1].data : [];
        _salesMedia = results[2].data is List ? results[2].data : [];
        _isLoading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage =
            e.response?.data?['message'] ?? e.message ?? "Failed to load data.";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // ─── Offers ─────────────────────────────────────────────────────────────────

  Future<void> _deleteOffer(int id) async {
    try {
      await _apiClient.dio.delete('/vendor/management/offers/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offer deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _fetchData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showOfferForm({Map<String, dynamic>? existingOffer}) {
    final titleController =
        TextEditingController(text: existingOffer?['title']);
    final descController =
        TextEditingController(text: existingOffer?['description']);
    DateTime startDate = existingOffer != null
        ? DateTime.parse(existingOffer['start_date'])
        : DateTime.now();
    DateTime endDate = existingOffer != null
        ? DateTime.parse(existingOffer['end_date'])
        : DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      existingOffer == null
                          ? '🎯 Create Promo Offer'
                          : '✏️ Edit Promo Offer',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.outfit(),
                      decoration: InputDecoration(
                        labelText: 'Offer Title *',
                        prefixIcon: const Icon(Icons.title_rounded),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: AppColors.accent, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      style: GoogleFonts.outfit(),
                      decoration: InputDecoration(
                        labelText: 'Offer Description',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.description_rounded),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: AppColors.accent, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today_rounded,
                                size: 16),
                            label: Text(
                              'Start: ${DateFormat('dd MMM').format(startDate)}',
                              style: GoogleFonts.outfit(fontSize: 13),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate,
                                firstDate: DateTime.now()
                                    .subtract(const Duration(days: 30)),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (picked != null)
                                setModalState(() => startDate = picked);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.event_rounded, size: 16),
                            label: Text(
                              'End: ${DateFormat('dd MMM').format(endDate)}',
                              style: GoogleFonts.outfit(fontSize: 13),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: endDate,
                                firstDate: startDate,
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (picked != null)
                                setModalState(() => endDate = picked);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) return;
                          final payload = {
                            "title": titleController.text.trim(),
                            "description": descController.text.trim(),
                            "start_date":
                                DateFormat('yyyy-MM-dd').format(startDate),
                            "end_date":
                                DateFormat('yyyy-MM-dd').format(endDate),
                            "status": "active",
                            "images": existingOffer?['images'] ?? []
                          };
                          try {
                            if (existingOffer == null) {
                              await _apiClient.dio.post(
                                  '/vendor/management/offers',
                                  data: payload);
                            } else {
                              await _apiClient.dio.put(
                                '/vendor/management/offers/${existingOffer['id']}',
                                data: payload,
                              );
                            }
                            Navigator.pop(context);
                            _fetchData();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error saving offer: $e')),
                            );
                          }
                        },
                        child: Text(
                          existingOffer == null
                              ? 'Create Offer'
                              : 'Update Offer',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Launches ────────────────────────────────────────────────────────────────

  Future<void> _deleteLaunch(int id) async {
    try {
      await _apiClient.dio.delete('/vendor/management/launches/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Launch deleted'), backgroundColor: Colors.green),
        );
      }
      _fetchData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showLaunchForm({Map<String, dynamic>? existingLaunch}) {
    final detailsController =
        TextEditingController(text: existingLaunch?['details']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existingLaunch == null
                    ? '🚀 Announce New Launch'
                    : '✏️ Edit Launch',
                style: GoogleFonts.outfit(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: detailsController,
                maxLines: 4,
                style: GoogleFonts.outfit(),
                decoration: InputDecoration(
                  labelText: 'Product/Service Details *',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.rocket_launch_rounded),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.accent, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    if (detailsController.text.trim().isEmpty) return;
                    final payload = {
                      "details": detailsController.text.trim(),
                      "status": "active",
                      "images": existingLaunch?['images'] ?? []
                    };
                    try {
                      if (existingLaunch == null) {
                        await _apiClient.dio
                            .post('/vendor/management/launches', data: payload);
                      } else {
                        await _apiClient.dio.put(
                          '/vendor/management/launches/${existingLaunch['id']}',
                          data: payload,
                        );
                      }
                      Navigator.pop(context);
                      _fetchData();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: Text(
                    existingLaunch == null
                        ? 'Announce Launch'
                        : 'Update Launch',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ─── Sales Media ─────────────────────────────────────────────────────────────

  Future<void> _uploadImage() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      final file = File(picked.path);
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Image must be under 10MB'),
                backgroundColor: Colors.red),
          );
        }
        return;
      }

      setState(() => _isUploadingMedia = true);

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          picked.path,
          filename: picked.name,
        ),
      });

      await _apiClient.dio.post('/vendor/management/media', data: formData);
      await _fetchData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Image uploaded successfully!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingMedia = false);
    }
  }

  Future<void> _uploadVideo() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'avi'],
      );
      if (result == null || result.files.isEmpty) return;

      final platformFile = result.files.first;
      if (platformFile.path == null) return;

      final fileSize = platformFile.size;
      if (fileSize > 100 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Video must be under 100MB'),
                backgroundColor: Colors.red),
          );
        }
        return;
      }

      setState(() => _isUploadingMedia = true);

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          platformFile.path!,
          filename: platformFile.name,
        ),
      });

      await _apiClient.dio.post('/vendor/management/media', data: formData);
      await _fetchData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Video uploaded successfully!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingMedia = false);
    }
  }

  Future<void> _deleteMedia(int id) async {
    try {
      await _apiClient.dio.delete('/vendor/management/media/$id');
      await _fetchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Media deleted'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showMediaUploadOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upload Sales Media',
              style:
                  GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Showcase your work to attract more customers',
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildUploadOptionCard(
                    icon: Icons.photo_library_rounded,
                    label: 'Upload Photo',
                    sublabel: 'JPG, PNG, WEBP\nMax 10 MB',
                    color: Colors.blue.shade400,
                    onTap: () {
                      Navigator.pop(context);
                      _uploadImage();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildUploadOptionCard(
                    icon: Icons.videocam_rounded,
                    label: 'Upload Video',
                    sublabel: 'MP4, MOV, AVI\nMax 100 MB',
                    color: Colors.purple.shade400,
                    onTap: () {
                      Navigator.pop(context);
                      _uploadVideo();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOptionCard({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(label,
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              sublabel,
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF7FBFF),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Offers & Media',
          style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.accent,
          labelStyle:
              GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: "Offers"),
            Tab(text: "Launches"),
            Tab(text: "Sales Media"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOffersTab(isDark),
                    _buildLaunchesTab(isDark),
                    _buildSalesMediaTab(isDark),
                  ],
                ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          if (_isUploadingMedia) {
            return FloatingActionButton(
              backgroundColor: AppColors.accent,
              onPressed: null,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          }
          return FloatingActionButton(
            backgroundColor: AppColors.accent,
            onPressed: () {
              if (_tabController.index == 0) {
                _showOfferForm();
              } else if (_tabController.index == 1) {
                _showLaunchForm();
              } else {
                _showMediaUploadOptions();
              }
            },
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 72, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Could not load data',
              style:
                  GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            )
          ],
        ),
      ),
    );
  }

  // ─── Offers Tab ──────────────────────────────────────────────────────────────

  Widget _buildOffersTab(bool isDark) {
    if (_offers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.local_offer_rounded,
        title: 'No Promotional Offers',
        subtitle: 'Create your first offer to attract more customers',
        color: Colors.orange,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _offers.length,
      itemBuilder: (context, index) {
        final offer = _offers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.4)
                  : Colors.orange.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (offer['status'] as String? ?? 'active').toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded,
                          color: Colors.blueAccent, size: 20),
                      onPressed: () => _showOfferForm(existingOffer: offer),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_rounded,
                          color: Colors.redAccent, size: 20),
                      onPressed: () => _deleteOffer(offer['id']),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  offer['title'] ?? '',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if ((offer['description'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    offer['description'] ?? '',
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      '${offer['start_date']}  →  ${offer['end_date']}',
                      style:
                          GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Launches Tab ────────────────────────────────────────────────────────────

  Widget _buildLaunchesTab(bool isDark) {
    if (_launches.isEmpty) {
      return _buildEmptyState(
        icon: Icons.rocket_launch_rounded,
        title: 'No Launch Announcements',
        subtitle: 'Announce new products or services to your customers',
        color: Colors.purple,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _launches.length,
      itemBuilder: (context, index) {
        final launch = _launches[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.4)
                  : Colors.purple.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.rocket_launch_rounded,
                      color: Colors.purple, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        launch['details'] ?? '',
                        style: GoogleFonts.outfit(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          (launch['status'] as String? ?? 'active')
                              .toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded,
                          color: Colors.blueAccent, size: 20),
                      onPressed: () => _showLaunchForm(existingLaunch: launch),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_rounded,
                          color: Colors.redAccent, size: 20),
                      onPressed: () => _deleteLaunch(launch['id']),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Sales Media Tab ─────────────────────────────────────────────────────────

  Widget _buildSalesMediaTab(bool isDark) {
    if (_isUploadingMedia) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Uploading media...'),
          ],
        ),
      );
    }

    final images =
        _salesMedia.where((m) => m['media_type'] == 'IMAGE').toList();
    final videos =
        _salesMedia.where((m) => m['media_type'] == 'VIDEO').toList();

    if (_salesMedia.isEmpty) {
      return _buildEmptyState(
        icon: Icons.perm_media_rounded,
        title: 'No Sales Media Yet',
        subtitle:
            'Upload photos and videos to showcase\nyour work and attract customers',
        color: Colors.teal,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            children: [
              _buildStatChip(
                icon: Icons.photo_rounded,
                count: images.length,
                label: 'Photos',
                color: Colors.blue,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                icon: Icons.videocam_rounded,
                count: videos.length,
                label: 'Videos',
                color: Colors.purple,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (images.isNotEmpty) ...[
            Text(
              '📷 Photos',
              style:
                  GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final media = images[index];
                return _buildMediaGridItem(media, isDark);
              },
            ),
            const SizedBox(height: 24),
          ],

          if (videos.isNotEmpty) ...[
            Text(
              '🎬 Videos',
              style:
                  GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final media = videos[index];
                return _buildVideoListItem(media, isDark);
              },
            ),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '$count $label',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGridItem(Map<String, dynamic> media, bool isDark) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            media['url'] ?? '',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: isDark ? AppColors.darkSurfaceVariant : Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: isDark ? AppColors.darkSurfaceVariant : Colors.grey[100],
                child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _showDeleteConfirmDialog(media['id']),
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoListItem(Map<String, dynamic> media, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.4)
              : Colors.purple.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.videocam_rounded,
                color: Colors.purple, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sales Video',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(media['created_at']),
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded,
                color: Colors.redAccent, size: 22),
            onPressed: () => _showDeleteConfirmDialog(media['id']),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  void _showDeleteConfirmDialog(int mediaId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Delete Media',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete this media file?',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancel', style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteMedia(mediaId);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.outfit(
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: color.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style:
                  GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (_tabController.index == 2) {
                  _showMediaUploadOptions();
                } else if (_tabController.index == 0) {
                  _showOfferForm();
                } else {
                  _showLaunchForm();
                }
              },
              icon: const Icon(Icons.add),
              label: Text(
                _tabController.index == 2 ? 'Upload Media' : 'Create Now',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
