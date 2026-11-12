import 'package:flutter/material.dart';

import '../models/note.dart';
import '../providers/app_provider.dart';
import '../repositories/note_repository.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import '../widgets/profile_card.dart';
import 'note_form_screen.dart';
import 'profile_screen.dart';

/// Layar utama: profil singkat, daftar catatan, dan tombol tambah catatan.
///
/// Menampilkan empat kondisi dengan jelas: loading, error, kosong, dan data.
class HomeScreen extends StatelessWidget {
  /// Membuat layar utama.
  const HomeScreen({super.key});

  /// Membuka ProfileScreen.
  Future<void> _openProfile(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
    );
  }

  /// Membuka NoteFormScreen; menampilkan SnackBar jika hasilnya `true`.
  Future<void> _openNoteForm(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (_) => const NoteFormScreen()),
    );
    if (saved == true) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Catatan berhasil disimpan.')),
      );
    }
  }

  /// Dialog konfirmasi sebelum menghapus catatan.
  Future<void> _confirmDelete(BuildContext context, Note note) async {
    final deleteNote = AppProvider.read(context).deleteNote;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: Text('Catatan "${note.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final success = await deleteNote(note.id);
    messenger.showSnackBar(
      SnackBar(
        content: Text(success ? 'Catatan dihapus.' : 'Gagal menghapus catatan.'),
      ),
    );
  }

  /// Membaca isi catatan dari secure storage lalu menampilkannya di dialog.
  Future<void> _showContent(BuildContext context, Note note) async {
    final getContent = AppProvider.read(context).getNoteContent;
    final content = await getContent(note.id);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(note.title),
        content: SingleChildScrollView(
          child: Text(content ?? '(Isi catatan tidak ditemukan)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  /// Membuka bottom sheet berisi data pengguna dari API publik (HTTP GET).
  void _showRemoteUsers(BuildContext context) {
    final fetchUsers = AppProvider.read(context).fetchUsers;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _RemoteUsersSheet(fetchUsers: fetchUsers),
    );
  }

  Widget _buildBody(BuildContext context, AppProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Terjadi kesalahan',
        message: provider.errorMessage!,
        actionLabel: 'Coba lagi',
        onAction: provider.reload,
      );
    }
    if (provider.notes.isEmpty) {
      return const EmptyState(
        icon: Icons.note_add_outlined,
        title: 'Belum ada catatan',
        message: 'Ketuk tombol + untuk menambahkan catatan kuliah pertama Anda.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: provider.notes.length,
      itemBuilder: (context, index) {
        final note = provider.notes[index];
        return NoteCard(
          note: note,
          onTap: () => _showContent(context, note),
          onDelete: () => _confirmDelete(context, note),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = AppProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Kuliah'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download_outlined),
            tooltip: 'Data dari API',
            onPressed: () => _showRemoteUsers(context),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profil',
            onPressed: () => _openProfile(context),
          ),
        ],
      ),
      body: Column(
        children: [
          ProfileCard(student: provider.student, compact: true),
          Expanded(child: _buildBody(context, provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteForm(context),
        tooltip: 'Tambah catatan',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Bottom sheet yang memuat dan menampilkan data `/users` di dalam ListView.
class _RemoteUsersSheet extends StatefulWidget {
  const _RemoteUsersSheet({required this.fetchUsers});

  final Future<List<RemoteUser>> Function() fetchUsers;

  @override
  State<_RemoteUsersSheet> createState() => _RemoteUsersSheetState();
}

class _RemoteUsersSheetState extends State<_RemoteUsersSheet> {
  late Future<List<RemoteUser>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.fetchUsers();
  }

  void _retry() {
    setState(() => _future = widget.fetchUsers());
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.6;
    return SizedBox(
      height: height,
      child: FutureBuilder<List<RemoteUser>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final error = snapshot.error;
            return EmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'Gagal memuat data',
              message: error is ApiException
                  ? error.message
                  : 'Terjadi kesalahan tak terduga.',
              actionLabel: 'Coba lagi',
              onAction: _retry,
            );
          }
          final users = snapshot.data ?? const <RemoteUser>[];
          if (users.isEmpty) {
            return const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'Data kosong',
              message: 'Server tidak mengembalikan data.',
            );
          }
          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(user.name.isEmpty ? '?' : user.name[0]),
                ),
                title: Text(user.name),
                subtitle: Text('${user.email} • ${user.company}'),
              );
            },
          );
        },
      ),
    );
  }
}
