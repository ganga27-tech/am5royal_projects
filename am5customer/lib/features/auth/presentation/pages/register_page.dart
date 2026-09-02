import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    String? phone;
    final phoneText = _phone.text.trim();
    if (phoneText.isNotEmpty) {
      final clean = phoneText.replaceAll(RegExp(r'[^\d]'), '');
      final phone10 = clean.length >= 10 ? clean.substring(clean.length - 10) : clean;
      phone = '+91$phone10';
    }
    context.read<AuthBloc>().add(
          AuthRegisterSubmitted(
            fullName: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            phone: phone,
          ),
        );
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
          title: 'Create account',
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text('Join LIVORA', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'A calmer way to book home care.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                LivoraTextField(
                  controller: _name,
                  label: 'Full name',
                  validator: AuthValidators.fullName,
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                LivoraTextField(
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthValidators.email,
                  prefixIcon: Icons.mail_outline,
                ),
                const SizedBox(height: 16),
                LivoraTextField(
                  controller: _phone,
                  label: 'Mobile Number (optional)',
                  hint: '9876543210',
                  prefixText: '+91 ',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    return AuthValidators.phone(v);
                  },
                  prefixIcon: Icons.phone_outlined,
                ),
                const SizedBox(height: 16),
                LivoraTextField(
                  controller: _password,
                  label: 'Password',
                  obscureText: _obscure,
                  validator: AuthValidators.password,
                  prefixIcon: Icons.lock_outline,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                LivoraButton(
                  label: 'Create account',
                  loading: state.status == AuthStatus.loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                LivoraButton(
                  label: 'Already have an account?',
                  variant: LivoraButtonVariant.ghost,
                  onPressed: () => context.push('/login'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
