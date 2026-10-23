# Design

- The form keeps the look of the old sheet (date fields, duration box, type, reason, submit) and adds a
  Whole days / Hours switch.
- `LeaveForm` is an immutable value with `from` / `to` / `error`; the widget only shows it.
