# SandanaTrackFlow 📱

> **Sistem Manajemen dan Tracking Alur Dokumen Proyek Berbasis Mobile**

---

## 👥 Tim Pengembang

| Nama | NPM | Role |
|------|-----|------|
| [Nadia Ardiyanti Sutrisno] | [24082010065] | Developer |
| [Shelvia Retha Sofiana] | [24082010082] | Developer |
| [Nafiisha Nuurfathina] | [24082010090] | Developer |

---

## 📖 Deskripsi Aplikasi

**SandanaTrackFlow** adalah aplikasi mobile berbasis Android yang dirancang untuk mengelola dan melacak alur dokumen proyek secara digital. Aplikasi ini menghubungkan tiga departemen utama — **Sales**, **Engineering**, dan **Finance** — dalam satu platform terintegrasi.

Aplikasi ini menyelesaikan permasalahan umum dalam pengelolaan dokumen proyek seperti alur persetujuan yang tidak terstruktur, kurangnya transparansi status dokumen, proses tanda tangan manual yang tidak efisien, dan tidak adanya notifikasi otomatis antar departemen.

---

## ✨ Fitur Utama

### 🔐 Autentikasi
- Login dengan dropdown pemilihan department (Sales / Engineering / Finance)
- Register akun baru dengan validasi department
- Password terenkripsi menggunakan SHA-256
- Session management dengan Shared Preferences

### 🏠 Home Dashboard
- Kartu status project: **Active**, **Delay**, **Done**, **Payment**
- Donut chart visualisasi Project Status secara real-time
- Recent Projects dengan warna berbeda per tipe dokumen
- Notifikasi bell di header

### 📁 Project — Pembuatan Dokumen
- **Sales** → Membuat **BRD** (Business Requirement Document)
  - Assign ke Engineering dan/atau Finance
- **Engineering** → Membuat **Berita Acara** / Technical Report
  - Hanya bisa dibuat setelah BRD disetujui semua pihak
  - Assign ke Finance
- **Finance** → Membuat **Invoice**
  - Hanya bisa dibuat setelah Berita Acara disetujui Finance
  - Assign ke Sales
- Form dokumen: Assign To, Lead Project, Task Title, Start/End Date, Description, Upload File (PDF/DOC/XLS)

### 📊 Reports — Alur Persetujuan
Filter dokumen per role:
- **Sales** → Lihat semua dokumen (BRD, Berita Acara, Invoice)
- **Engineering** → BRD + Berita Acara
- **Finance** → BRD + Berita Acara + Invoice

Fitur di Reports:
- Warna card berbeda: **BRD = Biru**, **Berita Acara = Merah**, **Invoice = Abu**
- Badge **"Perlu TTD"** / **"Sudah TTD"** per dokumen
- Tombol **TANDA TANGAN** untuk dokumen yang perlu disetujui
- Tombol **Menunggu...** untuk dokumen yang dibuat sendiri
- Tombol **SEE DETAILS** untuk dokumen yang sudah selesai
- Tombol **DELETE** khusus Sales untuk BRD yang belum ada approval sama sekali
- Tombol **UPDATE STATUS** untuk mengubah status project

### ✍️ Tanda Tangan Digital
- Signature pad untuk tanda tangan langsung di layar
- TTD tersimpan sebagai file gambar PNG
- Setelah TTD tidak bisa diubah lagi
- Gambar TTD ditampilkan kembali saat SEE DETAILS

### 📄 Preview Dokumen
- Preview file PDF langsung di dalam aplikasi
- Menampilkan detail dokumen (judul, deskripsi, tanggal, assign to)

### 🔔 Notifikasi
- Notifikasi otomatis saat dokumen memerlukan persetujuan
- Warna notifikasi berbeda per department pengirim:
  - Sales → Biru
  - Engineering → Abu
  - Finance → Merah
- Klik SEE DETAILS dari notifikasi langsung ke halaman tanda tangan

### 👤 Profile
- User Information (foto, nama, email, department, telepon)
- Edit Profile dengan upload foto dari galeri
- Change Password (current, new, confirm)
- Logout

---

## 🔄 Alur Dokumen

