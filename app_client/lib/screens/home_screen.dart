import 'package:flutter/material.dart';

import '../api_service.dart';
import '../token_storage.dart';
import '../widgets/network_image_box.dart';
import 'login_screen.dart';
import 'product_list_tab.dart';
import 'profile_screen.dart';
import 'user_list_tab.dart';

/// Màn hình 3: khung chính = Scaffold + Drawer + NavigationBar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _titles = ['Sản phẩm', 'Người dùng'];

  int _index = 0;
  String _name = '';
  String _image = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await TokenStorage.getProfile();
    if (!mounted) return;
    setState(() {
      _name = p['name'] ?? '';
      _image = p['image'] ?? '';
    });
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
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_name),
              accountEmail: const Text('Đã đăng nhập'),
              currentAccountPicture: ClipOval(
                child: NetworkImageBox(url: _image),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Sản phẩm'),
              onTap: () {
                setState(() => _index = 0);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Người dùng'),
              onTap: () {
                setState(() => _index = 1);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('Hồ sơ của tôi'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: const [ProductListTab(), UserListTab()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Sản phẩm',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Người dùng',
          ),
        ],
      ),
    );
  }
}
