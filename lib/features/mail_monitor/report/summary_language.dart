/// The languages the AI summary can be written and read aloud in (change `mail-summary-language`). [code]
/// is what the shared Java summary API takes; [voice] is the device text-to-speech locale.
class SummaryLanguage {
  const SummaryLanguage(this.code, this.name, this.nativeName, this.voice);

  final String code;

  /// The English name, for messages.
  final String name;

  /// How the language names itself, for the picker.
  final String nativeName;
  final String voice;

  static const english = SummaryLanguage('en', 'English', 'English', 'en-US');

  static const all = [
    english,
    SummaryLanguage('ta', 'Tamil', 'தமிழ்', 'ta-IN'),
    SummaryLanguage('ms', 'Malay', 'Bahasa Melayu', 'ms-MY'),
    SummaryLanguage('zh', 'Chinese', '中文', 'zh-CN'),
    SummaryLanguage('es', 'Spanish', 'Español', 'es-ES'),
    SummaryLanguage('hi', 'Hindi', 'हिन्दी', 'hi-IN'),
  ];

  /// "தமிழ் · Tamil"; English shows once.
  String get label => nativeName == name ? name : '$nativeName · $name';
}
