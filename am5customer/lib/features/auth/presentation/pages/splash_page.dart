import 'package:flutter/material.dart';
import 'package:am5_ui/am5_ui.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LivoraLogo(size: 56),
            SizedBox(height: 24),
            LivoraLoading(message: 'Preparing your home care…'),
          ],
        ),
      ),
    );
  }
}
