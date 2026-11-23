import 'package:flutter/material.dart';

import '../api_service.dart';
import '../models.dart';
import '../widgets/network_image_box.dart';

/// Danh sách 2 (ListView.builder tải từ API): người dùng.
class UserListTab extends StatefulWidget {
  const UserListTab({super.key});

  @override
  State<UserListTab> createState() => _UserListTabState();
}

class _UserListTabState extends State<UserListTab>
    with AutomaticKeepAliveClientMixin {
  List<AppUser> _users = [];
  bool _loading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final items = await ApiService.fetchUsers();
      if (!mounted) return;
      setState(() {
        _users = items;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorMessage(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Thử lại')),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(silent: true),
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, i) {
          final u = _users[i];
          return ListTile(
            leading: ClipOval(
              child: NetworkImageBox(url: u.image, width: 48, height: 48),
            ),
            title: Text(u.fullName),
            subtitle: Text(u.email),
          );
        },
      ),
    );
  }
}
