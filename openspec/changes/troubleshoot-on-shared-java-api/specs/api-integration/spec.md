## ADDED Requirements

### Requirement: Troubleshoot logs on the shared upload

Report a Problem SHALL upload its log with `/api/attachments` to the signed-in user's Troubleshoot
folder. A crash before sign-in SHALL be kept on the phone and uploaded once a session exists. The app
SHALL NOT call .NET `CommonApp/UploadFile2`.

#### Scenario: Report a Problem
- **WHEN** a signed-in user sends Report a Problem
- **THEN** the log is posted to `/api/attachments` with folder Troubleshoot and their id as the record

#### Scenario: Crash before sign-in
- **WHEN** the app crashes during start-up and a user signs in later
- **THEN** the kept crash log is uploaded to that user's Troubleshoot folder and removed from the phone
