# Design

The plan's requirements (save, order, conflict) are specified in the backend change
`plan-save-keeps-changes`; this client change only carries the version and shows the question, so it
has no spec delta (`skip_specs`). Reload uses the existing "same plan reloaded keeps edited rows" path.
