---
name: Jasama
description: Sistem desain pasar jasa Indonesia yang terstruktur, hangat, dan dapat dipercaya.
---

<!-- SEED: established with the user before implementation; re-run $impeccable document once there's code to capture the actual tokens and components. -->

# Design System: Jasama

## Overview

**Creative North Star: "Catatan Kerja yang Hidup"**

Jasama memakai ketertiban catatan kerja koperasi modern untuk membuat kepercayaan terlihat: siapa Mitranya, apa yang dikerjakan, berapa biayanya, dan bagaimana status Pesanan berubah. Sistem ini diperlunak oleh suasana papan jasa kota—foto manusia dalam konteks kerja nyata, warna hangat, dan bahasa Indonesia yang langsung. Perbandingan arah visualnya adalah sekitar 70% Koperasi Modern dan 30% Papan Jasa Kota.

Antarmuka terasa seperti alat transaksi yang jelas, bukan kantor administrasi. Bidang warna solid, garis tegas, tipografi padat, dan struktur informasi menjadi fondasi. Kehangatan datang dari isi, fotografi dokumenter, ruang bernapas, dan aksen kunyit; bukan dari dekorasi imut, kartu berlapis, atau bentuk membulat berlebihan.

**Tesis visual.** Setiap layar harus membantu pengguna memahami pekerjaan dan tingkat kepercayaannya dengan sekali pindai. Struktur mendahului dekorasi; bukti operasional mendahului klaim.

**Adegan fisik.** Jasama dipakai di ponsel di bawah cahaya siang—di kampus, rumah, tempat kerja, toko, dan perjalanan—serta di desktop untuk pekerjaan digital dan pengelolaan Pesanan. Permukaan terang hangat menjaga keterbacaan; hijau gelap memberi jangkar yang stabil.

**Karakter utama:**

- Terstruktur tetapi tidak birokratis.
- Lokal dan manusiawi tetapi tetap profesional.
- Transparan, tenang, dan praktis.
- Sama cocok untuk jasa lokal maupun digital.
- Ekspresif melalui warna bidang, foto, dan komposisi; bukan efek visual.

**Aturan 70/30.** Struktur, navigasi, formulir, status, tabel, dan pola transaksi mengikuti Koperasi Modern. Kehangatan kota muncul melalui foto, contoh kebutuhan, aksen warna, caption faktual, dan ritme halaman. Jangan menerapkan motif fisik pada setiap komponen.

## Colors

Strategi warna Jasama adalah **full palette yang terkendali**: hijau tua sebagai jangkar, permukaan putih gading, teks arang, kuning kunyit sebagai penekanan utama, dan merah bata hanya untuk risiko. Semua warna berupa bidang solid; gradien dekoratif tidak digunakan.

Nilai berikut adalah kandidat token awal yang sudah dipilih untuk kontras aksesibel. Nama dan perannya mengikat; nilai akhir boleh dikoreksi sedikit setelah pengujian pada perangkat nyata, tetapi tidak boleh mengubah hubungan peran atau karakter palet.

### Brand and action

| Token | Value | Role |
|---|---:|---|
| `color.brand.900` | `#123B34` | Jangkar merek, hero gelap, footer, teks atau ikon kuat pada permukaan hangat. |
| `color.brand.800` | `#174C42` | Hover untuk bidang hijau dan navigasi aktif. |
| `color.brand.700` | `#1E5E50` | Tautan, kontrol aktif, dan elemen merek pada latar terang. |
| `color.action.primary` | `#F2B84B` | Aksi utama seperti `Jelajahi Jasa`; selalu dengan teks arang. |
| `color.action.primary-hover` | `#DFA32F` | Hover atau pressed untuk aksi utama. |
| `color.action.focus` | `#0B6F6A` | Indikator fokus pada permukaan terang. |
| `color.action.focus-inverse` | `#F2B84B` | Indikator fokus pada permukaan hijau gelap. |

### Neutral surfaces and text

| Token | Value | Role |
|---|---:|---|
| `color.surface.canvas` | `#F7F1E3` | Kanvas hangat halaman publik. |
| `color.surface.default` | `#FFFDF7` | Formulir, baris data, kartu Jasa, dan permukaan baca. |
| `color.surface.subtle` | `#EFE8D8` | Kelompok bidang, header tabel, dan bagian sekunder. |
| `color.surface.inverse` | `#123B34` | Permukaan gelap bermerek. |
| `color.text.primary` | `#202522` | Teks utama; rasio 15.3:1 pada `surface.default`. |
| `color.text.secondary` | `#59625D` | Teks pendukung; rasio 6.2:1 pada `surface.default`. |
| `color.text.inverse` | `#FFFDF7` | Teks pada `surface.inverse`; rasio 12.1:1. |
| `color.border.subtle` | `#CDC5B4` | Pemisah non-interaktif dan batas konten yang tenang. |
| `color.border.default` | `#89877E` | Batas kontrol interaktif dan objek mandiri; rasio minimal 3:1 terhadap permukaan. |
| `color.border.strong` | `#6C756F` | Batas state terpilih atau berpenekanan tinggi. |
| `color.overlay` | `rgba(18, 59, 52, 0.56)` | Scrim untuk dialog dan sheet; bukan permukaan dekoratif. |

