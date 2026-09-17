import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  bool _useEmail = false;
  String? _navigatedDestination;

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _navigatedDestination = null;
    String target = _identifier.text.trim();
    if (!_useEmail) {
      final clean = target.replaceAll(RegExp(r'[^\d]'), '');
      final phone10 = clean.length >= 10 ? clean.substring(clean.length - 10) : clean;
      target = '+91$phone10';
    }
    context.read<AuthBloc>().add(AuthPhoneOtpRequested(target));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (p, c) =>
          p.message != c.message ||
          (p.otpDestination != c.otpDestination && c.otpDestination != null) ||
          (p.status == AuthStatus.loading && c.status == AuthStatus.unauthenticated && c.otpDestination != null),
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
          context.read<AuthBloc>().add(const AuthMessageCleared());
        }
        if (state.otpDestination != null &&
            state.otpDestination!.isNotEmpty &&
            state.otpDestination != _navigatedDestination) {
          _navigatedDestination = state.otpDestination;
          final dest = state.otpDestination!;
          final redirect = widget.redirectTo;
          final q = 'to=${Uri.encodeComponent(dest)}'
              '${redirect != null && redirect.isNotEmpty ? '&redirect=${Uri.encodeComponent(redirect)}' : ''}';
          context.push('/otp?$q');
        }
      },
      builder: (context, state) {
        final loading = state.status == AuthStatus.loading;
        return LivoraScaffold(
          title: 'Sign in',
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Sign in with a one-time code sent to your phone or email.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Phone'), icon: Icon(Icons.phone_outlined)),
                    ButtonSegment(value: true, label: Text('Email'), icon: Icon(Icons.mail_outline)),
                  ],
                  selected: {_useEmail},
                  onSelectionChanged: (s) => setState(() {
                    _useEmail = s.first;
                    _identifier.clear();
                  }),
                ),
                const SizedBox(height: 24),
                LivoraTextField(
                  controller: _identifier,
                  label: _useEmail ? 'Email' : 'Mobile Number',
                  hint: _useEmail ? 'you@example.com' : '9876543210',
                  prefixText: _useEmail ? null : '+91 ',
                  keyboardType: _useEmail ? TextInputType.emailAddress : TextInputType.phone,
                  validator: _useEmail ? AuthValidators.email : AuthValidators.phone,
                  prefixIcon: _useEmail ? Icons.mail_outline : Icons.phone_outlined,
                  inputFormatters: _useEmail
                      ? null
                      : [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                  autofillHints: _useEmail ? const [AutofillHints.email] : const [AutofillHints.telephoneNumber],
                ),
                const SizedBox(height: 24),
                LivoraButton(
                  label: 'Send OTP',
                  loading: loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
