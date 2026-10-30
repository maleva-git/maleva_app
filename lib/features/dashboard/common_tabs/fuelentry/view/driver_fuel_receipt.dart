import '../models/fuelentry_model.dart';

/// Receipt photo rules for the driver's Fuel tab (fuel data plan part B, owner 2026-10-29: "the driver app cannot save a
/// fuel entry without a receipt photo; guide the driver"). The office web stays optional. Pure (tested).

/// The server folder and table of a fuel entry's receipt (`/api/attachments`, Java `AttachmentController.FUEL_FOLDER`).
const fuelReceiptFolder = 'FuelEntry';
const fuelReceiptTable = 'FuelEntry';

/// A photo is needed for a new fill, and for an old one that has none yet.
bool needsReceiptPhoto(FuelEntryModel? entry) => entry == null || entry.filePath.trim().isEmpty;

/// A new fill, or one made in the driver app (FStatus 1), is the driver's to change. One the office made or keyed on the
/// web is not (the server refuses it): the driver may only add its receipt photo (owner 2026-10-30, entry 6666).
bool driverCanChange(FuelEntryModel? entry) => entry == null || entry.fStatus == 1;

/// The driver's other fills on the same day ([day] as the form shows it, dd/MM/yyyy), except the one being changed.
List<FuelEntryModel> sameDayFills(List<FuelEntryModel> mine, String day, {int excludeId = 0}) => [
      for (final e in mine)
        if (e.entryDate == day && e.id != excludeId) e
    ];

/// The fuel tab's words in English or Bahasa Malaysia (the driver's choice from the Today tab).
class FuelText {
  const FuelText(this.malay);

  final bool malay;

  String get photoTitle => malay ? 'Gambar resit (wajib)' : 'Receipt photo (needed)';
  List<String> get photoSteps => malay
      ? const [
          'Ambil resit pam selepas isi minyak.',
          'Letak resit rata, di tempat terang.',
          'Liter, RM dan tarikh mesti jelas dalam gambar.',
          'Tekan AMBIL GAMBAR.',
        ]
      : const [
          'Take the pump receipt after you fill.',
          'Put the receipt flat, in good light.',
          'The litres, RM and date must be easy to read.',
          'Tap TAKE PHOTO.',
        ];
  String get takePhoto => malay ? 'AMBIL GAMBAR' : 'TAKE PHOTO';
  String get retake => malay ? 'Ambil semula' : 'Take again';
  String get fromGallery => malay ? 'Pilih dari galeri' : 'Choose from gallery';
  String get photoReady => malay ? 'Gambar resit sedia' : 'Receipt photo ready';
  String get photoOnFile => malay
      ? 'Resit sudah ada. Ambil gambar baru hanya jika perlu.'
      : 'Receipt already sent. Take a new one only if needed.';
  String get officeEntry => malay
      ? 'Rekod ini dibuat oleh pejabat. Anda hanya boleh hantar gambar resit. Untuk ubah liter atau jumlah, hubungi pejabat.'
      : 'The office made this entry. You can only send its receipt photo. To change litres or amount, call the office.';
  String get sendPhoto => malay ? 'HANTAR GAMBAR' : 'SEND PHOTO';
  String get photoMissing => malay ? 'Ambil gambar resit dahulu' : 'Take a photo of the receipt first';
  String get saving => malay ? 'Menyimpan…' : 'Saving…';
  String get sendingPhoto => malay ? 'Menghantar gambar…' : 'Sending the photo…';
  String get photoFailed => malay
      ? 'Minyak sudah disimpan, tetapi gambar tidak dihantar. Tekan CUBA LAGI.'
      : 'Fuel is saved, but the photo was not sent. Tap TRY AGAIN.';
  String get tryAgain => malay ? 'CUBA LAGI' : 'TRY AGAIN';
  String get noPhotoBadge => malay ? 'Tiada resit' : 'No receipt';
  String sameDayTitle(int n) => malay ? 'Isi kali kedua hari ini?' : 'Second fill today?';
  String sameDayBody(List<FuelEntryModel> others) {
    final list = others.map((e) => '${e.entryNo} ${_l(e.aLiter)} L').join(', ');
    return malay
        ? 'Anda sudah simpan minyak pada hari ini: $list. Simpan hanya jika ini isi yang lain (resit lain).'
        : 'You already saved fuel on this day: $list. Save only if this is another fill (another receipt).';
  }

  String get saveAnyway => malay ? 'Ya, isi lain' : 'Yes, another fill';
  String get cancel => malay ? 'Batal' : 'Cancel';

  static String _l(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}