### Semantic status

| Token | Value | Tint | Use |
|---|---:|---:|---|
| `color.status.success` | `#216A4E` | `#E8F5EE` | Selesai, disetujui, atau verifikasi berhasil. |
| `color.status.info` | `#165C67` | `#EFF9FA` | Informasi proses dan status netral. |
| `color.status.warning` | `#745000` | `#FFF2CC` | Perlu perhatian atau tindakan tertunda. |
| `color.status.error` | `#A33A2B` | `#FFF4F1` | Kesalahan, laporan, pembatalan, dan bahaya. |

Teks status gelap pada tint masing-masing memenuhi WCAG AA untuk teks normal. Putih pada `success` dan `error` juga memenuhi AA. Status selalu menyertakan ikon atau label; warna tidak pernah menjadi satu-satunya pembeda.

**The Turmeric Means Action Rule.** Kuning kunyit menandai tindakan utama atau sorotan yang benar-benar dapat ditindaklanjuti. Jangan memakainya sebagai dekorasi latar pada banyak bagian sekaligus.

**The Brick Means Risk Rule.** Merah bata hanya untuk kesalahan, tindakan destruktif, pelaporan, dan keselamatan. Jangan memakainya untuk promosi atau kategori.

**The Solid Field Rule.** Gunakan warna sebagai bidang yang membangun struktur halaman. Jangan memakai gradien, glow, glassmorphism, atau transparansi dekoratif.

## Typography

Gunakan maksimal dua keluarga font sumber terbuka:

- **Display and heading:** `Barlow Condensed`, fallback `"Arial Narrow", "Roboto Condensed", sans-serif`.
- **Body and interface:** `Source Sans 3`, fallback `"Segoe UI", Arial, sans-serif`.

Barlow Condensed memberi rasa papan informasi dan label kerja yang padat tanpa menjadi industrial. Source Sans 3 bersifat humanis, nyaman untuk Bahasa Indonesia, dan memiliki angka yang jelas untuk harga, rating, serta status Pesanan.

### Type tokens

| Token | Family | Size | Weight | Line height | Use |
|---|---|---:|---:|---:|---|
| `type.display` | Barlow Condensed | `clamp(2.75rem, 6vw, 5rem)` | 600 | 0.98 | Judul hero publik; maksimum 12 kata atau 3 baris di ponsel. |
| `type.heading.1` | Barlow Condensed | `clamp(2.25rem, 4vw, 3.5rem)` | 600 | 1.02 | Judul halaman. |
| `type.heading.2` | Barlow Condensed | `clamp(1.75rem, 3vw, 2.5rem)` | 600 | 1.08 | Judul bagian. |
| `type.heading.3` | Barlow Condensed | `1.5rem` | 600 | 1.15 | Judul kartu besar, panel, dan kelompok data. |
| `type.title` | Source Sans 3 | `1.125rem` | 700 | 1.35 | Judul Jasa, dialog, dan baris penting. |
| `type.body.lg` | Source Sans 3 | `1.125rem` | 400 | 1.6 | Pengantar dan teks hero. |
| `type.body` | Source Sans 3 | `1rem` | 400 | 1.55 | Teks utama dan kontrol. |
| `type.body.sm` | Source Sans 3 | `0.875rem` | 400 | 1.45 | Metadata dan bantuan formulir. |
| `type.label` | Source Sans 3 | `0.875rem` | 600 | 1.3 | Label bidang, tombol ringkas, kategori, dan header data. |
| `type.caption` | Source Sans 3 | `0.8125rem` | 600 | 1.35 | Caption faktual dan metadata sekunder; tidak untuk informasi penting. |

- Aktifkan angka tabular (`font-variant-numeric: tabular-nums`) untuk harga, rating, tanggal, waktu, dan tabel.
- Panjang baris isi dibatasi 65–72 karakter; teks pendukung hero maksimum 52 karakter per baris di desktop.
- Judul menggunakan sentence case, bukan Title Case atau huruf kapital penuh.
- Label kapital penuh hanya boleh digunakan untuk penanda kecil seperti `DATA CONTOH`, maksimum 14 karakter dan tidak lebih dari satu per objek.
- Jangan memakai berat di bawah 400 atau teks di bawah 13px.

**The Two-Voice Rule.** Barlow Condensed memberi arah; Source Sans 3 menyelesaikan pekerjaan. Jangan memakai font ketiga, serif dekoratif, tulisan tangan, atau monospace sebagai gaya.

