import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../bloc/auth_bloc.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key, required this.email});

  final String email;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
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
        }
      },
      builder: (context, state) {
        return LivoraScaffold(
          title: 'Verify email',
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text('Confirm your email', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Enter the code sent to ${widget.email}. Login works before verification; '
                  'booking will require a verified email in a later module.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                LivoraTextField(
                  controller: _code,
                  label: 'Verification code',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: AuthValidators.otp,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: Icons.mark_email_read_outlined,
                ),
                const SizedBox(height: 24),
                LivoraButton(
                  label: 'Verify email',
                  loading: state.status == AuthStatus.loading,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    context.read<AuthBloc>().add(
                          AuthEmailVerified(email: widget.email, code: _code.text.trim()),
                        );
                  },
                ),
                const SizedBox(height: 12),
                LivoraButton(
                  label: 'Resend code',
                  variant: LivoraButtonVariant.secondary,
                  onPressed: () => context.read<AuthBloc>().add(
                        AuthEmailResendRequested(widget.email),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
