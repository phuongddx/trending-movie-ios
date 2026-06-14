# Codebase Summary

## Overview
Trending Movies iOS application built with SwiftUI, Clean Architecture, and MVVM pattern. ~13,632 LOC across 108 Swift files with comprehensive test coverage.

## Architecture Layers

### Domain Layer
- **Files**: 4 files in `Domain/`
- **Purpose**: Core business logic, entities, and use case protocols
- **Key Components**:
  - `Movie.swift` - Movie entity with Equatable/Codable
  - `MovieFilters.swift` - Filter configuration for movie discovery
  - `MovieQuery.swift` - Query parameter types
  - `UseCases.swift` - Use case protocols and request/response types

### Data Layer
- **Files**: 4 files in `Data/Network/` and `Data/Storage/`
- **Purpose**: Network services and data persistence
- **Key Components**:
  - `TMDBNetworkService.swift` - Moya-based network service
  - `RealUseCases.swift` - Concrete use case implementations
  - `TMDBResponseModels.swift` - API response DTOs
  - `MovieStorage.swift` - UserDefaults-based movie storage

### Presentation Layer
- **Files**: 79 files in `Presentation/`
- **Purpose**: SwiftUI views, ViewModels, design system
- **Sub-structure**:
  - `SwiftUI/Views/` - Main app views (9 files)
  - `SwiftUI/ViewModels/` - MVVM ViewModels (5 files)
  - `SwiftUI/Components/` - Reusable UI components (42 files across multiple sub-folders)
  - `SwiftUI/Navigation/` - Navigation and routing (2 files)
  - `DesignSystem/` - Design system foundation (11 files)
  - `Utils/` - Utility functions (5 files)

### Dependency Injection
- **Files**: 2 files in `DI/`
- **Purpose**: Single container architecture
- **Key Components**:
  - `AppContainer.swift` - Main shared container with all registrations
  - `PresentationContainer.swift` - Extension for SwiftUI ViewModels

### App Layer
- **Files**: 4 files in `App/`
- **Purpose**: App lifecycle and configuration
- **Key Components**:
  - AppDelegate, SceneDelegate
  - `AppConfigurations.swift` - App configuration
  - `AppAppearance.swift` - Theme and appearance setup

### Common Layer
- **Files**: 1 file in `Common/`
- **Purpose**: Shared utilities
- **Key Components**:
  - `DispatchQueueType.swift` - Testable dispatch abstraction

## Test Infrastructure

### Unit Tests
- **Location**: `trending-movie-iosTests/`
- **Coverage**: ~1,048 LOC across multiple test categories
- **Structure**:
  - `Domain/` - Domain logic tests
  - `Infrastructure/` - Network and data transfer tests
  - `Presentation/` - ViewModel and UI logic tests
  - `Mocks/` - Mock implementations for testing
  - `Stubs/` - Test data stubs

## Critical Architecture Note: Two Parallel Domain/Data Layers

### ACTIVE Implementation (Integrated)
Located in the app target:
- `trending-movie-ios/Domain/`
- `trending-movie-ios/Network/`
- `trending-movie-ios/Data/`
- **Status**: Compiled into app, fully functional

### DORMANT Implementation (SPM Packages)
Located in SPM packages but NOT integrated:
- `MoviesDomain/` - Clean domain design with DTOs
- `MoviesData/` - Repository pattern implementation
- **Status**: Not imported or used in the app
- **Warning**: This creates architectural inconsistency - new contributors may be confused

## Key Dependencies

| Dependency | Purpose | Version |
|------------|---------|---------|
| Factory | Dependency injection framework | Latest |
| Moya | Network abstraction over URLSession | Latest |
| CombineMoya | Combine integration for Moya | Latest |
| YouTubePlayerKit | In-app trailer playback | Latest |

## Entry Points

### Primary Entry
- **File**: `TrendingMovies.xcworkspace`
- **Target**: `trending-movie-ios` app target
- **Packages**: Includes dormant `MoviesDomain` and `MoviesData` SPM packages

### App Lifecycle
- **Main Storyboard**: SwiftUI app lifecycle
- **Launch**: App initialization via AppContainer DI setup

## Network Configuration
- **Base URL**: `https://api.themoviedb.org/3/`
- **Images URL**: `https://image.tmdb.org/t/p/`
- **API Key**: Hardcoded in `AppContainer.swift` - **SECURITY RISK**

## File Size Distribution
- **App Target**: ~13,632 LOC (108 files)
- **SPM Packages**: ~1,146 LOC (dormant, not integrated)
- **Tests**: ~1,048 LOC (integrated test suite)

## Key Design Patterns
- **Clean Architecture**: Layered separation of concerns
- **MVVM**: Model-View-ViewModel for UI logic
- **Factory Pattern**: Single container dependency injection
- **Protocol-Oriented**: Use case protocols and value objects
- **Combine**: Reactive programming for asynchronous operations

## Known Technical Issues
1. **API Key Security**: Hardcoded API key in source code
2. **Repository Pattern**: Missing abstraction layer
3. **SPM Package Integration**: Dormant packages create confusion
4. **Error Handling**: Inconsistent error handling across layers