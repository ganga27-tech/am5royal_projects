import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_ui/am5_ui.dart';

import '../cubit/address_cubit.dart';
import 'map_pin_picker_page.dart';

class AddressFormPage extends StatefulWidget {
  const AddressFormPage({super.key, this.addressId});

  final String? addressId;

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final AddressCubit _cubit;
  String _label = 'home';
  final _labelCustom = TextEditingController();
  final _line1 = TextEditingController();
  final _line2 = TextEditingController();
  final _landmark = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _postal = TextEditingController();
  bool _isDefault = false;
  bool _loadingExisting = false;
  String? _serviceabilityHint;
  bool _serviceable = false;
  double? _latitude;
  double? _longitude;

  bool get _isEdit => widget.addressId != null;

  @override
  void initState() {
    super.initState();
    _cubit = AddressCubit(context.read<AddressApi>());
    if (_isEdit) {
      _loadingExisting = true;
      _hydrate();
    }
  }

  Future<void> _hydrate() async {
    await _cubit.load();
    final match = _cubit.state.addresses.where((a) => a.id == widget.addressId).firstOrNull;
    if (match != null && mounted) {
      setState(() {
        _label = match.label;
        _labelCustom.text = match.labelCustom ?? '';
        _line1.text = match.line1;
        _line2.text = match.line2 ?? '';
        _landmark.text = match.landmark ?? '';
        _city.text = match.city;
        _state.text = match.state;
        _postal.text = match.postalCode;
        _isDefault = match.isDefault;
        _serviceable = match.isServiceable;
        _latitude = match.latitude;
        _longitude = match.longitude;
        _loadingExisting = false;
      });
    } else if (mounted) {
      setState(() => _loadingExisting = false);
    }
  }

  @override
  void dispose() {
    _labelCustom.dispose();
    _line1.dispose();
    _line2.dispose();
    _landmark.dispose();
    _city.dispose();
    _state.dispose();
    _postal.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _check() async {
    final result = await _cubit.checkServiceability(
      city: _city.text.trim(),
      postalCode: _postal.text.trim(),
    );
    if (!mounted || result == null) return;
    setState(() {
      _serviceable = result.serviceable;
      _serviceabilityHint = result.message;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final body = <String, dynamic>{
      'label': _label,
      if (_label == 'other') 'label_custom': _labelCustom.text.trim(),
      'line1': _line1.text.trim(),
      if (_line2.text.trim().isNotEmpty) 'line2': _line2.text.trim(),
      if (_landmark.text.trim().isNotEmpty) 'landmark': _landmark.text.trim(),
      'city': _city.text.trim(),
      'state': _state.text.trim(),
      'postal_code': _postal.text.trim(),
      'country': 'IN',
      'is_default': _isDefault,
      if (_latitude != null) 'latitude': _latitude,
      if (_longitude != null) 'longitude': _longitude,
    };
    await _cubit.save(id: widget.addressId, body: body);
    if (!mounted) return;
    if (_cubit.state.message == 'saved') {
      context.pop();
    } else if (_cubit.state.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_cubit.state.message!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    return BlocProvider.value(
      value: _cubit,
      child: LivoraScaffold(
        title: _isEdit ? s.editAddress : s.addAddress,
        body: _loadingExisting
            ? LivoraLoading(message: s.loading)
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text(s.addressLabel, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(s.labelHome),
                          selected: _label == 'home',
                          onSelected: (_) => setState(() => _label = 'home'),
                        ),
                        ChoiceChip(
                          label: Text(s.labelWork),
                          selected: _label == 'work',
                          onSelected: (_) => setState(() => _label = 'work'),
                        ),
                        ChoiceChip(
                          label: Text(s.labelOther),
                          selected: _label == 'other',
                          onSelected: (_) => setState(() => _label = 'other'),
                        ),
                      ],
                    ),
                    if (_label == 'other') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _labelCustom,
                        decoration: InputDecoration(labelText: s.customLabel),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? s.requiredField : null,
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _line1,
                      decoration: InputDecoration(labelText: s.addressLine1),
                      validator: (v) =>
                          (v == null || v.trim().length < 3) ? s.requiredField : null,
                    ),
                    TextFormField(
                      controller: _line2,
                      decoration: InputDecoration(labelText: s.addressLine2),
                    ),
                    TextFormField(
                      controller: _landmark,
                      decoration: InputDecoration(labelText: s.landmark),
                    ),
                    TextFormField(
                      controller: _city,
                      decoration: InputDecoration(labelText: s.city),
                      validator: (v) =>
                          (v == null || v.trim().length < 2) ? s.requiredField : null,
                      onChanged: (_) => _serviceabilityHint = null,
                    ),
                    TextFormField(
                      controller: _state,
                      decoration: InputDecoration(labelText: s.stateProvince),
                      validator: (v) =>
                          (v == null || v.trim().length < 2) ? s.requiredField : null,
                    ),
                    TextFormField(
                      controller: _postal,
                      decoration: InputDecoration(labelText: s.postalCode),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().length < 4) return s.requiredField;
                        return null;
                      },
                      onChanged: (_) => _serviceabilityHint = null,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () async {
                          final result = await Navigator.of(context).push<LatLng>(
                            MaterialPageRoute(
                              builder: (_) => MapPinPickerPage(
                                initialLatitude: _latitude ?? 12.9716,
                                initialLongitude: _longitude ?? 77.5946,
                              ),
                            ),
                          );
                          if (result != null && mounted) {
                            setState(() {
                              _latitude = result.latitude;
                              _longitude = result.longitude;
                            });
                          }
                        },
                        icon: const Icon(Icons.map_outlined),
                        label: Text(
                          _latitude == null
                              ? s.pickOnMap
                              : '${s.pickOnMap} (${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)})',
                        ),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(s.setDefault),
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _check,
                        child: Text(s.checkServiceability),
                      ),
                    ),
                    if (_serviceabilityHint != null)
                      Text(
                        _serviceabilityHint!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _serviceable
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error,
                            ),
                      ),
                    const SizedBox(height: 24),
                    BlocBuilder<AddressCubit, AddressViewState>(
                      builder: (context, state) {
                        return LivoraButton(
                          label: s.save,
                          onPressed: state.saving ? null : _submit,
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
