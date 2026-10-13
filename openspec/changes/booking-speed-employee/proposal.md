# Proposal

## Why

The backend change `booking-speed-employee` credits a booking to the sale order's employee (EmployeeMaster) and groups
bookings without one as "No employee on the sale order", never ranked. The web page was redesigned (podium, bars,
notice, job filters); the owner (2026-10-12) asked for the same design in the app.

## What Changes

- App Booking speed page, same Java answer as the web:
  - a podium for the three fastest employees (gold / silver / bronze, initials, median to sale order and to job-number
    reply, a bar against the slowest ranked);
  - the other ranked employees and the ones with too few bookings as rows with the same bar;
  - an amber notice for bookings whose sale order names no employee;
  - the jobs list with status chips (All / Counted / Existing job / No sale order, with counts) and a search on job
    number, employee and mailbox.
- No backend change.
