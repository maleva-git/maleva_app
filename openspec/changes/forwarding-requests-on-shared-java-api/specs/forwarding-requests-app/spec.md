# Spec Delta

## Purpose
Forwarding requests in the app: Customer Service asks for customs forms on a sale order and follows them; the forwarding team works the steps on the shared Java API.

## ADDED Requirements

### Requirement: Request FW from the sale order
The app SHALL offer "REQ FW" on a saved sale order (edit id > 0). The sheet SHALL require at least one form type and an estimated date-time, SHALL list the job's existing requests with status, SHALL warn (not block) when a chosen type is already open, and SHALL create one request per chosen type with one call to `POST /api/forwarding-requests`.

#### Scenario: K1 and K8 requested
- **WHEN** CS opens job MY002605939, taps REQ FW, chooses K1 and K8, keeps tomorrow 09:00 and taps Request
- **THEN** the body sent is `{saleOrderId, formTypes: [K1, K8], estimatedDate: 'yyyy-MM-dd 09:00:00', remarks: null}` and the sheet closes with "2 forwarding requests created"

#### Scenario: Unsaved job
- **WHEN** the sale order is new (edit id 0)
- **THEN** REQ FW is disabled

### Requirement: The forwarding team works the list
The app SHALL list the company's requests from `POST /api/forwarding-requests/search` (default the coming week), one card per request with the six-step ladder and status, coral when the estimate has passed without a draft, filterable by dates, form types, statuses and job number. Tapping a card SHALL open an edit page where the five ticks and their references and the seal and break-seal employees are edited locally and sent together by Save (`PUT …/{id}/ticks`); the client SHALL apply the ladder (ticking a step ticks those below, unticking a step unticks those above) and SHALL refuse Save without a C Number for a draft or a release number for a release; a server refusal SHALL be shown as its message.

#### Scenario: Draft with C Number
- **WHEN** the team ticks Draft created, types J33D10003057 and taps Save
- **THEN** the body carries documentReceived true, draftCreated true, cNumber J33D10003057, and the list shows the row as Draft created

#### Scenario: Released without a number
- **WHEN** the team ticks Released and leaves the release number blank
- **THEN** Save shows "Enter the release number to save Released" and sends nothing

### Requirement: My Forwarding Requests
The app SHALL show the CS employee's own requests (`mine: true`, a month back and ahead) read-only, with who did each step and when, from the Sales dashboard tab, the drawer and the notices.

#### Scenario: Progress
- **WHEN** Naga opens My Forwarding Requests and taps the K8 for MY002605939
- **THEN** the detail shows Draft created by Vasuntra with the C Number, and the later steps as "Not yet"

### Requirement: Entry points and notices
The app SHALL add "FW Requests" to the Forwarding Agent and Air Freight dashboards, "MY FW REQ" to the Sales dashboard, drawer cases "Forwarding Requests" and "My Forwarding Requests", and SHALL open the planning list for a `FORWARDING_REQUESTED` / `FORWARDING_OVERDUE` / `FORWARDING_CANCELLED` notice and My Forwarding Requests for the other `FORWARDING_*` notices, from a tap while open, in the background, or on a cold start. Assumption awaiting confirmation: which dashboard the owner's forwarding team uses.

#### Scenario: Tap "Your K8 … is drafted"
- **WHEN** the notice `type=FORWARDING_DRAFTED, link=/forwarding/my-requests` is tapped
- **THEN** the app opens My Forwarding Requests
