import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/seo/seo_metadata.dart';
import '../../../core/seo/seo_service.dart';
import '../../auth/services/auth_service.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_state.dart';
import '../../../widgets/service_image.dart';
import '../data/booking_api.dart';
import '../data/catalog_api.dart';
import '../data/location_api.dart';
import '../models/booking_models.dart';

class BookingFlowPage extends StatefulWidget {
  const BookingFlowPage({super.key});

  @override
  State<BookingFlowPage> createState() => _BookingFlowPageState();
}

class _BookingFlowPageState extends State<BookingFlowPage> {
  final CatalogApi _catalogApi = CatalogApi();
  final BookingApi _bookingApi = BookingApi();
  final LocationApi _locationApi = LocationApi();

  int _step = 0;
  bool _loading = true;
  String? _error;

  List<ServiceCategory> _categories = [];
  List<ServiceSubcategory> _subcategories = [];
  List<ServicePackage> _packages = [];
  List<VendorInfo> _vendors = [];
  List<VendorServiceOffering> _vendorServices = [];
  List<String> _slots = [];
  List<CustomerAddress> _addresses = [];

  ServiceCategory? _selectedCategory;
  ServiceSubcategory? _selectedSubcategory;
  ServicePackage? _selectedPackage;
  VendorInfo? _selectedVendor;
  VendorServiceOffering? _selectedVendorService;
  int? _vendorProfileId;
  DateTime? _selectedDate;
  String? _selectedSlot;
  CustomerAddress? _selectedAddress;
  double _totalAmount = 0;
  BookingConfirmation? _confirmation;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  String _addressLabel = 'HOME';
  bool _showNewAddressForm = false;
  bool _submitting = false;
  bool _usingLocationForVendors = false;

