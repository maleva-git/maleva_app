## Context

See proposal.md for why. Code-verified facts (2026-10-10):

- **Sale order add.** `salesorderadd_tab.dart` renders the vessel names with `_editField` (`txt_loadingvessel`,
  `txt_offvessel`); the bloc holds `txtLoadingVessel`, `txtOffVessel`, `txtLSCN`, `txtOSCN`,
  `txtLPort`, `txtOPort`, and the dates `dtpLETAdate`, `dtpLETDdate`, `dtpOETAdate`, `dtpOETDdate`,
  each with a `checkBoxValue...` flag that decides whether the date is sent (`sale_order_save_body.dart`).
- **Save.** `SalesorderaddBloc` calls `SaleOrderApi.save(...)` and ignores the answer; `save` returns the
  saved master as a map (Java `ApiResponse` data), which carries the order's `id`.
- **Push routing.** `main.dart` sends taps to `routeForPush(data)` / `routeForPayload(payload)` in
  `features/mail_monitor/mine/push_route.dart`, which chains the unread mail and forwarding request
  routes; cold starts go through `PendingPushRoute`. Routes are `GoRoute`s in `core/router/app_router.dart`.
- **Bulk update.** `POST /api/vessel-plannings/sale-order-update-many` answers one result per job
  (`VesselPlanningSaleOrderBulkUpdateResponse`).

Backend facts (API shapes, rules) are in the backend change's specs and design. This plan does not
depend on unconfirmed backend behaviour beyond what those specs state.

## Goals / Non-Goals

**Goals:** the save body is identical for the same typed values; free typing keeps working; the
notice opens one screen.

**Non-Goals:** the vessel master tidy-up screen and the PTP schedule page (web only); vessel fields
on enquiry, vessel planning and prealert screens.

## Decisions

- **Suggestions under the existing field**, not a new picker page: an overlay list under
  `_editField` driven by a debounced (300 ms) cubit call, so the field stays a text field. Alternative:
  a full-screen search page; rejected because it adds a step to every entry.
- **Picked ids in bloc state, not in the save body**: `pickedLoading` / `pickedOff` (vessel id, call
  id), cleared when the field text changes after a pick. The save body function is not touched.
- **Link after save in the bloc**: read `id` from `save`'s answer (or `editId` on update), then call
  `VesselMasterApi.saveLinks`; catch and log its failure so `savedMessage` stays the success text.
- **One route combiner**: `routeForPush` / `routeForPayload` gain a `vessel_changes/push_route.dart`
  check for `VESSEL_ETA_CHANGED` ahead of the forwarding fallback; `/vessel_changes` is a new `GoRoute`.
- **Models read Java fields directly** (owner's rule 2): new models in `lib/core/vessel_master/` and
  `lib/core/vessel_changes/` with `fromJava`, no `LegacyCallAdapter`.

## Risks / Trade-offs

- [Overlay hides the next field on small phones] → The list shows at most five rows and closes on
  scroll or outside tap.
- [Save answer lacks `id` on some path] → Fall back to `editId`; if both are 0, skip the link (the
  backend matcher links by name later) and log it.
- [Date boxes] → Picking ticks only the ETA and ETD boxes of that leg; an unticked ETB stays unticked.

## Migration Plan

Ships after the backend change is deployed. With the backend switches off, suggestions show master
vessels only and the vessel changes screen is empty; nothing breaks. Rollback: an app release without
the change; the backend is unaffected.
