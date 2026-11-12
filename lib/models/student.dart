/// Data profil mahasiswa.
class Student {
  /// Membuat data mahasiswa.
  const Student({
    required this.name,
    required this.nim,
    required this.programStudi,
    required this.email,
  });

  /// Nama lengkap.
  final String name;

  /// Nomor Induk Mahasiswa.
  final String nim;

  /// Program studi.
  final String programStudi;

  /// Alamat email.
  final String email;

  /// Inisial nama (maks. 2 huruf) untuk ditampilkan di avatar.
  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  /// Menyalin objek dengan mengganti field tertentu.
  Student copyWith({
    String? name,
    String? nim,
    String? programStudi,
    String? email,
  }) {
    return Student(
      name: name ?? this.name,
      nim: nim ?? this.nim,
      programStudi: programStudi ?? this.programStudi,
      email: email ?? this.email,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Student &&
      other.name == name &&
      other.nim == nim &&
      other.programStudi == programStudi &&
      other.email == email;

  @override
  int get hashCode => Object.hash(name, nim, programStudi, email);
}
