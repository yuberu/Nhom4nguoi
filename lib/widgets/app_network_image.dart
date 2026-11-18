import 'package:flutter/material.dart';

/// Ảnh từ URL (Supabase Storage) có loadingBuilder và errorBuilder.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.height,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final double? height;
  final double width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final address = url;

    if (address == null || address.isEmpty) {
      return _placeholder(cs, Icons.image_not_supported_outlined, 'Chưa có ảnh');
    }

    return Image.network(
      address,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        final total = progress.expectedTotalBytes;
        return Container(
          width: width,
          height: height,
          color: cs.surfaceContainerHighest,
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            value: total == null ? null : progress.cumulativeBytesLoaded / total,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) =>
          _placeholder(cs, Icons.broken_image_outlined, 'Không tải được ảnh'),
    );
  }

  Widget _placeholder(ColorScheme cs, IconData icon, String text) {
    return Container(
      width: width,
      height: height,
      color: cs.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: cs.onSurfaceVariant),
          const SizedBox(height: 6),
          Text(text, style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
