import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../bloc/auth_bloc.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, this.initialToken});

  final String? initialToken;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _token;
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _token = TextEditingController(text: widget.initialToken ?? '');
  }

  @override
  void dispose() {
    _token.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (p, c) => p.message != c.message,
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
          context.read<AuthBloc>().add(const AuthMessageCleared());
          if (state.message!.contains('Password updated')) {
            context.go('/login');
          }
        }
      },
      builder: (context, state) {
        return LivoraScaffold(
          title: 'New password',
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text('Choose a new password', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                LivoraTextField(
                  controller: _token,
                  label: 'Reset token',
                  validator: (v) => v == null || v.isEmpty ? 'Token required' : null,
                  prefixIcon: Icons.vpn_key_outlined,
                ),
                const SizedBox(height: 16),
                LivoraTextField(
                  controller: _password,
                  label: 'New password',
                  obscureText: true,
                  validator: AuthValidators.password,
                  prefixIcon: Icons.lock_outline,
                ),
                const SizedBox(height: 24),
                LivoraButton(
                  label: 'Update password',
                  loading: state.status == AuthStatus.loading,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    context.read<AuthBloc>().add(
                          AuthResetPasswordSubmitted(
                            token: _token.text.trim(),
                            newPassword: _password.text,
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
