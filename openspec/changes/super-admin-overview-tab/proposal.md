# Proposal

## Why

The Super Admin opens the admin dashboard on 33 tabs and has to visit SO, JO, Mailbox Monitor, IR Report,
Vessel Planning, Truck Planning and Truck Location one by one to see how the day stands. The owner asked
(2026-10-11) for one first tab that shows the overall numbers of these areas together, with a button to
open each one, in a cleaner card design (reference: logistics dashboard mock-ups) but in the app's
existing colours.

## What Changes

- The admin dashboard gets a new first tab **Overview**, for the Super Admin (role 100) only, like the
  Mailbox Monitor tab. Admin (role 200) keeps today's tabs. Tab count 33 to 34 for the Super Admin.
- The Overview tab shows:
  - **Quick-open buttons**: SO, JO, Mailbox Monitor, IR Report (switch to their tab in the same dashboard)
    and Vessel Planning, Truck Planning, Truck Location (open their screen as the side menu does, shown
    only when the user's menu has that entry, with the menu's permissions).
  - **Number cards**: sale orders (today and this month), job orders (open, by status), unread mail
    (total and overdue), open incident reports (last 30 days and their amount).
  - **Section cards**: Mailbox Monitor (mailboxes needing attention), Incident reports (latest open),
    Truck Planning (today's jobs), Vessel Planning (jobs in the next 7 days), Truck Location (this week:
    trucks with today's location filled, in workshop).
- Each card loads on its own: one area failing shows a retry on that card only.
- Phone: one column. Tablet: number cards four across, buttons in one row, sections in two columns.
- No API, backend or database change. Every number comes from a shared Java endpoint the app already
  calls (`/api/dashboard/sales`, `/api/job-orders/list`, `/api/mail-monitor/mailboxes`, `/api/ir` search,
  `/api/planing/search`, `/api/dashboard/vessel-planning`, the truck-location week).

## Capabilities

### New Capabilities

- `admin-overview`: the Super Admin's Overview tab on the admin dashboard - what it shows, where its
  buttons go, who sees it.

### Modified Capabilities

None.

## Impact

`features/dashboard/admin_dashboard/` (dashboard, UI, new `overview/` folder with cubit, repository,
widgets), tests under `test/features/dashboard/admin_dashboard/`. Shared Java API only, no mobile-only
endpoint, no new package.
