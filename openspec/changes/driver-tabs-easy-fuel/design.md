No new API: `FuelEntryRepositoryImpl` → `FuelEntryApi` (`GET/POST /api/fuel-entries`). For a driver token the server lists
only the driver's own entries and stamps every save with the driver, the truck on the driver's record and FStatus 1, so
the form never asks for a truck or a driver. A change of an entry the office made is refused by the server ("not found"),
shown as the toast. The limits (1,000 L, RM 5,000) are typing guards only, not business rules (readiness Q-F1 is still
the owner's).
