## ADDED Requirements

### Requirement: Google reviews on the shared API

The Google Review tab and the TransportDB review form SHALL list, save and delete reviews through
the shared Java `/api/google-reviews` with the session token.

#### Scenario: Save a review
- **WHEN** a review is saved for a staff member
- **THEN** the app posts `{refDate, employeeRefId, googleReview, googleMsg, shopName, mobileNo}` and shows success
