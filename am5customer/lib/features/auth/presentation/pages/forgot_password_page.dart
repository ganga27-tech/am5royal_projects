import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../bloc/auth_bloc.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (p, c) => p.message != c.message || p.resetToken != c.resetToken,
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
          context.read<AuthBloc>().add(const AuthMessageCleared());
        }
        if (state.resetToken != null) {
          context.push('/reset-password?token=${Uri.encodeComponent(state.resetToken!)}');
        }
      },
      builder: (context, state) {
        return LivoraScaffold(
          title: 'Forgot password',
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text('Reset access', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Enter your email and we will send a secure reset token.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                LivoraTextField(
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthValidators.email,
                  prefixIcon: Icons.mail_outline,
                ),
                const SizedBox(height: 24),
                LivoraButton(
                  label: 'Send reset link',
                  loading: state.status == AuthStatus.loading,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    context.read<AuthBloc>().add(AuthForgotPasswordSubmitted(_email.text.trim()));
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
