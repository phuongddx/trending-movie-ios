# Code Standards & Conventions

## Architecture Standards

### Clean Architecture + MVVM
**Mandatory**: All new features must follow Clean Architecture with strict layer separation:

```
┌─────────────────┐
│   Presentation  │
│   (SwiftUI)     │
├─────────────────┤
│     Domain      │
│   (Business     │
│    Logic)       │
├─────────────────┤
│      Data       │
│ (Network/Storage)│
└─────────────────┘
```

### Layer Responsibilities
- **Domain**: Pure business logic, entities, use case protocols, value objects
- **Data**: Network services, repositories, storage, data transfer objects
- **Presentation**: SwiftUI views, ViewModels, UI components, navigation

### MVVM Pattern Requirements
- **Models**: Domain entities (Movie, MovieFilters, etc.)
- **Views**: SwiftUI views with minimal logic, bind to ViewModels
- **ViewModels**: `ObservableObject` containing state and business logic, no direct data access

## Naming Conventions

### Swift File Naming
- Use PascalCase for Swift files matching their primary class/struct
- **Examples**: `Movie.swift`, `SearchViewModel.swift`, `TMDBNetworkService.swift`

### Type Naming
- **Classes**: PascalCase (`NetworkService`, `AppContainer`)
- **Structs**: PascalCase (`Movie`, `MovieFilters`, `SearchRequest`)
- **Protocols**: PascalCase prefixed with "I" or descriptive name (`UseCase`, `MovieQuery`)
- **Enums**: PascalCase (`MovieCategory`, `ViewMode`)
- **Variables**: camelCase (`movieTitle`, `isLoading`, `moviesList`)
- **Constants**: PascalCase (`API_KEY`, `BASE_URL`)

### File Organization
- **Presentation**: `Presentation/SwiftUI/{Views|ViewModels|Components|Navigation|Utils}`
- **Domain**: `Domain/{Entities|UseCases}`
- **Data**: `Data/{Network|Storage}`
- **DI**: `DI/{AppContainer|PresentationContainer}`

## Dependency Injection Rules

### Single Container Architecture
**Mandatory**: Use only `AppContainer` as the shared dependency container.

### Container Registration Rules
1. **Singletons**: Network services, repositories, app configuration
2. **Fresh Instances**: Use cases (business logic should be fresh per call)
3. **No Manual DI**: Never use `@Inject` or manual dependency creation

### AppContainer Requirements
```swift
class AppContainer: SharedContainer {
    // Singletons
    let appConfiguration: AppConfigurationProtocol
    let tmdbNetworkService: TMDBNetworkServiceProtocol
    let posterImagesRepository: PosterImagesRepositoryProtocol
    
    // Fresh instances for each use
    func makeSearchMoviesUseCase() -> SearchMoviesUseCaseProtocol
    func makeTrendingMoviesUseCase() -> TrendingMoviesUseCaseProtocol
    // ... other use cases
}
```

### Presentation Container Extension
**Mandatory**: Extend `AppContainer` for SwiftUI ViewModels, never create separate container.

## Network Architecture

### TMDB API Integration
- **Service**: `TMDBNetworkService` as final concrete class
- **Endpoints**: Enum conforming to Moya `TargetType`
- **Response Models**: `TMDBResponseModels` with `toDomain()` mapping
- **Request/Response**: Callback pattern (not async/await)

### Network Service Rules
1. **No Protocol Abstractions**: Use concrete service classes at app layer
2. **Moya Integration**: All endpoints via `networkService.request(endpoint, type:)`
3. **Error Handling**: Consistent error propagation through Result<MoviesPage, Error>
4. **Caching**: Implement `cached:` callback for immediate UI updates

## Data Layer Standards

### Movie Storage
- **Technology**: UserDefaults + Codable
- **Keys**: Constant strings (`watchlist`, `favorites`)
- **Encryption**: Built-in UserDefaults security
- **Functions**: `loadWatchlist()`, `loadFavorites()`, `saveStoredMovies()`

### Repository Pattern
**Current Issue**: Missing abstraction layer - TODO: implement proper repository pattern
**Temporary Solution**: Direct service calls in `RealUseCases.swift`

## Presentation Layer Standards

### SwiftUI View Architecture
- **State Management**: Use `@State`, `@Binding`, `@EnvironmentObject`
- **MVVM**: Views bind to ViewModels, never access data layer directly
- **Navigation**: Use `NavigationStack` with `AppDestination` enum
- **Error Handling**: Dedicated `ErrorView` component for consistent error display