**The Numbers Stay Calm Rule.** Harga dan data tidak dibesarkan seperti promosi. Gunakan ukuran tubuh atau judul, berat 600–700, dan angka tabular.

## Layout

Sistem layout memakai grid yang tegas dengan ruang bernapas. Bagian publik dapat berganti antara bidang hijau, kanvas hangat, dan permukaan putih, tetapi konten selalu mengikuti satu container dan sumbu grid yang sama.

### Spacing scale

| Token | Value | Typical use |
|---|---:|---|
| `space.0` | `0` | Reset. |
| `space.1` | `4px` | Jarak ikon internal atau metadata rapat. |
| `space.2` | `8px` | Pasangan label, badge, dan ikon. |
| `space.3` | `12px` | Isi kontrol ringkas. |
| `space.4` | `16px` | Padding dasar kartu dan jarak antarkontrol. |
| `space.6` | `24px` | Kelompok formulir dan isi kartu desktop. |
| `space.8` | `32px` | Antarkelompok dalam satu bagian. |
| `space.12` | `48px` | Jarak bagian ponsel dan tablet. |
| `space.16` | `64px` | Jarak bagian desktop. |
| `space.24` | `96px` | Pemisah bagian besar; tidak untuk dashboard. |

Gunakan kelipatan 4px. Hindari nilai satu kali kecuali diperlukan oleh rasio media atau alignment optik.

### Breakpoints

Breakpoints mengikuti perubahan isi, bukan nama perangkat:

| Token | Minimum width | Behavior |
|---|---:|---|
| `breakpoint.sm` | `640px` | Aksi hero dapat berdampingan; formulir pendek menjadi dua kolom. |
| `breakpoint.md` | `768px` | Grid 8 kolom; daftar Jasa dapat menjadi dua kolom. |
| `breakpoint.lg` | `1024px` | Grid 12 kolom; navigasi desktop; filter rail bila berguna. |
| `breakpoint.xl` | `1280px` | Kepadatan maksimum halaman publik dan dashboard. |

### Containers and grids

- **Public container:** lebar maksimum `1200px`; gutter `16px` di bawah 640px, `24px` pada tablet, dan `32px` pada desktop.
- **Dense app container:** lebar maksimum `1440px`; gutter `16px`, `24px`, lalu `32px`.
- **Grid:** 4 kolom di ponsel, 8 di tablet, 12 di desktop; gap `16px`, `24px`, lalu `24px`.
- **Reading column:** maksimum `720px`.
- **Hero:** padat dan fungsional. Di desktop, judul, pencarian, aksi, dan beberapa pintasan kategori harus terlihat dalam viewport awal yang wajar.
- **Category entries:** 2 kolom di ponsel dan 4 kolom di desktop. Delapan kategori homepage tetap terbaca sebagai dua keluarga:
  - **Lokal:** `Antar & Titip Beli`, `Ambil Paket atau Dokumen`, `Antre & Urusan Harian`, `Bantuan Acara`.
  - **Digital:** `Desain & Presentasi`, `Video & Audio`, `Belajar & Tutor`, `Teknologi & Data`.
- **Jasa results:** 1 kolom di ponsel, 2 di tablet, 3 atau 4 di desktop berdasarkan panjang isi; jangan memaksa empat kolom jika judul dan metadata menjadi sempit.
- **Section rhythm:** ruang di atas judul bagian selalu lebih besar daripada ruang antara judul dan isi.

### Responsive behavior

- Rancang dari lebar `320px`; tidak boleh ada scroll horizontal pada isi utama.
- Label Indonesia yang panjang membungkus alami. Tindakan utama tidak dipotong dengan elipsis.
- Urutan DOM sama dengan urutan visual. Jangan mengubah urutan dengan CSS bila merusak fokus keyboard.
- Navigasi dan kontrol sticky menghormati safe area dan tidak menutupi isi atau keyboard layar.
- Media memakai rasio stabil sebelum dimuat untuk mencegah layout shift.
- Informasi yang muncul saat hover juga harus tersedia lewat fokus, klik, atau teks tetap.

### Dashboards and dense data

- Dashboard lebih padat daripada halaman publik: jarak bagian `32–48px`, padding panel `16–24px`, dan tidak memakai hero pemasaran.
- Gunakan tabel untuk perbandingan data yang benar-benar tabular pada desktop. Di ponsel, ubah menjadi daftar baris berlabel; jangan membungkus setiap nilai menjadi kartu terpisah.
- Kolom angka rata kanan dan memakai angka tabular. Nama, Jasa, dan Pesanan rata kiri.
- Header tabel tetap terlihat hanya bila tidak menghalangi konten. Tabel lebar boleh scroll horizontal dengan petunjuk visual dan kolom identitas pertama tetap terbaca.
- Filter, pencarian, pilihan massal, dan jumlah hasil berada dalam satu toolbar yang dapat membungkus.
- Status Pesanan ditampilkan sebagai teks plus ikon. Riwayat status menjadi timeline vertikal yang menunjukkan waktu, pelaku, dan perubahan.
- Tindakan destruktif dipisahkan secara visual dari tindakan rutin dan meminta konfirmasi jika sulit dibatalkan.
- Empty state tidak boleh menghapus navigasi, konteks halaman, atau jalan keluar utama.

