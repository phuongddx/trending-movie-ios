# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

**Open `TrendingMovies.xcworkspace`** (root), not the `.xcodeproj`. The workspace groups the app target together with the two local SPM packages (`MoviesDomain`, `MoviesData`).

```bash
# Build / test / build+run via fastlane (CI uses this path)
bundle exec fastlane tests                                      # scan — runs full unit suite

# xcodebuild directly
xcodebuild -workspace TrendingMovies.xcworkspace -scheme trending-movie-ios \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build

xcodebuild test -workspace TrendingMovies.xcworkspace -scheme trending-movie-ios \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'

# Run a SINGLE test class or method
xcodebuild test -workspace TrendingMovies.xcworkspace -scheme trending-movie-ios \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:trending-movie-iosTests/MoviesListViewModelTests \
  -only-testing:trending-movie-iosTests/MoviesListViewModelTests/testExample
```

Prefer the **XcodeBuildMCP** tools over raw `xcodebuild` for build/run/test/screenshot. First call in a session must be `mcp__XcodeBuildMCP__session_show_defaults` to confirm project/scheme/simulator, then `build_run_sim` to launch.

CI (`.github/workflows/objective-c-xcode.yml`) runs `bundle exec fastlane tests` on every PR to `master` — keep this green.

- **Target:** iOS 14.0+, Swift 5.10, Xcode 15.4+
- **Tests:** `trending-movie-iosTests/` (Domain, Infrastructure, Presentation) + `trending-movie-iosUITests/`. Mocks live in `trending-movie-iosTests/Mocks/`.

## ⚠️ Critical: Two Parallel Domain/Data Layers

This is the single biggest trap in the repo. There are **two** copies of the domain + data layer:

| Where | Status | Notes |
|-------|--------|-------|
| `trending-movie-ios/Domain/`, `trending-movie-ios/Network/`, `trending-movie-ios/Data/` | **Active** — the app target compiles these | `Movie.swift`, `MovieFilters.swift`, `MovieQuery.swift`, `UseCases.swift`, `RealUseCases.swift`, `TMDBNetworkService.swift`, `TMDBResponseModels.swift`, `MovieStorage.swift` |
| `MoviesDomain/` + `MoviesData/` (local SPM packages) | **Dormant** — `grep` shows **0 `import MoviesDomain`/`import MoviesData`** anywhere in the app | Cleaner design (separate DTOs, `MoviesAPI` Moya enum, repository abstractions) but **not wired into the app target** |

The workspace references the SPM packages as groups, so they appear in Xcode, but the app does not depend on them. **Before editing domain/data code, confirm you are in the in-app `trending-movie-ios/` folders, not the SPM `Sources/` folders** — or you will edit code that nothing calls.

## Architecture (Clean Architecture + MVVM, callback-based)

Data flows **View → ViewModel → UseCase → `TMDBNetworkService` → Moya → TMDB API**, with DTOs mapped back to domain entities.

**Dependency Injection — Factory, one container.** `AppContainer` (`SharedContainer`) is the only container. All network service, repository, and use-case registrations live in `DI/AppContainer.swift` as `Factory<T>` properties (singletons for `tmdbNetworkService` + `posterImagesRepository`; use cases resolved fresh each call). `DI/PresentationContainer.swift` is an **extension of `AppContainer`** that adds SwiftUI ViewModels — there is no separate `PresentationContainer` type. ViewModels resolve their use cases via `self.someUseCase()`.

**Use-case contract — completion handlers, not async/await.** Every use case follows:
```swift
func execute(request: ..., cached: @escaping (MoviesPage) -> Void,
             completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable?
```
The `cached` closure fires first with disk/memory-cached data (instant UI), then `completion` fires with the fresh network result. `Cancellable?` lets the caller cancel in-flight requests. Implementations live in `Network/RealUseCases.swift`; protocols + `MoviesRequest`/`MovieFilters` value objects live in `Domain/UseCases.swift`.

**Networking.** `TMDBNetworkService` is a concrete `final class` (no protocol abstraction in the app layer) wrapping Moya. Call shape: `networkService.request(.trendingMovies(timeWindow:page:), type: TMDBMoviesResponse.self) { result in ... }`. The enum cases (`TMDBAPI`/endpoint cases) define the Moya `TargetType`; response DTOs in `Network/TMDBResponseModels.swift` implement `toDomain()` to map into `Movie`/`MoviesPage`.

**Presentation — SwiftUI + MVVM.** Screens in `Presentation/SwiftUI/Views/`, ViewModels in `Presentation/SwiftUI/ViewModels/`, reusable components in `Presentation/SwiftUI/Components/`. Navigation via `TabNavigation` (4 tabs: Home, Search, Downloads/Watchlist, Settings) + `AppDestination` route enum + Coordinator pattern.

## Design System

`Presentation/DesignSystem/` — `DSColors`, `DSTypography` (Montserrat, h1–h7 + body scale), `DSSpacing` (8pt grid), `DSThemeManager`, and components (`DSActionButton`, `DSIconButton`, `DSSearchBar`, `HeroCarousel`, `MovieCard`, `CategoryTabs`, `CinemaxTabBar`). Dark-theme-first (Cinemax-inspired). Full spec in `docs/cinemax-design-system-overview.md` + the `docs/figma-*.md` analyses.

## Network Configuration

TMDB config is hardcoded in `AppConfig` (`DI/AppContainer.swift`):
- Base URL: `https://api.themoviedb.org/3/`
- Images URL: `https://image.tmdb.org/t/p/`
- **API key is embedded in source and committed** — a real secret currently in git. Prefer moving it to an `.xcconfig`/env var before any further work that touches config.

## Key Dependencies

| Dependency | Purpose |
|------------|---------|
| Factory | DI (one `SharedContainer`, all registrations in `AppContainer`) |
| Moya + CombineMoya | Network abstraction over `URLSession`; `TargetType` enum endpoints |
| YouTubePlayerKit | In-app trailer playback on the movie detail screen |

## Conventions

- Use-case naming: protocol `XxxMoviesUseCaseProtocol` + impl `RealXxxMoviesUseCase`; each takes `TMDBNetworkService` in its initializer.
- DTOs map to domain via `toDomain()` — keep TMDB response shapes out of the domain layer.
- When adding a feature, wire it through all four layers: endpoint case → DTO (+`toDomain`) → use case protocol + `Real…` impl → `AppContainer` registration → ViewModel → View.
