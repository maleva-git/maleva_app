## Why

Staff type vessel names and dates by hand on the app's sale order screen too, and nobody is told
when PTP moves a vessel. Backend change `maleva-backend/openspec/changes/vessel-master-and-ptp-schedule`
adds a self-filling vessel master, PTP's schedule, a list of jobs whose dates differ from PTP, and a
phone notice (`type=VESSEL_ETA_CHANGED`) when PTP moves a vessel. The owner wants that notice on the
app (2026-10-10). React does the same in its own change of the same name.

## What Changes

- **Sale order add screen** (`features/transaction/salesorder/add`, existing capability
  `sales-enquiries`): the Load Vessel Name and Off Vessel Name fields (`txt_loadingvessel`,
  `txt_offvessel`) show suggestions from `GET /api/vessel-masters/suggest` while typing. Typing
  freely still saves as today. Picking a PTP call fills that leg's ETA and ETD (ticking their date
  boxes) and SCN; typed values are only replaced after the user agrees. On leaving the field, a
  close spelling gets one "Did you mean" prompt. After a successful save, the app sends
  `PUT /api/sale-orders/{id}/vessel-links`; its failure never turns the save into an error.
- **New "Vessel changes" screen** (new capability `vessel-changes`): `GET /api/vessel-changes`
  grouped by vessel call, Maleva's and PTP's times side by side, "Update these jobs" through the
  existing `POST /api/vessel-plannings/sale-order-update-many`, "Dismiss", SCN copy.
- **Pickup and delivery do not follow the ETA** (owner, 2026-10-13): the earlier "Also move pickup
  and delivery" option on Vessel changes (`POST /api/vessel-changes/move-pickup-delivery`, the
  suggested pickup/delivery and `pickupMoveReason` of the list) and the sale order save question
  "pickup and delivery the day before the ETA" (Change / Keep / Leave empty) were removed. The backend
  removed that endpoint and those fields at the same time. Updating ETA/ETD, dismiss and the PTP time
  question on save are unchanged.
- **Boarding month question**: a row whose boarding pay would move to another month is left out of
  the update until the user confirms it on that row.
- **Tapping the notice opens it** (existing capability `notifications-support`): a
  `VESSEL_ETA_CHANGED` push opens "Vessel changes" in the foreground, background and cold-start
  cases, like the unread mail and forwarding request notices do today.

Not changed: planning, RTI and boarding screens; the save body (`sale_order_save_body.dart`) and every other sale order field; other
screens that type vessel names (enquiry, vessel planning, prealert). The app reads the Java answers
as they are (owner's rule 2); no backend change is made for the app.

Clarification Q10 (tap destinations) is answered for this push type only: it opens "Vessel changes".
Clarification Q07 (partial success): the bulk update's per-job results are shown, so a refused job is
named.

## Capabilities

### New Capabilities
- `vessel-changes`: the app screen listing jobs whose dates differ from PTP, with apply and dismiss.

### Modified Capabilities
- `sales-enquiries`: the transaction sales form gains vessel suggestions, PTP date fill, the
  near-duplicate prompt and linking after save.
- `notifications-support`: a tapped `VESSEL_ETA_CHANGED` notice opens the vessel changes screen.

## Impact

`lib/core/vessel_master/` (models + API for suggest, similar, links), `lib/core/vessel_changes/`
(models + API), `lib/features/vessel_changes/` (cubit, screen, `push_route.dart`), the sale order add
view and bloc, `lib/features/mail_monitor/mine/push_route.dart` (route combiner),
`lib/core/router/app_router.dart` (`/vessel_changes`). Depends on the backend change. Needs the
owner's approval before applying; the owner tests on a device.
