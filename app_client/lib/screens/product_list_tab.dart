import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../api_service.dart';
import '../models.dart';
import '../widgets/network_image_box.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

/// Danh sách 1 (ListView.builder tải từ API): sản phẩm.
/// Vuốt sang trái để xóa -> SnackBar có nút "Hoàn tác".
class ProductListTab extends StatefulWidget {
  const ProductListTab({super.key});

  @override
  State<ProductListTab> createState() => _ProductListTabState();
}

class _ProductListTabState extends State<ProductListTab>
    with AutomaticKeepAliveClientMixin {
  List<Product> _products = [];
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
      final items = await ApiService.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = items;
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

  Future<void> _openDetail(Product p) async {
    final result = await Navigator.of(context).push<ProductAction>(
      MaterialPageRoute<ProductAction>(
        builder: (_) => ProductDetailScreen(product: p),
      ),
    );
    if (!mounted || result == null) return;
    if (result.type == ActionType.updated) {
      setState(() {
        final i = _products.indexWhere((e) => e.id == result.product.id);
        if (i != -1) _products[i] = result.product;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật sản phẩm')),
      );
    } else {
      _removeWithUndo(result.product);
    }
  }

  Future<void> _openAdd() async {
    final created = await Navigator.of(context).push<Product>(
      MaterialPageRoute<Product>(builder: (_) => const ProductFormScreen()),
    );
    if (!mounted || created == null) return;
    final newId =
        _products.fold<int>(0, (m, e) => math.max(m, e.id)) + 1;
    setState(() => _products.insert(0, created.copyWith(id: newId)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm sản phẩm')),
    );
  }

  /// Xóa khỏi giao diện ngay; chỉ gọi API xóa thật nếu người dùng KHÔNG bấm Hoàn tác.
  Future<void> _removeWithUndo(Product p) async {
    final index = _products.indexWhere((e) => e.id == p.id);
    if (index == -1) return;
    setState(() => _products.removeAt(index));

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    final controller = messenger.showSnackBar(
      SnackBar(
        content: Text('Đã xóa "${p.title}"'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () {
            if (!mounted) return;
            setState(() {
              _products.insert(math.min(index, _products.length), p);
            });
          },
        ),
      ),
    );

    final reason = await controller.closed;
    if (!mounted || reason == SnackBarClosedReason.action) return;
    try {
      await ApiService.deleteProduct(p.id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _products.insert(math.min(index, _products.length), p);
      });
      messenger.showSnackBar(
        SnackBar(content: Text('Xóa thất bại: ${errorMessage(e)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Thử lại')),
          ],
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: () => _load(silent: true),
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: _products.length,
          itemBuilder: (context, i) {
            final p = _products[i];
            return Dismissible(
              key: ValueKey<int>(p.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => _removeWithUndo(p),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NetworkImageBox(
                    url: p.thumbnail,
                    width: 56,
                    height: 56,
                  ),
                ),
                title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('\$${p.price.toStringAsFixed(2)} · ${p.category}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openDetail(p),
              ),
            );
          },
        ),
      );
    }

    return Stack(
      children: [
        body,
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _openAdd,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