**The Shared Axis Rule.** Setiap bagian mengikuti container dan sumbu grid yang sama, meskipun warna latarnya berubah.

**The Cards Are Objects Rule.** Kartu hanya untuk objek mandiri seperti Jasa, Mitra, Permintaan, atau Pesanan. Jangan memasukkan setiap bagian, teks, dan toolbar ke kartu bersarang.

## Elevation & Depth

Jasama datar secara default. Hirarki dibuat melalui warna permukaan, batas, jarak, dan bidang, bukan tumpukan bayangan. Bayangan hanya menunjukkan elemen yang secara nyata berada di atas alur dokumen.

### Border tokens

| Token | Value | Use |
|---|---|---|
| `border.subtle` | `1px solid #CDC5B4` | Pemisah non-interaktif, baris tabel, dan batas konten yang tenang. |
| `border.default` | `1px solid #89877E` | Kontrol interaktif dan objek mandiri seperti kartu Jasa. |
| `border.strong` | `2px solid #6C756F` | State terpilih atau kelompok penting. |
| `border.inverse` | `1px solid rgba(255, 253, 247, 0.32)` | Pemisah pada bidang hijau. |

### Shadow tokens

| Token | Value | Use |
|---|---|---|
| `shadow.low` | `0 2px 8px rgba(18, 59, 52, 0.10)` | Sticky navigation setelah terangkat dari hero. |
| `shadow.overlay` | `0 12px 32px rgba(18, 59, 52, 0.18)` | Dialog, menu, combobox, dan mobile sheet. |

Hover pada kartu boleh mengubah border ke `color.border.strong` dan berpindah maksimal `-2px`; jangan menambah bayangan besar. Fokus selalu memakai outline solid, bukan bayangan ambient.

**The Flat Until Floating Rule.** Jika elemen tidak menutupi atau mengambang di atas elemen lain, elemen itu tidak mendapat bayangan.

## Shapes

Bentuk Jasama terutama persegi panjang dengan pembulatan sederhana. Sudut terasa kokoh dan mudah dipindai, bukan lembut seperti aplikasi gaya hidup.

| Token | Value | Use |
|---|---:|---|
| `radius.none` | `0` | Tabel, divider, bidang bagian, dan detail potongan. |
| `radius.sm` | `4px` | Badge status dan label ringkas. |
| `radius.md` | `8px` | Tombol, input, kartu, menu, dan foto. |
| `radius.lg` | `12px` | Dialog dan sheet besar; tidak untuk setiap panel. |
| `radius.full` | `999px` | Avatar dan indikator bulat saja; bukan tombol atau filter default. |

Motif receipt, cap, label papan, kertas ditempel, atau sudut terpotong hanya boleh menyampaikan fungsi nyata—misalnya pemisah rincian Pesanan atau penanda dokumen. Maksimum satu motif ekspresif per kelompok visual; tidak ada tekstur kertas palsu, tape dekoratif, atau cap acak.

**The Modest Corner Rule.** Radius standar adalah 8px. Jangan memakai superellipse, blob, atau kartu 24–32px yang membuat produk terasa seperti SaaS generik.

## Components

Pola berikut adalah kontrak perilaku dan visual. Nama komponen adalah kandidat implementasi; jangan membuat abstraksi tambahan sebelum pola benar-benar dipakai berulang.

### Buttons

- Tinggi minimum `44px`; padding horizontal `16–20px`; gap ikon `8px`; radius `8px`.
- Label berupa kata kerja yang spesifik. Ikon mendukung label, bukan menggantikannya kecuali kontrol umum seperti favorit atau tutup.
- Satu kelompok tindakan memiliki satu aksi utama.
- **Primary:** latar `color.action.primary`, teks `color.text.primary`, berat 700. Hover memakai `color.action.primary-hover`; active tidak bergeser lebih dari 1px.
- **Secondary:** permukaan transparan atau putih, teks `color.brand.900`, border `color.brand.900`.
- **Tertiary:** tautan teks `color.brand.700` dengan underline pada hover dan fokus.
- **Inverse:** di atas hijau, gunakan permukaan putih gading dengan teks hijau; kuning tetap dicadangkan untuk aksi utama halaman.
- **Destructive:** latar `color.status.error` dengan teks putih, hanya untuk tindakan destruktif yang sudah jelas konsekuensinya.
- **Disabled:** pertahankan label terbaca, kurangi kontras keseluruhan, hilangkan hover, dan gunakan `cursor: not-allowed`; jangan hanya menurunkan opacity hingga sulit dibaca.
- **Loading:** pertahankan lebar tombol, ganti ikon dengan indikator kecil, dan ubah label menjadi tindakan sedang berlangsung seperti `Menyimpan…`.

