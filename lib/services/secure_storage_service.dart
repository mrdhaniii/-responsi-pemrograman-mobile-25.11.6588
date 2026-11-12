import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Layanan penyimpanan terenkripsi untuk isi catatan (flutter_secure_storage).
///
/// Isi catatan disimpan dengan key `note_content_<id>`. Kelas ini sengaja
/// tidak mencetak apa pun ke log agar isi catatan tidak pernah bocor.
class SecureStorageService {
  /// Membuat layanan. [storage] bisa diganti saat pengujian.
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  /// Membentuk key penyimpanan untuk catatan dengan id [noteId].
  static String keyFor(String noteId) => 'note_content_$noteId';

  /// Menyimpan [content] catatan [noteId] secara terenkripsi.
  Future<void> saveContent(String noteId, String content) =>
      _storage.write(key: keyFor(noteId), value: content);

  /// Membaca isi catatan [noteId]. Mengembalikan `null` jika tidak ada.
  Future<String?> getContent(String noteId) =>
      _storage.read(key: keyFor(noteId));

  /// Menghapus isi catatan [noteId].
  Future<void> deleteContent(String noteId) =>
      _storage.delete(key: keyFor(noteId));
}
