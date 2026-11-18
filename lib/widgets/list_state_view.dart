import 'package:flutter/material.dart';

/// Khung dùng chung cho các danh sách tải từ API:
/// đang tải / lỗi (có nút Thử lại) / rỗng / có dữ liệu, kèm kéo-để-làm-mới.
class ListStateView extends StatelessWidget {
  const ListStateView({
    super.key,
    required this.loading,
    required this.error,
    required this.isEmpty,
    required this.emptyText,
    required this.emptyIcon,
    required this.onRefresh,
    required this.child,
  });

  final bool loading;
  final String? error;
  final bool isEmpty;
  final String emptyText;
  final IconData emptyIcon;
  final Future<void> Function() onRefresh;

  /// Thường là một ListView.builder.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (loading && isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final Widget body;
    if (error != null && isEmpty) {
      body = _Message(
        icon: Icons.cloud_off_outlined,
        text: error!,
        actionLabel: 'Thử lại',
        onAction: onRefresh,
      );
    } else if (isEmpty) {
      body = _Message(icon: emptyIcon, text: emptyText);
    } else {
      body = child;
    }

    return RefreshIndicator(onRefresh: onRefresh, child: body);
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(32, 120, 32, 32),
      children: [
        Icon(icon, size: 64, color: cs.outline),
        const SizedBox(height: 16),
        Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 16),
          Center(
            child: FilledButton.tonal(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ),
        ],
      ],
    );
  }
}
