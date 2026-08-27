import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/services/onboarding_session_guard.dart';
import '../../../../core/constants/colors.dart';
import '../../../products/data/models/product_model.dart';
import '../../domain/entities/main_category.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../../domain/entities/service_entity.dart';
import '../bloc/service_bloc.dart';
import '../bloc/service_event.dart';
import '../bloc/service_state.dart';
import '../bloc/add_service_bloc.dart';
import '../bloc/add_service_event.dart';
import '../bloc/add_service_state.dart';
import '../providers/service_providers.dart';
import '../../../../core/widgets/app_network_image.dart';

class SelectServicePage extends ConsumerStatefulWidget {
  final MainCategory mainCategory;
  final List<SubCategoryEntity> selectedSubCategories;

  const SelectServicePage({
    super.key,
    required this.mainCategory,
    required this.selectedSubCategories,
  });

  @override
  ConsumerState<SelectServicePage> createState() => _SelectServicePageState();
}

class _SelectServicePageState extends ConsumerState<SelectServicePage> {
  final Map<int, double> _serviceAmounts = {};
  final Map<int, bool> _serviceIsNegotiable = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceBlocProvider).add(
            FetchServices(
              mainCategoryId: widget.mainCategory.id,
              subcategoryIds:
                  widget.selectedSubCategories.map((s) => s.id).toList(),
            ),
          );
    });
  }

  Future<void> _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (errorNotification) {
        if (mounted) {
          setState(() => _isListening = false);
          final err = errorNotification.errorMsg.toLowerCase();
          if (err.contains('timeout') ||
              err.contains('no_match') ||
              err.contains('no match') ||
              err.contains('client')) {
            return;
          }
        }
      },
    );
  }

  Future<void> _listenVoice() async {
    if (_isListening) {
      setState(() => _isListening = false);
      _speech.stop();
      return;
    }

    if (!_speech.isAvailable) {
      await _initSpeech();
    }

    if (_speech.isAvailable) {
      setState(() {
        _isListening = true;
        _searchController.clear();
        _searchQuery = '';
      });
      _speech.listen(
        onResult: (val) {
          if (mounted && val.recognizedWords.isNotEmpty) {
            setState(() {
              _searchController.text = val.recognizedWords;
              _searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: _searchController.text.length),
              );
              _searchQuery = val.recognizedWords.trim().toLowerCase();
            });
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 4),
          cancelOnError: false,
          partialResults: true,
          localeId: 'en_IN',
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition not available on this device.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToRegistration(List<SubCategoryItem> mappedSubs,
      List<SubSubCategoryItem> mappedServices) {
    context.go(
      '/vendor-registration',
      extra: {
        'mainCategoryId': widget.mainCategory.id,
        'mainCategoryName': widget.mainCategory.name,
        'selectedSubCategories': mappedSubs,
        'selectedServiceTypes': mappedServices,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bloc = ref.watch(serviceBlocProvider);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Select Service',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: (bloc.state is ServiceSuccess &&
                (bloc.state as ServiceSuccess).selectedServices.isNotEmpty)
            ? null
            : Container(
                margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  onPressed: () {
                    final hasServices = bloc.state is ServiceSuccess &&
                        (bloc.state as ServiceSuccess)
                            .selectedServices
                            .isNotEmpty;
                    if (context.canPop()) {
                      context.pop(hasServices);
                    } else {
                      Navigator.of(context).maybePop(hasServices);
                    }
                  },
                ),
              ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Glowing mesh background spheres for depth
          Positioned(
            top: -120,
            left: -120,
            child: IgnorePointer(
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2563EB)
                          .withValues(alpha: isDark ? 0.14 : 0.08),
                      const Color(0xFF2563EB).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -80,
            child: IgnorePointer(
              child: Container(
                width: 440,
                height: 440,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8B5CF6)
                          .withValues(alpha: isDark ? 0.12 : 0.06),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Splash background
          Positioned.fill(
            child: Image.asset(
              'assets/images/water.png',
              fit: BoxFit.cover,
              opacity: AlwaysStoppedAnimation(isDark ? 0.04 : 0.25),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDark
                        ? Colors.black.withValues(alpha: 0.65)
                        : Colors.white.withValues(alpha: 0.3),
                    isDark
                        ? Colors.black.withValues(alpha: 0.85)
                        : Colors.white.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: BlocListener<ServiceBloc, ServiceState>(
              bloc: bloc,
              listener: (context, state) {
                if (state is ServiceEmpty) {
                  _navigateToRegistration(const [], const []);
                }
              },
              child: BlocBuilder<ServiceBloc, ServiceState>(
                bloc: bloc,
                builder: (context, state) {
                  if (state is ServiceLoading || state is ServiceInitial) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 40),
                        margin: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B).withValues(alpha: 0.45)
                              : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                strokeWidth: 3.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Fetching matching services...',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Finding the best services for your selection',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is ServiceError) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        margin: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B).withValues(alpha: 0.45)
                              : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.error_outline_rounded,
                                color: Colors.redAccent,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Something went wrong',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                ref.read(serviceBlocProvider).add(
                                      FetchServices(
                                        mainCategoryId: widget.mainCategory.id,
                                        subcategoryIds: widget
                                            .selectedSubCategories
                                            .map((s) => s.id)
                                            .toList(),
                                      ),
                                    );
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is ServiceSuccess) {
                    final servicesList = state.services;
                    final selectedServices = state.selectedServices;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Page description
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
                                'Select one or more services you offer',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF475569),
                                ),
                              ),
                              if (widget.selectedSubCategories.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: widget.selectedSubCategories
                                      .map((sub) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF1E3A5F)
                                                  : AppColors.primary
                                                      .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isDark
                                                    ? const Color(0xFF60A5FA)
                                                    : AppColors.primary,
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Text(
                                              sub.name,
                                              style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? const Color(0xFF60A5FA)
                                                    : AppColors.primary,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                              const SizedBox(height: 14),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.06),
                                  ),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) {
                                    setState(() {
                                      _searchQuery = val.trim().toLowerCase();
                                    });
                                  },
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search available services...',
                                    hintStyle: GoogleFonts.outfit(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.black38,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      color: isDark
                                          ? const Color(0xFF60A5FA)
                                          : AppColors.primary,
                                      size: 20,
                                    ),
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            _isListening
                                                ? Icons.mic_rounded
                                                : Icons.mic_none_rounded,
                                            size: 20,
                                            color: _isListening
                                                ? Colors.redAccent
                                                : (isDark
                                                    ? const Color(0xFF60A5FA)
                                                    : AppColors.primary),
                                          ),
                                          onPressed: _listenVoice,
                                        ),
                                        if (_searchController.text.isNotEmpty)
                                          IconButton(
                                            icon: Icon(
                                              Icons.clear_rounded,
                                              size: 18,
                                              color: isDark
                                                  ? Colors.white54
                                                  : Colors.black45,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() {
                                                _searchQuery = '';
                                              });
                                            },
                                          ),
                                      ],
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Services Grid
                        Expanded(
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 1000),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final filteredServices = _searchQuery.isEmpty
                                      ? servicesList
                                      : servicesList
                                          .where((s) => s.name
                                              .toLowerCase()
                                              .contains(_searchQuery))
                                          .toList();

                                  if (filteredServices.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.search_off_rounded,
                                            size: 48,
                                            color: isDark
                                                ? Colors.white38
                                                : Colors.black38,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'No services found for "$_searchQuery"',
                                            style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              color: isDark
                                                  ? Colors.white60
                                                  : Colors.black54,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  final double gridWidth = constraints.maxWidth;
                                  final bool isWide = gridWidth > 600;

                                  // Calculate dynamic columns based on width
                                  final int finalCols = isWide
                                      ? (gridWidth / 240).floor().clamp(2, 5)
                                      : 2;

                                  final double totalSpacing =
                                      (finalCols - 1) * 16;
                                  final double cardWidth =
                                      (gridWidth - totalSpacing) / finalCols;

                                  // Dynamically calculate aspect ratio for target height
                                  final double targetHeight =
                                      isWide ? 190.0 : (cardWidth / 0.85);
                                  double finalRatio = cardWidth / targetHeight;
                                  if (isWide) {
                                    finalRatio = finalRatio.clamp(0.9, 1.4);
                                  } else {
                                    finalRatio = 0.85; // Mobile default
                                  }

                                  return GridView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    physics: const BouncingScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: finalCols,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: finalRatio,
                                    ),
                                    itemCount: filteredServices.length,
                                    itemBuilder: (context, index) {
                                      final service = filteredServices[index];
                                      final isSelected = selectedServices
                                          .any((s) => s.id == service.id);

                                      return _ServiceCard(
                                        service: service,
                                        isSelected: isSelected,
                                        isDark: isDark,
                                        onTap: () {
                                          if (isSelected) {
                                            // Call backend API to remove service from database
                                            ref
                                                .read(addServiceBlocProvider)
                                                .add(
                                                  SubmitRemoveService(
                                                      service.id),
                                                );
                                            // Optimistically toggle selection state in ServiceBloc
                                            ref.read(serviceBlocProvider).add(
                                                  ToggleServiceSelection(
                                                      service),
                                                );
                                          } else {
                                            _showPriceDialog(context, service);
                                          }
                                        },
                                        imagePlaceholder:
                                            _buildImagePlaceholder(
                                                service.name, isDark),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // Proceed Button
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              gradient: selectedServices.isEmpty
                                  ? null
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFF2563EB),
                                        Color(0xFF1D4ED8)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              color: selectedServices.isEmpty
                                  ? (isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.05))
                                  : null,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: selectedServices.isEmpty
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: const Color(0xFF2563EB)
                                            .withValues(alpha: 0.35),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                            ),
                            child: ElevatedButton(
                              onPressed: selectedServices.isEmpty
                                  ? () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please select at least one service to proceed.'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  : () {
                                      OnboardingSessionGuard.instance
                                          .unlockOnForwardProgress();
                                      context.pop(true);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                selectedServices.isEmpty
                                    ? 'CONTINUE'
                                    : 'CONTINUE (${selectedServices.length} SELECTED)',
                                style: GoogleFonts.outfit(
                                  color: selectedServices.isEmpty
                                      ? (isDark
                                          ? Colors.white38
                                          : Colors.black38)
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.0,
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
            ),
          ),
        ],
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
      [
        const Color(0xFF1E3A8A).withValues(alpha: 0.8),
        const Color(0xFF2563EB).withValues(alpha: 0.6)
      ],
      [
        const Color(0xFF581C87).withValues(alpha: 0.8),
        const Color(0xFF8B5CF6).withValues(alpha: 0.6)
      ],
      [
        const Color(0xFF831843).withValues(alpha: 0.8),
        const Color(0xFFDB2777).withValues(alpha: 0.6)
      ],
      [
        const Color(0xFF064E3B).withValues(alpha: 0.8),
        const Color(0xFF059669).withValues(alpha: 0.6)
      ],
      [
        const Color(0xFF4C0519).withValues(alpha: 0.8),
        const Color(0xFFE11D48).withValues(alpha: 0.6)
      ],
      [
        const Color(0xFF78350F).withValues(alpha: 0.8),
        const Color(0xFFD97706).withValues(alpha: 0.6)
      ],
      [
        const Color(0xFF115E59).withValues(alpha: 0.8),
        const Color(0xFF0D9488).withValues(alpha: 0.6)
      ],
    ];

    final palettes = isDark ? darkPalettes : lightPalettes;
    return palettes[hash.abs() % palettes.length];
  }

  IconData _getServiceIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('ac') ||
        lower.contains('air condition') ||
        lower.contains('cool') ||
        lower.contains('refrigerator') ||
        lower.contains('fridge')) {
      return Icons.ac_unit_rounded;
    }
    if (lower.contains('electr') ||
        lower.contains('light') ||
        lower.contains('fan') ||
        lower.contains('wire') ||
        lower.contains('power')) {
      return Icons.electric_bolt_rounded;
    }
    if (lower.contains('plumb') ||
        lower.contains('water') ||
        lower.contains('pipe') ||
        lower.contains('leak') ||
        lower.contains('tap')) {
      return Icons.plumbing_rounded;
    }
    if (lower.contains('clean') ||
        lower.contains('wash') ||
        lower.contains('maid') ||
        lower.contains('sweep') ||
        lower.contains('dust')) {
      return Icons.cleaning_services_rounded;
    }
    if (lower.contains('carpenter') ||
        lower.contains('wood') ||
        lower.contains('furniture') ||
        lower.contains('table') ||
        lower.contains('chair')) {
      return Icons.handyman_rounded;
    }
    if (lower.contains('paint') ||
        lower.contains('wall') ||
        lower.contains('color')) {
      return Icons.format_paint_rounded;
    }
    if (lower.contains('appliance') ||
        lower.contains('tv') ||
        lower.contains('television') ||
        lower.contains('oven') ||
        lower.contains('geyser')) {
      return Icons.home_repair_service_rounded;
    }
    if (lower.contains('garden') ||
        lower.contains('plant') ||
        lower.contains('lawn') ||
        lower.contains('tree')) {
      return Icons.yard_rounded;
    }
    if (lower.contains('pest') ||
        lower.contains('termite') ||
        lower.contains('insect') ||
        lower.contains('bug')) {
      return Icons.bug_report_rounded;
    }
    if (lower.contains('beauty') ||
        lower.contains('salon') ||
        lower.contains('hair') ||
        lower.contains('makeup') ||
        lower.contains('spa')) {
      return Icons.face_retouching_natural_rounded;
    }
    if (lower.contains('massage') ||
        lower.contains('therapy') ||
        lower.contains('physio')) {
      return Icons.spa_rounded;
    }
    if (lower.contains('construct') ||
        lower.contains('build') ||
        lower.contains('mason') ||
        lower.contains('tile')) {
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

  void _showPriceDialog(BuildContext context, ServiceEntity service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    bool isNegotiable = false;
    List<XFile> selectedImages = [];
    XFile? selectedVideo;
    final picker = ImagePicker();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Consumer(
              builder: (context, ref, child) {
                final addServiceBloc = ref.watch(addServiceBlocProvider);
                return Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(28),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header Row with Close Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        service.name,
                                        style: GoogleFonts.outfit(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1F2937),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => Navigator.pop(dialogCtx),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.black
                                              .withValues(alpha: 0.04),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Input field - Price (whole numbers only)
                            TextFormField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                              decoration: InputDecoration(
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
                                labelText: 'Service Price / Amount',
                                hintText: 'Enter service cost...',
                                hintStyle: GoogleFonts.outfit(
                                  color: isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF94A3B8),
                                  fontSize: 14,
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
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
                                    : const Color(0xFFF1F5F9)
                                        .withValues(alpha: 0.6),
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
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter an amount';
                                }
                                final trimmed = value.trim();
                                final price = int.tryParse(trimmed);
                                if (price == null) {
                                  return 'Please enter a valid whole number amount';
                                }
                                if (price <= 0) {
                                  return 'Amount must be greater than ₹0';
                                }
                                if (price > 1000000) {
                                  return 'Amount cannot exceed ₹10,00,000';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Custom fixed vs negotiable choice cards (replaces CheckboxListTile)
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setStateDialog(() {
                                        isNegotiable = false;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
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
                                                  ? Colors.white
                                                      .withValues(alpha: 0.12)
                                                  : Colors.grey.shade300),
                                          width: 1.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                        isNegotiable = true;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
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
                                                  ? Colors.white
                                                      .withValues(alpha: 0.12)
                                                  : Colors.grey.shade300),
                                          width: 1.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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

                            // Media Selection
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
                                    onPressed: () async {
                                      final pickedFiles =
                                          await picker.pickMultiImage();
                                      if (pickedFiles.isNotEmpty) {
                                        setStateDialog(() {
                                          selectedImages.addAll(pickedFiles);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.image_rounded,
                                        size: 18),
                                    label: Text(
                                        'Add Images (${selectedImages.length})'),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      backgroundColor: isDark
                                          ? const Color(0xFF2C2C2C)
                                          : Colors.grey.shade200,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: selectedVideo != null
                                        ? null
                                        : () async {
                                            final pickedFile =
                                                await picker.pickVideo(
                                                    source:
                                                        ImageSource.gallery);
                                            if (pickedFile != null) {
                                              final length =
                                                  await pickedFile.length();
                                              if (length > 10 * 1024 * 1024) {
                                                if (dialogCtx.mounted) {
                                                  ScaffoldMessenger.of(
                                                          dialogCtx)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: const Text(
                                                          'Video file size exceeds the 10 MB limit. Please select a smaller video.'),
                                                      backgroundColor:
                                                          Colors.orange.shade800,
                                                      behavior:
                                                          SnackBarBehavior.floating,
                                                    ),
                                                  );
                                                }
                                                return;
                                              }
                                              setStateDialog(() {
                                                selectedVideo = pickedFile;
                                              });
                                            }
                                          },
                                    icon: const Icon(Icons.videocam_rounded,
                                        size: 18),
                                    label: Text(selectedVideo == null
                                        ? 'Add Video'
                                        : '1 Video'),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      backgroundColor: isDark
                                          ? const Color(0xFF2C2C2C)
                                          : Colors.grey.shade200,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Show selected media
                            if (selectedImages.isNotEmpty ||
                                selectedVideo != null) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 80,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    ...selectedImages.map((img) => Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: kIsWeb
                                                    ? Image.network(img.path,
                                                        width: 80,
                                                        height: 80,
                                                        fit: BoxFit.cover)
                                                    : Image.file(File(img.path),
                                                        width: 80,
                                                        height: 80,
                                                        fit: BoxFit.cover),
                                              ),
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setStateDialog(() {
                                                      selectedImages
                                                          .remove(img);
                                                    });
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration:
                                                        const BoxDecoration(
                                                            color:
                                                                Colors.black54,
                                                            shape: BoxShape
                                                                .circle),
                                                    child: const Icon(
                                                        Icons.close,
                                                        size: 12,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                    if (selectedVideo != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade800,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                  Icons.play_circle_fill,
                                                  color: Colors.white,
                                                  size: 32),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setStateDialog(() {
                                                    selectedVideo = null;
                                                  });
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Colors.black54,
                                                          shape:
                                                              BoxShape.circle),
                                                  child: const Icon(Icons.close,
                                                      size: 12,
                                                      color: Colors.white),
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

                            // Bloc Consumer for submission state
                            BlocConsumer<AddServiceBloc, AddServiceState>(
                              bloc: addServiceBloc,
                              listener: (context, state) {
                                if (state is AddServiceSuccess &&
                                    state.serviceId == service.id) {
                                  OnboardingSessionGuard.instance
                                      .unlockOnForwardProgress();
                                  // Close dialog
                                  Navigator.pop(dialogCtx);

                                  // Save amount locally
                                  setState(() {
                                    _serviceAmounts[service.id] = state.amount;
                                    _serviceIsNegotiable[service.id] =
                                        isNegotiable;
                                  });

                                  // Toggle service selection in ServiceBloc (if not already selected)
                                  final serviceBloc =
                                      ref.read(serviceBlocProvider);
                                  final serviceState = serviceBloc.state;
                                  if (serviceState is ServiceSuccess) {
                                    final isSelected = serviceState
                                        .selectedServices
                                        .any((s) => s.id == service.id);
                                    if (!isSelected) {
                                      serviceBloc
                                          .add(ToggleServiceSelection(service));
                                    }
                                  }

                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded,
                                              color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text(state.response.message ??
                                              'Service added successfully!'),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else if (state is AddServiceError) {
                                  // Show error message as a SnackBar
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(state.message),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              builder: (context, state) {
                                final isLoading = state is AddServiceLoading;
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2563EB),
                                        Color(0xFF1D4ED8)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2563EB)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            if (formKey.currentState!
                                                .validate()) {
                                              final amount = (int.tryParse(
                                                          amountController.text
                                                              .trim()) ??
                                                      0)
                                                  .toDouble();
                                              addServiceBloc.add(
                                                SubmitAddService(
                                                  serviceId: service.id,
                                                  amount: amount,
                                                  isNegotiable: isNegotiable,
                                                  imageFiles: selectedImages,
                                                  videoFile: selectedVideo,
                                                ),
                                              );
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : Text(
                                            'SUBMIT',
                                            style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// Stateful card widget representing each service in the selection grid.
class _ServiceCard extends StatefulWidget {
  final ServiceEntity service;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  final Widget imagePlaceholder;

  const _ServiceCard({
    required this.service,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    required this.imagePlaceholder,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark
        ? (widget.isSelected
            ? const Color(0xFF1E293B)
            : const Color(0xFF1E1E2F))
        : (widget.isSelected ? const Color(0xFFEFF6FF) : Colors.white);

    final borderColor = widget.isSelected
        ? AppColors.primary
        : (widget.isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFE2E8F0));

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
          transform:
              Matrix4.translationValues(0.0, _isHovered ? -6.0 : 0.0, 0.0),
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
                          if (!resolvedUrl.startsWith('http') &&
                              !resolvedUrl.startsWith('assets/')) {
                            resolvedUrl =
                                'http://76.13.245.174:8000${resolvedUrl.startsWith('/') ? '' : '/'}$resolvedUrl';
                          }
                          if (resolvedUrl.startsWith('assets/')) {
                            return Image.asset(
                              resolvedUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, err, stack) =>
                                  widget.imagePlaceholder,
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
                                Colors.black.withValues(
                                    alpha: widget.isDark ? 0.45 : 0.15),
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
                // Bottom title section
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.service.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 13.5,
                            fontWeight: widget.isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: widget.isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: widget.isSelected
                                ? AppColors.primary
                                : (widget.isDark
                                    ? Colors.white30
                                    : const Color(0xFFCBD5E1)),
                            width: 1.5,
                          ),
                        ),
                        child: widget.isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 14,
                              )
                            : null,
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
