# Spec Delta

## MODIFIED Requirements

### Requirement: The forwarding team works the list
The app SHALL list the company's requests from `POST /api/forwarding-requests/search` (default the coming week), one card per request with the six-step ladder and status, coral when the estimate has passed without a draft, filterable by dates, form types, statuses and job number. Tapping a card SHALL open an edit page where only Documents received, Draft created and the C Number are edited locally and sent by Save (`PUT …/{id}/ticks`); Submitted, Approved, Released, their references and the seal and break-seal employees SHALL NOT be shown, and Save SHALL send their saved values unchanged. The client SHALL apply the ladder (ticking a step ticks those below, unticking a step unticks those above) and SHALL refuse Save without a C Number for a draft; a server refusal SHALL be shown as its message.

#### Scenario: Draft with C Number
- **WHEN** the team ticks Draft created, types J33D10003057 and taps Save
- **THEN** the body carries documentReceived true, draftCreated true, cNumber J33D10003057, and the list shows the row as Draft created

#### Scenario: Older released row
- **WHEN** the team opens a row already Released with release number K8-1 and seal by employee 31, changes the C Number and taps Save
- **THEN** the body still carries submitted, approved and released true, releaseNo K8-1 and sealByRefId 31, and the status chip shows Released

#### Scenario: Unticking Draft
- **WHEN** the team unticks Draft created on that row and taps Save
- **THEN** submitted, approved and released are sent false with their references blank, and the seal ids are sent unchanged

### Requirement: My Forwarding Requests
The app SHALL show the CS employee's own requests (`mine: true`, a month back and ahead) read-only, with who received the documents and created the draft and when, and the C Number, from the Sales dashboard tab, the drawer and the notices. Submitted, Approved, Released, their references and the seal people SHALL NOT be shown.

#### Scenario: Progress
- **WHEN** Naga opens My Forwarding Requests and taps the K8 for MY002605939
- **THEN** the detail shows Draft created by Vasuntra with the C Number, and no Submitted, Approved, Released or seal rows
