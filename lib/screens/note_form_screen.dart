import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_theme.dart';
import '../models/note.dart';
import '../providers/app_provider.dart';
import '../utils/validators.dart';

/// Form untuk menambah catatan baru.
///
/// Menutup layar dengan `Navigator.pop(context, true)` jika catatan berhasil
/// disimpan, sehingga layar pemanggil dapat bereaksi terhadap hasilnya.
/// Prinsip least privilege: layar ini hanya memanggil `addNote`.
class NoteFormScreen extends StatefulWidget {
  /// Membuat layar form catatan.
  const NoteFormScreen({super.key});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Memvalidasi, menyanitasi, lalu menyimpan catatan lewat provider.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final addNote = AppProvider.read(context).addNote;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSaving = true);
    final now = DateTime.now();
    final note = Note(
      id: now.microsecondsSinceEpoch.toString(),
      title: Validators.sanitize(_titleController.text),
      content: Validators.sanitize(_contentController.text),
      createdAt: now,
    );
    final success = await addNote(note);

    if (!mounted) return;
    if (success) {
      navigator.pop(true);
    } else {
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan catatan. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Catatan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  hintText: 'Mis. Ringkasan Pertemuan 5',
                ),
                maxLength: Validators.titleMax,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                textInputAction: TextInputAction.next,
                validator: Validators.validateTitle,
              ),
              const SizedBox(height: AppTheme.spacing),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Isi catatan',
                  alignLabelWithHint: true,
                ),
                minLines: 6,
                maxLines: 10,
                maxLength: Validators.contentMax,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                keyboardType: TextInputType.multiline,
                validator: Validators.validateContent,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Catatan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
