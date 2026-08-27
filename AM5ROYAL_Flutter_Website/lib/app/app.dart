import 'package:flutter/material.dart';

import '../features/auth/services/auth_service.dart';
import '../pages/home_page.dart';
import 'theme.dart';

class AM5RoyalApp extends StatefulWidget {
  const AM5RoyalApp({super.key});

  @override
  State<AM5RoyalApp> createState() => _AM5RoyalAppState();
}

class _AM5RoyalAppState extends State<AM5RoyalApp> {
  final AuthService _auth = AuthService.instance;

  @override
  void initState() {
    super.initState();
    _auth.initialize();
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AM5RoyalTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'AM5 ROYAL',
      debugShowCheckedModeBanner: false,
      theme: AM5RoyalTheme.lightTheme,
      home: HomePage(
        authService: _auth,
      ),
    );
  }
}
