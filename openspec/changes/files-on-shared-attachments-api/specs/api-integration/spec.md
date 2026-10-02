## ADDED Requirements

### Requirement: Record files on the shared attachments API

The app SHALL upload, list and delete record photos and files through the shared Java
`/api/attachments` with the session token, in the same `Upload/` folders as before.

#### Scenario: Boarding photo
- **WHEN** a boarding photo is taken for job 40
- **THEN** it is stored as `Upload/<company>/SalesOrder/40/Boarding/<phone file name>` and listed with the job's photos.

#### Scenario: Refused delete
- **WHEN** the server refuses a delete
- **THEN** the screen shows the error and keeps the photo.
