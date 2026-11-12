import 'package:flutter/material.dart';

/// Tampilan tengah layar untuk kondisi kosong atau error.
///
/// Jika [actionLabel] dan [onAction] diisi, tombol aksi (mis. "Coba lagi")
/// ikut ditampilkan.
class EmptyState extends StatelessWidget {
  /// Membuat tampilan kosong/error.
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  /// Ikon besar di atas teks.
  final IconData icon;

  /// Judul singkat.
  final String title;

  /// Penjelasan untuk pengguna.
  final String message;

  /// Label tombol aksi (opsional).
  final String? actionLabel;

  /// Aksi tombol (opsional).
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
