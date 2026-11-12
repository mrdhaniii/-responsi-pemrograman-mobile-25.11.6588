# Profil Mahasiswa dengan Catatan Kuliah

Aplikasi Flutter untuk Responsi Pemrograman Mobile (Pertemuan 1-6).

## Fitur
- **Profil Mahasiswa**: nama, NIM, program studi, email, avatar inisial; dapat diedit.
- **Catatan Kuliah**: tambah, lihat, dan hapus catatan dengan validasi + sanitasi input.
- **Penyimpanan aman**: metadata catatan di SharedPreferences, isi catatan terenkripsi di flutter_secure_storage.
- **HTTP GET**: data pengguna dari API publik (ikon awan di AppBar), lengkap dengan timeout, SocketException, dan logging aman.

## Cara menjalankan
1. Pastikan sudah ada file `.env` (salin dari `.env.example`):
   ```
   BASE_URL=https://jsonplaceholder.typicode.com
   API_KEY=isi_api_key_dummy
   ```
2. `flutter pub get`
3. `flutter run`

## Arsitektur
`UI (screens/widgets) -> Provider (InheritedWidget) -> Repository -> Storage (SharedPreferences / SecureStorage / HTTP)`

## Keamanan
- `.env` ada di `.gitignore`; tidak ada credential di kode.
- Log tidak pernah mencetak isi catatan, API key, atau data sensitif.
- `AndroidManifest.xml`: izin `INTERNET` dan `android:allowBackup="false"`.
