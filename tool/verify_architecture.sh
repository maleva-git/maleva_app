#!/usr/bin/env bash
# Run from any directory; use the caller's existing Flutter SDK and dependencies.
set -u
cd "$(dirname "$0")/.." || exit 1
result=0
flutter analyze --no-pub || result=1
flutter test --no-pub || result=1
exit "$result"
