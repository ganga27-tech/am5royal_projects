import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/constants/colors.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/auth/presentation/pages/login_page.dart';
import 'vendor_registration_page.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/map_screen_header.dart';
import '../widgets/categories_dashboard.dart';
import '../../data/models/product_model.dart';
import '../widgets/dynamic_subcategory_box.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../supercategory/data/datasources/main_category_api_service.dart';
import '../../../../core/services/onboarding_session_guard.dart';
import '../../../supercategory/domain/entities/main_category.dart';
import '../../../supercategory/presentation/pages/select_service_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../supercategory/presentation/providers/main_category_providers.dart';
import '../../../supercategory/presentation/bloc/main_category_bloc.dart';
import '../../../supercategory/presentation/bloc/main_category_state.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final PageController _pageController = PageController();
  bool _isMapView = true;
  List<SubCategoryItem> _selectedSubCategories = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    // Main categories load via mainCategoryBlocProvider; products API is legacy list view only.
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

  void _loadProductsIfNeeded() {
    final state = context.read<ProductBloc>().state;
    final alreadyLoaded = state.maybeWhen(
      loaded: (_, __) => true,
      orElse: () => false,
    );
    if (!alreadyLoaded) {
      context.read<ProductBloc>().add(const ProductEvent.loadProducts());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showProductDialog([Product? product]) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ProductFormDialog(product: product),
    );

    if (result != null && mounted) {
      if (product != null) {
        // Edit mode
        context.read<ProductBloc>().add(
              ProductEvent.updateProduct(
                id: product.id,
                name: result['name'],
                category: result['category'],
                price: result['price'],
                stock: result['stock'],
                description: result['description'],
                imageUrl: result['imageUrl'],
              ),
            );
      } else {
        // Create mode
        context.read<ProductBloc>().add(
              ProductEvent.createProduct(
                name: result['name'],
                category: result['category'],
                price: result['price'],
                stock: result['stock'],
                description: result['description'],
                imageUrl: result['imageUrl'],
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              state.maybeWhen(
                initial: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(fromLogout: true),
                    ),
                    (route) => false,
                  );
                },
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<ProductBloc, ProductState>(
            listener: (context, state) {
              if (_isMapView) return;
              state.maybeWhen(
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                },
                orElse: () {},
              );
            },
          ),
        ],
        child: _isMapView
            ? Consumer(
                builder: (context, ref, child) {
                  final bloc = ref.watch(mainCategoryBlocProvider);
                  return BlocBuilder<MainCategoryBloc, GetMainCategoriesState>(
                    bloc: bloc,
                    builder: (context, state) {
                      final apiCategories = state is GetMainCategoriesSuccess
                          ? state.categories
                          : null;
                      final categories = _getMappedCategories(apiCategories);
                      final isDesktop = MediaQuery.sizeOf(context).width > 900;

                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left: Map with floating categories on left and right sides
                            Expanded(
                              flex: 11,
                              child: Stack(
                                children: [
                                  // Map centered
                                  Positioned.fill(
                                    child: Container(
                                      color: isDark
                                          ? const Color(0xFF0F172A)
                                          : Colors.white,
                                      child: Center(
                                        child: InteractiveViewer(
                                          maxScale: 3.0,
                                          child: Image.asset(
                                            'assets/images/india_map.jpg',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Left floating categories list
                                  Positioned(
                                    left: 12,
                                    top: 40,
                                    bottom: 40,
                                    width: 75,
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      itemCount: (categories.length / 2).ceil(),
                                      itemBuilder: (context, index) {
                                        return _buildSideCategoryItem(
                                            categories[index]);
                                      },
                                    ),
                                  ),
                                  // Right floating categories list
                                  Positioned(
                                    right: 12,
                                    top: 40,
                                    bottom: 40,
                                    width: 75,
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      itemCount: categories.length ~/ 2,
                                      itemBuilder: (context, index) {
                                        return _buildSideCategoryItem(
                                            categories[index +
                                                (categories.length / 2)
                                                    .ceil()]);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Divider
                            VerticalDivider(
                              width: 1,
                              thickness: 1,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : const Color(0xFFE4E4E7),
                            ),
                            // Right: Search & Categories
                            Expanded(
                              flex: 9,
                              child: Container(
                                color: isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF9FAFB),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Custom header / search bar
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          24, 24, 24, 8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF1E293B)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.08)
                                                : const Color(0xFFE4E4E7),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF18181B)
                                                  .withValues(alpha: 0.04),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: TextField(
                                          controller: _searchController,
                                          onChanged: (value) {
                                            setState(() {
                                              _searchQuery = value;
                                            });
                                          },
                                          style: GoogleFonts.outfit(
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF18181B),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                          decoration: InputDecoration(
                                            hintText:
                                                'Search main categories...',
                                            hintStyle: GoogleFonts.outfit(
                                              color: isDark
                                                  ? Colors.white54
                                                  : const Color(0xFF71717A),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.search_rounded,
                                              color: isDark
                                                  ? Colors.white70
                                                  : const Color(0xFF71717A),
                                            ),
                                            suffixIcon: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (_searchQuery.isNotEmpty)
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.clear_rounded,
                                                      color: isDark
                                                          ? Colors.white70
                                                          : const Color(
                                                              0xFF71717A),
                                                    ),
                                                    onPressed: () {
                                                      _searchController.clear();
                                                      setState(() {
                                                        _searchQuery = '';
                                                      });
                                                    },
                                                  ),
                                                IconButton(
                                                  icon: Icon(
                                                    _isListening
                                                        ? Icons.mic_rounded
                                                        : Icons
                                                            .mic_none_rounded,
                                                    color: _isListening
                                                        ? Colors.redAccent
                                                        : (isDark
                                                            ? Colors.white70
                                                            : const Color(
                                                                0xFF71717A)),
                                                  ),
                                                  onPressed: _listenVoice,
                                                ),
                                              ],
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 12),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: CategoriesDashboard(
                                        searchQuery: _searchQuery,
                                        isBottomContainer: false,
                                        onCategoryTap: _handleCategoryTap,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return Stack(
                        children: [
                          // Background Map section
                          Positioned.fill(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height - 180,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      top: 90,
                                      child: Container(
                                        color: isDark
                                            ? const Color(0xFF0F172A)
                                            : Colors.white,
                                        child: Image.asset(
                                          'assets/images/india_map.jpg',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    // Left Categories List
                                    Positioned(
                                      left: 4,
                                      top: 120,
                                      bottom: 0,
                                      width: 70,
                                      child: ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        itemCount:
                                            (categories.length / 2).ceil(),
                                        itemBuilder: (context, index) {
                                          return _buildSideCategoryItem(
                                              categories[index]);
                                        },
                                      ),
                                    ),
                                    // Right Categories List
                                    Positioned(
                                      right: 4,
                                      top: 120,
                                      bottom: 0,
                                      width: 70,
                                      child: ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        itemCount: categories.length ~/ 2,
                                        itemBuilder: (context, index) {
                                          return _buildSideCategoryItem(
                                              categories[index +
                                                  (categories.length / 2)
                                                      .ceil()]);
                                        },
                                      ),
                                    ),
                                    // Floating Search Bar
                                    Positioned(
                                      top: 0,
                                      left: MediaQuery.of(context).size.width *
                                          0.1,
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: SafeArea(
                                        bottom: false,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0.0, vertical: 8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.15),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: BackdropFilter(
                                                filter: ui.ImageFilter.blur(
                                                    sigmaX: 12.0, sigmaY: 12.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: (isDark
                                                            ? Colors
                                                                .grey.shade900
                                                            : Colors.white)
                                                        .withValues(
                                                            alpha: 0.75),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    border: Border.all(
                                                      color: isDark
                                                          ? Colors.white
                                                              .withValues(
                                                                  alpha: 0.1)
                                                          : Colors.white
                                                              .withValues(
                                                                  alpha: 0.5),
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: TextField(
                                                    controller:
                                                        _searchController,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _searchQuery = value;
                                                      });
                                                    },
                                                    style: TextStyle(
                                                      color: isDark
                                                          ? Colors.white
                                                          : const Color(
                                                              0xFF1C1C1C),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                      letterSpacing: 0.3,
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Search main categories...',
                                                      hintStyle: TextStyle(
                                                        color: isDark
                                                            ? Colors.white54
                                                            : Colors.black45,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      prefixIcon: Icon(
                                                          Icons.search_rounded,
                                                          color: isDark
                                                              ? Colors.white70
                                                              : Colors.black87),
                                                      suffixIcon: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          if (_searchQuery
                                                              .isNotEmpty)
                                                            IconButton(
                                                              icon: Icon(
                                                                  Icons
                                                                      .clear_rounded,
                                                                  color: isDark
                                                                      ? Colors
                                                                          .white70
                                                                      : Colors
                                                                          .black87),
                                                              onPressed: () {
                                                                _searchController
                                                                    .clear();
                                                                setState(() {
                                                                  _searchQuery =
                                                                      '';
                                                                });
                                                              },
                                                            ),
                                                          IconButton(
                                                            icon: Icon(
                                                              _isListening
                                                                  ? Icons
                                                                      .mic_rounded
                                                                  : Icons
                                                                      .mic_none_rounded,
                                                              color: _isListening
                                                                  ? Colors
                                                                      .redAccent
                                                                  : (isDark
                                                                      ? Colors
                                                                          .white70
                                                                      : Colors
                                                                          .black87),
                                                            ),
                                                            onPressed:
                                                                _listenVoice,
                                                          ),
                                                        ],
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              vertical: 10,
                                                              horizontal: 10),
                                                      border: InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      filled: true,
                                                      fillColor:
                                                          Colors.transparent,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Expandable Bottom Sheet
                          DraggableScrollableSheet(
                            initialChildSize: 0.45,
                            minChildSize: 0.25,
                            maxChildSize: 0.88,
                            builder: (context, scrollController) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: (isDark
                                          ? const Color(0xFF0B1220)
                                          : const Color(0xFFF7FBFF))
                                      .withValues(alpha: 0.96),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(32),
                                  ),
                                  border: Border(
                                    top: BorderSide(
                                      color: (isDark
                                          ? Colors.white.withValues(alpha: 0.12)
                                          : Colors.black
                                              .withValues(alpha: 0.08)),
                                      width: 1.5,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.16),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                      offset: const Offset(0, -4),
                                    ),
                                  ],
                                ),
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 12),
                                      Center(
                                        child: Container(
                                          width: 38,
                                          height: 4.5,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.25)
                                                : Colors.black
                                                    .withValues(alpha: 0.18),
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      CategoriesDashboard(
                                        searchQuery: _searchQuery,
                                        isBottomContainer: true,
                                        onCategoryTap: _handleCategoryTap,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              )
            : Column(
                children: [
                  // Top custom header for Grid View
                  MapScreenHeader(
                    isMapView: _isMapView,
                    onToggleView: () {
                      setState(() {
                        _isMapView = !_isMapView;
                      });
                      if (!_isMapView) {
                        _loadProductsIfNeeded();
                      }
                    },
                    isFloating: false,
                  ),
                  //
                  // // Search & Category Header section
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //         child: TextField(
                  //           controller: _searchController,
                  //           onChanged: _onSearchChanged,
                  //           decoration: InputDecoration(
                  //             hintText: 'Search products, categories...',
                  //             prefixIcon: const Icon(Icons.search_rounded),
                  //             suffixIcon: _searchController.text.isNotEmpty
                  //                 ? IconButton(
                  //                     icon: const Icon(Icons.clear_rounded),
                  //                     onPressed: () {
                  //                       _searchController.clear();
                  //                       setState(() {
                  //                         _selectedSubCategories = [];
                  //                       });
                  //                       _onSearchChanged('');
                  //                     },
                  //                   )
                  //                 : null,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  //
                  // if (_selectedSubCategories.isNotEmpty)
                  //   Padding(
                  //     padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  //     child: Align(
                  //       alignment: Alignment.centerLeft,
                  //       child: Wrap(
                  //         spacing: 8,
                  //         runSpacing: 8,
                  //         children: _selectedSubCategories.map((sub) {
                  //           return Container(
                  //             padding: const EdgeInsets.symmetric(
                  //                 horizontal: 12, vertical: 6),
                  //             decoration: BoxDecoration(
                  //               color: sub.color.withValues(alpha: 0.1),
                  //               borderRadius: BorderRadius.circular(20),
                  //               border: Border.all(
                  //                 color: sub.color.withValues(alpha: 0.25),
                  //                 width: 1,
                  //               ),
                  //               boxShadow: [
                  //                 BoxShadow(
                  //                   color: sub.color.withValues(alpha: 0.03),
                  //                   blurRadius: 4,
                  //                   offset: const Offset(0, 2),
                  //                 ),
                  //               ],
                  //             ),
                  //             child: Row(
                  //               mainAxisSize: MainAxisSize.min,
                  //               children: [
                  //                 Container(
                  //                   padding: const EdgeInsets.all(3),
                  //                   decoration: BoxDecoration(
                  //                     shape: BoxShape.circle,
                  //                     color: sub.color.withValues(alpha: 0.1),
                  //                   ),
                  //                   child: Icon(
                  //                     sub.icon,
                  //                     color: sub.color,
                  //                     size: 12,
                  //                   ),
                  //                 ),
                  //                 const SizedBox(width: 6),
                  //                 Text(
                  //                   sub.title,
                  //                   style: TextStyle(
                  //                     color: sub.color,
                  //                     fontWeight: FontWeight.bold,
                  //                     fontSize: 11,
                  //                   ),
                  //                 ),
                  //                 const SizedBox(width: 6),
                  //                 GestureDetector(
                  //                   onTap: () {
                  //                     setState(() {
                  //                       _selectedSubCategories
                  //                           .removeWhere((item) => item.id == sub.id);
                  //                       if (_selectedSubCategories.isNotEmpty) {
                  //                         _searchController.text =
                  //                             _selectedSubCategories
                  //                                 .map((s) => s.title)
                  //                                 .join(', ');
                  //                       } else {
                  //                         _searchController.clear();
                  //                       }
                  //                       _onSearchChanged(_searchController.text);
                  //                     });
                  //                   },
                  //                   child: Icon(
                  //                     Icons.close_rounded,
                  //                     color: sub.color.withValues(alpha: 0.8),
                  //                     size: 14,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           );
                  //         }).toList(),
                  //       ),
                  //     ),
                  //   ),

                  // Product List Grid
                  Expanded(
                    child: BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, state) {
                        return state.maybeWhen(
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          loaded: (products, search) {
                            if (products.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 80,
                                      color: isDark
                                          ? AppColors.darkBorder
                                          : AppColors.border,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No products found',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Try searching for something else or add a new product.',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: () async {
                                context
                                    .read<ProductBloc>()
                                    .add(ProductEvent.loadProducts(
                                      search: _searchController.text.isEmpty
                                          ? null
                                          : _searchController.text,
                                    ));
                              },
                              child: GridView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 400,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.85,
                                ),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  return ProductCard(
                                    product: product,
                                    onTap: () {
                                      print("from map screen ");
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) =>
                                      //         ProductDetailPage(
                                      //             productId: product.id),
                                      //   ),
                                      // );
                                    },
                                    onEdit: () => _showProductDialog(product),
                                    onDelete: () {
                                      // Confirmation Dialog
                                      showDialog(
                                        context: context,
                                        builder: (dialogCtx) => AlertDialog(
                                          title: const Text('Delete Product'),
                                          content: Text(
                                              'Are you sure you want to delete "${product.name}"?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(dialogCtx),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(dialogCtx);
                                                context.read<ProductBloc>().add(
                                                    ProductEvent.deleteProduct(
                                                        product.id));
                                              },
                                              child: const Text('Delete',
                                                  style: TextStyle(
                                                      color: Colors.redAccent)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                          error: (message) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: Colors.redAccent, size: 60),
                                const SizedBox(height: 16),
                                Text('Error: $message',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<ProductBloc>()
                                        .add(const ProductEvent.loadProducts());
                                  },
                                  child: const Text('Retry'),
                                )
                              ],
                            ),
                          ),
                          actionInProgress: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          orElse: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: _isMapView
          ? null
          : Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _showProductDialog(),
                label: const Text(
                  'Add Product',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
    );
  }

  Widget _buildSideCategoryItem(CategoryItem category) {
    return GestureDetector(
      onTap: () => _handleCategoryTap(category),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(category.icon, color: category.color, size: 15),
            ),
            const SizedBox(height: 4),
            Text(
              category.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    required bool isDark,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withValues(alpha: 0.35),
            width: 1.5,
          ),
          color: color.withValues(alpha: 0.05),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    )
                  : Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CategoryItem> _getMappedCategories(List<MainCategory>? apiCategories) {
    if (apiCategories == null || apiCategories.isEmpty) {
      return ProductModel.categories;
    }
    return ProductModel.categories.map((staticCat) {
      final matches = apiCategories.where(
        (apiCat) =>
            apiCat.name.trim().toLowerCase() ==
            staticCat.title.trim().toLowerCase(),
      );
      final hasSub = matches.isNotEmpty
          ? matches.first.hasSubcategories
          : staticCat.hasSubcategories;
      final matchId =
          matches.isNotEmpty ? matches.first.id.toString() : staticCat.id;

      return CategoryItem(
        number: staticCat.number,
        title: staticCat.title,
        icon: staticCat.icon,
        color: staticCat.color,
        id: matchId,
        name: staticCat.name,
        description: staticCat.description,
        price: staticCat.price,
        stock: staticCat.stock,
        imageUrl: staticCat.imageUrl,
        category: staticCat.category,
        hasSubcategories: hasSub,
      );
    }).toList();
  }

  void _handleCategoryTap(CategoryItem category) {
    OnboardingSessionGuard.instance.unlockOnForwardProgress();
    if (!category.hasSubcategories) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkSurface : AppColors.background)
                  .withValues(alpha: 0.94),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border(
                top: BorderSide(
                  color: (isDark ? AppColors.darkBorder : AppColors.border)
                      .withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 30,
                  spreadRadius: 0,
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black26,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: category.color.withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                        ),
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        category.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "We are starting this category soon.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor: category.color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                            ),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
      return;
    }

    final mainCategory = MainCategory(
      id: int.tryParse(category.id) ?? 0,
      name: category.title,
      iconUrl: category.imageUrl,
      hasSubcategories: category.hasSubcategories,
    );

    final isDesktop = MediaQuery.sizeOf(context).width > 900;

    Future<bool?> serviceTypeFuture;
    if (isDesktop) {
      serviceTypeFuture = showDialog<bool>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.45),
        builder: (context) {
          String? loadingType;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final isInteractionDisabled = loadingType != null;
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE4E4E7),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Choose Service Type',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select how you want to offer your services',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Row(
                          children: [
                            Expanded(
                              child: _buildServiceTypeCard(
                                context,
                                title: 'INDIVIDUAL',
                                subtitle:
                                    'If you have single service register as Individual',
                                icon: Icons.person_outline_rounded,
                                color: AppColors.primary,
                                isLoading: loadingType == 'Individual',
                                onTap: isInteractionDisabled
                                    ? null
                                    : () async {
                                        setDialogState(() {
                                          loadingType = 'Individual';
                                        });
                                        await Future.delayed(
                                            const Duration(milliseconds: 500));
                                        if (context.mounted) {
                                          Navigator.pop(context, true);
                                        }
                                      },
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildServiceTypeCard(
                                context,
                                title: 'AGENCY',
                                subtitle:
                                    'If you have multiple services register as Agency',
                                icon: Icons.storefront_outlined,
                                color: AppColors.accent,
                                isLoading: loadingType == 'Business',
                                onTap: isInteractionDisabled
                                    ? null
                                    : () async {
                                        setDialogState(() {
                                          loadingType = 'Business';
                                        });
                                        await Future.delayed(
                                            const Duration(milliseconds: 500));
                                        if (context.mounted) {
                                          Navigator.pop(context, false);
                                        }
                                      },
                                isDark: isDark,
                              ),
                            ),
                          ],
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
    } else {
      serviceTypeFuture = showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          String? loadingType;
          return StatefulBuilder(
            builder: (context, setSheetState) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final isInteractionDisabled = loadingType != null;
              return Container(
                decoration: BoxDecoration(
                    color:
                        (isDark ? AppColors.darkSurface : AppColors.background)
                            .withValues(alpha: 0.94),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border(
                      top: BorderSide(
                        color:
                            (isDark ? AppColors.darkBorder : AppColors.border)
                                .withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 30,
                        spreadRadius: 0,
                      )
                    ]),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(32)),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white24 : Colors.black26,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Choose Service Type',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color:
                                  isDark ? Colors.white : AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select how you want to offer your services',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Column(
                            children: [
                              _buildServiceTypeCard(
                                context,
                                title: 'INDIVIDUAL',
                                subtitle:
                                    'If you have single service register as Individual',
                                icon: Icons.person_outline_rounded,
                                color: AppColors.primary,
                                isLoading: loadingType == 'Individual',
                                onTap: isInteractionDisabled
                                    ? null
                                    : () async {
                                        setSheetState(() {
                                          loadingType = 'Individual';
                                        });
                                        await Future.delayed(
                                            const Duration(milliseconds: 500));
                                        if (context.mounted) {
                                          Navigator.pop(context, true);
                                        }
                                      },
                                isDark: isDark,
                              ),
                              const SizedBox(height: 14),
                              _buildServiceTypeCard(
                                context,
                                title: 'AGENCY',
                                subtitle:
                                    'If you have multiple services register as Agency',
                                icon: Icons.storefront_outlined,
                                color: AppColors.accent,
                                isLoading: loadingType == 'Business',
                                onTap: isInteractionDisabled
                                    ? null
                                    : () async {
                                        setSheetState(() {
                                          loadingType = 'Business';
                                        });
                                        await Future.delayed(
                                            const Duration(milliseconds: 500));
                                        if (context.mounted) {
                                          Navigator.pop(context, false);
                                        }
                                      },
                                isDark: isDark,
                              ),
                            ],
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
    }

    serviceTypeFuture.then((isSingleService) {
      if (isSingleService == null || !context.mounted) return;

      if (category.hasSubcategories) {
        final categoryId = int.tryParse(category.id) ?? 0;
        context.push<List<SubCategoryItem>>(
          '/select-subcategory',
          extra: {
            'categoryId': categoryId,
            'superCategoryTitle': category.title,
            'mainCategory': mainCategory,
            'isSingleService': isSingleService,
            'initialSelectedSubCategories': _selectedSubCategories,
          },
        ).then((selectedList) {
          if (selectedList != null && context.mounted) {
            setState(() {
              _selectedSubCategories = selectedList;
              if (selectedList.isNotEmpty) {
                _searchController.text =
                    selectedList.map((s) => s.title).join(', ');
              } else {
                _searchController.text = category.title;
              }
            });
          }
        });
      } else {
        if (isSingleService) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VendorRegistrationPage(
                mainCategoryId: mainCategory.id,
                mainCategoryName: mainCategory.name,
                selectedSubCategories: const [],
                selectedServiceTypes: const [],
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectServicePage(
                mainCategory: mainCategory,
                selectedSubCategories: const [],
              ),
            ),
          );
        }
      }
    });
  }
}
