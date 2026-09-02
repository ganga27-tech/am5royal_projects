import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../bloc/profile_bloc.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (p, c) => p.message != c.message,
      listener: (context, state) {
        if (state.message == 'password_changed') {
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
          title: s.changePassword,
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                LivoraTextField(
                  controller: _current,
                  label: s.currentPassword,
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                LivoraTextField(
                  controller: _next,
                  label: s.newPassword,
                  obscureText: true,
                  validator: AuthValidators.password,
                ),
                const SizedBox(height: 24),
                LivoraButton(
                  label: s.save,
                  loading: state.status == ProfileStatus.saving,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    context.read<ProfileBloc>().add(
                          ProfilePasswordChanged(
                            currentPassword: _current.text,
                            newPassword: _next.text,
                          ),
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
