## ADDED Requirements

### Requirement: Unread mail in the app

The app SHALL open the "My unread mail" screen, listing each linked mailbox with its count, when its push notice is
tapped, and SHALL NOT add a bar or card to the dashboards.

#### Scenario: Screen
- **WHEN** an employee linked to cs1@ (3 unread) opens "My unread mail"
- **THEN** it shows 3 unread and cs1@ with 3

#### Scenario: Tap the notice
- **WHEN** the employee taps "You have 3 unread emails"
- **THEN** the app opens "My unread mail"