`Jelajahi Jasa` adalah aksi primary di hero. `Buat Permintaan` adalah secondary yang sama-sama menonjol, bukan tautan samar. `Daftar` boleh menjadi tombol hijau ringkas di navbar agar tidak bersaing dengan aksi kunyit di isi halaman.

### Forms and fields

- Label selalu terlihat di atas kontrol; placeholder hanya contoh, bukan pengganti label.
- Tinggi input satu baris minimum `48px`; padding `12px 14px`; border 1px; radius `8px`; permukaan putih.
- Teks bantuan berada sesudah kontrol dan sebelum pesan error.
- Fokus utama memakai outline solid `3px` dengan offset `2px`: `color.action.focus` pada permukaan terang dan `color.action.focus-inverse` pada permukaan hijau gelap. Border boleh ikut berubah, tetapi outline solid tidak boleh digantikan oleh ring transparan atau bayangan.
- Error memakai border merah bata, ikon, dan teks perbaikan yang spesifik. Setelah submit gagal, fokus berpindah ke bidang tidak valid pertama.
- Required ditulis dengan `Wajib` atau keterangan kelompok; jangan mengandalkan tanda bintang tanpa penjelasan.
- Pilihan lokal/digital, status, dan kategori memakai kontrol native bila sesuai. Jangan menambah date picker, select, atau switch kustom tanpa kebutuhan nyata.
- Nilai pengguna dipertahankan saat error, kembali dari detail, atau berpindah dari pencarian ke Permintaan.
- Aksi mengikat atau destruktif menjelaskan konsekuensi sebelum konfirmasi.

### Navigation

**Desktop public navigation:**

1. Wordmark `Jasama`
2. `Jelajahi Jasa`
3. `Cara Kerja`
4. `Jadi Mitra`
5. `Masuk`
6. `Daftar`

`Kategori` berada di dalam `Jelajahi Jasa`. Penjelasan `Keamanan` berada di homepage dan tautan lengkapnya di footer. `Buat Permintaan` boleh muncul sebagai aksi sekunder ringkas bila ruang mencukupi, tetapi tidak wajib.

- Tinggi navbar `64–72px`; wordmark dan tujuan utama rata pada satu sumbu.
- Item aktif memakai berat 700 dan garis bawah atau bidang aktif yang tegas; bukan perubahan warna samar.
- Navbar boleh sticky setelah hero. Saat sticky, gunakan permukaan solid dan `shadow.low`.

**Mobile public navigation:**

- Bar awal menampilkan wordmark, kontrol pencarian, `Masuk`, dan tombol menu berlabel aksesibel.
- Menu terbuka sebagai panel atau sheet yang terurut, tidak sebagai dropdown sempit.
- `Jelajahi Jasa` dan `Buat Permintaan` tetap mudah ditemukan; `Jadi Mitra` berada setelah jalur Pemesan.
- Saat keyboard terbuka, navbar tidak boleh menutup search atau isi.

Footer dikelompokkan berdasarkan tugas: Jelajahi; Untuk Mitra; Keamanan dan bantuan; Tentang Jasama. Jangan menampilkan tautan sosial, lencana app store, penghargaan, atau logo mitra yang belum ada.

### Jasa cards

Urutan baca wajib:

1. Thumbnail atau portfolio preview dengan rasio stabil.
2. Kategori serta konteks Lokal/Digital.
3. Judul Jasa spesifik, maksimum dua baris.
4. Nama Mitra dan status pemeriksaan yang benar: `Profil Mitra diperiksa` untuk closed beta; `Identitas terverifikasi` hanya untuk proses identitas masa depan yang telah disetujui dan beroperasi.
5. Lokasi atau `Dikerjakan online`.
6. Rating dan jumlah ulasan, atau `Belum ada ulasan`.
7. Dasar harga seperti `Mulai dari` hanya jika didukung listing.
8. Tombol favorit dengan nama aksesibel.

- Radius `8px`, border default, tanpa shadow saat diam.
- Isi tumbuh sesuai konten; jangan memotong informasi penting demi tinggi kartu seragam.
- Seluruh kartu memiliki satu tautan utama; favorit tetap tombol terpisah dengan target 44px.
- Maksimum dua marker trust/status yang ringkas.
- Di development dan staging, kartu boleh memakai harga, rating, ulasan, profil, listing, dan Pesanan sintetis yang realistis hanya dari record bertanda `is_demo`. Kartu hanya memakai label per objek ketika data demo dan data nyata sengaja ditampilkan bersama.
- Di produksi dan klaim publik, jangan menampilkan data fabrikasi, ranking, kecepatan respons, jumlah Pesanan, atau klaim kinerja.

### Mitra cards

