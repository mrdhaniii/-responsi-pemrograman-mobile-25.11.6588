/// Kumpulan validasi dan sanitasi input pengguna.
///
/// Semua validator bekerja pada teks yang SUDAH disanitasi, sehingga nilai
/// yang divalidasi sama dengan nilai yang akhirnya disimpan.
class Validators {
  Validators._();

  /// Panjang minimal judul catatan.
  static const int titleMin = 3;

  /// Panjang maksimal judul catatan.
  static const int titleMax = 50;

  /// Panjang minimal isi catatan.
  static const int contentMin = 10;

  /// Panjang maksimal isi catatan.
  static const int contentMax = 1000;

  static final RegExp _dangerous = RegExp('[<>"\']');
  static final RegExp _nimPattern = RegExp(r'^\d{8,15}$');
  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  /// Membersihkan karakter berbahaya (`<`, `>`, `"`, `'`) dan spasi di tepi.
  static String sanitize(String input) =>
      input.replaceAll(_dangerous, '').trim();

  /// Validasi judul: wajib, minimal [titleMin], maksimal [titleMax] karakter.
  static String? validateTitle(String? value) =>
      _validateLength(value, label: 'Judul', min: titleMin, max: titleMax);

  /// Validasi isi catatan: wajib, minimal [contentMin], maksimal [contentMax].
  static String? validateContent(String? value) => _validateLength(
        value,
        label: 'Isi catatan',
        min: contentMin,
        max: contentMax,
      );

  /// Validasi nama mahasiswa (3-60 karakter).
  static String? validateName(String? value) =>
      _validateLength(value, label: 'Nama', min: 3, max: 60);

  /// Validasi program studi (3-60 karakter).
  static String? validateProgramStudi(String? value) =>
      _validateLength(value, label: 'Program studi', min: 3, max: 60);

  /// Validasi NIM: hanya angka, 8-15 digit.
  static String? validateNim(String? value) {
    final text = sanitize(value ?? '');
    if (text.isEmpty) return 'NIM wajib diisi.';
    if (!_nimPattern.hasMatch(text)) {
      return 'NIM harus berupa 8-15 digit angka.';
    }
    return null;
  }

  /// Validasi format email.
  static String? validateEmail(String? value) {
    final text = sanitize(value ?? '');
    if (text.isEmpty) return 'Email wajib diisi.';
    if (text.length > 100 || !_emailPattern.hasMatch(text)) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  static String? _validateLength(
    String? value, {
    required String label,
    required int min,
    required int max,
  }) {
    final text = sanitize(value ?? '');
    if (text.isEmpty) return '$label wajib diisi.';
    if (text.length < min) return '$label minimal $min karakter.';
    if (text.length > max) return '$label maksimal $max karakter.';
    return null;
  }
}