### View Requirements
1. **Minimal Logic**: Views should only handle UI presentation and user input
2. **State Delegation**: Business logic in ViewModels
3. **Accessibility**: Support Dynamic Type, VoiceOver, reduced motion

### Component Naming
- **Components**: PascalCase with purpose prefix (`MovieCard`, `SearchBar`, `FilterChip`)
- **Modular Components**: Each component should be self-contained and reusable
- **Design System**: Use `DS` prefix for design system components (`DSActionButton`, `DSColors`)

## Testing Standards

### Test Organization
- **Unit Tests**: `trending-movie-iosTests/` with proper test structure
- **Mock Objects**: Dedicated `Mocks/` folder for test doubles
- **Test Coverage**: Minimum 80% coverage for business logic and ViewModels

### Test Naming
- **Convention**: `test[MethodName]_[Scenario]`
- **Examples**: `testSearchMovies_validQuery_returnsMovies`, `testTrendingMovies_networkError_returnsFailure`

### Test Requirements
1. **ViewModel Tests**: Test state changes and business logic
2. **Use Case Tests**: Test business rules and edge cases
3. **Network Tests**: Test API integration with mocked responses
4. **Integration Tests**: Test View-ViewModel binding

## Design System Standards

### Component Guidelines
- **Consistency**: Use established `DS` prefixed components
- **Color System**: `DSColors` for all colors - no hardcoded values
- **Typography**: `DSTypography` for all text - use semantic styles
- **Spacing**: `DSSpacing` for all layouts - 8pt grid system

### Theme Management
- **Dark Theme First**: Primary design theme is dark
- **Dynamic Support**: Support for light mode variations
- **Accessibility**: Respect user appearance preferences

## Error Handling Standards

### Consistent Error Propagation
```swift
enum AppError: Error {
    case networkError(Error)
    case decodingError
    case noResults
    case apiError(Int)
}
```

### Error Display
- **Views**: Use `ErrorView` component for consistent error display
- **ViewModels**: Handle errors and expose error states
- **Network**: Map API errors to domain errors

## Security Standards

### API Key Management
**Critical Issue**: API key is hardcoded - **IMMEDIATE ACTION REQUIRED**
**Solution**: Move to environment variables or `.xcconfig` files
**Priority**: HIGH - Security risk

### Data Storage
- **Watchlist/Favorites**: Use UserDefaults with built-in encryption
- **No Sensitive Data**: Never store personally identifiable information
- **Network Security**: Secure HTTPS with certificate validation

## File Size Management

### File Size Limits
- **Maximum**: 200 lines per Swift file
- **Split Strategy**: Extract logic into smaller, focused components
- **Composition**: Prefer composition over inheritance for complex widgets

### Refactoring Rules
1. **Large Files**: Split into smaller modules following logical boundaries
2. **Utility Functions**: Extract into separate modules
3. **Business Logic**: Keep use cases focused on single responsibility

## Code Quality Guidelines

### Readability
- **Clear Naming**: Self-documenting variable and function names
- **Comments**: meaningful comments for complex logic, not obvious code
- **Formatting**: Consistent indentation and spacing

### Maintainability
- **YAGNI**: Implement only what's needed, avoid over-engineering
- **DRY**: Extract common functionality into reusable components
- **Separation**: Clear boundaries between layers and concerns

### Performance
- **Memory Management**: Avoid retain cycles in ViewModels
- **Network Efficiency**: Implement caching and batch requests
- **UI Performance**: Optimize scrolling animations and list rendering

## Documentation Standards

### Code Documentation
- **Public APIs**: Document all public interfaces and methods
- **Complex Logic**: Add comments explaining business rules and algorithms
- **TODO Items**: Document technical debt with clear action items

### Architecture Documentation
- **Layer Boundaries**: Document data flow between layers
- **Dependency Rules**: Document DI container usage patterns
- **State Management**: Document how state flows through the app

## Known Technical Debt
1. **API Key Security**: Hardcoded API key (priority: HIGH)
2. **Repository Pattern**: Missing abstraction layer (priority: MEDIUM)
3. **SPM Integration**: Dormant packages causing confusion (priority: LOW)
4. **Error Handling**: Inconsistent error mapping (priority: MEDIUM)