Urutan baca: foto atau placeholder yang disetujui, nama, keahlian utama, area atau layanan online, status pemeriksaan profil, rating beserta jumlah ulasan atau status Mitra baru, dua sampai tiga keahlian, lalu `Lihat profil`.

- Portfolio preview hanya bila membantu evaluasi.
- Status belum terverifikasi disampaikan netral dan jelas; jangan mempermalukan Mitra baru.
- Status `Profil Mitra diperiksa` harus dapat dibuka atau diikuti penjelasan bahwa closed beta memeriksa email, telepon, kelengkapan profil, portfolio, dan kelayakan onboarding manual tanpa government ID atau media pencocokan identitas.
- Di produksi dan klaim publik, jangan menampilkan testimonial fabrikasi, `Mitra terbaik`, statistik rekaan, atau bukti performa yang tidak berasal dari data nyata.

### Search and filters

- Hero search memiliki label `Cari jasa`, placeholder contoh, dan tombol `Cari`.
- Suggestion list mengikuti pola ARIA combobox/listbox; opsi menunjukkan jenis `Jasa`, `Kategori`, atau `Mitra`.
- Keyboard mendukung panah, Enter, Escape, submit query mentah, dan pengumuman opsi aktif.
- Hasil menampilkan query yang dapat diedit, ringkasan dalam bahasa biasa, filter aktif, satu `Hapus semua`, serta urutan `Paling sesuai`.
- Filter lokasi hanya muncul untuk pekerjaan lokal. Jangan meminta GPS; kota atau area dipilih manual.
- Desktop boleh memakai filter rail jika jumlah filter membutuhkannya. Di ponsel, `Filter` dan `Urutkan` berdampingan; filter membuka sheet penuh dengan `Terapkan` dan `Hapus semua`.
- Filter aktif dapat memakai chip dengan radius `4px`, tombol hapus 44px, dan label lengkap. Hindari baris chip horizontal yang tidak dapat dipindai.
- Kembali dari detail memulihkan query, filter, posisi hasil, dan fokus.

**Browse-to-request bridge.** Jika hasil tidak cocok, tampilkan `Buat Permintaan dari pencarian ini`. Query dan filter yang relevan memprefill Permintaan; filter yang tidak bermakna tidak ikut. Pengguna dapat meninjau dan mengubah semua nilai sebelum mengirim. Jangan meminta pengguna mengetik ulang.

### Status and semantic feedback

- Badge status memakai radius `4px`, tint semantik, ikon 16px, dan label teks.
- Status Pesanan memakai kata kerja atau keadaan yang jelas: `Menunggu persetujuan`, `Sedang dikerjakan`, `Perlu tindakan`, `Selesai`, `Dibatalkan`.
- Pemeriksaan profil/verifikasi, review Pesanan selesai, laporan, sengketa, dan histori status harus menyebut mekanisme yang benar-benar terjadi. Closed beta memakai `Profil Mitra diperiksa`, bukan `Identitas terverifikasi`.
- Jangan menulis `Aman`, `Dijamin`, `Pembayaran terlindungi`, `Refund terjamin`, `Dukungan 24 jam`, atau `Semua Mitra terverifikasi` sebelum sistem dan bukti tersedia.

### Loading, empty, success, error, and unavailable states

**Loading**

- Gunakan skeleton yang mengikuti bentuk akhir; jangan memakai spinner satu halaman untuk pembaruan lokal.
- Pertahankan hasil lama saat filter diperbarui bila memungkinkan.
- Umumkan `Mencari jasa…` atau tindakan setara melalui live region yang sopan.

**Empty and no results**

- Jelaskan apa yang belum ada, lalu berikan satu jalan maju.
- No-results menawarkan `Hapus filter` dan `Buat Permintaan`; jangan menyalahkan istilah pengguna.
- Akun baru menawarkan `Jelajahi Jasa`, bukan ilustrasi besar tanpa tindakan.

**Success**

- Tindakan penting mendapat konfirmasi persisten dengan dampak dan langkah berikutnya.
- Tindakan ringan seperti favorit boleh memakai feedback inline atau toast singkat yang dapat dibaca pembaca layar.

**Error**

- Nyatakan masalah, apa yang tetap tersimpan, dan tindakan pemulihan.
- Pesan berada dekat sumber error dan diringkas di atas formulir panjang bila perlu.
- Jangan menghapus query, filter, draft, atau unggahan yang sudah berhasil.

**Unavailable**

- Bedakan `tidak tersedia lagi`, `tidak memiliki akses`, `sementara offline`, dan `dihapus karena moderasi`; masing-masing membutuhkan penjelasan dan jalan keluar yang berbeda.
- Jangan membuka detail moderasi privat. Arahkan ke kebijakan, alternatif, atau bantuan yang sesuai.
- Kontrol yang tidak tersedia harus menjelaskan alasannya; jangan sekadar disabled tanpa konteks.

### Iconography

