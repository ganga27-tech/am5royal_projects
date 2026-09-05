import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../bloc/auth_bloc.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key, required this.destination, this.redirectTo});

  final String destination;
  final String? redirectTo;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
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
      listenWhen: (p, c) =>
          p.message != c.message ||
          (p.status != c.status && c.status == AuthStatus.authenticated),
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          final redirect = widget.redirectTo;
          if (redirect != null && redirect.isNotEmpty) {
            context.go(redirect);
          } else {
            context.go('/home');
          }
          return;
        }
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
          context.read<AuthBloc>().add(const AuthMessageCleared());
        }
      },
      builder: (context, state) {
        return LivoraScaffold(
          title: 'Verify OTP',
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text('Enter the code', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'We sent a one-time code to ${widget.destination}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                LivoraTextField(
                  controller: _code,
                  label: 'OTP',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: AuthValidators.otp,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: Icons.pin_outlined,
                ),
                const SizedBox(height: 24),
                LivoraButton(
                  label: 'Verify & continue',
                  loading: state.status == AuthStatus.loading,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    context.read<AuthBloc>().add(
                          AuthOtpVerified(
                            destination: widget.destination,
                            code: _code.text.trim(),
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
