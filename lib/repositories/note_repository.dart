import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/note.dart';
import '../services/secure_storage_service.dart';

/// Error yang sudah diterjemahkan menjadi pesan ramah pengguna.
class ApiException implements Exception {
  /// Membuat error dengan [message] yang aman ditampilkan ke pengguna.
  const ApiException(this.message);

  /// Pesan untuk pengguna.
  final String message;

  @override
  String toString() => message;
}

/// Data pengguna dari API publik (`/users`).
class RemoteUser {
  /// Membuat data pengguna remote.
  const RemoteUser({
    required this.name,
    required this.email,
    required this.company,
  });

  /// Membaca satu objek JSON dari endpoint `/users`.
  factory RemoteUser.fromJson(Map<String, dynamic> json) {
    final company = json['company'];
    return RemoteUser(
      name: (json['name'] ?? '-').toString(),
      email: (json['email'] ?? '-').toString(),
      company: company is Map ? (company['name'] ?? '-').toString() : '-',
    );
  }

  /// Nama pengguna.
  final String name;

  /// Email pengguna.
  final String email;

  /// Nama perusahaan.
  final String company;
}

/// Repository untuk seluruh akses data catatan.
///
/// - Metadata (id, judul, tanggal) -> SharedPreferences (JSON list).
/// - Isi catatan -> flutter_secure_storage (key `note_content_<id>`).
/// - Data publik -> HTTP GET dengan error handling.
class NoteRepository {
  /// Membuat repository. Dependency dapat diganti saat pengujian.
  NoteRepository({SecureStorageService? secureStorage, http.Client? client})
      : _secure = secureStorage ?? SecureStorageService(),
        _client = client ?? http.Client();

  static const String _metadataKey = 'notes_metadata';
  static const Duration _timeout = Duration(seconds: 10);

  final SecureStorageService _secure;
  final http.Client _client;

  /// Membaca seluruh metadata catatan (terbaru di atas). Isi catatan kosong.
  Future<List<Note>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_metadataKey);
    if (raw == null || raw.isEmpty) return <Note>[];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Note.fromMetadata(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Metadata catatan rusak (${e.runtimeType}); dianggap kosong.');
      return <Note>[];
    }
  }

  /// Menyimpan catatan baru: isi ke secure storage, metadata ke SharedPreferences.
  Future<void> addNote(Note note) async {
    await _secure.saveContent(note.id, note.content);
    try {
      final notes = await getNotes();
      notes.insert(0, note.withoutContent());
      await _saveMetadata(notes);
    } catch (e) {
      // Batalkan isi yang sudah tersimpan agar tidak ada data yatim.
      await _secure.deleteContent(note.id);
      rethrow;
    }
  }

  /// Menghapus metadata dan isi catatan dengan id [id].
  Future<void> deleteNote(String id) async {
    final notes = await getNotes();
    notes.removeWhere((note) => note.id == id);
    await _saveMetadata(notes);
    await _secure.deleteContent(id);
  }

  /// Membaca isi catatan [id] dari secure storage.
  Future<String?> getContent(String id) => _secure.getContent(id);

  /// HTTP GET `/users` dari API publik.
  ///
  /// Melempar [ApiException] dengan pesan ramah pengguna untuk timeout,
  /// tidak ada koneksi (SocketException), status tidak 200, atau data rusak.
  /// Log hanya memuat status code, tidak pernah header/API key/isi respons.
  Future<List<RemoteUser>> fetchUsers() async {
    if (!AppConfig.isConfigured) {
      throw const ApiException('BASE_URL belum diatur di file .env.');
    }
    final uri = Uri.parse('${AppConfig.baseUrl}/users');
    try {
      final response = await _client.get(
        uri,
        headers: <String, String>{
          'Accept': 'application/json',
          if (AppConfig.apiKey.isNotEmpty) 'x-api-key': AppConfig.apiKey,
        },
      ).timeout(_timeout);
      debugPrint('HTTP GET /users -> ${response.statusCode}');
      if (response.statusCode != 200) {
        throw ApiException('Server mengembalikan status ${response.statusCode}.');
      }
      final decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded
          .map((item) => RemoteUser.fromJson(item as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw const ApiException('Permintaan melebihi batas waktu. Coba lagi.');
    } on SocketException {
      throw const ApiException('Tidak ada koneksi internet.');
    } on http.ClientException {
      throw const ApiException('Gagal menghubungi server.');
    } on FormatException {
      throw const ApiException('Format data dari server tidak valid.');
    } on TypeError {
      throw const ApiException('Format data dari server tidak valid.');
    }
  }

  Future<void> _saveMetadata(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(notes.map((note) => note.toMetadata()).toList());
    await prefs.setString(_metadataKey, encoded);
  }
}
