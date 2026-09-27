# Medication Reference

A Flutter mobile application for browsing, searching, and saving medication information from the public [openFDA Drug Labeling API](https://open.fda.gov/apis/drug/label/).

This is a technical take-home exercise. The displayed information is not medical advice.

## Requirements

- Flutter 3.44.4 / Dart 3.12.2, pinned through FVM (`.fvmrc`)
- FVM
- Internet connection
- Android or iOS toolchain for device runs

No private API key, personal credential, Firebase file, or backend credential is required.

## Setup

```bash
fvm install
fvm flutter pub get
```

If FVM is not available, install the Flutter version specified in `.fvmrc` and replace `fvm flutter` with `flutter`.

## Run

```bash
fvm flutter run
```

The application calls the public openFDA endpoint directly. Internet access is required.

## Build Android APK

```bash
fvm flutter build apk --debug
```

The installable debug APK is generated at `build/app/outputs/flutter-apk/app-debug.apk`.
The first build downloads Gradle and any missing Android dependencies, so it can take several minutes.
The Android manifest declares internet access for all build modes.

## Build iOS without signing

On macOS with Xcode installed:

```bash
fvm flutter build ios --no-codesign
```

The reviewer can compile without the author's Apple account. Installing on a physical iPhone requires signing with the reviewer's own team.

### Verification

- On 26 September 2026, Flutter analysis, Android debug APK build, and unsigned iOS build passed. The Android APK package, internet permission, and signature were checked. A fresh clone also built successfully.
- On 26 September 2026, the app launched on an iPhone simulator and received HTTP 200 from openFDA. Physical-device testing has not been performed.
- On 27 September 2026, after the search, data-filtering, and language-switching changes, `fvm flutter analyze --no-pub` reported no issues, all 28 automated tests passed with `fvm flutter test --no-pub`, the Android debug APK built, and an unsigned iOS device build succeeded.

## Test and quality checks

```bash
fvm flutter analyze
fvm flutter test
```

The tests cover successful API parsing, missing fields, openFDA no-match results, server errors, simulated HTTP 429 retry/backoff, filtered pagination, stale responses, favorites persistence failures, Cubit transitions, live-search debounce, language switching and persistence, localized loading/empty/error/retry UI, and a dark-mode medication-card golden image. No test intentionally stresses the live API.
Golden baselines are stored under `test/goldens/`; update them intentionally with `fvm flutter test --update-goldens` after reviewing the rendered image.

## Architecture overview

The project follows a small feature-based clean architecture:

```text
presentation → domain ← data
```

- `domain` contains framework-independent entities and repository contracts.
- `data` contains Dio data sources, defensive JSON mapping, and repository implementations.
- `presentation` contains Cubits, pages, and feature-specific widgets.
- `core` contains configuration, failures, networking, localization, theme tokens, context extensions, and reusable state widgets.

State management uses focused Cubits:

- `MedicationListCubit` handles initial loading, refresh, search, and load more.
- `FavoritesCubit` handles local favorites and persistence.

The UI is composed from reusable widgets such as `MedicationCard`, `FavoriteButton`, `MedicationInfoSection`, `AppLoadingView`, `AppEmptyView`, and `AppErrorView`. The list and favorites views are separate widgets below the home navigation.

Search starts after two characters and a 350 ms pause in typing. The loading state updates immediately; stale responses are ignored and clearing the field restores the full list. API records without a brand or generic name are omitted from the list, while pagination still advances by the number of records fetched from openFDA.

## Localization and design system

English and Bahasa Indonesia are defined in:

```text
lib/l10n/app_en.arb
lib/l10n/app_id.arb
```

User-facing strings are accessed through `context.l10n`. The AppBar menu switches between English and Bahasa Indonesia, and the choice is persisted locally; with no saved choice, the device locale is used. Colors, typography, spacing, and component styling are centralized in `lib/core/theme/`, with `context.colors`, `context.textStyles`, and `context.spacing` extensions used by presentation code. Light and dark themes follow the device setting automatically.

## Known limitations

- The app depends on the availability and public rate limits of openFDA.
- Favorites are stored locally on the device and are not synchronized between devices.
- The detail screen uses the data already loaded for the selected medication; a production app could add a dedicated detail endpoint/cache strategy.
- The public API is accessed directly for this exercise. A production hospital application should use a backend gateway for caching, authentication, auditing, and rate-limit control.

## Approximate time spent

Approximately 5 calendar days elapsed across implementation, review, bug fixes, and verification. Active hands-on hours were not tracked separately.

## Improvements with more time

- Add automatic infinite scrolling with a visible load-more retry footer.
- Add richer API query behavior and local caching.
- Add broader accessibility checks and integration tests on real devices.
- Add a backend gateway before integrating the feature into a hospital platform.

## License

This repository is provided for the take-home evaluation and is not intended for clinical use.
