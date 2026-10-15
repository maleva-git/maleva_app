## Decisions

- `ForwardingRequestTicks.fromRequest` already carries every saved value; the edit page only stops showing
  the later steps, so `toJava()` sends them back as they were. No model change.
- The "release number" blocker stays in the model: a row saved as Released always has its number (the server
  requires it), so it cannot block a pass-through save.
- The `employeeApi` parameter of `ForwardingRequestEditPage` is removed with the seal pickers; nothing else
  passed it.

## Risks

- The team can no longer tick Submitted / Approved / Released in the app; rows reach those statuses only if
  another client sets them. Accepted by the owner.
