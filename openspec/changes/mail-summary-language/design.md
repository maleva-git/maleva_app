# Design

## Context

The AI card (change `mail-response-report-tab`) writes the summary on tap and reads it with `flutter_tts`
in en-US.

## Goals / Non-Goals

**Goals:** six languages for writing and reading aloud. **Non-Goals:** translating the rest of the tab;
remembering the choice across app starts.

## Decisions

- **The server writes the language** (backend change `mail-summary-language`), not the device: one AI call,
  and the web can use the same parameter. A device-side translation would need another service.
- **`SummaryLanguage` list** in the app holds the API code, the native name for the picker and the TTS voice.
- **Speaker** returns `spoken / noVoice / failed`; `noVoice` comes from `isLanguageAvailable(voice)`, so the
  user is told to install the voice rather than hearing English.
- **Changing language** clears the summary; if one was shown it is written again, so text and voice always
  match.

## Risks / Trade-offs

- [Many phones lack Tamil or Malay voices by default] → clear message pointing to text-to-speech settings.
- [Backend not deployed yet] → the server answers English; the voice then reads English text in the chosen
  voice until the backend is deployed (note for the owner).
