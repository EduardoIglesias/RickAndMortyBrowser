# RickAndMortyBrowser

SwiftUI iOS app to browse **Rick and Morty** characters: list with search/filter and a character detail screen.

Repository: https://github.com/EduardoIglesias/RickAndMortyBrowser

## Requirements

- macOS + **Xcode**
- **iOS Deployment Target:** 18.6
- Internet connection (Rick and Morty public API)

Optional:
- SwiftLint (`brew install swiftlint`)

## Run the app

1. Clone:
   - `git clone https://github.com/EduardoIglesias/RickAndMortyBrowser.git`
   - `cd RickAndMortyBrowser`

2. Open in Xcode:
   - Open `RickAndMortyBrowser.xcodeproj`

3. Select a simulator and run:
   - Scheme: `RickAndMortyBrowser`
   - Run: **⌘R**

## Run tests

- Unit tests: **⌘U**
- UI tests: included in `RickAndMortyBrowserUITests`

## SwiftLint

SwiftLint runs:
- In CI (GitHub Actions)
- Locally via an Xcode Run Script Phase (only if `swiftlint` is installed)

Install:
- `brew install swiftlint`
- `swiftlint version`

If `swiftlint --strict` fails due to SourceKit/Xcode selection, try:
- `DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer" swiftlint --strict`

## CI

GitHub Actions workflow runs on pushes/PRs:
- SwiftLint
- Build & tests

Workflow: `.github/workflows/ci.yml`

## Technical decisions

### Architecture (Clean-ish + SOLID)
- **Domain**
  - Entities: `RMCharacter`, `RMPageInfo`
  - Repository protocols
  - Use cases (e.g. `FetchCharactersPageUseCase`, `FetchCharacterDetailUseCase`)
- **Data**
  - Remote data source + DTOs
  - Repository implementation(s)
  - Networking isolated behind `NetworkClient`
- **Presentation**
  - SwiftUI Views + ViewModels

This keeps the UI layer independent from networking and improves testability.

### Dependency Injection
- Centralized DI in `AppDIContainer`
- Views get ViewModels through DI (no business-logic singletons)

### Networking
- `DefaultNetworkClient` uses `URLSession` + `Decodable`
- Errors mapped to `NetworkError` (transport, invalidResponse, httpStatus, decodingFailed)

### Pagination
- Infinite scrolling with a small **buffer** so UI consumes items in chunks
- Guards in ViewModel to avoid multiple load-more triggers in the same frame

### Caching (reduce API calls)
- In-memory caching in the repository:
  - Character cache by `id` (detail can be served from list cache)
  - Page cache by `(remotePage, filter)` with TTL to avoid repeated remote fetches

### Image loading
- Custom image pipeline:
  - NSCache in-memory caching
  - in-flight request de-dup per URL
  - retries
  - prefetch on page loads to reduce “fast scroll” image failures
- Detail uses the same cached component for consistency

### UI/UX
- List rows show: **name, image, status** (plus species)
- Detail shows: **image, name, status, species, gender, current location, origin**
- Filtered empty state with Rick & Morty themed copy
- Simple animations for state transitions and detail appearance
- Launch Screen included (`LaunchScreen.storyboard`)

## Troubleshooting

### Launch screen image not visible
iOS caches launch screen snapshots:
- Delete the app from the simulator
- Clean build folder (⇧⌘K)
- Simulator: Device → Shut Down / Boot (or Erase All Content and Settings)

## API
Data source: https://rickandmortyapi.com/
