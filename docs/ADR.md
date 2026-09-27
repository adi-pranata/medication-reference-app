# Architecture Decision Record

## Context

The application must provide medication browsing, search, details, favorites, localization, error handling, and automated tests within a short take-home exercise. The source data comes from the public openFDA Drug Labeling API, whose fields can be missing, repeated, or represented as arrays.

## Decisions

### BLoC/Cubit state management

Focused Cubits are used for medication list and favorites state. Cubit keeps the state transitions explicit, avoids putting business logic in Widgets, and is straightforward to test. A single global Cubit was avoided because it would couple unrelated screens.

### Feature-based clean architecture

The dependency direction is `presentation → domain ← data`. API JSON is converted to domain entities before reaching the UI. This keeps openFDA-specific parsing out of Widgets and makes the data source replaceable with a fake or a future hospital backend.

### Dependency injection

`get_it` provides explicit registration of Dio, data sources, repositories, and Cubits. The setup is small enough for this application while keeping construction out of pages and making repository/Cubit tests independent from the production graph.

### Local persistence

Favorites use SharedPreferences because the stored dataset is small and does not require relational queries. The saved representation contains enough medication data to reopen details without immediately requiring another API call. A larger product would use a local database and synchronization strategy.

The JSON persistence mapper lives in the favorites data layer so the domain entity stays independent of storage. Favorites are shown as updated only after a successful write; failed writes keep the previous list and show localized feedback.

### Networking and rate limits

Dio is configured with timeouts. Low-level Dio exceptions are mapped to application failures for network, server, invalid-data, and rate-limit cases. HTTP 429 is retried a bounded number of times with backoff; the delay is injectable so tests do not wait in real time or contact the live API.

Labels without a usable brand or generic name are excluded from browsing rather than rendered as unidentified medications. Missing individual fields remain optional. Pagination uses the count of raw API records consumed, so filtering does not repeat or skip source pages.

`pretty_dio_logger` is registered once in the shared Dio factory, only in debug mode. It shows request URLs, response status and duration, and errors. Successful response bodies are omitted because openFDA labels can be very large. No HTTP logger is registered in profile or release builds.

### Localization and reusable UI

Flutter built-in localization with ARB files is used for English and Bahasa Indonesia. User-facing strings are not embedded in Widgets. Theme extensions centralize spacing and the Material theme centralizes colors and typography. Reusable state views, medication cards, detail sections, and search controls reduce duplication without introducing generic abstractions without a repeated responsibility.

The app follows the device's light/dark setting with the same seeded color scheme. List and favorites content are separate widgets, while the favorite action is shared between cards and detail pages.

The AppBar language menu changes the app locale without restarting. The selected locale is stored in SharedPreferences; if none is saved, Flutter follows the device locale. Search input immediately changes presentation state, but requests are debounced for 350 ms after at least two characters. The Cubit discards stale request results when the query changes.

### Testing strategy

Repository tests fake Dio and inject a delay callback to verify HTTP 429 backoff without contacting openFDA. Cubit tests cover loading and failure transitions, filtered pagination, stale responses, and failed favorite writes. Widget tests cover live search, language selection, localized empty/error/retry states, and save feedback. Locale persistence has focused tests. A golden image protects the dark medication card layout with long and missing fields.

## Trade-offs

- Direct openFDA access keeps the submission credential-free and simple, but a production system should put a controlled backend gateway in front of external APIs.
- SharedPreferences is easy to audit and sufficient for a small favorite list, but it is not suitable for large datasets or complex synchronization.
- A load-more action is simpler and more deterministic than aggressive automatic scrolling within the time limit.
- The project uses a modest number of layers; additional use-case classes can be introduced when business workflows become more complex.

## Scaling to a hospital application

The medication feature can remain an independent feature module while appointments, medical records, laboratory results, prescriptions, and notifications receive their own domain/data/presentation modules. Shared infrastructure can provide authentication, secure storage, API clients, caching, analytics, audit logging, feature flags, and a design system. External drug data should be fetched and cached by a backend gateway, with authorization, observability, and clinical governance handled centrally.
