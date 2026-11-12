import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/note.dart';
import '../models/student.dart';
import '../repositories/note_repository.dart';

/// State global aplikasi yang disebarkan ke subtree lewat [InheritedWidget].
///
/// Prinsip least privilege: layar hanya menerima data baca-saja ([notes] tidak
/// dapat dimodifikasi) dan fungsi spesifik yang memang mereka perlukan.
class AppProvider extends InheritedWidget {
  /// Membuat provider. Biasanya dibuat oleh [AppProviderWrapper].
  const AppProvider({
    super.key,
    required this.student,
    required this.notes,
    required this.isLoading,
    required this.errorMessage,
    required this.updateStudent,
    required this.addNote,
    required this.deleteNote,
    required this.getNoteContent,
    required this.fetchUsers,
    required this.reload,
    required super.child,
  });

  /// Data profil mahasiswa saat ini.
  final Student student;

  /// Daftar catatan (hanya metadata, tidak dapat dimodifikasi).
  final List<Note> notes;

  /// `true` saat catatan sedang dimuat dari penyimpanan.
  final bool isLoading;

  /// Pesan error pemuatan catatan, atau `null` jika tidak ada.
  final String? errorMessage;

  /// Memperbarui profil mahasiswa.
  final void Function(Student student) updateStudent;

  /// Menyimpan catatan baru. Mengembalikan `true` jika berhasil.
  final Future<bool> Function(Note note) addNote;

  /// Menghapus catatan berdasarkan id. Mengembalikan `true` jika berhasil.
  final Future<bool> Function(String id) deleteNote;

  /// Membaca isi catatan (terdekripsi) berdasarkan id, `null` jika gagal.
  final Future<String?> Function(String id) getNoteContent;

  /// Mengambil data pengguna dari API publik.
  final Future<List<RemoteUser>> Function() fetchUsers;

  /// Memuat ulang daftar catatan.
  final Future<void> Function() reload;

  /// Mengambil provider dan mendaftarkan [context] agar rebuild saat state berubah.
  static AppProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppProvider>();
    assert(provider != null, 'AppProvider tidak ditemukan di widget tree.');
    return provider!;
  }

  /// Mengambil provider tanpa mendaftarkan rebuild (untuk dipakai di callback).
  static AppProvider read(BuildContext context) {
    final provider = context.getInheritedWidgetOfExactType<AppProvider>();
    assert(provider != null, 'AppProvider tidak ditemukan di widget tree.');
    return provider!;
  }

  @override
  bool updateShouldNotify(AppProvider oldWidget) =>
      student != oldWidget.student ||
      !identical(notes, oldWidget.notes) ||
      isLoading != oldWidget.isLoading ||
      errorMessage != oldWidget.errorMessage;
}

/// Widget stateful yang mengelola state dan menyediakan [AppProvider] ke subtree.
class AppProviderWrapper extends StatefulWidget {
  /// Membuat wrapper. [repository] opsional (untuk pengujian).
  const AppProviderWrapper({super.key, required this.child, this.repository});

  /// Subtree yang dapat mengakses [AppProvider].
  final Widget child;

  /// Repository data; default [NoteRepository].
  final NoteRepository? repository;

  @override
  State<AppProviderWrapper> createState() => _AppProviderWrapperState();
}

class _AppProviderWrapperState extends State<AppProviderWrapper> {
  late final NoteRepository _repository;

  Student _student = const Student(
    name: 'RAHMAT ROMDHANI',
    nim: '25.11.6588',
    programStudi: 'Teknik Informatika',
    email: 'r.romdhani@students.amikom.ac.id',
  );
  List<Note> _notes = const <Note>[];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? NoteRepository();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await _repository.getNotes();
      if (!mounted) return;
      setState(() {
        _notes = List<Note>.unmodifiable(notes);
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat catatan (${e.runtimeType}).');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat catatan. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  Future<void> _reload() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _loadNotes();
  }

  void _updateStudent(Student student) {
    setState(() => _student = student);
  }

  Future<bool> _addNote(Note note) async {
    try {
      await _repository.addNote(note);
      if (!mounted) return true;
      setState(() {
        _notes = List<Note>.unmodifiable(<Note>[note.withoutContent(), ..._notes]);
      });
      return true;
    } catch (e) {
      debugPrint('Gagal menyimpan catatan (${e.runtimeType}).');
      return false;
    }
  }

  Future<bool> _deleteNote(String id) async {
    try {
      await _repository.deleteNote(id);
      if (!mounted) return true;
      setState(() {
        _notes = List<Note>.unmodifiable(_notes.where((note) => note.id != id));
      });
      return true;
    } catch (e) {
      debugPrint('Gagal menghapus catatan (${e.runtimeType}).');
      return false;
    }
  }

  Future<String?> _getNoteContent(String id) async {
    try {
      return await _repository.getContent(id);
    } catch (e) {
      debugPrint('Gagal membaca isi catatan (${e.runtimeType}).');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppProvider(
      student: _student,
      notes: _notes,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      updateStudent: _updateStudent,
      addNote: _addNote,
      deleteNote: _deleteNote,
      getNoteContent: _getNoteContent,
      fetchUsers: _repository.fetchUsers,
      reload: _reload,
      child: widget.child,
    );
  }
}
