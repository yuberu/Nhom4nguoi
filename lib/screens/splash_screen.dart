import 'package:flutter/material.dart';

import '../core/token_storage.dart';

/// Màn hình 1: kiểm tra token đã lưu để vào thẳng Home hoặc Login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final token = await TokenStorage.read();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      (token == null || token.isEmpty) ? '/login' : '/home',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_parking, size: 72, color: cs.primary),
            const SizedBox(height: 12),
            Text(
              'Bãi xe thông minh',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
