import 'package:flutter/material.dart';

import '../api_service.dart';
import '../models.dart';
import '../widgets/network_image_box.dart';
import 'login_screen.dart';

/// Màn hình 6: hồ sơ cá nhân, gọi API kèm token (Authorization: Bearer ...).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppUser? _user;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final u = await ApiService.getMe();
      if (!mounted) return;
      setState(() {
        _user = u;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    final user = _user;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null || user == null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error ?? 'Không có dữ liệu'),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Thử lại')),
          ],
        ),
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: ClipOval(
              child: NetworkImageBox(url: user.image, width: 120, height: 120),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(user.fullName,
                style: Theme.of(context).textTheme.headlineSmall),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Tên đăng nhập'),
            subtitle: Text(user.username),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(user.email),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Điện thoại'),
            subtitle: Text(user.phone),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
          ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ của tôi')),
      body: body,
    );
  }
}
