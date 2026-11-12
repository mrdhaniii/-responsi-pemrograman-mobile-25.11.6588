import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/student.dart';

/// Kartu profil mahasiswa: avatar inisial, nama, NIM, program studi, email.
///
/// Dengan [compact] = true, kartu hanya menampilkan nama dan NIM (dipakai di
/// bagian atas HomeScreen). Widget ini murni UI; tidak berisi logika bisnis.
class ProfileCard extends StatelessWidget {
  /// Membuat kartu profil untuk [student].
  const ProfileCard({super.key, required this.student, this.compact = false});

  /// Data yang ditampilkan.
  final Student student;

  /// Mode ringkas (nama + NIM saja).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = compact ? 28.0 : 48.0;

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      child: Text(
        student.initials,
        style: TextStyle(fontSize: radius * 0.7, fontWeight: FontWeight.bold),
      ),
    );

    if (compact) {
      return Container(
        margin: const EdgeInsets.all(AppTheme.spacing),
        padding: const EdgeInsets.all(AppTheme.spacing),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            avatar,
            const SizedBox(width: AppTheme.spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIM: ${student.nim}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          avatar,
          const SizedBox(height: AppTheme.spacing),
          Text(
            student.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacing),
          _InfoRow(icon: Icons.badge_outlined, label: 'NIM', value: student.nim),
          _InfoRow(
            icon: Icons.school_outlined,
            label: 'Program Studi',
            value: student.programStudi,
          ),
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: student.email,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelMedium),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
