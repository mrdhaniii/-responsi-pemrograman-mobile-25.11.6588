import 'package:flutter_test/flutter_test.dart';
import 'package:responsi_profil_mahasiswa/models/student.dart';
import 'package:responsi_profil_mahasiswa/utils/validators.dart';

void main() {
  group('Validators.sanitize', () {
    test('menghapus karakter berbahaya < > " \'', () {
      expect(Validators.sanitize('<b>"Halo"</b> \'dunia\''), 'bHalo/b dunia');
    });
  });

  group('Validators.validateTitle', () {
    test('menolak judul kosong, < 3 karakter, dan > 50 karakter', () {
      expect(Validators.validateTitle(''), isNotNull);
      expect(Validators.validateTitle('ab'), isNotNull);
      expect(Validators.validateTitle('a' * 51), isNotNull);
    });
    test('menerima judul 3-50 karakter', () {
      expect(Validators.validateTitle('Pertemuan 5'), isNull);
    });
  });

  group('Validators.validateContent', () {
    test('menolak isi < 10 karakter dan > 1000 karakter', () {
      expect(Validators.validateContent('pendek'), isNotNull);
      expect(Validators.validateContent('a' * 1001), isNotNull);
    });
    test('menerima isi 10-1000 karakter', () {
      expect(Validators.validateContent('Isi catatan yang cukup.'), isNull);
    });
  });

  group('Validators profil', () {
    test('NIM hanya angka 8-15 digit', () {
      expect(Validators.validateNim('abc'), isNotNull);
      expect(Validators.validateNim('1234567890'), isNull);
    });
    test('email harus valid', () {
      expect(Validators.validateEmail('bukan-email'), isNotNull);
      expect(Validators.validateEmail('a@b.com'), isNull);
    });
  });

  group('Student.initials', () {
    test('mengambil inisial dua kata pertama', () {
      const s = Student(
        name: 'budi santoso',
        nim: '1',
        programStudi: 'TI',
        email: 'a@b.c',
      );
      expect(s.initials, 'BS');
    });
  });
}