```
1. SALES buat BRD
   └─► Notifikasi ke Finance & Engineering
         │
         ├─► Finance TTD BRD        (progress 50%)
         └─► Engineering TTD BRD    (progress 100%) → BRD: DONE

2. ENGINEERING buat Berita Acara
   └─► Notifikasi ke Finance
         │
         └─► Finance TTD Berita Acara (progress 100%)
               └─► Berita Acara: PAYMENT
               └─► Semua BRD → PAYMENT

3. FINANCE buat Invoice
   └─► Notifikasi ke Sales
         │
         └─► Sales TTD Invoice (progress 100%)
               └─► Invoice: DONE
               └─► Semua BRD & Berita Acara → DONE ✅
```

---

## 📊 Status Dokumen

| Status | Arti | 
|--------|------|
| `active` | Dokumen aktif, dalam proses persetujuan 
| `delay` | Ditunda (update manual oleh Sales) 
| `payment` | Pekerjaan selesai, menunggu pembayaran 
| `done` | Selesai & lunas 

---

## 🗄️ Database

Menggunakan **SQLite** (sqflite) — database lokal di perangkat.

### Tabel:
| Tabel | Fungsi |
|-------|--------|
| `users` | Data pengguna (nama, email, password hash, department) |
| `documents` | Data dokumen (type, title, status, file path) |
| `document_approvals` | Record tanda tangan per dokumen per user |
| `notifications` | Notifikasi antar departemen |

---

## 🛠️ Tech Stack

| Kategori | Teknologi | Versi |
|----------|-----------|-------|
| Framework | Flutter | 3.x |
| Bahasa | Dart | 3.x |
| State Management | Provider | 6.1.1 |
| Database | sqflite (SQLite) | 2.3.0 |
| Tanda Tangan Digital | syncfusion_flutter_signaturepad | 33.2.7 |
| PDF Viewer | syncfusion_flutter_pdfviewer | 33.2.7 |
| Chart | fl_chart | 1.2.0 |
| File Upload | file_picker | 8.0.0 |
| Image Picker | image_picker | 1.0.7 |
| Enkripsi Password | crypto (SHA-256) | 3.0.3 |
| Session | shared_preferences | 2.2.2 |

---

## 🏗️ Arsitektur

Menggunakan **MVVM (Model-View-ViewModel)** dengan struktur:

```
lib/
├── main.dart
├── app/
│   ├── app_colors.dart
│   ├── app_routes.dart
│   └── app_theme.dart
├── core/
│   └── database/
│       └── db_helper.dart
├── models/
│   ├── user_model.dart
│   ├── document_model.dart
│   └── notification_model.dart
├── viewmodels/
│   ├── auth_viewmodel.dart
│   ├── home_viewmodel.dart
│   ├── document_viewmodel.dart
│   ├── report_viewmodel.dart
│   └── profile_viewmodel.dart
└── views/
    ├── splash/
    ├── landing/
    ├── auth/
    ├── home/
    ├── project/
    ├── reports/
    ├── notification/
    ├── profile/
    └── widgets/
```

---

## 📋 Metodologi

**SDLC Prototype** — dipilih karena kebutuhan yang dinamis dan memerlukan visualisasi awal sebelum produk final.

Tahapan:
1. Communication
2. Quick Plan
3. Modelling Quick Design
4. Construction of Prototype
5. Deployment Delivery and Feedback

---

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK 3.x
- Android Studio + Emulator (API 33+) atau HP Android
- VS Code dengan extension Flutter & Dart

---


## 📦 Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  sqflite: ^2.3.0
  path: ^1.9.0
  file_picker: ^8.0.0
  image_picker: ^1.0.7
  syncfusion_flutter_signaturepad: ^33.2.7
  syncfusion_flutter_pdfviewer: ^33.2.7
  fl_chart: ^1.2.0
  shared_preferences: ^2.2.2
  cupertino_icons: ^1.0.2
  crypto: ^3.0.3
```

---

## 🎓 Informasi Akademik

| | |
|---|---|
| **Mata Kuliah** | Pemrograman Mobile |
| **Platform** | Android (Flutter) |
| **Metodologi** | SDLC Prototype |
| **Architectural Pattern** | MVVM (Model-View-ViewModel) |
| **Universitas** | Universitas Pembangunan Nasional "Veteran" Jawa Timur |

---

*SandanaTrackFlow — Digitalisasi Alur Dokumen Proyek untuk Efisiensi Bisnis yang Lebih Baik* 🚀
