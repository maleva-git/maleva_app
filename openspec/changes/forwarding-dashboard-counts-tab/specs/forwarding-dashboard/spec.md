## ADDED Requirements

### Requirement: The Forwarding dashboard shows the forwarding counters
The app's Forwarding dashboard SHALL show, on tablet and phone, the forwarding counters the web Forwarding dashboard shows: the period block (today, yesterday, week, month, fixed windows) and the K1/K2/K3/K8 block for a chosen date range, read from the shared Java `GET /api/dashboard/forwarding/{comId}`, beside the existing unreleased K-1,2,3 and K8 tabs.

#### Scenario: Forwarding user opens the dashboard on a phone
- **WHEN** a forwarding user opens the Forwarding dashboard on a phone
- **THEN** the first tab, FW Report, lists the period counters, the date pickers and the K-type breakdown in one column, with the same numbers as the web dashboard for the same dates

#### Scenario: Tablet
- **WHEN** the same dashboard is opened on a tablet
- **THEN** the FW Report tab shows the counters and date pickers on the left and the K-type breakdown on the right
