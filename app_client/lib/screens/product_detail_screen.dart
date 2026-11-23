import 'package:flutter/material.dart';

import '../models.dart';
import '../widgets/network_image_box.dart';
import 'product_form_screen.dart';

/// Màn hình 4: chi tiết sản phẩm. Trả kết quả (sửa/xóa) về màn hình trước.
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  Future<void> _edit(BuildContext context) async {
    final updated = await Navigator.of(context).push<Product>(
      MaterialPageRoute<Product>(
        builder: (_) => ProductFormScreen(product: product),
      ),
    );
    if (!context.mounted || updated == null) return;
    Navigator.of(context).pop(ProductAction(ActionType.updated, updated));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        actions: [
          IconButton(
            tooltip: 'Sửa',
            icon: const Icon(Icons.edit),
            onPressed: () => _edit(context),
          ),
          IconButton(
            tooltip: 'Xóa',
            icon: const Icon(Icons.delete),
            onPressed: () => Navigator.of(context)
                .pop(ProductAction(ActionType.deleted, product)),
          ),
        ],
      ),
      body: ListView(
        children: [
          NetworkImageBox(
            url: product.thumbnail,
            height: 260,
            fit: BoxFit.contain,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (product.category.isNotEmpty)
                  Chip(label: Text(product.category)),
                const SizedBox(height: 12),
                Text(product.description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
