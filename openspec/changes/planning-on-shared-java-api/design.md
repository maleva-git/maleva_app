# Design

| Screen call (.NET) | Now (shared Java) |
|---|---|
| PLANING/MaxPLANINGNo | POST /api/planing/max-planning-no/{c} → `{sequenceNumber}` |
| PlanningApp/SelectPLANING | POST /api/planing/select-planning `{comid, employeeid, search, fromdate, todate}` |
| PlanningApp/EditPLANING | GET /api/planing/edit?id&companyId |
| PlanningApp/PLANINGSearch | POST /api/planing/search (rows: `Id` is the sale order) |
| PlanningApp/InsertPLANING | POST /api/planing/save, header Comid, `[PlanningRequest]` → `[{ok, message, name, id}]` |
| PLANING/DeletePLANING | DELETE /api/planing/{id}?companyId |
| PlanningApp/PLANINGVIEW | GET /api/planning/reports/{id}/pdf-ticket → `Data1.Url` (public, 3 minutes) |
| VESSELPLANING/MaxVESSELPLANINGNo | POST /api/vessel-plannings/max-vessel-planning-no/{c} |
| VesselPlanningApp/SelectVESSELPLANING | POST /api/vessel-plannings/select-vessel-planning |
| VesselPlanningApp/EditVESSELPLANING | GET /api/vessel-plannings/edit?id&companyId |
| VesselPlanningApp/VESSELPLANINGSearch | POST /api/vessel-plannings/search (`etaType` 1 OETA, 2 ETA, 0 either) |
| VesselPlanningApp/InsertVESSELPLANING | POST /api/vessel-plannings/save, header Comid; rows keep only the job |
| VesselPlanningApp/DeleteVESSELPLANING | DELETE /api/vessel-plannings/{id}?companyId |
| VesselPlanningApp/VESSELPLANINGVIEW | GET /api/vessel-plannings/{id}/report-ticket |
| SaleOrder/UpdateSaleorder (job update sheet) | POST /api/vessel-plannings/sale-order-update |

## Notes

- The reports are keyed by plan id (.NET took the plan number) and open by the public ticket link.
- The planning list model reads the Java select row (`PickupDateD`, `DeliveryDateD`, `OriginD`,
  `DestinationD`); a saved plan opened in the page is read with the edit (`SaleDetails`).
- The vessel update sheet no longer edits the general boarding officers (`BoardingOfficerRefid`,
  `BoardingOfficer1Refid`): the web's window and the Java update write the loading and off-vessel
  officers, and their amounts (50, 30 each, 20 each).
- The .NET save, delete and update reported "Success" on any failure; a refusal now shows the
  server's message.

## Known gaps (not changed)

- Vessel Planning has no screen-access check in Java (owner: when VESSEL_PLANNING rights are set up).
- The employee pickers on these screens still use the .NET employee list (employee move).
- The planning edit answers the time/quantity lists of the sale order, not of the saved plan row.
