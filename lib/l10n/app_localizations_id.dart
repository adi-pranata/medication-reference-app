// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Referensi Obat';

  @override
  String get medications => 'Obat';

  @override
  String get favorites => 'Favorit';

  @override
  String get searchMedications => 'Cari obat';

  @override
  String get searchHint => 'Cari berdasarkan nama dagang atau generik';

  @override
  String get searchMinLengthHint => 'Ketik minimal 2 karakter untuk mencari.';

  @override
  String get clearSearch => 'Hapus pencarian';

  @override
  String get noMedicationsFound => 'Obat tidak ditemukan';

  @override
  String get noFavoritesYet => 'Belum ada obat favorit';

  @override
  String get tryDifferentSearch => 'Coba kata pencarian yang berbeda.';

  @override
  String get saveFavoritesHint => 'Simpan obat di sini untuk akses cepat.';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get loadMore => 'Muat lebih banyak';

  @override
  String get loading => 'Memuat';

  @override
  String get manufacturer => 'Produsen';

  @override
  String get genericName => 'Nama generik';

  @override
  String get brandName => 'Nama dagang';

  @override
  String get purpose => 'Tujuan dan indikasi';

  @override
  String get dosage => 'Dosis dan penggunaan';

  @override
  String get warnings => 'Peringatan';

  @override
  String get activeIngredients => 'Bahan aktif';

  @override
  String get notAvailable => 'Tidak tersedia';

  @override
  String get technicalDisclaimer =>
      'Informasi ini hanya untuk demonstrasi teknis dan bukan merupakan nasihat medis.';

  @override
  String get networkError =>
      'Tidak dapat terhubung. Periksa koneksi Anda dan coba lagi.';

  @override
  String get serverError => 'Layanan obat sedang tidak tersedia.';

  @override
  String get rateLimitError =>
      'Terlalu banyak permintaan. Tunggu sebentar lalu coba lagi.';

  @override
  String get invalidDataError =>
      'Layanan mengembalikan data obat yang tidak lengkap.';

  @override
  String get unknownError => 'Terjadi kesalahan. Silakan coba lagi.';

  @override
  String get favoriteAdded => 'Ditambahkan ke favorit';

  @override
  String get favoriteRemoved => 'Dihapus dari favorit';

  @override
  String get favoritesSaveError =>
      'Tidak dapat menyimpan favorit. Silakan coba lagi.';

  @override
  String get removeFromFavorites => 'Hapus dari favorit';

  @override
  String get addToFavorites => 'Tambahkan ke favorit';

  @override
  String get refresh => 'Segarkan';

  @override
  String get loadMoreError => 'Tidak dapat memuat obat lainnya.';

  @override
  String get openDetails => 'Buka detail obat';
}
