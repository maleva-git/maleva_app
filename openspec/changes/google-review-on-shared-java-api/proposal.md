# Proposal

## Why

The Google Review tab and the TransportDB review form called .NET `EmployeeApp`
(`Select/Insert/DeleteGoogleReview`). Backend change `share-google-review-api` ports them to
`/api/google-reviews`.

## What Changes

- **New** `GoogleReviewApi` (`lib/core/employee`), registered in DI, with `list`, `save` and
  `delete`.
- `Review.fromJava` reads the Java fields (`id`, `refDate`, `employeeRefId`, `employeeName`,
  `googleReview`, `googleMsg`, `shopName`, `mobileNo`). The .NET `fromJson` is removed.
- The save sends the review count as a number, not as text.
- **Removed**: the three Google Review `ApiConstants`.

## Behaviour changes

- A refused save shows the server's reason, for example "Select the staff" or a value that is too
  long.
- The list includes reviews later on the to-date.

## Capabilities

### Modified Capabilities
- `api-integration`: staff Google reviews use the shared Java API.

## Impact

`lib/core/employee/google_review_api.dart`, `lib/core/models/shared/review.dart`, the `googlereview`
repository and bloc, the TransportDB repository and bloc, `api_constants.dart` and
`auth_injection.dart`. Ships with backend change `share-google-review-api`.
