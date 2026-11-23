import 'package:flutter/material.dart';

/// Hiển thị ảnh từ URL, có vòng tròn tải (loadingBuilder)
/// và biểu tượng lỗi (errorBuilder).
class NetworkImageBox extends StatelessWidget {
  const NetworkImageBox({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _placeholder(Icons.image_not_supported_outlined);
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        final total = progress.expectedTotalBytes;
        return SizedBox(
          width: width,
          height: height,
          child: Center(
            child: CircularProgressIndicator(
              value: total == null ? null : progress.cumulativeBytesLoaded / total,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) =>
          _placeholder(Icons.broken_image_outlined),
    );
  }

  Widget _placeholder(IconData icon) {
    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: Colors.black12,
        child: Center(child: Icon(icon)),
      ),
    );
  }
}
