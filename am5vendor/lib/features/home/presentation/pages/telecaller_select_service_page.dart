import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../products/data/models/product_model.dart';
import '../../../supercategory/domain/entities/main_category.dart';
import '../../../supercategory/domain/entities/service_entity.dart';
import '../../../supercategory/presentation/bloc/service_bloc.dart';
import '../../../supercategory/presentation/bloc/service_event.dart';
import '../../../supercategory/presentation/bloc/service_state.dart';
import '../../../supercategory/presentation/providers/service_providers.dart';
import '../../data/models/telecaller_vendor_onboard_request_model.dart';
import '../../data/datasources/employee_api_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/widgets/app_network_image.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../supercategory/domain/usecases/upload_media_usecase.dart';
import '../../../supercategory/data/models/add_service_request_model.dart';

class TelecallerSelectServicePage extends ConsumerStatefulWidget {
  final String mobile;
  final TelecallerVendorOnboardRequestModel request;
  final MainCategory mainCategory;
  final List<SubCategoryItem> selectedSubCategories;
  final TelecallerCategoryRequest pendingCategory;

  const TelecallerSelectServicePage({
    super.key,
    required this.mobile,
    required this.request,
    required this.mainCategory,
    required this.selectedSubCategories,
    required this.pendingCategory,
  });

  @override
  ConsumerState<TelecallerSelectServicePage> createState() => _TelecallerSelectServicePageState();
}

