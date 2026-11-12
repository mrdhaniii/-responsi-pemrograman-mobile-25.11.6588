import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note.dart';

/// Kartu satu catatan: judul, tanggal, dan tombol hapus.
///
/// Isi catatan tidak ditampilkan di sini; ketuk kartu untuk membacanya.
class NoteCard extends StatelessWidget {
  /// Membuat kartu untuk [note].
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  /// Catatan yang ditampilkan.
  final Note note;

  /// Dipanggil saat kartu diketuk.
  final VoidCallback onTap;

  /// Dipanggil saat tombol hapus ditekan.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(note.createdAt);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.sticky_note_2_outlined)),
        title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(date),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Hapus catatan',
          onPressed: onDelete,
        ),
      ),
    );
  }
}
