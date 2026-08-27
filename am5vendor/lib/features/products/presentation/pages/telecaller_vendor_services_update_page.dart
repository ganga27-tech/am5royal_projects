import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/widgets/app_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/constants/colors.dart';
import '../../../../features/supercategory/domain/usecases/upload_media_usecase.dart';
class TelecallerVendorServicesUpdatePage extends StatefulWidget {
  const TelecallerVendorServicesUpdatePage({super.key});

  @override
  State<TelecallerVendorServicesUpdatePage> createState() =>
      _TelecallerVendorServicesUpdatePageState();
}

class _TelecallerVendorServicesUpdatePageState
    extends State<TelecallerVendorServicesUpdatePage> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<dynamic> _services = [];
  Map<String, dynamic> _vendorProfile = {};

  // Grouped services by sub_category_name
  Map<String, List<dynamic>> _groupedServices = {};

  // Controllers and local state per service
  final Map<int, TextEditingController> _priceControllers = {};
  final Map<int, TextEditingController> _descriptionControllers = {};
  final Map<int, bool> _negotiableState = {};
  final Map<int, List<Map<String, String>>> _uploadedMedia =
      {}; // list of {url, type}
  final Map<int, bool> _mediaUploading = {};

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfileAndServices();
  }

  Future<void> _fetchProfileAndServices() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final dio = di.sl<Dio>();

      // 1. Fetch Profile
      final profileRes = await dio.get('/vendors/me/profile');
      if (profileRes.statusCode == 200) {
        _vendorProfile = profileRes.data;
      }

      // 2. Fetch Services
      final servicesRes = await dio.get('/vendors/me/services');
      if (servicesRes.statusCode == 200) {
        _services = servicesRes.data;

        // Group services
        for (var srv in _services) {
          final subCatName = srv['sub_category_name'] ?? 'Other Services';
          if (!_groupedServices.containsKey(subCatName)) {
            _groupedServices[subCatName] = [];
          }
          _groupedServices[subCatName]!.add(srv);

          final srvId = srv['id'] as int;
          _priceControllers[srvId] = TextEditingController(
              text: srv['price'] != null && srv['price'] != 0.0
                  ? srv['price'].toString()
                  : '');
          _descriptionControllers[srvId] =
              TextEditingController(text: srv['description'] ?? '');
          _negotiableState[srvId] = srv['negotiable'] ?? false;

          final mediaList = srv['media'] as List?;
          _uploadedMedia[srvId] = mediaList != null
              ? mediaList
                  .map((m) => {
                        'media_url': m['media_url'] as String,
                        'media_type': m['media_type'] as String,
                      })
                  .toList()
              : [];
          _mediaUploading[srvId] = false;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load services: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    for (var controller in _descriptionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<String?> _uploadMediaFile(XFile file) async {
    try {
      final uploadUseCase = di.sl<UploadMediaUseCase>();
      final result = await uploadUseCase(file);
      
      return result.fold(
        (failure) {
          debugPrint('Upload error: ${failure.message}');
          return null;
        },
        (mediaItem) => mediaItem.mediaUrl,
      );
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<void> _pickImage(int srvId, StateSetter setStateDialog) async {
    final int imagesCount =
        _uploadedMedia[srvId]!.where((m) => m['media_type'] == 'image').length;
    if (imagesCount >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 2 images allowed per service')),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (image != null) {
      setStateDialog(() {
        _mediaUploading[srvId] = true;
      });

      final url = await _uploadMediaFile(image);
      if (url != null) {
        setStateDialog(() {
          _uploadedMedia[srvId]!.add({
            'media_url': url,
            'media_type': 'image',
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }

      setStateDialog(() {
        _mediaUploading[srvId] = false;
      });
    }
  }

  Future<void> _pickVideo(int srvId, StateSetter setStateDialog) async {
    final bool hasVideo =
        _uploadedMedia[srvId]!.any((m) => m['media_type'] == 'video');
    if (hasVideo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 1 video allowed per service')),
      );
      return;
    }

    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setStateDialog(() {
        _mediaUploading[srvId] = true;
      });

      final url = await _uploadMediaFile(video);
      if (url != null) {
        setStateDialog(() {
          _uploadedMedia[srvId]!.add({
            'media_url': url,
            'media_type': 'video',
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload video')),
        );
      }

      setStateDialog(() {
        _mediaUploading[srvId] = false;
      });
    }
  }

  void _removeMedia(int srvId, int index, StateSetter setStateDialog) {
    setStateDialog(() {
      _uploadedMedia[srvId]!.removeAt(index);
    });
  }

  void _openServiceDialog(Map<String, dynamic> srv) {
    final int srvId = srv['id'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final isWide = MediaQuery.of(context).size.width > 600;
            final borderRadius = isWide
                ? BorderRadius.circular(28)
                : const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  );
            final bool isNegotiable = _negotiableState[srvId] ?? false;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                constraints:
                    isWide ? const BoxConstraints(maxWidth: 520) : null,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: borderRadius,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Header Row with Close Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ADD SERVICE DETAILS',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFF60A5FA)
                                        : AppColors.primary,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  srv['title'] ?? 'Service',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white10
                                    : Colors.black.withValues(alpha: 0.04),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _priceControllers[srvId],
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Service Price / Amount',
                          labelStyle: GoogleFonts.outfit(
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                          floatingLabelStyle: GoogleFonts.outfit(
                            color: isDark
                                ? const Color(0xFF60A5FA)
                                : AppColors.primary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                          hintText: 'Enter service cost...',
                          hintStyle: GoogleFonts.outfit(
                            color: isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Icon(
                              Icons.currency_rupee,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              size: 20,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9).withValues(alpha: 0.6),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF60A5FA)
                                  : AppColors.primary,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Custom choice cards for fixed vs negotiable
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setStateDialog(() {
                                  _negotiableState[srvId] = false;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: !isNegotiable
                                      ? (isDark
                                          ? const Color(0xFF3B82F6)
                                              .withValues(alpha: 0.2)
                                          : AppColors.primary
                                              .withValues(alpha: 0.1))
                                      : (isDark
                                          ? const Color(0xFF0F172A)
                                          : Colors.grey.shade50),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: !isNegotiable
                                        ? (isDark
                                            ? const Color(0xFF60A5FA)
                                            : AppColors.primary)
                                        : (isDark
                                            ? Colors.white.withValues(alpha: 0.12)
                                            : Colors.grey.shade300),
                                    width: 1.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock_rounded,
                                      size: 16,
                                      color: !isNegotiable
                                          ? (isDark
                                              ? const Color(0xFF60A5FA)
                                              : AppColors.primary)
                                          : (isDark
                                              ? Colors.white38
                                              : Colors.black38),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Fixed Price',
                                      style: GoogleFonts.outfit(
                                        fontWeight: !isNegotiable
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: !isNegotiable
                                            ? (isDark
                                                ? const Color(0xFF60A5FA)
                                                : AppColors.primary)
                                            : (isDark
                                                ? Colors.white70
                                                : Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setStateDialog(() {
                                  _negotiableState[srvId] = true;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isNegotiable
                                      ? (isDark
                                          ? const Color(0xFF3B82F6)
                                              .withValues(alpha: 0.2)
                                          : AppColors.primary
                                              .withValues(alpha: 0.1))
                                      : (isDark
                                          ? const Color(0xFF0F172A)
                                          : Colors.grey.shade50),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isNegotiable
                                        ? (isDark
                                            ? const Color(0xFF60A5FA)
                                            : AppColors.primary)
                                        : (isDark
                                            ? Colors.white.withValues(alpha: 0.12)
                                            : Colors.grey.shade300),
                                    width: 1.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.handshake_rounded,
                                      size: 16,
                                      color: isNegotiable
                                          ? (isDark
                                              ? const Color(0xFF60A5FA)
                                              : AppColors.primary)
                                          : (isDark
                                              ? Colors.white38
                                              : Colors.black38),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Negotiable',
                                      style: GoogleFonts.outfit(
                                        fontWeight: isNegotiable
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isNegotiable
                                            ? (isDark
                                                ? const Color(0xFF60A5FA)
                                                : AppColors.primary)
                                            : (isDark
                                                ? Colors.white70
                                                : Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Media Selection Label
                      Text(
                        'MEDIA (OPTIONAL)',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFF60A5FA)
                              : AppColors.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _mediaUploading[srvId] == true ||
                                      (_uploadedMedia[srvId]
                                                  ?.where((m) =>
                                                      m['media_type'] ==
                                                      'image')
                                                  .length ??
                                              0) >=
                                          2
                                  ? null
                                  : () => _pickImage(srvId, setStateDialog),
                              icon: const Icon(Icons.image_rounded, size: 18),
                              label: Text(
                                  'Images (${_uploadedMedia[srvId]?.where((m) => m['media_type'] == 'image').length ?? 0}/2)',
                                  style: GoogleFonts.outfit(fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    isDark ? Colors.white : Colors.black87,
                                backgroundColor: isDark
                                    ? const Color(0xFF2C2C2C)
                                    : Colors.grey.shade200,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _mediaUploading[srvId] == true ||
                                      (_uploadedMedia[srvId]?.any((m) =>
                                              m['media_type'] == 'video') ??
                                          false)
                                  ? null
                                  : () => _pickVideo(srvId, setStateDialog),
                              icon:
                                  const Icon(Icons.videocam_rounded, size: 18),
                              label: Text(
                                  (_uploadedMedia[srvId]?.any((m) =>
                                              m['media_type'] == 'video') ??
                                          false)
                                      ? '1 Video'
                                      : 'Add Video',
                                  style: GoogleFonts.outfit(fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    isDark ? Colors.white : Colors.black87,
                                backgroundColor: isDark
                                    ? const Color(0xFF2C2C2C)
                                    : Colors.grey.shade200,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Previews
                      if (_uploadedMedia[srvId]!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 80,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ..._uploadedMedia[srvId]!
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final mIdx = entry.key;
                                final media = entry.value;
                                final isImage = media['media_type'] == 'image';

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: isImage
                                            ? AppNetworkImage(
                                                imageUrl: Uri.encodeFull((media[
                                                                'media_url']
                                                            as String)
                                                        .startsWith('http')
                                                    ? (media['media_url']
                                                        as String)
                                                    : 'http://76.13.245.174:8000${(media["media_url"] as String).startsWith("/") ? "" : "/"}${(media["media_url"] as String)}'),
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                                placeholder: Container(
                                                    color: Colors.grey.shade800,
                                                    width: 80,
                                                    height: 80,
                                                    child: const Icon(
                                                        Icons.image,
                                                        color: Colors.white)),
                                              )
                                            : Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey.shade800,
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                    Icons.play_circle_fill,
                                                    color: Colors.white,
                                                    size: 32),
                                              ),
                                      ),
                                      if (_mediaUploading[srvId] != true)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () => _removeMedia(
                                                srvId, mIdx, setStateDialog),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.close,
                                                  size: 12,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                      if (_mediaUploading[srvId] == true)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2563EB),
                              Color(0xFF1D4ED8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB)
                                  .withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _mediaUploading[srvId] == true
                              ? null
                              : () {
                                  setState(() {});
                                  Navigator.of(context).pop();
                                },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Save Service',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveAndContinue() async {
    // Validate that all services have a valid price
    for (var srv in _services) {
      final srvId = srv['id'] as int;
      final priceStr = _priceControllers[srvId]?.text.trim() ?? '';
      final price = double.tryParse(priceStr);
      if (price == null || price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid price for "${srv['title']}"'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final dio = di.sl<Dio>();

      // 1. Save each service's updated info
      for (var srv in _services) {
        final srvId = srv['id'] as int;
        final price = double.parse(_priceControllers[srvId]!.text.trim());
        final description = _descriptionControllers[srvId]!.text.trim();
        final negotiable = _negotiableState[srvId] ?? false;
        final media = _uploadedMedia[srvId]!;

        await dio.put(
          '/vendors/me/services/$srvId',
          data: {
            'price': price,
            'description': description,
            'negotiable': negotiable,
            'media': media
                .map((m) => {
                      'media_url': m['media_url'],
                      'media_type': m['media_type'],
                    })
                .toList(),
          },
        );
      }

      // 2. Confirm updates complete
      await dio.post('/vendors/me/services/confirm-updates');

      if (mounted) {
        // Fetch values for next screen navigation parameters
        final String firstName = _vendorProfile['first_name'] ?? 'Partner';
        final String lastName = _vendorProfile['last_name'] ?? '';
        final String businessName =
            _vendorProfile['business_name'] ?? '$firstName Services';
        final int mainCategoryId =
            _services.isNotEmpty ? (_services[0]['main_category_id'] ?? 1) : 1;

        context.go(
          '/vendor-availability',
          extra: {
            'mainCategoryId': mainCategoryId,
            'mainCategoryName': 'Services',
            'selectedSubCategories': const [],
            'selectedServiceTypes': const [],
            'firstName': firstName,
            'lastName': lastName,
            'businessName': businessName,
            'isSingleService': false,
            'isTelecallerOnboarded': true,
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save service details: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Update Your Services',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UPDATE SERVICE DETAILS',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap on a service to update price, description, photos and videos.',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double gridWidth = constraints.maxWidth;
                      final bool isWide = gridWidth > 600;
                      final int finalCols =
                          isWide ? (gridWidth / 260).floor().clamp(2, 5) : 2;
                      final double totalSpacing = (finalCols - 1) * 16;
                      final double cardWidth =
                          (gridWidth - totalSpacing) / finalCols;
                      final double targetHeight =
                          isWide ? 220.0 : (cardWidth / 0.85);
                      double finalRatio = cardWidth / targetHeight;
                      if (isWide) {
                        finalRatio = finalRatio.clamp(0.9, 1.3);
                      } else {
                        finalRatio = 0.82; // Mobile default
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: finalCols,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: finalRatio,
                        ),
                        itemCount: _services.length,
                        itemBuilder: (context, index) {
                          final srv = _services[index];
                          final srvId = srv['id'] as int;
                          final priceStr =
                              _priceControllers[srvId]?.text.trim() ?? '';
                          final bool hasPrice = priceStr.isNotEmpty &&
                              double.tryParse(priceStr) != null &&
                              double.parse(priceStr) > 0;

                          // Determine image to show
                          String? imageUrl;
                          if (_uploadedMedia[srvId]!.isNotEmpty) {
                            imageUrl =
                                _uploadedMedia[srvId]!.first['media_url'];
                          } else if (srv['media'] != null &&
                              (srv['media'] as List).isNotEmpty) {
                            imageUrl = srv['media'][0]['media_url'];
                          } else if (srv['image_url'] != null) {
                            imageUrl = srv['image_url'];
                          }

                          return GestureDetector(
                            onTap: () => _openServiceDialog(srv),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: hasPrice
                                      ? AppColors.primary
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : const Color(0xFFE2E8F0)),
                                  width: hasPrice ? 2.0 : 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                        alpha: isDark ? 0.25 : 0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: imageUrl != null &&
                                                    imageUrl.isNotEmpty
                                                ? AppNetworkImage(
                                                    imageUrl: Uri.encodeFull(
                                                        imageUrl.startsWith(
                                                                'http')
                                                            ? imageUrl
                                                            : 'http://76.13.245.174:8000${imageUrl.startsWith("/") ? "" : "/"}$imageUrl'),
                                                    fit: BoxFit.cover,
                                                    placeholder: Container(
                                                        color: Colors
                                                            .grey.shade300,
                                                        child: const Icon(
                                                            Icons.image,
                                                            color:
                                                                Colors.grey)),
                                                  )
                                                : Container(
                                                    color: Colors.grey.shade200,
                                                    child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.grey)),
                                          ),
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black.withValues(
                                                        alpha: isDark
                                                            ? 0.45
                                                            : 0.15),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            srv['title'] ?? 'Service',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.outfit(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF1E293B),
                                              height: 1.25,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  hasPrice
                                                      ? '₹$priceStr'
                                                      : 'Tap to set price',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 12.5,
                                                    fontWeight: hasPrice
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: hasPrice
                                                        ? AppColors.primary
                                                        : (isDark
                                                            ? Colors.white38
                                                            : Colors.black38),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Icon(
                                                Icons.edit,
                                                size: 16,
                                                color: AppColors.primary,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF2563EB).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveAndContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Save & Continue',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
