/// The Today tab's words in English or Bahasa Malaysia (owner 2026-10-28). The driver's choice is kept on the phone.
/// Place names, job numbers and stop types (SEAL, K2 Clearance) are shown as the office typed them.
class TripText {
  const TripText(this.malay);

  final bool malay;

  String get yesterday => malay ? 'Semalam' : 'Yesterday';
  String get today => malay ? 'Hari ini' : 'Today';
  String get tomorrow => malay ? 'Esok' : 'Tomorrow';
  String trips(int n) => malay ? '$n perjalanan' : '$n trip${n == 1 ? '' : 's'}';
  String tripOf(int i, int n) => malay ? 'Perjalanan $i / $n' : 'Trip $i of $n';
  String get trip => malay ? 'Perjalanan' : 'Trip';
  String get pickUp => malay ? 'Ambil' : 'Pick up';
  String get deliver => malay ? 'Hantar' : 'Deliver';
  String get forwarding => malay ? 'Forwarding' : 'Forwarding';
  String get pickUpTitle => malay ? 'AMBIL' : 'PICK UP';
  String get deliverTitle => malay ? 'HANTAR' : 'DELIVER';
  String get forwardingTitle => malay ? 'HENTIAN FORWARDING' : 'FORWARDING STOPS';
  String places(int n) => malay ? '$n tempat' : '$n place${n == 1 ? '' : 's'}';
  String stops(int n) => malay ? '$n hentian' : '$n stop${n == 1 ? '' : 's'}';
  String jobsAtPlaces(int jobs, int places) => malay
      ? '$jobs kerja di $places tempat'
      : '$jobs job${jobs == 1 ? '' : 's'} at $places place${places == 1 ? '' : 's'}';
  String jobsList(int n, String list) => malay ? '$n kerja: $list' : '$n job${n == 1 ? '' : 's'}: $list';
  String get noPlace => malay ? '(tiada tempat)' : '(no place typed)';
  String get qty => malay ? 'Kuantiti' : 'Qty';
  String get vessel => malay ? 'Kapal' : 'Vessel';
  String get agent => malay ? 'Ejen' : 'Agent';
  String get pic => 'PIC';
  String get photos => malay ? 'Gambar / status' : 'Photos / status';
  String get rtiPdf => 'RTI PDF';
  String get timeOnSite => malay ? 'Masa di tapak' : 'Time on site';
  String get hideTimes => malay ? 'Sembunyi masa' : 'Hide times';
  String get whichJob => malay ? 'Kerja mana?' : 'Which job?';
  String get noTripDay => malay ? 'Tiada perjalanan pada hari ini.' : 'No trip on this day.';
  String get noTripTomorrow => malay
      ? 'Belum ada perjalanan esok. Anda akan dapat notis bila pejabat membuatnya.'
      : 'No trip for tomorrow yet. You get a notice when the office makes it.';
  String get loadFailed => malay ? 'Tidak dapat muat perjalanan. Tarik ke bawah untuk cuba lagi.' : 'Could not load your trips. Pull down to try again.';
  String offline(String at) => malay ? 'Tiada talian — perjalanan yang disimpan pada $at' : 'No signal — trips saved at $at';
  String get next => malay ? 'SETERUSNYA' : 'NEXT';
  String get allDone => malay ? 'Semua hentian hari ini sudah lepas.' : 'All of today\'s stops are behind you.';
  String get changedByOffice => malay ? 'Diubah oleh pejabat' : 'Changed by the office';
  String get newTrip => malay ? 'Perjalanan baru — sila semak' : 'New trip — please check';
  String get gotIt => malay ? 'Faham' : 'Got it';
  String get gotItSaved => malay ? 'Terima kasih — pejabat nampak anda sudah semak' : 'Thank you — the office sees you checked it';
  String get cannotOpen => malay ? 'Tidak dapat dibuka di telefon ini' : 'Could not open it on this phone';
  String get languageButton => malay ? 'EN' : 'BM';
}
