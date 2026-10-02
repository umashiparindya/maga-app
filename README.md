# Maga mobile application

Maga is an Android-primary Flutter prototype for the research project **The
Influence of Social Media Content on Travel Destination Choice among Sri Lankan
Youth**. It collects a small set of travel preferences and returns a
deterministic, explainable ranking of bundled Sri Lankan destinations.

The app is deliberately local and rule-based. It does not use authentication,
Firebase, machine learning, generative AI, live social-media analytics,
bookings, payments, chat, or scraping.

## Quick start

Install Flutter 3.47.5 or a compatible stable release, then run these commands
from the repository root:

```bash
flutter pub get
flutter analyze
flutter test
flutter test integration_test
flutter build apk --debug
```

The debug APK is generated at
`build/app/outputs/flutter-apk/app-debug.apk`. To run it on an Android emulator,
start a supported emulator and use:

```bash
flutter devices
flutter run -d <device-id>
```

The technical package identity is `mashi_smoke` and the Android application ID
is `com.example.mashi_smoke`. Keep those identifiers unchanged unless the
package migration is explicitly planned and the existing evidence is updated.

## Project guidance

This directory is controlled by the following documents:

1. [AGENTS.md](AGENTS.md): mandatory rules for every AI coding agent.
2. [PROJECT_CONTRACT.md](PROJECT_CONTRACT.md): frozen research, product, data,
   and scoring decisions.
3. [APP_BUILD_GUIDE.md](APP_BUILD_GUIDE.md): architecture and implementation
   guidance.
4. [BUILD_ROADMAP.md](BUILD_ROADMAP.md): gated build steps and tests. Give an
   agent one step at a time.
5. [THESIS_EVIDENCE_MATRIX.md](THESIS_EVIDENCE_MATRIX.md): evidence required
   before making claims in the final thesis.

The core implementation is under `lib/`, automated tests are under `test/` and
`integration_test/`, and Android configuration is under `android/`.

The original survey workbook is intentionally excluded from this repository.
It contains research source data and is not required to build or run the app.

## Development commands

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter test integration_test
flutter build apk --debug
```

Read AGENTS.md before making any change. Do not treat this as a generic Flutter
starter app. The implementation must stay deterministic, rule-based, and aligned
with the research contract.
