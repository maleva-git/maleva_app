## ADDED Requirements

### Requirement: The sales form suggests vessels and keeps free typing

The transaction sales form's Load Vessel Name and Off Vessel Name fields SHALL accept any typed
text and save it unchanged as `loadingvesselname` / `offvesselname`. From 2 typed characters they
SHALL show suggestions for that leg and its port (loading: L port, off: O port), with PTP calls
(voyage, arrival, departure, SCN, estimated mark) when the backend returns them. A failed or slow
suggestion request SHALL leave the field working as a plain text field.

#### Scenario: Typed and saved without picking
- **WHEN** a user types "CMA CGM PETRON" as off vessel and saves
- **THEN** the save body carries `offvesselname` "CMA CGM PETRON" and is otherwise identical to today's

#### Scenario: No network for suggestions
- **WHEN** the suggest request fails
- **THEN** no suggestions show and the typed text is kept

### Requirement: Picking a PTP call fills that leg's dates

Picking a PTP call SHALL set that leg's vessel name, ETA and ETD (ticking their date boxes) and SCN
(loading: L ETA, L ETD, L SCN; off: O ETA, O ETD, O SCN). It SHALL NOT change ETB, the other leg or
any other field. When the leg already has a different ETA, ETD or SCN, the form SHALL ask before
replacing them.

#### Scenario: Off leg filled
- **WHEN** the off leg is empty and the user picks MAERSK RIO NEGRO 641S
- **THEN** O ETA is 10 Oct 06:30 with its box ticked, O ETD is 11 Oct 17:00 with its box ticked, and O SCN is 269EK6

#### Scenario: Dates already typed
- **WHEN** O ETA is already 10 Oct 09:00
- **THEN** the form asks before replacing, and keeps 10 Oct 09:00 if the user says no

### Requirement: The sales form asks once about a close spelling

When the user leaves a vessel field, the form SHALL ask the backend for a similar vessel. A same
vessel SHALL replace the text with the master's spelling silently; a close one SHALL show one
prompt with "Use <name>" and "Keep my spelling". Saving SHALL never be blocked.

#### Scenario: Keep my spelling
- **WHEN** the backend answers CLOSE with CMA CGM PETRA for "CMA CGM PETRON" and the user keeps their spelling
- **THEN** the field keeps "CMA CGM PETRON" and the prompt does not appear again for that text

### Requirement: The sales form warns when a typed ETA differs from PTP

The user SHALL be able to type any ETA or ETD on a leg linked to a PTP call. When they save and a
typed (ticked) ETA or ETD is an hour or more away from the linked call's time (the call picked on this
visit, else the one read from `GET /api/sale-orders/{id}/vessel-links` when the order opened), the
form SHALL ask once "PTP's schedule shows another time", listing each time next to PTP's, with
"Use PTP's times" and "Keep my times"; either answer continues the save. It SHALL NOT ask for an
empty time, a hidden vessel section, a renamed vessel, or a loaded order whose ETA and ETD did not
change since it was opened or answered.

#### Scenario: ETA typed two days later
- **WHEN** the off leg is linked to FM NAMTHONG EXCELLENCE 2653 (PTP 14 Oct 15:00) and the user enters O ETA 16 Oct 10:00 and saves
- **THEN** the form asks first; "Use PTP's times" saves O ETA 14 Oct 15:00, "Keep my times" saves 16 Oct 10:00

### Requirement: The sales form checks pickup and delivery against the ETA

For any port and vessel, when the user saves, the form SHALL compare pickup and delivery with the day
before the ETA (the loading ETA when its section shows and is ticked, else the off ETA) and, when a
date is on another day or empty, ask once with "Change to <day>" and "Keep my dates" ("Leave empty"
when both are empty). "Change" SHALL tick and set those dates to that day, keeping the time of day
(00:00 for an empty date); "Keep" SHALL save them as they are, empty included. It SHALL NOT ask when
both vessel sections are hidden (general cargo), without an ETA, or for a loaded order whose dates
did not change. It is asked after the PTP warning, with the ETA chosen there.

#### Scenario: Pickup four days early
- **WHEN** O ETA is 15 Oct 15:00 and pickup is 11 Oct 09:00 and the user saves
- **THEN** the form asks "Is the pickup date correct?"; "Change to 14 Oct" saves pickup 14 Oct 09:00

### Requirement: The sales form links the vessels after a successful save

After the order saves, the form SHALL send both legs' names and any picked vessel and call ids to
`PUT /api/sale-orders/{id}/vessel-links`, using the saved order's id from the save answer. A failed
link request SHALL NOT change the "Created Successfully" / "Updated Successfully" message.

#### Scenario: Link fails
- **WHEN** the save succeeds and the link request fails
- **THEN** the user sees "Created Successfully" and the order is saved