Gunakan satu library: **Material Symbols Sharp**, dengan gaya variable yang konsisten.

- Ukuran default 20px; 16px untuk metadata, 24px untuk aksi utama, dan 28–32px untuk kategori.
- Stroke/weight visual setara 500; gunakan sumbu `FILL` untuk state aktif bila tersedia.
- Ikon kategori harus memiliki metafora tunggal dan tidak ambigu. Ikon tidak menggantikan label.
- Status selalu memakai ikon plus teks. Ikon-only button wajib memiliki accessible name dan tooltip bila maknanya tidak universal.
- Jangan memakai emoji, campuran library, ikon 3D, atau ilustrasi generik dalam kotak warna.

### Imagery

- Gunakan fotografi dokumenter tentang pekerjaan nyata di Indonesia: jarak dekat yang kontekstual, cahaya alami, ruang sehari-hari, pakaian dan alat kerja yang wajar.
- Seimbangkan jasa lokal dan digital. Pekerjaan digital diperlihatkan melalui orang yang bekerja dan crop artefak yang berguna, bukan layar laptop generik.
- Tampilkan variasi usia dewasa, gender, warna kulit, kemampuan, wilayah, dan konteks ekonomi tanpa tokenisme.
- Hindari pose sambil menatap kamera, high-five tim kantor, kurir sebagai satu-satunya wajah layanan lokal, latar coworking mewah, dan visual AI yang cacat atau tidak masuk akal.
- Foto Jasa memakai rasio `4:3`; portfolio digital boleh `3:2` atau rasio asli bila konteksnya jelas; avatar `1:1`.
- Caption hanya faktual—jenis layanan atau area. Jangan menempelkan kutipan testimonial rekaan pada foto.
- Alt text menjelaskan informasi yang berguna; gambar dekoratif memiliki alt kosong.
- Lingkungan staging menampilkan banner demo persisten. Foto, profil, listing, harga, rating, ulasan, dan Pesanan sintetis membawa marker data `is_demo`, dan semua record demo ditolak atau dikecualikan dari produksi. Label per objek hanya dipakai ketika data demo dan data nyata sengaja ditampilkan bersama.

### Motion and reduced motion

- State mikro: `160ms` dengan `cubic-bezier(0.2, 0, 0, 1)`.
- Panel, sheet, dan dialog: `220ms` dengan easing yang sama.
- Entrance bagian, bila benar-benar membantu orientasi: maksimum `320ms`, sekali, tanpa menahan akses ke isi.
- Transform maksimum 2px untuk hover; jangan memakai parallax, scroll hijacking, marquee, floating loop, atau animasi dekoratif terus-menerus.
- Konten terlihat secara default; kegagalan JavaScript tidak boleh menyembunyikannya.
- Pada `prefers-reduced-motion: reduce`, hapus entrance dan transform; pertahankan perubahan state instan atau crossfade maksimum `80ms`. Skeleton tidak berkilau.

### Accessibility

- Target minimum **WCAG 2.2 AA**.
- Kontras teks normal minimum 4.5:1, teks besar 3:1, komponen dan indikator fokus 3:1 terhadap warna sekitarnya.
- Indikator fokus utama adalah outline solid `3px` dengan offset `2px`, memakai token fokus terang atau inverse sesuai permukaan. Ring transparan tidak boleh menjadi satu-satunya indikator.
- Target sentuh minimum 44×44 CSS px dengan jarak yang cukup.
- Semua alur dapat digunakan dengan keyboard; fokus terlihat, urut, dan kembali ke pemicu setelah dialog atau sheet ditutup.
- Gunakan elemen semantik native sebelum ARIA. Heading berurutan; landmark dan nama halaman jelas.
- Setiap kontrol memiliki label yang persisten. Error mengidentifikasi bidang dan cara memperbaikinya.
- Status, pilihan, dan grafik tidak bergantung pada warna saja.
- Layout harus reflow pada 320px dan tetap dapat digunakan pada zoom 200%.
- Teks dapat diperbesar tanpa terpotong. Jangan mengunci tinggi komponen yang berisi copy dinamis.
- Video atau audio, jika kelak ada, membutuhkan caption/transkrip dan kontrol; autoplay bersuara dilarang.
- Pengujian minimum sebelum rilis: keyboard lengkap, pembaca layar pada alur utama, kontras token, zoom 200%, reduced motion, dan mobile touch.

### Content and Indonesian copy