class _TelecallerSelectServicePageState extends ConsumerState<TelecallerSelectServicePage> {
  final Map<int, TelecallerServiceRequest> _selectedServices = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceBlocProvider).add(
            FetchServices(
              mainCategoryId: widget.mainCategory.id,
              subcategoryIds:
                  widget.selectedSubCategories.map((s) => int.tryParse(s.id) ?? 0).toList(),
            ),
          );
    });
  }

  void _showServicePricingSheet(ServiceEntity service) {
    final isWide = MediaQuery.of(context).size.width > 600;

    if (isWide) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: _ServicePricingForm(
              service: service,
              existing: _selectedServices[service.id],
              onSave: (request) {
                setState(() {
                  _selectedServices[service.id] = request;
                });
              },
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: _ServicePricingForm(
              service: service,
              existing: _selectedServices[service.id],
              onSave: (request) {
                setState(() {
                  _selectedServices[service.id] = request;
                });
              },
            ),
          );
        },
      );
    }
  }


  Future<void> _saveCategoryServices() async {
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one service.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final services = _selectedServices.values.toList();
      await di.sl<EmployeeApiService>().telecallerSaveCategoryServices(
        widget.mobile,
        categories: [widget.pendingCategory],
        services: services,
      );

      final updatedRequest = widget.request.copyWith(
        categories: [...widget.request.categories, widget.pendingCategory],
        services: [...widget.request.services, ...services],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category and services saved. Add more or tap Continue.'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(updatedRequest);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bloc = ref.watch(serviceBlocProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        title: Text(
          'Select Services',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<ServiceBloc, ServiceState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is ServiceLoading || state is ServiceInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ServiceError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is ServiceSuccess) {
            final servicesList = state.services;

            if (servicesList.isEmpty) {
              return const Center(child: Text('No services found.'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium Page description
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CHOOSE FROM AVAILABLE SERVICES',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFF60A5FA)
                              : AppColors.primary,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Select one or more services and set their prices for this vendor',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),

                // Services Grid
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double gridWidth = constraints.maxWidth;
                          final bool isWide = gridWidth > 600;
                          
                          // Calculate dynamic columns based on width
                          final int finalCols = isWide
                              ? (gridWidth / 260).floor().clamp(2, 5)
                              : 2;
                              
                          final double totalSpacing = (finalCols - 1) * 16;
                          final double cardWidth = (gridWidth - totalSpacing) / finalCols;
                          
                          // Dynamically calculate aspect ratio for target height
                          final double targetHeight = isWide ? 220.0 : (cardWidth / 0.85);
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
                            itemCount: servicesList.length,
                            itemBuilder: (context, index) {
                              final service = servicesList[index];
                              final isSelected = _selectedServices.containsKey(service.id);
                              final selectedInfo = _selectedServices[service.id];

                              return _TelecallerServiceCard(
                                service: service,
                                isSelected: isSelected,
                                selectedInfo: selectedInfo,
                                isDark: isDark,
                                onTap: () => _showServicePricingSheet(service),
                                onRemove: () {
                                  setState(() => _selectedServices.remove(service.id));
                                },
                                imagePlaceholder:
                                    _buildImagePlaceholder(service.name, isDark),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                
                // Save and continue bottom bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: _selectedServices.isEmpty
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        color: _selectedServices.isEmpty
                            ? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05))
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _selectedServices.isEmpty
                            ? []
                            : [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : (_selectedServices.isEmpty
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please select at least one service to save.'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                : _saveCategoryServices),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Save & Add Another Category (${_selectedServices.length} Selected)',
                                style: GoogleFonts.outfit(
                                  color: _selectedServices.isEmpty
                                      ? (isDark ? Colors.white38 : Colors.black38)
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.0,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<Color> _getPlaceholderGradients(int hash, bool isDark) {
    final List<List<Color>> lightPalettes = [
      [const Color(0xFF60A5FA), const Color(0xFF2563EB)], // Blue
      [const Color(0xFFC084FC), const Color(0xFF8B5CF6)], // Purple
      [const Color(0xFFF472B6), const Color(0xFFDB2777)], // Pink
      [const Color(0xFF34D399), const Color(0xFF059669)], // Green
      [const Color(0xFFFB7185), const Color(0xFFE11D48)], // Rose
      [const Color(0xFFFBBF24), const Color(0xFFD97706)], // Amber
      [const Color(0xFF2DD4BF), const Color(0xFF0D9488)], // Teal
    ];

    final List<List<Color>> darkPalettes = [
      [const Color(0xFF1E3A8A).withValues(alpha: 0.8), const Color(0xFF2563EB).withValues(alpha: 0.6)],
      [const Color(0xFF581C87).withValues(alpha: 0.8), const Color(0xFF8B5CF6).withValues(alpha: 0.6)],
      [const Color(0xFF831843).withValues(alpha: 0.8), const Color(0xFFDB2777).withValues(alpha: 0.6)],
      [const Color(0xFF064E3B).withValues(alpha: 0.8), const Color(0xFF059669).withValues(alpha: 0.6)],
      [const Color(0xFF4C0519).withValues(alpha: 0.8), const Color(0xFFE11D48).withValues(alpha: 0.6)],
      [const Color(0xFF78350F).withValues(alpha: 0.8), const Color(0xFFD97706).withValues(alpha: 0.6)],
      [const Color(0xFF115E59).withValues(alpha: 0.8), const Color(0xFF0D9488).withValues(alpha: 0.6)],
    ];

    final palettes = isDark ? darkPalettes : lightPalettes;
    return palettes[hash.abs() % palettes.length];
  }

  IconData _getServiceIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('ac') || lower.contains('air condition') || lower.contains('cool') || lower.contains('refrigerator') || lower.contains('fridge')) {
      return Icons.ac_unit_rounded;
    }
    if (lower.contains('electr') || lower.contains('light') || lower.contains('fan') || lower.contains('wire') || lower.contains('power')) {
      return Icons.electric_bolt_rounded;
    }
    if (lower.contains('plumb') || lower.contains('water') || lower.contains('pipe') || lower.contains('leak') || lower.contains('tap')) {
      return Icons.plumbing_rounded;
    }
    if (lower.contains('clean') || lower.contains('wash') || lower.contains('maid') || lower.contains('sweep') || lower.contains('dust')) {
      return Icons.cleaning_services_rounded;
    }
    if (lower.contains('carpenter') || lower.contains('wood') || lower.contains('furniture') || lower.contains('table') || lower.contains('chair')) {
      return Icons.handyman_rounded;
    }
    if (lower.contains('paint') || lower.contains('wall') || lower.contains('color')) {
      return Icons.format_paint_rounded;
    }
    if (lower.contains('appliance') || lower.contains('tv') || lower.contains('television') || lower.contains('oven') || lower.contains('geyser')) {
      return Icons.home_repair_service_rounded;
    }
    if (lower.contains('garden') || lower.contains('plant') || lower.contains('lawn') || lower.contains('tree')) {
      return Icons.yard_rounded;
    }
    if (lower.contains('pest') || lower.contains('termite') || lower.contains('insect') || lower.contains('bug')) {
      return Icons.bug_report_rounded;
    }
    if (lower.contains('beauty') || lower.contains('salon') || lower.contains('hair') || lower.contains('makeup') || lower.contains('spa')) {
      return Icons.face_retouching_natural_rounded;
    }
    if (lower.contains('massage') || lower.contains('therapy') || lower.contains('physio')) {
      return Icons.spa_rounded;
    }
    if (lower.contains('construct') || lower.contains('build') || lower.contains('mason') || lower.contains('tile')) {
      return Icons.foundation_rounded;
    }
    return Icons.settings_suggest_rounded;
  }

  Widget _buildImagePlaceholder(String serviceName, bool isDark) {
    final int nameHash = serviceName.hashCode;
    final List<Color> gradients = _getPlaceholderGradients(nameHash, isDark);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradients,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          Icon(
            _getServiceIcon(serviceName),
            color: Colors.white.withValues(alpha: 0.9),
            size: 36,
          ),
        ],
      ),
    );
  }
}

class _ServicePricingForm extends StatefulWidget {
  final ServiceEntity service;
  final TelecallerServiceRequest? existing;
  final Function(TelecallerServiceRequest request) onSave;

  const _ServicePricingForm({
    required this.service,
    required this.existing,
    required this.onSave,
  });

  @override
  State<_ServicePricingForm> createState() => _ServicePricingFormState();
}

class _ServicePricingFormState extends State<_ServicePricingForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late bool _isNegotiable;

  // Media states
  final List<dynamic> _localImages = [];
  dynamic _localVideo;
  final _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.existing?.amount.toString() ?? '',
    );
    _isNegotiable = widget.existing?.isNegotiable ?? true;

    if (widget.existing != null) {
      for (var m in widget.existing!.media) {
        if (m.mediaType == 'video') {
          _localVideo = m;
        } else {
          _localImages.add(m);
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 600;

    final borderRadius = isWide
        ? BorderRadius.circular(28)
        : const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          );

    return Container(
      constraints: isWide ? const BoxConstraints(maxWidth: 520) : null,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: borderRadius,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                            color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.service.name,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
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
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  labelText: 'Service Price / Amount',
                  labelStyle: GoogleFonts.outfit(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                  floatingLabelStyle: GoogleFonts.outfit(
                    color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  hintText: 'Enter service cost...',
                  hintStyle: GoogleFonts.outfit(
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(
                      Icons.currency_rupee,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                      width: 2.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                      width: 1.2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                      width: 2.0,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final price = double.tryParse(value.trim());
                  if (price == null || price <= 0) {
                    return 'Please enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              // Custom choice cards for fixed vs negotiable
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isNegotiable = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: !_isNegotiable
                              ? (isDark
                                  ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                                  : AppColors.primary.withValues(alpha: 0.1))
                              : (isDark ? const Color(0xFF0F172A) : Colors.grey.shade50),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: !_isNegotiable
                                ? (isDark ? const Color(0xFF60A5FA) : AppColors.primary)
                                : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.grey.shade300),
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
                              color: !_isNegotiable
                                  ? (isDark ? const Color(0xFF60A5FA) : AppColors.primary)
                                  : (isDark ? Colors.white38 : Colors.black38),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Fixed Price',
                              style: GoogleFonts.outfit(
                                fontWeight: !_isNegotiable ? FontWeight.bold : FontWeight.normal,
                                color: !_isNegotiable
                                    ? (isDark ? const Color(0xFF60A5FA) : AppColors.primary)
                                    : (isDark ? Colors.white70 : Colors.black87),
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
                        setState(() {
                          _isNegotiable = true;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _isNegotiable
                              ? (isDark
                                  ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                                  : AppColors.primary.withValues(alpha: 0.1))
                              : (isDark ? const Color(0xFF0F172A) : Colors.grey.shade50),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _isNegotiable
                                ? (isDark ? const Color(0xFF60A5FA) : AppColors.primary)
                                : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.grey.shade300),
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
                              color: _isNegotiable
                                  ? (isDark ? const Color(0xFF60A5FA) : AppColors.primary)
                                  : (isDark ? Colors.white38 : Colors.black38),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Negotiable',
                              style: GoogleFonts.outfit(
                                fontWeight: _isNegotiable ? FontWeight.bold : FontWeight.normal,
                                color: _isNegotiable
                                    ? (isDark ? const Color(0xFF60A5FA) : AppColors.primary)
                                    : (isDark ? Colors.white70 : Colors.black87),
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
                  color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isUploading || _localImages.length >= 2
                          ? null
                          : () async {
                              final pickedFiles = await _picker.pickMultiImage();
                              if (pickedFiles.isNotEmpty) {
                                setState(() {
                                  for (var file in pickedFiles) {
                                    if (_localImages.length < 2) {
                                      _localImages.add(file);
                                    }
                                  }
                                });
                              }
                            },
                      icon: const Icon(Icons.image_rounded, size: 18),
                      label: Text('Images (${_localImages.length}/2)', style: GoogleFonts.outfit(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isUploading || _localVideo != null
                          ? null
                          : () async {
                              final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                setState(() {
                                  _localVideo = pickedFile;
                                });
                              }
                            },
                      icon: const Icon(Icons.videocam_rounded, size: 18),
                      label: Text(_localVideo == null ? 'Add Video' : '1 Video', style: GoogleFonts.outfit(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              // Previews
              if (_localImages.isNotEmpty || _localVideo != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._localImages.map((img) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: (img is XFile || img is File)
                                    ? (kIsWeb
                                        ? Image.network(img.path, width: 80, height: 80, fit: BoxFit.cover)
                                        : Image.file(img is File ? img : File(img.path), width: 80, height: 80, fit: BoxFit.cover))
                                    : AppNetworkImage(
                                        imageUrl: (img as MediaItemModel).mediaUrl.startsWith('http')
                                            ? img.mediaUrl
                                            : 'http://76.13.245.174:8000${img.mediaUrl.startsWith('/') ? '' : '/'}${img.mediaUrl}',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        placeholder: Container(color: Colors.grey.shade800),
                                      ),
                              ),
                              if (!_isUploading)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _localImages.remove(img);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                      if (_localVideo != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
                              ),
                              if (!_isUploading)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _localVideo = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isUploading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isUploading = true;
                      });

                      final navigator = Navigator.of(context);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      try {
                        final uploadUseCase = di.sl<UploadMediaUseCase>();
                        List<MediaItemModel> finalMedia = [];

                        // 1. Process images
                        for (var img in _localImages) {
                          if (img is MediaItemModel) {
                            finalMedia.add(img);
                          } else if (img is XFile) {
                            final uploadResult = await uploadUseCase(img);
                            uploadResult.fold(
                              (failure) => throw failure.message,
                              (mediaItem) => finalMedia.add(mediaItem),
                            );
                          } else if (img is File) {
                            final uploadResult = await uploadUseCase(XFile(img.path));
                            uploadResult.fold(
                              (failure) => throw failure.message,
                              (mediaItem) => finalMedia.add(mediaItem),
                            );
                          }
                        }

                        // 2. Process video
                        if (_localVideo != null) {
                          if (_localVideo is MediaItemModel) {
                            finalMedia.add(_localVideo);
                          } else if (_localVideo is XFile) {
                            final uploadResult = await uploadUseCase(_localVideo);
                            uploadResult.fold(
                              (failure) => throw failure.message,
                              (mediaItem) => finalMedia.add(mediaItem),
                            );
                          } else if (_localVideo is File) {
                            final uploadResult = await uploadUseCase(XFile(_localVideo.path));
                            uploadResult.fold(
                              (failure) => throw failure.message,
                              (mediaItem) => finalMedia.add(mediaItem),
                            );
                          }
                        }

                        final price = double.parse(_amountController.text.trim());

                        widget.onSave(TelecallerServiceRequest(
                          serviceId: widget.service.id.toString(),
                          amount: price,
                          discountedAmount: null,
                          isNegotiable: _isNegotiable,
                          media: finalMedia,
                        ));

                        navigator.pop();
                      } catch (error) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Upload failed: $error'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Save Service',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Stateful card widget representing each service in the telecaller selection grid.
class _TelecallerServiceCard extends StatefulWidget {
  final ServiceEntity service;
  final bool isSelected;
  final TelecallerServiceRequest? selectedInfo;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final Widget imagePlaceholder;

  const _TelecallerServiceCard({
    required this.service,
    required this.isSelected,
    this.selectedInfo,
    required this.isDark,
    required this.onTap,
    required this.onRemove,
    required this.imagePlaceholder,
  });

  @override
  State<_TelecallerServiceCard> createState() => _TelecallerServiceCardState();
}

class _TelecallerServiceCardState extends State<_TelecallerServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark
        ? (widget.isSelected ? const Color(0xFF1E293B) : const Color(0xFF1E1E2F))
        : (widget.isSelected ? const Color(0xFFEFF6FF) : Colors.white);
            
    final borderColor = widget.isSelected
        ? AppColors.primary
        : (widget.isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0));

    final shadowColor = widget.isSelected
        ? AppColors.primary.withValues(alpha: widget.isDark ? 0.3 : 0.15)
        : Colors.black.withValues(alpha: widget.isDark ? 0.25 : 0.04);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, _isHovered ? -6.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: widget.isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: _isHovered ? 20 : 12,
                offset: Offset(0, _isHovered ? 10 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Section
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: () {
                          final imageUrl = widget.service.imageUrl;
                          if (imageUrl == null || imageUrl.isEmpty) {
                            return widget.imagePlaceholder;
                          }
                          String resolvedUrl = imageUrl;
                          if (!resolvedUrl.startsWith('http') && !resolvedUrl.startsWith('assets/')) {
                            resolvedUrl = 'http://76.13.245.174:8000${resolvedUrl.startsWith('/') ? '' : '/'}$resolvedUrl';
                          }
                          if (resolvedUrl.startsWith('assets/')) {
                            return Image.asset(
                              resolvedUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, err, stack) => widget.imagePlaceholder,
                            );
                          } else {
                            return AppNetworkImage(
                              imageUrl: resolvedUrl,
                              fit: BoxFit.cover,
                              placeholder: widget.imagePlaceholder,
                            );
                          }
                        }(),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: widget.isDark ? 0.45 : 0.15),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      // Selected badge or delete button
                      if (widget.isSelected)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              widget.onRemove();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Bottom details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.service.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w600,
                          color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: widget.isSelected && widget.selectedInfo != null
                                ? Text(
                                    '₹${widget.selectedInfo!.amount}'
                                    '${widget.selectedInfo!.discountedAmount != null ? ' → ₹${widget.selectedInfo!.discountedAmount}' : ''}'
                                    ' · ${widget.selectedInfo!.isNegotiable ? 'Neg.' : 'Fix'}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    'Tap to set price',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: widget.isDark ? Colors.white38 : Colors.black38,
                                    ),
                                  ),
                          ),
                          if (!widget.isSelected)
                            const Icon(
                              Icons.add_circle_outline_rounded,
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
      ),
    );
  }
}
