import 'package:flutter/material.dart';

import '../api_service.dart';
import '../models.dart';

/// Màn hình 5: form thêm / sửa sản phẩm (Form + validator).
/// Bấm Lưu thành công -> trả Product về màn hình trước.
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _price;
  late final TextEditingController _category;
  late final TextEditingController _image;
  late final TextEditingController _desc;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _title = TextEditingController(text: p?.title ?? '');
    _price = TextEditingController(text: p == null ? '' : p.price.toString());
    _category = TextEditingController(text: p?.category ?? '');
    _image = TextEditingController(text: p?.thumbnail ?? '');
    _desc = TextEditingController(text: p?.description ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _category.dispose();
    _image.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final draft = Product(
      id: widget.product?.id ?? 0,
      title: _title.text.trim(),
      description: _desc.text.trim(),
      price: double.parse(_price.text.trim()),
      thumbnail: _image.text.trim(),
      category: _category.text.trim(),
    );

    try {
      if (_isEdit) {
        await ApiService.updateProduct(draft);
      } else {
        await ApiService.createProduct(draft);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lưu thất bại: ${errorMessage(e)}')),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Tên sản phẩm',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên';
                if (v.trim().length < 3) return 'Tên tối thiểu 3 ký tự';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Giá (USD)',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final n = double.tryParse((v ?? '').trim());
                if (n == null) return 'Giá phải là một con số';
                if (n <= 0) return 'Giá phải lớn hơn 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _category,
              decoration: const InputDecoration(
                labelText: 'Danh mục',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Vui lòng nhập danh mục' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _image,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Link ảnh (không bắt buộc)',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return null;
                if (!s.startsWith('http://') && !s.startsWith('https://')) {
                  return 'Link ảnh phải bắt đầu bằng http:// hoặc https://';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _desc,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Vui lòng nhập mô tả' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
