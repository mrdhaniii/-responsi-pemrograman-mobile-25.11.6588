#!/usr/bin/env bash
# Membuat riwayat Git untuk Soal 1:
#   - minimal 5 commit dengan pesan deskriptif
#   - 2 branch fitur (fitur-profil, fitur-catatan) yang di-merge ke main
#
# Jalankan SEKALI dari folder proyek (setelah semua file ada):
#   GIT_NAME="Nama Anda" GIT_EMAIL="email@anda.com" bash setup_git.sh
set -euo pipefail
cd "$(dirname "$0")"

if [ -d .git ]; then
  echo "Folder ini sudah berisi repository Git. Hentikan." >&2
  exit 1
fi

git init -q -b main
git config user.name "${GIT_NAME:-Nama Mahasiswa}"
git config user.email "${GIT_EMAIL:-mahasiswa@example.com}"

# Menambahkan path hanya jika ada (folder platform dibuat oleh `flutter create`).
add_existing() {
  for p in "$@"; do
    if [ -e "$p" ]; then git add -- "$p"; fi
  done
}
commit() {
  local msg="$1"; shift
  add_existing "$@"
  git commit -q -m "$msg"
}

# --- main: fondasi proyek ---------------------------------------------------
commit "chore: inisialisasi proyek Flutter, .gitignore, dan konfigurasi Android" \
  .gitignore .env.example pubspec.yaml pubspec.lock analysis_options.yaml README.md \
  .metadata android ios

commit "feat(config): tambah AppConfig, tema terpusat, model Student/Note, dan Validators" \
  lib/config lib/models lib/utils

commit "feat(data): tambah SecureStorageService dan NoteRepository (HTTP GET + error handling)" \
  lib/services lib/repositories

commit "feat(state): tambah AppProvider (InheritedWidget) dan AppProviderWrapper" \
  lib/providers

# --- branch fitur-profil ----------------------------------------------------
git checkout -q -b fitur-profil
commit "feat(profil): tambah widget ProfileCard" lib/widgets/profile_card.dart
commit "feat(profil): tambah ProfileScreen dengan dialog edit profil" lib/screens/profile_screen.dart

# --- branch fitur-catatan (dari main yang sama) -----------------------------
git checkout -q main
git checkout -q -b fitur-catatan
commit "feat(catatan): tambah NoteCard dan EmptyState" \
  lib/widgets/note_card.dart lib/widgets/empty_state.dart
commit "feat(catatan): tambah NoteFormScreen dengan validasi dan sanitasi" \
  lib/screens/note_form_screen.dart

# --- merge kedua branch fitur ke main ---------------------------------------
git checkout -q main
git merge -q --no-ff fitur-profil -m "merge: gabungkan fitur-profil ke main"
git merge -q --no-ff fitur-catatan -m "merge: gabungkan fitur-catatan ke main"

# --- integrasi akhir --------------------------------------------------------
git add -A
git commit -q -m "feat: tambah HomeScreen, navigasi, main.dart, dan unit test"

echo
echo "Riwayat commit:"
git log --graph --oneline --all
