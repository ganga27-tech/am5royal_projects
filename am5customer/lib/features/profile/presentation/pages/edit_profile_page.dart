import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../bloc/profile_bloc.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _displayName;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  late final TextEditingController _bio;
  var _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final profile = context.read<ProfileBloc>().state.profile;
    _fullName = TextEditingController(text: profile?.fullName ?? '');
    _displayName = TextEditingController(text: profile?.displayName ?? '');
    _phone = TextEditingController(text: profile?.phone ?? '');
    _city = TextEditingController(text: profile?.city ?? '');
    _bio = TextEditingController(text: profile?.bio ?? '');
    _initialized = true;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _displayName.dispose();
    _phone.dispose();
    _city.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (p, c) => p.message != c.message,
      listener: (context, state) {
        if (state.message == 'saved') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.saved)));
          context.read<ProfileBloc>().add(const ProfileMessageCleared());
          context.pop();
        } else if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
          context.read<ProfileBloc>().add(const ProfileMessageCleared());
        }
      },
      builder: (context, state) {
        return LivoraScaffold(
          title: s.editProfile,
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                LivoraTextField(
                  controller: _fullName,
                  label: s.fullName,
                  validator: AuthValidators.fullName,
                ),
                const SizedBox(height: 16),
                LivoraTextField(controller: _displayName, label: s.displayName),
                const SizedBox(height: 16),
                LivoraTextField(
                  controller: _phone,
                  label: s.phone,
                  hint: '+919876543210',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    return AuthValidators.phoneE164(v);
                  },
                ),
                const SizedBox(height: 16),
                LivoraTextField(controller: _city, label: s.city),
                const SizedBox(height: 16),
                LivoraTextField(controller: _bio, label: s.bio),
                const SizedBox(height: 24),
                LivoraButton(
                  label: s.save,
                  loading: state.status == ProfileStatus.saving,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    context.read<ProfileBloc>().add(
                          ProfileUpdated({
                            'full_name': _fullName.text.trim(),
                            'display_name': _displayName.text.trim(),
                            'phone': _phone.text.trim().isEmpty ? '' : _phone.text.trim(),
                            'city': _city.text.trim(),
                            'bio': _bio.text.trim(),
                          }),
                        );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
