
# Trending Movies Today

An iOS application designed to showcase today's trending movies using The Movie Database (TMDB) API. Built with Clean Layered Architecture and MVVM pattern featuring a modern SwiftUI interface with a custom design system.

![](https://github.com/phuongddx/trending-movie-ios/blob/master/Demo.gif)

## Features

- **Trending Movies List:** Explore the latest trending movies with a beautiful hero carousel.
- **Movie Categories:** Browse movies by categories including Popular, Now Playing, Top Rated, and Upcoming.
- **Detailed Movie Information:** Access comprehensive details about each movie including synopsis, release date, ratings, cast, and crew.
- **Trailer Playback:** Watch movie trailers directly in-app with YouTubePlayerKit integration.
- **Search Functionality:** Search for movies with support for offline mode using cached data.
- **Watchlist Management:** Save movies to your personal watchlist for later viewing.
- **Modern SwiftUI Design:** Beautiful dark theme UI following the Cinemax-inspired design language.
- **Custom Design System:** Consistent UI with DSColors, DSTypography, DSSpacing, and reusable components.
- **Accessibility Support:** Haptic feedback options and accessibility identifiers throughout the app.

## Requirements

- iOS 14.0+
- Xcode 15.4+
- Swift 5.10

## Installation

1. Clone the repository.
2. Open the `trending-movie-ios.xcodeproj` file in Xcode.
3. Run the application on your iOS device or simulator.

## Architecture

### Domain Layer
- **Entities:** Core data structures representing movie-related data (`Movie`, `MovieDetails`, `MovieQuery`).
- **Use Cases:** Business logic and interaction rules for fetching movies, searching, and managing queries.
- **Repository Interfaces:** Abstract definitions for data handling.

### Data Layer
- **Repository Implementations:** Concrete implementations of repository interfaces.
- **API (Network):** Handles network requests to the TMDB API via `TMDBNetworkService`.
- **Persistence DB:** Manages local data storage and caching via `MovieStorage`.

### Presentation Layer (MVVM)
- **ViewModels:** Handles presentation logic and prepares data for views (`HomeViewModel`, `ObservableMovieDetailsViewModel`, `SearchViewModel`).
- **Views:** SwiftUI views and components with push navigation.

## Design System

The app features a comprehensive custom design system located in `Presentation/DesignSystem/`:

### DSColors
- Primary colors (dark theme optimized)
- Semantic colors for success, warning, error states
- SwiftUI color extensions

### DSTypography
- Montserrat font family integration
- Heading styles (h1-h7)
- Body styles (large, medium, small, caption)
- SwiftUI font extensions

### DSSpacing
- 8pt grid system with predefined spacing units
- Component-specific padding and margins
- Corner radius values
- Layout constraints

### Components
- `DSActionButton` - Styled buttons with multiple variants (primary, secondary, destructive)
- `DSIconButton` - Icon-only buttons with accessibility support
- `DSSearchBar` - Search input component
- `HeroCarousel` - Featured movie carousel
- `MovieCard` - Movie poster card with skeleton loading
- `CategoryTabs` - Category filter tabs
- `CinemaxTabBar` - Custom bottom navigation

## Navigation

The app uses SwiftUI navigation with:
- `TabNavigationView` for main app structure with 4 tabs (Home, Search, Downloads, Profile)
- `AppDestination` for route definitions
- Push navigation for movie details

## Dependency Injection

Uses Factory pattern for dependency injection with two main containers:
- `AppContainer`: Core dependencies (network service, repositories, use cases)
- `PresentationContainer`: UI-specific ViewModels

## Key Dependencies

| Dependency | Purpose |
|------------|---------|
| Factory | Dependency injection framework |
| Moya | Network abstraction layer |
| CombineMoya | Combine integration for Moya |
| YouTubePlayerKit | Trailer playback functionality |

## Network Configuration

TMDB API configuration in `AppContainer.swift`:
- Base URL: `https://api.themoviedb.org/3/`
- Images URL: `https://image.tmdb.org/t/p/`

## Testing

Test files are organized in `trending-movie-iosTests/` with:
- Unit tests for ViewModels, Use Cases, and Network services
- Mock implementations for testing
- Test coverage for SwiftUI components

Run tests via Fastlane:
```bash
bundle exec fastlane tests
```

Or directly with xcodebuild:
```bash
xcodebuild test -project trending-movie-ios.xcodeproj -scheme trending-movie-ios -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max'
```

## How to Use the App

### Browsing Movies
1. Launch the app to see trending movies in the hero carousel.
2. Scroll down to browse "Most Popular" movies.
3. Use category tabs to filter by different movie types.

### Searching for a Movie
1. Navigate to the Search tab.
2. Enter the name of a movie in the search bar.
3. Results will display matching movies.

### Viewing Movie Details
1. Tap on any movie card to view detailed information.
2. See synopsis, cast, crew, and ratings.
3. Tap "Trailer" button to watch the movie trailer.
4. Add movies to your watchlist using the bookmark button.

### Managing Watchlist
1. Navigate to the Downloads tab to view saved movies.
2. Remove movies by tapping the bookmark icon again.

## Project Structure

```
trending-movie-ios/
├── App/                    # AppDelegate, SceneDelegate
├── DI/                     # Dependency Injection containers
├── Domain/                 # Entities, UseCase protocols
├── Data/                   # Storage implementations
├── Network/                # Network services, API models
├── Presentation/
│   ├── DesignSystem/       # Colors, Typography, Spacing, Components
│   ├── SwiftUI/
│   │   ├── Views/          # Screen views (HomeView, MovieDetailsView)
│   │   ├── ViewModels/     # Observable ViewModels
│   │   ├── Components/     # Reusable UI components
│   │   ├── Navigation/     # Tab navigation
│   │   └── Coordinators/   # Navigation destinations
│   └── Utils/              # Extensions, utilities
├── Resources/              # Assets, fonts
└── MoviesDomain/           # Domain module (SPM)
```

## Contributing

Feel free to submit pull requests!

## License

This project is available under the MIT license.
