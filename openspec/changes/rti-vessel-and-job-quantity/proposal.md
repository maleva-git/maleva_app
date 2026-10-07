## Why

The owner wants each RTI job line and route activity to show the job's vessel name and job quantity, like the React RTI page (2026-10-07). The shared Java API now returns and stores them (`maleva-backend` change `store-rti-line-vessel-quantity`):
- `RTIDetailsDto.vesselName` / `jobQuantity`: set by the server on save;
- `RTIRouteActivitiesDto.vesselName` / `jobQuantity`: chosen on the RTI page.

The app does not show or save them yet. The .NET RTI had neither field; this is a new rule from the owner, not a port.

## What Changes

- Job lines (phone card and tablet grid) show the Vessel Name and Job Qty, both read only.
  - A saved line shows the stored values.
  - A line looked up but not yet saved previews them from its sale order, using the server's rule:
    - job type 11: the vessel whose ETA is nearest now;
    - other job types: the loading vessel, else the off-loading vessel;
    - quantity: `Quantity / TotalWeight`.
  - Planning's Push RTI reads each line's sale order for them after the rows show.
- Route activities (phone card and tablet grid) get two fields:
  - Vessel Name: pick one of the job lines' vessels or type one;
  - Job Qty: filled with the quantities of the lines with that vessel, and editable.
  - When the RTI has one vessel, a new stop starts with it.
- The save sends the stop's `vesselName` / `jobQuantity`. Job-line details do not send them: the server sets them.
- No backend change for the app: it reads the Java fields as they are.
