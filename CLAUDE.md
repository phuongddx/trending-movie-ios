# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Structure

This is an iOS app that showcases trending movies using The Movie Database (TMDB) API. The codebase follows Clean Architecture principles with distinct layers:

### Architecture Layers
- **Domain Layer**: Core business logic, entities (Movie, MovieQuery), and use case protocols in `Domain/` and separate `MoviesDomain` module
- **Data Layer**: Network services, repositories, and storage implementations in `Data/` and separate `MoviesData` module
- **Presentation Layer**: SwiftUI views, ViewModels, design system components in `Presentation/`

### Dependency Injection
Uses Factory pattern for DI with two main containers:
- `AppContainer`: Core dependencies (network, repositories, use cases)
- `PresentationContainer`: UI-specific ViewModels

Key files:
- `DI/AppContainer.swift`: Main DI container with singletons for network service and repositories
- `DI/PresentationContainer.swift`: Extension for SwiftUI ViewModels

## Development Commands

### Building and Testing
```bash
# Build the project (use Xcode or xcodebuild)
xcodebuild -project trending-movie-ios.xcodeproj -scheme trending-movie-ios build

# Run tests via Fastlane
bundle exec fastlane tests

# Run tests directly
xcodebuild test -project trending-movie-ios.xcodeproj -scheme trending-movie-ios -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'
```

### XcodeBuildMCP (Recommended for iOS Development)
Use XcodeBuildMCP tools for Apple platform development instead of raw bash commands:
- `mcp__XcodeBuildMCP__build_sim` - Build for iOS Simulator
- `mcp__XcodeBuildMCP__build_run_sim` - Build and run on simulator
- `mcp__XcodeBuildMCP__test_sim` - Run tests on simulator
- `mcp__XcodeBuildMCP__screenshot` - Capture simulator screenshot
- `mcp__XcodeBuildMCP__snapshot_ui` - Print view hierarchy

First, set session defaults:
```
mcp__XcodeBuildMCP__session_set_defaults with projectPath, scheme, simulatorName
```

### Requirements
- iOS 14.0+
- Xcode 15.4+
- Swift 5.10

## Key Dependencies
- **Factory**: Dependency injection framework
- **Moya**: Network abstraction layer
- **CombineMoya**: Combine integration for Moya

## Network Configuration
TMDB API configuration is hardcoded in `AppContainer.swift`:
- Base URL: `https://api.themoviedb.org/3/`
- Images URL: `https://image.tmdb.org/t/p/`
- API Key: Embedded in AppConfig (consider moving to environment variables)

## Testing
Test files are organized in `trending-movie-iosTests/` with:
- Unit tests for ViewModels, Use Cases, and Network services
- Mock implementations for testing
- Test coverage for both UIKit and SwiftUI components

## Design System
Custom design system in `Presentation/DesignSystem/` includes:
- Colors (`DSColors`)
- Typography (`DSTypography`)
- Spacing (`DSSpacing`)
- Reusable components (`DSActionButton`, `DSTabView`, etc.)

## Navigation
Uses SwiftUI navigation with:
- `TabNavigation` for main app structure
- `AppDestination` for route definitions
- Coordinator pattern for navigation flow