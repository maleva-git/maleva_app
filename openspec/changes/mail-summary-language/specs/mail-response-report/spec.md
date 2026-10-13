## ADDED Requirements

### Requirement: Summary language
The AI card SHALL let the user pick English, Tamil, Bahasa Melayu, Chinese, Spanish or Hindi, SHALL ask the
server for the summary in the picked language, and SHALL read it aloud with the device voice of that language,
saying how to add the voice when the device has none.

#### Scenario: Tamil
- **WHEN** the user picks Tamil and taps Write summary, then Read aloud
- **THEN** the summary is requested with language ta and spoken with the ta-IN voice

#### Scenario: Change language with a summary shown
- **WHEN** a summary is shown and the user picks Hindi
- **THEN** the summary is written again in Hindi

#### Scenario: No voice on the device
- **WHEN** the device has no Tamil voice and the user taps Read aloud
- **THEN** the card says the device has no Tamil voice and to add it in the phone's text-to-speech settings
