# Proposal

## Why

The owner asked (2026-10-15) for the app's Overview tab (Super Admin, role 100) to look and work like the
web Super Admin dashboard (`maleva-front-end/src/features/dashboard/superadmin/pages/SuperAdminDashboard.tsx`),
in a better design.

## What Changes

- **Quick Access** chips as on the web command bar (wrap on a phone, none hidden).
- **Report card** (web report centre): Sale Order / Invoice switch; Today, Yesterday, This Week, This Month
  count and amount; monthly breakdown with a bar per month (6 shown, Show all).
- **Pickup queue** (web left panel): Today / Tomorrow switch, numbered rows (job, customer, packages),
  expired rows red. Replaces the "Truck planning today" count.
- **Vessel planning** (web right panel): Today (board from 2025-02-01 to today, as the web) / Tomorrow,
  `total · expired · action` line, expired first then needing action (the web pop flags), vessel pill.
  Replaces the "next 7 days" count.
- Long lists show 8 rows and Show all.
- Layout: width >= 1000 the web's three columns (pickups | report | vessels); tablet the report on top and
  the two lists side by side; phone one column. Mailbox, Incident and Truck location cards stay.
- No API, backend or database change: the same shared Java endpoints the web uses
  (`/api/dashboard/sales` type 1 and 0, `/api/planing/search`, `/api/dashboard/vessel-planning`).

## Update 2026-10-16

The owner asked to leave the web's two side panels (Today's pickup and Vessel planning) off the app
Overview tab. They are removed with their data loading (`pickups`, `vesselPlanning`, `PickupJob`,
`VesselJob`). The tab is now header, Quick Access (still opens Vessel Planning and Truck Planning), the
report card, then the Mailbox, Incident and Truck location cards. The Overview no longer calls
`/api/planing/search` or `/api/dashboard/vessel-planning`.

## Update 2026-10-16 (design)

Owner asked for a better-looking Overview. Same data and endpoints; design only:
- Header: greeting, soft background circles, glass number tiles with icons; each number opens its tab.
- Quick Access: coloured icon tiles (4 per row on a phone, one row on a tablet).
- Section headings (Quick access, Sales report, Operations).
- Report card: period tiles with icons; the months as a bar chart (fl_chart, already a dependency) with
  tap-for-details, plus Best month, Avg / month and Total.
- Mailbox (teal), Incidents (rose) and Truck location (green) as coloured panels: letter avatars, date
  blocks, and a split bar for filled / not filled / workshop.
