import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/student.dart';
import '../providers/app_provider.dart';
import '../utils/validators.dart';
import '../widgets/profile_card.dart';

/// Layar profil mahasiswa dengan tombol Edit Profil.
///
/// Layar ini hanya membaca [Student] dari [AppProvider] dan memanggil
/// `updateStudent`; seluruh state disimpan di provider (separation of concerns).
class ProfileScreen extends StatelessWidget {
  /// Membuat layar profil.
  const ProfileScreen({super.key});

  Future<void> _editProfile(BuildContext context, Student current) async {
    final messenger = ScaffoldMessenger.of(context);
    final onSave = AppProvider.read(context).updateStudent;
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _EditProfileDialog(student: current, onSave: onSave),
    );
    if (saved == true) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = AppProvider.of(context).student;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Mahasiswa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing),
        child: Column(
          children: [
            ProfileCard(student: student),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _editProfile(context, student),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog form untuk mengubah data profil (validasi + sanitasi input).
class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.student, required this.onSave});

  final Student student;
  final void Function(Student student) onSave;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _nim;
  late final TextEditingController _programStudi;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.student.name);
    _nim = TextEditingController(text: widget.student.nim);
    _programStudi = TextEditingController(text: widget.student.programStudi);
    _email = TextEditingController(text: widget.student.email);
  }

  @override
  void dispose() {
    _name.dispose();
    _nim.dispose();
    _programStudi.dispose();
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(
      Student(
        name: Validators.sanitize(_name.text),
        nim: Validators.sanitize(_nim.text),
        programStudi: Validators.sanitize(_programStudi.text),
        email: Validators.sanitize(_email.text),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profil'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nama'),
                textInputAction: TextInputAction.next,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nim,
                decoration: const InputDecoration(labelText: 'NIM'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: Validators.validateNim,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _programStudi,
                decoration: const InputDecoration(labelText: 'Program Studi'),
                textInputAction: TextInputAction.next,
                validator: Validators.validateProgramStudi,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}
