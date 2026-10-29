## ADDED Requirements

### Requirement: The RTI preview shows each stop's time on site
The RTI preview SHALL list the RTI's pickups and deliveries from `GET /api/site-visits` with arrival, departure and
minutes, or the reason there is no time. For a driver it SHALL offer "Start loading" (pickup) or "Start unloading"
(delivery) on a stop with no saved start that the truck has not left, sending `PUT /api/site-visits/work-start`.

#### Scenario: Driver starts unloading
- **WHEN** a driver opens their RTI at the customer and taps "Start unloading"
- **THEN** the app shows "Start time saved" and the stop shows "Started 10:02"
