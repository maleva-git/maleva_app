## Context

The React RTI page and the Java API have the same rule (`RtiJobInfo.java`, React `features/rti/utils/rtiJobInfo.ts`). The server is the authority for job lines, because it stamps them on save. The app only previews them for lines not yet saved.

## Decisions

- **`RtiJobInfo` (models/rti_job_info.dart)**: the rule as pure functions, the same as the web, and tested. Also holds the vessel choices and the quantity of a picked vessel.
- **Saved values first**: `RtiMapper.fromDetail` reads `vesselName` / `jobQuantity` from the detail and uses the sale-order preview only when they are empty. This covers RTIs saved before the columns existed.
- **Revise**: the server already returns fresh values in the revise lines, so there is no extra call.
- **Planning push**: the rows show at once. The bloc then reads the sale orders and sets only these two fields, so edits made meanwhile stay. A failure leaves the fields empty; the server still stores them on save.
- **Save payload**: stops send `vesselName` (max 200) and `jobQuantity` (max 210), with empty sent as null. Details are unchanged.
- **One-click Planning create** (`rti_from_planning_service.dart`) saves without a screen, so it is unchanged; the server stamps the lines.

## Risks

- The sale-order preview uses the device clock for "now"; the stored value uses the server's save time. The two can differ only for job type 11 near the halfway point between the two ETAs.