- Bahasa utama adalah Indonesia yang alami, langsung, inklusif, dan tidak terlalu formal.
- Gunakan istilah produk secara konsisten: `Pemesan`, `Mitra`, `Jasa`, `Permintaan`, `Pesanan`, `Jadi Mitra`, `Jelajahi Jasa`, `Buat Permintaan`.
- Gunakan `kamu` dalam panduan percakapan; gunakan label netral pada kontrol yang sering berulang.
- Pilih verba familier: `Cari`, `Lihat`, `Pilih`, `Simpan`, `Kirim`, `Batalkan`.
- Jelaskan istilah marketplace saat pertama muncul. Nyatakan konsekuensi sebelum tindakan mengikat atau destruktif.
- Gunakan sentence case. Hindari jargon Inggris, bahasa korporat, slang anak muda, hiperbola, dan copy yang terdengar dibuat mesin.
- Format uang sebagai `Rp25.000`; tanggal sebagai `27 Juli 2026`; waktu menyebut zona seperti `14.30 WIB` bila relevan.
- Di produksi dan semua klaim publik, testimonial, klaim, statistik, rating, ulasan, harga, partner, ranking, dan bukti performa fabrikasi dilarang. Data sintetis tidak pernah boleh ditampilkan sebagai bukti pelanggan nyata.
- Development dan staging boleh memakai harga, rating, ulasan, profil, listing, dan Pesanan sintetis yang realistis hanya pada record bertanda `is_demo`. Staging wajib menampilkan banner demo persisten.
- Produksi wajib menolak atau mengecualikan seluruh record `is_demo`. Gunakan label per objek hanya bila data demo dan data nyata sengaja tampil bersama.
- Copy trust closed beta menyebut tindakan sistem: `Profil Mitra diperiksa admin`, `Ulasan dari Pesanan selesai`, atau `Riwayat status tercatat`; bukan `Identitas terverifikasi` atau janji keselamatan umum.

### Reusable naming conventions

Gunakan nama berbasis peran agar visual dapat berubah tanpa mengganti seluruh kode:

- **Primitive tokens:** `color.brand.900`, `space.4`, `radius.md`.
- **Semantic tokens:** `color.surface.default`, `color.text.secondary`, `color.action.primary`, `color.status.error`.
- **Component tokens:** `{component}.{part}.{state}`, misalnya `button.primary.hover`, `input.border.focus`, `card.jasa.border`.
- **Motion tokens:** `motion.duration.fast`, `motion.duration.panel`, `motion.ease.standard`.
- **Components:** gunakan nama domain yang langsung: `JasaCard`, `MitraCard`, `SearchField`, `FilterSheet`, `StatusBadge`, `EmptyState`, `OrderHistory`.
- **Variants:** gunakan tujuan, bukan warna: `primary`, `secondary`, `tertiary`, `destructive`, `inverse`.
- **States:** gunakan atribut semantik seperti `data-state="loading|success|error|unavailable"` bila native state tidak tersedia.

Jangan membuat alias untuk satu pemakaian, `CardBase` abstrak sebelum ada pola bersama, atau token seperti `green-1` dan `yellow-button` yang mengikat nama pada warna atau tempat.

## Do's and Don'ts

### Do

- **Do** membuat kepercayaan terlihat melalui status pemeriksaan profil yang benar, provenance ulasan, rincian Pesanan, pelaporan, dan riwayat—hanya saat mekanismenya benar-benar tersedia.
- **Do** menjaga `Jelajahi Jasa` sebagai aksi utama dan `Buat Permintaan` sebagai pendamping menonjol.
- **Do** memperlakukan jasa lokal dan digital sebagai dua keluarga yang setara.
- **Do** memakai delapan kategori homepage yang disetujui: empat Lokal dan empat Digital; taksonomi lengkap berada di discovery.
- **Do** memakai foto manusia dan artefak kerja yang nyata untuk menghangatkan struktur.
- **Do** menyimpan query serta filter saat berpindah dari browse ke Permintaan.
- **Do** menguji komponen dengan label Bahasa Indonesia yang panjang, data kosong, error, dan isi maksimum.
- **Do** menggunakan warna, garis, ruang, dan tipografi sebelum menambah kartu atau bayangan.

### Prohibited design patterns (Don't)

- **Don't** membuat Jasama terlihat seperti situs pemerintah, administrasi koperasi tradisional, dashboard bank, aplikasi kurir saja, atau template SaaS generik.
- **Don't** memakai gradien dekoratif, glassmorphism, glow, blob, kartu bersarang, pill berlebihan, headline kosong yang terlalu besar, atau whitespace yang mendorong pencarian keluar viewport awal.
- **Don't** memakai receipt, cap, papan pengumuman, sudut terpotong, label kiriman, tape, atau kertas ditempel sebagai gimmick berulang.
- **Don't** memakai ungu-biru bergaya AI, ikon emoji, campuran keluarga ikon, foto stok korporat, atau copy generik.
- **Don't** menandai kategori sebagai `Populer` tanpa analytics.
- **Don't** mengklaim pembayaran aman, refund, garansi, dukungan 24 jam, atau verifikasi menyeluruh sebelum sistem dan buktinya ada.
- **Don't** menyamarkan data sintetis sebagai bukti pelanggan.
- **Don't** mengorbankan aksesibilitas, validasi, keamanan, atau pemulihan data untuk kerapian visual.
