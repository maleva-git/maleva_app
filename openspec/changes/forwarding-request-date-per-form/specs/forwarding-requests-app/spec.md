# Spec Delta

## MODIFIED Requirements

### Requirement: Request FW from the sale order
The app SHALL offer "REQ FW" on a saved sale order (edit id > 0). The sheet SHALL require at least one form type, SHALL show one estimated date-time per ticked form type (the first ticked form starting at tomorrow 09:00, a newly ticked form starting with the date of the last ticked form before it in K1, K2, K3, K8 order), SHALL keep Request disabled until every ticked form has a date, SHALL list the job's existing requests with status, SHALL warn (not block) when a chosen type is already open, and SHALL create one request per chosen type with one call to `POST /api/forwarding-requests` carrying `items`.

#### Scenario: K1 and K8 requested with their own dates
- **WHEN** CS opens job MY002605939, taps REQ FW, ticks K8 (tomorrow 09:00), sets it to 20 Oct 14:00, ticks K1 (starts at 20 Oct 14:00), changes K1 to 18 Oct 10:00 and taps Request
- **THEN** the body sent is `{saleOrderId, items: [{formType: K1, estimatedDate: '…-10-18 10:00:00'}, {formType: K8, estimatedDate: '…-10-20 14:00:00'}], remarks: null}` and the sheet closes with "2 forwarding requests created"

#### Scenario: A ticked form without a date
- **WHEN** a ticked form's date is cleared
- **THEN** Request is disabled until it has a date again

#### Scenario: Unsaved job
- **WHEN** the sale order is new (edit id 0)
- **THEN** REQ FW is disabled