  @override
  void initState() {
    super.initState();
    SeoService.applyMetadata(SeoMetadata.booking);
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _categories = await _catalogApi.getCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _selectCategory(ServiceCategory category) async {
    setState(() {
      _selectedCategory = category;
      _selectedSubcategory = null;
      _selectedPackage = null;
      _loading = true;
      _error = null;
    });
    try {
      _subcategories = await _catalogApi.getSubcategories(
        categoryId: category.id,
      );
      if (_subcategories.isEmpty) {
        _packages = await _catalogApi.getPackages(categoryId: category.id);
      }
      _step = 1;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<CustomerAddress?> _resolveBookingAddress() async {
    if (!AuthService.instance.isAuthenticated) {
      return _selectedAddress;
    }

    if (_addresses.isEmpty) {
      try {
        _addresses = await _locationApi.getAddresses();
      } catch (_) {
        return _selectedAddress;
      }
    }

    return _addresses.where((a) => a.isDefault).firstOrNull ??
        _addresses.firstOrNull ??
        _selectedAddress;
  }

  Future<void> _loadVendorsForSelection({int? subcategoryId}) async {
    final CustomerAddress? address = await _resolveBookingAddress();
    _selectedAddress = address;

    final double? latitude = address?.latitude;
    final double? longitude = address?.longitude;
    final String? pincode = address?.pincode;

    _usingLocationForVendors =
        latitude != null && longitude != null || (pincode?.isNotEmpty ?? false);

    _vendors = await _catalogApi.getVendors(
      categoryId: _selectedCategory?.id,
      subcategoryId: subcategoryId ?? _selectedSubcategory?.id,
      latitude: latitude,
      longitude: longitude,
      pincode: pincode,
    );
  }

  Future<void> _selectSubcategory(ServiceSubcategory sub) async {
    setState(() {
      _selectedSubcategory = sub;
      _loading = true;
      _error = null;
    });
    try {
      _packages = await _catalogApi.getPackages(subcategoryId: sub.id);
      if (_packages.isEmpty) {
        await _loadVendorsForSelection(subcategoryId: sub.id);
        _step = 2;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectPackage(ServicePackage pkg) async {
    setState(() {
      _selectedPackage = pkg;
      _loading = true;
      _error = null;
    });
    try {
      await _loadVendorsForSelection(
        subcategoryId: _selectedSubcategory?.id ?? pkg.subcategoryId,
      );
      _step = 2;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectVendor(VendorInfo vendor) async {
    setState(() {
      _selectedVendor = vendor;
      _selectedVendorService = null;
      _loading = true;
      _error = null;
    });
    try {
      _vendorProfileId = await _catalogApi.getVendorProfileId(vendor.id);
      _vendorServices = await _catalogApi.getVendorServices(
        vendorId: vendor.id,
        categoryId: _selectedCategory?.id,
        subcategoryId: _selectedSubcategory?.id,
      );
      if (_vendorServices.isEmpty) {
        _error = 'This vendor has no services listed for the selected category.';
        return;
      }
      _step = 3;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectVendorService(VendorServiceOffering service) async {
    setState(() {
      _selectedVendorService = service;
      _loading = true;
      _error = null;
    });
    try {
      _addresses = await _locationApi.getAddresses();
      _selectedAddress =
          _addresses.where((a) => a.isDefault).firstOrNull ?? _addresses.firstOrNull;
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      _step = 4;
      await _loadSlots();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadSlots() async {
    if (_selectedDate == null) return;
    final String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    try {
      _slots = await _bookingApi.getAvailableSlots(
        professionId: _selectedCategory?.id,
        serviceIds: _selectedVendorService != null
            ? [_selectedVendorService!.subCategoryId]
            : _selectedSubcategory != null
                ? [_selectedSubcategory!.id]
                : null,
        packageIds: _selectedPackage?.numericId != null &&
                _selectedPackage!.numericId > 0
            ? [_selectedPackage!.numericId]
            : null,
        addressId: _selectedAddress?.id,
        serviceDate: dateStr,
        customerId: AuthService.instance.profile?.id,
      );
      if (_slots.isNotEmpty) {
        _selectedSlot = _slots.first;
      }
    } catch (_) {
      _slots = ['08:30-11:30', '11:30-14:30', '14:30-17:30'];
      _selectedSlot = _slots.first;
    }
    if (mounted) setState(() {});
  }

  Future<void> _goToReview() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a service address.')),
      );
      return;
    }
    if (_selectedDate == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time.')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final Map<String, dynamic> calc = await _bookingApi.calculateOrder(
        addressId: _selectedAddress!.id,
        packages: [
          {
            'packageId': _selectedPackage?.numericId ?? 0,
            'packageAmount': _selectedServicePrice,
            'quantity': 1,
          },
        ],
      );
      _totalAmount = (calc['totalAmount'] as num?)?.toDouble() ??
          _selectedServicePrice;
      _step = 5;
    } catch (e) {
      _totalAmount = _selectedServicePrice;
      _step = 5;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedAddress == null ||
        _selectedDate == null ||
        _selectedSlot == null) {
      return;
    }

    setState(() => _submitting = true);
    try {
      final List<String> parts = _selectedSlot!.split('-');
      final String startTime = parts.first.trim();
      final List<String> timeParts = startTime.split(':');
      final DateTime scheduled = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      final List<Map<String, dynamic>> items = [];
      if (_selectedPackage != null && _selectedPackage!.numericId > 0) {
        items.add({
          'package_id': _selectedPackage!.numericId,
          'quantity': 1,
          'unit_price': _selectedPackage!.price,
        });
      } else if (_selectedVendorService != null) {
        items.add({
          'subcategory_id': _selectedVendorService!.subCategoryId,
          'quantity': 1,
          'unit_price': _selectedVendorService!.effectivePrice,
        });
      } else if (_selectedSubcategory != null) {
        items.add({
          'subcategory_id': _selectedSubcategory!.id,
          'quantity': 1,
          'unit_price': _selectedServicePrice,
        });
      }

      _confirmation = await _bookingApi.createBooking(
        addressId: _selectedAddress!.id,
        paymentMethod: 'COD',
        items: items,
        scheduledAt: scheduled,
        vendorProfileId: _vendorProfileId,
      );
      _step = 6;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _saveNewAddress() async {
    if (_addressLine1Controller.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _stateController.text.trim().isEmpty ||
        _pincodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all address fields.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final CustomerAddress address = await _locationApi.createAddress(
        label: _addressLabel,
        addressLine1: _addressLine1Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
      );
      _addresses = [..._addresses, address];
      _selectedAddress = address;
      _showNewAddressForm = false;
      await _loadSlots();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool desktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF9EBD1),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(_stepTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _step > 0 && _step < 6 ? _goBack : () => Navigator.pop(context),
        ),
      ),
      body: Row(
        children: [
          Expanded(
            child: _loading
                ? const LoadingState(showSkeleton: true)
                : _error != null
                    ? ErrorState(message: _error!, onRetry: _loadCategories)
                    : _buildStepContent(),
          ),
          if (desktop && _step < 6) _buildSummaryPanel(),
        ],
      ),
    );
  }

  String get _stepTitle {
    switch (_step) {
      case 0:
        return 'Select Service';
      case 1:
        if (_subcategories.isNotEmpty && _selectedSubcategory == null) {
          return 'Choose Service';
        }
        return 'Choose Package';
      case 2:
        return 'Select Vendor';
      case 3:
        return 'Choose Service';
      case 4:
        return 'Booking Details';
      case 5:
        return 'Review Booking';
      case 6:
        return 'Booking Confirmed';
      default:
        return 'Book a Service';
    }
  }

  String get _selectedServiceName =>
      _selectedVendorService?.title ??
      _selectedPackage?.title ??
      _selectedSubcategory?.name ??
      _selectedCategory?.name ??
      '';

  double get _selectedServicePrice =>
      _selectedVendorService?.effectivePrice ??
      _selectedPackage?.price ??
      0;

  void _goBack() {
    setState(() {
      _error = null;
      if (_step == 1 && _selectedSubcategory != null) {
        _selectedSubcategory = null;
        _packages = [];
        return;
      }
      if (_step == 3) {
        _selectedVendor = null;
        _vendorServices = [];
        _selectedVendorService = null;
      }
      if (_step == 4) {
        _selectedVendorService = null;
      }
      if (_step > 0) {
        _step--;
      }
    });
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildCategoryStep();
      case 1:
        return _buildPackageStep();
      case 2:
        return _buildVendorStep();
      case 3:
        return _buildVendorServicesStep();
      case 4:
        return _buildDetailsStep();
      case 5:
        return _buildReviewStep();
      case 6:
        return _buildConfirmationStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCategoryStep() {
    final String query = _searchController.text.trim().toLowerCase();
    final List<ServiceCategory> filtered = _categories
        .where((c) => c.name.toLowerCase().contains(query))
        .toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        title: 'No services available',
        subtitle: 'Please try again later or contact support.',
        icon: Icons.home_repair_service_outlined,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search services...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 3 : 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.82,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final ServiceCategory cat = filtered[index];
              return _SelectableCard(
                title: cat.name,
                subtitle: cat.description,
                imageUrl: cat.iconUrl,
                selected: _selectedCategory?.id == cat.id,
                layout: _CardLayout.grid,
                onTap: () => _selectCategory(cat),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPackageStep() {
    if (_subcategories.isNotEmpty && _selectedSubcategory == null) {
      return GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 3 : 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.82,
        ),
        itemCount: _subcategories.length,
        itemBuilder: (context, index) {
          final ServiceSubcategory sub = _subcategories[index];
          return _SelectableCard(
            title: sub.name,
            subtitle: sub.description,
            imageUrl: sub.iconUrl,
            layout: _CardLayout.grid,
            onTap: () => _selectSubcategory(sub),
          );
        },
      );
    }

    if (_packages.isEmpty) {
      return EmptyState(
        title: 'No packages available',
        subtitle: 'Try a different service category.',
        icon: Icons.inventory_2_outlined,
        actionLabel: 'Go Back',
        onAction: _goBack,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _packages.length,
      itemBuilder: (context, index) {
        final ServicePackage pkg = _packages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _SelectableCard(
            title: pkg.title,
            subtitle: pkg.description,
            imageUrl: pkg.heroImage,
            price: '₹${pkg.price.toStringAsFixed(0)}',
            selected: _selectedPackage?.id == pkg.id,
            layout: _CardLayout.list,
            onTap: () => _selectPackage(pkg),
          ),
        );
      },
    );
  }

  Widget _buildVendorStep() {
    if (_vendors.isEmpty) {
      return EmptyState(
        title: 'No vendors available',
        subtitle: _usingLocationForVendors
            ? 'No service providers found within 70 km for this service.'
            : 'Add a service address or log in to find nearby providers.',
        icon: Icons.person_search_outlined,
        actionLabel: 'Choose Another Service',
        onAction: () => setState(() => _step = 0),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _vendors.length + (_usingLocationForVendors ? 1 : 0),
      itemBuilder: (context, index) {
        if (_usingLocationForVendors && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.near_me_rounded, color: AppColors.royalBlue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing nearest providers first. Search expands up to 70 km.',
                      style: TextStyle(
                        color: AppColors.heading,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final int vendorIndex = _usingLocationForVendors ? index - 1 : index;
        final VendorInfo vendor = _vendors[vendorIndex];
        final List<String> meta = [
          if (vendor.operatingCity != null) vendor.operatingCity!,
          if (vendor.distanceKm != null)
            '${vendor.distanceKm!.toStringAsFixed(1)} km away',
          if (vendor.avgRating != null)
            '${vendor.avgRating!.toStringAsFixed(1)} ★',
          if (vendor.yearsOfExperience != null)
            '${vendor.yearsOfExperience} yrs exp',
        ];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _SelectableCard(
            title: vendor.businessName,
            subtitle: meta.join(' • '),
            imageUrl: vendor.photoUrl,
            selected: _selectedVendor?.id == vendor.id,
            layout: _CardLayout.list,
            onTap: () => _selectVendor(vendor),
          ),
        );
      },
    );
  }

  Widget _buildVendorServicesStep() {
    if (_vendorServices.isEmpty) {
      return EmptyState(
        title: 'No services available',
        subtitle: 'This vendor has not listed services for this category yet.',
        icon: Icons.handyman_outlined,
        actionLabel: 'Choose Another Vendor',
        onAction: _goBack,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _vendorServices.length,
      itemBuilder: (context, index) {
        final VendorServiceOffering service = _vendorServices[index];
        final String priceLabel = service.negotiable
            ? 'Starting from ₹${service.effectivePrice.toStringAsFixed(0)}'
            : '₹${service.effectivePrice.toStringAsFixed(0)}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _SelectableCard(
            title: service.title,
            subtitle: service.description,
            imageUrl: service.imageUrl,
            price: priceLabel,
            badge: service.pricingLabel,
            badgeColor: service.negotiable
                ? const Color(0xFFFFF3E0)
                : const Color(0xFFE8F5E9),
            badgeTextColor: service.negotiable
                ? const Color(0xFFE65100)
                : const Color(0xFF2E7D32),
            selected: _selectedVendorService?.id == service.id,
            layout: _CardLayout.list,
            onTap: () => _selectVendorService(service),
          ),
        );
      },
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Select Date',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
                await _loadSlots();
              }
            },
            icon: const Icon(Icons.calendar_today_rounded),
            label: Text(
              _selectedDate != null
                  ? DateFormat('EEE, d MMM yyyy').format(_selectedDate!)
                  : 'Pick a date',
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Available Time Slots',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 10),
          if (_slots.isEmpty)
            const Text('No slots available for this date.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _slots.map((slot) {
                final bool selected = _selectedSlot == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedSlot = slot),
                  selectedColor: AppColors.royalBlue.withValues(alpha: 0.15),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Service Address',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.heading,
                ),
              ),
              TextButton(
                onPressed: () =>
                    setState(() => _showNewAddressForm = !_showNewAddressForm),
                child: Text(_showNewAddressForm ? 'Cancel' : 'Add New'),
              ),
            ],
          ),
          if (_showNewAddressForm) ...[
            _buildAddressForm(),
          ] else if (_addresses.isEmpty) ...[
            const Text('No saved addresses. Please add one.'),
            const SizedBox(height: 10),
            _buildAddressForm(),
          ] else ...[
            ..._addresses.map((address) {
              return RadioListTile<CustomerAddress>(
                value: address,
                groupValue: _selectedAddress,
                onChanged: (value) => setState(() => _selectedAddress = value),
                title: Text(address.label),
                subtitle: Text(address.fullAddress),
              );
            }),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Additional notes (optional)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _goToReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.royalBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continue to Review',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _addressLabel,
          items: const [
            DropdownMenuItem(value: 'HOME', child: Text('Home')),
            DropdownMenuItem(value: 'OFFICE', child: Text('Office')),
            DropdownMenuItem(value: 'OTHER', child: Text('Other')),
          ],
          onChanged: (v) => setState(() => _addressLabel = v ?? 'HOME'),
          decoration: InputDecoration(
            labelText: 'Label',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _addressLine1Controller,
          decoration: InputDecoration(
            labelText: 'Address',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _cityController,
          decoration: InputDecoration(
            labelText: 'City',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _stateController,
          decoration: InputDecoration(
            labelText: 'State',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _pincodeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            labelText: 'Pincode',
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _saveNewAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.royalBlue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save Address'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryCard(
            service: _selectedServiceName,
            vendor: _selectedVendor?.businessName ?? '',
            date: _selectedDate != null
                ? DateFormat('EEE, d MMM yyyy').format(_selectedDate!)
                : '',
            time: _selectedSlot ?? '',
            address: _selectedAddress?.fullAddress ?? '',
            amount: _totalAmount,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitting ? null : _confirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: AppColors.navy,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Text(
                    'CONFIRM BOOKING',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0x1416805A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Booking Confirmed',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Booking ID: ${_confirmation?.orderId ?? ''}',
              style: const TextStyle(
                color: AppColors.mutedText,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _SummaryCard(
              service: _selectedServiceName,
              vendor: _selectedVendor?.businessName ?? '',
              date: _selectedDate != null
                  ? DateFormat('EEE, d MMM yyyy').format(_selectedDate!)
                  : '',
              time: _selectedSlot ?? '',
              address: _selectedAddress?.fullAddress ?? '',
              amount: _totalAmount,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Home'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.royalBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPanel() {
    return Container(
      width: 320,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: _SummaryCard(
        service: _selectedServiceName.isNotEmpty
            ? _selectedServiceName
            : _selectedCategory?.name ?? '',
        vendor: _selectedVendor?.businessName ?? 'Not selected',
        date: _selectedDate != null
            ? DateFormat('d MMM yyyy').format(_selectedDate!)
            : 'Not selected',
        time: _selectedSlot ?? 'Not selected',
        address: _selectedAddress?.fullAddress ?? 'Not selected',
        amount: _totalAmount > 0 ? _totalAmount : _selectedServicePrice,
      ),
    );
  }
}

enum _CardLayout { grid, list }

class _SelectableCard extends StatelessWidget {
  const _SelectableCard({
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.price,
    this.badge,
    this.badgeColor,
    this.badgeTextColor,
    this.selected = false,
    this.layout = _CardLayout.list,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? price;
  final String? badge;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final bool selected;
  final _CardLayout layout;
  final VoidCallback onTap;

  Widget _imageArea() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.iceBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ServiceImage(
        imageUrl: imageUrl,
        name: title,
        fit: BoxFit.contain,
        iconSize: 40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.royalBlue : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.royalBlue.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: layout == _CardLayout.grid
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _imageArea()),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.heading,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    if (price != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        price!,
                        style: const TextStyle(
                          color: AppColors.royalBlue,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: _imageArea(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.heading,
                              fontSize: 15,
                            ),
                          ),
                          if (subtitle != null && subtitle!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (badge != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor ?? AppColors.iceBlue,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                badge!,
                                style: TextStyle(
                                  color: badgeTextColor ?? AppColors.royalBlue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          if (price != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              price!,
                              style: const TextStyle(
                                color: AppColors.royalBlue,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.service,
    required this.vendor,
    required this.date,
    required this.time,
    required this.address,
    required this.amount,
  });

  final String service;
  final String vendor;
  final String date;
  final String time;
  final String address;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Booking Summary',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: AppColors.heading,
          ),
        ),
        const SizedBox(height: 14),
        _row('Service', service),
        _row('Vendor', vendor),
        _row('Date', date),
        _row('Time', time),
        _row('Address', address),
        const Divider(height: 24),
        _row('Amount', '₹${amount.toStringAsFixed(0)}', bold: true),
      ],
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.mutedText,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.heading,
                fontSize: 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}
