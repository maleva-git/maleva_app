# MALEVA architecture

## Dependency direction

Migrated pages use presentation → BLoC/controller → repository → transport or platform adapter. GetIt composes dependencies; feature logic receives them through constructors. BLoC remains the state owner. Local visual state can remain in widgets. No additional Provider state layer is introduced.

Compatibility adapters preserve each existing HTTP/Dio contract. They do not normalize error results, identity, preference keys or request scheduling. Stock repositories capture identity at construction; request-time global readers remain live. BlocProvider closes BLoCs it creates; borrowed instances retain their original owners.

## Verification

Run `bash tool/verify_architecture.sh`. It uses the installed Flutter SDK and existing dependencies, runs analyzer and tests even when analysis fails, and exits nonzero if either check fails. See [verification record](architecture-verification.md) for inherited failures and actual results. Structural widget tests use a local SDK font and do not certify production typography.

## Migration status

Implementation is in progress; the complete per-module adoption matrix is pending. No unlisted feature is claimed migrated. Native configuration, routes, business rules and wire contracts remain outside redesign scope.
