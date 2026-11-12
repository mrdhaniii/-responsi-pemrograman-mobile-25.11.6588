/// Catatan kuliah.
///
/// Hanya metadata ([id], [title], [createdAt]) yang disimpan di
/// SharedPreferences. [content] disimpan terenkripsi di flutter_secure_storage
/// dan TIDAK pernah ikut diserialisasi oleh [toMetadata].
class Note {
  /// Membuat catatan. [content] kosong untuk catatan yang hanya berisi metadata.
  const Note({
    required this.id,
    required this.title,
    required this.createdAt,
    this.content = '',
  });

  /// Identitas unik catatan.
  final String id;

  /// Judul catatan.
  final String title;

  /// Waktu catatan dibuat.
  final DateTime createdAt;

  /// Isi catatan (sensitif; hanya dipakai saat menyimpan/menampilkan).
  final String content;

  /// Mengubah metadata (tanpa isi catatan) menjadi JSON map.
  Map<String, dynamic> toMetadata() => <String, dynamic>{
        'id': id,
        'title': title,
        'date': createdAt.toIso8601String(),
      };

  /// Membuat [Note] dari JSON metadata. Isi catatan dibiarkan kosong.
  factory Note.fromMetadata(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['date'] as String),
    );
  }

  /// Menyalin objek dengan mengganti field tertentu.
  Note copyWith({String? title, String? content}) {
    return Note(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      content: content ?? this.content,
    );
  }

  /// Salinan tanpa isi catatan, agar isi sensitif tidak tinggal di memori/state.
  Note withoutContent() => copyWith(content: '');
}
