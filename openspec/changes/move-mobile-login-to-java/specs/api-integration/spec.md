# Spec Delta

## ADDED Requirements

### Requirement: Authenticate Java backend requests with the session token

Requests to the Java backend host SHALL carry the session token as a bearer authorization header. Requests to the legacy .NET host SHALL NOT carry it, and their existing headers SHALL be unchanged.

#### Scenario: Java request
- **WHEN** the client calls a Java endpoint other than sign-in while a session token is stored
- **THEN** the request has an Authorization header with that bearer token.

#### Scenario: Legacy request
- **WHEN** the client calls a .NET endpoint
- **THEN** the session token is not sent, and the existing Tokenkey-based headers behave as before.

#### Scenario: Expired access token
- **WHEN** a Java request returns HTTP status 401
- **THEN** the client refreshes the session once and retries that request once; if the refresh is refused, it ends the session and opens the login page.

### Requirement: Verify the Java host certificate

Requests to the Java backend host SHALL require a valid TLS certificate; the legacy .NET host keeps its current certificate behavior.

#### Scenario: Invalid Java certificate
- **WHEN** the Java host presents a certificate that does not validate
- **THEN** the request fails, and no credentials or token are sent.
